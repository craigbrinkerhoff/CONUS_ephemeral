## Craig Brinkerhoff
## Summer 2022
## Functions for additional results figures that aren't created in 'src/paperFigures.R'. These are mostly troubleshooting figures and/or supplemental info figures



#' create main validation paper figure
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
  
  results$basinTSS <- round(results$basinTSS, 2)
  
  ##TSS MAP---------------------------------------------
  tssFig <- ggplot(results) +
    geom_sf(aes(fill=basinTSS), #actual map
            color='black',
            size=0.5)+
    geom_sf(data=states, #conus boundary
            color='black',
            size=1.25,
            alpha=0)+
    scale_fill_gradientn(name='Ephemeral TSS Score',
                         colors =c("#d73027", "#ffffbf", "#4575b4"),
                         #limits=c(60,100),
                         #breaks=c(60,65,70,75,80,85,90,95, 100),
                         guide = guide_colorbar(direction = "horizontal",title.position = "top"))+
    labs(tag='A')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(.2, 0.125),
          legend.key.size = unit(2, 'cm'))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 18),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                                  face='bold'),
          legend.box.background = element_rect(colour = "black"))+
    xlab('')+
    ylab('')
  
  ##NUMBER MAP------------------------------------------------
  numberFig <- ggplot(results) +
    geom_sf(aes(fill=n_total), color='black', size=0.3) +
    geom_sf(data=states, color='black', size=1.5, alpha=0)+
    scale_fill_gradientn(name='Number Observations',
                         colors =c("#dadaeb", "#807dba", "#3f007d"),
                         limits=c(59,1156),
                         breaks=c(59,300,600,900,1156),
                         guide = guide_colorbar(direction = "horizontal",title.position = "top"))+
    labs(tag='B')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(.2, 0.125),
          legend.key.size = unit(2, 'cm'))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 18),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                                  face='bold'),
          legend.box.background = element_rect(colour = "black"))+
    xlab('')+
    ylab('')
  
  ##COMBO PLOT------------------------------
  design <- "
  A
  B
  "
  comboPlot <- patchwork::wrap_plots(A=tssFig, B=numberFig, design=design)
  
  ggsave('cache/validationMap.jpg', comboPlot, width=15, height=18)
  return('see cache/validationMap.jpg')
}




#' create main validation paper figure number 2
#'
#' @name mappingValidationFigure2
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
mappingValidationFigure2 <- function(val_shapefile_fin){
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
  
  results$basinSensitivity <- round(results$basinSensitivity*100, 0)
  results$basinSpecificity <- round(results$basinSpecificity*100, 0)
  
  ##Sensitivity MAP---------------------------------------------
  sensFig <- ggplot(results) +
    geom_sf(aes(fill=basinSensitivity), #actual map
            color='black',
            size=0.5)+
    geom_sf(data=states, #conus boundary
            color='black',
            size=1.25,
            alpha=0)+
    scale_fill_gradientn(name='Ephemeral Classification Sensitivity',
                         colors =c("#d73027", "#ffffbf", "#4575b4"),
                         limits=c(45,100),
                         guide = guide_colorbar(direction = "horizontal",title.position = "top"))+
    labs(tag='A')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(.2, 0.125),
          legend.key.size = unit(2, 'cm'))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 18),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                                  face='bold'),
          legend.box.background = element_rect(colour = "black"))+
    xlab('')+
    ylab('')
  
  ##Specificity MAP------------------------------------------------
  specFig <- ggplot(results) +
    geom_sf(aes(fill=basinSpecificity), color='black', size=0.3) +
    geom_sf(data=states, color='black', size=1.5, alpha=0)+
    scale_fill_gradientn(name='Ephemeral Classification Specificity',
                         colors =c("#d73027", "#ffffbf", "#4575b4"),
                         limits=c(45,100),
                         guide = guide_colorbar(direction = "horizontal",title.position = "top"))+
    labs(tag='B')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(.2, 0.125),
          legend.key.size = unit(2, 'cm'))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 18),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                                  face='bold'),
          legend.box.background = element_rect(colour = "black"))+
    xlab('')+
    ylab('')
  
  ##COMBO PLOT------------------------------
  design <- "
  A
  B
  "
  comboPlot <- patchwork::wrap_plots(A=sensFig, B=specFig, design=design)
  
  ggsave('cache/validationMap2.jpg', comboPlot, width=15, height=18)
  return('see cache/validationMap2.jpg')
}




#' Makes boxplot summarizing classification results
#'
#' @name boxPlots_classification
#'
#' @param val_shapefile_fin: HUC2 validation shapefile
#'
#' @import ggplot2
#' @import tidyr
#'
#' @return figure showing reional clasification performance across accuracy metrics (also writes this to file)
boxPlots_classification <- function(val_shapefile_fin){
  theme_set(theme_classic())

  df <- val_shapefile_fin$shapefile

  #discharge
  forPlot <- tidyr::gather(df, key=key, value=value, c('basinAccuracy', 'basinTSS', 'basinSensitivity', 'basinSpecificity'))
  boxplots <- ggplot(forPlot, aes(x=key, y=value, fill=key)) +
    geom_boxplot(color='black', size=1.25) +
    stat_summary(fun = mean, geom = "point", col = "darkred", size=8) +
    annotate('text', label=paste0('n = ', nrow(df), ' basins'), x=as.factor('basinSpecificity'), y=0.20, size=8)+
    scale_fill_brewer(palette='Set2') +
    scale_y_continuous(limits=c(-0.1,1), breaks=c(-0.1,0,0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1))+
    scale_x_discrete('', labels=c('Accuracy', 'Sensitivity', 'Specificity', 'TSS'))+
    ylab('Value') +
    theme(axis.text=element_text(size=20),
      axis.title=element_text(size=22,face="bold"),
      legend.text = element_text(size=17),
      legend.position='none',
      axis.text.x = element_text( angle=60,hjust = 1, size=20, color="black"))

  ggsave('cache/boxPlots_classification.jpg', boxplots, width=9, height=8)

  return(boxplots)
}


#' Makes boxplot summarizing 'sensitivity' results for number flowing days calculation
#'
#' @name boxPlots_sensitivity
#'
#' @param combined_numFlowingDays: aggregated and tabulated model results across all HUC4 basins
#' @param combined_numFlowingDays_low: aggregated and tabulated model results across all HUC4 basins using low runoff scenario
#' @param combined_numFlowingDays_high: aggregated and tabulated model results across all HUC4 basins using high runoff scenario
#' @param combined_numFlowingDays_med_low: aggregated and tabulated model results across all HUC4 basins using medium low runoff scenario
#' @param combined_numFlowingDays_med_high: aggregated and tabulated model results across all HUC4 basins using medium high runoff scenario
#'
#' @import dplyr
#' @import tidyr
#' @import ggplot2
#'
#' @return figure comparing the results across the three scanerios (also wirtes figure to file)
boxPlots_sensitivity <- function(combined_numFlowingDays, combined_numFlowingDays_low, combined_numFlowingDays_high, combined_numFlowingDays_med_low, combined_numFlowingDays_med_high){
  theme_set(theme_classic())

  combined_results <- data.frame('numFlowingDays'=combined_numFlowingDays,
                                 'znumFlowingDays_low'=combined_numFlowingDays_low,
                                 'anumFlowingDays_high'=combined_numFlowingDays_high,
                                 'ynumFlowingDays_med_low'=combined_numFlowingDays_med_low,
                                 'bnumFlowingDays_med_high'=combined_numFlowingDays_med_high)
  
  #discharge
  forPlot <- tidyr::gather(combined_results, key=key, value=value, c('numFlowingDays', 'znumFlowingDays_low', 'ynumFlowingDays_med_low', 'anumFlowingDays_high', 'bnumFlowingDays_med_high'))
  forPlot$key <- as.factor(forPlot$key)
  levels(forPlot$key) <- c('High runoff 1','High runoff 2', 'Model', 'Low runoff 2', 'Low runoff 1')

  boxplotsSens <- ggplot(forPlot, aes(x=key, y=value, fill=key)) +
    geom_boxplot(color='black', size=1.25) +
    stat_summary(fun = mean, geom = "point", col = "darkred", size=8) +
    annotate('text', label=paste0('n = ', nrow(combined_results), ' basins'), x=as.factor('Model'), y=75, size=8)+
    scale_fill_brewer(palette='BrBG') +
    ylab('Mean Annual ephemeral days flowing [dys]') +
    xlab('')+
    theme(axis.text=element_text(size=20),
      axis.title=element_text(size=22,face="bold"),
      legend.text = element_text(size=17),
      legend.position='none',
      axis.text.x = element_text(angle = 65, hjust=1))

  ggsave('cache/boxPlots_sensitivity.jpg', boxplotsSens, width=10, height=10)
  return(boxplotsSens)
}



#' Makes plots for snapping threshold senstivity analysis
#'
#' @name snappingSensitivityFigures
#'
#' @param sensResults: df containing sensitivity analysis results
#'
#' @import tidyr
#' @import ggplot2
#'
#' @return figures plotting sensitivity results (also written to file)
snappingSensitivityFigures <- function(out){  #tradeoff plot between horton law of stream numbers and snapping thresholds
  theme_set(theme_classic())

  forPlot <- dplyr::distinct(out, mae, .keep_all=TRUE) #drop duplicate rows that are needed to accuracy Plot
  forPlot <- tidyr::gather(forPlot, key=key, value=value, c('mae', 'ephMinOrder'))
  tradeOffPlot <- ggplot(forPlot, aes(thresh, value, color=key)) +
        geom_point(size=7) +
        geom_line(linetype='dashed', size=1) +
        scale_color_brewer(palette='Accent', name='', labels=c('# Scaled Orders', 'MAE of log(N)'))+
        xlab('Snapping Threshold [m]') +
        ylab('Value')+
        theme(axis.text=element_text(size=20),
          axis.title=element_text(size=22,face="bold"),
          legend.text = element_text(size=17),
          legend.position='bottom')
  ggsave('cache/snappingThreshTradeOff.jpg', tradeOffPlot, width=9, height=8)

  #check sensitivity of classification accuracy to snapping threshold
  accuracyPlot <- ggplot(out, aes(x=factor(thresh), y=basinAccuracy.basinAccuracy*100, fill=factor(thresh))) +
    geom_boxplot(size=1.75, color='black', color='lightblue') +
    stat_summary(fun = mean, geom = "point", col = "darkred", size=6) +
    scale_fill_brewer(palette='Set3')+
    xlab('Snapping Threshold [m]') +
    ylab('Epehemeral Classification Accuracy [%]')+
    ylim(0,100)+
    theme(axis.text=element_text(size=20),
      axis.title=element_text(size=22,face="bold"),
      legend.position = 'none')
  ggsave('cache/acc_sens_to_snapping.jpg', accuracyPlot, width=9, height=8)

  return(list('tradeOffPlot'=tradeOffPlot,
              'accuracyPlot'=accuracyPlot))
}

#' Build figure showing determination of runoff threshold (and comparison against geomorphic model)
#'
#' @name runoffThreshCalibPlot
#'
#' @param calibResults: df of runoff threshold calibration results
#' @param theoreticalThresholds: vector of by basin runoff thresholds calculated via geomorphic scaling
#'
#' @import ggplot2
#'
#' @return ggplot showing claibration (also writes fig to file)
runoffThreshCalibPlot <- function(calibResults, theoreticalThresholds){
  theme_set(theme_classic())
  
  df <- data.frame('theoreticalThresholds'=theoreticalThresholds)

  plot <- ggplot(calibResults, aes(x=thresh, y=mae)) +
    geom_line(linetype='dashed', size=1.2, color='darkblue') +
    geom_point(size=8, color='darkblue') +
    ylab('Number Flowing Days\nMean Absolute Error [dys]') +
    xlab('Runoff threshold (global calibration) [mm/dy]')+
    scale_x_log10()+
    labs(tag='A')+
    theme(axis.text=element_text(size=20),
      axis.title=element_text(size=22,face="bold"),
      legend.text = element_text(size=17),
      plot.title = element_text(size = 30, face = "bold"),
      legend.position='none',
      plot.tag = element_text(size=26,
                              face='bold'))
  
  plot2 <- ggplot(df, aes(theoreticalThresholds)) +
    geom_density(size=1.25, color='black', fill='lightgreen') +
    scale_x_log10(limits=c(0.001, 1))+
    labs(tag='B')+
    xlab('Runoff threshold (estimated via theory per basin) [mm/dy]') +
    ylab('Density')+
    theme(axis.text=element_text(size=20),
          axis.title=element_text(size=22,face="bold"),
          legend.text = element_text(size=17),
          plot.title = element_text(size = 30, face = "bold"),
          legend.position='none',
          plot.tag = element_text(size=26,
                                  face='bold'))
  
  
  ##COMBO PLOT
  design <- "
    AAAA
    AAAA
    AAAA
    AAAA
    BBBB
    "
  comboPlot <- patchwork::wrap_plots(A=plot, B=plot2, design=design)
  
  ggsave('cache/runoffThresh_fitting.jpg', comboPlot, width=12, height=10)
  return(plot)
}



#' Builds discharge verification figure for all gaged NHD reaches (that pass USGS QC/QC) eventually used in model validation
#'
#' @name eromVerification
#'
#' @param USGS_data: df of USGS gauges and observed mean annual flow
#' @param nhdGages: df lookup table of NHD reaches and their respective gauge IDs (and modeled streamflow)
#'
#' @import tidyr
#' @import dplyr
#' @import ggplot2
#' @import cowplot
#'
#' @return streamflow validation plot (also writes to file)
eromVerification <- function(USGS_data, nhdGages){
  theme_set(theme_classic())

  #add observed meann anual Q (1970-2018 calculated using gage records) to the NHD reaches for erom validation
  qma <- USGS_data
  qma <- dplyr::select(qma, c('gageID','Q_MA'))
  assessmentDF <- dplyr::left_join(nhdGages, qma, by=c('GageIDMA' = 'gageID'))

  #save number of gauges to file for later reference
  write_rds(list('gages_w_sufficent_data'=nrow(qma),
                 'gages_on_nhd'=nrow(assessmentDF)),
                 'cache/gageNumbers.rds')

  assessmentDF <- tidyr::drop_na(assessmentDF)
  
  model_se <- summary(lm(log(QDMA)~log(Q_MA), data=assessmentDF))$sigma #model standard error

  eromVerification_QDMA <- ggplot(assessmentDF, aes(x=Q_MA, y=QDMA)) +
    geom_abline(linetype='dashed', color='darkgrey', size=2)+
    geom_point(size=3, alpha=0.2, color='darkblue')+
    xlab('Observed Mean Annual Flow\n(1970-2018)')+
    ylab('USGS Discharge Model')+
    geom_smooth(method='lm', size=1.5, color='black', se=F)+
    annotate('text', label=paste0('r2: ', round(summary(lm(log(QDMA)~log(Q_MA), data=assessmentDF))$r.squared,2)), x=0.01, y=175, size=9)+
    annotate('text', label=paste0('MAE: ', round(Metrics::mae(assessmentDF$QDMA, assessmentDF$Q_MA),1), ' m3/s'), x=0.01, y=950, size=9)+
    annotate('text', label=paste0(nrow(assessmentDF), ' gages'), x=100, y=0.001, size=7, color='darkblue')+
    scale_y_log10(breaks=c(0.0001, 0.001, 0.01, 0.1, 1, 10, 100,1000, 10000),
                  labels=c('0.0001', '0.001', '0.01', '0.1', '1', '10', '100', '1000', '10000'))+
    scale_x_log10(breaks=c(0.0001, 0.001, 0.01, 0.1, 1, 10, 100, 1000, 10000),
                  labels=c('0.0001','0.001', '0.01', '0.1', '1', '10', '100', '1000', '10000'))+
    theme(axis.text=element_text(size=20),
          axis.title=element_text(size=24,face="bold"),
          legend.text = element_text(size=17),
          plot.title = element_text(size = 30, face = "bold"))
  
  # eromVerification_QEMA <- ggplot(assessmentDF, aes(x=Q_MA, y=QEMA)) +
  #   geom_abline(linetype='dashed', color='darkgrey', size=2)+
  #   geom_point(size=3, alpha=0.2, color='darkblue')+
  #   xlab('Observed Mean Annual Flow\n(1970-2018)')+
  #   ylab('NHD Gage Flow')+
  #   geom_smooth(method='lm', size=1.5, color='black', se=F)+
  #   annotate('text', label=paste0('r2: ', round(summary(lm(log(QEMA)~log(Q_MA), data=assessmentDF))$r.squared,2)), x=0.001, y=175, size=9)+
  #   annotate('text', label=paste0('MAE: ', round(Metrics::mae(assessmentDF$QEMA, assessmentDF$Q_MA),1), ' m3/s'), x=0.01, y=950, size=9)+
  #   annotate('text', label=paste0(nrow(assessmentDF), ' gages'), x=100, y=0.001, size=7, color='darkblue')+
  #   scale_y_log10(breaks=c(0.0001, 0.001, 0.01, 0.1, 1, 10, 100,1000, 10000),
  #                 labels=c('0.0001', '0.001', '0.01', '0.1', '1', '10', '100', '1000', '10000'))+
  #   scale_x_log10(breaks=c(0.0001, 0.001, 0.01, 0.1, 1, 10, 100, 1000, 10000),
  #                 labels=c('0.0001','0.001', '0.01', '0.1', '1', '10', '100', '1000', '10000'))+
  #   theme(axis.text=element_text(size=20),
  #         axis.title=element_text(size=24,face="bold"),
  #         legend.text = element_text(size=17),
  #         plot.title = element_text(size = 30, face = "bold"))
  
 # plot_fin <- plot_grid(eromVerification_QDMA, eromVerification_QEMA, ncol=1)
  
  #write to file
  ggsave('cache/eromVerification.jpg', eromVerification_QDMA, width=10, height=10)
  
  return(list('plot_fin'=eromVerification_QDMA,
              'model_se'=model_se))
}



#' create figure detailing Hortonian ephemeral scaling
#'
#' @name buildScalingModelFig
#'
#' @param scalingModel: scaling model calculations object
#'
#' @return figure for explaining Hortonian scaling
buildScalingModelFig <- function(scalingModel){
  theme_set(theme_classic())
  
  df <- scalingModel$df
  df$label <- 'Field data on hydrography'
  df$StreamOrde <- df$StreamOrde + (1-scalingModel$ephMinOrder)
  df2 <- data.frame('StreamOrde'=1-scalingModel$ephMinOrder, #add on that we are scaling to
                    'n'=scalingModel$desiredFreq,
                    'label'='Field data off hydrography')
  df <- rbind(df, df2)
  
  plot <- ggplot(df, aes(x=StreamOrde-1, y=n, color=label)) +
    geom_point(size=8)+
    scale_x_continuous(limits = c(0, 6), breaks = c(0,1,2,3,4,5,6)) +
    scale_y_log10() +
    scale_color_brewer(palette='Dark2', name='')+
    ylab('# Field-Assessed Ephemeral Streams')+
    xlab('Hydrography Stream Order')+
    theme(axis.text=element_text(size=20),
          axis.title=element_text(size=22,face="bold"),
          legend.text = element_text(size=17),
          plot.title = element_text(size = 30, face = "bold"),
          legend.position='bottom')
  
  ggsave('cache/scalingModel.jpg', plot, width=9, height=8)
  return(plot)
}





#' create ephemeral losing stream basin figure
#'
#' @name losingStreamMap
#'
#' @param shapefile_fin: final sf object with model results
#'
#' @import sf
#' @import dplyr
#' @import ggplot2
#' @import cowplot
#'
#' @return losing basim figure (also writes figure to file)
losingStreamMap <- function(shapefile_fin){
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
  #states <- st_union(states)
  
  #setup
  results$losing <- ifelse(round(results$percQ_eph,2) > 1, 'Non-ephemeral contribution < 0 m3/yr', 'Non-ephemeral contribution > 0 m3/yr')
  
  #MAIN MAP-------------------------------------------------
  results_map <- ggplot(results) +
    geom_sf(aes(fill=losing), #actual map
            color='black',
            size=0.5) +
    geom_sf(data=states,
            color='black',
            size=1.25,
            alpha=0)+
    scale_fill_brewer(name='Basin-wide losing streamflow conditions',
                       palette='Accent')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(.20, 0.05))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 20),
          legend.text = element_text(family = "Futura-Medium", size = 18))+
    xlab('')+
    ylab('')
  
  ggsave('cache/losingBasins.jpg', results_map, width=20, height=15)
  return('see cache/losingBasins.jpg')
}




#' create ephemeral discharge vs river size plot
#'
#' @name hydrographyFigure
#'
#' @param shapefile_fin: final model results shapefile
#' @param many many river networks
#'
#' @import sf
#' @import dplyr
#' @import ggplot2
#' @import cowplot
#'
#' @return writes to file
hydrographyFigure <- function(shapefile_fin, net_0108_results, net_1023_results, net_0313_results, net_1503_results,
                              net_1306_results, net_0804_results, net_0501_results, net_1703_results,
                              net_0703_results, net_0304_results, net_1605_results, net_1507_results,
                              net_0317_results, net_0506_results, net_0103_results, net_1709_results){
  theme_set(theme_classic())
  
  ##GET DATA--------------------------------
  results <- shapefile_fin$shapefile
  
  ##RIVER NETWORK MAP 0108-------------------------------------------------------------------------------------
  net_0108 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_01/NHDPLUS_H_0108_HU4_GDB/NHDPLUS_H_0108_HU4_GDB.gdb', layer='NHDFlowline')
  net_0108 <- dplyr::left_join(net_0108, net_0108_results, 'NHDPlusID')
  net_0108 <- dplyr::filter(net_0108, is.na(perenniality)==0)
  
  #recast as non-ephemeral for visualization's sake
  net_0108$perenniality <- ifelse(net_0108$perenniality == 'foreign', 'non_ephemeral', net_0108$perenniality)
  
  hydrography_0108 <- ggplot(net_0108, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#f18f01','#006e90'),
                       labels=c('Ephemeral','Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='A')+
    theme(plot.title = element_text(face = "italic", size = 26),
          plot.tag = element_text(size=26,
                                  face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Connecticut River:\n', round(results[results$huc4 == '0108',]$totalephemeralQ_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '0108',]$percQ_eph*100,0), '%)'))
  
  ##RIVER NETWORK MAP 1023-------------------------------------------------------------------------------------
  net_1023 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_10/NHDPLUS_H_1023_HU4_GDB/NHDPLUS_H_1023_HU4_GDB.gdb', layer='NHDFlowline')
  net_1023 <- dplyr::left_join(net_1023, net_1023_results, 'NHDPlusID')
  net_1023 <- dplyr::filter(net_1023, is.na(perenniality)==0)
  
  #recast as non-ephemeral for visualization's sake
  net_1023$perenniality <- ifelse(net_1023$perenniality == 'foreign', 'non_ephemeral', net_1023$perenniality)
  
  hydrography_1023 <- ggplot(net_1023, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#f18f01','#006e90'),
                       labels=c('Ephemeral','Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='B')+
    theme(plot.title = element_text(face = "italic", size = 26),
          legend.position='none',
          plot.tag = element_text(size=26,
                                  face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Missouri/Little Sioux\nRiver: ', round(results[results$huc4 == '1023',]$totalephemeralQ_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '1023',]$percQ_eph*100,0), '%)'))
  
  
  ##RIVER NETWORK MAP 0313-------------------------------------------------------------------------------------
  net_0313 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_03/NHDPLUS_H_0313_HU4_GDB/NHDPLUS_H_0313_HU4_GDB.gdb', layer='NHDFlowline')
  net_0313 <- dplyr::left_join(net_0313, net_0313_results, 'NHDPlusID')
  net_0313 <- dplyr::filter(net_0313, is.na(perenniality)==0)
  
  #recast as non-ephemeral for visualization's sake
  net_0313$perenniality <- ifelse(net_0313$perenniality == 'foreign', 'non_ephemeral', net_0313$perenniality)
  
  hydrography_0313 <- ggplot(net_0313, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#f18f01','#006e90'),
                       labels=c('Ephemeral','Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='C')+
    theme(plot.title = element_text(face = "italic", size = 26),
          legend.position='none',
          plot.tag = element_text(size=26,
                                  face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Apalachicola River:\n', round(results[results$huc4 == '0313',]$totalephemeralQ_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '0313',]$percQ_eph*100,0), '%)'))
  
  
  ##RIVER NETWORK MAP 1503-------------------------------------------------------------------------------------
  net_1503 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_15/NHDPLUS_H_1503_HU4_GDB/NHDPLUS_H_1503_HU4_GDB.gdb', layer='NHDFlowline')
  net_1503 <- dplyr::left_join(net_1503, net_1503_results, 'NHDPlusID')
  net_1503 <- dplyr::filter(net_1503, is.na(perenniality)==0)
  
  #recast as non-ephemeral for visualization's sake
  net_1503$perenniality <- ifelse(net_1503$perenniality == 'foreign', 'non_ephemeral', net_1503$perenniality)
  
  hydrography_1503 <- ggplot(net_1503, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#f18f01','#006e90'),
                       labels=c('Ephemeral','Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='D')+
    theme(plot.title = element_text(face = "italic", size = 26),
          legend.position='none',
          plot.tag = element_text(size=26,
                                  face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Lower Colorado River:\n', round(results[results$huc4 == '1503',]$totalephemeralQ_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '1503',]$percQ_eph*100,0), '%)'))
  
  ##RIVER NETWORK MAP 1306-------------------------------------------------------------------------------------
  net_1306 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_13/NHDPLUS_H_1306_HU4_GDB/NHDPLUS_H_1306_HU4_GDB.gdb', layer='NHDFlowline')
  net_1306 <- dplyr::left_join(net_1306, net_1306_results, 'NHDPlusID')
  net_1306 <- dplyr::filter(net_1306, is.na(perenniality)==0)
  
  #recast as non-ephemeral for visualization's sake
  net_1306$perenniality <- ifelse(net_1306$perenniality == 'foreign', 'non_ephemeral', net_1306$perenniality)
  
  hydrography_1306 <- ggplot(net_1306, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#f18f01','#006e90'),
                       labels=c('Ephemeral','Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='E')+
    theme(plot.title = element_text(face = "italic", size = 26),
          legend.position='none',
          plot.tag = element_text(size=26,
                                  face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Upper Pecos River:\n', round(results[results$huc4 == '1306',]$totalephemeralQ_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '1306',]$percQ_eph*100,0), '%)'))
  
  
  ##RIVER NETWORK MAP 0804-------------------------------------------------------------------------------------
  net_0804 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_08/NHDPLUS_H_0804_HU4_GDB/NHDPLUS_H_0804_HU4_GDB.gdb', layer='NHDFlowline')
  net_0804 <- dplyr::left_join(net_0804, net_0804_results, 'NHDPlusID')
  net_0804 <- dplyr::filter(net_0804, is.na(perenniality)==0)
  
  #recast as non-ephemeral for visualization's sake
  net_0804$perenniality <- ifelse(net_0804$perenniality == 'foreign', 'non_ephemeral', net_0804$perenniality)
  
  hydrography_0804 <- ggplot(net_0804, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#f18f01','#006e90'),
                       labels=c('Ephemeral','Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='F')+
    theme(plot.title = element_text(face = "italic", size = 26),
          legend.position='none',
          plot.tag = element_text(size=26,
                                  face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Lower Red/Ouachita\nRiver: ', round(results[results$huc4 == '0804',]$totalephemeralQ_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '0804',]$percQ_eph*100,0), '%)'))
  
  ##RIVER NETWORK MAP 0501-------------------------------------------------------------------------------------
  net_0501 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_05/NHDPLUS_H_0501_HU4_GDB/NHDPLUS_H_0501_HU4_GDB.gdb', layer='NHDFlowline')
  net_0501 <- dplyr::left_join(net_0501, net_0501_results, 'NHDPlusID')
  net_0501 <- dplyr::filter(net_0501, is.na(perenniality)==0)
  
  #recast as non-ephemeral for visualization's sake
  net_0501$perenniality <- ifelse(net_0501$perenniality == 'foreign', 'non_ephemeral', net_0501$perenniality)
  
  hydrography_0501 <- ggplot(net_0501, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#f18f01','#006e90'),
                       labels=c('Ephemeral','Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='G')+
    theme(plot.title = element_text(face = "italic", size = 26),
          legend.position='none',
          plot.tag = element_text(size=26,
                                  face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Allegheny River:\n', round(results[results$huc4 == '0501',]$totalephemeralQ_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '0501',]$percQ_eph*100,0), '%)'))
  
  
  ##RIVER NETWORK MAP 1703-------------------------------------------------------------------------------------
  net_1703 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_17/NHDPLUS_H_1703_HU4_GDB/NHDPLUS_H_1703_HU4_GDB.gdb', layer='NHDFlowline')
  net_1703 <- dplyr::left_join(net_1703, net_1703_results, 'NHDPlusID')
  net_1703 <- dplyr::filter(net_1703, is.na(perenniality)==0)
  
  #recast as non-ephemeral for visualization's sake
  net_1703$perenniality <- ifelse(net_1703$perenniality == 'foreign', 'non_ephemeral', net_1703$perenniality)
  
  hydrography_1703 <- ggplot(net_1703, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#f18f01','#006e90'),
                       labels=c('Ephemeral','Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='H')+
    theme(plot.title = element_text(face = "italic", size = 26),
          legend.position='none',
          plot.tag = element_text(size=26,
                                  face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Yakima River:\n', round(results[results$huc4 == '1703',]$totalephemeralQ_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '1703',]$percQ_eph*100,0), '%)'))
  
  
  ##RIVER NETWORK MAP 0703-------------------------------------------------------------------------------------
  net_0703 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_07/NHDPLUS_H_0703_HU4_GDB/NHDPLUS_H_0703_HU4_GDB.gdb', layer='NHDFlowline')
  net_0703 <- dplyr::left_join(net_0703, net_0703_results, 'NHDPlusID')
  net_0703 <- dplyr::filter(net_0703, is.na(perenniality)==0)
  
  #recast as non-ephemeral for visualization's sake
  net_0703$perenniality <- ifelse(net_0703$perenniality == 'foreign', 'non_ephemeral', net_0703$perenniality)
  
  hydrography_0703 <- ggplot(net_0703, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#f18f01','#006e90'),
                       labels=c('Ephemeral','Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='I')+
    theme(plot.title = element_text(face = "italic", size = 26),
          legend.position='none',
          plot.tag = element_text(size=26,
                                  face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('St. Croix River:\n', round(results[results$huc4 == '0703',]$totalephemeralQ_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '0703',]$percQ_eph*100,0), '%)'))
  
  
  ##RIVER NETWORK MAP 0304-------------------------------------------------------------------------------------
  net_0304 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_03/NHDPLUS_H_0304_HU4_GDB/NHDPLUS_H_0304_HU4_GDB.gdb', layer='NHDFlowline')
  net_0304 <- dplyr::left_join(net_0304, net_0304_results, 'NHDPlusID')
  net_0304 <- dplyr::filter(net_0304, is.na(perenniality)==0)
  
  #recast as non-ephemeral for visualization's sake
  net_0304$perenniality <- ifelse(net_0304$perenniality == 'foreign', 'non_ephemeral', net_0304$perenniality)
  
  hydrography_0304 <- ggplot(net_0304, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#f18f01','#006e90'),
                       labels=c('Ephemeral','Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='J')+
    theme(plot.title = element_text(face = "italic", size = 26),
          legend.position='none',
          plot.tag = element_text(size=26,
                                  face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Pee Dee River:\n', round(results[results$huc4 == '0304',]$totalephemeralQ_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '0304',]$percQ_eph*100,0), '%)'))
  
  
  ##RIVER NETWORK MAP 1605-------------------------------------------------------------------------------------
  net_1605 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_16/NHDPLUS_H_1605_HU4_GDB/NHDPLUS_H_1605_HU4_GDB.gdb', layer='NHDFlowline')
  net_1605 <- dplyr::left_join(net_1605, net_1605_results, 'NHDPlusID')
  net_1605 <- dplyr::filter(net_1605, is.na(perenniality)==0)
  
  #recast as non-ephemeral for visualization's sake
  net_1605$perenniality <- ifelse(net_1605$perenniality == 'foreign', 'non_ephemeral', net_1605$perenniality)
  
  hydrography_1605 <- ggplot(net_1605, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#f18f01','#006e90'),
                       labels=c('Ephemeral','Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='K')+
    theme(plot.title = element_text(face = "italic", size = 26),
          legend.position='none',
          plot.tag = element_text(size=26,
                                  face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Central Lahontan River:\n', round(results[results$huc4 == '1605',]$totalephemeralQ_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '1605',]$percQ_eph*100,0), '%)'))
  
  
  
  ##RIVER NETWORK MAP 1507-------------------------------------------------------------------------------------
  net_1507 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_15/NHDPLUS_H_1507_HU4_GDB/NHDPLUS_H_1507_HU4_GDB.gdb', layer='NHDFlowline')
  net_1507 <- dplyr::left_join(net_1507, net_1507_results, 'NHDPlusID')
  net_1507 <- dplyr::filter(net_1507, is.na(perenniality)==0)
  
  #recast as non-ephemeral for visualization's sake
  net_1507$perenniality <- ifelse(net_1507$perenniality == 'foreign', 'non_ephemeral', net_1507$perenniality)
  
  hydrography_1507 <- ggplot(net_1507, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#f18f01','#006e90'),
                       labels=c('Ephemeral','Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='L')+
    theme(plot.title = element_text(face = "italic", size = 26),
          legend.position='none',
          plot.tag = element_text(size=26,
                                  face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Lower Gila River:\n', round(results[results$huc4 == '1507',]$totalephemeralQ_cms*86400*365*1e-9,2), ' km3/yr (', round(results[results$huc4 == '1507',]$percQ_eph*100,0), '%)'))
  
  
  ##RIVER NETWORK MAP 0317-------------------------------------------------------------------------------------
  net_0317 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_03/NHDPLUS_H_0317_HU4_GDB/NHDPLUS_H_0317_HU4_GDB.gdb', layer='NHDFlowline')
  net_0317 <- dplyr::left_join(net_0317, net_0317_results, 'NHDPlusID')
  net_0317 <- dplyr::filter(net_0317, is.na(perenniality)==0)
  
  #recast as non-ephemeral for visualization's sake
  net_0317$perenniality <- ifelse(net_0317$perenniality == 'foreign', 'non_ephemeral', net_0317$perenniality)
  
  hydrography_0317 <- ggplot(net_0317, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#f18f01','#006e90'),
                       labels=c('Ephemeral','Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='M')+
    theme(plot.title = element_text(face = "italic", size = 26),
          legend.position='none',
          plot.tag = element_text(size=26,
                                  face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Pascagoula River:\n', round(results[results$huc4 == '0317',]$totalephemeralQ_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '0317',]$percQ_eph*100,0), '%)'))
  
  
  ##RIVER NETWORK MAP 0506-------------------------------------------------------------------------------------
  net_0506 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_05/NHDPLUS_H_0506_HU4_GDB/NHDPLUS_H_0506_HU4_GDB.gdb', layer='NHDFlowline')
  net_0506 <- dplyr::left_join(net_0506, net_0506_results, 'NHDPlusID')
  net_0506 <- dplyr::filter(net_0506, is.na(perenniality)==0)
  
  #recast as non-ephemeral for visualization's sake
  net_0506$perenniality <- ifelse(net_0506$perenniality == 'foreign', 'non_ephemeral', net_0506$perenniality)
  
  hydrography_0506 <- ggplot(net_0506, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#f18f01','#006e90'),
                       labels=c('Ephemeral','Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='N')+
    theme(plot.title = element_text(face = "italic", size = 26),
          legend.position='none',
          plot.tag = element_text(size=26,
                                  face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Scioto River:\n', round(results[results$huc4 == '0506',]$totalephemeralQ_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '0506',]$percQ_eph*100,0), '%)'))
  
  
  ##RIVER NETWORK MAP 0103-------------------------------------------------------------------------------------
  net_0103 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_01/NHDPLUS_H_0103_HU4_GDB/NHDPLUS_H_0103_HU4_GDB.gdb', layer='NHDFlowline')
  net_0103 <- dplyr::left_join(net_0103, net_0103_results, 'NHDPlusID')
  net_0103 <- dplyr::filter(net_0103, is.na(perenniality)==0)
  
  #recast as non-ephemeral for visualization's sake
  net_0103$perenniality <- ifelse(net_0103$perenniality == 'foreign', 'non_ephemeral', net_0103$perenniality)
  
  hydrography_0103 <- ggplot(net_0103, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#f18f01','#006e90'),
                       labels=c('Ephemeral','Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='O')+
    theme(plot.title = element_text(face = "italic", size = 26),
          legend.position='none',
          plot.tag = element_text(size=26,
                                  face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Kennebec River:\n', round(results[results$huc4 == '0103',]$totalephemeralQ_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '0103',]$percQ_eph*100,0), '%)'))
  
  
  
  ##RIVER NETWORK MAP 1709-------------------------------------------------------------------------------------
  net_1709 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_17/NHDPLUS_H_1709_HU4_GDB/NHDPLUS_H_1709_HU4_GDB.gdb', layer='NHDFlowline')
  net_1709 <- dplyr::left_join(net_1709, net_1709_results, 'NHDPlusID')
  net_1709 <- dplyr::filter(net_1709, is.na(perenniality)==0)
  
  #recast as non-ephemeral for visualization's sake
  net_1709$perenniality <- ifelse(net_1709$perenniality == 'foreign', 'non_ephemeral', net_1709$perenniality)
  
  hydrography_1709 <- ggplot(net_1709, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#f18f01','#006e90'),
                       labels=c('Ephemeral','Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    labs(tag='P')+
    theme(plot.title = element_text(face = "italic", size = 26),
          legend.position='none',
          plot.tag = element_text(size=26,
                                  face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(paste0('Willamette River:\n', round(results[results$huc4 == '1709',]$totalephemeralQ_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '1709',]$percQ_eph*100,0), '%)'))
  
  
  ##EXTRACT SHARED LEGEND-----------------
  hydrography_legend <- cowplot::get_legend(
    hydrography_0108 +
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
    ABCD
    ABCD
    EFGH
    EFGH
    IJKL
    IJKL
    MNOP
    MNOP
    QQQQ
    "
  comboPlot <- patchwork::wrap_plots(A=hydrography_0108+theme(legend.position='none'), B=hydrography_1023, C=hydrography_0313, D=hydrography_1503,
                                     E=hydrography_1306, F=hydrography_0804, G=hydrography_0501, H=hydrography_1703,
                                     I=hydrography_0703, J=hydrography_0304, K=hydrography_1605, L=hydrography_1507,
                                     M=hydrography_0317, N=hydrography_0506, O=hydrography_0103, P=hydrography_1709,
                                     Q=hydrography_legend, design=design)
  
  ggsave('cache/hydrographyMaps.jpg', comboPlot, width=20, height=25)
  
  return('see cache/hydrographyMaps.jpg')
}