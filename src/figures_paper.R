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
                         ifelse(results$huc4 == '1804', 'E',
                                ifelse(results$huc4 == '1407', 'C',NA)))
  results$ids_east <- ifelse(results$huc4 == '0107', 'D',NA)

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
                        ylim=c(30,45),
                        xlim=c(-127,-125.1))+
    ggsflabel::geom_sf_label_repel(aes(label=ids_east),
                        fontface = "bold",
                        size =12,
                        segment.size=3,
                        segment.color='#564C4D',
                        show.legend = FALSE,
                        ylim=c(30,40),
                        xlim=c(-72.5,-70))+
    scale_fill_gradientn(name='% Discharge ephemeral',
                         colors=c('white', '#3E1F47'),#164d71
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
    ggtitle(paste0('Merrimack River:\n', round(results[results$huc4 == '0107',]$QEph_exported_cms*86400*365*1e-9,1), ' km3/yr (', round(results[results$huc4 == '0107',]$percQ_eph,0), '%)'))

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
    ggtitle(paste0('Lower Green River:\n', round(results[results$huc4 == '1407',]$QEph_exported_cms*86400*365*1e-9,1), ' km3/yr (', round(results[results$huc4 == '1407',]$percQ_eph,0), '%)'))

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
    labs(tag='E')+
    theme(legend.position = 'none',
          plot.title = element_text(face = "italic", size = 26),
          plot.tag = element_text(size=26,
                               face='bold'))+
    xlab('')+
    ylab('') +
    ggtitle(paste0('San Joaquin River:\n', round(results[results$huc4 == '1804',]$QEph_exported_cms*86400*365*1e-9,1), ' km3/yr (', round(results[results$huc4 == '1804',]$percQ_eph,0), '%)'))
  
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
    ggtitle(paste0('Rio Grande Endorheic:\n', round(results[results$huc4 == '1305',]$QEph_exported_cms*86400*365*1e-9,1), ' km3/yr (', round(results[results$huc4 == '1305',]$percQ_eph,0), '%)'))
  
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
streamOrderPlot <- function(combined_results_by_order, combined_results, theoretical_curve){
  theme_set(theme_classic())
  
  #get regions
  combined_results_by_order$huc2 <- substr(combined_results_by_order$method, 18, 19)
  combined_results_by_order$huc4 <- substr(combined_results_by_order$method, 18, 21)
  east <- c('0101', '0102', '0103', '0104', '0105', '0106', '0107', '0108', '0109', '0110',
            '0202', '0203', '0206', '0207', '0208', '0204', '0205',
            '0301', '0302', '0303', '0304', '0305', '0306', '0307', '0308', '0309', '0310', '0311', '0312', '0313', '0314', '0315', '0316', '0317', '0318',
            '0401', '0402', '0403', '0404', '0405', '0406', '0407', '0408', '0409', '0410', '0411', '0412', '0413', '0414', '0420', '0427', '0429', '0430',
            '0501', '0502', '0503', '0504', '0505', '0506', '0507', '0508', '0509', '0510', '0511', '0512', '0513', '0514',
            '0601', '0602', '0603', '0604',
            '0701', '0703', '0704', '0705', '0707', '0709', '0712', '0713', '0714',
            '0801', '0803', '0806', '0807', '0809',
            '0901', '0902', '0903', '0904')
  west <- combined_results[!(combined_results$huc4 %in% c(east)),]$huc4
  
  combined_results_by_order$region <- ifelse(combined_results_by_order$huc4 %in% east, 'East of Mississippi River','West of Mississippi River')
  
  keepHUCs <- combined_results[is.na(combined_results$num_flowing_dys)==0,]$huc4
  combined_results_by_order <- dplyr::filter(combined_results_by_order, huc4 %in% keepHUCs)
  
  ####SUMMARY STATS-------------------
  forPlot <- dplyr::group_by(combined_results_by_order, region, StreamOrde) %>%
    dplyr::summarise(percQ_eph_order = mean(percQEph_reach_median*100),
              percQ_eph_order_min =  ifelse(mean(percQEph_reach_median*100) - sd(percQEph_reach_median*100) < 0,0,mean(percQEph_reach_median*100) - sd(percQEph_reach_median*100)),
              percQ_eph_order_max =  ifelse(mean(percQEph_reach_median*100) + sd(percQEph_reach_median*100)> 100,100,mean(percQEph_reach_median*100) + sd(percQEph_reach_median*100)),
              percArea_eph_order = mean(percAreaEph_reach_median*100),
              percArea_eph_order_min =  ifelse(mean(percAreaEph_reach_median*100) - sd(percAreaEph_reach_median*100) < 0,0,mean(percAreaEph_reach_median*100) - sd(percAreaEph_reach_median*100)),
              percArea_eph_order_max =  ifelse(mean(percAreaEph_reach_median*100) + sd(percAreaEph_reach_median*100)> 100,100,mean(percAreaEph_reach_median*100) + sd(percAreaEph_reach_median*100)),
              percN_eph_order = mean(percNEph*100),
              percN_eph_order_min = ifelse(mean(percNEph*100) - sd(percNEph*100) < 0,0,mean(percNEph*100) - sd(percNEph*100)),
              percN_eph_order_max = ifelse(mean(percNEph*100) + sd(percNEph*100) < 0,0,mean(percNEph*100) + sd(percNEph*100)))

  ####DISCHARGE PLOT--------------------
  plotQ <- ggplot(forPlot, aes(color=region, fill=region, x=factor(StreamOrde), y=percQ_eph_order, group=region)) +
    geom_ribbon(aes(ymin=percQ_eph_order_min, ymax=percQ_eph_order_max), alpha=0.25) +
    geom_line(size=2)+
    geom_point(size=11)+
    xlab('Stream Order') +
    ylab('% ephemeral discharge\n(basin medians)')+
    scale_fill_manual(name='',
                      values=c('#688B55', '#2D93AD'))+
    scale_color_manual(name='',
                       values=c('#688B55', '#2D93AD'))+
    ylim(0,100)+
    labs(tag='C')+
    theme(axis.title = element_text(size=26, face='bold'),
          axis.text = element_text(size=24,face='bold'),
          plot.tag = element_text(size=26,
                                  face='bold'),
          legend.position='bottom',
          legend.text = element_text(size=24))

  ####AREA PLOT--------------------
  plotArea <- ggplot(forPlot, aes(color=region, fill=region, x=factor(StreamOrde), y=percArea_eph_order, group=region)) +
    geom_ribbon(aes(ymin=percArea_eph_order_min, ymax=percArea_eph_order_max), alpha=0.25) +
    geom_line(size=2)+
    geom_point(size=11)+
    xlab('') +
    ylab('% ephemeral drainage area\n(basin medians)')+
    scale_fill_manual(name='',
                      values=c('#688B55', '#2D93AD'))+
    scale_color_manual(name='',
                       values=c('#688B55', '#2D93AD'))+
    ylim(0,100)+
    labs(tag='B')+
    theme(axis.title = element_text(size=26, face='bold'),
          axis.text = element_text(size=24,face='bold'),
          plot.tag = element_text(size=26,
                                  face='bold'),
          legend.position='none')
  
  
  ####N PLOT--------------------
  plotN <- ggplot(forPlot, aes(color=region, fill=region, x=factor(StreamOrde), y=percN_eph_order, group=region)) +
    geom_ribbon(aes(ymin=percN_eph_order_min, ymax=percN_eph_order_max), alpha=0.25) +
    geom_line(size=2)+
    geom_point(size=11)+
    xlab('') +
    ylab('% ephemeral streams')+
    scale_fill_manual(name='',
                      values=c('#688B55', '#2D93AD'))+
    scale_color_manual(name='',
                       values=c('#688B55', '#2D93AD'))+
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
  
  #take basin average of field data
  joinedData <- joinedData %>%
    dplyr::group_by(huc4) %>%
    dplyr::summarise(name=first(name),
                     num_flowing_dys = mean(num_flowing_dys),
                     num_flowing_dys_sigma = mean(num_flowing_dys_sigma),
                     n_flw_d = mean(n_flw_d),
                     num_sample_yrs = mean(num_sample_yrs),
                     n_sites = sum(n_sites))# %>%
   # dplyr::filter(huc4 != '1012')
  
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
    geom_pointrange(size=3, fatten=5, pch=23, color='black')+
   # geom_smooth(aes(fill=NULL), color='black', method='lm', se=F, size=2, show.legend = FALSE)+
    scale_fill_manual(name='',
                      values=c('#264653', '#2a9d8f'))+
    ylab('Predicted days/yr')+
    xlab('Measured days/yr')+
    ylim(0,125)+
    xlim(0,125)+
    labs(tag='B')+
    theme(axis.text=element_text(size=24),
          axis.title=element_text(size=26,face="bold"),
          plot.title = element_text(size = 30, face = "bold"),
          legend.position=c(0.20, 0.85),
          legend.title =element_blank(),
          legend.text = element_text(family = "Futura-Medium", size = 26),
          legend.key = element_rect(fill = "grey"),
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
   BBCC
   BBCC
   "
  
  comboPlot <- patchwork::wrap_plots(A=flowingDaysFig, B=flowingDaysVerifyFig, design=design)
  
  
  ggsave('cache/paper_figures/fig3.jpg', comboPlot, width=20, height=20)
  return('see cache/paper_figures/fig3.jpg')
}