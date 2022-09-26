#########################
## FUNCTIONS FOR PAPER FIGURES
## Craig Brinkerhoff
## Summer 2022
#########################



#' create main results paper figure (fig 1)
#'
#' @name mainFigureFunction
#'
#' @param shapefile_fin: final sf object with model results
#' @param net_0107_results: final river network results for basin 0107
#' @param net_1021_results: final river network results for basin 1021
#' @param net_1709_results: final river network results for basin 1709
#' @param net_1104_results: final river network results for basin 1104
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
mainFigureFunction <- function(shapefile_fin, net_0107_results, net_1021_results, net_1709_results, net_1104_results) {
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
  results <- dplyr::filter(results, is.na(percQ_eph_scaled)==0)
  results$percQ_eph_scaled <- results$percQ_eph_scaled * 100

  #labels for select basins with subplots
  results$ids_west <- ifelse(results$huc4 == '1021', 'C',
                         ifelse(results$huc4 == '1709', 'E',
                            ifelse(results$huc4 == '1104', 'B', NA)))
  results$ids_east <- ifelse(results$huc4 == '0107', 'D', NA)

  #bin all model results for mapping purposes (manual palette specification)
  results$perc_binned <- ifelse(results$percQ_eph_scaled <= 1, '1',
                            ifelse(results$percQ_eph_scaled <= 5, '5',
                                ifelse(results$percQ_eph_scaled <= 10, '10',
                                    ifelse(results$percQ_eph_scaled <= 15, '15',
                                        ifelse(results$percQ_eph_scaled <= 20, '20', '100')))))

  #HISTOGRAM INSET
  ephVolumeHist <- ggplot(results, aes(x=percQ_eph_scaled))+
    geom_histogram(color='black', fill='#cab2d6', size=1, bins = 20) +
    xlab('') +
    ylab('Count') +
    theme(axis.title = element_text(size=18, face='bold'),
          axis.text = element_text(size=15,face='bold'))

  #MAIN MAP
  results_map <- ggplot(results) +
    draw_plot(ephVolumeHist,
              x = -128,
              y = 25.5,
              width = 25,
              height = 5.5)+ #histogram
    geom_sf(aes(fill=perc_binned),
            color='black',
            size=0.5) +
    geom_sf(data=states,
            color='black',
            size=1.25,
            alpha=0)+
    ggsflabel::geom_sf_label_repel(aes(label=ids_west),
                        fontface = "bold",
                        size =12,
                        segment.size=3,
                        segment.color='black',
                        show.legend = FALSE,
                        ylim=c(35,48.25),
                        xlim=c(-127,-125.1))+
    ggsflabel::geom_sf_label_repel(aes(label=ids_east),
                        fontface = "bold",
                        size =12,
                        segment.size=3,
                        segment.color='black',
                        show.legend = FALSE,
                        ylim=c(35,37),
                        xlim=c(-72.5,-70))+
    scale_fill_manual(name='% water exported via U.S.\nephemeral streams',
                      values = c("#335c67", "#99a88c", "#fff3b0", "#e09f3e", "#9e2a2b", "#540b0e"),
                    #  limits=c(0,100), #max/min values
                    #  values=c(0,5,10,15,20,100), #values that correspond to colors
                      breaks=c('1','5','10','15','20','100'), #palette color breaks for legend
                      guide = guide_legend(direction = "horizontal",
                                           title.position = "top"))+
    labs(tag='A')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(.15, 0.05))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 20),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                              face='bold'))+
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
                       values=c('#fdae61', '#313695'),
                       labels=c('Ephemeral', 'Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
               breaks=c(0.1, 1, 10, 100),
               range=c(0.4,2))+
    labs(tag='D')+
    theme(plot.title = element_text(face = "italic", size = 26),
          plot.tag = element_text(size=26,
                              face='bold'))+
    ggspatial::annotation_scale(location = "bl")+
                                  #width_hint = 0.5) +
    xlab('')+
    ylab('') +
    ggtitle(paste0('Merrimack River:\n', round(results[results$huc4 == '0107',]$percQ_eph_scaled,0), '% ephemeral export'))

  ##RIVER NETWORK MAP 1709-------------------------------------------------------------------------------------------
  net_1709 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_17/NHDPLUS_H_1709_HU4_GDB/NHDPLUS_H_1709_HU4_GDB.gdb', layer='NHDFlowline')
  net_1709 <- dplyr::left_join(net_1709, net_1709_results, 'NHDPlusID')
  net_1709 <- dplyr::filter(net_1709, is.na(perenniality)==0)

  hydrography_1709 <- ggplot(net_1709, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='',
                       values=c('#fdae61', '#313695'),
                       labels=c('Ephemeral', 'Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2))+
    labs(tag='E')+
    theme(legend.position = 'none',
          plot.title = element_text(face = "italic", size = 26),
          plot.tag = element_text(size=26,
                                  face='bold'))+
    ggspatial::annotation_scale(location = "bl")+
                                  #width_hint = 0.5) +
    xlab('')+
    ylab('') +
    ggtitle(paste0('Willamette River:\n', round(results[results$huc4 == '1709',]$percQ_eph_scaled,0), '% ephemeral export'))

  ##RIVER NETWORK MAP 1021---------------------------------------------------------------------------
  net_1021 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_10/NHDPLUS_H_1021_HU4_GDB/NHDPLUS_H_1021_HU4_GDB.gdb', layer='NHDFlowline')
  net_1021 <- dplyr::left_join(net_1021, net_1021_results, 'NHDPlusID')
  net_1021 <- dplyr::filter(net_1021, is.na(perenniality)==0)

  hydrography_1021 <- ggplot(net_1021, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='',
                      values=c('#fdae61', '#313695'),
                      labels=c('Ephemeral', 'Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2))+
    ggspatial::annotation_scale(location = "bl")+
                      #width_hint = 0.5) +
    labs(tag='C')+
    theme(legend.position = 'none',
          plot.title = element_text(face = "italic", size = 26),
          plot.tag = element_text(size=26,
                               face='bold'))+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Loup River:\n', round(results[results$huc4 == '1021',]$percQ_eph_scaled,0), '% ephemeral export'))

##RIVER NETWORK MAP 1104-----------------------------------------------------------
  net_1104 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_11/NHDPLUS_H_1104_HU4_GDB/NHDPLUS_H_1104_HU4_GDB.gdb', layer='NHDFlowline')
  net_1104 <- dplyr::left_join(net_1104, net_1104_results, 'NHDPlusID')
  net_1104 <- dplyr::filter(net_1104, is.na(perenniality)==0)

  hydrography_1104 <- ggplot(net_1104, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#fdae61', '#313695'),
                       labels=c('Ephemeral', 'Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2))+
    labs(tag='B')+
    theme(legend.position = 'none',
          plot.title = element_text(face = "italic", size = 26),
          plot.tag = element_text(size=26,
                              face='bold'))+
    ggspatial::annotation_scale(location = "bl")+
                                #width_hint = 0.5) +
    xlab('')+
    ylab('') +
    ggtitle(paste0('Upper Cimarron River:\n', round(results[results$huc4 == '1104',]$percQ_eph_scaled,0), '% ephemeral export'))

    ##EXTRACT SHARED LEGEND
    hydrography_legend <- cowplot::get_legend(
                                    hydrography_0107 +
                                      labs(tag = '')+
                                      theme(legend.position = "bottom",
                                            legend.text = element_text(size=24),
                                            legend.title = element_text(size=26,
                                                                    face='bold'),
                                            legend.box="vertical",
                                            legend.margin=margin()) +
                                      guides(color = guide_legend(override.aes = list(size=10),
                                                                  title.hjust = 2.5,
                                                                  label.hjust = -0.005),
                                             size = guide_legend(title.hjust = 2.5)))

    ##COMBO PLOT
    design <- "
    AAAA
    AAAA
    AAAA
    AAAA
    AAAA
    AAAA
    BCDE
    BCDE
    FFFF
    "
    comboPlot <- patchwork::wrap_plots(A=results_map, B=hydrography_1104, C=hydrography_1021, D=hydrography_0107+theme(legend.position='none'), E=hydrography_1709, F=hydrography_legend, design=design)

   ggsave('cache/paper_figures/fig1.jpg', comboPlot, width=20, height=20)
   return('see cache/paper_figures/fig1.jpg')
}



#' create flowing days paper figure (fig 2)
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

  #results shapefile
  results <- dplyr::filter(results, is.na(percQ_eph_scaled)==0)

  ##SETUP FIELD VERIFICATION STUFF
  #take HUC4 basin averages (because model reflects a basin-average value)
  joinedData <- joinedData %>%
      dplyr::group_by(huc4) %>%
      dplyr::summarise(n_flw_d = mean(n_flw_d),
                num_flowing_dys = mean(round(num_flowing_dys, 0))) #round off model result

  joinedData$flag <- ifelse(joinedData$huc4 == '0302', 'Ephemeral + Intermittent', 'Ephemeral') #duke Forest special case
  joinedData$region <- ifelse(substr(joinedData$huc4,1,2) %in% c('01', '02', '03', '04', '05', '06', '07', '08', '09'), 'East', 'West') #assign east vs west

  ##HISTOGRAM
  flowingDaysHist <- ggplot(results, aes(x=num_flowing_dys))+
    geom_histogram(color='black', fill='#cab2d6', size=1, bins=30) +
    xlab('') +
    ylab('Count') +
    theme(axis.title = element_text(size=18, face='bold'),
          axis.text = element_text(size=15,face='bold'))

  ##MAP
  flowingDaysFig <- ggplot(results) +
   draw_plot(flowingDaysHist,
             x = -127,
             y = 25.2,
             width = 25,
             height = 5.5)+ #histogram
   geom_sf(aes(fill=num_flowing_dys), color='black', size=0.3) + #map
   geom_sf(data=states, color='black', size=1.0, alpha=0)+ #conus domain
   geom_sf(data=joinedData, aes(color=flag, pch=region), size=15)+ #verification data locations
   scale_color_brewer(palette='Accent',
                      name='',
                      guide='none') +
   scale_fill_gradientn(name='Annual Average Number of Days\nU.S. Ephemeral Streams Flow',
                    colors = c("#ff6945", "#f7e9e8", "#06629e"),
                    limits=c(0,75),
                    breaks=c(1,10,20,30,40,50,60,70),
                    guide = guide_legend(direction = "horizontal",title.position = "top"))+
   labs(tag='A')+
   theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
   theme(legend.position = c(.2, 0.05))+ #legend position settings
   theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 18),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                              face='bold'))+
   guides(fill = guide_legend(nrow = 1))+
   xlab('')+
   ylab('') +
   guides(pch = 'none') #remove pch from legend

   ##VERIFICATION FIGURE
   flowingDaysVerifyFig <- ggplot(joinedData, aes(x=n_flw_d, y=num_flowing_dys)) +
        geom_point(aes(color=flag, pch=region), size=15)+
        scale_color_brewer(palette='Accent', name='')+
        geom_abline(size=2, linetype='dashed', color='darkgrey')+
        ylab('Predicted # Dys (basin avg.)')+
        xlab('In Situ # Dys (basin avg.)')+
        ylim(0,75)+
        xlim(0,75)+
        labs(tag='B')+
        theme(axis.text=element_text(size=20),
              axis.title=element_text(size=22,face="bold"),
              plot.title = element_text(size = 30, face = "bold"),
              legend.position='right',
              legend.title =element_blank(),
              legend.text = element_text(family = "Futura-Medium", size = 26),
              plot.tag = element_text(size=26,
                                  face='bold'))

   ##EXTRACT SHARED LEGEND
   legend <- cowplot::get_legend(flowingDaysVerifyFig +
                                    labs('')+
                                    theme(plot.tag = element_text(size=32,
                                                          face='bold')))

   ##COMBO PLOT
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

  ggsave('cache/paper_figures/fig3.jpg', comboPlot, width=20, height=20)
  return('see cache/paper_figures/fig3.jpg')
}



#' create main validation paper figure (fig 3)
#'
#' @name mappingValidationFigure
#'
#' @param val_shapefile_fin: final validation sf object with model results
#''
#' @import sf
#' @import dplyr
#' @import ggplot2
#' @import cowplot
#' @import patchwork
#'
#' @return main model validation figure (also writes figure to file)
mappingValidationFigure <- function(val_shapefile_fin){
  theme_set(theme_classic())

  ##GET DATA
  results <- val_shapefile_fin$shapefile

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

  #crop to CONUS
  results <- sf::st_intersection(results, states)

  ##HISTOGRAM
  accuracyHist <- ggplot(results, aes(x=basinAccuracy))+
    geom_histogram(color='black', size=1, bins=30) +
    xlab('') +
    ylab('Count') +
    theme(axis.title = element_text(size=18, face='bold'),
          axis.text = element_text(size=15,face='bold'))

  ##ACCURACY MAP
  accuracyFig <- ggplot(results) +
   geom_sf(aes(fill=basinAccuracy), color='black', size=0.3) +
   geom_sf(data=states, color='black', size=1.5, alpha=0)+
   scale_fill_gradientn(name='Classification Accuracy',
                       colors =c("#d73027", "#ffffbf", "#4575b4"),
                       limits=c(0.60,1),
                       breaks=c(0.60, 0.65, 0.70, 0.75, 0.80,0.85, 0.90,0.95, 1.0),
                       guide = guide_legend(direction = "horizontal",title.position = "top"))+
   labs(tag='A')+
   theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
   theme(legend.position = c(.8, 0.15))+ #legend position settings
   theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 18),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                              face='bold'),
          legend.box.background = element_rect(colour = "black"))+
   xlab('')+
   ylab('')

   ##NUMBER MAP
   numberFig <- ggplot(results) +
    geom_sf(aes(fill=n_total), color='black', size=0.3) +
    geom_sf(data=states, color='black', size=1.5, alpha=0)+
    scale_fill_gradientn(name='Number Observations',
                        colors =c("#dadaeb", "#807dba", "#3f007d"),
                        limits=c(59,1156),
                        breaks=c(59,300,600,900,1156),
                        guide = guide_legend(direction = "horizontal",title.position = "top"))+
    labs(tag='B')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(.8, 0.15))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
           legend.title = element_text(face = "bold", size = 18),
           legend.text = element_text(family = "Futura-Medium", size = 18),
           plot.tag = element_text(size=26,
                               face='bold'),
           legend.box.background = element_rect(colour = "black"))+
    xlab('')+
    ylab('')

   ##COMBO PLOT
  design <- "
  A
  B
  "
  comboPlot <- patchwork::wrap_plots(A=accuracyFig, B=numberFig, design=design)

  ggsave('cache/paper_figures/fig2.jpg', comboPlot, width=15, height=18)
  return('see cache/paper_figures/fig2.jpg')
}



#' create main results paper figure (fig 1)
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
bivariateMapFunction <- function(shapefile_fin) {
  theme_set(theme_classic())

  ##GET DATA
  results <- shapefile_fin$shapefile
  results$percEph_cult_devp <- ifelse(is.na(results$percEph_cult_devp), 0, results$percEph_cult_devp) #reset NAs to zero

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
  results$percEph_cult_devp <- results$percEph_cult_devp * 100
  results$percQ_eph_scaled <- results$percQ_eph_scaled * 100

  setDim <- 3 #dimensions for bivariate map

  #calculate bi-variate class for each basin
  #results$percQ_eph_scaled_bin <- cut(results$percQ_eph_scaled, breaks = c(0,5,100), include.lowest = TRUE)
  #results$percEph_cult_devp_bin <- cut(results$percEph_cult_devp, breaks = c(0,5,100), include.lowest = TRUE)
  labels <- biscale::bi_class_breaks(results, percEph_cult_devp, percQ_eph_scaled, style = "quantile", dim = setDim, dig_lab = 0, split = TRUE)
  data <- biscale::bi_class(results, percEph_cult_devp, percQ_eph_scaled, style = "quantile", dim = setDim)

  #LEGEND
  # bivariate legend
  legend <- biscale::bi_legend(pal = "DkBlue2",
                       dim = setDim,
                       ylab = "% ephemeral streamflow",
                       xlab = "% ephemeral that are cultivated/developed",
                       size = 20,
                       breaks = labels,
                       arrows = FALSE) +
            labs(tag='B')+
            theme(plot.tag = element_text(size=26,
                             face='bold'))

  #MAIN MAP
  bivariate_map <- ggplot() +
    geom_sf(data = data,
            mapping = aes(fill = bi_class),
            color = "black",
            size = 0.5,
            show.legend = FALSE) +
    biscale::bi_scale_fill(pal = "DkBlue2", dim = setDim) +
    geom_sf(data=states, color='black', size=1.25, alpha=0)+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(text = element_text(family = "Futura-Medium"))+
    xlab('')+
    ylab('') +
    labs(tag='A')+
    theme(plot.tag = element_text(size=26,
                     face='bold'))

#  finalPlot <- cowplot::ggdraw() +
#    cowplot::draw_plot(bivariate_map, 0, 0, 1, 1) +
#    cowplot::draw_plot(legend, 0.1, .2, 0.2, 0.2)

  ##COMBO PLOT
  design <- "
  AAAA
  AAAA
  AAAA
  AAAA
  AAAA
  CCBB
  CCBB
  "
  finalPlot <- patchwork::wrap_plots(A=bivariate_map, B=legend, design=design)

  ggsave('cache/paper_figures/fig4.jpg', finalPlot, width=15, height=15)
  return('see cache/paper_figures/fig4.jpg')
}
