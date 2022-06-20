#####################
## Craig Brinkerhoff
## Summer 2022
## Function to update discharges to refelct 'average flowing Q'
#####################

scalingFunc <- function(validationResults){
  desiredFreq <- validationResults$eph_features_off_nhd #ephemeral features not on the NHD, what we want to scale too

  df <- validationResults$validation_fin
  df <- filter(df, is.na(StreamOrde)==0 & distinction == 'ephemeral') #remove USGS gages, which are always perennial anyway

  df <- group_by(df, StreamOrde) %>%
      summarise(n=n())

  #fit model for Horton number of streams per order
  lm <- lm(log(n)~StreamOrde, data=df)
  Rb <- 1/exp(lm$coefficient[2]) #Horton law parameter
  #ephMinOrder <- round((max(df$StreamOrde)*log(Rb) - log(desiredFreq))/log(Rb),0)
  ephMinOrder <- round((log(desiredFreq) - log(df[df$StreamOrde == max(df$StreamOrde),]$n) - max(df$StreamOrde)*log(Rb))/(-1*log(Rb)),0)

  return(list('ephMinOrder'=ephMinOrder,
              'df'=df,
              'desiredFreq'=desiredFreq,
              'horton_lm'=lm)) #https://www.engr.colostate.edu/~ramirez/ce_old/classes/cive322-Ramirez/CE322_Web/Example_Horton_html.htm
}

scalingByBasin <- function(scalingModel, rivNetFin, results){
  #fit horton laws to this river system
  numNewOrders <- (1-scalingModel$ephMinOrder)

  #num flowing days per earlier rain analysis
  numFlowingDays <- results$num_flowing_dys

  #number and average discharge of ephemeral streams
  df <- filter(rivNetFin, perenniality == 'ephemeral') %>%
      group_by(StreamOrde) %>%
      summarise(n=n(),
                Qbar = mean(Q_cms, na.rm=T),
                Qbar_adj = mean(Q_cms, na.rm=T)* (365/numFlowingDays))

  #rewrte stream orders for scaling
  df$old_orders <- df$StreamOrde
  df$StreamOrde <- df$StreamOrde + numNewOrders

  #get horton ratios
  lm <- lm(log(n)~StreamOrde, data=df)
  Rb <- 1/exp(lm$coefficient[2]) #Horton law parameter for num streams
  lm2 <- lm(log(Qbar)~StreamOrde, data=df)
  Rq <- exp(lm2$coefficient[2]) #Horton law parameter for mean Q
  lm3 <- lm(log(Qbar_adj)~StreamOrde, data=df)
  Rq_f <- exp(lm3$coefficient[2]) #Horton law parameter for mean flowing Q

  #scale
  for (i in 1:numNewOrders){
    new <- data.frame('StreamOrde'=i, 'n'=NA, 'Qbar'=NA)
    new$old_orders <- NA
    new$n <- df[df$StreamOrde == max(df$StreamOrde),]$n*Rb^(max(df$StreamOrde) - i)
    if(i ==1){
      new$Qbar <- (df[df$StreamOrde == 3,]$Qbar)/(Rq^(df[df$StreamOrde == 3,]$StreamOrde - 1)) #ratio using 3rd order
      new$Qbar_adj <- (df[df$StreamOrde == 3,]$Qbar_adj)/(Rq_f^(df[df$StreamOrde == 3,]$StreamOrde - 1)) #ratio using 3rd order
    }
    else{
      new$Qbar <- df[df$StreamOrde == 1,]$Qbar*Rq^(i-1)
      new$Qbar_adj <- df[df$StreamOrde == 1,]$Qbar*Rq_f^(i-1)
    }
    df <- rbind(df, new)
  }

  df <- df[order(df$StreamOrde), ]

  #get water volume in additional stream order
  additionalQ <- sum(df[1:numNewOrders,]$Qbar * df[1:numNewOrders,]$n) #mean annual
  additionalQ_flowing <- sum(df[1:numNewOrders,]$Qbar_adj * df[1:numNewOrders,]$n) #mean annual flowing

  #adding scaled results to previous results
  results$totalephmeralQ_scaled <- results$totalephmeralQ + additionalQ #mean annual
  results$percQ_eph_scaled <- results$totalephmeralQ_scaled / (results$totalephmeralQ_scaled + results$totalNotEphQ)

  results$totalephmeralQ_flowing_scaled <- results$totalephmeralQ_flowing + additionalQ_flowing #mean annual flowing
  results$percQ_eph_flowing_scaled <- results$totalephmeralQ_flowing_scaled / (results$totalephmeralQ_flowing_scaled + results$totalNotEphQ)


  return(results)
}



#flowingQ <- function(USGS_data){
#  theme_set(theme_classic())

  #get gages with no flow flow in their mean daily flows
#  nonP <- dplyr::filter(USGS_data, no_flow_fraction > 0)

#  nonP$Q_bin <- ifelse(nonP$Q_MA < 0.01, 0.01,
#                      ifelse(nonP$Q_MA < 0.1, 0.1,
#                            ifelse(nonP$Q_MA < 1, 1,
#                                  ifelse(nonP$Q_MA < 10, 10, 100))))

  #reduce to Q bins
#  scaling <- nonP %>%
#      group_by(Q_bin) %>%
#      summarise(meanFlowingDays = mean((1-no_flow_fraction)*365), #number of days flowing
#      n=n())

  #setup modelPlot
#  model <- lm(log10(meanFlowingDays)~log10(Q_bin), data=scaling)

  #save model as plot
#  modelPlot <- ggplot(scaling, aes(x=Q_bin, y=meanFlowingDays)) +
#      geom_point(size=5) +
#      annotate('text', label=paste0('r2: ', round(summary(model)$r.squared,2)), x=1, y=100, size=8)+
#      annotate('text', label=paste0('n = ', nrow(nonP), ' gauges'), x=1, y=30, size=8)+
#      geom_smooth(method='lm', se=F, fullrange=TRUE) +
#      xlab('Mean Annual Flow Bins')+
#      ylab('Average Flowing Days per year')+
#      scale_y_log10(breaks=c(1, 30, 180, 365),
#                    labels=c('1', '30', '180', '365'),
#                    limits=c(1, 365))+
#      scale_x_log10(breaks=c(0.0001, 0.001, 0.01, 0.1, 1, 10, 100),
#                    labels=c('0.0001','0.001', '0.01', '0.1', '1', '10', '100'),
#                    limits=c(0.0001, 100))+
#      theme(axis.text=element_text(size=20),
#            axis.title=element_text(size=22,face="bold"),
#            legend.text = element_text(size=17),
#            plot.title = element_text(size = 30, face = "bold"))

#  ggsave('cache/flowingQModel.jpg', modelPlot, width=8, height=8)

  #return model itself
#  return(model)
#}
