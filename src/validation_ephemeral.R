## Craig Brinkerhoff
## Functions to validate ephemeral classification, routing, and discharge
## Spring 2024



#' Prep and clean EPA WOTUS Jurisdictional Distinction dataset
#'
#' We keep only features directly connected to the drainage network and throw out disconnected features (see below). See the actual dataset for the descriptions of these codes
#' KEEP:
#'  A1: Traditionally navigable waters (both rivers and lakes)
#'  A2: Perennial/intermittent tributaries to traditionally navigable waters (both rivers and lakes)
#'  A3: Tributary lake/pond that contributes water to traditionally navigable waters
#'  B3: Ephemeral streams
#'  B4, B10: Stormwater control features (B4 == 'sheetflow')
#'  B5: Ditches
#'  B7: Artificially irrigated features
#'  B8: Artificial lakes/ponds
#'  RHAB codes for A1-4 and B3: Features classified under the older (and stricter) River and Harbors Act. Includes some ephemeral sites.
#'
#' REMOVE
#'  All upland/dryland/isolated features with codes like UPLAND, DRYLAND, ISOLATE
#'  A4: wetlands that abut A1-A3 and/or are seasonally inundated by A1-A3
#'  B1: wetlands/lakes/ponds that aren't connected to network, i.e. 'non adjacent'
#'  B2, B11: Groundwater features
#'  B6: Converted croplands (from wetlands, so basically drained wetlands)
#'  B9: upland water-filled depressions
#'  B12: Wastewater plants
#'  All other section 10 features removed
#'
#' @name prepValDF
#'
#' @param path_to_data: data repo directory path
#'
#' @import readr
#' @import dplyr
#'
#' @return df of prepared validation set
prepValDF <- function(path_to_data){
  `%notin%` <- Negate(`%in%`)

  #load in validation dataset: we queried the "Clean Water Act Approved Jurisdictional Determinations" database on 06/20/2022 for all JDs requested by landowners.
    #filter for desicions made under the NWPR (post 2020) because these ones explicitly distinguish ephemeral features as their own class
  validationDF <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/jds202206201319.csv'))
  validationDF <- dplyr::filter(validationDF, `JD Basis` == 'NWPR')

  #Filter dataset to include features directly connected to drainage network (see function documentation above)
  validationDF <- dplyr::filter(validationDF, substr(`Resource Types`, 1, 2) %in% c('A1', 'A2', 'A3', 'B3', 'B4', 'B5', 'B7', 'B8', 'B10') | substr(`Resource Types`, 1, 4) == 'RHAB') %>%
      dplyr::select(`JD ID`, `Resource Types`, `Project ID`, Longitude, Latitude, `Water of the U.S.`, HUC8)

  #manually set column names
  colnames(validationDF) <- c('JD_ID', 'resource_type', 'project_id', 'long', 'lat', 'wotus_class', 'huc8')
  validationDF$huc4 <- substr(validationDF$huc8, 1, 4)

  #recast as ephemeral/not ephemeral based on the above codes
  validationDF$distinction <- ifelse(substr(validationDF$resource_type, 1, 2) == 'B3' | substr(validationDF$resource_type, 1, 5) == 'RHAB3', 'ephemeral', 'non_ephemeral')

  return(validationDF)
}






#' Joins EPA WOTUS Jurisdictional distinctions to NHD-HR hydrography:
#'    1) Auto-finds the correct UTM zone to project data
#'    2) Gets distance between EPA in situ ephemeral classification and nearest NHD-HR reach
#'    3) Also grabs USGS gauges that fit 'non-ephemeral' status and adds them to the validation set
#'
#' @name snapValidateToNetwork
#'
#' @param path_to_data: data repo directory path
#' @param validationDF: WOTUS Jurisdictional determinations dataset (already cleaned and prepped)
#' @param USGS_data: USGS gauge IDs and 'no flow fractions'
#' @param nhdGages: lookup table linking USGS gauges to NHD-HR reach ids
#' @param nhd_df: basin routing table + results
#' @param huc4id: HUC4 id for current basin
#' @param noFlowGageThresh: Threshold for 'certainly non-ephemeral', i.e. % of year that streamgauges can run dry while almost certainly not being ephemeral
#'
#' @import sf
#' @import dplyr
#'
#' @return df with WOTUS validation points associated with NHD reaches (and their respective distance [m] from the reach)
snapValidateToNetwork <- function(path_to_data, validationDF, USGS_data, nhdGages, nhd_df, huc4id, noFlowGageThresh) {
  indiana_hucs <- c('0508', '0509', '0514', '0512', '0712', '0404', '0405', '0410') #Indiana-effected basins

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

  #make shapefile from reported lat/lons
  validationDF <- sf::st_as_sf(validationDF,
                                coords = c("long", "lat"),
                                crs = 4269)

  #read in shapefiles, depending on Indiana-effect or not
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
    nhd <- fixGeometries(nhd) #~src/utils.R
  }

  #set up stream order and Q for filtering that are identical to actual model (see ~/src/analysis.R)
  NHD_HR_EROM <- sf::st_read(dsn = dsnPath, layer = "NHDPlusEROMMA", quiet=TRUE) #mean annual flow table
  NHD_HR_VAA <- sf::st_read(dsn = dsnPath, layer = "NHDPlusFlowlineVAA", quiet=TRUE) #additional 'value-added' attributes
  nhd <- dplyr::left_join(nhd, NHD_HR_EROM, by='NHDPlusID')
  nhd <- dplyr::left_join(nhd, NHD_HR_VAA, by='NHDPlusID')
  nhd$StreamOrde <- nhd$StreamCalc #stream calc handles divergent streams 'correctly': https://pubs.usgs.gov/of/2019/1096/ofr20191096.pdf
  nhd$Q_cms <- nhd$QBMA * 0.0283 #cfs to cms
  if(huc4id %in% indiana_hucs){
    thresh <- c(2,2,2,2,3,2,3,2) #see README file
    thresh <- thresh[which(indiana_hucs == huc4id)]
    nhd$StreamOrde <- ifelse(nhd$indiana_fl == 1, nhd$StreamOrde - thresh, nhd$StreamOrde)
  }

  nhd <- dplyr::filter(nhd, StreamOrde > 0 & Q_cms > 0)

  #extract coords from river network
  coords <- sf::st_coordinates(sf::st_centroid(nhd$Shape)) #get each line centroid
  utm_zone <- long2UTM(mean(coords[,1]))#get appropriate UTM zone using mean longitude of river network (~/src/utils.R)

  #project to given UTM zone for distance calcs
  epsg <- as.numeric(paste0('326', as.character(utm_zone)))
  validationDF <- sf::st_transform(validationDF, epsg)
  nhd <- sf::st_transform(nhd, epsg)

  #snap each jurisdictional determination to nearest river (NHD-HR reach)
  nearestIndex <- sf::st_nearest_feature(validationDF, nhd)

  #Get the actual distance between point (x in func) and nearest NHD-HR reach (y in func)
  distance <- sf::st_distance(validationDF, nhd[nearestIndex,], by_element = TRUE)

  #build snapped validation set, containing the NHD-HR reach that is closet to the jurisdictional determination
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
  USGS_data <- dplyr::filter(USGS_data, no_flow_fraction < noFlowGageThresh & NHDPlusID %in% nhd_df$NHDPlusID) #if average year the river is flowing > x% of the time, it's almost certainly non-ephemeral
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





#' Join the in situ river classifications from the Northeast US to NHD-HR hydrography
#'
#' @name addOurFieldData
#'
#' @param rivNetFin_0106: 0106 river network, needed to pair in situ data in 0106 with model results (basins are identified a priori)
#' @param rivNetFin_0108: 0108 river network, needed to pair in situ data in 0108 with model results (basins are identified a priori)
#' @param path_to_data: data repo directory path
#' @param field_dataset our in situ river ephemerality classifications in New England (summer 2022)
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







#' Validate the ephemeral mapping model using all three validation datasets
#'
#' @name validateModel
#'
#' @param combined_validation: combo df of all validation tables for all HUC4 basins
#' @param ourFieldData: prepped df of our in situ stream classifications in the Northeast US
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

  #all ephemeral streams, regardless of NHD flowline presence
  totNHD_tot <- nrow(verifyDF[!duplicated(verifyDF$NHDPlusID) & verifyDF$distinction == 'ephemeral',])

  #filter for sites on the NHD (via some snapping threshold defined a priori)
  verifyDF <- dplyr::filter(verifyDF, snap_distance_m < snappingThresh)

  #take most frequent perenniality classification along the NHD flowline reach (if its a tie, throw it out as lacking a consensus)
  verifyDFfin <- verifyDF %>%
    dplyr::group_by(NHDPlusID, distinction) %>% #handle ties
    dplyr::mutate(num = n()) %>%
    dplyr::slice_max(num, with_ties=TRUE) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(NHDPlusID) %>% #remove those reaches lacking a consensus (i.e. theres a tie and thus number duplictaes > 1)
    dplyr::mutate(dups = n()) %>%
    dplyr::filter(dups == 1)

  #number of in situ pereniality classifications on the NHD-HR (given snapping threshold)
  onNHD_tot <- nrow(verifyDFfin[verifyDFfin$distinction == 'ephemeral',])

  out <- list('validation_fin'=verifyDFfin,
              'eph_features_on_nhd_tot'=onNHD_tot,
              'eph_features_off_nhd_tot'=totNHD_tot - onNHD_tot,
              'all_validation_features'=nrow(verifyDFfin))

  return(out)
}







#' Sets up ephemeral Q validation df by bringing together all sources of ephemeral discharge data used in this study. When necessary, snaps ephemeral sites to NHD-HR following the approach used for jurisdictional determinations
#'
#' @name setupEphemeralQValidation
#'
#' @param path_to_data: data repo directory path
#' @param walnutGulch: df of walnut gulch runoff data
#' @param ephemeralUSGSDischarge: USGS ephemeral gauge list
#' @param rivNetFin_1008: routing model result for basin 1008
#' @param rivNetFin_1009: routing model result for basin 1009
#' @param rivNetFin_1012: routing model result for basin 1012
#' @param rivNetFin_1404: routing model result for basin 1404
#' @param rivNetFin_1408: routing model result for basin 1408
#' @param rivNetFin_1405: routing model result for basin 1405
#' @param rivNetFin_1507: routing model result for basin 1507
#' @param rivNetFin_1506: routing model result for basin 1506
#' @param rivNetFin_1809: routing model result for basin 1809
#' @param rivNetFin_1501: routing model result for basin 1501
#' @param rivNetFin_1503: routing model result for basin 1503
#' @param rivNetFin_1606: routing model result for basin 1606
#' @param rivNetFin_1302: routing model result for basin 1302
#' @param rivNetFin_1306: routing model result for basin 1306
#' @param rivNetFin_1303: routing model result for basin 1303
#' @param rivNetFin_1305: routing model result for basin 1305
#'
#' @import sf
#' @import dataRetrieval
#' @import dplyr
#'
#' @return df with ephemeral streams' in situ mean annual flow paired with model reach and model discharge
setupEphemeralQValidation <- function(path_to_data, walnutGulch, ephemeralUSGSDischarge, rivNetFin_1008, rivNetFin_1009, rivNetFin_1012, rivNetFin_1404, rivNetFin_1408, rivNetFin_1405, rivNetFin_1507, rivNetFin_1506,rivNetFin_1809, rivNetFin_1501,rivNetFin_1503,rivNetFin_1606,rivNetFin_1302,rivNetFin_1306,rivNetFin_1303,rivNetFin_1305){
  #make shapefile of USGS ephemeral streamflow measurement locations
  ephemeralUSGSDischarge <- sf::st_as_sf(ephemeralUSGSDischarge, coords=c('lon', 'lat'))
  
  sf::st_crs(ephemeralUSGSDischarge) <- sf::st_crs('epsg:4269')
  
  #build network of rivers in the basins with in situ validation data
  rivNetFin <- rbind(rivNetFin_1008, rivNetFin_1009, rivNetFin_1012, rivNetFin_1404, rivNetFin_1408, rivNetFin_1405, rivNetFin_1507, rivNetFin_1506,rivNetFin_1809, rivNetFin_1501,rivNetFin_1503,rivNetFin_1606,rivNetFin_1302,rivNetFin_1306,rivNetFin_1303,rivNetFin_1305)
  
  #join to networks iteratively to handle memory overloading...
  out <- data.frame()
  for (i in 1:nrow(ephemeralUSGSDischarge)){
    huc4 <- ephemeralUSGSDischarge[i,]$huc4
    huc2 <- substr(huc4, 1, 2)
    
    network <- sf::st_read(dsn = paste0(path_to_data, '/HUC2_', huc2, '/NHDPLUS_H_', huc4, '_HU4_GDB/NHDPLUS_H_', huc4, '_HU4_GDB.gdb'), layer='NHDFlowline')
    network<- sf::st_zm(network)
    
    coords <- sf::st_coordinates(sf::st_centroid(network$Shape)) #get each line centroid
    utm_zone <- long2UTM(mean(coords[,1]))#get appropriate UTM zone using mean network longitude (~src/utils.R)
    epsg <- as.numeric(paste0('326', as.character(utm_zone))) #get pepsg projection code
    
    #reproject to correct UTM zone
    validationDF <- sf::st_transform(ephemeralUSGSDischarge, epsg)
    network <- sf::st_transform(network, epsg)
    
    ##join to NHD-HR
    network <- dplyr::left_join(network, rivNetFin, 'NHDPlusID')
    network <- dplyr::filter(network, is.na(perenniality)==0)
    
    temp <- sf::st_join(ephemeralUSGSDischarge, network, join=st_is_within_distance, dist=2500) #search within 2.5 km of the point (just an upper limit for pragmaticism, these sites are ovbiously closer to NHD-HR reaches than 2.5 km)
    out <- rbind(out, temp)
  }
  
  #QAQC that the matched in situ data and guages are actually in the right place
    #keep the pair with the best matching drainage area between model and reported in situ drainage area (must also be within 20% of drainage area agreement regardless)
  out <- dplyr::group_by(out, gageID) %>%
    dplyr::mutate(error = abs(drainageArea_km2 - TotDASqKm)/TotDASqKm) %>%
    dplyr::filter(error < 0.20) %>% #matches Walnut Gulch QAQC procedure (see SI FIgure captions)
    dplyr::slice_min(error, with_ties=FALSE, n=1) %>% #ties are pretty much never going to happen, but still need something so it takes the first option
    dplyr::select(c('NHDPlusID', 'huc4', 'meas_runoff_m3_s', 'drainageArea_km2', 'Q_cms', 'num_flowing_dys','TotDASqKm', 'gageID', 'period_of_record_yrs'))
 
   return(out)
}







#' Verifies our routing model can be anticipated by network theory (Tokunaga ratios) (doesn't do basins with foreign streams out of necessity)
#'
#' @name tokunaga_eph
#'
#' @param nhd_df: basin routing table + results
#' @param results: model results for huc4 basin
#' @param huc4: huc4 basin id
#'
#' @import dplyr
#'
#' @return df containing 1) model results and 2) tokunaga scaling results
tokunaga_eph <- function(nhd_df, results, huc4){
  #prep results for joining to df
  results <- data.frame('StreamOrde'=max(nhd_df$StreamOrde),
                        'percQEph_exported' = results[1,]$percQEph_exported)

  #calculate tokunaga ratios using length instead of number
  out <- nhd_df %>%
    dplyr::group_by(StreamOrde) %>%
    dplyr::summarise(length_eph = sum(LengthKM*(perenniality == 'ephemeral')), #sum of ephemeral network length by order
                     length = sum(LengthKM))%>% #sum of total network length by order
    dplyr::mutate(length_up_eph = cumsum(length_eph), #cumulative network length of all ephemerals stream orders smaller than present order
                  length_up = cumsum(length)) %>% #cumulative network length of all stream orders smaller than present order
    dplyr::mutate(Tk_eph = NA, #tokunaga ratios intialize
                  Tk_all = NA) %>%
    dplyr::mutate(r2 = summary(lm(log(length)~StreamOrde, data=.))$r.squared) #strength of fit for network length vs. stream order
  
  #calculate Tokunaga ratio (Tk), iterting by stream order. Tk = the avg. number of reaches that flow into the average reach per stream order see: 10.1029/2012JF002392 and 10.1111/j.1752-1688.2007.00005.x
  #here we use netowkr length rather than number of reaches because of the short artifical paths that maintain lake/reservoir connectivity to the network. See manuscript.
  for(i in 2:nrow(out)){
    out[i,]$Tk_eph <- out[i-1,]$length_up_eph / out[i,]$length #using orders i-1 / order i --> see: 10.1029/2012JF002392
    out[i,]$Tk_all <- out[i-1,]$length_up / out[i,]$length #using orders i-1 / order i --> see: 10.1029/2012JF002392
  }

  #join model results and prep output
  out <- out %>%
    dplyr::mutate(percEphemeralStreamInfluence_mean = Tk_eph / Tk_all) %>% #to get the "percent ephemeral contribution", we compare the cumulative upstream ephemeral number (Tk_eph) to the cumulative upstream whole-network value (TK_all). This is akin to eq S1.
    dplyr::left_join(results, by='StreamOrde') %>%
    dplyr::slice_max(StreamOrde) %>% #"basin-exported value" would be the max stream order (see manuscript)
    dplyr::mutate(export = ifelse((huc4 %in% c('0418', '0419', '0424', '0426', '0428')) |  #remove scenarios that won't work with this scaling: great lakes and foreign basins
                                    any(nhd_df$perenniality == 'foreign'), NA, percEphemeralStreamInfluence_mean),
                 huc4 = huc4) %>%
    dplyr::select(c('huc4', 'percQEph_exported', 'export'))

  return(out)
}