'totalephemeralQ_flowing_cms'=sum(nhd_df[nhd_df$perenniality == 'ephemeral',]$dQdX_cms, na.rm=T) * (365/numFlowingDays), #actual water volume calculated via dQdX and network routing
results_nhd$percQ_eph_flowing <- results_nhd$totalephemeralQ_flowing_cms / (results_nhd$totalNotEphQ_cms + results_nhd$totalephemeralQ_flowing_cms)
Qbar_adj = mean(Q_cms, na.rm=T) * (365/numFlowingDays),

lm5 <- lm(log(Qbar_adj)~StreamOrde, data=df)
Rq_f <- exp(lm5$coefficient[2]) #Horton law parameter for mean flowing Q

new$Qbar_adj <- (df[df$StreamOrde == 3,]$Qbar_adj)/(Rq_f^(df[df$StreamOrde == 3,]$StreamOrde - 1)) #ratio using 3rd order
new$Qbar_adj <- df[df$StreamOrde == 1,]$Qbar*Rq_f^(i-1)

additionalQ_flowing <- sum(df[1:numNewOrders,]$Qbar_adj * df[1:numNewOrders,]$n) #mean annual flowing
additionalQ_flowing <- 0

results$totalephmeralQ_flowing_scaled_cms <- results$totalephemeralQ_flowing_cms + additionalQ_flowing #mean annual flowing
results$percQ_eph_flowing_scaled_cms <- results$totalephmeralQ_flowing_scaled_cms / (results$totalephmeralQ_flowing_scaled_cms + results$totalNotEphQ_cms) #mean annual flowing percent


'accumNotEphQ_cms' = sum(nhd_df[nhd_df$perenniality != 'ephemeral',]$Q_cms, na.rm=T), #accumulated numbers used just for relative calculations against non-ephemeral rivers (easier)
'accumephmeralQ_flowing_cms' = sum(nhd_df[nhd_df$perenniality == 'ephemeral',]$Q_cms, na.rm=T)* (365/numFlowingDays), #scale to 'flowingQ'
'accumephmeralQ_cms' = sum(nhd_df[nhd_df$perenniality == 'ephemeral',]$Q_cms, na.rm=T),


#' Scales model results to additional stream order(s) if necessary. Horton ratio used in this calcualtion comes from the NHD 3rd order calculated ratio (to be somehere in the middle of the network)
#'
#' @name scalingByBasin
#' 
#' @note the dQdX is updated (via scaling Qbar) for a single scenario: headwater non_ephemeral streams that have 'upland scaled ephemeral streams'.
#'       So, the dQdX in the river network files are raw (unaffected by scaling) but here they are obviously changed
#'
#' @param scalingModel: Horton laws, already fit to ephemeral field data
#' @param rivNetFin: nhd hydrography for a given huc4 basin
#' @param results: results file for a given huc4 basin
#' @param huc4: HUC4 basin code
#'
#' @import dplyr
#'
#' @return updated results dataframe with scaled results
scalingByBasin <- function(scalingModel, rivNetFin, results, huc4){
  #fit horton laws to this river system (east vs west of Mississippi, different scaling)
  numNewOrders <- 1 - scalingModel$ephMinOrder
  
  #number, length, and average discharge of ephemeral streams
  df <- dplyr::filter(rivNetFin, perenniality == 'ephemeral') %>%
    dplyr::group_by(StreamOrde) %>%
    dplyr::summarise(n=n(),
                     Qbar = mean(Q_cms, na.rm=T),
                     length = sum(LengthKM, na.rm=T))
  
  #length of ephemeral streams flowing through cultivated/developed lands
  df2 <- dplyr::filter(rivNetFin, perenniality == 'ephemeral' & nlcd_broad %in% c(20,70)) %>%
    dplyr::group_by(StreamOrde) %>%
    dplyr::summarise(cultDevp_length = sum(LengthKM, na.rm=T))
  
  df <- left_join(df, df2, by='StreamOrde')
  
  #rewrite stream orders for scaling (when appropriate, set up for scaling multiple orders even though it only runs 1)
  if(numNewOrders > 0){
    df$old_orders <- df$StreamOrde
    df$StreamOrde <- df$StreamOrde + numNewOrders
    
    #get horton ratios
    lm <- lm(log(n)~StreamOrde, data=df)
    Rb <- 1/exp(lm$coefficient[2]) #Horton law parameter for num streams
    
    lm2 <- lm(log(cultDevp_length)~StreamOrde, data=df)
    Rl_cd <- exp(lm2$coefficient[2]) #Horton law parameter for stream order length for cult/devp streams
    
    lm3 <- lm(log(length)~StreamOrde, data=df)
    Rl <- exp(lm3$coefficient[2]) #Horton law parameter for stream order length
    
    lm4 <- lm(log(Qbar)~StreamOrde, data=df)
    Rq <- exp(lm4$coefficient[2]) #Horton law parameter for mean Q
    
    #scale to new minimum order
    for (i in 1:numNewOrders){
      new <- data.frame('StreamOrde'=i, 'n'=NA, 'Qbar'=NA, 'cultDevp_length'=NA)
      new$old_orders <- NA
      new$n <- df[df$StreamOrde == max(df$StreamOrde),]$n*Rb^(max(df$StreamOrde) - i)
      if(i ==1){ #do first order first (as its different)
        new$Qbar <- (df[df$StreamOrde == 3,]$Qbar)/(Rq^(df[df$StreamOrde == 3,]$StreamOrde - 1)) #ratio using 3rd order
        new$length <- (df[df$StreamOrde == 3,]$length)/(Rl^(df[df$StreamOrde == 3,]$StreamOrde - 1)) #ratio using 3rd order
        new$cultDevp_length <- (df[df$StreamOrde == 3,]$cultDevp_length)/(Rl_cd^(df[df$StreamOrde == 3,]$StreamOrde - 1)) #ratio using 3rd order
      }
      else{ #do all other additional orders (if necessary)
        new$Qbar <- df[df$StreamOrde == 1,]$Qbar*Rq^(i-1)
        new$length <- df[df$StreamOrde == 1,]$length*Rl^(i-1)
        new$cultDevp_length <- df[df$StreamOrde == 1,]$cultDevp_length*Rl_cd^(i-1)
      }
      df <- rbind(df, new)
    }
    
    df <- df[order(df$StreamOrde), ]
    
    #get number, length, and discharge in additional stream order(s)
    additionalQ <- sum(df[1:numNewOrders,]$Qbar * df[1:numNewOrders,]$n)
    additionalLength <- sum(df[1:numNewOrders,]$length) #km
    additionalCultDevpLength <- sum(df[1:numNewOrders,]$cultDevp_length) #km
    additionalN <- round(sum(df[1:numNewOrders,]$n),0) #n streams
    
    scalingFlag <- 1
  }
  
  #when no additional scaling is done
  else{
    additionalQ <- 0
    additionalLength <- 0
    additionalCultDevpLength <- 0
    scalingFlag <- 0
  }
  
  #adding scaled results to previous results
  results$totalephmeralQ_scaled_cms <- results$totalephemeralQ_cms + additionalQ #mean annual
  results$ephemeralCultDevpNetworkLength_scaled_km <- results$ephemeralCultDevpNetworkLength_km + additionalCultDevpLength #ephemeral length
  results$ephemeralLength_scaled_km <- results$ephemeralNetworkLength_km + additionalLength #ephemeral cultivated/developed length
  results$n_scaled <- additionalN
  
  results$percQ_eph_scaled <- results$totalephmeralQ_scaled_cms / (results$totalephmeralQ_scaled_cms + results$totalNotEphQ_cms) #mean annual percent
  results$percLength_eph_cult_devp_scaled <- results$ephemeralCultDevpNetworkLength_scaled_km / (results$ephemeralLength_scaled_km + results$notEphNetworkLength_km) #ephemeral cultivated/devleoped length
  
  results$scalingFlag <- scalingFlag
  
  return(results)
}