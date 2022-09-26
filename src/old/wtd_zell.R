#' get ephemeral threshold using EPA/WOTUS distinctions between intermittent and ephemeral streams
#getThreshold <- function(rivnet, fieldData) {
#  fieldData <- dplyr::left_join(fieldData, rivnet, 'NHDPlusID')

#  #perennial sites
#  data_per <- dplyr::filter(fieldData, resource_type %in%  c('A2TRIBPER', 'A1TNWFED', 'A1TNW10', 'USGS_gage'))
#  data_per$wtd_m <- data_per$wtd_m_median
#  data_per$id <- 'perennial'
#  data_per <- dplyr::select(data_per, c('wtd_m', 'id'))

  #intermittent sites
#  data_int <- dplyr::filter(fieldData, resource_type == 'A2TRIBINT')
#  data_int$wtd_m <- data_int$wtd_m_median
#  data_int$id <- 'intermittent'
#  data_int <- dplyr::select(data_int, c('wtd_m', 'id'))

  #ephemerl sites
#  data_eph <- dplyr::filter(fieldData, resource_type  == 'B3EPHEMERAL')
#  data_eph$wtd_m <- data_eph$wtd_m_median
#  data_eph$id <- 'ephemeral'
#  data_eph <- dplyr::select(data_eph, c('wtd_m', 'id'))

#  data_fin <- rbind(data_per, data_int, data_eph)

#  stats <- dplyr::group_by(data_fin, id) %>%
#      summarise(median = median(wtd_m, na.rm=T),
#                mean = mean(wtd_m, na.rm=T),
#                sd = sd(wtd_m, na.rm=T))

#  return(stats)
#}



#  if(summarizer == 'median'){
#    nhd_df$perenniality <- mapply(perenniality_func_zell, nhd_df$wtd_m_median, nhd_df$depth_m, thresh, err)
#  } else if(summarizer == 'mean'){
#    nhd_df$perenniality <- mapply(perenniality_func_zell, nhd_df$wtd_m_mean, nhd_df$depth_m, thresh, err)
#  } else if(summarizer == 'min'){
#    nhd_df$perenniality <- mapply(perenniality_func_zell, nhd_df$wtd_m_min, nhd_df$depth_m, thresh, err)
#  } else if(summarizer == 'max'){
#    nhd_df$perenniality <- mapply(perenniality_func_zell, nhd_df$wtd_m_max, nhd_df$depth_m, thresh, err)
#  } else { #default is median
#    nhd_df$perenniality <- mapply(perenniality_func_zell, nhd_df$wtd_m_median, nhd_df$depth_m, thresh, err)
#  }


#' Calculates river ephemerality status using Zell et al 202 mean annual WTD
#'
#' @name perenniality_func_zell
#'
#' @param wtd_m: water table depth summary stat (extracted earlier) along reach [m]
#' @param depth: river/lake/reservoir depth [m]
#' @param thresh: 'error buffer' for water table depth (so it isn't exactly zero) [m]
#' @param err: additional error term that can be folded into threshold analysis (set to zero here) [m]
#'
#' @return 'epehemeral' or 'perennial' (here, this means not ephemeral)
perenniality_func_zell <- function(wtd_m, depth, thresh, err){
  wtd_m <- ifelse(wtd_m > 0, 0, wtd_m)

  if(is.na(wtd_m) == 1){ #NA handling for  fore streams that flow into the US basins
     return('foreign')
  } else if(wtd_m < (thresh+err+(-1*depth))) {
     return('ephemeral')
  } else{
     return('perennial')
  }
}


#' extracts water table depth at the NHD flowlines. How the pixels are summarized at each reach is specified in the summariseWTD() function within '~/src/utils.R``
#'
#' @name extractWTD
#'
#' @note Be aware of the expilict repo structure within the data repo, i.e. even though the user specifies the path to the data repo, there are assumed internal folders.
#'
#' @param path_to_data: data repo path directory
#' @param huc4: huc basin level 4 code
#'
#' @import terra
#' @import sf
#' @import dplyr
#'
#' @return NHD hydrograpy with mean annual water table depth attached.
extractWTD_MA <- function(path_to_data, huc4){
  indiana_hucs <- c('0508', '0509', '0514', '0512', '0712', '0404', '0405', '0410') #indiana-effected basins

  sf::sf_use_s2(FALSE)

  huc2 <- substr(huc4, 1, 2)

  #get basin to clip wtd model
  basins <- terra::vect(paste0(path_to_data, '/HUC2_', huc2, '/WBD_', huc2, '_HU2_Shape/Shape/WBDHU4.shp')) #basin polygon
  basin <- basins[basins$huc4 == huc4,]

  #Process-based water table depth modeling
  wtd <- terra::rast(paste0(path_to_data, '/for_ephemeral_project/conus_MF6_SS_Unconfined_250_dtw.tif'))   #steady state averages
  wtd$wtd_m <- wtd$conus_MF6_SS_Unconfined_250_dtw * -1 #(convert to depth below water table)

  #USGS NHD
  dsnPath <- paste0(path_to_data, '/HUC2_', huc2, '/NHDPLUS_H_', huc4, '_HU4_GDB/NHDPLUS_H_', huc4, '_HU4_GDB.gdb')

  #load river network, depending on indiana-effect or not
  if(huc4 %in% indiana_hucs) {
    nhd <- sf::st_read(paste0(path_to_data, '/HUC2_', huc2, '/indiana/indiana_fixed_', huc4, '.shp'))
    nhd <- sf::st_zm(nhd)
    colnames(nhd)[10] <- 'WBArea_Permanent_Identifier'
  }
  else{
    nhd <- sf::st_read(dsn=dsnPath, layer='NHDFlowline', quiet=TRUE)
    nhd <- sf::st_zm(nhd)
    nhd <- fixGeometries(nhd)
  }

  #load lakes
  lakes <- sf::st_read(dsn=dsnPath, layer='NHDWaterbody', quiet=TRUE)
  lakes <- sf::st_zm(lakes)

  lakes <- as.data.frame(lakes) %>%
    dplyr::filter(FType %in% c(390, 436)) #lakes/reservoirs only
  colnames(lakes)[6] <- 'LakeAreaSqKm'
  NHD_HR_EROM <- sf::st_read(dsn = dsnPath, layer = "NHDPlusEROMMA", quiet=TRUE) #mean annual flow table
  NHD_HR_VAA <- sf::st_read(dsn = dsnPath, layer = "NHDPlusFlowlineVAA", quiet=TRUE) #additional 'value-added' attributes

  nhd <- left_join(nhd, lakes, by=c('WBArea_Permanent_Identifier'='Permanent_Identifier'))

  if(huc4 %in% indiana_hucs){
    colnames(nhd)[17] <- 'NHDPlusID' #some manual rewriting b/c this columns get doubled from previous joins where data was needed for specific GIS tasks...
  }
  else{
    colnames(nhd)[16] <- 'NHDPlusID' #some manual rewriting b/c this columns get doubled from previous joins where data was needed for specific GIS tasks...
  }

  nhd <- left_join(nhd, NHD_HR_EROM, by='NHDPlusID')
  nhd <- left_join(nhd, NHD_HR_VAA, by='NHDPlusID')
  nhd$StreamOrde <- nhd$StreamCalc #stream calc handles divergent streams correctly: https://pubs.usgs.gov/of/2019/1096/ofr20191096.pdf
  nhd$Q_cms <- nhd$QEMA * 0.0283 #cfs to cms

  #handle indiana-effect basin stream orders
  if(huc4 %in% indiana_hucs){
    thresh <- c(2,2,2,2,3,2,3,2) #see README file
    thresh <- thresh[which(indiana_hucs == huc4)]
    nhd$StreamOrde <- ifelse(nhd$indiana_fl == 1, nhd$StreamOrde - thresh, nhd$StreamOrde)
  }

  #assign waterbody type for depth modeling
  nhd$waterbody <- ifelse(is.na(nhd$WBArea_Permanent_Identifier)==0 & is.na(nhd$LakeAreaSqKm) == 0 & nhd$LakeAreaSqKm > 0, 'Lake/Reservoir', 'River')

  #no pipelines, connectors, canals. Only rivers/streams and 'artificial paths', ie.e. lake throughflow lines. Also- even epehmeral streams should have a mean annual flow > 0...
  nhd <- filter(nhd, StreamOrde > 0 & Q_cms > 0)

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
  nhd <- terra::vect(nhd)

  #reproject to match wtd raster
  nhd <- terra::project(nhd, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs ")
  basin <- terra::project(basin, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs ")

  #clip wtd data to basin at hand
  wtd <- terra::crop(wtd, basin)

  nhd_wtd <- terra::extract(wtd$wtd_m, nhd, fun=summariseWTD)

  nhd_df <- as.data.frame(nhd)
  nhd_df <- select(nhd_df, c('NHDPlusID', 'StreamOrde', 'HydroSeq', 'FromNode', 'ToNode','Q_cms', 'LengthKM', 'width_m', 'depth_m'))

  nhd_df$wtd_m_min <- as.numeric(nhd_wtd$wtd_m.min)
  nhd_df$wtd_m_median <- as.numeric(nhd_wtd$wtd_m.median)
  nhd_df$wtd_m_mean <- as.numeric(nhd_wtd$wtd_m.mean)
  nhd_df$wtd_m_max <- as.numeric(nhd_wtd$wtd_m.max)

  return(nhd_df)
}
