## Craig Brinkerhoff
## Functions to validate ephemeral classification, routing, and discharge
## Winter 2023



#' Prep and clean EPA WOTUS Jurisdictional Ditinction validation dataset
#'
#' We keep only features directly connected to the drainage network and throw out disconnected features (see below)
#' See the actual dataset for the descriptions of these codes
#' KEEP:
#'  A1: Traditionally navigable waters (i.e. perennial) (both rivers and lakes)
#'  A2: Perennnial/intermittent tributaries to traditionally navigable waters (both rivers and lakes)
#'  A3: Tributary lake/pond that contributes water to traditionally navigatable waters
#'  B3: ephemeral streams
#'  B4, B10: Stormwater control features (B4 == 'sheetflow')
#'  B5: Ditches
#'  B7: Artifically irrigated features
#'  B8: artifical lakes/ponds
#'  B3: Ephemeral features
#'  RHAB codes for A1-4 and B3: Features classified under the older (and stricter) River and Harbors Act. Includes some ephemeral sites.
#'
#' REMOVE
#'  All upland/dryland/isolated features with codes like UPLAND, DRYLAND, ISOLATE
#'  A4: wetlands that abut A1-A3 and/or are seasonally innundated by A1-A3
#'  B1: wetlands/lakes/ponds that aren't connected to network, i.e. 'non adjacent'
#'  B2, B11: Groundwater features
#'  B6: Converted croplands (from wetlands, so basically drainged wetlands)
#'  B9: upland water-filled depressions
#'  B12: Wastewater plants
#'  All other section 10 features removed
#'
#' @name prepValDF
#'
#' @note Be aware of the explicit repo structure within the data repo, i.e. even though the user specifies the path to the data repo, there are assumed internal folders.
#'
#' @param path_to_data: character string for path to data repo
#'
#' @import readr
#' @import dplyr
#'
#' @return df of prepared validation set
prepValDF <- function(path_to_data){
  `%notin%` <- Negate(`%in%`)

  #load in validation dataset
    #Queried "Clean Water Act Approved Jurisdictional Determinations" database on 06/20/2022 for all JDs requested by landowners.
    #filter for desiscions made under NWPR ruling (post 2020) because these are actually specifying ephemeral features as their own classes
  validationDF <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/jds202206201319.csv'))
  validationDF <- dplyr::filter(validationDF, `JD Basis` == 'NWPR')

  #Filter dataset to include features we care about (see function documentation for rational here)
  validationDF <- dplyr::filter(validationDF, substr(`Resource Types`, 1, 2) %in% c('A1', 'A2', 'A3', 'B3', 'B4', 'B5', 'B7', 'B8', 'B10') | substr(`Resource Types`, 1, 4) == 'RHAB') %>%
      select(`JD ID`, `Resource Types`, `Project ID`, Longitude, Latitude, `Water of the U.S.`, HUC8)

  colnames(validationDF) <- c('JD_ID', 'resource_type', 'project_id', 'long', 'lat', 'wotus_class', 'huc8')
  validationDF$huc4 <- substr(validationDF$huc8, 1, 4)

  #reclassify as epehemeral/not ephemeral.
  validationDF$distinction <- ifelse(substr(validationDF$resource_type, 1, 2) == 'B3' | substr(validationDF$resource_type, 1, 5) == 'RHAB3', 'ephemeral', 'non_ephemeral')

  return(validationDF)
}



#' Snaps EPA WOTUS Jurisdictional distinctions to HUC4 river networks:
#'    1) auto-finds the correct UTM zone to project data
#'    2) gets distance between NHD reach and tagged WOTUS distinction point
#'
#' Also grabs USGS gagues that fit 'non-ephemeral' status and appends adds them to the validation set
#'
#' @name snapValidateToNetwork
#'
#' @param path_to_data: path to data directory
#' @param validationDF: EPA/Corps WOTUS Jurisdictional distinction dataset (pre-cleaned and prepped)
#' @param USGS_data: USGS gauge IDs and 'no flow fractions'
#' @param nhdGages: loopup table linking USGS gages to nhd reach ids
#' @param nhd_df: model result river network (as data.frame)
#' @param huc4id: HUC4 id for current network
#' @param noFlowGageThresh: Threshold for % of year the gage runs dry that is allowable for rivers that are 'certainly non-ephemeral'
#'
#' @import sf
#' @import dplyr
#'
#' @return df with WOTUS validation points associated with NHD reaches (and their respective dicstance [m] from the reach)
snapValidateToNetwork <- function(path_to_data, validationDF, USGS_data, nhdGages, nhd_df, huc4id, noFlowGageThresh) {
  indiana_hucs <- c('0508', '0509', '0514', '0512', '0712', '0404', '0405', '0410') #indiana-effected basins

  #do by basin to speed up processing
  validationDF <- dplyr::filter(validationDF, huc4 %in% huc4id)

  #handle regions with no validation data
  if(nrow(validationDF) == 0){
    return(data.frame('NHDPlusID'=NA,
                      'dataset'=NA,
                      'snap_distance_m'=NA,
                      'network_utm_zone'=NA,
                      'JD_ID'=NA,
                      'resource_type'=NA,
                      'project_id'=NA,
                      "wotus_class"=NA,
                      "huc8"=NA,
                      "huc4"=NA,
                      "distinction"=NA,
                      "geometry"=NA,
                      "perenniality"=NA,
                      'StreamOrde'=NA))
  }

  validationDF <- sf::st_as_sf(validationDF,
                 coords = c("long", "lat"),
                 crs = 4269)

  #read in shapefiles, depending on indiana-effect or not
  huc2 <- substr(huc4id, 1, 2)
  dsnPath <- paste0(path_to_data, '/HUC2_', huc2, '/NHDPLUS_H_', huc4id, '_HU4_GDB/NHDPLUS_H_', huc4id, '_HU4_GDB.gdb')
  if(huc4id %in% indiana_hucs) {
    nhd <- sf::st_read(paste0(path_to_data, '/HUC2_', huc2, '/indiana/indiana_fixed_', huc4id, '.shp'))
    nhd <- sf::st_zm(nhd)
    colnames(nhd)[10] <- 'WBArea_Permanent_Identifier'
    colnames(nhd)[23] <- 'Shape'
    st_geometry(nhd)= 'Shape'
  }
  else{
    nhd <- sf::st_read(dsn=dsnPath, layer='NHDFlowline', quiet=TRUE)
    nhd <- sf::st_zm(nhd)
    nhd <- fixGeometries(nhd)
  }

  #set up stream order and Q for filtering nhd identical to model
  NHD_HR_EROM <- sf::st_read(dsn = dsnPath, layer = "NHDPlusEROMMA", quiet=TRUE) #mean annual flow table
  NHD_HR_VAA <- sf::st_read(dsn = dsnPath, layer = "NHDPlusFlowlineVAA", quiet=TRUE) #additional 'value-added' attributes
  nhd <- dplyr::left_join(nhd, NHD_HR_EROM, by='NHDPlusID')
  nhd <- dplyr::left_join(nhd, NHD_HR_VAA, by='NHDPlusID')
  nhd$StreamOrde <- nhd$StreamCalc #stream calc handles divergent streams correctly: https://pubs.usgs.gov/of/2019/1096/ofr20191096.pdf
  nhd$Q_cms <- nhd$QBMA * 0.0283 #cfs to cms
  if(huc4id %in% indiana_hucs){
    thresh <- c(2,2,2,2,3,2,3,2) #see README file
    thresh <- thresh[which(indiana_hucs == huc4id)]
    nhd$StreamOrde <- ifelse(nhd$indiana_fl == 1, nhd$StreamOrde - thresh, nhd$StreamOrde)
  }

  nhd <- dplyr::filter(nhd, StreamOrde > 0 & Q_cms > 0)

  #extract coords from river network
  coords <- sf::st_coordinates(sf::st_centroid(nhd$Shape)) #get each line centroid
  utm_zone <- long2UTM(mean(coords[,1]))#get appropriate UTM zone using mean network longitude

  #project to given UTM zone for distance calcs
  epsg <- as.numeric(paste0('326', as.character(utm_zone)))

  validationDF <- sf::st_transform(validationDF, epsg)
  nhd <- sf::st_transform(nhd, epsg)

  #snap each point to nearest river
  nearestIndex <- sf::st_nearest_feature(validationDF, nhd)

  #Get the actual snapping distance
  distance <- sf::st_distance(validationDF, nhd[nearestIndex,], by_element = TRUE)

  #build snapped validation set
  out <- data.frame('NHDPlusID'=nhd[nearestIndex,]$NHDPlusID,
                    'dataset'='EPA',
                    'snap_distance_m'=sf::st_distance(validationDF, nhd[nearestIndex,], by_element = TRUE),
                    'network_utm_zone'=utm_zone)
  out <- cbind(out, validationDF)

  #join model results with validation data
  out <- as.data.frame(out)
  nhd_df <- dplyr::select(nhd_df, c('NHDPlusID', 'perenniality', 'StreamOrde'))
  out <- dplyr::left_join(out, nhd_df, by='NHDPlusID')

  #join usgs gauges to flesh out training set
  USGS_data <- dplyr::left_join(USGS_data, nhdGages, by=c('gageID'='GageIDMA'))
  USGS_data <- dplyr::filter(USGS_data, no_flow_fraction < noFlowGageThresh & NHDPlusID %in% nhd_df$NHDPlusID) #if average year the river is flowing > 90% of the time, it's almost certainly non-ephemeral
  USGS_data <- dplyr::left_join(USGS_data, nhd_df, by='NHDPlusID')
  if(nrow(USGS_data) > 0){
    USGS_data$distinction <- 'non_ephemeral'
    USGS_out <- data.frame('NHDPlusID'=USGS_data$NHDPlusID,
                      'dataset'='USGS',
                      'snap_distance_m'=0,
                      'network_utm_zone'=NA,
                      'JD_ID'=NA,
                      'resource_type'='USGS_gage',
                      'project_id'=NA,
                      "wotus_class"=NA,
                      "huc8"=NA,
                      "huc4"=huc4id,
                      "distinction"=USGS_data$distinction,
                      "geometry"=NA,
                      "perenniality"=USGS_data$perenniality,
                      'StreamOrde'=USGS_data$StreamOrde)

    out <- rbind(out, USGS_out)
  }

  return(out)
}





#' Adds our field-assessed river classifications from the Northeast US to the validation data frame
#'
#' @name addOurFieldData
#'
#' @param rivNetFin_0106: 0106 river network, needed to pair field data in 0106 with model results
#' @param rivNetFin_0108: 0108 river network, needed to pair field data in 0108 with model results
#' @param path_to_data: path to data directory
#' @param field_dataset our field-assessed river ephemerality classifications in New England (summer 2022)
#'
#' @import dplyr
#'
#' @return updated combined_validation df
addOurFieldData <- function(rivNetFin_0106, rivNetFin_0108, path_to_data, field_dataset){
  #get model results
  df_0106 <- dplyr::filter(rivNetFin_0106, NHDPlusID %in% field_dataset$NHDPlusID)
  df_0106 <- dplyr::select(df_0106, c('NHDPlusID', 'perenniality', 'StreamOrde'))

  df_0108 <- dplyr::filter(rivNetFin_0108, NHDPlusID %in% field_dataset$NHDPlusID)
  df_0108 <- dplyr::select(df_0108, c('NHDPlusID', 'perenniality', 'StreamOrde'))

  field_dataset_0106 <- dplyr::left_join(df_0106, field_dataset)
  field_dataset_0108 <- dplyr::left_join(df_0108, field_dataset)

  field_dataset <- rbind(field_dataset_0106, field_dataset_0108)

  #update validation table
  field_dataset$method <- field_dataset$name
  field_dataset$dataset <- 'this_study'
  field_dataset$snap_distance_m <- 0 #dummy value to keep in dataset
  field_dataset$network_utm_zone <- NA
  field_dataset$JD_ID <- NA
  field_dataset$resource_type <- NA
  field_dataset$project_id <- NA
  field_dataset$wotus_class <- NA
  field_dataset$huc8 <- NA
  field_dataset$distinction <- field_dataset$classification
  field_dataset$geometry <- NA

  field_dataset <- dplyr::select(field_dataset, c('method', 'NHDPlusID', 'dataset', 'snap_distance_m', 'network_utm_zone', 'JD_ID', 'resource_type', 'project_id', 'wotus_class', 'huc8', 'huc4', 'distinction', 'geometry', 'perenniality', 'StreamOrde'))
  return(field_dataset)
}





#' Validates the ephemeral mapping model
#'
#' @name validateModel
#'
#' @param combined_validation: combo df of all validation tables for each HUC4
#' @param ourFieldData: prepped df of our field-mapped stream classifications in the Northeast US
#' @param snappingThresh: snapping threshold
#'
#' @import dplyr
#' @import tidyr
#'
#' @return df containing ephemeral mapping validation results
validateModel <- function(combined_validation, ourFieldData, snappingThresh){
  #join datasets
  combined_validation <- rbind(combined_validation, ourFieldData)

  #remove empty columns that arise from empty validation HUC regions
  verifyDF <- tidyr::drop_na(combined_validation, 'NHDPlusID')
  verifyDF$snap_distance_m <- as.numeric(verifyDF$snap_distance_m)

  #all ephemeral-classed rivers, regardless of NHD river presence
  totNHD_tot <- nrow(verifyDF[!duplicated(verifyDF$NHDPlusID) & verifyDF$distinction == 'ephemeral',])

  #filter for sites on the NHD (via some snapping threshold)
  verifyDF <- dplyr::filter(verifyDF, snap_distance_m < snappingThresh)

  #take most frequent JD per NHD reach
  verifyDFfin <- verifyDF %>%
    dplyr::group_by(NHDPlusID, distinction) %>%
    dplyr::mutate(num = n()) %>%
    dplyr::slice_max(num, with_ties=TRUE) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(NHDPlusID) %>%
    dplyr::mutate(dups = n()) %>%
    dplyr::filter(dups == 1)

  #EPA ephemeral-classed JDs on the NHD
  onNHD_tot <- nrow(verifyDFfin[verifyDFfin$distinction == 'ephemeral',])

  out <- list('validation_fin'=verifyDFfin,
              'eph_features_on_nhd_tot'=onNHD_tot,
              'eph_features_off_nhd_tot'=totNHD_tot - onNHD_tot,
              'all_validation_features'=nrow(verifyDFfin))

  return(out)
}






#' Calculates frequency that headwater reaches are classified ephemeral
#'
#' @name ephemeralFirstOrder
#'
#' @param nhd_df: routing model result for basin
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




#' Sets up df of ephemeral streams with in situ mean annual streamflow and our model's discharge estimates
#'
#' @name setupEphemeralQValidation
#' 
#' @note: these are the ephemeral streams we will have data for (Walnut Gulch and some temp USGS gages in WYoming/Colorado from the 70s)
#'
#' @param path_to_data: character string to data repo
#' @param walnutGulch: walnut gulch data frame for runoff data\
#' @param ephemeralUSGSDischarge: usgs ephemeral gauge list
#' @param rivNetFin_x: routing model result for basin x
#'
#' @import sf
#' @import dataRetrieval
#' @import dplyr
#'
#' @return ephemeral streams mean annual flow paired with model reach and model discharge
setupEphemeralQValidation <- function(path_to_data, walnutGulch, ephemeralUSGSDischarge, rivNetFin_1008, rivNetFin_1009, rivNetFin_1012, rivNetFin_1404, rivNetFin_1408, rivNetFin_1405, rivNetFin_1507, rivNetFin_1506,rivNetFin_1809, rivNetFin_1501,rivNetFin_1503,rivNetFin_1606,rivNetFin_1302,rivNetFin_1306,rivNetFin_1303,rivNetFin_1305){
  ephemeralUSGSDischarge <- sf::st_as_sf(ephemeralUSGSDischarge, coords=c('lon', 'lat'))
  
  sf::st_crs(ephemeralUSGSDischarge) <- sf::st_crs('epsg:4269')
  
  rivNetFin <- rbind(rivNetFin_1008, rivNetFin_1009, rivNetFin_1012, rivNetFin_1404, rivNetFin_1408, rivNetFin_1405, rivNetFin_1507, rivNetFin_1506,rivNetFin_1809, rivNetFin_1501,rivNetFin_1503,rivNetFin_1606,rivNetFin_1302,rivNetFin_1306,rivNetFin_1303,rivNetFin_1305)
  
  #join to networks iteratively to handle memory overloading...
  out <- data.frame()
  for (i in 1:nrow(ephemeralUSGSDischarge)){
    huc4 <- ephemeralUSGSDischarge[i,]$huc4
    huc2 <- substr(huc4, 1, 2)
    
    network <- sf::st_read(dsn = paste0(path_to_data, '/HUC2_', huc2, '/NHDPLUS_H_', huc4, '_HU4_GDB/NHDPLUS_H_', huc4, '_HU4_GDB.gdb'), layer='NHDFlowline')
    network<- sf::st_zm(network)
    
    coords <- sf::st_coordinates(sf::st_centroid(network$Shape)) #get each line centroid
    utm_zone <- long2UTM(mean(coords[,1]))#get appropriate UTM zone using mean network longitude
    epsg <- as.numeric(paste0('326', as.character(utm_zone)))
    
    validationDF <- sf::st_transform(ephemeralUSGSDischarge, epsg)
    network <- sf::st_transform(network, epsg)
    
    network <- dplyr::left_join(network, rivNetFin, 'NHDPlusID')
    network <- dplyr::filter(network, is.na(perenniality)==0)
    
    temp <- sf::st_join(ephemeralUSGSDischarge, network, join=st_is_within_distance, dist=2500) #search within 2.5 km of the point
    out <- rbind(out, temp)
  }
  
  #keep the one with the best matching drainage area (must also be within 5% of drainage area agreement)
  out <- dplyr::group_by(out, gageID) %>%
    dplyr::mutate(error = abs(drainageArea_km2 - TotDASqKm)/TotDASqKm) %>%
    dplyr::filter(error < 0.20) %>%
    dplyr::slice_min(error, with_ties=FALSE, n=1) %>% #ties are pretty much never going to happen, but still need something...
    dplyr::select(c('NHDPlusID', 'huc4', 'meas_runoff_m3_s', 'drainageArea_km2', 'Q_cms', 'num_flowing_dys','TotDASqKm', 'gageID', 'period_of_record_yrs'))
 
   return(out)
}




#' Verifies our model in the Walnut Gulch Experimental watershed
#'
#' @name walnutGulchQualitative
#'
#' @param rivNetFin_1505: routing model result for basin
#' @param path_to_data: charater string to data repo
#'
#' @import sf
#' @import ggplot2
#' @import patchwork
#' @import dplyr
#'
#' @return map of Wlanut gulch hydrography and discharge model (written to file)
walnutGulchQualitative <- function(rivNetFin_1505, path_to_data) {
  theme_set(theme_classic())
  
  #wrangling walnut gulch--------------------------
  walnutGulch <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/WalnutGulchData.csv'))
  walnutGulch <- tidyr::gather(walnutGulch, key=site, value=runoff_mm, c("Flume 1", "Flume 2", "Flume 3","Flume 4","Flume 6","Flume 7","Flume 11","Flume 15","Flume 103","Flume 104", "Flume 112", "Flume 121", "Flume 125"))
  walnutGulch$date <- paste0(walnutGulch$Year, '-', walnutGulch$Month, '-', walnutGulch$Day)
  walnutGulch$date <- lubridate::as_date(walnutGulch$date)
  walnutGulch <- walnutGulch %>%
    dplyr::mutate(year = lubridate::year(date)) %>%
    dplyr::group_by(site) %>% #get no flow stats per sub watershed
    dplyr::summarise(runoff_m_s = mean(runoff_mm, na.rm=T)*0.001/86400) %>% #m/s
    dplyr::mutate(site = substr(site, 7, nchar(site)))

  #setup flume locations----------------------------
  flume_sites <- read.csv('/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/exp_catchments/walnut_gulch/walnut_gulch_flumes.csv')
  flume_sites <- dplyr::filter(flume_sites, !is.na(drainageArea_km2)) %>%
    dplyr::mutate(flume = as.character(flume)) %>%
    dplyr::left_join(walnutGulch, by=c('flume'='site')) %>%
    sf::st_as_sf(coords=c('easting', 'northing')) %>%
    dplyr::mutate(meas_runoff_m3_s = runoff_m_s*drainageArea_km2*1e6) #m3/s
  
  sf::st_crs(flume_sites) <- sf::st_crs('epsg:26912')

  #set up hydrography------------------------------
  basin <- sf::st_read('/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/exp_catchments/walnut_gulch/boundary.shp')
  basin <- sf::st_transform(basin, 'epsg:26912')
  
  #map ephemeral classification----------------------
  network <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_15/NHDPLUS_H_1505_HU4_GDB/NHDPLUS_H_1505_HU4_GDB.gdb', layer='NHDFlowline')
  network<- sf::st_zm(network)
  network <- sf::st_transform(network, 'epsg:26912')
  network <- sf::st_intersection(network, basin)
  
  network <- dplyr::left_join(network, rivNetFin_1505, 'NHDPlusID')
  network <- dplyr::filter(network, is.na(perenniality)==0)
  
  #snap flume data to network----------------------------
  nearestIndex <- sf::st_nearest_feature(flume_sites, network)
  flume_sites$NHDPlusID <- network[nearestIndex,]$NHDPlusID
  flume_sites2 <- dplyr::left_join(as.data.frame(flume_sites), network, by='NHDPlusID') %>%
    dplyr::filter(abs((drainageArea_km2-TotDASqKm)/TotDASqKm) <= 0.20) #to ensure accuracy, drainage areas must be within 20% of one another
  
  #basin map----------------------------------
  map <- ggplot(network, aes(color=perenniality)) +
    geom_sf()+
    geom_sf(data=flume_sites[flume_sites$NHDPlusID %in% flume_sites2$NHDPlusID,],
            color='black',
            size=6)+
    scale_color_manual(name='',
                       values=c('#f18f01', '#006e90'),
                       labels=c('Model ephemeral', 'Model non-ephemeral')) +
    labs(tag='A')+
    theme(axis.text = element_text(family="Futura-Medium", size=20),
          legend.position = c(0.8, 0.1),
          legend.text=element_text(size=20),
          plot.title = element_text(face = "italic", size = 26),
          plot.tag = element_text(size=26,
                                  face='bold'))+
    xlab('')+
    ylab('') +
    ggtitle('Walnut Gulch Experimental Ephemeral Watershed, AZ')
  
  #Q validation-----------------------------
  scatterPlot <- ggplot(flume_sites2, aes(x=meas_runoff_m3_s, y=Q_cms)) +
    geom_abline(linetype='dashed', color='darkgrey', size=2) +
    geom_point(size=8) +
    labs(tag='B')+
    xlim(0,0.1)+
    ylim(0,0.1)+
    ylab(expr(bold('Model Streamflow ['~frac(m^3,s)~']')))+
    xlab(expr(bold('Mean Annual Streamflow ['~frac(m^3,s)~']')))+
    #ylab('Model Streamflow [cms]')+
    #xlab('Mean Annual Streamflow [cms]')+
    theme(axis.title = element_text(size=20, face='bold'),
          axis.text = element_text(size=18,face='bold'),
          legend.position='none',
          plot.tag = element_text(size=26,
                                  face='bold'))
  
  
  design <- "
    AA
    AA
    AA
    BB
  "
  
  comboPlot <- patchwork::wrap_plots(A=map, B=scatterPlot, design=design)
  
  ggsave('cache/walnutGulch.jpg', comboPlot, width=13, height=12)
  
  out <- list('see cache/walnutGulch.jpg',
              'df'=flume_sites2 %>% select(c('NHDPlusID', 'meas_runoff_m3_s', 'drainageArea_km2', 'Q_cms', 'TotDASqKm')),
              'percQEph_exported'=network[which.max(network$Q_cms),]$percQEph_reach)

  return(out)
}





#' Verifies our routing model can be anticipated by network length and the ephemeral map. Ignores basins wirh foreign streams out of necessity
#'
#' @name tokunaga_eph
#'
#' @param nhd_df: routing model result for basin
#' @param results: model results for huc4 basin
#' @param huc4: huc4 basin id
#'
#' @import dplyr
#'
#' @return df containing routing vs network length analysis
tokunaga_eph <- function(nhd_df, results, huc4){
  #prep results for joining to df
  results <- data.frame('StreamOrde'=max(nhd_df$StreamOrde),
                        'percQEph_exported' = results[1,]$percQEph_exported)

  #calc df for tokunaga
  out <- nhd_df %>%
    dplyr::group_by(StreamOrde) %>%
    dplyr::summarise(length_eph = sum(LengthKM*(perenniality == 'ephemeral')),
                     length = sum(LengthKM))%>%
    dplyr::mutate(length_up_eph = cumsum(length_eph),
                  length_up = cumsum(length)) %>%
    dplyr::mutate(Tk_eph = NA,
                  Tk_all = NA) %>%
    dplyr::mutate(r2 = summary(lm(log(length)~StreamOrde, data=.))$r.squared)
  
  for(i in 2:nrow(out)){
    out[i,]$Tk_eph <- out[i-1,]$length_up_eph / out[i,]$length
    out[i,]$Tk_all <- out[i-1,]$length_up / out[i,]$length
  }

  out <- out %>%
    dplyr::mutate(percEphemeralStreamInfluence_mean = Tk_eph / Tk_all) %>%
    dplyr::left_join(results, by='StreamOrde') %>%
    dplyr::slice_max(StreamOrde) %>% #minimum value is the exported one from the max stream orde
    dplyr::mutate(export = ifelse((huc4 %in% c('0418', '0419', '0424', '0426', '0428')) |  #remove scenarios that won't work with this scaling: 1) great lakes, 2) > 10% foreign basins, 3) net losing basins
                                    any(nhd_df$perenniality == 'foreign'), NA, percEphemeralStreamInfluence_mean),
                 huc4 = huc4) %>%
    dplyr::select(c('huc4', 'percQEph_exported', 'export'))

  return(out)
}