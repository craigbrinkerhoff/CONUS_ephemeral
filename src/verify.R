#################
## Compare river perenniality to gage-estimated ephemeral streams via hydrograph separation
## Craig Brinkerhoff
## Spring 2022
#################

#' BuildsHUC4 datasets for verification of perenniality model against 'baseflow' at USGS streamgauges.
#' 
#' @param erom_data: USGS gages joined to NHD a priori
#' @param usgs_data: USGS gage baseflow fractions, estimated a priori
#' 
#' @note Note that baseflow is itself inferred via hydrograph seperation and so is not a true validation
#' 
#' @return verification df per HUC4
getRivNetverify <- function(rivNetFin, nhdGages, usgs_data){
  #setup gages on NHD
  nhd_gages <- left_join(nhdGages, usgs_data, by=c('GageIDMA'='gageID')) %>%
    tidyr::drop_na()
  
  #VERIFY AGAINST BASEFLOW calculated previously-------------------
  verifyDF <- left_join(nhd_gages, rivNetFin, by='NHDPlusID') %>%
    tidyr::drop_na() %>%
    mutate(baseflow_cf = ifelse(round(no_flow_fraction, 2) < 0.014, 'perennial', #Minimum 1 month dry, following our model's monthly resolution
                                ifelse(round(baseflow_fraction_lynehollick_singh,2) <= 0.05, 'ephemeral','intermittent')))
     # mutate(baseflow_cf = ifelse(round(baseflow_fraction_lynehollick_singh,2) <= 0.05, 'ephemeral', 'perennial'), #Overwriting intermittent, the correct names are used in the figure function below
     #       model_cf = ifelse(perenniality == 'intermittent', 'perennial', perenniality))

  if(nrow(verifyDF) == 0){
    return()
  } else{
    return(verifyDF) 
  }
}

#' Creates confusion matrix for model verification per HUC4
#' 
#' @param verifyDF: combo df of all verification tables for each HUC4
#' @note Note that baseflow is itself inferred via hydrograph seperation and so is not a true validation
#' 
#' @return confusion matrix. Figure saved to file
verifyModel <- function(verifyDF){
  theme_set(theme_classic())
  
  cm <- as.data.frame(caret::confusionMatrix(factor(verifyDF$perenniality), factor(verifyDF$baseflow_cf))$table)
  cm$Prediction <- factor(cm$Prediction, levels=rev(levels(cm$Prediction)))
  cfMatrix <- ggplot(cm, aes(Reference, Prediction,fill=factor(Freq))) +
    geom_tile() + 
    geom_text(aes(label=Freq), size=15)+
  #  scale_fill_manual(values=c('#bebada', '#8dd3c7','#bebada', '#8dd3c7')) +
  #  labs(x = "Estimated baseflow component of\nmean annual hydrograph",y = "Model Prediction") +
  #  scale_x_discrete(labels=c("<5%",">=5%")) +
  #  scale_y_discrete(labels=c("Not\nEphemeral","Ephemeral")) +
    theme(legend.position = "none",
          axis.text=element_text(size=24),
          axis.title=element_text(size=28,face="bold"),
          legend.text = element_text(size=17),
          legend.title = element_text(size=17, face='bold'))
  
  ggsave('cache/verify_cf.jpg', cfMatrix, width=10, height=8)
  return(cm)
}