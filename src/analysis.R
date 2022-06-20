############
## Craig Brinkerhoff
## Spring 2022
## Main functions for classifying epehmeral streams along the NHD
#################

#' extracts water table depth at the NHD flowlines. How the pixels are summarized at each reach is specified in the summariseWTD() function within '~/src/utils.R``
#'
#' @note Be aware of the expilict repo structure within the data repo, i.e. even though the user specifies the path to the data repo, there are assumed internal folders.
#'
#' @param path_to_data: data repo path directory
#' @param huc4: huc basin level 4 code
#' @param widAHG: width~Q AHG model from Brinkerhoff et al (in review GBC)
#' @param depAHG: depth~Q AHG model from Brinkerhoff et al (in review GBC)
#'
#' @import terra
#' @import sf
#' @import dplyr
#'
#' @return NHD hydrograpy with mean monthly water table depths attached.
extractWTD <- function(path_to_data, huc4){
  sf::sf_use_s2(FALSE)

  huc2 <- substr(huc4, 1, 2)

  #get basin to clip wtd model
  basins <- vect(paste0(path_to_data, '/HUC2_', huc2, '/WBD_', huc2, '_HU2_Shape/Shape/WBDHU4.shp')) #basin polygon
  basin <- basins[basins$huc4 == huc4,]

  #Process-based water table depth modeling
  wtd <- rast(paste0(path_to_data, '/for_ephemeral_project/conus_MF6_SS_Unconfined_250_dtw.tif'))   #monthly averages for hourly model runs for 2004-2014
  wtd$wtd_m <- wtd$conus_MF6_SS_Unconfined_250_dtw * -1 #(convert to depth below water table)

  #USGS NHD
  dsnPath <- paste0(path_to_data, '/HUC2_', huc2, '/NHDPLUS_H_', huc4, '_HU4_GDB/NHDPLUS_H_', huc4, '_HU4_GDB.gdb')
  nhd <- sf::st_read(dsn=dsnPath, layer='NHDFlowline', quiet=TRUE)
  nhd <- sf::st_zm(nhd)
  lakes <- sf::st_read(dsn=dsnPath, layer='NHDWaterbody', quiet=TRUE)
  lakes <- sf::st_zm(lakes)

  lakes <- as.data.frame(lakes) %>%
    dplyr::filter(FType %in% c(390, 436)) #lakes/reservoirs only
  colnames(lakes)[6] <- 'LakeAreaSqKm'
  NHD_HR_EROM <- st_read(dsn = dsnPath, layer = "NHDPlusEROMMA", quiet=TRUE) #mean annual flow table
  NHD_HR_VAA <- st_read(dsn = dsnPath, layer = "NHDPlusFlowlineVAA", quiet=TRUE) #additional 'value-added' attributes

  nhd <- left_join(nhd, lakes, by=c('WBArea_Permanent_Identifier'='Permanent_Identifier'))
  colnames(nhd)[16] <- 'NHDPlusID' #some manual rewriting b/c this columns get doubled from previous joins where data was needed for specific GIS tasks...
  nhd <- left_join(nhd, NHD_HR_EROM, by='NHDPlusID')
  nhd <- left_join(nhd, NHD_HR_VAA, by='NHDPlusID')
  nhd$Q_cms <- nhd$QEMA * 0.0283 #cfs to cms
  nhd$waterbody <- ifelse(is.na(nhd$WBArea_Permanent_Identifier)==0 & is.na(nhd$LakeAreaSqKm) == 0 & nhd$LakeAreaSqKm > 0, 'Lake/Reservoir', 'River') #assign waterbody type for depth modeling
  nhd <- filter(nhd, StreamCalc > 0 & Q_cms > 0) #no pipelines, connectors, canals. Only rivers/streams and 'artificial paths', ie.e. lake throughflow lines. Also- even epehmeral streams should have a mean annual flow > 0...

  #calculate depths and widths via hydraulic geomtery and lake volume modeling
  nhd$lakeVol_m3 <- 0.533 * (nhd$LakeAreaSqKm*1e6)^1.204 #Cael et al. 2016 function

  #Calculate and assign lake percents to each throughflow line so that we have fracVols and fracSAs for each throughflow line
  sumThroughFlow <- filter(as.data.frame(nhd), is.na(WBArea_Permanent_Identifier)==0) %>% #This is based on reachLength/total throughflow line reach length
    group_by(WBArea_Permanent_Identifier) %>%
    summarise(sumThroughFlow = sum(LengthKM))
  nhd <- left_join(nhd, sumThroughFlow, by='WBArea_Permanent_Identifier')
  nhd$lakePercent <- nhd$LengthKM / nhd$sumThroughFlow
  nhd$frac_lakeVol_m3 <- nhd$lakeVol_m3 * nhd$lakePercent
  nhd$frac_lakeSurfaceArea_m2 <- nhd$LakeAreaSqKm * nhd$lakePercent * 1e6

  #get width and depth
  depAHG <- readr::read_rds('/nas/cee-water/cjgleason/craig/RSK600/cache/depAHG.rds') #depth AHG model
  widAHG <- readr::read_rds('/nas/cee-water/cjgleason/craig/RSK600/cache/widAHG.rds') #depth AHG model
  nhd$a <- widAHG$coefficients[1]
  nhd$b <- widAHG$coefficients[2]
  nhd$c <- depAHG$coefficients[1]
  nhd$f <- depAHG$coefficients[2]
  nhd$depth_m <- mapply(depth_func, nhd$waterbody, nhd$Q_cms, nhd$frac_lakeVol_m3, nhd$frac_lakeSurfaceArea_m2*1e6, nhd$c, nhd$f)
  nhd$width_m <- mapply(width_func, nhd$waterbody, nhd$Q_cms, nhd$a, nhd$b)

  #extract water table depths
  nhd <- vect(nhd)

  #reproject to match wtd raster
  nhd <- project(nhd, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs ")
  basin <- project(basin, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs ")

  #clip wtd data to basin at hand
  wtd <- crop(wtd, basin)

  nhd_wtd <- extract(wtd$wtd_m, nhd, fun=summariseWTD)

  nhd_df <- as.data.frame(nhd)
  nhd_df <- select(nhd_df, c('NHDPlusID', 'StreamOrde', 'HydroSeq', 'FromNode', 'ToNode','Q_cms', 'LengthKM', 'width_m', 'depth_m'))

  nhd_df$wtd_m_min <- as.numeric(nhd_wtd$wtd_m.min)
  nhd_df$wtd_m_median <- as.numeric(nhd_wtd$wtd_m.median)
  nhd_df$wtd_m_mean <- as.numeric(nhd_wtd$wtd_m.mean)
  nhd_df$wtd_m_max <- as.numeric(nhd_wtd$wtd_m.max)

  return(nhd_df)
}

#' Calculate runoff efficiency per HUC4 basin mostly following  https://doi.org/10.1111/1752-1688.12431
#'
#' @param path_to_data: data repo path directory
#' @param codes_huc02: HUC2 zones we are currently running on
#'
#' @import sf
#' @import raster
#' @import terra
#' @import ncdf4
#'
#' @return dataframe with runoff coefficients at HUC level 4 scale
calcRunoffEff <- function(path_to_data, codes_huc02){
  #read in all HUC4 basins------------------
  basins_overall <- st_read(paste0(path_to_data, '/HUC2_', codes_huc02[1], '/WBD_', codes_huc02[1], '_HU2_Shape/Shape/WBDHU4.shp')) %>% select(c('huc4', 'name'))
  for(i in codes_huc02[-1]){
    basins <- st_read(paste0(path_to_data, '/HUC2_', i, '/WBD_', i, '_HU2_Shape/Shape/WBDHU4.shp')) %>% select(c('huc4', 'name')) #basin polygons
    basins_overall <- rbind(basins_overall, basins)
  }

  #SETUP RUNOFF DATA----------------------------------
  HUC4_runoff <- read.table(paste0(path_to_data, '/for_ephemeral_project/HUC4_runoff_mm.txt'), header=TRUE)
  HUC4_runoff$huc4 <- as.character(HUC4_runoff$huc_cd)   #setup IDs
  HUC4_runoff$huc4 <- ifelse(nchar(HUC4_runoff$huc_cd)==3, paste0('0', HUC4_runoff$huc_cd), HUC4_runoff$huc_cd)
  HUC4_runoff$runoff_ma_mm_yr <- rowMeans(HUC4_runoff[,71:122]) #1970-2021   #get long-term mean annual runoff
  HUC4_runoff <- select(HUC4_runoff, c('huc4', 'runoff_ma_mm_yr'))
  basins_overall <- left_join(basins_overall, HUC4_runoff, by='huc4')

  basins_overall <- vect(basins_overall)

  #SETUP MEAN DAILY PRECIP DATA-----------------------------------
  precip <- raster::brick(paste0(path_to_data, '/for_ephemeral_project/precip.V1.0.day.ltm.nc'))
  precip <- raster::rotate(precip)
  precip_mean <- rast(mean(precip)) #get long term mean for 1981-2010

  #reproject
  basins_overall <- project(basins_overall, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs ")
  precip_mean <- project(precip_mean, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs ")

  precip_mean_basins <- terra::extract(precip_mean, basins_overall, fun='mean', na.rm=TRUE)
  basins_overall$precip_ma_mm_yr <- (precip_mean_basins$layer*365) #apply long term mean over the entire year

  #runoff efficecincy
  basins_overall$runoff_eff <- basins_overall$runoff_ma_mm_yr / basins_overall$precip_ma_mm_yr #efficiency of P to streamflow routing

  #save as rds file
  basins_overall <- as.data.frame(basins_overall)

  return(basins_overall)
}

#' Estimates reach perenniality status for the NHD
#'
#' @param nhd_df: nhd hydrography with mean monthly water table depths already joined to hydrography
#' @param huc4: huc basin level 4 code
#' @param thresh: threshold for 'persistent surface groundwater'
#' @param err: error tolerance for calculation. This should reflect reisdual model error in the groundwater flow model
#' @param summarizer: metric to summarise wtd along the reach: min, max, mean, or mode. Default is median
#'
#' @import dplyr
#' @import readr
#'
#' @return NHD hydrography with perenniality status
getPerenniality <- function(nhd_df, huc4, thresh, err, summarizer){
  huc2 <- substr(huc4, 1, 2)

  ######INTIAL PASS AT ASSIGNING PERENNIALITY------------------
  if(summarizer == 'median'){
    nhd_df$perenniality <- mapply(perenniality_func_zell, nhd_df$wtd_m_median, nhd_df$depth_m, thresh, err)
  } else if(summarizer == 'mean'){
    nhd_df$perenniality <- mapply(perenniality_func_zell, nhd_df$wtd_m_mean, nhd_df$depth_m, thresh, err)
  } else if(summarizer == 'min'){
    nhd_df$perenniality <- mapply(perenniality_func_zell, nhd_df$wtd_m_min, nhd_df$depth_m, thresh, err)
  } else if(summarizer == 'max'){
    nhd_df$perenniality <- mapply(perenniality_func_zell, nhd_df$wtd_m_max, nhd_df$depth_m, thresh, err)
  } else { #default is median
    nhd_df$perenniality <- mapply(perenniality_func_zell, nhd_df$wtd_m_median, nhd_df$depth_m, thresh, err)
  }

  #drop potential NA perennial streams, i.e. those with NA water table depths. I've come across a single one of these so far....
  nhd_df <- nhd_df[is.na(nhd_df$perenniality)==0,]

  #####ROUTING---------------------------
  #now, route through network and identify 'perched perennial rivers', i.e. those supposedly above the water table that are always flowing because of upstream perennial rivers
  #sort rivers from upstream to downstream
  nhd_df <- filter(nhd_df, HydroSeq != 0)
  nhd_df <- nhd_df[order(-nhd_df$HydroSeq),] #sort descending

  #vectorize nhd to help with speed
  fromNode_vec <- as.vector(nhd_df$FromNode)
  toNode_vec <- as.vector(nhd_df$ToNode)
  perenniality_vec <- as.vector(nhd_df$perenniality)
  order_vec <- as.vector(nhd_df$StreamOrde)
  Q_vec <- as.vector(nhd_df$Q_cms)

  #run vectorized model
  for (i in 1:nrow(nhd_df)) {
    perenniality_vec[i] <- routing_func(fromNode_vec[i], perenniality_vec[i], toNode_vec, perenniality_vec, order_vec[i], Q_vec[i], Q_vec)
  }

  nhd_df$perenniality <- perenniality_vec

  #save some example HUCs (including those used for model validation/verification)
  if(huc4 %in% c('1103', '1111', '0108', '1603', '1503', '1505', '0107')){
    write_csv(nhd_df, paste0('cache/reaches_', huc4, '.csv'))
  }

  out <- nhd_df %>% select('NHDPlusID','ToNode', 'StreamOrde', 'Q_cms', 'width_m', 'LengthKM', 'perenniality')
  return(out)
}

#' Tabulates summary statistics (namely % discharge and % surface area) at the huc 4 level
#'
#' @param nhd_df: NHD hydrography with river perenniality status
#' @param huc4: huc basin level 4 code
#' @param flowQmodel: scaling model for number of days that Q is flowing
#'
#' @return summary statistics
collectResults <- function(nhd_df, path_to_data, huc4, runoff_eff, precip_thresh){
  #get basin to clip wtd model
  huc2 <- substr(huc4, 1, 2)
  basins <- vect(paste0(path_to_data, '/HUC2_', huc2, '/WBD_', huc2, '_HU2_Shape/Shape/WBDHU4.shp')) #basin polygon
  basin <- basins[basins$huc4 == huc4,]

  #add year gridded precip
  precip <- raster::brick(paste0(path_to_data, '/for_ephemeral_project/dailyPrecip_1980_2010.gri')) #daily precip for 1980-2010, perfect for identifying storm events!
  precip <- raster::rotate(precip) #convert 0360 lon to -180-180 lon
  basin <- project(basin, '+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0 ')
  basin <- as(basin, 'Spatial')
  precip <- raster::crop(precip, basin)

  #obtain results for flowing days, given a runoff threshold and huc4-scale runoff efficiency
  thresh <- precip_thresh / runoff_eff[runoff_eff$huc4 == huc4,]$runoff_eff #convert runoff thresh to precip thresh using runoff efficiency coefficient (because proportion of P that becomes Q varies regionally)
  precip <- sum(precip >= thresh)

  numFlowingDays <- (raster::cellStats(precip, 'mean')) #average over HUC4 basin

  numFlowingDays <- (numFlowingDays/(31*365))*365#average number of dys per year across the record

  #adjusted Q
  nhd_df$Q_cms_adj <- nhd_df$Q_cms * (365/numFlowingDays) #ifelse(is.finite(nhd_df$Q_cms * (365/numFlowingDays))==0, 0, nhd_df$Q_cms * (365/numFlowingDays))

  #adjusted widths
  widAHG <- readr::read_rds('/nas/cee-water/cjgleason/craig/RSK600/cache/widAHG.rds') #depth AHG model
  a <- widAHG$coefficients[1]
  b <- widAHG$coefficients[2]
  nhd_df$width_m_adj <- exp(a)*nhd_df$Q_cms_adj^(b)

  #concatenate and generate results
  results_nhd <- data.frame(
    'huc4'=huc4,
    'num_flowing_dys'=numFlowingDays,
    'notEphNetworkSA' = sum(nhd_df[nhd_df$perenniality != 'ephemeral',]$LengthKM*nhd_df[nhd_df$perenniality != 'ephemeral',]$width_m*1000, na.rm=T),
    'ephemeralNetworkSA_flowing' = sum(nhd_df[nhd_df$perenniality == 'ephemeral',]$LengthKM*nhd_df[nhd_df$perenniality == 'ephemeral',]$width_m_adj*1000, na.rm=T),
    'ephemeralNetworkSA' = sum(nhd_df[nhd_df$perenniality == 'ephemeral',]$LengthKM*nhd_df[nhd_df$perenniality == 'ephemeral',]$width_m*1000, na.rm=T),
    'totalNotEphQ' = sum(nhd_df[nhd_df$perenniality != 'ephemeral',]$Q_cms, na.rm=T),
    'totalephmeralQ_flowing' = sum(nhd_df[nhd_df$perenniality == 'ephemeral',]$Q_cms_adj, na.rm=T),
    'totalephmeralQ' = sum(nhd_df[nhd_df$perenniality == 'ephemeral',]$Q_cms, na.rm=T))

  results_nhd$percQ_eph_flowing <- results_nhd$totalephmeralQ_flowing / (results_nhd$totalNotEphQ + results_nhd$totalephmeralQ_flowing)
  results_nhd$percQ_eph <- results_nhd$totalephmeralQ / (results_nhd$totalNotEphQ + results_nhd$totalephmeralQ)

  results_nhd$percSA_eph <- results_nhd$ephemeralNetworkSA / (results_nhd$ephemeralNetworkSA + results_nhd$notEphNetworkSA)
  results_nhd$percSA_eph_flowing <- results_nhd$ephemeralNetworkSA_flowing / (results_nhd$ephemeralNetworkSA_flowing + results_nhd$notEphNetworkSA)

  return(results_nhd)
}

#' Makes boxplot summarizing results
#'
#' @param combined_results: aggreagted and tabulated results across all HUC4 basins
#'
#' @return figure showing relative influence of ephemeral streams when flowing and year round
boxPlots <- function(combined_results){
  theme_set(theme_classic())

  #discharge
  forPlotQ <- tidyr::gather(combined_results, key=key, value=value, c('percQ_eph_scaled', 'percQ_eph_flowing_scaled'))
  forPlotQ$key <- as.factor(forPlotQ$key)
  levels(forPlotQ$key) <- c("When flowing", "All year")
  boxplotsQ <- ggplot(forPlotQ, aes(x=key, y=value, fill=key)) +
    geom_boxplot(color='black', size=1.25) +
    annotate('text', label=paste0('n = ', nrow(combined_results), ' basins'), x=as.factor('All year'), y=0.80, size=8)+
    scale_fill_brewer(palette='Dark2') +
    ylab('% streamflow passing through ephemeral reach') +
    xlab('')+
    theme(axis.text=element_text(size=20),
      axis.title=element_text(size=22,face="bold"),
      legend.text = element_text(size=17),
      plot.title = element_text(size = 30, face = "bold"),
      legend.position='none')

  #surface area
  forPlotSA <- tidyr::gather(combined_results, key=key, value=value, c('percSA_eph', 'percSA_eph_flowing'))
  forPlotSA$key <- as.factor(forPlotSA$key)
  levels(forPlotSA$key) <- c("All year", "When flowing")
  boxplotsSA <- ggplot(forPlotSA, aes(x=key, y=value, fill=key)) +
    geom_boxplot(color='black', size=1.25) +
    scale_fill_brewer(palette='Dark2') +
    ylab('% ephemeral surface area') +
    xlab('')+
    theme(axis.text=element_text(size=20),
      axis.title=element_text(size=22,face="bold"),
      legend.text = element_text(size=17),
      plot.title = element_text(size = 30, face = "bold"),
      legend.position='none')

  plot_fin <- plot_grid(boxplotsQ, boxplotsSA, ncol=2)

  ggsave('cache/boxplots.jpg', plot_fin, width=18, height=10)
  return(boxplotsQ)
}




#adjust Q for ephemeral streams to reflect 'average flowing discharge', i.e. ignoring days when the ephemeral reach is dry
#nhd_df$Q_bin <- ifelse(nhd_df$Q_cms < 0.01, 0.01,
#                    ifelse(nhd_df$Q_cms < 0.1, 0.1,
#                          ifelse(nhd_df$Q_cms < 1, 1,
#                                ifelse(nhd_df$Q_cms < 10, 10, 100))))
#nhd_df$meanFlowingDays <- predict(flowQmodel, nhd_df)
#nhd_df$meanFlowingDays <- ifelse(nhd_df$perenniality != 'ephemeral', NA, nhd_df$meanFlowingDays) #only applies to ephemeral reaches

#getPerenniality_peckel <- function(nhd_df, huc4, thresh, err,summarizer){
#  huc2 <- substr(huc4, 1, 2)

  ######INTIAL PASS AT ASSIGNING PERENNIALITY------------------
#  if(summarizer == 'median'){
#    nhd_df$perenniality <- mapply(perenniality_func_peckel, nhd_df$peckel_water_ocurrence, nhd_df$wtd_m_median_01, nhd_df$wtd_m_median_02, nhd_df$wtd_m_median_03, nhd_df$wtd_m_median_04, nhd_df$wtd_m_median_05, nhd_df$wtd_m_median_06, nhd_df$wtd_m_median_07, nhd_df$wtd_m_median_08, nhd_df$wtd_m_median_09, nhd_df$wtd_m_median_10, nhd_df$wtd_m_median_11, nhd_df$wtd_m_median_12, nhd_df$depth_m, thresh, err)
#  } else if(summarizer == 'mean'){
#    nhd_df$perenniality <- mapply(perenniality_func_peckel, nhd_df$peckel_water_ocurrence, nhd_df$wtd_m_mean_01, nhd_df$wtd_m_mean_02, nhd_df$wtd_m_mean_03, nhd_df$wtd_m_mean_04, nhd_df$wtd_m_mean_05, nhd_df$wtd_m_mean_06, nhd_df$wtd_m_mean_07, nhd_df$wtd_m_mean_08, nhd_df$wtd_m_mean_09, nhd_df$wtd_m_mean_10, nhd_df$wtd_m_mean_11, nhd_df$wtd_m_mean_12,  nhd_df$depth_m, thresh, err)
#  } else if(summarizer == 'min'){
#    nhd_df$perenniality <- mapply(perenniality_func_peckel, nhd_df$peckel_water_ocurrence, nhd_df$wtd_m_min_01, nhd_df$wtd_m_min_02, nhd_df$wtd_m_min_03, nhd_df$wtd_m_min_04, nhd_df$wtd_m_min_05, nhd_df$wtd_m_min_06, nhd_df$wtd_m_min_07, nhd_df$wtd_m_min_08, nhd_df$wtd_m_min_09, nhd_df$wtd_m_min_10, nhd_df$wtd_m_min_11, nhd_df$wtd_m_min_12,  nhd_df$depth_m, thresh, err)
#  } else if(summarizer == 'max'){
#    nhd_df$perenniality <- mapply(perenniality_func_peckel, nhd_df$peckel_water_ocurrence, nhd_df$wtd_m_max_01, nhd_df$wtd_m_max_02, nhd_df$wtd_m_max_03, nhd_df$wtd_m_max_04, nhd_df$wtd_m_max_05, nhd_df$wtd_m_max_06, nhd_df$wtd_m_max_07, nhd_df$wtd_m_max_08, nhd_df$wtd_m_max_09, nhd_df$wtd_m_max_10, nhd_df$wtd_m_max_11, nhd_df$wtd_m_max_12,  nhd_df$depth_m, thresh, err)
#  } else { #default is median
#    nhd_df$perenniality <- mapply(perenniality_func_peckel, nhd_df$peckel_water_ocurrence, nhd_df$wtd_m_median_01, nhd_df$wtd_m_median_02, nhd_df$wtd_m_median_03, nhd_df$wtd_m_median_04, nhd_df$wtd_m_median_05, nhd_df$wtd_m_median_06, nhd_df$wtd_m_median_07, nhd_df$wtd_m_median_08, nhd_df$wtd_m_median_09, nhd_df$wtd_m_median_10, nhd_df$wtd_m_median_11, nhd_df$wtd_m_median_12,  nhd_df$depth_m, thresh, err)
#  }

  #drop potential NA perennial streams, i.e. those with NA water table depths. I've come across a single one of these so far....
#  nhd_df <- nhd_df[is.na(nhd_df$perenniality)==0,]

  #####ROUTING---------------------------
  #now, route through network and identify 'perched perennial rivers', i.e. those supposedly above the water table that are always flowing because of upstream perennial rivers
  #sort rivers from upstream to downstream
#  nhd_df <- filter(nhd_df, HydroSeq != 0)
#  nhd_df <- nhd_df[order(-nhd_df$HydroSeq),] #sort descending

  #vectorize nhd to help with speed
#  fromNode_vec <- as.vector(nhd_df$FromNode)
#  toNode_vec <- as.vector(nhd_df$ToNode)
#  perenniality_vec <- as.vector(nhd_df$perenniality)
#  order_vec <- as.vector(nhd_df$StreamOrde)
#  Q_vec <- as.vector(nhd_df$Q_cms)

  #run vectorized model
#  for (i in 1:nrow(nhd_df)) {
#    perenniality_vec[i] <- routing_func(fromNode_vec[i], perenniality_vec[i], toNode_vec, perenniality_vec, order_vec[i], Q_vec[i], Q_vec)
#  }

#  nhd_df$perenniality <- perenniality_vec

  #save some example HUCs
#  if(huc4 %in% c('1103', '1111', '0108', '1603')){
#    write_csv(nhd_df, paste0('cache/reaches_', huc4, '.csv'))
#  }

#  out <- nhd_df %>% select('NHDPlusID','ToNode', 'StreamOrde', 'Q_cms', 'width_m', 'LengthKM', 'perenniality')
#  return(out)
#}

#  if(summarizer == 'median'){
#    nhd_df$perenniality <- mapply(perenniality_func, nhd_df$wtd_m_median_01, nhd_df$wtd_m_median_02, nhd_df$wtd_m_median_03, nhd_df$wtd_m_median_04, nhd_df$wtd_m_median_05, nhd_df$wtd_m_median_06, nhd_df$wtd_m_median_07, nhd_df$wtd_m_median_08, nhd_df$wtd_m_median_09, nhd_df$wtd_m_median_10, nhd_df$wtd_m_median_11, nhd_df$wtd_m_median_12, nhd_df$depth_m, thresh, err)
#  } else if(summarizer == 'mean'){
#    nhd_df$perenniality <- mapply(perenniality_func, nhd_df$wtd_m_mean_01, nhd_df$wtd_m_mean_02, nhd_df$wtd_m_mean_03, nhd_df$wtd_m_mean_04, nhd_df$wtd_m_mean_05, nhd_df$wtd_m_mean_06, nhd_df$wtd_m_mean_07, nhd_df$wtd_m_mean_08, nhd_df$wtd_m_mean_09, nhd_df$wtd_m_mean_10, nhd_df$wtd_m_mean_11, nhd_df$wtd_m_mean_12,  nhd_df$depth_m, thresh, err)
#  } else if(summarizer == 'min'){
#    nhd_df$perenniality <- mapply(perenniality_func, nhd_df$wtd_m_min_01, nhd_df$wtd_m_min_02, nhd_df$wtd_m_min_03, nhd_df$wtd_m_min_04, nhd_df$wtd_m_min_05, nhd_df$wtd_m_min_06, nhd_df$wtd_m_min_07, nhd_df$wtd_m_min_08, nhd_df$wtd_m_min_09, nhd_df$wtd_m_min_10, nhd_df$wtd_m_min_11, nhd_df$wtd_m_min_12,  nhd_df$depth_m, thresh, err)
#  } else if(summarizer == 'max'){
#    nhd_df$perenniality <- mapply(perenniality_func, nhd_df$wtd_m_max_01, nhd_df$wtd_m_max_02, nhd_df$wtd_m_max_03, nhd_df$wtd_m_max_04, nhd_df$wtd_m_max_05, nhd_df$wtd_m_max_06, nhd_df$wtd_m_max_07, nhd_df$wtd_m_max_08, nhd_df$wtd_m_max_09, nhd_df$wtd_m_max_10, nhd_df$wtd_m_max_11, nhd_df$wtd_m_max_12,  nhd_df$depth_m, thresh, err)
#  } else { #default is median
#    nhd_df$perenniality <- mapply(perenniality_func, nhd_df$wtd_m_median_01, nhd_df$wtd_m_median_02, nhd_df$wtd_m_median_03, nhd_df$wtd_m_median_04, nhd_df$wtd_m_median_05, nhd_df$wtd_m_median_06, nhd_df$wtd_m_median_07, nhd_df$wtd_m_median_08, nhd_df$wtd_m_median_09, nhd_df$wtd_m_median_10, nhd_df$wtd_m_median_11, nhd_df$wtd_m_median_12,  nhd_df$depth_m, thresh, err)
#  }

#  nhd_df$wtd_m_min_01 <- as.numeric(nhd_wtd_01$WTD_1.min)
#  nhd_df$wtd_m_median_01 <- as.numeric(nhd_wtd_01$WTD_1.median)
#  nhd_df$wtd_m_mean_01 <- as.numeric(nhd_wtd_01$WTD_1.mean)
#  nhd_df$wtd_m_max_01 <- as.numeric(nhd_wtd_01$WTD_1.max)

#  nhd_df$wtd_m_min_02 <- as.numeric(nhd_wtd_02$WTD_2.min)
#  nhd_df$wtd_m_median_02 <- as.numeric(nhd_wtd_02$WTD_2.median)
#  nhd_df$wtd_m_mean_02 <- as.numeric(nhd_wtd_02$WTD_2.mean)
#  nhd_df$wtd_m_max_02 <- as.numeric(nhd_wtd_02$WTD_2.max)

#  nhd_df$wtd_m_min_03 <- as.numeric(nhd_wtd_03$WTD_3.min)
#  nhd_df$wtd_m_median_03 <- as.numeric(nhd_wtd_03$WTD_3.median)
#  nhd_df$wtd_m_mean_03 <- as.numeric(nhd_wtd_03$WTD_3.mean)
#  nhd_df$wtd_m_max_03 <- as.numeric(nhd_wtd_03$WTD_3.max)

#  nhd_df$wtd_m_min_04 <- as.numeric(nhd_wtd_04$WTD_4.min)
#  nhd_df$wtd_m_median_04 <- as.numeric(nhd_wtd_04$WTD_4.median)
#  nhd_df$wtd_m_mean_04 <- as.numeric(nhd_wtd_04$WTD_4.mean)
#  nhd_df$wtd_m_max_04 <- as.numeric(nhd_wtd_04$WTD_4.max)

#  nhd_df$wtd_m_min_05 <- as.numeric(nhd_wtd_05$WTD_5.min)
#  nhd_df$wtd_m_median_05 <- as.numeric(nhd_wtd_05$WTD_5.median)
#  nhd_df$wtd_m_mean_05 <- as.numeric(nhd_wtd_05$WTD_5.mean)
#  nhd_df$wtd_m_max_05 <- as.numeric(nhd_wtd_05$WTD_5.max)

#  nhd_df$wtd_m_min_06 <- as.numeric(nhd_wtd_06$WTD_6.min)
#  nhd_df$wtd_m_median_06 <- as.numeric(nhd_wtd_06$WTD_6.median)
#  nhd_df$wtd_m_mean_06 <- as.numeric(nhd_wtd_06$WTD_6.mean)
#  nhd_df$wtd_m_max_06 <- as.numeric(nhd_wtd_06$WTD_6.max)

#  nhd_df$wtd_m_min_07 <- as.numeric(nhd_wtd_07$WTD_7.min)
#  nhd_df$wtd_m_median_07 <- as.numeric(nhd_wtd_07$WTD_7.median)
#  nhd_df$wtd_m_mean_07 <- as.numeric(nhd_wtd_07$WTD_7.mean)
#  nhd_df$wtd_m_max_07 <- as.numeric(nhd_wtd_07$WTD_7.max)

#  nhd_df$wtd_m_min_08 <- as.numeric(nhd_wtd_08$WTD_8.min)
#  nhd_df$wtd_m_median_08 <- as.numeric(nhd_wtd_08$WTD_8.median)
#  nhd_df$wtd_m_mean_08 <- as.numeric(nhd_wtd_08$WTD_8.mean)
#  nhd_df$wtd_m_max_08 <- as.numeric(nhd_wtd_08$WTD_8.max)

#  nhd_df$wtd_m_min_09 <- as.numeric(nhd_wtd_09$WTD_9.min)
#  nhd_df$wtd_m_median_09 <- as.numeric(nhd_wtd_09$WTD_9.median)
#  nhd_df$wtd_m_mean_09 <- as.numeric(nhd_wtd_09$WTD_9.mean)
#  nhd_df$wtd_m_max_09 <- as.numeric(nhd_wtd_09$WTD_9.max)

#  nhd_df$wtd_m_min_10 <- as.numeric(nhd_wtd_10$WTD_10.min)
#  nhd_df$wtd_m_median_10 <- as.numeric(nhd_wtd_10$WTD_10.median)
#  nhd_df$wtd_m_mean_10 <- as.numeric(nhd_wtd_10$WTD_10.mean)
#  nhd_df$wtd_m_max_10 <- as.numeric(nhd_wtd_10$WTD_10.max)

#  nhd_df$wtd_m_min_11 <- as.numeric(nhd_wtd_11$WTD_11.min)
#  nhd_df$wtd_m_median_11 <- as.numeric(nhd_wtd_11$WTD_11.median)
#  nhd_df$wtd_m_mean_11 <- as.numeric(nhd_wtd_11$WTD_11.mean)
#  nhd_df$wtd_m_max_11 <- as.numeric(nhd_wtd_11$WTD_11.max)

#  nhd_df$wtd_m_min_12 <- as.numeric(nhd_wtd_12$WTD_12.min)
#  nhd_df$wtd_m_median_12 <- as.numeric(nhd_wtd_12$WTD_12.median)
#  nhd_df$wtd_m_mean_12 <- as.numeric(nhd_wtd_12$WTD_12.mean)
#  nhd_df$wtd_m_max_12 <- as.numeric(nhd_wtd_12$WTD_12.max)

#  nhd_df$peckel_water_ocurrence <- as.numeric(nhd_peckel$peckel_CONUS_occurrence)

#  nhd_wtd_01 <- extract(wtd$WTD_1, nhd, fun=summariseWTD)
#  nhd_wtd_02 <- extract(wtd$WTD_2, nhd, fun=summariseWTD)
#  nhd_wtd_03<- extract(wtd$WTD_3, nhd, fun=summariseWTD)
#  nhd_wtd_04 <- extract(wtd$WTD_4, nhd, fun=summariseWTD)
#  nhd_wtd_05 <- extract(wtd$WTD_5, nhd, fun=summariseWTD)
#  nhd_wtd_06<- extract(wtd$WTD_6, nhd, fun=summariseWTD)
#  nhd_wtd_07 <- extract(wtd$WTD_7, nhd, fun=summariseWTD)
#  nhd_wtd_08 <- extract(wtd$WTD_8, nhd, fun=summariseWTD)
#  nhd_wtd_09 <- extract(wtd$WTD_9, nhd, fun=summariseWTD)
#  nhd_wtd_10 <- extract(wtd$WTD_10, nhd, fun=summariseWTD)
#  nhd_wtd_11<- extract(wtd$WTD_11, nhd, fun=summariseWTD)
#  nhd_wtd_12 <- extract(wtd$WTD_12, nhd, fun=summariseWTD)

  #extract Peckel 2016 Landsat water occurence
#  peckel <- rast(paste0(path_to_data, '/for_ephemeral_project/peckel_CONUS_occurrence.tif'))
#  peckel <- crop(peckel, basin)
#  nhd_peckel <- extract(peckel, nhd, fun=mean)
