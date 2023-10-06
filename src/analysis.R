## Main functions for running the analysis.
## Craig Brinkerhoff
## Winter 2023


#' Preps hydrography shapefiles into lightweight routing tables. Also extracts monthly water table depth per streamline
#'
#' @name extractData
#'
#' @note Be aware of the explicit repo structure within the data repo, i.e. even though the user specifies the path to the data repo, there are assumed internal folders.
#'
#' @param path_to_data: data repo path directory
#' @param huc4: huc basin level 4 code
#'
#' @import terra
#' @import sf
#' @import dplyr
#'
#' @return df of NHD-HR routing table with all necessary attributes
extractData <- function(path_to_data, huc4, Hbmodel){
  ########SETUP
  indiana_hucs <- c('0508', '0509', '0514', '0512', '0712', '0404', '0405', '0410') #Indiana-effected basins

  sf::sf_use_s2(FALSE)

  huc2 <- substr(huc4, 1, 2)

  #setup physiographic region
  huc4id <- huc4
  shapefile <- sf::st_read(paste0(path_to_data, '/HUC2_', huc2, '/WBD_', huc2, '_HU2_Shape/Shape/WBDHU4.shp')) %>% dplyr::select(c('huc4', 'name')) %>% dplyr::filter(huc4 == huc4id)

  regions <- sf::st_read(paste0(path_to_data, '/other_shapefiles/physio.shp')) #physiographic regions
  regions <- fixGeometries(regions)

  shapefile <- sf::st_join(shapefile, regions, largest=TRUE) #take the physiogrpahic region that the basin is mostly in (dominant intersection)
  physio_region <- shapefile$DIVISION

  # setup CONUS shapefile
  states <- sf::st_read(paste0(path_to_data,'/other_shapefiles/cb_2018_us_state_5m.shp'))
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
  wtd <- terra::rast(paste0(path_to_data, '/for_ephemeral_project/NAMERICA_WTD_monthlymeans.nc'))   #monthly averages of hourly model runs for 2004-2014 at 1km resolution

  #HUC4 basin at hand
  basins <- terra::vect(paste0(path_to_data, '/HUC2_', huc2, '/WBD_', huc2, '_HU2_Shape/Shape/WBDHU4.shp')) #basin polygon
  basin <- basins[basins$huc4 == huc4,]

  #USGS NHD
  dsnPath <- paste0(path_to_data, '/HUC2_', huc2, '/NHDPLUS_H_', huc4, '_HU4_GDB/NHDPLUS_H_', huc4, '_HU4_GDB.gdb')

  #load river network, depending on Indiana-effect or not (see ~/docs/README_Indiana.html for more details)
  if(huc4 %in% indiana_hucs) {
    nhd <- sf::st_read(paste0(path_to_data, '/HUC2_', huc2, '/indiana/indiana_fixed_', huc4, '.shp'))
    nhd <- sf::st_zm(nhd)
    colnames(nhd)[10] <- 'WBArea_Permanent_Identifier'
    nhd$NHDPlusID <- round(nhd$NHDPlusID, 0) #some of these have digits for some reason......
  }
  else{
    nhd <- sf::st_read(dsn=dsnPath, layer='NHDFlowline', quiet=TRUE)
    nhd <- sf::st_zm(nhd)
    nhd <- fixGeometries(nhd) #~src/utils.R
  }

  #fix Great lake basins with fake shoreline rivers
  if(huc4 %in% c('0402', '0405', '0406', '0407', '0408', '0411', '0412','0401','0410','0414','0403','0404')) {
    fix <- readr::read_csv(paste0('data/fix_',huc4,'.csv'))
    model <- dplyr::left_join(nhd, fix, by='NHDPlusID') %>%
      dplyr::filter(GL_pass == '1')
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
  nhd$Q_cms <- nhd$QBMA * 0.0283 #USGS discharge model
  nhd$Q_cms_adj <- nhd$QEMA*0.0283
  
  #handle Indiana-effected basin stream orders
  if(huc4 %in% indiana_hucs){
    thresh <- c(2,2,2,2,3,2,3,2) #see README file
    thresh <- thresh[which(indiana_hucs == huc4)]
    nhd$StreamOrde <- ifelse(nhd$indiana_fl == 1, nhd$StreamOrde - thresh, nhd$StreamOrde)
  }

  #assign waterbody type for depth modeling
  nhd$waterbody <- ifelse(is.na(nhd$WBArea_Permanent_Identifier)==0 & is.na(nhd$LakeAreaSqKm) == 0 & nhd$LakeAreaSqKm > 0, 'Lake/Reservoir', 'River')

  #fix erronous IDs for matching basins for routing (manually identified in CO2 projects)
  if(huc4 == '0514'){nhd[nhd$NHDPlusID == 24000100384878,]$StreamOrde <- 8}   #fix erroneous 'divergent' reach in the Ohio mainstem (matching Indiana file upstream)
  if(huc4 == '0514'){nhd[nhd$NHDPlusID == 24000100569580,]$ToNode <- 22000100085737} #from/to node ID typo (from Ohio River to Missouri River) so I manually fix it
  if(huc4 == '0706'){nhd[nhd$NHDPlusID == 22000400022387,]$StreamOrde <- 7} #error in stream order calculation because reach is miss-assigned as stream order 0 (on divergent path) which isn't true. Easiest to just skip over the reach because it's just a connector into the Mississippi River (from Wisconsin river)
  
  #no divergent channels, i.e. all downstream routing flows into a single downstream reach.
  nhd <- dplyr::filter(nhd, StreamOrde > 0)

  #calculate lake volumes (when appropriate)
  nhd$lakeVol_m3 <- 0.533 * (nhd$LakeAreaSqKm*1e6)^1.204 #https://doi.org/10.1002/2016GL071378

  #Calculate and assign lake percents to each throughflow line so that we have fractional lake surface areas and volumes for each throughflow line
  sumThroughFlow <- dplyr::filter(as.data.frame(nhd), is.na(WBArea_Permanent_Identifier)==0) %>% #This is based on reachLength/total throughflow line reach length
    dplyr::group_by(WBArea_Permanent_Identifier) %>%
    dplyr::summarise(sumThroughFlow = sum(LengthKM))
  nhd <- dplyr::left_join(nhd, sumThroughFlow, by='WBArea_Permanent_Identifier')
  nhd$lakePercent <- nhd$LengthKM / nhd$sumThroughFlow
  nhd$frac_lakeVol_m3 <- nhd$lakeVol_m3 * nhd$lakePercent
  nhd$frac_lakeSurfaceArea_m2 <- nhd$LakeAreaSqKm * nhd$lakePercent * 1e6

  #get river depth using hydraulic scaling
  nhd$a <- Hbmodel[Hbmodel$division == physio_region,]$a
  nhd$b <- Hbmodel[Hbmodel$division == physio_region,]$b
  nhd$depth_m <- mapply(depth_func, nhd$waterbody, nhd$frac_lakeVol_m3, nhd$frac_lakeSurfaceArea_m2*1e6, physio_region, nhd$TotDASqKm, nhd$a, nhd$b)

  ########EXTRACT DATA TO NHD-HR
  #convert back to terra to do extractions
  nhd <- terra::vect(nhd)

  #clip models to basin at hand
  wtd <- terra::crop(wtd, basin)

  #extract mean monthly water table depths along reach (as summary stats)
  nhd_wtd_01 <- terra::extract(wtd$WTD_1, nhd, fun=summariseWTD)
  nhd_wtd_02 <- terra::extract(wtd$WTD_2, nhd, fun=summariseWTD)
  nhd_wtd_03 <- terra::extract(wtd$WTD_3, nhd, fun=summariseWTD)
  nhd_wtd_04 <- terra::extract(wtd$WTD_4, nhd, fun=summariseWTD)
  nhd_wtd_05 <- terra::extract(wtd$WTD_5, nhd, fun=summariseWTD)
  nhd_wtd_06 <- terra::extract(wtd$WTD_6, nhd, fun=summariseWTD)
  nhd_wtd_07 <- terra::extract(wtd$WTD_7, nhd, fun=summariseWTD)
  nhd_wtd_08 <- terra::extract(wtd$WTD_8, nhd, fun=summariseWTD)
  nhd_wtd_09 <- terra::extract(wtd$WTD_9, nhd, fun=summariseWTD)
  nhd_wtd_10 <- terra::extract(wtd$WTD_10, nhd, fun=summariseWTD)
  nhd_wtd_11 <- terra::extract(wtd$WTD_11, nhd, fun=summariseWTD)
  nhd_wtd_12 <- terra::extract(wtd$WTD_12, nhd, fun=summariseWTD)

  #intersect with CONUS boundary to identify American/non-American rivers
  nhd_conus <- sf::st_intersection(sf::st_as_sf(nhd), states)
  nhd$conus <- ifelse(nhd$NHDPlusID %in% nhd_conus$NHDPlusID, 1,0)

  #Wrangle everything into a lightweight routing table (no spatial info anymore)
  nhd_df <- as.data.frame(nhd)
  nhd_df <- dplyr::select(nhd_df, c('NHDPlusID', 'StreamOrde', 'TerminalPa', 'HydroSeq', 'FromNode','ToNode', 'conus', 'FCode_riv', 'FCode_waterbody', 'waterbody', 'AreaSqKm', 'TotDASqKm','Q_cms', 'Q_cms_adj', 'LengthKM', 'depth_m', 'LakeAreaSqKm'))

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






#' Estimates reach perenniality and percent ephemeral contribution by routing downstream and running the model (see ~src/model.R)
#'
#' @name routeModel
#' 
#' @param nhd_df: basin routing table
#' @param huc4: huc basin level 4 code
#' @param thresh: threshold for 'persistent surface groundwater'
#' @param err: error tolerance for calculation (if desired)
#' @param upstreamDF: data frame of 'exporting Q reaches' for basins from previous level
#'
#' @import dplyr
#' @import readr
#'
#' @return routing table with reach perenniality added
routeModel <- function(nhd_df, huc4, thresh, err, upstreamDF){
  huc2 <- substr(huc4, 1, 2)

  #remove streams with absolutely no mean annual flow
  nhd_df <- dplyr::filter(nhd_df, Q_cms > 0)

  ######INTIAL PASS AT ASSIGNING PERENNIALITY using just water table depth (function handles non-CONUS streams, canals, ditches, and small ponds)
  nhd_df$perenniality <- mapply(perenniality_func_fan, nhd_df$wtd_m_median_01,  nhd_df$wtd_m_median_02,  nhd_df$wtd_m_median_03,  nhd_df$wtd_m_median_04,  nhd_df$wtd_m_median_05,  nhd_df$wtd_m_median_06,  nhd_df$wtd_m_median_07,  nhd_df$wtd_m_median_08,  nhd_df$wtd_m_median_09,  nhd_df$wtd_m_median_10,  nhd_df$wtd_m_median_11,  nhd_df$wtd_m_median_12, nhd_df$depth_m, thresh, err, nhd_df$conus, nhd_df$LakeAreaSqKm, nhd_df$FCode_riv)

  #some streams that are adjacent to swamps/marshes are tagged as artificial paths (i.e. lakes) even though they are streams.
      #We can use the lwaterbody tag to remap these back to streams, i.e. 460
  nhd_df$FCode_riv <- ifelse(substr(nhd_df$FCode_riv,1,3) == '558' & nhd_df$waterbody == 'River', '46000', nhd_df$FCode_riv)

  #####ROUTING
  #sort rivers from upstream to downstream
  nhd_df <- dplyr::filter(nhd_df, HydroSeq != 0)
  nhd_df <- nhd_df[order(-nhd_df$HydroSeq),] #sort descending

  #vectorize NHD-HR to help with speed
  fromNode_vec <- as.vector(nhd_df$FromNode)
  toNode_vec <- as.vector(nhd_df$ToNode)
  perenniality_vec <- as.vector(nhd_df$perenniality)
  order_vec <- as.vector(nhd_df$StreamOrde)
  Q_vec <- as.vector(nhd_df$Q_cms)
  Area_vec <- as.vector(nhd_df$TotDASqKm) #just initialized this way, it gets overridden down below
  dQ_vec <- as.vector(nhd_df$Q_cms) #just initialized this way, it gets overridden down below
  dArea_vec <- as.vector(nhd_df$AreaSqKm)
  percQEph_vec <- rep(1, length(fromNode_vec)) #just initialized this way, it gets overridden down below
  percAreaEph_vec <- rep(1, length(fromNode_vec)) #just initialized this way, it gets overridden down below
  
  #read in values exported from basins immediately upstream
  if(is.na(upstreamDF) == 0){ #to skip doing this in level 0
    upstreamDF <- dplyr::filter(upstreamDF, downstreamBasin == huc4)
    
    toNode_vec <- c(toNode_vec, upstreamDF$exported_ToNode)
    Q_vec <- c(Q_vec, upstreamDF$exported_Q_cms)
    Area_vec <- c(Area_vec, upstreamDF$exported_Area_km2)
    percQEph_vec <- c(percQEph_vec, upstreamDF$exported_percQEph_reach)
    percAreaEph_vec <- c(percAreaEph_vec, upstreamDF$exported_percAreaEph_reach)
    perenniality_vec <- c(perenniality_vec, upstreamDF$exported_perenniality)
  }

  #run vectorized models
  for (i in 1:nrow(nhd_df)) { #functions from ~src/model.R
    perenniality_vec[i] <- perenniality_func_update(fromNode_vec[i], toNode_vec, perenniality_vec[i], perenniality_vec, order_vec, Q_vec[i], Q_vec) #update perenniality given the upstream classification
    dQ_vec[i] <- getdQ(fromNode_vec[i], toNode_vec, Q_vec[i], Q_vec) #calculate lateral discharge / new water / catchment's contribution to discharge
    Area_vec[i] <- getTotDA(fromNode_vec[i], toNode_vec, dArea_vec[i], Area_vec) #calculate accumulated drainage area
    percQEph_vec[i] <- getPercEph(fromNode_vec[i], toNode_vec, perenniality_vec[i], dQ_vec[i], dArea_vec[i], Q_vec[i], Q_vec, percQEph_vec, 'discharge') #calculate percent water volume ephemeral
    percAreaEph_vec[i] <- getPercEph(fromNode_vec[i], toNode_vec, perenniality_vec[i], dQ_vec[i], dArea_vec[i], Area_vec[i], Area_vec, percAreaEph_vec, 'drainageArea') #calculate percent drainage area ephemeral
  }
  
  #remove exported parameters added to the vector temporarily
  if(is.na(upstreamDF) == 0){
    Q_vec <- Q_vec[1:nrow(nhd_df)]
    Area_vec <- Area_vec[1:nrow(nhd_df)]
    percQEph_vec <- percQEph_vec[1:nrow(nhd_df)]
    percAreaEph_vec <- percAreaEph_vec[1:nrow(nhd_df)]
    perenniality_vec <- perenniality_vec[1:nrow(nhd_df)]
  }

  #####PREP OUTPUT
  nhd_df$perenniality <- perenniality_vec
  nhd_df$dQ_cms <- dQ_vec
  nhd_df$percQEph_reach <- percQEph_vec
  nhd_df$percAreaEph_reach <- percAreaEph_vec
  nhd_df$TotDASqKm <- Area_vec
  
  #retroactively re-set small ponds and canals/ditches to non_ephemeral (classed differently above to not affect the downstream routing)
  nhd_df$perenniality <- ifelse(nhd_df$perenniality %in% c('canal_ditch', 'small_pond'), 'non_ephemeral', nhd_df$perenniality)

  out <- nhd_df %>%
    dplyr::select('NHDPlusID','ToNode', 'TerminalPa', 'StreamOrde', 'FCode_riv', 'FCode_waterbody','AreaSqKm', 'TotDASqKm', 'Q_cms', 'dQ_cms', 'LengthKM', 'perenniality', 'percQEph_reach', 'percAreaEph_reach')
  
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
#' @return df with runoff coefficients at HUC level 4 scale
calcRunoffEff <- function(path_to_data, huc4_c){
  ##READ IN HUC4 BASIN
  huc2 <- substr(huc4_c, 1, 2)
  basin <- sf::st_read(paste0(path_to_data, '/HUC2_', huc2, '/WBD_', huc2, '_HU2_Shape/Shape/WBDHU4.shp')) %>% 
    dplyr::select(c('huc4', 'name')) #basin polygons
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
  #add year gridded precipitation (decade chunks to use less memory)
  #1980-1989
  precip_1 <- raster::brick(paste0(path_to_data, '/for_ephemeral_project/dailyPrecip_1980_1989.gri')) #daily precip for 1980-1989
  precip_1 <- raster::rotate(precip_1) #convert 0-360 lon to -180-180 lon
  precip_mean_1 <- rast(mean(precip_1, na.rm=T)) #get long term mean

  #1990-1999
  precip_2 <- raster::brick(paste0(path_to_data, '/for_ephemeral_project/dailyPrecip_1990_1999.gri')) #daily precip for 1990-1999
  precip_2 <- raster::rotate(precip_2) #convert 0-360 lon to -180-180 lon
  precip_mean_2 <- rast(mean(precip_2, na.rm=T)) #get long term mean

  #2000-2006
  precip_3 <- raster::brick(paste0(path_to_data, '/for_ephemeral_project/dailyPrecip_2000_2006.gri')) #daily precip for 2000-2006
  precip_3 <- raster::rotate(precip_3) #convert 0-360 lon to -180-180 lon
  precip_mean_3 <- rast(mean(precip_3, na.rm=T)) #get long term mean

  ##REPROJECT
  basin <- project(basin, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs ")
  precip_mean_1 <- project(precip_mean_1, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs ")
  precip_mean_2 <- project(precip_mean_2, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs ")
  precip_mean_3 <- project(precip_mean_3, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs ")

  precip_mean <- (precip_mean_1 + precip_mean_2 + precip_mean_3)/3 #get long term mean

  precip_mean_basins <- terra::extract(precip_mean, basin, fun='mean', na.rm=TRUE)
  basin$precip_ma_mm_yr <- (precip_mean_basins$layer*365) #apply long term mean over the entire year

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





#' Calculates a first-order 'number ephemeral flowing days' per HUC4 basin
#'
#' @name calcFlowingDays
#'
#' @param path_to_data: data repo path directory
#' @param huc4: huc basin level 4 code
#' @param runoff_eff: calculated runoff ratio per HUC4 basin
#' @param runoff_thresh: [mm] operational runoff threshold for ephemeral streamflow
#' @param runoffEffScalar: [percent] sensitivity parameter to use to perturb model sensitivity to runoff efficiency
#' @param memory: bulk 'runoff memory' parameter for Nflw model
#'
#' @import terra
#' @import raster
#'
#' @return number of flowing days for a given HUC4 basin
calcFlowingDays <- function(path_to_data, huc4, runoff_eff, runoff_thresh, runoffEffScalar, memory){

  if(is.na(runoff_eff[runoff_eff$huc4 == huc4,]$runoff_eff)){ #great lakes handling
    return(NA)
  }

  #get basin to clip precip model
  huc2 <- substr(huc4, 1, 2)
  basins <- terra::vect(paste0(path_to_data, '/HUC2_', huc2, '/WBD_', huc2, '_HU2_Shape/Shape/WBDHU4.shp')) #basin polygon
  basin <- basins[basins$huc4 == huc4,]
  basin <- terra::project(basin, '+proj=longlat +datum=WGS84 +no_defs')
  basin <- as(basin, 'Spatial')

  #obtain results for flowing days, given a runoff threshold and huc4-scale runoff efficiency (both calculated per basin previously)
  thresh <- runoff_thresh / (runoff_eff[runoff_eff$huc4 == huc4,]$runoff_eff + runoff_eff[runoff_eff$huc4 == huc4,]$runoff_eff*runoffEffScalar) #convert runoff thresh to precip thresh using runoff efficiency coefficient

  #loop through years
  numFlowingDays <- rep(NA,27) #years
  k <- 1
  for(i in seq(1980,2006,1)){
    precip <- raster::stack(paste0(path_to_data, '/for_ephemeral_project/precip_model/precip.V1.0.',i,'.nc'))
    precip <- terra::rotate(precip) #convert 0-360 lon to -180-180 lon
    precip <- terra::crop(precip, basin)

    #convert to terra to df
    precip <- terra::rast(precip)
    df <- as.data.frame(precip) #convert rasterLayer to df for easy summarizing across basin and over time

    #average across the basin (across pixels) so we have a single timeseries
    df <- colMeans(df, na.rm=T)

    #convert to flowing/non-flowing
    df[df < thresh] <- 0
    df[df >= thresh] <- 1

    orig <- df

    # add watershed memory
     if(memory == 0){
       out <- sum(df)
       return(mean(out, na.rm=T))
     }
     else{
       #propagate memory for days following runoff events
       for(m in 1:length(orig)){
          if(df[m] == 1 & orig[m] == 1){
            for(j in seq(1+m,memory+m,1)){
              df[j] <- 1
            }
        }
       }
       df <- df[1:length(orig)] #remove 'memory' added beyond the year days (meaningless add ons)
    }

    #total flowing days per year
    numFlowingDays[k] <- sum(df)

    k <- k + 1
  }

  avg_numFlowingDays <- mean(numFlowingDays, na.rm=T)
    
  return(avg_numFlowingDays)
}







#' Calculates a first-order average month for 'ephemeral flowing days' per HUC4 basin
#'
#' @name calcDatesFlowingDays
#'
#' @param path_to_data: data repo path directory
#' @param huc4: huc basin level 4 code
#' @param runoff_eff: calculated runoff ratio per HUC4 basin
#' @param runoff_thresh: [mm] operational runoff threshold for ephemeral streamflow
#' @param runoffEffScalar: [percent] sensitivity parameter to use to perturb model sensitivity to runoff efficiency
#' @param memory: bulk 'runoff memory' parameter for Nflw model
#'
#' @import terra
#' @import raster
#'
#' @return mean month that ephemeeral flowing days occur ( for a given HUC4 basin)
calcDatesFlowingDays <- function(path_to_data, huc4, runoff_eff, runoff_thresh, runoffEffScalar, memory){
  if(is.na(runoff_eff[runoff_eff$huc4 == huc4,]$runoff_eff)){ #great lakes handling
    return(NA)
  }

  #get basin to clip precip model
  huc2 <- substr(huc4, 1, 2)
  basins <- terra::vect(paste0(path_to_data, '/HUC2_', huc2, '/WBD_', huc2, '_HU2_Shape/Shape/WBDHU4.shp')) #basin polygon
  basin <- basins[basins$huc4 == huc4,]
  basin <- terra::project(basin, '+proj=longlat +datum=WGS84 +no_defs')
  basin <- as(basin, 'Spatial')

  #obtain results for flowing days, given a runoff threshold and huc4-scale runoff efficiency (both calculated per basin previously)
  thresh <- runoff_thresh / (runoff_eff[runoff_eff$huc4 == huc4,]$runoff_eff + runoff_eff[runoff_eff$huc4 == huc4,]$runoff_eff*runoffEffScalar) #convert runoff thresh to precip thresh using runoff efficiency coefficient

  #loop through years
  daysFlowingDays <- rep(NA,27) #years
  k <- 1
  for(i in seq(1980,2006,1)){
    precip <- raster::stack(paste0(path_to_data, '/for_ephemeral_project/precip_model/precip.V1.0.',i,'.nc'))
    precip <- terra::rotate(precip) #convert 0-360 lon to -180-180 lon
    precip <- terra::crop(precip, basin)

    #convert to terra to df
    precip <- terra::rast(precip)
    df <- as.data.frame(precip) #convert rasterLayer to df for easy summarizing across basin and over time

    #average across the basin (across pixels) so we have a single timeseries
    df <- colMeans(df, na.rm=T)

    #convert to flowing/non-flowing
    df[df < thresh] <- 0
    df[df >= thresh] <- 1

    orig <- df

    # add watershed memory
     if(memory == 0){
       out <- sum(df)
       return(mean(out, na.rm=T))
     }
     else{
       #propagate memory for days following runoff events
       for(m in 1:length(orig)){
          if(df[m] == 1 & orig[m] == 1){
            for(j in seq(1+m,memory+m,1)){
              df[j] <- 1
            }
        }
       }
       df <- df[1:length(orig)] #remove 'memory' added beyond the year days (meaningless add ons)
    }

    flowing_dates <- as.numeric(substr(names(df[df == 1]), 7,8)) #extract months from flowing days
    median_flowing_month <- mean(flowing_dates, na.rm=T)
    daysFlowingDays[k] <- median_flowing_month

    k <- k + 1
  }

  return(mean(daysFlowingDays, na.rm=T))
}





#' Fits Horton laws to ephemeral data and calculates number of additional stream orders needed to re-produce the in situ data
#'
#' @name scalingFunc
#'
#' @param validationResults: completed snapped and cleaned in situ ephemeral classification df
#'
#' @import dplyr
#'
#' @return list of properties obtained from Horton fitting
scalingFunc <- function(validationResults){
  desiredFreq <- validationResults$eph_features_off_nhd_tot #ephemeral features not on the NHD, i.e. the number we are trying to scale to
  
  df <- validationResults$validation_fin
  df <- dplyr::filter(df, is.na(StreamOrde)==0 & distinction == 'ephemeral') #only use ephemeral rivers for ephemeral scaling
  
  df <- dplyr::group_by(df, StreamOrde) %>%
    dplyr::summarise(n=n())
  
  #fit model for Horton number of streams per order
  lm <- lm(log(n)~StreamOrde, data=df)
  Rb <- 1/exp(lm$coefficient[2]) #Horton law parameter
  ephMinOrder <- round((log(desiredFreq) - log(df[df$StreamOrde == max(df$StreamOrde),]$n) - max(df$StreamOrde)*log(Rb))/(-1*log(Rb)),0) #algebraically solve for smallest order in the system
  df_west <- df
  
  #return model
  return(list('desiredFreq'=desiredFreq,
              'df'=df,
              'ephMinOrder'=ephMinOrder,
              'horton_lm'=lm,
              'Rb'=  Rb))
}






#' Sensitivity of snapping threshold for field data to NHD-HR
#'
#' @name snappingSensitivityWrapper
#'
#' @param threshs: snapping thresholds to test
#' @param combined_validation: validation dataset with snapping distances to NHD-HR reaches
#' @param ourFieldData: our in situ ephemeral classifications of river ephemerality in northeastern US (to be joined to combined_validation)
#'
#' @import Metrics
#' @import dplyr
#' @import ggplot2
#'
#' @return df of sensitivity test results
snappingSensitivityWrapper <- function(threshs, combined_validation, ourFieldData){

  out <- data.frame()
  for(i in threshs){
    validationResults <- validateModel(combined_validation, ourFieldData, i) #~src/validation_ephemeral.R

    #validation test per HUC2 region
    df <- validationResults$validation_fin
    basinAccuracy <- dplyr::group_by(df, substr(huc4,1,2)) %>% #group by HUC2
      dplyr::mutate(TP = ifelse(distinction == 'ephemeral' & perenniality == 'ephemeral', 1, 0), #true positive rate
             FP = ifelse(distinction == 'non_ephemeral' & perenniality == 'ephemeral', 1, 0), #false positive rate
             TN = ifelse(distinction == 'non_ephemeral' & perenniality == 'non_ephemeral', 1, 0), #true negative rate
             FN = ifelse(distinction == 'ephemeral' & perenniality == 'non_ephemeral', 1, 0)) %>% #false negative rate
      dplyr::summarise(basinAccuracy = round((sum(TP, na.rm=T) + sum(TN, na.rm=T))/(sum(TP, na.rm=T) + sum(TN, na.rm=T) + sum(FN, na.rm=T) + sum(FP, na.rm=T)),2)) #overall accuracy

    #scaling test across CONUS
    desiredFreq <- validationResults$eph_features_off_nhd_tot #ephemeral features not on the NHD, eventual number we want to scale too

    #refit Horton model given i snapping threshold
    df <- validationResults$validation_fin
    df <- dplyr::filter(df, is.na(StreamOrde)==0 & distinction == 'ephemeral') #remove USGS gauges, which are always perennial anyway

    df <- dplyr::group_by(df, StreamOrde) %>%
      dplyr::summarise(n=n())

    #fit model for Horton number of streams per order
    lm <- lm(log(n)~StreamOrde, data=df)
    Rb <- 1/exp(lm$coefficient[2]) #Horton law parameter

    predN <- df[df$StreamOrde == max(df$StreamOrde),]$n*Rb^(max(df$StreamOrde) - df$StreamOrde)
    maeN <- Metrics::mae(log(df$n), log(predN))
    rmseN <- Metrics::rmse(log(df$n), log(predN))
    temp <- data.frame('thresh'=i,
                       'mae'=maeN,
                       'rmse'=rmseN,
                       'basinAccuracy'=basinAccuracy,
                       'n'=sum(df$n))

    out <- rbind(out, temp)
  }

  return(out)
}











#' Calculate ephemeral contribution to a basin's exported discharge (Q and drainage area)
#'
#' @name getResultsExported
#'
#' @param nhd_df: basin routing table + results
#' @param huc4: huc basin level 4 code
#' @param numFlowingDays: model estimated Nflw. This just gets passed along as a result
#' 
#' @import dplyr
#'
#' @return fraction of exported water and drainage area that is ephemeral
getResultsExported <- function(nhd_df, huc4, numFlowingDays, datesFlowingDays){
  #water volume ephemeral fraction at outlets
  exportDF <- dplyr::group_by(nhd_df, TerminalPa) %>%
    dplyr::arrange(desc(Q_cms)) %>% 
    dplyr::slice(1) %>% #only keep reach with max Q, i.e. the outlet per terminal network
    dplyr::ungroup()

  percQEph_exported <- sum(exportDF$Q_cms*exportDF$percQEph_reach)/sum(exportDF$Q_cms)
  percAreaEph_exported <- sum(exportDF$TotDASqKm*exportDF$percAreaEph_reach)/sum(exportDF$TotDASqKm)
  n_total <- nrow(nhd_df)
  n_eph <- sum(nhd_df$perenniality == 'ephemeral')
  median_eph_DA_km <- median(nhd_df[nhd_df$perenniality == 'ephemeral' & nhd_df$TotDASqKm  > 0,]$TotDASqKm, na.rm=T)
  perc_length_eph <- sum(nhd_df[nhd_df$perenniality == 'ephemeral',]$LengthKM, na.rm=T)/sum(nhd_df$LengthKM, na.rm=T)
  
  #prep output
  out <- data.frame('percQEph_exported'=percQEph_exported,
                    'percAreaEph_exported'=percAreaEph_exported,
                    'QEph_exported_cms'= sum(exportDF$Q_cms*exportDF$percQEph_reach),
                    'AreaEph_exported_km2'= sum(exportDF$TotDASqKm*exportDF$percAreaEph_reach),
                    'num_flowing_dys'=numFlowingDays,
                    'mean_date_flowing'=datesFlowingDays,
                    'n_eph'=n_eph,
                    'n_total'=n_total,
                    'perc_length_eph'=perc_length_eph,
                    'huc4'=huc4)

  return(out)
}










#' Calculates ephemeral contributions per stream order per basin (Q and drainage area)
#'
#' @name getResultsByOrder
#'
#' @param nhd_df: basin routing table + results
#' @param huc4: huc basin level 4 code
#' 
#' @import dplyr
#'
#' @return ephemeral fraction summary stats by order
getResultsByOrder <- function(nhd_df, huc4){

  #percents by order----------------------
  #discharge
  results_by_order_Q <- nhd_df %>%
    dplyr::group_by(StreamOrde) %>%
    dplyr::summarise(percQEph_reach_mean = mean(percQEph_reach),
                     percQEph_reach_median = median(percQEph_reach),
                     percQEph_reach_sd = sd(percQEph_reach))

  #drainage area
  results_by_order_Area <- nhd_df %>%
    dplyr::group_by(StreamOrde) %>%
    dplyr::summarise(percAreaEph_reach_mean = mean(percAreaEph_reach),
                     percAreaEph_reach_median = median(percAreaEph_reach),
                     percAreaEph_reach_sd = sd(percAreaEph_reach))
  
  #length streams
  results_by_order_length <- nhd_df %>%
    dplyr::group_by(StreamOrde) %>%
    dplyr::mutate(ephLengthKM = ifelse(perenniality == 'ephemeral', LengthKM, 0)) %>%
    dplyr::summarise(LengthEph = sum(ephLengthKM),
                     LengthTotal = sum(LengthKM))

  out <- dplyr::left_join(results_by_order_Q, results_by_order_Area, by='StreamOrde')
  out <- dplyr::left_join(out, results_by_order_length, by='StreamOrde')
  
  return(out)
}









#' Calculates frequency that headwater/first order reaches are classified ephemeral
#'
#' @name ephemeralFirstOrder
#'
#' @param nhd_df: basin routing table + results
#' @param huc4: huc4 basin id
#'
#' @return df containing number and % of headwater reaches that are classified ephemeral, per basin
ephemeralFirstOrder <- function(nhd_df, huc4) {
  #river source calculation
  eph <- sum(nhd_df[nhd_df$perenniality == 'ephemeral' & nhd_df$dQ_cms == nhd_df$Q_cms,]$LengthKM) #if these are equal, then they are the headwater subset of 1st order streams...
  total <- sum(nhd_df[nhd_df$dQ_cms == nhd_df$Q_cms,]$LengthKM)
  res <- ifelse(huc4 %in% c('0418', '0419', '0424', '0426', '0428'), NA, eph/total) #percent headwater reaches that are ephemeral
  
  #first order ('headwater') calculation
  eph2 <- sum(nhd_df[nhd_df$perenniality == 'ephemeral' & nhd_df$StreamOrde == 1,]$LengthKM) #if these are equal, then they are the headwater subset of 1st order streams...
  total2 <- sum(nhd_df[nhd_df$StreamOrde == 1,]$LengthKM)
  res2 <- ifelse(huc4 %in% c('0418', '0419', '0424', '0426', '0428'), NA, eph2/total2) #percent headwater reaches that are ephemeral

  out <- data.frame('huc4'=huc4,
                    'percEph_firstOrder'=res2,
                    'lenKM_eph_firstOrder'=eph2,
                    'lenKM_firstOrder'=total2,
                    'percEph_source'=res,
                    'lenKM_eph_source'=eph,
                    'lenKM_source'=total)

  return(out)
}










#' Finds model properties for reaches that connect to basins downstream (i.e. the exported values from the basin)
#'
#' @name getExportedQ
#'
#' @param model: basin routing table + results
#' @param huc4: river network basin code
#' @param lookUpTable: lookup table to get the downstream basins (when applicable) for all CONUS basins
#'
#' @import dplyr
#' @import sf
#'
#' @return list with 'exported properties' from reaches that connect to basins downstream. List includes reach fromNode ID to enable routing to downstream basin
getExportedQ <- function(model, huc4, lookUpTable) {
  lookUpTable <- dplyr::filter(lookUpTable, HUC4 == huc4)
  downstreamBasins <- lookUpTable$toBasin #downstream basin ID
  if(is.na(downstreamBasins)) {
    out <- data.frame('downstreamBasin'=NA,
                      'exported_ToNode'=NA,
                      'exported_Q_cms'=NA,
                      'exported_Area_km2'=NA,
                      'exported_percQEph_reach'=NA,
                      'exported_percAreaEph_reach'=NA,
                      'exported_perenniality'=NA)
    return(out)
  }
  
  indiana_hucs <- c('0508', '0509', '0514', '0512', '0712', '0404', '0405', '0410') #Indiana-effected basins
  
  out <- data.frame()
  for(downstreamBasin in downstreamBasins){
    #grab and prep downstream river network (to then grab the right routing ID)
    huc2 <- substr(downstreamBasin, 1, 2)
    dsnPath <- paste0(path_to_data, '/HUC2_', huc2, '/NHDPLUS_H_', downstreamBasin, '_HU4_GDB/NHDPLUS_H_', downstreamBasin, '_HU4_GDB.gdb')
    if(downstreamBasin %in% indiana_hucs) {
      nhd_d <- sf::st_read(paste0(path_to_data, '/HUC2_', huc2, '/indiana/indiana_fixed_', downstreamBasin, '.shp'))
      nhd_d <- sf::st_zm(nhd_d)
      colnames(nhd_d)[10] <- 'WBArea_Permanent_Identifier'
      nhd_d$NHDPlusID <- round(nhd_d$NHDPlusID, 0) #some of these have digits for some reason......
    }
    else{
      nhd_d <- sf::st_read(dsn=dsnPath, layer='NHDFlowline', quiet=TRUE)
      nhd_d <- sf::st_zm(nhd_d)
      nhd_d <- fixGeometries(nhd_d) #~src/utils.R
    }
    
    NHD_HR_VAA <- sf::st_read(dsn = dsnPath, layer = "NHDPlusFlowlineVAA", quiet=TRUE) #additional 'value-added' attributes
    NHD_HR_EROM <- sf::st_read(dsn = dsnPath, layer = "NHDPlusEROMMA", quiet=TRUE) #mean annual flow table
    
    nhd_d <- dplyr::left_join(nhd_d, NHD_HR_VAA)
    nhd_d <- dplyr::left_join(nhd_d, NHD_HR_EROM)
    
    nhd_d$StreamOrde <- nhd_d$StreamCalc #stream calc handles divergent streams correctly: https://pubs.usgs.gov/of/2019/1096/ofr20191096.pdf
    nhd_d$Q_cms <- nhd_d$QEMA * 0.0283 #cfs to cms
    nhd_d <- dplyr::filter(nhd_d, Q_cms > 0) #remove streams with no flow
    nhd_d <- dplyr::filter(nhd_d, StreamOrde > 0 & is.na(HydroSeq)==0 & FlowDir == 1)
    
    #filter for correct reach
    model_filt <- dplyr::filter(model, ToNode %in% nhd_d$FromNode)
    
    #handle the basins that flow into great lakes but aren't exports from a great lake, i.e. no topological connection to lake & thus NA export reach
    if(nrow(model_filt) == 0){
      out <- data.frame('downstreamBasin'=downstreamBasin,
                        'exported_ToNode'=NA,
                        'exported_Q_cms'=NA,
                        'exported_Area_km2'=NA,
                        'exported_percQEph_reach'=NA,
                        'exported_percAreaEph_reach'=NA,
                        'exported_perenniality'=NA)
    }
    
    else{
      exported_ToNode <- model_filt$ToNode
      exported_Q <- model_filt$Q_cms
      exported_Area <- model_filt$TotDASqKm
      exported_percQEph_reach <- model_filt$percQEph_reach
      exported_percAreaEph_reach <- model_filt$percAreaEph_reach
      exported_perenniality <- model_filt$perenniality
      
      temp <- data.frame('downstreamBasin'=downstreamBasin,
                         'exported_ToNode'=exported_ToNode,
                         'exported_Q_cms'=exported_Q,
                         'exported_Area_km2'=exported_Area,
                         'exported_percQEph_reach'=exported_percQEph_reach,
                         'exported_percAreaEph_reach'=exported_percAreaEph_reach,
                         'exported_perenniality'=exported_perenniality)
      out <- rbind(out, temp)
    }
  }
  
  return(out)
}