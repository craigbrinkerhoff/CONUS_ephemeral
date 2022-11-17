#'
#'
#'
#' #' Scales model results to additional stream order(s) if necessary. Horton ratio used in this calcualtion comes from the NHD 3rd order calculated ratio (to be somehere in the middle of the network)
#' #'
#' #' @name scalingdQdX
#' #'
#' #' @note the dQdX is updated (via scaling Qbar) for a single scenario: headwater non_ephemeral streams that have 'upland scaled ephemeral streams'.
#' #'       So, the dQdX in the river network files are raw (unaffected by scaling) but here they are obviously changed
#' #'
#' #' @param rivNetFin: nhd hydrography for a given huc4 basin
#' #' @param scalingModel: Horton laws, already fit to ephemeral field data
#' #' @param huc4: HUC4 basin code
#' #'
#' #' @import dplyr
#' #'
#' #' @return list of needed scaling results + rivnet hydrography model with updated dQdX when appropriate
#' scaleNetwork <- function(rivNetFin, scalingModel, huc4){
#'   #FIT HORTON SCALING TO EACH BASIN-------------
#'   numNewOrders <- 1 - scalingModel$ephMinOrder
#'
#'   #length and number of ephemeral streams per stream order
#'   df <- dplyr::filter(rivNetFin, perenniality == 'ephemeral') %>%
#'     dplyr::group_by(StreamOrde) %>%
#'     dplyr::summarise(n=n(), #overall ephemeral scaling
#'                      length = mean(LengthKM, na.rm=T))
#'   df$cummLength <- ifelse(df$StreamOrde == 1, df$length, NA)
#'   for (i in 2:nrow(df)){ #convert to cummulative mean length, used for horton scaling
#'     df[i,]$cummLength <- df[i,]$length + sum(df[which(df$StreamOrde < i),]$length, na.rm=T)
#'   }
#'
#'   #rewrite stream orders for scaling (when appropriate, set up for scaling multiple orders even though for our analysis it ends up only doing 1 order)
#'   if(numNewOrders > 0){
#'     df$old_orders <- df$StreamOrde
#'     df$StreamOrde <- df$StreamOrde + numNewOrders
#'
#'     #get horton ratios
#'     lm <- lm(log(n)~StreamOrde, data=df)
#'     Rb <- 1/exp(lm$coefficient[2]) #Horton law parameter for num streams
#'
#'     lm2 <- lm(log(cummLength)~StreamOrde, data=df)
#'     Rl <- exp(lm2$coefficient[2]) #Horton law parameter for stream order mean length
#'
#'     #scale to new minimum order
#'     for (i in 1:numNewOrders){
#'       new <- data.frame('StreamOrde'=i, 'n'=NA, 'length'=NA, 'cummLength'=NA)
#'       new$old_orders <- NA
#'       new$n <- df[df$StreamOrde == max(df$StreamOrde),]$n*Rb^(max(df$StreamOrde) - i)
#'
#'       if(i ==1){ #do first order first (as its different, ratio using 3rd order)
#'         new$length <- (df[df$StreamOrde == 3,]$cummLength)/(Rl^(df[df$StreamOrde == 3,]$StreamOrde - 1))* new$n #cummlbar * numstreams
#'       }
#'       else{ #do all other additional orders (if necessary)
#'         new$length <- df[df$StreamOrde == 1,]$cummLength*Rl^(i-1) * new$n #cummlbar * numstreams
#'       }
#'       df <- rbind(df, new)
#'     }
#'
#'     df <- df[order(df$StreamOrde), ]
#'
#'     #SETUP SCALED PROPERTIES USING THE MOST UPLAND HYDROGRAPHY (i.e. not-scaled) STREAM ORDER------------------------------
#'     #cult/devp stream length (using the smallest non-scaled order in the model via numNewOrders)
#'     cultDevpRatio <- sum(rivNetFin[rivNetFin$StreamOrde == numNewOrders & rivNetFin$nlcd_broad %in% c(20,70),]$LengthKM)/sum(rivNetFin[rivNetFin$StreamOrde == numNewOrders,]$LengthKM)
#'     df$cultDevpCummLength <- df[numNewOrders,]$length * cultDevpRatio
#'
#'     #Use median relative dQdX for 'trouble reaches' (using the smallest non-scaled order in the model via numNewOrders)
#'     medianQratio <- 1-median(rivNetFin[rivNetFin$StreamOrde == numNewOrders+1,]$dQdX_cms / rivNetFin[rivNetFin$StreamOrde == numNewOrders+1,]$Q_cms) #ratio of increasing downstream flow
#'     medianARatio <- 1-median(rivNetFin[rivNetFin$StreamOrde == numNewOrders+1,]$AreaSqKm / rivNetFin[rivNetFin$StreamOrde == numNewOrders+1,]$TotDASqKm) #ratio of increasing downstream drainage area
#'
#'     #REDISTRIBUTE ACCUMULATED FLOW (AND DRAINAGE AREA) FROM TERMINAL, NON-EPHEMERAL (domestic) STREAMS TO UPLAND SCALED EPHEMERAL STREAMS-----------------------------
#'     #first, get the 'trouble' reaches that this applies to (note: this code assumes only one additional scaled order is being added....)
#'     rivNetFin$trouble <- ifelse(rivNetFin$perenniality == 'non_ephemeral' & rivNetFin$StreamOrde == numNewOrders & (rivNetFin$dQdX_cms == rivNetFin$Q_cms), 1,0) #terminal non-ephemeral streams that need dQ re-mapped to account for upland ephemeral scaled contributions accumulated in these reaches
#'
#'     #update trouble reach dQdX using the scaled Qbar as the fromNode discharge value
#'     rivNetFin$dQdX_cms <- ifelse(rivNetFin$trouble == 1, (rivNetFin$Q_cms - rivNetFin$Q_cms*medianQratio), rivNetFin$dQdX_cms) #cms
#'     rivNetFin$AreaSqKm <- ifelse(rivNetFin$trouble == 1, rivNetFin$AreaSqKm - rivNetFin$AreaSqKm*medianARatio, rivNetFin$AreaSqKm) #km2
#'
#'     #Re-distribute this scaled accumulated flow/drainage area for every trouble reach's upland ephemeral network
#'     additionalQ_cms <- sum(rivNetFin[rivNetFin$trouble == 1,]$Q_cms*medianQratio, na.rm=T) #mean annual cms
#'     additionalA_km2 <- sum(rivNetFin[rivNetFin$trouble == 1,]$AreaSqKm*medianARatio, na.rm=T) #km2
#'
#'     #GET NUMBER, LENGTH, AND DISCHARGE IN ADDITIONAL STREAM ORDER(s)------------------
#'     additionalCultDevpLength_km <- sum(df[1:numNewOrders,]$cultDevpCummLength) #km applied to entire network
#'     additionalLength_km <- sum(df[1:numNewOrders,]$length) #km
#'     additionalN <- round(sum(df[1:numNewOrders,]$n),0) #n streams applied to entire network
#'   }
#'
#'   #if no additional scaling is done (doesn't actually happen in this setup)
#'   else{
#'     additionalQ_cms <- 0
#'     additionalA_km2 <- 0
#'     additionalLength_km <- 0
#'     additionalCultDevpLength_km <- 0
#'     additionalN <- 0
#'   }
#'
#'   return(list('rivNet_scaled'=rivNetFin,
#'               'additionalQ_cms'=additionalQ_cms,
#'               'additionalA_km2' = additionalA_km2,
#'               'additionalLength_km'=additionalLength_km,
#'               'additionalCultDevpLength_km'=additionalCultDevpLength_km,
#'               'additionalN_total'=additionalN))
#' }
#'
#'
#'
#' #' Tabulates model summary statistics at the huc 4 level after scaling additional stream order(s)
#' #'
#' #' @name collectResults
#' #'
#' #' @param rivNetFin_scaled: list of model and scaled results
#' #' @param numFlowingDays: mean annual ephemeral days flowing
#' #' @param huc4: huc basin level 4 code
#' #'
#' #' @return summary statistics
#' collectResults <- function(rivNetFin_scaled, numFlowingDays, huc4){
#'   #breakup list into important bits
#'   nhd_df <- rivNetFin_scaled$rivNet_scaled
#'   additionalQ_cms <- rivNetFin_scaled$additionalQ_cms #cms
#'   additionalN_total <- rivNetFin_scaled$additionalN_total #scaled ephemeral streams
#'   additionalCultDevpLength_km <- rivNetFin_scaled$additionalCultDevpLength_km
#'   additionalLength_km <- rivNetFin_scaled$additionalLength_km
#'   additionalA_km2 <- rivNetFin_scaled$additionalA_km2 #km2
#'
#'   #concatenate and generate initial (not scaled) results
#'   results_nhd <- data.frame(
#'     'huc4'=huc4,
#'     'num_flowing_dys'=numFlowingDays,
#'
#'     'notEphNetworkLength_km' = sum(nhd_df[nhd_df$perenniality != 'ephemeral',]$LengthKM, na.rm=T),
#'     'ephemeralNetworkLength_km' = sum(nhd_df[nhd_df$perenniality == 'ephemeral',]$LengthKM, na.rm=T) + additionalLength_km,
#'     'ephemeralCultDevpNetworkLength_km'=sum(nhd_df[nhd_df$perenniality == 'ephemeral' & nhd_df$nlcd_broad %in% c(20,70),]$LengthKM, na.rm=T) + additionalCultDevpLength_km,
#'
#'     'totalephemeralQ_cms'=sum(nhd_df[nhd_df$perenniality == 'ephemeral',]$dQdX_cms, na.rm=T) + additionalQ_cms, #with 'trouble' reaches fixed and scaled in scaleNetwork()
#'     'totalNotEphQ_cms'=sum(nhd_df[nhd_df$perenniality != 'ephemeral',]$dQdX_cms, na.rm=T), #with 'trouble' reaches fixed in scaleNetwork()
#'
#'     'totalephemeralArea_km2'=sum(nhd_df[nhd_df$perenniality == 'ephemeral',]$AreaSqKm, na.rm=T) + additionalA_km2, #with 'trouble' reaches fixed and scaled in scaleNetwork()
#'     'totalNotEphArea_km2'=sum(nhd_df[nhd_df$perenniality != 'ephemeral',]$AreaSqKm, na.rm=T), #with 'trouble' reaches fixed in scaleNetwork()
#'
#'     'n_eph'=nrow(nhd_df[nhd_df$perenniality == 'ephemeral',]), #num streams
#'     'n_noteph'=nrow(nhd_df[nhd_df$perenniality != 'ephemeral',]),
#'     'additionalN_total'=additionalN_total)
#'
#'   #get the relative percents (uses accumulated Q because the accumulated terms cancel out; avoids difficult calculations of accumulated flow)
#'   results_nhd$percQ_eph <- results_nhd$totalephemeralQ_cms / (results_nhd$totalNotEphQ_cms + results_nhd$totalephemeralQ_cms)
#'   results_nhd$percArea_eph <- results_nhd$totalephemeralArea_km2 / (results_nhd$totalNotEphArea_km2 + results_nhd$totalephemeralArea_km2)
#'   results_nhd$percLength_eph_cult_devp =  results_nhd$ephemeralCultDevpNetworkLength_km/((results_nhd$ephemeralNetworkLength_km + results_nhd$notEphNetworkLength_km))
#'   results_nhd$percNumFlowingDys <- results_nhd$num_flowing_dys / 365
#'
#'   return(results_nhd)
#' }
