## FUNCTIONS FOR PAPER FIGURES
## Craig Brinkerhoff
## Summer 2022



#' create ephemeral contribution paper figure (fig 1)
#'
#' @name mainFigureFunction
#'
#' @param shapefile_fin: final sf object with model results
#' @param net_0107_results: final river network results for basin 0107
#' @param net_1804_results: final river network results for basin 1804
#' @param net_1407_results: final river network results for basin 1407
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
mainFigureFunction <- function(shapefile_fin, net_0107_results, net_1804_results, net_1407_results, net_1305_results) {
  theme_set(theme_classic())

  ##GET DATA
  results <- shapefile_fin$shapefile
  results <- dplyr::filter(results, is.na(num_flowing_dys)==0)

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
  results$percQ_eph <- round(results$percQEph_exported*100,0) #setup percent

  #labels for select basins with subplots
  results$ids_west <- ifelse(results$huc4 == '1305', 'B',
                         ifelse(results$huc4 == '1804', 'E', NA))
  results$ids_east <- ifelse(results$huc4 == '0107', 'D',
                          ifelse(results$huc4 == '1407', 'C',NA))

  #MAIN MAP------------------------------------------------------------------------------
  results_map <- ggplot(results) +
    geom_sf(aes(fill=percQ_eph), #actual map
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
                        segment.color='#564C4D',
                        show.legend = FALSE,
                        ylim=c(35,45),
                        xlim=c(-127,-125.1))+
    ggsflabel::geom_sf_label_repel(aes(label=ids_east),
                        fontface = "bold",
                        size =12,
                        segment.size=3,
                        segment.color='#564C4D',
                        show.legend = FALSE,
                        ylim=c(30,40),
                        xlim=c(-72.5,-70))+
    scale_fill_gradientn(name='% Dishcarge ephemeral',
                         colors=c('white', '#012a4a'),#164d71
                         guide = guide_colorbar(direction = "horizontal",
                                                title.position = "bottom"))+
    labs(tag='A')+
    theme(axis.text = element_text(family="Futura-Medium", size=20),
          legend.key.size = unit(2, 'cm'))+ #axis text settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 20),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                              face='bold'))+
    theme(legend.position = c(.15, 0.1))+ #legend position settings
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
    ggtitle(paste0('Merrimack River:\n', round(results[results$huc4 == '0107',]$totalephemeralQ_cms*86400*365*1e-9,1), ' km3/yr (', round(results[results$huc4 == '0107',]$percQ_eph,0), '%)'))

  ##RIVER NETWORK MAP 1407-------------------------------------------------------------------------------------------
  net_1407 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_14/NHDPLUS_H_1407_HU4_GDB/NHDPLUS_H_1407_HU4_GDB.gdb', layer='NHDFlowline')
  net_1407 <- dplyr::left_join(net_1407, net_1407_results, 'NHDPlusID')
  net_1407 <- dplyr::filter(net_1407, is.na(perenniality)==0)

  hydrography_1407 <- ggplot(net_1407, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='',
                       values=c('#f18f01', '#006e90'),
                       labels=c('Ephemeral', 'Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='C')+
    theme(legend.position = 'none',
          plot.title = element_text(face = "italic", size = 26),
          plot.tag = element_text(size=26,
                                  face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Lower Green River:\n', round(results[results$huc4 == '1407',]$totalephemeralQ_cms*86400*365*1e-9,1), ' km3/yr (', round(results[results$huc4 == '1407',]$percQ_eph,0), '%)'))

  ##RIVER NETWORK MAP 1804---------------------------------------------------------------------------
  net_1804 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_18/NHDPLUS_H_1804_HU4_GDB/NHDPLUS_H_1804_HU4_GDB.gdb', layer='NHDFlowline')
  net_1804 <- dplyr::left_join(net_1804, net_1804_results, 'NHDPlusID')
  net_1804 <- dplyr::filter(net_1804, is.na(perenniality)==0)

  hydrography_1804 <- ggplot(net_1804, aes(color=perenniality, size=Q_cms)) +
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
    labs(tag='B')+
    theme(legend.position = 'none',
          plot.title = element_text(face = "italic", size = 26),
          plot.tag = element_text(size=26,
                               face='bold'))+
    xlab('')+
    ylab('') +
    ggtitle(paste0('San Joaquin River:\n', round(results[results$huc4 == '1804',]$totalephemeralQ_cms*86400*365*1e-9,1), ' km3/yr (', round(results[results$huc4 == '1804',]$percQ_eph,0), '%)'))
  
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
    ggtitle(paste0('Rio Grande Endorheic:\n', round(results[results$huc4 == '1305',]$totalephemeralQ_cms*86400*365*1e-9,1), ' km3/yr (', round(results[results$huc4 == '1305',]$percQ_eph,0), '%)'))
  
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
    comboPlot <- patchwork::wrap_plots(A=results_map, B=hydrography_1305, C=hydrography_1407, D=hydrography_0107+theme(legend.position='none'), E=hydrography_1804, F=hydrography_legend, design=design)

   ggsave('cache/paper_figures/fig1.jpg', comboPlot, width=20, height=20)
   return('see cache/paper_figures/fig1.jpg')
}







#' create stream order results figure (fig 2)
#'
#' @name streamOrderPlot
#'
#' @param combined_results_by_order: df of model results per stream order
#'
#' @import dplyr
#' @import ggplot2
#' @import cowplot
#' @import patchwork
#'
#' @return flowing days figure (also writes figure to file)
streamOrderPlot <- function(combined_results_by_order, combined_results){
  theme_set(theme_classic())
  
  #get regions
  combined_results_by_order$huc2 <- substr(combined_results_by_order$method, 18, 19)
  combined_results_by_order$huc4 <- substr(combined_results_by_order$method, 18, 21)
  combined_results_by_order$region <- ifelse(combined_results_by_order$huc2 %in% c('01', '02', '03','04', '05', '06', '07', '08', '09'), 'East','West')
  # combined_results_by_order$region <- ifelse(combined_results_by_order$huc2 %in% c('01', '02', '03','08'), 'East Coast',
  #                                                   ifelse(combined_results_by_order$huc2 %in% c('04', '05', '06', '07', '09'), 'Midwest',
  #                                                          ifelse(combined_results_by_order$huc2 %in% c('11', '12','10'), 'Plains',
  #                                                                        ifelse(combined_results_by_order$huc2 %in% c('13', '14', '15', '16'), 'Southwest', "West Coast"))))
  
  keepHUCs <- combined_results[is.na(combined_results$num_flowing_dys)==0,]$huc4
  combined_results_by_order <- dplyr::filter(combined_results_by_order, huc4 %in% keepHUCs)
  
  ####SUMMARY STATS-------------------
  forPlot <- dplyr::group_by(combined_results_by_order, region, StreamOrde) %>%
    dplyr::summarise(percQ_eph_order_median = median(percQEph_reach_median*100),
              percQ_eph_order_min = quantile(percQEph_reach_median*100,0.25),
              percQ_eph_order_max = quantile(percQEph_reach_median*100,0.75),
              percArea_eph_order_median = median(percAreaEph_reach_median*100),
              percArea_eph_order_min = quantile(percAreaEph_reach_median*100,0.25),
              percArea_eph_order_max = quantile(percAreaEph_reach_median*100,0.75),
              percN_eph_order_median = median(percNEph*100),
              percN_eph_order_min = quantile(percNEph*100,0.25),
              percN_eph_order_max = quantile(percNEph*100,0.75),)
  
  ####DISCHARGE PLOT--------------------
  plotQ <- ggplot(forPlot, aes(color=region, fill=region, x=factor(StreamOrde), y=percQ_eph_order_median, group=region)) +
    geom_ribbon(aes(ymin=percQ_eph_order_min, ymax=percQ_eph_order_max), alpha=0.4, size=0.25) +
    geom_line(size=2)+
    geom_point(size=9)+
    xlab('Stream Order') +
    ylab('% ephemeral water volume\n(basin-median)')+
    scale_fill_manual(name='',
                      values=c('#5f0f40', '#9a031e'))+#, '#fb8b24', '#52796f', '#0f4c5c'))+
    scale_color_manual(name='',
                       values=c('#5f0f40', '#9a031e'))+#, '#fb8b24', '#52796f', '#0f4c5c'))+
    ylim(0,100)+
    labs(tag='C')+
    theme(axis.title = element_text(size=26, face='bold'),
          axis.text = element_text(size=24,face='bold'),
          plot.tag = element_text(size=26,
                                  face='bold'),
          legend.position='bottom',
          legend.text = element_text(size=20))

  ####AREA PLOT--------------------
  plotArea <- ggplot(forPlot, aes(color=region, fill=region, x=factor(StreamOrde), y=percArea_eph_order_median, group=region)) +
    geom_ribbon(aes(ymin=percArea_eph_order_min, ymax=percArea_eph_order_max), alpha=0.4, size=0.25) +
    geom_line(size=2)+
    geom_point(size=9)+
    xlab('') +
    ylab('% ephemeral drainage area\n(basin-median)')+
    scale_fill_manual(name='',
                      values=c('#5f0f40', '#9a031e'))+#, '#fb8b24', '#52796f', '#0f4c5c'))+
    scale_color_manual(name='',
                       values=c('#5f0f40', '#9a031e'))+#, '#fb8b24', '#52796f', '#0f4c5c'))+
    ylim(0,100)+
    labs(tag='B')+
    theme(axis.title = element_text(size=26, face='bold'),
          axis.text = element_text(size=24,face='bold'),
          plot.tag = element_text(size=26,
                                  face='bold'),
          legend.position='none')
  
  
  ####N PLOT--------------------
  plotN <- ggplot(forPlot, aes(color=region, fill=region, x=factor(StreamOrde), y=percN_eph_order_median, group=region)) +
    geom_ribbon(aes(ymin=percN_eph_order_min, ymax=percN_eph_order_max), alpha=0.4, size=0.25) +
    geom_line(size=2)+
    geom_point(size=9)+
    xlab('') +
    ylab('% ephemeral streams')+
    scale_fill_manual(name='',
                      values=c('#5f0f40', '#9a031e'))+#, '#fb8b24', '#52796f', '#0f4c5c'))+
    scale_color_manual(name='',
                       values=c('#5f0f40', '#9a031e'))+#, '#fb8b24', '#52796f', '#0f4c5c'))+
    ylim(0,100)+
    labs(tag='A')+
    theme(axis.title = element_text(size=26, face='bold'),
          axis.text = element_text(size=24,face='bold'),
          plot.tag = element_text(size=26,
                                  face='bold'),
          legend.position='none')
  
  #setup plot layout 
  design <- "
    AB
    CC
  "
  
  comboPlot <- patchwork::wrap_plots(A=plotN, B=plotArea, C=plotQ, design=design)
  
  
  ggsave('cache/paper_figures/fig2.jpg', comboPlot, width=18, height=18)
  return('see cache/paper_figures/fig2.jpg')
}



















#' create ephemeral flow frequency paper figure (fig 3)
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
  results <- dplyr::filter(results, is.na(num_flowing_dys)==0)
  
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
  
  ##MAIN MAP------------------------------------------
  flowingDaysFig <- ggplot(results) +
    geom_sf(aes(fill=num_flowing_dys), #observed
            color='black',
            size=0.5) + #map
    scale_fill_gradientn(name='Average annual ephemeral flow days',
                         colors = c("#FF4B1F", "#f7e9e8", "#044976"),
                         guide = guide_colorbar(direction = "horizontal",title.position = "bottom"))+
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
    theme(legend.position = c(.2, 0.1),
          legend.key.size = unit(2, 'cm'))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 20),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                                  face='bold'))+
    xlab('')+
    ylab('')
  
  ##VERIFICATION FIGURE------------------
  flowingDaysVerifyFig <- ggplot(joinedData, aes(x=n_flw_d, y=num_flowing_dys, ymin=num_flowing_dys-num_flowing_dys_sigma, ymax=num_flowing_dys+num_flowing_dys_sigma, fill=region))+
    geom_abline(size=2, linetype='dashed', color='darkgrey')+
    geom_pointrange(size=3, fatten=6, pch=23, color='black')+
    scale_fill_manual(name='',
                      values=c('#264653', '#2a9d8f'))+
    ylab('Predicted days/yr (basin avg.)')+
    xlab('Measured days/yr (catchment avg.)')+
    ylim(-2,80)+
    xlim(-2,80)+
    labs(tag='B')+
    theme(axis.text=element_text(size=24),
          axis.title=element_text(size=26,face="bold"),
          plot.title = element_text(size = 30, face = "bold"),
          legend.position=c(0.85,0.2),
          legend.title =element_blank(),
          legend.text = element_text(family = "Futura-Medium", size = 26),
          plot.tag = element_text(size=26,
                                  face='bold'),
          legend.spacing.x = unit(1.5, 'cm')) +
    guides(fill = guide_legend(override.aes = list(size = 3),  keyheight = 4))
  
  ##COMBO PLOT------------------------
  design <- "
   AAAA
   AAAA
   AAAA
   AAAA
   AAAA
   BBBB
   BBBB
   "
  
  comboPlot <- patchwork::wrap_plots(A=flowingDaysFig, B=flowingDaysVerifyFig, design=design)
  
  
  ggsave('cache/paper_figures/fig3.jpg', comboPlot, width=20, height=20)
  return('see cache/paper_figures/fig3.jpg')
}