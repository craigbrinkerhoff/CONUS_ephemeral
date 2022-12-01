## Craig Brinkerhoff
## Fall 2022
## Functions to make experimental catchment verification/validation plots

#' Sets up df of ephemeral streams with in situ mean annual streamflow and our model's discharge estimates
#'
#' @name setupEphemeralQValidation
#' 
#' @note: these are the ephemeral streams we will have data for (Walnut Gulch and some temp USGS gages in WYoming/Colorado from the 70s)
#'
#' @param rivNetFin_1505: routing model result for basin
#' @param path_to_data: charater string to data repo
#'
#' @import sf
#' @import dataRetrieval
#' @import dplyr
#'
#' @return ephemeral streams mean annual flow paired with model reach and model discharge
setupEphemeralQValidation <- function(path_to_data, walnutGulch, other_sites, rivNetFin_1008, rivNetFin_1009, rivNetFin_1012, rivNetFin_1404){
  #Wyoming gages-----------------------------------------------------------
  other_sites$wy_eph_gages <- substr(other_sites$name, 6,nchar(other_sites$name))

  wy_eph_Q <- data.frame()
  for(i in other_sites$wy_eph_gages){
    gageQ <- readNWISstat(siteNumbers = i, #check if site mets our date requirements
                          parameterCd = '00060') #discharge
    
    #get mean annual flow
    gageQ <- gageQ %>% 
      dplyr::mutate(Q_cms = mean_va*0.0283) #cfs to cms
    
      Q_MA <- mean(gageQ$Q_cms, na.rm=T) #mean annual
    
    temp <- data.frame('gageID'=i, #take first row
                       'meas_runoff_m3_s'=Q_MA)
    
    wy_eph_Q <- rbind(wy_eph_Q, temp)
  }
  
  wy_eph_Q <- dplyr::left_join(wy_eph_Q, other_sites, by=c('gageID'='wy_eph_gages')) %>%
    sf::st_as_sf(coords=c('lon', 'lat'))
  
  sf::st_crs(wy_eph_Q) <- sf::st_crs('epsg:4269')
  
  #1008
  network1 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_10/NHDPLUS_H_1008_HU4_GDB/NHDPLUS_H_1008_HU4_GDB.gdb', layer='NHDFlowline')
  network2 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_10/NHDPLUS_H_1009_HU4_GDB/NHDPLUS_H_1009_HU4_GDB.gdb', layer='NHDFlowline')
  network3 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_10/NHDPLUS_H_1012_HU4_GDB/NHDPLUS_H_1012_HU4_GDB.gdb', layer='NHDFlowline')
  network4 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_14/NHDPLUS_H_1404_HU4_GDB/NHDPLUS_H_1404_HU4_GDB.gdb', layer='NHDFlowline')
  
  network <- rbind(network1, network2, network3, network4)
  network<- sf::st_zm(network)
  
  #project to correct UTM zones------------------------
  coords <- sf::st_coordinates(sf::st_centroid(network$Shape)) #get each line centroid
  utm_zone <- long2UTM(mean(coords[,1]))#get appropriate UTM zone using mean network longitude
  epsg <- as.numeric(paste0('326', as.character(utm_zone)))
  
  validationDF <- sf::st_transform(wy_eph_Q, epsg)
  network <- sf::st_transform(network, epsg)
  
  rivNetFin <- rbind(rivNetFin_1008, rivNetFin_1009, rivNetFin_1012, rivNetFin_1404)
  
  network <- dplyr::left_join(network, rivNetFin, 'NHDPlusID')
  network <- dplyr::filter(network, is.na(perenniality)==0)
  
  #snap to network----------------------------
  #grab everything within a kilometer of the field point
  wy_eph_Q <- sf::st_join(wy_eph_Q, network, join=st_is_within_distance, dist=2500) #search within 2.5 km of the point
  
  #keep the one with the best matching drainage area (must also be within 5% of drainage area agreement)
  wy_eph_Q <- dplyr::group_by(wy_eph_Q, gageID) %>%
    dplyr::mutate(error = abs(drainageArea_km2 - TotDASqKm)/TotDASqKm) %>%
    dplyr::filter(error < 0.20) %>%
    dplyr::slice_min(error, with_ties=FALSE, n=1) %>% #ties are pretty much never going to happen, but still need something...
    dplyr::select(c('NHDPlusID', 'meas_runoff_m3_s', 'drainageArea_km2', 'Q_cms', 'TotDASqKm', 'gageID')) %>%
    dplyr::mutate(basin = 'wyoming_eph_int')
    
  return(wy_eph_Q)
  #walnut gulch flumes (already done in figure)---------------------------
  walnutGulch$basin <- 'walnut_gulch'
  
  
  out <- rbind(walnutGulch, wy_eph_Q)
  
  return(out)
}





#' Verifies our routing model approximately matches gage-based analysis (not a true validation!!)
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
  # walnut_gulch_hydrography <- sf::st_read('/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/exp_catchments/walnut_gulch/streamlines.shp')
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
    dplyr::filter(abs((drainageArea_km2-TotDASqKm)/TotDASqKm) <= 0.20) #to ensure accuracy, drainage areas must be within 10% of one another
  
  #basin map----------------------------------
  map <- ggplot(network, aes(color=perenniality)) +
    # geom_sf(data=walnut_gulch_hydrography, #conus boundary
    #         color='darkred',
    #         show.legend='line')+
    geom_sf()+
    geom_sf(data=flume_sites[flume_sites$NHDPlusID %in% flume_sites2$NHDPlusID,],
            color='black',
            size=6)+
    scale_color_manual(name='',
                       values=c('#f18f01', '#006e90'),
                       labels=c('Model ephemeral', 'Model non-ephemeral')) +
    labs('A')+
    theme(axis.text = element_text(family="Futura-Medium", size=20),
          legend.position = c(0.8, 0.1),
          legend.text=element_text(size=20),
          plot.title = element_text(face = "italic", size = 26),
          plot.tag = element_text(size=26,
                                  face='bold'))+
    xlab('')+
    ylab('') +
    ggtitle('Walnut Gulch Experimental Ephemeral Catchment, AZ')
  
  #Q validation-----------------------------
  scatterPlot <- ggplot(flume_sites2, aes(x=meas_runoff_m3_s, y=Q_cms)) +
    geom_abline(linetype='dashed', color='darkgrey', size=2) +
    geom_point(size=8) +
    labs('B')+
    xlim(0,0.1)+
    ylim(0,0.1)+
    ylab('Model Streamflow [cms]')+
    xlab('Mean Annual Streamflow [cms]')+
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
  
  ggsave('cache/walnutGulch.jpg', comboPlot, width=12, height=12)
  
  return(list('see cache/walnutGulch.jpg',
              'df'=flume_sites2 %>% select(c('NHDPlusID', 'meas_runoff_m3_s', 'drainageArea_km2', 'Q_cms', 'TotDASqKm')),
              'percQEph_exported'=network[which.max(network$Q_cms),]$percQEph_reach))
}
