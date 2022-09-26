#####################
## Craig Brinkerhoff
## Summer 2022
## Functions to scale model to additional stream orders beyond the NHD
#####################



#' Fits horton laws to ephemeral data and calculates number of additional stream orders to match the observed ephemeral data occurence off  network
#'
#' @name scalingFunc
#'
#' @param validationResults: completed snapped and cleaned WOTUS JD validation dataset
#'
#' @import dplyr
#'
#' @return list of properties obtained from horton fitting: new minimum order ('ephMinOrder'), desired epehemeral frequncy ('desiredFreq'), horton model ('horton_lm'), horton coefficient ('Rb')
scalingFunc <- function(validationResults){
  desiredFreq <- validationResults$eph_features_off_nhd_tot #ephemeral features not on the NHD, what we want to scale too

  df <- validationResults$validation_fin
  df <- dplyr::filter(df, is.na(StreamOrde)==0 & distinction == 'ephemeral') #remove USGS gages, which are always perennial anyway

  df <- dplyr::group_by(df, StreamOrde) %>%
      dplyr::summarise(n=n())

  #fit model for Horton number of streams per order
  lm <- lm(log(n)~StreamOrde, data=df)
  Rb <- 1/exp(lm$coefficient[2]) #Horton law parameter
  ephMinOrder <- round((log(desiredFreq) - log(df[df$StreamOrde == max(df$StreamOrde),]$n) - max(df$StreamOrde)*log(Rb))/(-1*log(Rb)),0) #algebraically solve for smallest order in the system
  df_west <- df

  return(list('desiredFreq'=desiredFreq,
              'df'=df,
              'ephMinOrder'=ephMinOrder,
              'horton_lm'=lm,
              'Rb'=  Rb)) #https://www.engr.colostate.edu/~ramirez/ce_old/classes/cive322-Ramirez/CE322_Web/Example_Horton_html.htm
}



#' Scales model results to additional stream order(s) if necessary. Horton ratio used in this calcualtion comes from the NHD 3rd order calculated ratio (to be somehere in the middle of the network)
#'
#' @name scalingByBasin
#'
#' @param scalingModel: Horton laws, already fit to ephemeral field data
#' @param rivNetFin: nhd hydrography for a given huc4 basin
#' @param results: results file for a given huc4 basin
#' @param huc4: HUC4 basin code
#'
#' @import dplyr
#'
#' @return updated results dataframe with scaled and scaled_flowing results
scalingByBasin <- function(scalingModel, rivNetFin, results, huc4){
  #fit horton laws to this river system (east vs west of Mississippi, different scaling)
  numNewOrders <- 1 - scalingModel$ephMinOrder

  #num flowing days per earlier rain analysis
  numFlowingDays <- results$num_flowing_dys

  #number and average discharge of ephemeral streams
  df <- dplyr::filter(rivNetFin, perenniality == 'ephemeral') %>%
      dplyr::group_by(StreamOrde) %>%
      dplyr::summarise(n=n(),
                Qbar = mean(Q_cms, na.rm=T),
                Qbar_adj = mean(Q_cms, na.rm=T) * (365/numFlowingDays))

  #rewrte stream orders for scaling (when appropritate)
  if(numNewOrders > 0){
    df$old_orders <- df$StreamOrde
    df$StreamOrde <- df$StreamOrde + numNewOrders

    #get horton ratios
    lm <- lm(log(n)~StreamOrde, data=df)
    Rb <- 1/exp(lm$coefficient[2]) #Horton law parameter for num streams
    lm2 <- lm(log(Qbar)~StreamOrde, data=df)
    Rq <- exp(lm2$coefficient[2]) #Horton law parameter for mean Q
    lm3 <- lm(log(Qbar_adj)~StreamOrde, data=df)
    Rq_f <- exp(lm3$coefficient[2]) #Horton law parameter for mean flowing Q

    #scale to new minimum order
    for (i in 1:numNewOrders){
      new <- data.frame('StreamOrde'=i, 'n'=NA, 'Qbar'=NA)
      new$old_orders <- NA
      new$n <- df[df$StreamOrde == max(df$StreamOrde),]$n*Rb^(max(df$StreamOrde) - i)
      if(i ==1){ #do first order first (as its different)
        new$Qbar <- (df[df$StreamOrde == 3,]$Qbar)/(Rq^(df[df$StreamOrde == 3,]$StreamOrde - 1)) #ratio using 3rd order
        new$Qbar_adj <- (df[df$StreamOrde == 3,]$Qbar_adj)/(Rq_f^(df[df$StreamOrde == 3,]$StreamOrde - 1)) #ratio using 3rd order
      }
      else{ #do all other additional orders (if necessary)
        new$Qbar <- df[df$StreamOrde == 1,]$Qbar*Rq^(i-1)
        new$Qbar_adj <- df[df$StreamOrde == 1,]$Qbar*Rq_f^(i-1)
      }
      df <- rbind(df, new)
    }

    df <- df[order(df$StreamOrde), ]

    #get water volume in additional stream order
    additionalQ <- sum(df[1:numNewOrders,]$Qbar * df[1:numNewOrders,]$n) #mean annual
    additionalQ_flowing <- sum(df[1:numNewOrders,]$Qbar_adj * df[1:numNewOrders,]$n) #mean annual flowing

    scalingFlag <- 1
  }

  #when no additional scaling is done
  else{
    additionalQ <- 0
    additionalQ_flowing <- 0
    scalingFlag <- 0
  }

  #adding scaled results to previous results
  results$totalephmeralQ_scaled <- results$totalephmeralQ + additionalQ #mean annual
  results$percQ_eph_scaled <- results$totalephmeralQ_scaled / (results$totalephmeralQ_scaled + results$totalNotEphQ) #mean annual percent
  results$totalephmeralQ_flowing_scaled <- results$totalephmeralQ_flowing + additionalQ_flowing #mean annual flowing
  results$percQ_eph_flowing_scaled <- results$totalephmeralQ_flowing_scaled / (results$totalephmeralQ_flowing_scaled + results$totalNotEphQ) #mean annual flowing percent

  results$scalingFlag <- scalingFlag

  return(results)
}
