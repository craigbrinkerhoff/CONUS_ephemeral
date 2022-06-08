#####################
## Craig Brinkerhoff
## Summer 2022
## Function to update discharges to refelct 'average flowing Q'
#####################

#' Builds discharge verification figure for all gaged NHD reaches (that pass USGS QC/QC) eventually used in model validation
#'
#' @param combined_verify: all model verification results
#'
#' @return NULL but writes figures to file
flowingQ <- function(USGS_data){
  theme_set(theme_classic())

  #get gages with no flow flow in their mean daily flows
  nonP <- dplyr::filter(USGS_data, no_flow_fraction > 0)

  nonP$Q_bin <- ifelse(nonP$Q_MA < 0.01, 0.01,
                      ifelse(nonP$Q_MA < 0.1, 0.1,
                            ifelse(nonP$Q_MA < 1, 1,
                                  ifelse(nonP$Q_MA < 10, 10, 100))))

  #reduce to Q bins
  scaling <- nonP %>%
      group_by(Q_bin) %>%
      summarise(meanFlowingDays = mean((1-no_flow_fraction)*365), #number of days flowing
      n=n())

  #setup modelPlot
  model <- lm(log10(meanFlowingDays)~log10(Q_bin), data=scaling)

  #save model as plot
  modelPlot <- ggplot(scaling, aes(x=Q_bin, y=meanFlowingDays)) +
      geom_point(size=5) +
      annotate('text', label=paste0('r2: ', round(summary(model)$r.squared,2)), x=1, y=100, size=8)+
      annotate('text', label=paste0('n = ', nrow(nonP), ' gauges'), x=1, y=30, size=8)+
      geom_smooth(method='lm', se=F, fullrange=TRUE) +
      xlab('Mean Annual Flow Bins')+
      ylab('Average Flowing Days per year')+
      scale_y_log10(breaks=c(1, 30, 180, 365),
                    labels=c('1', '30', '180', '365'),
                    limits=c(1, 365))+
      scale_x_log10(breaks=c(0.0001, 0.001, 0.01, 0.1, 1, 10, 100),
                    labels=c('0.0001','0.001', '0.01', '0.1', '1', '10', '100'),
                    limits=c(0.0001, 100))+
      theme(axis.text=element_text(size=20),
            axis.title=element_text(size=22,face="bold"),
            legend.text = element_text(size=17),
            plot.title = element_text(size = 30, face = "bold"))

  ggsave('cache/flowingQModel.jpg', modelPlot, width=8, height=8)

  #return model itself
  return(model)
}
