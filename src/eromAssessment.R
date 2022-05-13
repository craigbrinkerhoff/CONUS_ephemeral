#####################
## Craig Brinkerhoff
## Spring 2022
## Functions to validate EROM discharges in the NHD
#####################

#' Builds discharge verification figure for all gaged NHD reaches (that pass USGS QC/QC)
#'
#' @param USGS_data: set of USGS gauges with their observed mean annual flow and baseflow indices
#' @param nhdGages: all USGS gages joined to the NHD a priori and filtered by the USGS using their QA/QC protocols
#'
#' @return NULL but writes figures to file
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
    geom_point(size=3, alpha=0.3, color='darkblue')+
    xlab('')+
    ylab('NHD Ungaged Flow')+
    geom_smooth(method='lm', size=1.5, color='black', se=F)+
    annotate('text', label=paste0('r2: ', round(summary(lm(log(QDMA)~log(Q_MA), data=assessmentDF))$r.squared,2)), x=0.001, y=175, size=9)+
    annotate('text', label=paste0('RMSE: ', round(Metrics::rmse(assessmentDF$QDMA, assessmentDF$Q_MA),1), ' m3/s'), x=0.01, y=950, size=9)+
    annotate('text', label=paste0(nrow(assessmentDF), ' gages'), x=900, y=0.001, size=7, color='darkblue')+
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
    geom_point(size=3, alpha=0.3, color='darkblue')+
    xlab('Observed Mean Annual Flow\n(1970-2018)')+
    ylab('NHD Gage Flow')+
    geom_smooth(method='lm', size=1.5, color='black', se=F)+
    annotate('text', label=paste0('r2: ', round(summary(lm(log(QEMA)~log(Q_MA), data=assessmentDF))$r.squared,2)), x=0.001, y=175, size=9)+
    annotate('text', label=paste0('RMSE: ', round(Metrics::rmse(assessmentDF$QEMA, assessmentDF$Q_MA),1), ' m3/s'), x=0.01, y=950, size=9)+
    annotate('text', label=paste0(nrow(assessmentDF), ' gages'), x=900, y=0.001, size=7, color='darkblue')+
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
