#########################
## Scaling beyond the Peckel 30m threshold
## Craig Brinkerhoff
## Summer 2022
########################

doScaling <- function(nhd_df, ephThresh, huc2, perc_thresh){
  `%notin%` <- Negate(`%in%`)

  #calculate general terms
  sumQ <- sum(nhd_df$Q_cms) #[nhd_df$perenniality != 'ephemeral',]
  minQ <- min(nhd_df$Q_cms, na.rm=T)

  nhd_clip_eph <- nhd_df[nhd_df$Q_cms < quantile(nhd_df$Q_cms, probs=c(0.95), na.rm=T),]

  nhd_clip_eph <- nhd_clip_eph[nhd_df$perenniality == 'ephemeral',]
  nhd_clip_eph <- select(nhd_clip_eph, c('Q_cms', 'NHDPlusID'))
  nhd_clip_eph <- nhd_clip_eph[order(-nhd_clip_eph$Q_cms),] #sort descending
  nhd_clip_eph$cumm_eph_Q <- cumsum(nhd_clip_eph$Q_cms)

  all_data <- nhd_clip_eph #store all data for complete model in figure

  nhd_clip_eph <- nhd_clip_eph[(log10(max(nhd_clip_eph$cumm_eph_Q, na.rm=T))-log10(nhd_clip_eph$cumm_eph_Q))/log10(nhd_clip_eph$cumm_eph_Q) >= perc_thresh & is.na((log10(max(nhd_clip_eph$cumm_eph_Q, na.rm=T))-log10(nhd_clip_eph$cumm_eph_Q))/log10(nhd_clip_eph$cumm_eph_Q))==0,]
  #t <- nhd_clip_eph[-nrow(nhd_clip_eph),]
  #thresh <- t[which.max(diff(t$cumm_eph_Q)),]$cumm_eph_Q
  #nhd_clip_eph <- nhd_clip_eph[nhd_clip_eph$cumm_eph_Q >= thresh,] #percent change in cummQ is > 1%, to identify 'point of asymptote'

  #nhd_clip_eph <- nhd_clip_eph[-nrow(nhd_clip_eph),] #remove last point, which has an artifically high diff

  #fit GAM
  nhd_clip_eph$log10_Q <- log10(nhd_clip_eph$Q_cms)
  nhd_clip_eph$log10_cumm_Q <- log10(nhd_clip_eph$cumm_eph_Q)
  gamModel <- gam(formula = log10_cumm_Q ~ s(log10_Q, bs = "cs"), data=nhd_clip_eph)
  dev_exp <- summary(gamModel)$dev.expl #deviance explained by GAM model

  #predict/extapolate via GAM
  nhd_clip_eph <- rbind(nhd_clip_eph, c(minQ, -9999, NA, log10(minQ), NA)) #add maximium extrapolate value to df
  nhd_clip_eph$pred_cumm_eph_Q <- 10^(predict(gamModel, newdata=nhd_clip_eph))
  extrapolatedresult <- 10^(predict(gamModel, newdata=data.frame('log10_Q'=log10(minQ))))

  #total sumQ is the non-ephemeral estimate and the extrapolated ephemeral estimate
#  sumQ <- sumQ + extrapolatedresult

  #plot
  t <- ggplot() +
    geom_line(data=all_data, aes(y=cumm_eph_Q, x=Q_cms), size=2, color='darkgrey') + #empirical relationship, all data
    geom_line(data=nhd_clip_eph, aes(y=cumm_eph_Q, x=Q_cms), size=2) + #empirical relationship, removing ends following Messager 2021
    geom_line(data=nhd_clip_eph, aes(y=pred_cumm_eph_Q, x=Q_cms), size=2, linetype='dotted', color='pink')+ #gam model
    geom_vline(xintercept = minQ, linetype='dashed') +
    ggtitle('Ephemeral Streams Cummulative Q Distribution')+
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x)))+
    scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x)))
  ggsave(paste0('cache/scaling/scalingModel_', huc2,'.jpg'),t, width=8, height=8)

  return(data.frame('HUC2'=huc2,
              'totalQ'=sumQ,
              'ephemeralQ'=extrapolatedresult,
              'percEphQ_scaled'=extrapolatedresult / sumQ,
              'deviance_exp'=dev_exp)) #perc deviance explained by the model
}



#doScalingHorton <- function(nhd_df, huc2){
#  sumQ <- sum(nhd_df$Q_cms)
#  networkSize <- max(nhd_df$StreamOrde) #what order is this system?

#  nhd_clip_eph <- nhd_df[nhd_df$perenniality == 'ephemeral',]

  #reduce to stream orders for 'ephemeral network'
#  nhd_clip_eph <- nhd_clip_eph %>%
#    group_by(StreamOrde) %>%
#    summarise(N = n(),
#              Qbar = mean(Q_cms, na.rm=T))

  #get horton parameters for 'ephemeral network'
#  lm_N <- lm(log(nhd_clip_eph$N)~nhd_clip_eph$StreamOrde)
#  lm_Qbar <- lm(log(nhd_clip_eph$Qbar)~nhd_clip_eph$StreamOrde)

#  Rn <- 1/(exp(lm_N$coefficient[1]))
#  Rqbar <- (exp(lm_N$coefficient[1]))

  #scale!!
#  nhd_clip_eph$N_or <- Rn^(networkSize - nhd_clip_eph$StreamOrde)
#  nhd_clip_eph$Qbar_or <- nhd_clip_eph[1,]$Qbar * Rqbar^(nhd_clip_eph$StreamOrde - 1)

#  extrapolatedresult <- sum(nhd_clip_eph$N_or * nhd_clip_eph$Qbar_or)

#  return(data.frame('HUC2'=huc2,
#              'percEphQ_scaled'=extrapolatedresult / sumQ))
#}
