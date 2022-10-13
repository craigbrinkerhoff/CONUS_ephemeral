## Craig Brinkerhoff
## Summer 2022
## Functions for additional results figures that aren't created in 'src/paperFigures.R'. These are mostly troubleshooting figures and/or supplemental info figures



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
  
  ##ACCURACY MAP---------------------------------------------
  accuracyFig <- ggplot(results) +
    geom_sf(aes(fill=basinAccuracy), color='black', size=0.3) +
    geom_sf(data=states, color='black', size=1.5, alpha=0)+
    scale_fill_gradientn(name='Ephemeral classification accuracy',
                         colors =c("#d73027", "#ffffbf", "#4575b4"),
                         limits=c(0.60,1),
                         breaks=c(0.60, 0.65, 0.70, 0.75, 0.80,0.85, 0.90,0.95, 1.0),
                         guide = guide_legend(direction = "horizontal",title.position = "top"))+
    labs(tag='A')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(.2, 0.1))+ #legend position settings
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
                         guide = guide_legend(direction = "horizontal",title.position = "top"))+
    labs(tag='B')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(.2, 0.1))+ #legend position settings
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
  comboPlot <- patchwork::wrap_plots(A=accuracyFig, B=numberFig, design=design)
  
  ggsave('cache/validationMap.jpg', comboPlot, width=15, height=18)
  return('see cache/validationMap.jpg')
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
    ylab('Classification Accuracy [%]')+
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
    xlab('')+
    ylab('NHD Ungaged Flow')+
    geom_smooth(method='lm', size=1.5, color='black', se=F)+
    annotate('text', label=paste0('r2: ', round(summary(lm(log(QDMA)~log(Q_MA), data=assessmentDF))$r.squared,2)), x=0.001, y=175, size=9)+
    annotate('text', label=paste0('RMSE: ', round(Metrics::rmse(assessmentDF$QDMA, assessmentDF$Q_MA),1), ' m3/s'), x=0.01, y=950, size=9)+
    annotate('text', label=paste0(nrow(assessmentDF), ' gages'), x=100, y=0.001, size=7, color='darkblue')+
    scale_y_log10(breaks=c(0.0001, 0.001, 0.01, 0.1, 1, 10, 100,1000, 10000),
                  labels=c('0.0001', '0.001', '0.01', '0.1', '1', '10', '100', '1000', '10000'))+
    scale_x_log10(breaks=c(0.0001, 0.001, 0.01, 0.1, 1, 10, 100, 1000, 10000),
                  labels=c('0.0001','0.001', '0.01', '0.1', '1', '10', '100', '1000', '10000'))+
    theme(axis.text=element_text(size=20),
          axis.title=element_text(size=24,face="bold"),
          legend.text = element_text(size=17),
          plot.title = element_text(size = 30, face = "bold"))
  
  eromVerification_QEMA <- ggplot(assessmentDF, aes(x=Q_MA, y=QEMA)) +
    geom_abline(linetype='dashed', color='darkgrey', size=2)+
    geom_point(size=3, alpha=0.2, color='darkblue')+
    xlab('Observed Mean Annual Flow\n(1970-2018)')+
    ylab('NHD Gage Flow')+
    geom_smooth(method='lm', size=1.5, color='black', se=F)+
    annotate('text', label=paste0('r2: ', round(summary(lm(log(QEMA)~log(Q_MA), data=assessmentDF))$r.squared,2)), x=0.001, y=175, size=9)+
    annotate('text', label=paste0('RMSE: ', round(Metrics::rmse(assessmentDF$QEMA, assessmentDF$Q_MA),1), ' m3/s'), x=0.01, y=950, size=9)+
    annotate('text', label=paste0(nrow(assessmentDF), ' gages'), x=100, y=0.001, size=7, color='darkblue')+
    scale_y_log10(breaks=c(0.0001, 0.001, 0.01, 0.1, 1, 10, 100,1000, 10000),
                  labels=c('0.0001', '0.001', '0.01', '0.1', '1', '10', '100', '1000', '10000'))+
    scale_x_log10(breaks=c(0.0001, 0.001, 0.01, 0.1, 1, 10, 100, 1000, 10000),
                  labels=c('0.0001','0.001', '0.01', '0.1', '1', '10', '100', '1000', '10000'))+
    theme(axis.text=element_text(size=20),
          axis.title=element_text(size=24,face="bold"),
          legend.text = element_text(size=17),
          plot.title = element_text(size = 30, face = "bold"))
  
  plot_fin <- plot_grid(eromVerification_QDMA, eromVerification_QEMA, ncol=1)
  
  #write to file
  ggsave('cache/eromVerification.jpg', plot_fin, width=10, height=15)
  
  return(list('plot_fin'=plot_fin,
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
  
  plot <- ggplot(df, aes(x=StreamOrde, y=n, color=label)) +
    geom_point(size=8)+
    scale_x_continuous(limits = c(1, 7), breaks = c(1,2,3,4,5,6,7)) +
    scale_y_log10() +
    scale_color_brewer(palette='Dark2', name='')+
    ylab('# Field-Assessed Ephemeral Streams')+
    xlab('Stream Order + # Scaled Orders')+
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
  results$losing <- ifelse(round(results$percQ_eph,2) > 1, 'Losing Basins', 'Not Losing Basins')
  
  #MAIN MAP-------------------------------------------------
  results_map <- ggplot(results) +
    geom_sf(aes(fill=losing), #actual map
            color='black',
            size=0.5) +
    geom_sf(data=states,
            color='black',
            size=1.25,
            alpha=0)+
    scale_fill_brewer(name='',
                       palette='Dark2')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(.20, 0.05))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 20),
          legend.text = element_text(family = "Futura-Medium", size = 18))+
    guides(fill = guide_legend(nrow = 1))+
    xlab('')+
    ylab('')
  
  ggsave('cache/losingBasins.jpg', results_map, width=20, height=15)
  return('see cache/losingBasins.jpg')
}