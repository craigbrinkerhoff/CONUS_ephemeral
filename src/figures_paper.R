## FUNCTIONS FOR PAPER FIGURES
## Craig Brinkerhoff
## Summer 2022



#' create ephemeral contribution paper figure (fig 1)
#'
#' @name mainFigureFunction
#'
#' @param shapefile_fin: final sf object with model results
#' @param net_0107_results: final river network results for basin 0107
#' @param net_1009_results: final river network results for basin 1009
#' @param net_1709_results: final river network results for basin 1709
#' @param net_1305_results: final river network results for basin 1305
#'
#' @import sf
#' @import dplyr
#' @import ggplot2
#' @import ggsflabel
#' @import ggspatial
#' @import ggrepel
#' @import cowplot
#' @import patchwork
#'
#' @return main model results figure (also writes figure to file)
mainFigureFunction <- function(shapefile_fin, net_0107_results, net_1009_results, net_1709_results, net_1305_results) {
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

  #results shapefile
  results$totalephemeralQ_km3_yr <- results$totalephemeralQ_cms * 86400 * 365 * 1e-9 #convert to km3/yr

  #labels for select basins with subplots
  results$ids_west <- ifelse(results$huc4 == '1009', 'C',
                         ifelse(results$huc4 == '1709', 'E', NA))
  results$ids_east <- ifelse(results$huc4 == '0107', 'D',
                          ifelse(results$huc4 == '1305', 'B',NA))

  #bin all model results for mapping purposes (manual palette specification)
   results$perc_binned <- cut(results$totalephemeralQ_km3_yr, breaks = c(0,1,5,10,15,20,max(results$totalephemeralQ_km3_yr)), include.lowest = TRUE)

  #HISTOGRAM INSET
  ephVolumeHist <- ggplot(results, aes(x=totalephemeralQ_km3_yr))+
    geom_histogram(color='black', fill='#cab2d6', size=1, bins = 30) +
    xlab('') +
    ylab('Count') +
    theme(axis.title = element_text(size=18, face='bold'),
          axis.text = element_text(size=15,face='bold'))

  #MAIN MAP------------------------------------------------------------------------------
  results_map <- ggplot(results) +
    draw_plot(ephVolumeHist,
              x = -128,
              y = 25.5,
              width = 25,
              height = 5.5)+ #histogram
    geom_sf(aes(fill=perc_binned), #actual map
            color='black',
            size=0.5) +
    geom_sf(data=states, #conus boundary
            color='black',
            size=1.25,
            alpha=0)+
    ggsflabel::geom_sf_label_repel(aes(label=ids_west),
                        fontface = "bold",
                        size =12,
                        segment.size=3,
                        segment.color='darkgrey',
                        show.legend = FALSE,
                        ylim=c(35,45),
                        xlim=c(-127,-125.1))+
    ggsflabel::geom_sf_label_repel(aes(label=ids_east),
                        fontface = "bold",
                        size =12,
                        segment.size=3,
                        segment.color='darkgrey',
                        show.legend = FALSE,
                        ylim=c(30,40),
                        xlim=c(-72.5,-70))+
     scale_fill_manual(name='U.S. Ephemeral\nDischarge Contribution [km3/yr]',
                       values = c("#264653", "#2A9D8F", "#E9C46A", "#F4A261", "#EB886F", '#E76F51'),
                       labels=c('0-1','1-5','5-10','10-15','15-20','20+'), #palette color breaks for legend
                       guide = guide_legend(direction = "horizontal",
                                            title.position = "top"))+
    labs(tag='A')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 20),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                              face='bold'))+
    theme(legend.position = c(.22, 0.05))+ #legend position settings
    guides(fill = guide_legend(nrow = 1))+
    xlab('')+
    ylab('')

  ##RIVER NETWORK MAP 0107-------------------------------------------------------------------------------------
  net_0107 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_01/NHDPLUS_H_0107_HU4_GDB/NHDPLUS_H_0107_HU4_GDB.gdb', layer='NHDFlowline')
  net_0107 <- dplyr::left_join(net_0107, net_0107_results, 'NHDPlusID')
  net_0107 <- dplyr::filter(net_0107, is.na(perenniality)==0)

  hydrography_0107 <- ggplot(net_0107, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#f18f01', '#006e90'),
                       labels=c('Ephemeral', 'Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='D')+
    theme(plot.title = element_text(face = "italic", size = 26),
          plot.tag = element_text(size=26,
                              face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Merrimack River:\n', round(results[results$huc4 == '0107',]$totalephemeralQ_km3_yr,0), ' km3/yr'))

  ##RIVER NETWORK MAP 1709-------------------------------------------------------------------------------------------
  net_1709 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_17/NHDPLUS_H_1709_HU4_GDB/NHDPLUS_H_1709_HU4_GDB.gdb', layer='NHDFlowline')
  net_1709 <- dplyr::left_join(net_1709, net_1709_results, 'NHDPlusID')
  net_1709 <- dplyr::filter(net_1709, is.na(perenniality)==0)

  hydrography_1709 <- ggplot(net_1709, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='',
                       values=c('#f18f01', '#006e90'),
                       labels=c('Ephemeral', 'Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='E')+
    theme(legend.position = 'none',
          plot.title = element_text(face = "italic", size = 26),
          plot.tag = element_text(size=26,
                                  face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Willamette River:\n', round(results[results$huc4 == '1709',]$totalephemeralQ_km3_yr,0), ' km3/yr'))

  ##RIVER NETWORK MAP 1009---------------------------------------------------------------------------
  net_1009 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_10/NHDPLUS_H_1009_HU4_GDB/NHDPLUS_H_1009_HU4_GDB.gdb', layer='NHDFlowline')
  net_1009 <- dplyr::left_join(net_1009, net_1009_results, 'NHDPlusID')
  net_1009 <- dplyr::filter(net_1009, is.na(perenniality)==0)

  hydrography_1009 <- ggplot(net_1009, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='',
                       values=c('#f18f01', '#006e90'),
                      labels=c('Ephemeral', 'Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    labs(tag='C')+
    theme(legend.position = 'none',
          plot.title = element_text(face = "italic", size = 26),
          plot.tag = element_text(size=26,
                               face='bold'))+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Powder/Tongue Rivers:\n', round(results[results$huc4 == '1009',]$totalephemeralQ_km3_yr,0), ' km3/yr'))

##RIVER NETWORK MAP 1305-----------------------------------------------------------
  net_1305 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_13/NHDPLUS_H_1305_HU4_GDB/NHDPLUS_H_1305_HU4_GDB.gdb', layer='NHDFlowline')
  net_1305 <- dplyr::left_join(net_1305, net_1305_results, 'NHDPlusID')
  net_1305 <- dplyr::filter(net_1305, is.na(perenniality)==0)

  hydrography_1305 <- ggplot(net_1305, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#f18f01', '#006e90'),
                       labels=c('Ephemeral', 'Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='B')+
    theme(legend.position = 'none',
          plot.title = element_text(face = "italic", size = 26),
          plot.tag = element_text(size=26,
                              face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Rio Grande Endorheic:\n', round(results[results$huc4 == '1305',]$totalephemeralQ_km3_yr,0), ' km3/yr'))

    ##EXTRACT SHARED LEGEND-----------------
    hydrography_legend <- cowplot::get_legend(
                                    hydrography_0107 +
                                      labs(tag = '')+
                                      theme(legend.position = "bottom",
                                            legend.text = element_text(size=24),
                                            legend.title = element_text(size=26,
                                                                    face='bold'),
                                            legend.box="vertical",
                                            legend.margin=margin(),
                                            legend.spacing.x = unit(2, 'cm')) +
                                      guides(color = guide_legend(override.aes = list(size=10))))

    ##COMBO PLOT------------------------------
    design <- "
    AAAA
    AAAA
    AAAA
    AAAA
    AAAA
    AAAA
    BCDE
    BCDE
    BCDE
    FFFF
    "
    comboPlot <- patchwork::wrap_plots(A=results_map, B=hydrography_1305, C=hydrography_1009, D=hydrography_0107+theme(legend.position='none'), E=hydrography_1709, F=hydrography_legend, design=design)

   ggsave('cache/paper_figures/fig1.jpg', comboPlot, width=20, height=20)
   return('see cache/paper_figures/fig1.jpg')
}






#' create ephemeral flow frequency paper figure (fig 2)
#'
#' @name flowingFigureFunction
#'
#' @param joinedData: df of flowing days field data joined to huc4 basin model results
#' @param shapefile_fin: final sf object with flowing days results
#'
#' @import sf
#' @import dplyr
#' @import ggplot2
#' @import cowplot
#' @import patchwork
#'
#' @return flowing days figure (also writes figure to file)
flowingFigureFunction <- function(shapefile_fin, joinedData) {
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
  states <- sf::st_union(states)

  ##SETUP FIELD VERIFICATION STUFF
  joinedData$n_flw_d <- round(joinedData$n_flw_d, 0)
  joinedData$num_flowing_dys <- round(joinedData$num_flowing_dys, 0)
  joinedData$num_flowing_dys_sigma <- round(joinedData$num_flowing_dys_sigma, 0)

  #joinedData$flag <- ifelse(is.na(joinedData$se), 'No confidence intervals', '95% confidence intervals')  #ifelse(joinedData$huc4 == '0302', 'Ephemeral + Intermittent', 'Ephemeral') #duke Forest special case
  joinedData$region <- ifelse(substr(joinedData$huc4,1,2) %in% c('01', '02', '03', '04', '05', '06', '07', '08', '09'), 'East', 'West') #assign east vs west

  ##HISTOGRAM
  flowingDaysHist <- ggplot(results, aes(x=num_flowing_dys))+
    geom_histogram(color='black', fill='#cab2d6', size=1, bins=30) +
    xlab('') +
    ylab('Count') +
    theme(axis.title = element_text(size=18, face='bold'),
          axis.text = element_text(size=15,face='bold'))

  ##MAIN MAP------------------------------------------
  flowingDaysFig <- ggplot(results) +
    draw_plot(flowingDaysHist,
              x = -128,
               y = 24.7,
              width = 25,
              height = 5.5)+ #histogram
    geom_sf(aes(fill=num_flowing_dys), #observed
            color='black',
            size=0.5) + #map
    scale_fill_gradientn(name='U.S. Ephemeral Flow Frequency [d/yr]',
                         colors = c("#FF4B1F", "#f7e9e8", "#044976"),
                         limits=c(0,80),
                         breaks=c(1,10,20,30,40,50,60,70,80),
                         guide = guide_legend(direction = "horizontal",title.position = "top"))+
    guides(fill = guide_legend(nrow = 1))+
    ggnewscale::new_scale_fill()+ #'resets' scale so we can do two scale_fills in the same plot
    geom_sf(data=states,
            color='black',
            size=1.0,
            alpha=0)+ #conus domain
    geom_sf(data=joinedData,
            aes(fill=region),
            size=10,
            pch=23,
            stroke=2)+ #verification data locations
    scale_fill_manual(name='',
                      values=c('#264653', '#2a9d8f'),
                      guide='none')+
    labs(tag='A')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(.2, 0.05))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 18),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                               face='bold'))+
    xlab('')+
    ylab('')

   ##VERIFICATION FIGURE------------------
  flowingDaysVerifyFig <- ggplot(joinedData, aes(x=n_flw_d, y=num_flowing_dys, ymin=num_flowing_dys-num_flowing_dys_sigma, ymax=num_flowing_dys+num_flowing_dys_sigma, fill=region))+
    geom_abline(size=2, linetype='dashed', color='darkgrey')+
    geom_pointrange(size=3, fatten=4, pch=23, color='black')+
    scale_fill_manual(name='',
                       values=c('#264653', '#2a9d8f'))+
    ylab('Predicted d/yr (basin avg.)')+
    xlab('Measured d/yr (catchment avg.)')+
    ylim(-2,80)+
    xlim(-2,80)+
    labs(tag='B')+
    theme(axis.text=element_text(size=20),
          axis.title=element_text(size=22,face="bold"),
          plot.title = element_text(size = 30, face = "bold"),
          legend.position='right',
          legend.title =element_blank(),
          legend.text = element_text(family = "Futura-Medium", size = 26),
          plot.tag = element_text(size=26,
                                  face='bold'))

   ##EXTRACT SHARED LEGEND--------------------------
   legend <- cowplot::get_legend(flowingDaysVerifyFig +
                                    labs('')+
                                    theme(plot.tag = element_text(size=32,
                                                          face='bold'),
                                          legend.spacing.x = unit(1.5, 'cm')) +
                                    guides(fill = guide_legend(override.aes = list(size = 3),  keyheight = 4)))
                

   ##COMBO PLOT------------------------
   design <- "
   AAAA
   AAAA
   AAAA
   AAAA
   AAAA
   CCBB
   CCBB
   "
   comboPlot <- patchwork::wrap_plots(A=flowingDaysFig, B=flowingDaysVerifyFig + theme(legend.position='none'), C=legend, design=design)

  ggsave('cache/paper_figures/fig2.jpg', comboPlot, width=20, height=20)
  return('see cache/paper_figures/fig2.jpg')
}



#' create ephemeral land use paper figure (fig 3)
#'
#' @name landUseMapFunction
#'
#' @param shapefile_fin: final sf object with model results
#'
#' @import sf
#' @import dplyr
#' @import ggplot2
#' @import cowplot
#'
#' @return land use results figure (also writes figure to file)
landUseMapFunction <- function(shapefile_fin) {
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
  
  #results shapefile
  results$ephemeralCultDevpNetworkLength_km <- results$ephemeralCultDevpNetworkLength_km
  
  #bin all model results for mapping purposes (manual palette specification)
  results$binned <- cut(results$ephemeralCultDevpNetworkLength_km, breaks = c(0,5000,10000,25000,50000,100000,max(results$ephemeralCultDevpNetworkLength)), include.lowest = TRUE)
  
  #HISTOGRAM INSET
  ephVolumeHist <- ggplot(results, aes(x=ephemeralCultDevpNetworkLength_km/1000))+
    geom_histogram(color='black', fill='#cab2d6', size=1, bins = 20) +
    xlab('') +
    ylab('Count') +
    theme(axis.title = element_text(size=18, face='bold'),
          axis.text = element_text(size=15,face='bold'))
  
  #MAIN MAP-------------------------------------------------
  results_map <- ggplot(results) +
    draw_plot(ephVolumeHist,
              x = -128,
              y = 25.15,
              width = 25,
              height = 5.5)+ #histogram
    geom_sf(aes(fill=binned), #actual map
            color='black',
            size=0.5) +
    geom_sf(data=states,
            color='black',
            size=1.25,
            alpha=0)+
    scale_fill_manual(name='U.S. ephemeral network flowing\nthrough cultivated/developed lands [1e3 km]',
                      values = c("#355070", "#6d597a", "#b56576", "#e56b6f", "#e88c7d", '#CF6126'),
                      labels=c('0-5','5-10','10-25','25-50','50-100','100+'), #palette color breaks for legend
                      guide = guide_legend(direction = "horizontal",
                                           title.position = "top"))+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(.20, 0.05))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 20),
          legend.text = element_text(family = "Futura-Medium", size = 18))+
    guides(fill = guide_legend(nrow = 1))+
    xlab('')+
    ylab('')
  
  ggsave('cache/paper_figures/fig3.jpg', results_map, width=20, height=15)
  return('see cache/paper_figures/fig3.jpg')
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
  
  #setup
  results$ephemeralIndex <- results$ephemeralIndex * 100
  
  #bin all model results for mapping purposes (manual palette specification)
  results$perc_binned <- cut(results$ephemeralIndex, breaks = c(0,5,10,15,20,25,100), include.lowest = TRUE)
  
  #HISTOGRAM INSET
  ephVolumeHist <- ggplot(results, aes(x=ephemeralIndex))+
    geom_histogram(color='black', fill='#cab2d6', size=1, bins = 20) +
    xlab('') +
    ylab('Count') +
    theme(axis.title = element_text(size=18, face='bold'),
          axis.text = element_text(size=15,face='bold'))
  
  #MAIN MAP-------------------------------------------------
  results_map <- ggplot(results) +
    draw_plot(ephVolumeHist,
              x = -128,
              y = 25.25,
              width = 25,
              height = 5.5)+ #histogram
    geom_sf(aes(fill=perc_binned), #actual map
            color='black',
            size=0.5) +
    geom_sf(data=states,
            color='black',
            size=1.25,
            alpha=0)+
    scale_fill_manual(name='NWPR impact index',
                      values = c("#213e52", "#66827A", "#99A88C", "#FFF3B0", "#E09F3E", "#9E2A2B"),
                      labels=c('0-5','5-10','10-15','15-20','20-25', '25-100'), #palette color breaks for legend
                      guide = guide_legend(direction = "horizontal",
                                           title.position = "top"))+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(.20, 0.05))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 20),
          legend.text = element_text(family = "Futura-Medium", size = 18))+
    guides(fill = guide_legend(nrow = 1))+
    xlab('')+
    ylab('')
  
  ggsave('cache/paper_figures/fig4.jpg', results_map, width=20, height=15)
  return('see cache/paper_figures/fig4.jpg')
}
















#' create bivariate paper figure (fig 4)
#'
#' @name mainFigureFunction
#'
#' @param shapefile_fin: final sf object with model results
#'
#' @import sf
#' @import dplyr
#' @import ggplot2
#' @import ggsflabel
#' @import ggspatial
#' @import ggrepel
#' @import cowplot
#' @import patchwork
#'
#' @return main model results figure (also writes figure to file)
bivariateMapFunction <- function(shapefile_fin, net_1025_results) {
  theme_set(theme_classic())
  
  ##GET DATA
  results <- shapefile_fin$shapefile
  results$percLength_eph_cult_devp <- ifelse(is.na(results$percLength_eph_cult_devp), 0, results$percLength_eph_cult_devp) #reset NAs to zero
  
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
  
  #results shapefile
  results <- dplyr::filter(results, is.na(percQ_eph_scaled)==0)
  results$percLength_eph_cult_devp <- round(results$percLength_eph_cult_devp * 100,0)
  results$percQ_eph_scaled <- round(results$percQ_eph_scaled * 100,0)
  results$id <- ifelse(results$huc4 == '1025','B',NA)
  
  setDim <- 3 #dimensions for bivariate map
  
  #calculate bi-variate class for each basin
  results$percQ_eph_scaled_bin <- cut(results$percQ_eph_scaled, breaks = c(0,1,5,100), include.lowest = TRUE)
  # results$percLength_eph_cult_devp_bin <- cut(results$percLength_eph_cult_devp, breaks = c(0,3,10,100), include.lowest = TRUE)
  labels <- biscale::bi_class_breaks(results, percLength_eph_cult_devp, percQ_eph_scaled_bin, style = "quantile", dim = setDim, dig_lab = 0, split = TRUE)
  data <- biscale::bi_class(results, percLength_eph_cult_devp, percQ_eph_scaled_bin, style = "quantile", dim = setDim)
  
  #LEGEND
  # bivariate legend
  legend <- biscale::bi_legend(pal = "DkViolet2",
                               dim = setDim,
                               ylab = "% streamflow is ephemeral",
                               xlab = "% ephemeral that are cultivated/developed",
                               size = 24,
                               breaks = labels,
                               arrows = FALSE)
  
  #MAIN MAP-----------------------------------------------
  bivariate_map <- ggplot(data) +
    geom_sf(mapping = aes(fill = bi_class),
            color = "black",
            size = 0.5,
            show.legend = FALSE) +
    biscale::bi_scale_fill(pal = "DkViolet2", dim = setDim) +
    geom_sf(data=states, color='black', size=1.25, alpha=0)+
    ggsflabel::geom_sf_label_repel(aes(label=id),
                                   fontface = "bold",
                                   size =12,
                                   segment.size=3,
                                   segment.color='darkgrey',
                                   show.legend = FALSE,
                                   ylim=c(25,30),
                                   xlim=c(-127,-125.1))+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(text = element_text(family = "Futura-Medium"))+
    xlab('')+
    ylab('') +
    labs(tag='A')+
    theme(plot.tag = element_text(size=26,
                                  face='bold'))
  
  ##RIVER NETWORK MAP 1009---------------------------------------------------------------------------
  net_1025 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_10/NHDPLUS_H_1025_HU4_GDB/NHDPLUS_H_1025_HU4_GDB.gdb', layer='NHDFlowline')
  net_1025 <- dplyr::left_join(net_1025, net_1025_results, 'NHDPlusID')
  net_1025 <- dplyr::filter(net_1025, is.na(nlcd_broad)==0)
  
  net_1025$nlcd_ephemeral <- ifelse(net_1025$nlcd_broad %in% c(70,20) & net_1025$perenniality == 'ephemeral', 'Cultivated/developed ephemeral streams', 'Other')
  
  hydrography_1025 <- ggplot(net_1025, aes(color=nlcd_ephemeral, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='',
                       values=c('#d16014', '#313715'),
                       guide = guide_legend(direction = "horizontal",
                                            title.position = "top")) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    labs(tag='B')+
    theme(legend.position = 'bottom',
          plot.title = element_text(face = "italic", size = 26),
          plot.tag = element_text(size=26,
                                  face='bold'),
          legend.title = element_text(size=26,
                                      face='bold'),
          legend.box="vertical",
          legend.margin=margin(),
          legend.text = element_text(family = "Futura-Medium", size = 24))+
    guides(color = guide_legend(override.aes = list(size=10),
                                title.hjust = 2.5,
                                label.hjust = -0.005))+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Republican River:\n', round(results[results$huc4 == '1025',]$percQ_eph_scaled,0), '% streamflow is ephemeral\n', round(results[results$huc4 == '1025',]$percLength_eph_cult_devp,0), '% ephemeral network is cultivated/developed'))
  
  
  ##COMBO PLOT----------------------
  design <- "
  AAAA
  AAAA
  AAAA
  AAAA
  AAAA
  CCBB
  CCBB
  "
  finalPlot <- patchwork::wrap_plots(A=bivariate_map, B=legend, C=hydrography_1025, design=design)
  
  ggsave('cache/paper_figures/fig4.jpg', finalPlot, width=20, height=20)
  return('see cache/paper_figures/fig4.jpg')
}
