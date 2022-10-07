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
    scale_fill_gradientn(name='Classification Accuracy',
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





#' create main results paper figure (fig 1)
#'
#' @name flowingMapFigureFunction
#'
#' @param shapefile_fin: final sf object with model results
#'
#' @import sf
#' @import dplyr
#' @import ggplot2
#' @import cowplot
#'
#' @return main model results figure (also writes figure to file)
flowingMapFigureFunction <- function(shapefile_fin) {
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
  results <- dplyr::filter(results, is.na(percQ_eph_flowing_scaled)==0)
  results$percQ_eph_flowing_scaled <- results$percQ_eph_flowing_scaled * 100
  
  #bin all model results for mapping purposes (manual palette specification)
  results$perc_binned <- ifelse(results$percQ_eph_flowing_scaled <= 15, '0-15',
                                ifelse(results$percQ_eph_flowing_scaled <= 30, '15-30',
                                       ifelse(results$percQ_eph_flowing_scaled <= 45, '30-45',
                                              ifelse(results$percQ_eph_flowing_scaled <= 60, '45-60',
                                                     ifelse(results$percQ_eph_flowing_scaled <= 75, '60-75',
                                                            ifelse(results$percQ_eph_flowing_scaled <= 90, '75-90','90-100'))))))

  #HISTOGRAM INSET
  ephVolumeHist <- ggplot(results, aes(x=percQ_eph_flowing_scaled))+
    geom_histogram(color='black', fill='#cab2d6', size=1, bins = 20) +
    xlab('') +
    ylab('Count') +
    theme(axis.title = element_text(size=18, face='bold'),
          axis.text = element_text(size=15,face='bold'))

  #MAIN MAP-----------------------------------------------
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
    scale_fill_manual(name='% streamflow exported via U.S.\nephemeral streams when flowing',
                      values = c("#264653", "#2A9D8F", "#E9C46A", "#F4A261", "#EB886F", '#E76F51', '#E45C3A'),
                      breaks=c('0-15','15-30','30-45','45-60','60-75', '75-90', '90-100'), #palette color breaks for legend
                      guide = guide_legend(direction = "horizontal",
                                           title.position = "top"))+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(.25, 0.05))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 20),
          legend.text = element_text(family = "Futura-Medium", size = 18))+
    guides(fill = guide_legend(nrow = 1))+
    xlab('')+
    ylab('')

    ggsave('cache/flowingMap.jpg', results_map, width=20, height=15)
    return('see cache/flowingMap.jpg')
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

  forPlot <- tidyr::gather(out, key=key, value=value, c('mae', 'ephMinOrder'))
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

  #check sensitvity of classification accuracy to snapping threshold
  accuracyPlot <- ggplot(out, aes(thresh, basinAccuracy)) +
        geom_point(size=7, color='darkgreen') +
        geom_line(linetype='dashed', size=1, color='darkgreen') +
        geom_vline(xintercept=10, linetype='dashed', size=1)+
        xlab('Snapping Threshold [m]') +
        ylab('Classification Accuracy')+
        ylim(0,1)+
        theme(axis.text=element_text(size=20),
          axis.title=element_text(size=22,face="bold"),
          legend.text = element_text(size=17))
  ggsave('cache/acc_sens_to_snapping.jpg', accuracyPlot, width=9, height=8)

  return(list('tradeOffPlot'=tradeOffPlot,
              'accuracyPlot'=accuracyPlot))
}

#' Build figure showing determination of runoff threshold (and comparisonagainst geomorphic model)
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
  
  return(plot_fin)
}



#' Creates confusion matrix from ephemeral mapping validation exercise
#'
#' @name buildConfusionMatrix
#'
#' @param verifyDFfin: results of validation exercise
#'
#' @import caret
#' @import ggplot
#'
#' @return confusion matrix. Figure saved to file.
buildConfusionMatrix <- function(verifyDFfin){
  theme_set(theme_classic())
  
  cm <- as.data.frame(caret::confusionMatrix(factor(verifyDFfin$perenniality), factor(verifyDFfin$distinction))$table)
  cm$Prediction <- factor(cm$Prediction, levels=rev(levels(cm$Prediction)))
  
  cfMatrix <- ggplot(cm, aes(Reference, Prediction,fill=factor(Freq))) +
    geom_tile() +
    geom_text(aes(label=Freq), size=15)+
    scale_fill_manual(values=c('grey', 'grey', '#1b9e77', '#1b9e77')) +
    labs(x = "Observed Class",y = "Model Class") +
    scale_x_discrete(labels=c("Ephemeral","Not Ephemeral")) +
    scale_y_discrete(labels=c("Not Ephemeral","Ephemeral")) +
    theme(legend.position = "none",
          axis.text=element_text(size=24),
          axis.title=element_text(size=28,face="bold"),
          legend.text = element_text(size=17),
          legend.title = element_text(size=17, face='bold'))
  
  ggsave('cache/verify_cf.jpg', cfMatrix, width=10, height=8)
  write_csv(verifyDFfin, 'cache/validationResults.csv')
  
  return(cfMatrix)
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
