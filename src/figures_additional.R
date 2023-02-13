## Craig Brinkerhoff
## Winter 2023
## Functions for additional results figures that aren't created in 'src/paperFigures.R'. These are mostly troubleshooting figures and/or supplemental info figures




#' create primary validation plot for model
#'
#' @name validationPlot
#'
#' @param tokunaga_df: results from network length assessment
#' @param USGS_data: USGS mean annual flow observations at streamgauges
#' @param nhdGages: lookup table pairing USGS gauges to the NHD reaches
#' @param ephemeralQdataset: additional validation data for some ephemeral streams from USGS reports
#' @param walnutGulch: additional validation data for some ephemeral streams with in situ flume records in Walnut Gulch exp catchment
#' @param val_shapefile_fin: final sf object with ephemeral classification validation
#'
#' @import sf
#' @import dplyr
#' @import ggplot2
#' @import cowplot
#' @import patchwork
#'
#' @return combined Q validation df (also writes figure to file)
validationPlot <- function(tokunaga_df, USGS_data, nhdGages, ephemeralQDataset, walnutGulch, val_shapefile_fin){
  theme_set(theme_classic())
  
  
  #####VALIDATION MAP--------------------------------------------------------
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
  
  ##ACCURACY MAP
  accuracyFig <- ggplot(results) +
    geom_sf(aes(fill=basinAccuracy*100), #actual map
            color='black',
            size=0.5)+
    geom_sf(data=states, #conus boundary
            color='black',
            size=1.25,
            alpha=0)+
    scale_fill_gradientn(name='Ephemeral Classification Accuracy [%]',
                         colors =c('#d73027', 'white', "#4575b4"),
                         limits=c(0,100),
                         guide = guide_colorbar(direction = "horizontal",title.position = "top"))+
    labs(tag='A')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(.2, 0.125),
          legend.key.size = unit(2, 'cm'))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 18),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                                  face='bold'))+
    xlab('')+
    ylab('')
  
  
  #####TOKUNAGA ROUTING VERIFICATION---------------------------------------------------
  #dont plot the great lakes because the network scaling makes no sense
  forPlot <- dplyr::filter(tokunaga_df, !is.na(export))
  
  tokunagaPlot <- ggplot(forPlot, aes(x=export*100, y=percQEph_exported*100)) + 
    geom_abline(linetype='dashed', size=2, color='darkgrey') +
    geom_point(size=7, color='#335c67') +
    geom_smooth(method='lm', size=1.5, color='black', se=F)+
    xlim(0,100)+
    ylim(0,100)+
    ylab('% Discharge ephemeral\n(via routing model)') +
    xlab('% Upstream network ephemeral\n(via scaling theory)') +
    annotate('text', label=expr(r^2: ~ !!round(summary(lm(percQEph_exported~export, data=forPlot))$r.squared,2)), x=10, y=75, size=9)+
    annotate('text', label=paste0('n = ', nrow(forPlot), ' basins'), x=75, y=15, size=9, color='black')+
    labs(tage='C')+
    theme(axis.text=element_text(size=20),
          axis.title=element_text(size=24,face="bold"),
          legend.text = element_text(size=20),
          legend.position='bottom',
          plot.title = element_text(size = 30, face = "bold"),
          plot.tag = element_text(size=26,
                                  face='bold'))
  
  
  #####DISCHARGE VALIDATION-------------------------------------------------
  #rename walnut gulch discharge columes to match this df
  walnutGulch <- walnutGulch$df #grab data frame from list
  colnames(walnutGulch) <- c('NHDPlusID', 'Q_MA', 'drainageArea_km2', 'QBMA','ToTDASqKm')
  walnutGulch <- dplyr::select(as.data.frame(walnutGulch), c('Q_MA', 'QBMA')) %>%
    dplyr::mutate(type = 'Ephemeral/Intermittent')
  
  #rename ephemeral discharge columns to match this df
  colnames(ephemeralQDataset) <- c('NHDPlusID', 'huc4', 'Q_MA', 'drainageArea_km2', 'QBMA', 'num_flowing_dys','ToTDASqKm', 'gageID', 'errorFlag')
  ephemeralQDataset <- dplyr::select(ephemeralQDataset, c('Q_MA', 'QBMA')) %>%
    dplyr::mutate(type = 'Ephemeral/Intermittent')

  #now make plots!
  theme_set(theme_classic())
  
  #add observed mean annual Q (1970-2018 calculated using gage records) to the NHD reaches for erom validation
  qma <- USGS_data
  qma <- dplyr::select(qma, c('gageID','Q_MA', 'no_flow_fraction'))
  assessmentDF <- dplyr::left_join(nhdGages, qma, by=c('GageIDMA' = 'gageID'))
  
  assessmentDF <- tidyr::drop_na(assessmentDF) %>%
    dplyr::mutate(type = ifelse(no_flow_fraction >= 5/365, 'Ephemeral/Intermittent', 'Perennial')) %>% #Messager definition for non-perenniality is 1 day a year not flowing
    dplyr::select('Q_MA', 'QBMA', 'type')
  
  #join two datasets together
  assessmentDF <- rbind(assessmentDF, walnutGulch) #ephemeralQDataset
  assessmentDF$type <- factor(assessmentDF$type, levels = c("Perennial", "Ephemeral/Intermittent")) #recast to be copacetic
  
  assessmentDF <- dplyr::filter(assessmentDF, !(is.na(QBMA)) & !(is.na(Q_MA)))
  
  #Model plot
  eromVerification_QBMA <- ggplot(assessmentDF, aes(x=Q_MA, y=QBMA, color=type)) +
    geom_abline(linetype='dashed', color='darkgrey', size=2)+
    geom_point(size=4)+
    xlab('Observed Mean Annual Flow')+
    ylab('USGS Discharge Model')+
    geom_smooth(method='lm', size=1.5, color='black', se=F)+
    scale_color_manual(name='', values=c('#007E5D', '#E7C24B', '#775C04'))+
    annotate('text', label=expr(r^2: ~ !!round(summary(lm(log(QBMA)~log(Q_MA), data=assessmentDF))$r.squared,2)), x=0.01, y=175, size=9)+
    annotate('text', label=expr(MAE: ~ !!round(Metrics::mae(assessmentDF$QBMA, assessmentDF$Q_MA),1) ~ frac(m^3, s)), x=0.01, y=1000, size=9)+
    annotate('text', label=paste0('n = ', nrow(assessmentDF), ' streams'), x=100, y=0.001, size=9, color='black')+
    scale_y_log10(breaks=c(0.0001, 0.001, 0.01, 0.1, 1, 10, 100,1000, 10000),
                  labels=c('0.0001', '0.001', '0.01', '0.1', '1', '10', '100', '1000', '10000'))+
    scale_x_log10(breaks=c(0.0001, 0.001, 0.01, 0.1, 1, 10, 100, 1000, 10000),
                  labels=c('0.0001','0.001', '0.01', '0.1', '1', '10', '100', '1000', '10000'))+
    labs(tag='B')+
    theme(axis.text=element_text(size=20),
          axis.title=element_text(size=24,face="bold"),
          legend.text = element_text(size=20),
          legend.position='bottom',
          plot.title = element_text(size = 30, face = "bold"),
          plot.tag = element_text(size=26,
                                  face='bold'))
  
  ##COMBO PLOT------------------------
  design <- "
   AA
   AA
   AA
   BC
   BC
   "
  
  comboPlot <- patchwork::wrap_plots(A=accuracyFig, B=eromVerification_QBMA, C=tokunagaPlot, design=design)
  
  
  ggsave('cache/validationPlot.jpg', comboPlot, width=20, height=20)
  return(assessmentDF)
  
}





#' create main validation paper figure
#'
#' @name mappingValidationFigure
#'
#' @param val_shapefile_fin: final validation sf object with model results
#'
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
                         colors =c("#d73027", 'white', "#4575b4"), #ffffbf
                         limits=c(0,1),
                         guide = guide_colorbar(direction = "horizontal",title.position = "top"))+
    labs(tag='A')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(.2, 0.125),
          legend.key.size = unit(2, 'cm'))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 18),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                                  face='bold'))+
    xlab('')+
    ylab('')
  
  ##number MAP------------------------------------------------
  numberFig <- ggplot(results) +
    geom_sf(aes(fill=n_total), color='black', size=0.3) +
    geom_sf(data=states, color='black', size=1.5, alpha=0)+
    scale_fill_gradientn(name='Number Observations                ',
                         colors =c("#dadaeb", "#807dba", "#3f007d"),
                         limits=c(48,973),
                         breaks=c(48,300,600,973),
                         guide = guide_colorbar(direction = "horizontal",title.position = "top"))+
    labs(tag='C')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(0.2, 0.125),
          legend.key.size = unit(2, 'cm'))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 18),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                                  face='bold'))+
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
                         colors =c("#d73027", 'white',"#4575b4"), #ffffbf
                         limits=c(0,100),
                         guide = guide_colorbar(direction = "horizontal",title.position = "top"))+
    labs(tag='A')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(0.2, 0.125),
          legend.key.size = unit(2, 'cm'))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 18),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                                  face='bold'))+
    xlab('')+
    ylab('')
  
  ##Specificity MAP------------------------------------------------
  specFig <- ggplot(results) +
    geom_sf(aes(fill=basinSpecificity), color='black', size=0.3) +
    geom_sf(data=states, color='black', size=1.5, alpha=0)+
    scale_fill_gradientn(name='Ephemeral Classification Specificity',
                         colors =c("#d73027", 'white', "#4575b4"), #ffffbf
                         limits=c(0,100),
                         guide = guide_colorbar(direction = "horizontal",title.position = "top"))+
    labs(tag='B')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(0.2, 0.125),
          legend.key.size = unit(2, 'cm'))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 18),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                                  face='bold'))+
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
    annotate('text', label=paste0('n = ', nrow(df), ' basins'), x=as.factor('basinSpecificity'), y=0.20, size=7)+
    scale_fill_brewer(palette='Set2') +
    scale_y_continuous(limits=c(0,1), breaks=c(0,0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1))+
    scale_x_discrete('', labels=c('Accuracy', 'Sensitivity', 'Specificity', 'TSS'))+
    ylab('Value') +
    theme(axis.text=element_text(size=20),
      axis.title=element_text(size=22,face="bold"),
      legend.text = element_text(size=17),
      legend.position='none',
      axis.text.x = element_text( angle=60,hjust = 1, size=20, color="black"))

  ggsave('cache/boxPlots_classification.jpg', boxplots, width=8, height=8)

  return(boxplots)
}




#' Makes boxplot summarizing sensitivity results for number flowing days calculation
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
  
  combined_results <- dplyr::filter(combined_results, !is.na(numFlowingDays))
  
  #discharge
  forPlot <- tidyr::gather(combined_results, key=key, value=value, c('numFlowingDays', 'znumFlowingDays_low', 'ynumFlowingDays_med_low', 'anumFlowingDays_high', 'bnumFlowingDays_med_high'))
  forPlot$key <- as.factor(forPlot$key)
  levels(forPlot$key) <- c('High runoff 1','High runoff 2', 'Model', 'Low runoff 2', 'Low runoff 1')

  boxplotsSens <- ggplot(forPlot, aes(x=key, y=value, fill=key)) +
    geom_boxplot(color='black', size=1.25) +
    stat_summary(fun = mean, geom = "point", col = "darkred", size=8) +
    annotate('text', label=paste0('n = ', nrow(combined_results), ' basins'), x=as.factor('Model'), y=-5, size=8)+
    scale_fill_brewer(palette='BrBG') +
    ylab('Mean annual ephemeral days flowing [dys]') +
    xlab('')+
    ylim(0,365)+
    theme(axis.text=element_text(size=20),
      axis.title=element_text(size=22,face="bold"),
      legend.text = element_text(size=17),
      legend.position='none',
      axis.text.x = element_text(angle = 65, hjust=1))

  ggsave('cache/boxPlots_sensitivity.jpg', boxplotsSens, width=10, height=10)
  
  return(boxplotsSens)
}




#' Makes plots for snapping threshold sensitivity analysis
#'
#' @name snappingSensitivityFigures
#'
#' @param out: df containing sensitivity analysis results
#'
#' @import tidyr
#' @import ggplot2
#'
#' @return figures plotting sensitivity results (also written to file)
snappingSensitivityFigures <- function(out){  #tradeoff plot between horton law of stream numbers and snapping thresholds
  theme_set(theme_classic())

  forPlot <- dplyr::distinct(out, mae, .keep_all=TRUE) #drop duplicate rows that are needed to plot accuracy
  forPlot <- tidyr::gather(forPlot, key=key, value=value, c('mae', 'rmse'))
  tradeOffPlot <- ggplot(forPlot, aes(x=thresh, y=value, color=key)) +
        geom_point(size=10) +
        geom_line(linetype='dashed', size=1) +
        scale_color_brewer(palette='Accent', name='', labels=c('MAE of log(N)', 'RMSE of log(N)'))+
        xlab('Snapping Threshold [m]') +
        ylab('Value')+
        ylim(0,1)+
        theme(axis.text=element_text(size=20),
          axis.title=element_text(size=22,face="bold"),
          legend.text = element_text(size=17),
          legend.position='bottom')
  ggsave('cache/snappingThreshTradeOff.jpg', tradeOffPlot, width=8, height=8)

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
  ggsave('cache/acc_sens_to_snapping.jpg', accuracyPlot, width=8, height=8)

  return(list('tradeOffPlot'=tradeOffPlot,
              'accuracyPlot'=accuracyPlot))
}





#' Build figure showing runoff threshold calibration compared against the geomorphic model actually used
#'
#' @name runoffThreshCalibPlot
#'
#' @param calibResults: df of runoff threshold calibration results
#' @param theoreticalThresholds: vector of by basin runoff thresholds calculated via geomorphic scaling
#'
#' @import ggplot2
#' @import patchwork
#'
#' @return ggplot showing calibration (also writes fig to file)
runoffThreshCalibPlot <- function(calibResults){
  theme_set(theme_classic())
  
  calibResults$r2 <- calibResults$r2 * 100
  forPlot <- tidyr::gather(calibResults, key=key, value=value, c('r2', 'mae', 'rmse'))
  
  
  plot <- ggplot(forPlot, aes(x=thresh, y=value, color=key)) +
    geom_line(linetype='dashed', size=1.2) +
    geom_point(size=8) +
    scale_color_brewer(name='', palette='Set1', labels=c(expression(MAE), expression(r^2%*%100), expression(RMSE)))+
    ylab('Value') +
    xlab(expr(bold('Runoff threshold (global calibration) ['~frac(mm,dy)~']')))+
    scale_x_log10(limits=c(1e-4,100),
                  breaks=c(1e-4, 1e-3, 1e-2, 1e-1, 1e-0,10,100),
                  labels=c('0.0001', '0.001', '0.01', '0.1', '1','10','100'))+
    theme(axis.text=element_text(size=20),
          axis.title=element_text(size=22,face="bold"),
          legend.text = element_text(size=17),
          plot.title = element_text(size = 30, face = "bold"),
          legend.position='bottom')
  
  ggsave('cache/runoffThresh_fitting.jpg', plot, width=12, height=8)
  
  return(plot)
}




#' create figure for Horton scaling result
#'
#' @name buildScalingModelFig
#'
#' @param scalingModel: scaling model calculations object
#'
#' @return figure for explaining Hortonian scaling
buildScalingModelFig <- function(scalingModel){
  theme_set(theme_classic())
  
  scalingModel$ephMinOrder <- round(scalingModel$ephMinOrder,0)
  
  df <- scalingModel$df
  df$label <- 'Field data on hydrography'
  df$StreamOrde <- df$StreamOrde + (1-scalingModel$ephMinOrder)
  df2 <- data.frame('StreamOrde'=1-scalingModel$ephMinOrder, #add on that we are scaling to
                    'n'=scalingModel$desiredFreq,
                    'label'='Field data off hydrography')
  df <- rbind(df, df2)
  
  plot <- ggplot(df, aes(x=StreamOrde-1, y=n, color=label)) +
    geom_point(size=10)+
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






#' create ephemeral drainage area paper figure
#'
#' @name areaMapFunction
#'
#' @param shapefile_fin: final sf object with model results
#'
#' @import sf
#' @import dplyr
#' @import ggplot2
#' @import cowplot
#'
#' @return land use results figure (also writes figure to file)
areaMapFunction <- function(shapefile_fin) {
  theme_set(theme_classic())
  
  ##GET DATA
  results <- shapefile_fin$shapefile
  results <- dplyr::filter(results, is.na(num_flowing_dys)==0) #remove great lakes
  
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
  results$percArea_eph <- round(results$percAreaEph_exported*100,0) #setup percent
  
  #INSET MAP-----------------------------------------------
  cdf_inset <- ggplot(results, aes(percArea_eph))+
    stat_ecdf(size=2, color='black') +
    xlab('% ephemeral drainage area')+
    ylab('Exceedance Probability')+
    theme(axis.title = element_text(size=20),
          axis.text = element_text(family="Futura-Medium", size=18))+ #axis text settings
    theme(legend.position = 'none') #legend position settings

  #MAIN MAP-------------------------------------------------
  results_map <- ggplot(results) +
    geom_sf(aes(fill=percArea_eph), #actual map
            color='black',
            size=0.5) +
    geom_sf(data=states,
            color='black',
            size=1.25,
            alpha=0)+
    scale_fill_gradientn(name='% ephemeral drainage area',
                         colors=c('white', '#2c6e49'),
                         limits=c(0,100),
                         guide = guide_colorbar(direction = "horizontal",
                                                title.position = "bottom"))+
    scale_color_brewer(name='',
                       palette='Dark2',
                       guide='none')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(.15, 0.1),
          legend.key.size = unit(2, 'cm'))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 20),
          legend.text = element_text(family = "Futura-Medium", size = 18))+
    xlab('')+
    ylab('')
  
  results_map <- results_map + inset_element(cdf_inset, right = 0.975, bottom = 0.001, left = 0.775, top = 0.35)

  ggsave('cache/drainageAreaMap.jpg', results_map, width=20, height=15)
  return('see cache/drainageAreaMap.jpg')
}







#' create ephemeral hydrography map per huc4 basin
#'
#' @name hydrographyFigureSmall
#'
#' @param shapefile_fin: final model results shapefile
#' @param net_results: hydrography df detailing each reach's perenniality
#' @param huc4: huc4 basin id 
#'
#' @import sf
#' @import dplyr
#' @import ggplot2
#' @import cowplot
#'
#' @return ggplot object of hydrography map
hydrographyFigureSmall <- function(shapefile_fin, net_results, huc4){
  theme_set(theme_classic())
  
  ##GET DATA--------------------------------
  huc2 <- substr(huc4, 1, 2)
  results <- shapefile_fin$shapefile
  name <- results[results$huc4 == huc4,]$name
  exported_abs <- results[results$huc4 == huc4,]$QEph_exported_cms
  exported_perc <- results[results$huc4 == huc4,]$percQEph_exported

  net <- sf::st_read(dsn = paste0('/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_',huc2,'/NHDPLUS_H_',huc4,'_HU4_GDB/NHDPLUS_H_', huc4, '_HU4_GDB.gdb'), layer='NHDFlowline')
  if('MULTICURVE' %in% sf::st_geometry_type(net)){
    net <- sf::st_cast(net, 'MULTILINESTRING') #plotting functions can't handle the few streamlines saved as multicurve....
  }

  net <- dplyr::left_join(net, net_results, 'NHDPlusID')
  net <- dplyr::filter(net, is.na(perenniality)==0)
  
  #recast foreign streams as non-ephemeral for visualization's sake
  net$perenniality <- ifelse(net$perenniality == 'foreign', 'non_ephemeral', net$perenniality)
  
  #make plot name that is line-aware (so cool!!)
  plotName <- paste0(name,': ', round(exported_abs*86400*365*1e-9,0), ' km3/yr (', round(exported_perc*100,0), '%)')
  plotName <- stringr::str_wrap(plotName, 20) #wrap to twenty characters, seems to fit nicely

  #make hydrography map (keeping legend for later)
  hydrography <- ggplot(net, aes(color=perenniality, size=Q_cms)) +
    geom_sf()+
    coord_sf(datum = NA)+
    scale_color_manual(name='Stream Type',
                       values=c('#f18f01','#006e90'),
                       labels=c('Ephemeral','Not Ephemeral')) +
    scale_size_binned(name='Discharge [cms]',
                      breaks=c(0.1, 1, 10, 100),
                      range=c(0.4,2),
                      guide = "none")+
    theme(plot.title = element_text(face = "italic", size = 26),
         plot.tag = element_text(size=26,
                                face='bold'))+
    ggspatial::annotation_scale(location = "bl",
                                height = unit(0.5, "cm"),
                                text_cex = 1)+
    xlab('')+
    ylab('') +
    ggtitle(plotName)
  
  return(hydrography)
}






#' combines 16 hydrography ggplots into single patchwork plot
#'
#' @name comboHydroSmalls
#'
#' @param hydroMap_1: ggplot obejct mapping network 1
#' @param hydroMap_2: ggplot obejct mapping network 2
#' @param hydroMap_3: ggplot obejct mapping network 3
#' @param hydroMap_4: ggplot obejct mapping network 4
#' @param hydroMap_5: ggplot obejct mapping network 5
#' @param hydroMap_6: ggplot obejct mapping network 6
#' @param hydroMap_7: ggplot obejct mapping network 7
#' @param hydroMap_8: ggplot obejct mapping network 8
#' @param hydroMap_9: ggplot obejct mapping network 9
#' @param hydroMap_10: ggplot obejct mapping network 10
#' @param hydroMap_11: ggplot obejct mapping network 11
#' @param hydroMap_12: ggplot obejct mapping network 12
#' @param hydroMap_13: ggplot obejct mapping network 13
#' @param hydroMap_14: ggplot obejct mapping network 14
#' @param hydroMap_15: ggplot obejct mapping network 15
#' @param hydroMap_16: ggplot obejct mapping network 16
#' @param imageID: id for writing image to file
#'
#' @import sf
#' @import dplyr
#' @import ggplot2
#' @import cowplot
#'
#' @return writes patchwork plot to file
comboHydroSmalls <- function(hydroMap_1, hydroMap_2, hydroMap_3, hydroMap_4,
                             hydroMap_5, hydroMap_6, hydroMap_7, hydroMap_8,
                             hydroMap_9, hydroMap_10, hydroMap_11, hydroMap_12,
                             hydroMap_13, hydroMap_14, hydroMap_15, hydroMap_16, imageID){
  
  theme_set(theme_classic())

  ##EXTRACT SHARED LEGEND-----------------
  hydrography_legend <- cowplot::get_legend(
    hydroMap_1 +
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
  comboPlot <- patchwork::wrap_plots(A=hydroMap_1 + theme(legend.position='none'), B=hydroMap_2 + theme(legend.position='none'), C=hydroMap_3 + theme(legend.position='none'), D=hydroMap_4 + theme(legend.position='none'),
                                     E=hydroMap_5 + theme(legend.position='none'), F=hydroMap_6 + theme(legend.position='none'), G=hydroMap_7 + theme(legend.position='none'), H=hydroMap_8 + theme(legend.position='none'),
                                     I=hydroMap_9 + theme(legend.position='none'), J=hydroMap_10 + theme(legend.position='none'), K=hydroMap_11 + theme(legend.position='none'), L=hydroMap_12 + theme(legend.position='none'),
                                     M=hydroMap_13 + theme(legend.position='none'), N=hydroMap_14 + theme(legend.position='none'), O=hydroMap_15 + theme(legend.position='none'), P=hydroMap_16 + theme(legend.position='none'),
                                     Q=hydrography_legend, design=design)
  
  ggsave(paste0('cache/hydrographyMaps_', imageID, '.jpg'), comboPlot, width=20, height=25)
  
  return(paste0('cache/hydrographyMaps_', imageID, '.jpg'))
}






#' combines 13 hydrography ggplots into single patchwork plot
#'
#' @name comboHydroSmalls
#'
#' @param hydroMap_1: ggplot obejct mapping network 1
#' @param hydroMap_2: ggplot obejct mapping network 2
#' @param hydroMap_3: ggplot obejct mapping network 3
#' @param hydroMap_4: ggplot obejct mapping network 4
#' @param hydroMap_5: ggplot obejct mapping network 5
#' @param hydroMap_6: ggplot obejct mapping network 6
#' @param hydroMap_7: ggplot obejct mapping network 7
#' @param hydroMap_8: ggplot obejct mapping network 8
#' @param hydroMap_9: ggplot obejct mapping network 9
#' @param hydroMap_10: ggplot obejct mapping network 10
#' @param hydroMap_11: ggplot obejct mapping network 11
#' @param hydroMap_12: ggplot obejct mapping network 12
#' @param hydroMap_13: ggplot obejct mapping network 13
#' @param imageID: id for writing image to file
#'
#' @import sf
#' @import dplyr
#' @import ggplot2
#' @import cowplot
#'
#' @return writes patchwork plot to file
comboHydroSmalls_13 <- function(hydroMap_1, hydroMap_2, hydroMap_3, hydroMap_4,
                             hydroMap_5, hydroMap_6, hydroMap_7, hydroMap_8,
                             hydroMap_9, hydroMap_10, hydroMap_11, hydroMap_12,
                             hydroMap_13, imageID){
  
  theme_set(theme_classic())

  ##EXTRACT SHARED LEGEND-----------------
  hydrography_legend <- cowplot::get_legend(
    hydroMap_1 +
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
  comboPlot <- patchwork::wrap_plots(A=hydroMap_1 + theme(legend.position='none'), B=hydroMap_2 + theme(legend.position='none'), C=hydroMap_3 + theme(legend.position='none'), D=hydroMap_4 + theme(legend.position='none'),
                                     E=hydroMap_5 + theme(legend.position='none'), F=hydroMap_6 + theme(legend.position='none'), G=hydroMap_7 + theme(legend.position='none'), H=hydroMap_8 + theme(legend.position='none'),
                                     I=hydroMap_9 + theme(legend.position='none'), J=hydroMap_10 + theme(legend.position='none'), K=hydroMap_11 + theme(legend.position='none'), L=hydroMap_12 + theme(legend.position='none'),
                                     M=hydroMap_13 + theme(legend.position='none'),Q=hydrography_legend, design=design)
  
  ggsave(paste0('cache/hydrographyMaps_', imageID, '.jpg'), comboPlot, width=20, height=25)
  
  return(paste0('cache/hydrographyMaps_', imageID, '.jpg'))
}