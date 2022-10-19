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
