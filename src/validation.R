##########################
## Craig Brinkerhoff
## Functions to validation ephemeral WOTUS model against EPA/Corps in situ WOTUS classifications
## Summer 2022
##########################

#' Prep and clean EPA WOTUS Jurisdictional Ditinction validation dataset
#'
#' @param NULL
#'
#' @import readr
#'
#' @return prepared validation set (as dataframe)
prepValDF <- function(){
  `%notin%` <- Negate(`%in%`)

  #load in validation dataset
    #Queried "Clean Water Act Approved Jurisdictional Determinations" database on 6/15/2022 for all JDs post Navigatable Waters Protection Rule
    #n= 62,955
  validationDF <- read_csv('/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/for_ephemeral_project/jds202206151449.csv')

  #clean up this mess of a dataset...
  #A1: Traditionally navigable waters (i.e. perennial)
  #A2: Perennnial/intermittent tributaries to traditionally navigable waters
  #B3: Ephemeral features
  # All upland/dryland data removed
  # All wetlands removed
  # All wastewater plants removed
  # All storm runoff / tile drainage removed
  # All Section 10 features removed (special classes involving coastal features)
  validationDF <- filter(validationDF, substr(`Resource Types`, 1, 2) %in% c('A1', 'A2', 'A3', 'B3')) %>% #because our model exists only in a paradigm of ephemeral -> intermttent -> perennial, we only keep these categories (for both river and lakes. NOT wetlands)
      select(`JD ID`, `Resource Types`, `Project ID`, Longitude, Latitude, `Water of the U.S.`, HUC8)

  colnames(validationDF) <- c('JD_ID', 'resource_type', 'project_id', 'long', 'lat', 'wotus_class', 'huc8')
  validationDF$huc4 <- substr(validationDF$huc8, 1, 4)

  #assign ephemeral/not ephemeral. 'Ephemeral' is all waters classed as ephemeral streams, disconnected lakes/wetlands, and ditches (as the later two meet our broader defintion of ephemeralality)
  validationDF$distinction <- ifelse(substr(validationDF$resource_type, 1, 2) == 'B3', 'ephemeral', 'perennial') #note that perennial here is actually perennial/intermittent

  return(validationDF)
}

#' Snaps EPA WOTUS Jurisdictional distinctions to HUC4 river networks: 1) auto-finds the correct UTM zone to project data and 2) gets distance between NHD reach and tagged WOTUS distinction point
#' Also also grabs USGS data and appends adds it to the validation set
#'
#' @param path_to_data: path to data directory
#' @param validationDF: EPA/Corps WOTUS Jurisdictional distinction dataset (pre-cleaned and prepped)
#' @param rivNetFin: model result river network (as data.frame)
#' @param USGS_data: USGS gauge IDs and 'no flow fractions'
#' @param nhdGages: loopup table linking USGS gages to nhd reach ids
#' @param huc4id: HUC4 id for current network
#'
#' @import sf
#' '@import dplyr
#'
#' @return sf object with WOTUS validation points associated with NHD reaches (and their respective dicstance [m] from the reach)
snapValidateToNetwork <- function(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4id) {
  #do by basin to speed up processing
  validationDF <- dplyr::filter(validationDF, huc4 %in% huc4id)

  #handle regions with no validation data
  if(nrow(validationDF) == 0){
    return(data.frame('NHDPlusID'=NA,
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

  #read in shapefiles
  huc2 <- substr(huc4id, 1, 2)
  dsnPath <- paste0(path_to_data, '/HUC2_', huc2, '/NHDPLUS_H_', huc4id, '_HU4_GDB/NHDPLUS_H_', huc4id, '_HU4_GDB.gdb')
  nhd <- sf::st_read(dsn=dsnPath, layer='NHDFlowline', quiet=TRUE)
  nhd <- sf::st_zm(nhd)

  #extract coords from river network
  coords <- sf::st_coordinates(sf::st_centroid(nhd$Shape)) #get each line centroid
  utm_zone <- long2UTM(mean(coords[,1]))#get approproate UTM zone using mean network longitude

  #project to given UTM zone for distance calcs
  epsg <- as.numeric(paste0('326', as.character(utm_zone)))

  validationDF <- sf::st_transform(validationDF, epsg)
  nhd <- sf::st_transform(nhd, epsg)

  #get nearest river to each point
  nearestIndex <- sf::st_nearest_feature(validationDF, nhd)

  #remove those beyond the max snapping distance
  distance <- sf::st_distance(validationDF, nhd[nearestIndex,], by_element = TRUE)

  #build snapped validation set
  out <- data.frame('NHDPlusID'=nhd[nearestIndex,]$NHDPlusID,
                    'snap_distance_m'=sf::st_distance(validationDF, nhd[nearestIndex,], by_element = TRUE),
                    'network_utm_zone'=utm_zone)
  out <- cbind(out, validationDF)

  #join model results with validation data
  out <- as.data.frame(out)
  rivNetFin <- select(rivNetFin, c('NHDPlusID', 'perenniality', 'StreamOrde'))
  out <- left_join(out, rivNetFin, by='NHDPlusID')

  #join usgs gauges to flesh out training set
  USGS_data <- left_join(USGS_data, nhdGages, by=c('gageID'='GageIDMA'))
  USGS_data <- filter(USGS_data, no_flow_fraction < 0.05 & NHDPlusID %in% rivNetFin$NHDPlusID) #if average year the river is flowing > 50% of the time, it's almost certainly non-ephemeral
  USGS_data <- left_join(USGS_data, rivNetFin, by='NHDPlusID')
  if(nrow(USGS_data) > 0){
    USGS_data$distinction <- 'perennial'
    USGS_out <- data.frame('NHDPlusID'=USGS_data$NHDPlusID,
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
                      'StreamOrde'=NA) #not actually, but doesn't matter for these because they're not ephemeral)

    out <- rbind(out, USGS_out)
  }

  return(out)
}

#' Creates confusion matrix for model valdation
#'
#' @param verifyDF: combo df of all verification tables for each HUC4
#'
#' @return confusion matrix. Figure saved to file
validateModel <- function(combined_validation){
  verifyDF <- tidyr::drop_na(combined_validation, 'NHDPlusID') #remove empty columns that arise from empty validation HUC regions
  verifyDF$snap_distance_m <- as.numeric(verifyDF$snap_distance_m)

  totNHD <- nrow(verifyDF[!duplicated(verifyDF$NHDPlusID) & verifyDF$distinction == 'ephemeral',])
  verifyDF <- dplyr::filter(verifyDF, snap_distance_m < 15) #15m snapping buffer

  #take most frequent JD per NHD reach
  verifyDFfin <- verifyDF %>%
        group_by(NHDPlusID) %>%
        count(distinction) %>% #most frequent EPA JD per reach is assigned, after removing ones beyond the snap distance
        slice(which.max(n))

  #add model results back
  verifyDF <- select(verifyDF, c('NHDPlusID', 'perenniality', 'huc4', 'StreamOrde'))
  verifyDF <- verifyDF[!duplicated(verifyDF$NHDPlusID),]#drop columns for multiple JDs on same reach (model result is duplicated so it's fine)
  verifyDFfin <- left_join(verifyDFfin, verifyDF, by='NHDPlusID') #join model results to finished product

  onNHD <- nrow(verifyDFfin[verifyDFfin$distinction == 'ephemeral',]) #EPA JDs on the High res NHD

  theme_set(theme_classic())

  #confusion matrix
  cm <- as.data.frame(caret::confusionMatrix(factor(verifyDFfin$perenniality), factor(verifyDFfin$distinction))$table)
  cm$Prediction <- factor(cm$Prediction, levels=rev(levels(cm$Prediction)))
  cfMatrix <- ggplot(cm, aes(Reference, Prediction,fill=factor(Freq))) +
    geom_tile() +
    geom_text(aes(label=Freq), size=15)+
    scale_fill_manual(values=c('#d95f02', '#d95f02', '#1b9e77', '#1b9e77')) +
    labs(x = "Observed Class",y = "Model Class") +
    scale_x_discrete(labels=c("Ephemeral","Intermittent/Perennial")) +
    scale_y_discrete(labels=c("Intermittent\n/Perennial","Ephemeral")) +
    theme(legend.position = "none",
          axis.text=element_text(size=24),
          axis.title=element_text(size=28,face="bold"),
          legend.text = element_text(size=17),
          legend.title = element_text(size=17, face='bold'))

  #write to file
  ggsave('cache/verify_cf.jpg', cfMatrix, width=10, height=8)
  write_csv(verifyDFfin, 'cache/validationResults.csv')

  return(list('validation_fin'=verifyDFfin,
              'eph_features_on_nhd'=onNHD,
              'eph_features_off_nhd'=totNHD - onNHD))
}
