## Craig Brinkerhoff
## Spring 2022
## Main functions for classifying ephemeral streams along the NHD (and calculating water volumes in ephemeral streams)



#' Preps hydrography shapefiles into leightweight routing tables. Part of this is extracting 1) monthly water table depth and 2) average land cover type at each NHD flowline.
#'
#' @name extractData
#'
#' @note Be aware of the expilict repo structure within the data repo, i.e. even though the user specifies the path to the data repo, there are assumed internal folders.
#' @note How the pixels are summarized for WTD extractions at each reach is specified in the summariseWTD() function within '~/src/utils.R``. Land cover is always the mean
#'
#' @param path_to_data: data repo path directory
#' @param huc4: huc basin level 4 code
#'
#' @import terra
#' @import sf
#' @import dplyr
#'
#' @return df of NHD hydrograpy with mean monthly water table depths attached.
extractData <- function(path_to_data, huc4){
  ########SETUP
  indiana_hucs <- c('0508', '0509', '0514', '0512', '0712', '0404', '0405', '0410') #indiana-effected basins

  sf::sf_use_s2(FALSE)

  huc2 <- substr(huc4, 1, 2)

  # setup CONUS shapefile
  states <- sf::st_read('/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/other_shapefiles/cb_2018_us_state_5m.shp')
  states <- dplyr::filter(states, !(NAME %in% c('Alaska',
                                         'American Samoa',
                                         'Commonwealth of the Northern Mariana Islands',
                                         'Guam',
                                         'District of Columbia',
                                         'Puerto Rico',
                                         'United States Virgin Islands',
                                         'Hawaii'))) #remove non CONUS states/territories
  states <- sf::st_union(states)

  ########PULL IN DATA
  #Fan et al 2017 water table depth model
  wtd <- terra::rast(paste0(path_to_data, '/for_ephemeral_project/NAMERICA_WTD_monthlymeans.nc'))   #monthly averages for hourly model runs for 2004-2014

  #USGS NLCD 2019 (downscaled to 1km a priori in google earth engine to speed up processing)
  nlcd <- terra::rast(paste0(path_to_data, '/NLCD_2019/nlcd_HUC', huc2, '.tif'))
  nlcd <- terra::project(nlcd, crs(wtd))

  #HUC4 basin at hand
  basins <- terra::vect(paste0(path_to_data, '/HUC2_', huc2, '/WBD_', huc2, '_HU2_Shape/Shape/WBDHU4.shp')) #basin polygon
  basin <- basins[basins$huc4 == huc4,]

  #USGS NHD
  dsnPath <- paste0(path_to_data, '/HUC2_', huc2, '/NHDPLUS_H_', huc4, '_HU4_GDB/NHDPLUS_H_', huc4, '_HU4_GDB.gdb')

  #load river network, depending on indiana-effect or not
  if(huc4 %in% indiana_hucs) {
    nhd <- sf::st_read(paste0(path_to_data, '/HUC2_', huc2, '/indiana/indiana_fixed_', huc4, '.shp'))
    nhd <- sf::st_zm(nhd)
    colnames(nhd)[10] <- 'WBArea_Permanent_Identifier'
    nhd$NHDPlusID <- round(nhd$NHDPlusID, 0) #some of these have digits for some reason......
  }
  else{
    nhd <- sf::st_read(dsn=dsnPath, layer='NHDFlowline', quiet=TRUE)
    nhd <- sf::st_zm(nhd)
    nhd <- fixGeometries(nhd)
  }

  #load waterbodies
  lakes <- sf::st_read(dsn=dsnPath, layer='NHDWaterbody', quiet=TRUE)
  lakes <- sf::st_zm(lakes)

  #filter for lakes/reservoirs only
  lakes <- as.data.frame(lakes) %>%
    dplyr::filter(FType %in% c(390, 436)) #lakes/reservoirs only
  colnames(lakes)[6] <- 'LakeAreaSqKm'
  nhd <- left_join(nhd, lakes, by=c('WBArea_Permanent_Identifier'='Permanent_Identifier'))

  #load additional attributes
  NHD_HR_EROM <- sf::st_read(dsn = dsnPath, layer = "NHDPlusEROMMA", quiet=TRUE) #mean annual flow table
  NHD_HR_VAA <- sf::st_read(dsn = dsnPath, layer = "NHDPlusFlowlineVAA", quiet=TRUE) #additional 'value-added' attributes

  #some manual rewriting b/c this columns get doubled from previous joins where data was needed for specific GIS tasks...
  if(huc4 %in% indiana_hucs){
    colnames(nhd)[17] <- 'NHDPlusID'
    nhd$NHDPlusID <- round(nhd$NHDPlusID, 0) #some of these have digits for some reason......
    colnames(nhd)[12] <- 'FCode_riv'
    colnames(nhd)[31] <- 'FCode_waterbody'
  }
  else{
    colnames(nhd)[16] <- 'NHDPlusID'
    colnames(nhd)[11] <- 'FCode_riv'
    colnames(nhd)[27] <- 'FCode_waterbody'
  }

  #join everything into a single shapefile for basin hydrography
  nhd <- dplyr::left_join(nhd, NHD_HR_EROM, by='NHDPlusID')
  nhd <- dplyr::left_join(nhd, NHD_HR_VAA, by='NHDPlusID')

  #Convert to more useful values
  nhd$StreamOrde <- nhd$StreamCalc #stream calc handles divergent streams correctly: https://pubs.usgs.gov/of/2019/1096/ofr20191096.pdf
  nhd$Q_cms <- nhd$QEMA * 0.0283 #cfs to cms

  #handle indiana-effected basin stream orders
  if(huc4 %in% indiana_hucs){
    thresh <- c(2,2,2,2,3,2,3,2) #see README file
    thresh <- thresh[which(indiana_hucs == huc4)]
    nhd$StreamOrde <- ifelse(nhd$indiana_fl == 1, nhd$StreamOrde - thresh, nhd$StreamOrde)
  }

  #assign waterbody type for depth modeling
  nhd$waterbody <- ifelse(is.na(nhd$WBArea_Permanent_Identifier)==0 & is.na(nhd$LakeAreaSqKm) == 0 & nhd$LakeAreaSqKm > 0, 'Lake/Reservoir', 'River')

  #no divergent channels, i.e. all downstream routing flows into a single downstream reach.
  nhd <- dplyr::filter(nhd, StreamOrde > 0)

  #calculate depths and widths via hydraulic geomtery and lake volume modeling
  nhd$lakeVol_m3 <- 0.533 * (nhd$LakeAreaSqKm*1e6)^1.204 #Cael et al. 2016

  #Calculate and assign lake percents to each throughflow line so that we have fracional lake surface areas and volumes for each throughflow line
  sumThroughFlow <- dplyr::filter(as.data.frame(nhd), is.na(WBArea_Permanent_Identifier)==0) %>% #This is based on reachLength/total throughflow line reach length
    dplyr::group_by(WBArea_Permanent_Identifier) %>%
    dplyr::summarise(sumThroughFlow = sum(LengthKM))
  nhd <- dplyr::left_join(nhd, sumThroughFlow, by='WBArea_Permanent_Identifier')
  nhd$lakePercent <- nhd$LengthKM / nhd$sumThroughFlow
  nhd$frac_lakeVol_m3 <- nhd$lakeVol_m3 * nhd$lakePercent
  nhd$frac_lakeSurfaceArea_m2 <- nhd$LakeAreaSqKm * nhd$lakePercent * 1e6

  #get width and depth using hydraulic scaling
  depAHG <- readr::read_rds('/nas/cee-water/cjgleason/craig/RSK600/cache/depAHG.rds') #depth AHG model
  widAHG <- readr::read_rds('/nas/cee-water/cjgleason/craig/RSK600/cache/widAHG.rds') #depth AHG model
  nhd$a <- widAHG$coefficients[1]
  nhd$b <- widAHG$coefficients[2]
  nhd$c <- depAHG$coefficients[1]
  nhd$f <- depAHG$coefficients[2]
  nhd$depth_m <- mapply(depth_func, nhd$waterbody, nhd$Q_cms, nhd$frac_lakeVol_m3, nhd$frac_lakeSurfaceArea_m2*1e6, nhd$c, nhd$f)
  nhd$width_m <- mapply(width_func, nhd$waterbody, nhd$Q_cms, nhd$a, nhd$b)

  ########EXTRACT RASTER MODELS AND DATA TO NHD
  #convert back to terra to do extractions
  nhd <- terra::vect(nhd)

  #clip models to basin at hand
  wtd <- terra::crop(wtd, basin)
  nlcd <- terra::crop(nlcd, basin)

  #extract average land cover along stream channel
  m <- c(0,NA, #ignore non-land pixels
         11,10,
         12,10,
         21,20, #developed
         22,20, #developed
         23,20, #developed
         24,20, #developed
         31,30,
         41,40,
         42,40,
         43,40,
         51,50,
         52,50,
         71,60, #there is no nlcd category 60 for some reason so we do this to later take a mean
         81,70, #cultivated
         82,70, #cultivated
         90,80,
         95,80)
  rclmat <- matrix(m, ncol=2, byrow=TRUE)
  nlcd <- terra::classify(nlcd, rclmat, include.lowest=TRUE)
  nhd_nlcd <- terra::extract(nlcd, nhd, fun=function(x){return(mean(x, na.rm=T))})#'mean', na.rm=T)

  #extract mean monthly water table depths
  nhd_wtd_01 <- terra::extract(wtd$WTD_1, nhd, fun=summariseWTD)
  nhd_wtd_02 <- terra::extract(wtd$WTD_2, nhd, fun=summariseWTD)
  nhd_wtd_03<- terra::extract(wtd$WTD_3, nhd, fun=summariseWTD)
  nhd_wtd_04 <- terra::extract(wtd$WTD_4, nhd, fun=summariseWTD)
  nhd_wtd_05 <- terra::extract(wtd$WTD_5, nhd, fun=summariseWTD)
  nhd_wtd_06<- terra::extract(wtd$WTD_6, nhd, fun=summariseWTD)
  nhd_wtd_07 <- terra::extract(wtd$WTD_7, nhd, fun=summariseWTD)
  nhd_wtd_08 <- terra::extract(wtd$WTD_8, nhd, fun=summariseWTD)
  nhd_wtd_09 <- terra::extract(wtd$WTD_9, nhd, fun=summariseWTD)
  nhd_wtd_10 <- terra::extract(wtd$WTD_10, nhd, fun=summariseWTD)
  nhd_wtd_11<- terra::extract(wtd$WTD_11, nhd, fun=summariseWTD)
  nhd_wtd_12 <- terra::extract(wtd$WTD_12, nhd, fun=summariseWTD)

  #intersect with conus boundary to identify american/non-american rivers
  nhd_conus <- sf::st_intersection(sf::st_as_sf(nhd), states)
  nhd$conus <- ifelse(nhd$NHDPlusID %in% nhd_conus$NHDPlusID, 1,0)

  #Wrangle everything into a lightweight routing table (no spatial info anymore)
  nhd_df <- as.data.frame(nhd)
  nhd_df <- dplyr::select(nhd_df, c('NHDPlusID', 'StreamOrde', 'HydroSeq', 'FromNode','ToNode', 'conus', 'FCode_riv', 'FCode_waterbody', 'AreaSqKm', 'TotDASqKm','Q_cms', 'LengthKM', 'width_m', 'depth_m'))

  nhd_df$nlcd_broad <- as.numeric(round(nhd_nlcd$landcover, -1)) #round to broad categories, i.e. forest, cultivated, urban, etc.
  nhd_df$nlcd_broad <- ifelse(nhd_df$conus == 0, 0, nhd_df$nlcd_broad) #don't tabulate non-CONUS streams

  nhd_df$wtd_m_min_01 <- as.numeric(nhd_wtd_01$WTD_1.min)
  nhd_df$wtd_m_median_01 <- as.numeric(nhd_wtd_01$WTD_1.median)
  nhd_df$wtd_m_mean_01 <- as.numeric(nhd_wtd_01$WTD_1.mean)
  nhd_df$wtd_m_max_01 <- as.numeric(nhd_wtd_01$WTD_1.max)

  nhd_df$wtd_m_min_02 <- as.numeric(nhd_wtd_02$WTD_2.min)
  nhd_df$wtd_m_median_02 <- as.numeric(nhd_wtd_02$WTD_2.median)
  nhd_df$wtd_m_mean_02 <- as.numeric(nhd_wtd_02$WTD_2.mean)
  nhd_df$wtd_m_max_02 <- as.numeric(nhd_wtd_02$WTD_2.max)

  nhd_df$wtd_m_min_03 <- as.numeric(nhd_wtd_03$WTD_3.min)
  nhd_df$wtd_m_median_03 <- as.numeric(nhd_wtd_03$WTD_3.median)
  nhd_df$wtd_m_mean_03 <- as.numeric(nhd_wtd_03$WTD_3.mean)
  nhd_df$wtd_m_max_03 <- as.numeric(nhd_wtd_03$WTD_3.max)

  nhd_df$wtd_m_min_04 <- as.numeric(nhd_wtd_04$WTD_4.min)
  nhd_df$wtd_m_median_04 <- as.numeric(nhd_wtd_04$WTD_4.median)
  nhd_df$wtd_m_mean_04 <- as.numeric(nhd_wtd_04$WTD_4.mean)
  nhd_df$wtd_m_max_04 <- as.numeric(nhd_wtd_04$WTD_4.max)

  nhd_df$wtd_m_min_05 <- as.numeric(nhd_wtd_05$WTD_5.min)
  nhd_df$wtd_m_median_05 <- as.numeric(nhd_wtd_05$WTD_5.median)
  nhd_df$wtd_m_mean_05 <- as.numeric(nhd_wtd_05$WTD_5.mean)
  nhd_df$wtd_m_max_05 <- as.numeric(nhd_wtd_05$WTD_5.max)

  nhd_df$wtd_m_min_06 <- as.numeric(nhd_wtd_06$WTD_6.min)
  nhd_df$wtd_m_median_06 <- as.numeric(nhd_wtd_06$WTD_6.median)
  nhd_df$wtd_m_mean_06 <- as.numeric(nhd_wtd_06$WTD_6.mean)
  nhd_df$wtd_m_max_06 <- as.numeric(nhd_wtd_06$WTD_6.max)

  nhd_df$wtd_m_min_07 <- as.numeric(nhd_wtd_07$WTD_7.min)
  nhd_df$wtd_m_median_07 <- as.numeric(nhd_wtd_07$WTD_7.median)
  nhd_df$wtd_m_mean_07 <- as.numeric(nhd_wtd_07$WTD_7.mean)
  nhd_df$wtd_m_max_07 <- as.numeric(nhd_wtd_07$WTD_7.max)

  nhd_df$wtd_m_min_08 <- as.numeric(nhd_wtd_08$WTD_8.min)
  nhd_df$wtd_m_median_08 <- as.numeric(nhd_wtd_08$WTD_8.median)
  nhd_df$wtd_m_mean_08 <- as.numeric(nhd_wtd_08$WTD_8.mean)
  nhd_df$wtd_m_max_08 <- as.numeric(nhd_wtd_08$WTD_8.max)

  nhd_df$wtd_m_min_09 <- as.numeric(nhd_wtd_09$WTD_9.min)
  nhd_df$wtd_m_median_09 <- as.numeric(nhd_wtd_09$WTD_9.median)
  nhd_df$wtd_m_mean_09 <- as.numeric(nhd_wtd_09$WTD_9.mean)
  nhd_df$wtd_m_max_09 <- as.numeric(nhd_wtd_09$WTD_9.max)

  nhd_df$wtd_m_min_10 <- as.numeric(nhd_wtd_10$WTD_10.min)
  nhd_df$wtd_m_median_10 <- as.numeric(nhd_wtd_10$WTD_10.median)
  nhd_df$wtd_m_mean_10 <- as.numeric(nhd_wtd_10$WTD_10.mean)
  nhd_df$wtd_m_max_10 <- as.numeric(nhd_wtd_10$WTD_10.max)

  nhd_df$wtd_m_min_11 <- as.numeric(nhd_wtd_11$WTD_11.min)
  nhd_df$wtd_m_median_11 <- as.numeric(nhd_wtd_11$WTD_11.median)
  nhd_df$wtd_m_mean_11 <- as.numeric(nhd_wtd_11$WTD_11.mean)
  nhd_df$wtd_m_max_11 <- as.numeric(nhd_wtd_11$WTD_11.max)

  nhd_df$wtd_m_min_12 <- as.numeric(nhd_wtd_12$WTD_12.min)
  nhd_df$wtd_m_median_12 <- as.numeric(nhd_wtd_12$WTD_12.median)
  nhd_df$wtd_m_mean_12 <- as.numeric(nhd_wtd_12$WTD_12.mean)
  nhd_df$wtd_m_max_12 <- as.numeric(nhd_wtd_12$WTD_12.max)

  return(nhd_df)
}



#' Estimates reach perenniality status for the NHD
#'
#' @name getPerenniality
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

  #remove streams with absolutely no mean annual flow (can't compute flowing...)
  nhd_df <- dplyr::filter(nhd_df, Q_cms > 0)

  ######INTIAL PASS AT ASSIGNING PERENNIALITy: using median water table depth (function handles non-CONUS streams in its calculation)
  nhd_df$perenniality <- mapply(perenniality_func_fan, nhd_df$wtd_m_median_01,  nhd_df$wtd_m_median_02,  nhd_df$wtd_m_median_03,  nhd_df$wtd_m_median_04,  nhd_df$wtd_m_median_05,  nhd_df$wtd_m_median_06,  nhd_df$wtd_m_median_07,  nhd_df$wtd_m_median_08,  nhd_df$wtd_m_median_09,  nhd_df$wtd_m_median_10,  nhd_df$wtd_m_median_11,  nhd_df$wtd_m_median_12, nhd_df$width_m, nhd_df$depth_m, thresh, err, nhd_df$conus)

  #####ROUTING
  #now, route through network and identify 'perched perennial rivers', i.e. those supposedly above the water table that are always flowing because of upstream perennial rivers
  #sort rivers from upstream to downstream
  nhd_df <- dplyr::filter(nhd_df, HydroSeq != 0)
  nhd_df <- nhd_df[order(-nhd_df$HydroSeq),] #sort descending

  #vectorize nhd to help with speed
  fromNode_vec <- as.vector(nhd_df$FromNode)
  toNode_vec <- as.vector(nhd_df$ToNode)
  perenniality_vec <- as.vector(nhd_df$perenniality)
  order_vec <- as.vector(nhd_df$StreamOrde)
  Q_vec <- as.vector(nhd_df$Q_cms)

  #run vectorized model
  for (i in 1:nrow(nhd_df)) {
    perenniality_vec[i] <- routing_func(fromNode_vec[i], toNode_vec, perenniality_vec[i], perenniality_vec, order_vec[i], order_vec, Q_vec[i], Q_vec)
  }

  nhd_df$perenniality <- perenniality_vec

  #remove ephemeral ponds from 'ephemeral' as WOTUS only wants streams
    #use Fcode to only keep streams and remove canals, ditches, lakes/reservoirs
    #some streams width adjacent to swamp/marsh are tagged as artifical paths (i.e. lakes) for some reason. We can use the lack of assigned widths to lakes/reservoirs to remap these FCodes to streams, i.e. 460
  nhd_df$FCode_riv <- ifelse(substr(nhd_df$FCode_riv,1,3) == '558' & is.na(nhd_df$width_m)== 0, '46000', nhd_df$FCode_riv)
  nhd_df$perenniality <- ifelse(nhd_df$perenniality == 'ephemeral' & substr(nhd_df$FCode_riv,1,3) != '460', 'non_ephemeral', nhd_df$perenniality)

  out <- nhd_df %>% dplyr::select('NHDPlusID','ToNode', 'StreamOrde', 'FCode_riv', 'FCode_waterbody','AreaSqKm', 'TotDASqKm', 'Q_cms', 'width_m', 'LengthKM', 'perenniality', 'nlcd_broad')
  return(out)
}


#' Calculate runoff ratio per HUC4 basin
#'
#' @name calcRunoffEff
#'
#' @param path_to_data: data repo path directory
#' @param huc4_c: HUC4 basin code
#'
#' @import sf
#' @import raster
#' @import terra
#' @import ncdf4
#'
#' @return dataframe with runoff coefficients at HUC level 4 scale
calcRunoffEff <- function(path_to_data, huc4_c){

  ##READ IN HUC4 BASIN
  huc2 <- substr(huc4_c, 1, 2)
  basin <- st_read(paste0(path_to_data, '/HUC2_', huc2, '/WBD_', huc2, '_HU2_Shape/Shape/WBDHU4.shp')) %>% select(c('huc4', 'name')) #basin polygons
  basin <- dplyr::filter(basin, huc4 == huc4_c)

  ##SETUP RUNOFF DATA
  HUC4_runoff <- read.table(paste0(path_to_data, '/for_ephemeral_project/HUC4_runoff_mm.txt'), header=TRUE)
  HUC4_runoff$huc4 <- as.character(HUC4_runoff$huc_cd)   #setup IDs
  HUC4_runoff$huc4 <- ifelse(nchar(HUC4_runoff$huc_cd)==3, paste0('0', HUC4_runoff$huc_cd), HUC4_runoff$huc_cd)
  HUC4_runoff$runoff_ma_mm_yr <- rowMeans(HUC4_runoff[,71:122]) #1970-2021   #get long-term mean annual runoff
  HUC4_runoff <- dplyr::select(HUC4_runoff, c('huc4', 'runoff_ma_mm_yr'))
  basin <- left_join(basin, HUC4_runoff, by='huc4')

  basin <- vect(basin)

  ##SETUP MEAN DAILY PRECIP DATA
  precip <- raster::brick(paste0(path_to_data, '/for_ephemeral_project/precip.V1.0.day.ltm.nc')) #raster must be used for this, NOT terra in its current form
  precip <- raster::rotate(precip)
  precip_mean <- rast(mean(precip, na.rm=T)) #get long term mean for 1981-2010, converted to terra spatRaster

  ##REPROJECT
  basin <- project(basin, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs ")
  precip_mean <- project(precip_mean, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs ")

  precip_mean_basins <- terra::extract(precip_mean, basin, fun='mean', na.rm=TRUE)
  basin$precip_ma_mm_yr <- (precip_mean_basins$layer*365) #apply long term mean over the entire year

  #Manually adding results from Canadian gauges within the basin because no usgs gauges to calc runoff
  #Some basins have no USGS gauges and therefore no USGS runoff data. I manually set their annual runoff timeseries to adjacent basins.
  basin$runoff_ma_mm_yr <- ifelse(basin$huc4 == '0904', 17.40769, basin$runoff_ma_mm_yr) #m3/s to mm/yr using HUC4 1005
  basin$runoff_ma_mm_yr <- ifelse(basin$huc4 == '0420', 412.7192, basin$runoff_ma_mm_yr) #m3/s to mm/yr using HUC4 0402
  basin$runoff_ma_mm_yr <- ifelse(basin$huc4 == '0427', 426.2077, basin$runoff_ma_mm_yr) #m3/s to mm/yr using HUC4 0413
  basin$runoff_ma_mm_yr <- ifelse(basin$huc4 == '0429', 562.3712, basin$runoff_ma_mm_yr) #m3/s to mm/yr using HUC4 0414
  basin$runoff_ma_mm_yr <- ifelse(basin$huc4 == '0430', 562.3712, basin$runoff_ma_mm_yr) #m3/s to mm/yr using HUC4 0414

  #runoff efficiency
  basin$runoff_eff <- basin$runoff_ma_mm_yr / basin$precip_ma_mm_yr #efficiency of P to streamflow routing

  #save as rds file
  basin <- as.data.frame(basin)

  return(basin)
}



#' Calculates a first-order runoff-generation threshold [mm/dy] using geomorphic scaling a characteristic minimum headwater stream width from Allen et al. 2018
#'
#' @name calcRunoffThresh
#'
#' @param rivnet: basin hydrography model
#'
#' @import readr
#'
#' @return runoff-generation thresholdfor a given HUC4 basin [mm/dy]
calcRunoffThresh <- function(rivnet) {
  #Width AHG scaling relation
  widAHG <- readr::read_rds('/nas/cee-water/cjgleason/craig/RSK600/cache/widAHG.rds') #width AHG model
  a <- exp(coef(widAHG)[1])
  b <- coef(widAHG)[2]
  W_min <- 0.32 #Allen et al 2018 minimum headwater width in meters

  #geomorphic scaling function to get ephemeral runoff generation threshold
  rivnet$runoff_min_mm_dy <- ifelse(rivnet$perenniality == 'ephemeral' & rivnet$TotDASqKm  > 0, ((W_min/a)^(1/b) /( rivnet$TotDASqKm*1e6) ) * 86400000, NA) #[mm/dy] only use non-0 km2 catchments for this....

  return(mean(rivnet$runoff_min_mm_dy, na.rm=T))
}



#' Calculates a first-order 'number flowing days' per HUC4 basin using long-term runoff ratio and daily precip for 1980-2010
#'
#' @name calcFlowingDays
#'
#' @param path_to_data: path to data repo
#' @param huc4: huc basin level 4 code
#' @param runoff_eff: calculated runoff ratio per HUC4 basin
#' @param runoff_thresh: [mm] a priori runoff threshold for 'streamflowflow generation'
#' @param runoffEffScalar: [percent] sensitivty parameter to use to perturb model sensitivty to runoff efficiency
#' @param runoffMemory: sensitivity parameter to test 'runoff memory' in number of flowing days calculation: even if rain stops, there will be some overland flow and interflow that are delayed in their reaching the river
#'
#' @import terra
#' @import raster
#'
#' @return number of flowing days for a given HUC4 basin
calcFlowingDays <- function(path_to_data, huc4, runoff_eff, runoff_thresh, runoffEffScalar, runoffMemory){
  #get basin to clip wtd model
  huc2 <- substr(huc4, 1, 2)
  basins <- terra::vect(paste0(path_to_data, '/HUC2_', huc2, '/WBD_', huc2, '_HU2_Shape/Shape/WBDHU4.shp')) #basin polygon
  basin <- basins[basins$huc4 == huc4,]

  #add year gridded precip
  precip <- raster::brick(paste0(path_to_data, '/for_ephemeral_project/dailyPrecip_1980_2010.gri')) #daily precip for 1980-2010
  precip <- raster::rotate(precip) #convert 0-360 lon to -180-180 lon
  basin <- terra::project(basin, '+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0 ')
  basin <- as(basin, 'Spatial')
  precip <- raster::crop(precip, basin)

  #obtain results for flowing days, given a runoff threshold and huc4-scale runoff efficiency (both calculated per basin previously)
  thresh <- runoff_thresh / (runoff_eff[runoff_eff$huc4 == huc4,]$runoff_eff + runoff_eff[runoff_eff$huc4 == huc4,]$runoff_eff*runoffEffScalar) #convert runoff thresh to precip thresh using runoff efficiency coefficient (because proportion of P that becomes Q varies regionally)
  precip <- raster::calc(precip, fun=function(x){addingRunoffMemory(x, runoffMemory, thresh)}) #calculate number of days flowing per cell, introducing 'runoff memory' that handles potential double counting (if required)

  numFlowingDays <- (raster::cellStats(precip, 'mean')) #average over HUC4 basin DEFAULT FUNCTION IGNORES NAs

  numFlowingDays <- (numFlowingDays/(31*365))*365 #average number of dys per year across the record (31 years)

  return(numFlowingDays)
}



#' Tabulates model summary statistics (namely % discharge and % length) at the huc 4 level
#'
#' @name collectResults
#'
#' @param nhd_df: NHD hydrography with river perenniality status
#' @param numFlowingDays: number of flowing days for a given HU43 basin
#' @param huc4: huc basin level 4 code
#'
#' @return summary statistics
collectResults <- function(nhd_df, numFlowingDays, huc4){
  #concatenate and generate initial (not scaled) results
  results_nhd <- data.frame(
    'huc4'=huc4,
    'num_flowing_dys'=numFlowingDays,
    'notEphNetworkLength' = sum(nhd_df[nhd_df$perenniality != 'ephemeral',]$LengthKM, na.rm=T),
    'ephemeralNetworkLength' = sum(nhd_df[nhd_df$perenniality == 'ephemeral',]$LengthKM, na.rm=T),
    'ephemeralCultDevpNetworkLength'=sum(nhd_df[nhd_df$perenniality == 'ephemeral' & nhd_df$nlcd_broad %in% c(20,70),]$LengthKM, na.rm=T),
    'totalNotEphQ' = sum(nhd_df[nhd_df$perenniality != 'ephemeral',]$Q_cms, na.rm=T),
    'totalephmeralQ_flowing' = sum(nhd_df[nhd_df$perenniality == 'ephemeral',]$Q_cms, na.rm=T)* (365/numFlowingDays), #scale to 'flowingQ'
    'totalephmeralQ' = sum(nhd_df[nhd_df$perenniality == 'ephemeral',]$Q_cms, na.rm=T),
    'n'=nrow(nhd_df))

  results_nhd$percQ_eph_flowing <- results_nhd$totalephmeralQ_flowing / (results_nhd$totalNotEphQ + results_nhd$totalephmeralQ_flowing)
  results_nhd$percQ_eph <- results_nhd$totalephmeralQ / (results_nhd$totalNotEphQ + results_nhd$totalephmeralQ)
  results_nhd$percLength_eph <- results_nhd$ephemeralNetworkLength / (results_nhd$ephemeralNetworkLength + results_nhd$notEphNetworkLength)
  results_nhd$percLength_eph_cult_devp =  results_nhd$ephemeralCultDevpNetworkLength/((results_nhd$ephemeralNetworkLength + results_nhd$notEphNetworkLength))

  return(results_nhd)
}



#' Fits horton laws to ephemeral data and calculates number of additional stream orders to match the observed ephemeral data occurence off  network
#'
#' @name scalingFunc
#'
#' @param validationResults: completed snapped and cleaned WOTUS JD validation dataset
#'
#' @import dplyr
#'
#' @return list of properties obtained from horton fitting: new minimum order ('ephMinOrder'), desired epehemeral frequncy ('desiredFreq'), horton model ('horton_lm'), horton coefficient ('Rb')
scalingFunc <- function(validationResults){
  desiredFreq <- validationResults$eph_features_off_nhd_tot #ephemeral features not on the NHD, what we want to scale too
  
  df <- validationResults$validation_fin
  df <- dplyr::filter(df, is.na(StreamOrde)==0 & distinction == 'ephemeral') #remove USGS gages, which are always perennial anyway
  
  df <- dplyr::group_by(df, StreamOrde) %>%
    dplyr::summarise(n=n())
  
  #fit model for Horton number of streams per order
  lm <- lm(log(n)~StreamOrde, data=df)
  Rb <- 1/exp(lm$coefficient[2]) #Horton law parameter
  ephMinOrder <- round((log(desiredFreq) - log(df[df$StreamOrde == max(df$StreamOrde),]$n) - max(df$StreamOrde)*log(Rb))/(-1*log(Rb)),0) #algebraically solve for smallest order in the system
  df_west <- df
  
  return(list('desiredFreq'=desiredFreq,
              'df'=df,
              'ephMinOrder'=ephMinOrder,
              'horton_lm'=lm,
              'Rb'=  Rb)) #https://www.engr.colostate.edu/~ramirez/ce_old/classes/cive322-Ramirez/CE322_Web/Example_Horton_html.htm
}



#' Scales model results to additional stream order(s) if necessary. Horton ratio used in this calcualtion comes from the NHD 3rd order calculated ratio (to be somehere in the middle of the network)
#'
#' @name scalingByBasin
#'
#' @param scalingModel: Horton laws, already fit to ephemeral field data
#' @param rivNetFin: nhd hydrography for a given huc4 basin
#' @param results: results file for a given huc4 basin
#' @param huc4: HUC4 basin code
#'
#' @import dplyr
#'
#' @return updated results dataframe with scaled and scaled_flowing results
scalingByBasin <- function(scalingModel, rivNetFin, results, huc4){
  #fit horton laws to this river system (east vs west of Mississippi, different scaling)
  numNewOrders <- 1 - scalingModel$ephMinOrder
  
  #num flowing days per earlier rain analysis
  numFlowingDays <- results$num_flowing_dys
  
  #number and average discharge of ephemeral streams
  df <- dplyr::filter(rivNetFin, perenniality == 'ephemeral') %>%
    dplyr::group_by(StreamOrde) %>%
    dplyr::summarise(n=n(),
                     Qbar = mean(Q_cms, na.rm=T),
                     Qbar_adj = mean(Q_cms, na.rm=T) * (365/numFlowingDays))
  
  #rewrte stream orders for scaling (when appropritate)
  if(numNewOrders > 0){
    df$old_orders <- df$StreamOrde
    df$StreamOrde <- df$StreamOrde + numNewOrders
    
    #get horton ratios
    lm <- lm(log(n)~StreamOrde, data=df)
    Rb <- 1/exp(lm$coefficient[2]) #Horton law parameter for num streams
    lm2 <- lm(log(Qbar)~StreamOrde, data=df)
    Rq <- exp(lm2$coefficient[2]) #Horton law parameter for mean Q
    lm3 <- lm(log(Qbar_adj)~StreamOrde, data=df)
    Rq_f <- exp(lm3$coefficient[2]) #Horton law parameter for mean flowing Q
    
    #scale to new minimum order
    for (i in 1:numNewOrders){
      new <- data.frame('StreamOrde'=i, 'n'=NA, 'Qbar'=NA)
      new$old_orders <- NA
      new$n <- df[df$StreamOrde == max(df$StreamOrde),]$n*Rb^(max(df$StreamOrde) - i)
      if(i ==1){ #do first order first (as its different)
        new$Qbar <- (df[df$StreamOrde == 3,]$Qbar)/(Rq^(df[df$StreamOrde == 3,]$StreamOrde - 1)) #ratio using 3rd order
        new$Qbar_adj <- (df[df$StreamOrde == 3,]$Qbar_adj)/(Rq_f^(df[df$StreamOrde == 3,]$StreamOrde - 1)) #ratio using 3rd order
      }
      else{ #do all other additional orders (if necessary)
        new$Qbar <- df[df$StreamOrde == 1,]$Qbar*Rq^(i-1)
        new$Qbar_adj <- df[df$StreamOrde == 1,]$Qbar*Rq_f^(i-1)
      }
      df <- rbind(df, new)
    }
    
    df <- df[order(df$StreamOrde), ]
    
    #get water volume in additional stream order
    additionalQ <- sum(df[1:numNewOrders,]$Qbar * df[1:numNewOrders,]$n) #mean annual
    additionalQ_flowing <- sum(df[1:numNewOrders,]$Qbar_adj * df[1:numNewOrders,]$n) #mean annual flowing
    
    scalingFlag <- 1
  }
  
  #when no additional scaling is done
  else{
    additionalQ <- 0
    additionalQ_flowing <- 0
    scalingFlag <- 0
  }
  
  #adding scaled results to previous results
  results$totalephmeralQ_scaled <- results$totalephmeralQ + additionalQ #mean annual
  results$totalephmeralQ_flowing_scaled <- results$totalephmeralQ_flowing + additionalQ_flowing #mean annual flowing
  
  results$percQ_eph_scaled <- results$totalephmeralQ_scaled / (results$totalephmeralQ_scaled + results$totalNotEphQ) #mean annual percent
  results$percQ_eph_flowing_scaled <- results$totalephmeralQ_flowing_scaled / (results$totalephmeralQ_flowing_scaled + results$totalNotEphQ) #mean annual flowing percent
  
  results$scalingFlag <- scalingFlag
  
  return(results)
}




#' Determines an 'ideal snapping threshold'.
#' This is done by calculating horton scaling performance (via MAE for number of streams) on ephemeral data, given a set of NHD snapping distance thresholds
#'
#' @name scalingTestWrapper
#'
#' @param threshs: snapping thresholds to test
#' @param combined_validation: validation dataset (with snapping distances)
#' @param ourFieldData: New England field assessments of river ephemerality (to be joined to combined_validation)
#'
#' @import Metrics
#' @import dplyr
#' @import ggplot2
#'
#' @return df of senstivity test results
snappingSensitivityWrapper <- function(threshs, combined_validation, ourFieldData){

  out <- data.frame()
  for(i in threshs){
    validationResults <- validateModel(combined_validation, ourFieldData, i)

    #validation test
    df <- validationResults$validation_fin
    df$TP <- ifelse(df$distinction == 'ephemeral' & df$perenniality == 'ephemeral', 1, 0)
    df$FP <- ifelse(df$distinction == 'non_ephemeral' & df$perenniality == 'ephemeral', 1, 0)
    df$TN <- ifelse(df$distinction == 'non_ephemeral' & df$perenniality == 'non_ephemeral', 1, 0)
    df$FN <- ifelse(df$distinction == 'ephemeral' & df$perenniality == 'non_ephemeral', 1, 0)

    basinAccuracy <- round((sum(df$TP, na.rm=T) + sum(df$TN, na.rm=T))/(sum(df$TP, na.rm=T) + sum(df$TN, na.rm=T) + sum(df$FN, na.rm=T) + sum(df$FP, na.rm=T)),2)

    #scaling test
    desiredFreq <- validationResults$eph_features_off_nhd_tot #ephemeral features not on the NHD, eventual number we want to scale too

    df <- validationResults$validation_fin
    df <- dplyr::filter(df, is.na(StreamOrde)==0 & distinction == 'ephemeral') #remove USGS gages, which are always perennial anyway

    df <- dplyr::group_by(df, StreamOrde) %>%
        dplyr::summarise(n=n())

    #fit model for Horton number of streams per order
    lm <- lm(log(n)~StreamOrde, data=df)
    Rb <- 1/exp(lm$coefficient[2]) #Horton law parameter

    predN <- df[df$StreamOrde == max(df$StreamOrde),]$n*Rb^(max(df$StreamOrde) - df$StreamOrde)
    maeN <- Metrics::mae(log(df$n), log(predN))
    ephMinOrder <- 1 - round((log(desiredFreq) - log(df[df$StreamOrde == max(df$StreamOrde),]$n) - max(df$StreamOrde)*log(Rb))/(-1*log(Rb)),0) #algebraically solve for smallest order in the system
    temp <- data.frame('thresh'=i,
                       'mae'=maeN,
                       'ephMinOrder'=ephMinOrder,
                       'basinAccuracy'=basinAccuracy,
                       'n'=sum(df$n))

    out <- rbind(out, temp)
  }

  return(out)
}
