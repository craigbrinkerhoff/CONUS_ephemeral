# addTempPrecip <- function(rivNetFin, huc4){
#   huc2 <- substr(huc4, 1, 2)
#   
#   dsnPath <- paste0(path_to_data, '/HUC2_', huc2, '/NHDPLUS_H_', huc4, '_HU4_GDB/NHDPLUS_H_', huc4, '_HU4_GDB.gdb')
#   
#   #get mean annual T (direct column indexing because of typos in USGS tables...)-------------------------------
#   NHD_HR_temp_01 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrTempMM01", quiet=TRUE) #additional 'value-added' attributes
#   temp <- data.frame('NHDPlusID'=NHD_HR_temp_01[,1],
#                      'temp_c_01' = NHD_HR_temp_01[,3] / 100)
#   
#   NHD_HR_temp_02 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrTempMM02", quiet=TRUE) #additional 'value-added' attributes
#   if(nrow(NHD_HR_temp_02) > 0){
#     NHD_HR_temp <- NHD_HR_temp_02[,3]
#     temp$temp_c_02 <- NHD_HR_temp / 100
#   }
#   
#   NHD_HR_temp_03 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrTempMM03", quiet=TRUE) #additional 'value-added' attributes
#   if(nrow(NHD_HR_temp_03) > 0){
#     NHD_HR_temp <- NHD_HR_temp_03[,3]
#     temp$temp_c_03 <- NHD_HR_temp / 100
#   }
#   
#   NHD_HR_temp_04 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrTempMM04", quiet=TRUE) #additional 'value-added' attributes
#   if(nrow(NHD_HR_temp_04) > 4){
#     NHD_HR_temp <- NHD_HR_temp_04[,3]
#     temp$temp_c_04 <- NHD_HR_temp / 100
#   }
#   
#   NHD_HR_temp_05 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrTempMM05", quiet=TRUE) #additional 'value-added' attributes
#   if(nrow(NHD_HR_temp_05) > 0){
#     NHD_HR_temp <- NHD_HR_temp_05[,3]
#     temp$temp_c_05 <- NHD_HR_temp / 100
#   }
#   
#   NHD_HR_temp_06 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrTempMM06", quiet=TRUE) #additional 'value-added' attributes
#   if(nrow(NHD_HR_temp_06) > 0){
#     NHD_HR_temp <- NHD_HR_temp_06[,3]
#     temp$temp_c_06 <- NHD_HR_temp / 100
#   }
#   
#   NHD_HR_temp_07 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrTempMM07", quiet=TRUE) #additional 'value-added' attributes
#   if(nrow(NHD_HR_temp_07) > 0){
#     NHD_HR_temp <- NHD_HR_temp_07[,3]
#     temp$temp_c_07 <- NHD_HR_temp / 100
#   }
#   
#   NHD_HR_temp_08 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrTempMM08", quiet=TRUE) #additional 'value-added' attributes
#   if(nrow(NHD_HR_temp_08) > 0){
#     NHD_HR_temp <- NHD_HR_temp_08[,3]
#     temp$temp_c_08 <- NHD_HR_temp / 100
#   }
#   
#   NHD_HR_temp_09 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrTempMM09", quiet=TRUE) #additional 'value-added' attributes
#   if(nrow(NHD_HR_temp_09) > 0){
#     NHD_HR_temp <- NHD_HR_temp_09[,3]
#     temp$temp_c_09 <- NHD_HR_temp / 100
#   }
#   
#   NHD_HR_temp_10 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrTempMM10", quiet=TRUE) #additional 'value-added' attributes
#   if(nrow(NHD_HR_temp_10) > 0){
#     NHD_HR_temp <- NHD_HR_temp_10[,3]
#     temp$temp_c_10 <- NHD_HR_temp / 100
#   }
#   
#   NHD_HR_temp_11 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrTempMM11", quiet=TRUE) #additional 'value-added' attributes
#   if(nrow(NHD_HR_temp_11) > 0){
#     NHD_HR_temp <- NHD_HR_temp_11[,3]
#     temp$temp_c_11 <- NHD_HR_temp / 100
#   }
#   
#   NHD_HR_temp_12 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrTempMM12", quiet=TRUE) #additional 'value-added' attributes
#   if(nrow(NHD_HR_temp_12) > 0){
#     NHD_HR_temp <- NHD_HR_temp_12[,3]
#     temp$temp_c_12 <- NHD_HR_temp / 100
#   }
#   
#   temp$airTemp_mean_c <- rowMeans(temp[,2:ncol(temp)], na.rm=T)
#   temp <- dplyr::select(temp, c('NHDPlusID', 'airTemp_mean_c'))
#   
#   # #get mean annual T (direct column indexing because of typos in USGS tables...)-----------------------------
#   # NHD_HR_precip_01 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrPrecipMM01", quiet=TRUE) #additional 'value-added' attributes
#   # precip <- data.frame('NHDPlusID'=NHD_HR_precip_01[,1],
#   #                    'precip_c_01' = NHD_HR_precip_01[,3] / 1000 * 25.4)
#   # 
#   # NHD_HR_precip_02 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrPrecipMM02", quiet=TRUE) #additional 'value-added' attributes
#   # if(nrow(NHD_HR_precip_02) > 0){
#   #   NHD_HR_precip <- NHD_HR_precip_02[,3]
#   #   precip$precip_c_02 <- NHD_HR_precip /1000 * 25.4
#   # }
#   # 
#   # NHD_HR_precip_03 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrPrecipMM03", quiet=TRUE) #additional 'value-added' attributes
#   # if(nrow(NHD_HR_precip_03) > 0){
#   #   NHD_HR_precip <- NHD_HR_precip_03[,3]
#   #   precip$precip_c_03 <- NHD_HR_precip /1000 * 25.4
#   # }
#   # 
#   # NHD_HR_precip_04 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrPrecipMM04", quiet=TRUE) #additional 'value-added' attributes
#   # if(nrow(NHD_HR_precip_04) > 4){
#   #   NHD_HR_precip <- NHD_HR_precip_04[,3]
#   #   precip$precip_c_04 <- NHD_HR_precip /1000 * 25.4
#   # }
#   # 
#   # NHD_HR_precip_05 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrPrecipMM05", quiet=TRUE) #additional 'value-added' attributes
#   # if(nrow(NHD_HR_precip_05) > 0){
#   #   NHD_HR_precip <- NHD_HR_precip_05[,3]
#   #   precip$precip_c_05 <- NHD_HR_precip /1000 * 25.4
#   # }
#   # 
#   # NHD_HR_precip_06 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrPrecipMM06", quiet=TRUE) #additional 'value-added' attributes
#   # if(nrow(NHD_HR_precip_06) > 0){
#   #   NHD_HR_precip <- NHD_HR_precip_06[,3]
#   #   precip$precip_c_06 <- NHD_HR_precip /1000 * 25.4
#   # }
#   # 
#   # NHD_HR_precip_07 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrPrecipMM07", quiet=TRUE) #additional 'value-added' attributes
#   # if(nrow(NHD_HR_precip_07) > 0){
#   #   NHD_HR_precip <- NHD_HR_precip_07[,3]
#   #   precip$precip_c_07 <- NHD_HR_precip /1000 * 25.4
#   # }
#   # 
#   # NHD_HR_precip_08 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrPrecipMM08", quiet=TRUE) #additional 'value-added' attributes
#   # if(nrow(NHD_HR_precip_08) > 0){
#   #   NHD_HR_precip <- NHD_HR_precip_08[,3]
#   #   precip$precip_c_08 <- NHD_HR_precip /1000 * 25.4
#   # }
#   # 
#   # NHD_HR_precip_09 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrPrecipMM09", quiet=TRUE) #additional 'value-added' attributes
#   # if(nrow(NHD_HR_precip_09) > 0){
#   #   NHD_HR_precip <- NHD_HR_precip_09[,3]
#   #   precip$precip_c_09 <- NHD_HR_precip /1000 * 25.4
#   # }
#   # 
#   # NHD_HR_precip_10 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrPrecipMM10", quiet=TRUE) #additional 'value-added' attributes
#   # if(nrow(NHD_HR_precip_10) > 0){
#   #   NHD_HR_precip <- NHD_HR_precip_10[,3]
#   #   precip$precip_c_10 <- NHD_HR_precip /1000 * 25.4
#   # }
#   # 
#   # NHD_HR_precip_11 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrPrecipMM11", quiet=TRUE) #additional 'value-added' attributes
#   # if(nrow(NHD_HR_precip_11) > 0){
#   #   NHD_HR_precip <- NHD_HR_precip_11[,3]
#   #   precip$precip_c_11 <- NHD_HR_precip /1000 * 25.4
#   # }
#   # 
#   # NHD_HR_precip_12 <- sf::st_read(dsn = dsnPath, layer = "NHDPlusIncrPrecipMM12", quiet=TRUE) #additional 'value-added' attributes
#   # if(nrow(NHD_HR_precip_12) > 0){
#   #   NHD_HR_precip <- NHD_HR_precip_12[,3]
#   #   precip$precip_c_12 <- NHD_HR_precip /1000 * 25.4
#   # }
#   # 
#   # precip$precip_sum_mm <- rowSums(precip[,2:ncol(precip)], na.rm=T) #apply mean monthly precip to 30 days for eah month in the sum
#   # precip$precip_sd_mm <- apply(precip[,2:ncol(precip)], 1, sd, na.rm=T)
#   # precip <- dplyr::select(precip, c('NHDPlusID', 'precip_sum_mm', 'precip_sd_mm'))
#   
#   rivNetFin <- dplyr::left_join(rivNetFin, temp, by='NHDPlusID')
#   #rivNetFin <- dplyr::left_join(rivNetFin, precip, by='NHDPlusID')
#   
#   return(rivNetFin)
# }






#' Adds ephemeral index to combined results
#'
#' @name addEphemeralIndex
#'
#' @param combined_results: combined target of results
#'
#' @return summary statistics
addEphemeralIndex <- function(combined_results_init){
  combined_results_init$ephemeralIndex <- mapply(ephemeralIndexFunc, combined_results_init$percQ_eph, combined_results_init$percLength_eph_cult_devp, combined_results_init$percNumFlowingDys,
                                            max(combined_results_init$percQ_eph, na.rm=T), min(combined_results_init$percQ_eph, na.rm=T),
                                            max(combined_results_init$percLength_eph_cult_devp, na.rm=T), min(combined_results_init$percLength_eph_cult_devp, na.rm=T),
                                            max(combined_results_init$percNumFlowingDys, na.rm=T), min(combined_results_init$percNumFlowingDys, na.rm=T))

  return(combined_results_init)
}


#' create ephemeral index paper figure (fig 4)
#'
#' @name combinedMetricPlot
#'
#' @param shapefile_fin: final sf object with model results
#'
#' @import sf
#' @import dplyr
#' @import ggplot2
#' @import cowplot
#'
#' @return combined metric results figure (also writes figure to file)
combinedMetricPlot <- function(shapefile_fin) {
  theme_set(theme_classic())

  ##GET DATA
  results <- shapefile_fin$shapefile

  # CONUS boundary
  states <- sf::st_read('/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/other_shapefiles/cb_2018_us_state_5m.shp')
  states <- dplyr::filter(states, !(NAME %in% c('Alaska',
                                                'American Samoa',
                                                'Commonwealth of the Northern Mariana Islands',
                                                'Guam',
                                                'District of Columbia',
                                                'Puerto Rico',
                                                'United States Virgin Islands',
                                                'Hawaii'))) #remove non CONUS states/territories
  states <- st_union(states)

  #MAIN MAP-------------------------------------------------
  results_map <- ggplot(results) +
    geom_sf(aes(fill=ephemeralIndex), #actual map
            color='black',
            size=0.5) +
    geom_sf(data=states,
            color='black',
            size=1.25,
            alpha=0)+
    scale_fill_gradientn(name='NWPR Impact Index',
                         colors=c('white', '#A2222A', '#800E13'),
                         limits=c(0,1),
                         guide = guide_colorbar(direction = "horizontal",
                                                title.position = "bottom"))+
    labs(tag='A')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(0.15, 0.1),
          legend.key.size = unit(2, 'cm'))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 20),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                                  face='bold'))+
    xlab('')+
    ylab('')

  #HISTOGRAM--------------------------------
  histo <- ggplot(results, aes(x=ephemeralIndex))+
    geom_histogram(color='black', fill='#cab2d6', size=1, bins = 30) +
    xlab('NWPR Impact Index') +
    xlim(0,1)+
    ylab('Count') +
    labs(tag='B')+
    theme(axis.title = element_text(size=20, face='bold'),
          axis.text = element_text(size=20,face='bold'),
          plot.tag = element_text(size=26,
                                  face='bold'))

  ##COMBO PLOT------------------------
  design <- "
    A
    A
    A
    A
    A
    B
   "
  comboPlot <- patchwork::wrap_plots(A=results_map, B=histo, design=design)

  ggsave('cache/paper_figures/fig4.jpg', comboPlot, width=20, height=17)
  return('cache/paper_figures/fig4.jpg')
}



#' Calculates index for potential for water quality degradation due to NWPR + ephemeral streams
#'
#' @name ephemeralIndexFunc
#'
#' @param contribution: dimension 1: ephemeral contribution to streamflow
#' @param landuse: dimension 2: ephemeral flow frequency
#' @param frequency: dimension 3: potential for ephemeral contribution to point-source pollution
#'
#' @return mean of the three dimensions (equation S9)
ephemeralIndexFunc <- function(contribution, landuse, frequency, maxContrib, minContrib, maxLanduse, minLanduse, maxFreq, minFreq) {
  #re-scale yto 0-1
  contribution <- (contribution - minContrib) / (maxContrib - minContrib)
  landuse <- (landuse - minLanduse) / (maxLanduse - minLanduse)
  frequency <- (frequency - minFreq) / (maxFreq - minFreq)

  return(mean(c(contribution, landuse, frequency)))
}
