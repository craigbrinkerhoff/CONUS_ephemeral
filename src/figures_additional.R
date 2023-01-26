## Craig Brinkerhoff
## Summer 2022
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
#' @return flowing days figure (also writes figure to file)
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
                                  face='bold'),
          legend.box.background = element_rect(colour = "black"))+
    xlab('')+
    ylab('')
  
  
  #####TOKUNAGA ROUTING VERIFICATION---------------------------------------------------
  #dont plot the great lakes because the network scaling makes no sense
  forPlot <- dplyr::filter(tokunaga_df, !is.na(export))
  
  tokunagaPlot <- ggplot(forPlot, aes(x=export*100, y=percQEph_exported*100)) + 
    geom_point(size=7, color='#335c67') +
    geom_abline(linetype='dashed', size=2, color='darkgrey') +
    xlim(0,100)+
    ylim(0,100)+
    ylab('% Discharge ephemeral\n(via routing model)') +
    xlab('% Upstream network ephemeral\n(via scaling theory)') +
    annotate('text', label=paste0(nrow(forPlot), ' basins'), x=75, y=15, size=7, color='black')+
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
  
  #save number of gauges to file for later reference
  write_rds(list('gages_w_sufficent_data'=nrow(qma),
                 'gages_on_nhd'=nrow(assessmentDF)),
            'cache/gageNumbers.rds')
  
  assessmentDF <- tidyr::drop_na(assessmentDF) %>%
    dplyr::mutate(type = ifelse(no_flow_fraction >= 5/365, 'Ephemeral/Intermittent', 'Perennial')) %>% #Messager definition for non-perenniality is 1 day a year not flowing
    dplyr::select('Q_MA', 'QBMA', 'type')
  
  #join datasets
  assessmentDF <- rbind(assessmentDF, walnutGulch) #ephemeralQDataset
  assessmentDF$type <- factor(assessmentDF$type, levels = c("Perennial", "Ephemeral/Intermittent"))
  
  assessmentDF <- dplyr::filter(assessmentDF, !(is.na(QBMA)) & !(is.na(Q_MA)))
  
  #Model plot
  eromVerification_QBMA <- ggplot(assessmentDF, aes(x=Q_MA, y=QBMA, color=type)) +
    geom_abline(linetype='dashed', color='darkgrey', size=2)+
    geom_point(size=4)+
    xlab('Observed Mean Annual Flow')+
    ylab('USGS Discharge Model')+
    geom_smooth(method='lm', size=1.5, color='black', se=F)+
    scale_color_manual(name='', values=c('#007E5D', '#E7C24B', '#775C04'))+
  #  annotate('text', label=paste0('r2: ', round(summary(lm(log(QBMA)~log(Q_MA), data=assessmentDF))$r.squared,2)), x=0.01, y=175, size=9)+
    annotate('text', label=expr(r^2: ~ !!round(summary(lm(log(QBMA)~log(Q_MA), data=assessmentDF))$r.squared,2)), x=0.01, y=175, size=9)+
    annotate('text', label=expr(MAE: ~ !!round(Metrics::mae(assessmentDF$QBMA, assessmentDF$Q_MA),1) ~ frac(m^3, s)), x=0.01, y=1000, size=9)+
    annotate('text', label=paste0(nrow(assessmentDF), ' streams'), x=100, y=0.001, size=7, color='black')+
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
  return('see cache/validationPlot.jpg')
  
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
                                  face='bold'),
          legend.box.background = element_rect(colour = "black"))+
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
                                  face='bold'),
          legend.box.background = element_rect(colour = "black"))+
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
    scale_y_continuous(limits=c(0,1), breaks=c(0,0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1))+
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
    ylab('Mean Annual ephemeral days flowing [dys]') +
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

  forPlot <- dplyr::distinct(out, mae, .keep_all=TRUE) #drop duplicate rows that are needed to accuracy Plot
  forPlot <- tidyr::gather(forPlot, key=key, value=value, c('mae', 'ephMinOrder'))
  tradeOffPlot <- ggplot(forPlot, aes(x=thresh, y=value, color=key)) +
        geom_point(size=7) +
        geom_line(linetype='dashed', size=1) +
        scale_color_brewer(palette='Accent', name='', labels=c('# Scaled Orders', 'MAE of log(N)'))+
        xlab('Snapping Threshold [m]') +
        ylab('Value')+
        ylim(0,2)+
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
                  breaks=c(1e-4, 1e-2, 1e-0,10,100),
                  labels=c('0.0001', '0.001', '1','10','100'))+
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
                         colors=c('white', '#2c6e49', '#173B27'),
                         limits=c(0,100),
                         guide = guide_colorbar(direction = "horizontal",
                                                title.position = "bottom"))+
    scale_color_brewer(name='',
                       palette='Dark2',
                       guide='none')+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = c(.20, 0.1),
          legend.key.size = unit(2, 'cm'))+ #legend position settings
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 20),
          legend.text = element_text(family = "Futura-Medium", size = 18))+
    xlab('')+
    ylab('')
  
  ggsave('cache/drainageAreaMap.jpg', results_map, width=20, height=15)
  return('see cache/drainageAreaMap.jpg')
}





#' create ephemeral discharge vs river size plot
#'
#' @name hydrographyFigure
#'
#' @param shapefile_fin: final model results shapefile
#' @param net_0108_results model results
#' @param net_1023_results model results
#' @param net_0313_results model results
#' @param net_1503_results model results
#' @param net_1306_results model results
#' @param net_0804_results model results
#' @param net_0501_results model results
#' @param net_1703_results model results
#' @param net_0703_results model results
#' @param net_0304_results model results
#' @param net_1605_results model results
#' @param net_1507_results model results
#' @param net_0317_results model results
#' @param net_0506_results model results
#' @param net_0103_results model results
#' @param net_1709_results model results
#' 
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
    ggtitle(paste0('Connecticut River:\n', round(results[results$huc4 == '0108',]$QEph_exported_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '0108',]$percQEph_exported*100,0), '%)'))
  
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
    ggtitle(paste0('Missouri/Little Sioux\nRiver: ', round(results[results$huc4 == '1023',]$QEph_exported_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '1023',]$percQEph_exported*100,0), '%)'))
  
  
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
    ggtitle(paste0('Apalachicola River:\n', round(results[results$huc4 == '0313',]$QEph_exported_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '0313',]$percQEph_exported*100,0), '%)'))
  
  
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
    ggtitle(paste0('Lower Colorado River:\n', round(results[results$huc4 == '1503',]$QEph_exported_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '1503',]$percQEph_exported*100,0), '%)'))
  
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
    ggtitle(paste0('Upper Pecos River:\n', round(results[results$huc4 == '1306',]$QEph_exported_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '1306',]$percQEph_exported*100,0), '%)'))
  
  
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
    ggtitle(paste0('Lower Red/Quachita\nRiver: ', round(results[results$huc4 == '0804',]$QEph_exported_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '0804',]$percQEph_exported*100,0), '%)'))
  
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
    ggtitle(paste0('Allegheny River:\n', round(results[results$huc4 == '0501',]$QEph_exported_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '0501',]$percQEph_exported*100,0), '%)'))
  
  
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
    ggtitle(paste0('Yakima River:\n', round(results[results$huc4 == '1703',]$QEph_exported_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '1703',]$percQEph_exported*100,0), '%)'))
  
  
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
    ggtitle(paste0('St. Croix River:\n', round(results[results$huc4 == '0703',]$QEph_exported_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '0703',]$percQEph_exported*100,0), '%)'))
  
  
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
    ggtitle(paste0('Pee Dee River:\n', round(results[results$huc4 == '0304',]$QEph_exported_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '0304',]$percQEph_exported*100,0), '%)'))
  
  
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
    ggtitle(paste0('Central Lahontan River:\n', round(results[results$huc4 == '1605',]$QEph_exported_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '1605',]$percQEph_exported*100,0), '%)'))
  
  
  
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
    ggtitle(paste0('Lower Gila River:\n', round(results[results$huc4 == '1507',]$QEph_exported_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '1507',]$percQEph_exported*100,0), '%)'))
  
  
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
    ggtitle(paste0('Pascagoula River:\n', round(results[results$huc4 == '0317',]$QEph_exported_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '0317',]$percQEph_exported*100,0), '%)'))
  
  
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
    ggtitle(paste0('Scioto River:\n', round(results[results$huc4 == '0506',]$QEph_exported_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '0506',]$percQEph_exported*100,0), '%)'))
  
  
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
    ggtitle(paste0('Kennebec River:\n', round(results[results$huc4 == '0103',]$QEph_exported_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '0103',]$percQEph_exported*100,0), '%)'))
  
  
  
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
    ggtitle(paste0('Willamette River:\n', round(results[results$huc4 == '1709',]$QEph_exported_cms*86400*365*1e-9,0), ' km3/yr (', round(results[results$huc4 == '1709',]$percQEph_exported*100,0), '%)'))
  
  
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
