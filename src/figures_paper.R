## FUNCTIONS FOR PAPER FIGURES
## Craig Brinkerhoff
## Fall 2023



#' create ephemeral contribution paper figure (fig 1)
#'
#' @name mainFigureFunction
#'
#' @param path_to_data: data repo directory path
#' @param shapefile_fin: final sf object with model results
#' @param net_0107_results: final river network results for basin 0107
#' @param net_0701_results: final river network results for basin 0701
#' @param net_1406_results: final river network results for basin 1406
#' @param net_1305_results: final river network results for basin 1305
#'
#' @import sf
#' @import dplyr
#' @import ggplot2
#' @import ggsflabel
#' @import ggspatial
#' @import cowplot
#' @import patchwork
#'
#' @return print statement where main results figure is written to file
mainFigureFunction <- function(path_to_data, shapefile_fin, net_0107_results, net_0701_results, net_1406_results, net_1305_results) {
  theme_set(theme_classic())

  ##GET DATA
  results <- shapefile_fin$shapefile
  results <- dplyr::filter(results, is.na(num_flowing_dys)==0) #remove great lakes

  # CONUS boundary
  states <- sf::st_read(paste0(path_to_data, '/other_shapefiles/cb_2018_us_state_5m.shp'))
  states <- dplyr::filter(states, !(NAME %in% c('Alaska',
                                         'American Samoa',
                                         'Commonwealth of the Northern Mariana Islands',
                                         'Guam',
                                         'District of Columbia',
                                         'Puerto Rico',
                                         'United States Virgin Islands',
                                         'Hawaii'))) #remove non CONUS states/territories
  states <- sf::st_union(states)

  #round results
  results$percQ_eph <- round(results$percQEph_exported*100,0) #setup percent

  #labels for basins with subplots in the figure
  results$ids_west <- ifelse(results$huc4 == '1305', 'B',
                                ifelse(results$huc4 == '1406', 'C',NA))
  results$ids_east <- ifelse(results$huc4 == '0107', 'D',NA)
  results$ids_gl <- ifelse(results$huc4 == '0701', 'E',NA)
  
  #INSET MAP-----------------------------------------------
  cdf_inset <- ggplot(results, aes(percQ_eph))+
    stat_ecdf(size=2, color='black') +
    xlab('% ephemeral discharge')+
    ylab('Probability')+
    theme(axis.title = element_text(size=20),
          axis.text = element_text(family="Futura-Medium", size=18))+
    theme(legend.position = 'none')

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
    ggsflabel::geom_sf_label_repel(aes(label=ids_gl),
                                   fontface = "bold",
                                   size =12,
                                   segment.size=3,
                                   segment.color='#564C4D',
                                   show.legend = FALSE,
                                   ylim=c(48,50),
                                   xlim=c(-88,-87))+
    scale_fill_gradientn(name='% Discharge ephemeral',
                         colors=c('white', '#3E1F47'),
                         limits=c(0,100),
                         guide = guide_colorbar(direction = "horizontal",
                                                title.position = "bottom"))+
    labs(tag='A')+
    theme(axis.text = element_text(family="Futura-Medium", size=20),
          legend.key.size = unit(2, 'cm'))+
    theme(text = element_text(family = "Futura-Medium"),
          legend.title = element_text(face = "bold", size = 20),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                              face='bold'))+
    theme(legend.position = c(.15, 0.1))+
    xlab('')+
    ylab('')

  results_map <- results_map +
    patchwork::inset_element(cdf_inset, right = 0.975, bottom = 0.001, left = 0.775, top = 0.35)

  ##RIVER NETWORK MAP 0107-------------------------------------------------------------------------------------
  huc4 <- '0107'
  net <- sf::st_read(dsn = paste0(path_to_data, '/HUC2_', substr(huc4,1,2), '/NHDPLUS_H_', huc4, '_HU4_GDB/NHDPLUS_H_', huc4, '_HU4_GDB.gdb'), layer='NHDFlowline')
  net <- dplyr::left_join(net, net_0107_results, 'NHDPlusID')
  net <- dplyr::filter(net, is.na(perenniality)==0)
  name <- results[results$huc4 == huc4,]$name

  hydrography_0107 <- ggplot(net, aes(color=perenniality, size=Q_cms)) +
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
    ggtitle(paste0(name, ' River:\n', round(results[results$huc4 == huc4,]$QEph_exported_cms*86400*365*1e-9,1), ' km3/yr (', round(results[results$huc4 == huc4,]$percQ_eph,0), '%)'))

  ##RIVER NETWORK MAP 1406-------------------------------------------------------------------------------------------
  huc4 <- '1406'
  net <- sf::st_read(dsn = paste0(path_to_data, '/HUC2_', substr(huc4,1,2), '/NHDPLUS_H_', huc4, '_HU4_GDB/NHDPLUS_H_', huc4, '_HU4_GDB.gdb'), layer='NHDFlowline')
  net <- dplyr::left_join(net, net_1406_results, 'NHDPlusID')
  net <- dplyr::filter(net, is.na(perenniality)==0)
  name <- results[results$huc4 == huc4,]$name

  hydrography_1406 <- ggplot(net, aes(color=perenniality, size=Q_cms)) +
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
    ggtitle(paste0(name, ' River:\n', round(results[results$huc4 == huc4,]$QEph_exported_cms*86400*365*1e-9,1), ' km3/yr (', round(results[results$huc4 == huc4,]$percQ_eph,0), '%)'))

  ##RIVER NETWORK MAP 0701---------------------------------------------------------------------------
  huc4 <- '0701'
  net <- sf::st_read(dsn = paste0(path_to_data, '/HUC2_', substr(huc4,1,2), '/NHDPLUS_H_', huc4, '_HU4_GDB/NHDPLUS_H_', huc4, '_HU4_GDB.gdb'), layer='NHDFlowline')
  net <- dplyr::left_join(net, net_0701_results, 'NHDPlusID')
  net <- dplyr::filter(net, is.na(perenniality)==0)
  name <- results[results$huc4 == huc4,]$name

  hydrography_0701 <- ggplot(net, aes(color=perenniality, size=Q_cms)) +
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
    ggtitle(paste0(name, ':\n', round(results[results$huc4 == huc4,]$QEph_exported_cms*86400*365*1e-9,1), ' km3/yr (', round(results[results$huc4 == huc4,]$percQ_eph,0), '%)'))
  
##RIVER NETWORK MAP 1305-----------------------------------------------------------
  huc4 <- '1305'
  net <- sf::st_read(dsn = paste0(path_to_data, '/HUC2_', substr(huc4,1,2), '/NHDPLUS_H_', huc4, '_HU4_GDB/NHDPLUS_H_', huc4, '_HU4_GDB.gdb'), layer='NHDFlowline')
  net <- dplyr::left_join(net, net_1305_results, 'NHDPlusID')
  net <- dplyr::filter(net, is.na(perenniality)==0)
  name <- substr(results[results$huc4 == huc4,]$name,1,10)

  hydrography_1305 <- ggplot(net, aes(color=perenniality, size=Q_cms)) +
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
    ggtitle(paste0(name, ' Endorheic:\n', round(results[results$huc4 == huc4,]$QEph_exported_cms*86400*365*1e-9,1), ' km3/yr (', round(results[results$huc4 == huc4,]$percQ_eph,0), '%)'))
  
    ##EXTRACT SHARED LEGEND-----------------
    hydrography_legend <- cowplot::get_legend(hydrography_0107 +
                                                  labs(tag = '')+
                                                  theme(legend.position = "bottom",
                                                        legend.text = element_text(size=24),
                                                        legend.title = element_text(size=26, face='bold'),
                                                        legend.box="vertical",
                                                        legend.margin=margin(),
                                                        legend.spacing.x = unit(2, 'cm')) +
                                                  guides(color = guide_legend(override.aes = list(size=10))))

    ##BUILD PLOT----------------------------
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
    comboPlot <- patchwork::wrap_plots(A=results_map, B=hydrography_1305, C=hydrography_1406, D=hydrography_0107+theme(legend.position='none'), E=hydrography_0701, F=hydrography_legend, design=design)

   ggsave('cache/paper_figures/fig1.tiff', comboPlot, width=20, height=20, compression = "lzw", dpi=300)
   return('see cache/paper_figures/fig1.tiff')
}







#' create stream order results figure (fig 2)
#'
#' @name streamOrderPlot
#'
#' @param combined_results_by_order: df of model results per stream order
#' @param combined_results: df of model results
#'
#' @import dplyr
#' @import ggplot2
#' @import patchwork
#'
#' @return flowing days figure (also writes figure to file)
streamOrderPlot <- function(combined_results_by_order, combined_results){
  theme_set(theme_classic())
  
  #get regions sorted out for plotting------------------------------------------------------------
  combined_results_by_order$huc2 <- substr(combined_results_by_order$method, 18, 19)
  combined_results_by_order$huc4 <- substr(combined_results_by_order$method, 18, 21)
  east <- c('0101', '0102', '0103', '0104', '0105', '0106', '0107', '0108', '0109', '0110', #all basins east of the Mississippi River (determined visually)
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
  
  #remove great lakes and foreign basins
  keepHUCs <- combined_results[is.na(combined_results$num_flowing_dys)==0,]$huc4
  combined_results_by_order <- dplyr::filter(combined_results_by_order, huc4 %in% keepHUCs)
  
  ####SUMMARY STATS-------------------
  #summarise by stream order
  forPlot <- dplyr::group_by(combined_results_by_order, region, StreamOrde) %>%
    dplyr::summarise(percLength_eph_order = sum(LengthEph)/sum(LengthTotal))

  ####DISCHARGE PLOT--------------------
  plotQ <- ggplot(combined_results_by_order, aes(fill=region, x=factor(StreamOrde), y=percQEph_reach_median*100)) +
    geom_boxplot(color='black', size=1.2, alpha=0.25)+
    stat_summary(fun = mean,geom = 'line',aes(group = region, colour = region),position = position_dodge(width = 0.9), size=2)+
    stat_summary(fun = mean,geom = 'point',aes(group = region, colour = region),size=12, position = position_dodge(width = 0.9))+
    xlab('') +
    ylab('Median % ephemeral discharge')+
    scale_fill_manual(name='',
                      values=c('#2b3a67', '#b56b45'))+
    scale_color_manual(name='',
                       values=c('#2b3a67', '#b56b45'))+
    coord_cartesian(ylim=c(0,100))+
    labs(tag='A')+
    theme(axis.title = element_text(size=26, face='bold'),
          axis.text = element_text(size=24,face='bold'),
          plot.tag = element_text(size=26,
                                  face='bold'),
          legend.position='none',
          legend.text = element_text(size=24))

  ####AREA PLOT--------------------
  plotArea <- ggplot(combined_results_by_order, aes(fill=region, x=factor(StreamOrde), y=percAreaEph_reach_median*100)) +
    geom_boxplot(color='black', size=1.2, alpha=0.25)+
    stat_summary(fun = mean,geom = 'line',aes(group = region, colour = region),position = position_dodge(width = 0.9), size=2)+
    stat_summary(fun = mean,geom = 'point',aes(group = region, colour = region),size=12, position = position_dodge(width = 0.9))+
    xlab('') +
    ylab('Median % ephemeral drainage area')+
    scale_fill_manual(name='',
                      values=c('#2b3a67', '#b56b45'))+
    scale_color_manual(name='',
                       values=c('#2b3a67', '#b56b45'))+
    coord_cartesian(ylim=c(0,100))+
    labs(tag='B')+
    theme(axis.title = element_text(size=26, face='bold'),
          axis.text = element_text(size=24,face='bold'),
          plot.tag = element_text(size=26,
                                  face='bold'),
          legend.position='none')
  
  
  ####N PLOT--------------------
  plotN <- ggplot(forPlot, aes(color=region, x=factor(StreamOrde), y=percLength_eph_order*100, group=region)) +
    geom_line(size=3)+
    geom_point(size=18)+
    xlab('Stream Order') +
    ylab('% ephemeral streams by length')+
    scale_color_manual(name='',
                       values=c('#2b3a67', '#b56b45'))+
    coord_cartesian(ylim=c(0,100))+
    labs(tag='C')+
    theme(axis.title = element_text(size=26, face='bold'),
          axis.text = element_text(size=24,face='bold'),
          plot.tag = element_text(size=26,
                                  face='bold'),
          legend.position='bottom',
          legend.text = element_text(size=26))


  ##BUILD PLOT----------------------------
  design <- "
    AB
    CC
  "

  comboPlot <- patchwork::wrap_plots(A=plotQ, B=plotArea, C=plotN, design=design)
  
  ggsave('cache/paper_figures/fig2.png', comboPlot, width=20, height=20)
  ggsave('cache/paper_figures/fig2.tiff', comboPlot, width=20, height=20, compression = "lzw", dpi=300)
  return('see cache/paper_figures/fig2.tiff')
}











#' create ephemeral flow frequency paper figure (fig 3)
#'
#' @name flowingFigureFunction
#'
#' @param path_to_data: data repo directory path
#' @param shapefile_fin: final sf object with model results
#' @param joinedData: df of in situ Nflw data joined to HUC4 basins (for verification)
#'
#' @import sf
#' @import dplyr
#' @import ggplot2
#' @import patchwork
#'
#' @return flowing days figure (also writes figure to file)
flowingFigureFunction <- function(path_to_data, shapefile_fin, joinedData) {
  theme_set(theme_classic())
  
  ##GET DATA
  results <- shapefile_fin$shapefile
  results <- dplyr::filter(results, is.na(num_flowing_dys)==0)
  
  # CONUS boundary
  states <- sf::st_read(paste0(path_to_data, '/other_shapefiles/cb_2018_us_state_5m.shp'))
  states <- dplyr::filter(states, !(NAME %in% c('Alaska',
                                                'American Samoa',
                                                'Commonwealth of the Northern Mariana Islands',
                                                'Guam',
                                                'District of Columbia',
                                                'Puerto Rico',
                                                'United States Virgin Islands',
                                                'Hawaii'))) #remove non CONUS states/territories
  states <- sf::st_union(states)

  #round results
  joinedData$num_flowing_dys <- round(joinedData$num_flowing_dys,0)
  joinedData$n_flw_d <- round(joinedData$n_flw_d,0)

  #INSET MAP-----------------------------------------------
  cdf_inset <- ggplot(results, aes(num_flowing_dys))+ #modeled Nflw
    stat_ecdf(size=2, color='black') +
    xlab('Annual ephemeral flow\ndays')+
    ylab('Probability')+
    xlim(0,365)+
    theme(axis.title = element_text(size=20),
          axis.text = element_text(family="Futura-Medium", size=18),
          legend.position = 'none')
  
  ##MAIN MAP------------------------------------------
  flowingDaysFig <- ggplot(results) +
    geom_sf(aes(fill=num_flowing_dys), #modeled Nflw
            color='black',
            size=0.5) +
    scale_fill_gradientn(name='Annual ephemeral flow days',
                         colors = c("#9e2a2b", "white", "#2b2d42"),
                         guide = guide_colorbar(direction = "horizontal",title.position = "bottom"),
                         limits= c(0,365))+
    geom_sf(data=states,  #conus domain
            color='black',
            size=1.0,
            alpha=0)+
    geom_sf(data=joinedData,  #in situ data locations for model verification
            color='#564C4D',
            size=10,
            stroke=2)+
    labs(tag='A')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+
    theme(legend.position = c(.15, 0.10),
          legend.key.size = unit(2, 'cm'))+
    theme(text = element_text(family = "Futura-Medium"),
          legend.title = element_text(face = "bold", size = 20),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                                  face='bold'))+
    xlab('')+
    ylab('')
  
  ##VERIFICATION FIGURE------------------  
  flowingDaysVerifyFig <- ggplot(joinedData, aes(x=n_flw_d, y=num_flowing_dys))+
    geom_abline(size=2, linetype='dashed', color='darkgrey')+
    geom_point(size=12, color='#564C4D', alpha=0.35)+
    geom_smooth(method='lm', size=2, color='black', se=F)+
    annotate('text', label=expr(r^2: ~ !!round(summary(lm(num_flowing_dys~n_flw_d, data=joinedData))$r.squared,2)), x=50, y=350, size=9)+
    annotate('text', label=expr(SE: ~ !!round(summary(lm(num_flowing_dys~n_flw_d, data=joinedData))$sigma,0) ~ days), x=50, y=300, size=9)+
    annotate('text', label=paste0('n = ', nrow(joinedData), ' catchments'), x=250, y=50, size=9, color='black')+
    xlab('In situ days/yr')+
    ylab('Modeled days/yr')+
    coord_cartesian(ylim=c(0,365), xlim=c(0,365))+
    theme(axis.title = element_text(size=20),
      axis.text = element_text(family="Futura-Medium", size=18),
      legend.position = 'none')+
    labs(tag='B')+
    theme(axis.text=element_text(size=24),
          axis.title=element_text(size=26,face="bold"),
          plot.title = element_text(size = 30, face = "bold"),
          legend.position=c(0.85, 0.20),
          legend.text = element_text(family = "Futura-Medium", size = 26),
          legend.key = element_rect(fill = "grey"),
          plot.tag = element_text(size=26,
                                  face='bold'))
  
  ##ECDF VERIFICATION FIGURE------------------
  forPlot <- tidyr::gather(joinedData, key=key, value=value, c('num_flowing_dys', 'n_flw_d'))
  flowingDaysCDF <- ggplot(forPlot, aes(value, linetype=key))+
    stat_ecdf(size=2, color='#564C4D') +
    scale_linetype_manual(name='', labels=c('In situ', 'Modeled'), values=c('dotted', 'solid'))+
    xlab('Annual ephemeral flow days')+
    ylab('Probability')+
    xlim(0,365)+
    labs(tag='C')+
    theme(axis.text=element_text(size=24),
          axis.title=element_text(size=26,face="bold"),
          plot.title = element_text(size = 30, face = "bold"),
          legend.position=c(0.75, 0.20),
          legend.text = element_text(family = "Futura-Medium", size = 26),
          plot.tag = element_text(size=26,
                                  face='bold')) +
    guides(linetype=guide_legend(keywidth = 3, keyheight = 1))
  
  ##BUILD PLOT------------------------
  design <- "
   AAAA
   AAAA
   AAAA
   AAAA
   AAAA
   BBCC
   BBCC
   "
  
  flowingDaysFig <- flowingDaysFig + 
    patchwork::inset_element(cdf_inset, right = 0.975, bottom = 0.001, left = 0.775, top = 0.35)  
  comboPlot <- patchwork::wrap_plots(A=flowingDaysFig, B=flowingDaysVerifyFig, C=flowingDaysCDF, design=design)

  ggsave('cache/paper_figures/fig3.png', comboPlot, width=20, height=20)
  ggsave('cache/paper_figures/fig3.tiff', comboPlot, width=20, height=20, compression = "lzw", dpi=300)
  return('see cache/paper_figures/fig3.tiff')
}








#' create ephemeral network length paper figure (fig 4)
#'
#' @name lengthMapFunction
#'
#' @param path_to_data: data repo directory path
#' @param shapefile_fin: final sf object with model results
#'
#' @import sf
#' @import dplyr
#' @import ggplot2
#' @import patchwork
#'
#' @return ephemeral network length results figure (written to file- location print returned from this function)
lengthMapFunction <- function(path_to_data, shapefile_fin) {
  theme_set(theme_classic())
  
  ##GET DATA
  results <- shapefile_fin$shapefile
  results <- dplyr::filter(results, is.na(num_flowing_dys)==0) #remove great lakes
  
  # CONUS boundary
  states <- sf::st_read(paste0(path_to_data, '/other_shapefiles/cb_2018_us_state_5m.shp'))
  states <- dplyr::filter(states, !(NAME %in% c('Alaska',
                                                'American Samoa',
                                                'Commonwealth of the Northern Mariana Islands',
                                                'Guam',
                                                'District of Columbia',
                                                'Puerto Rico',
                                                'United States Virgin Islands',
                                                'Hawaii'))) #remove non CONUS states/territories
  states <- sf::st_union(states)
  
  #round results
  results$percLength_eph <- round(results$perc_length_eph*100,0) #setup percent

  #INSET MAP-----------------------------------------------
  cdf_inset <- ggplot(results, aes(percLength_eph))+
    stat_ecdf(size=2, color='black') +
    xlab('% ephemeral network\nextent')+
    ylab('Probability')+
    theme(axis.title = element_text(size=20),
          axis.text = element_text(family="Futura-Medium", size=18))+
    theme(legend.position = 'none')

  #LENGTH MAP-------------------------------------------------
  length_map <- ggplot(results) +
    geom_sf(aes(fill=percLength_eph), #map of % network length ephemeral
            color='black',
            size=0.5) +
    geom_sf(data=states,
            color='black',
            size=1.25,
            alpha=0)+
    scale_fill_gradientn(name='% ephemeral network extent',
                         colors=c('white', '#400406'),
                         limits=c(0,100),
                         guide = guide_colorbar(direction = "horizontal",
                                                title.position = "bottom"))+
    scale_color_brewer(name='',
                       palette='Dark2',
                       guide='none')+
    theme(axis.title = element_text(size=26, face='bold'),axis.text = element_text(family="Futura-Medium", size=20))+
    theme(legend.position = c(0.15, 0.1),
          legend.key.size = unit(2, 'cm'))+
    theme(text = element_text(family = "Futura-Medium"),
          legend.title = element_text(face = "bold", size = 18),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                                  face='bold'))+
    xlab('')+
    ylab('')
  
  #add inset
  length_map <- length_map + 
    patchwork::inset_element(cdf_inset, right = 0.975, bottom = 0.001, left = 0.775, top = 0.35)

  ggsave('cache/paper_figures/fig4.png', length_map, width=20, height=13)
  ggsave('cache/paper_figures/fig4.tiff', length_map, width=20, height=13, compression = "lzw", dpi=300)
  return('see cache/paper_figures/fig4.tiff')
}
