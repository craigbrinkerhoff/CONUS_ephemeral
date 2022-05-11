############
## Main functions
## Craig Brinkerhoff
## Spring 2022
#################

#' extracts water table depth at the NHD flowlines. How the pixels are summarized at each reach is specified in the summariseWTD() function within '~/src/utils.R``
#' 
#' @note Be aware of the expilict repo structure within the data repo, i.e. even though the user specifies the path to the data repo, there are assumed internal folders.
#' 
#' @param path_to_data: data repo path directory
#' @param huc4: huc basin level 4 code
#' 
#' @import terra
#' @import sf
#' @import dplyr
#' 
#' @return NHD hydrograpy with mean monthly water table depths attached.
extractWTD <- function(path_to_data, huc4){
  huc2 <- substr(huc4, 1, 2)
  
  #get basin to clip wtd model
  basins <- vect(paste0(path_to_data, '\\HUC2_', huc2, '\\WBD_', huc2, '_HU2_Shape\\Shape\\WBDHU4.shp')) #basin polygon
  
  #Process-based water table depth modeling Fan etal 2013 (updated in 2020: doi:10.1126/science.1229881)
  #monthly averages for hourly model runs for 2004-2014
  wtd <- rast(paste0(path_to_data, '/for_ephemeral_project/NAMERICA_WTD_monthlymeans.nc'))

    #USGS NHD
  dsnPath <- paste0(path_to_data, '\\HUC2_', huc2, '\\NHDPLUS_H_', huc4, '_HU4_GDB\\NHDPLUS_H_', huc4, '_HU4_GDB.gdb')
  nhd <- st_read(dsn=dsnPath, layer='NHDFlowline', quiet=TRUE)
  NHD_HR_EROM <- st_read(dsn = dsnPath, layer = "NHDPlusEROMMA", quiet=TRUE) #mean annual flow table
  #NHD_HR_ROMA <- st_read(dsn = dsnPath, layer='NHDPlusIncrROMA')
  NHD_HR_VAA <- st_read(dsn = dsnPath, layer = "NHDPlusFlowlineVAA", quiet=TRUE) #additional 'value-added' attributes
  basin <- basins[basins$huc4 == huc4,]

  #clip wtd data to basin at hand
  wtd <- crop(wtd, basin)
  
  nhd <- left_join(nhd, NHD_HR_EROM, by='NHDPlusID')
  nhd <- left_join(nhd, NHD_HR_VAA, by='NHDPlusID')
  nhd$Q_cms <- nhd$QEMA * 0.0283 #cfs to cms
  nhd <- filter(nhd, StreamCalc > 0 & Q_cms > 0) #no pipelines, connectors, canals. Only rivers/streams and 'artificial paths', ie.e. lake throughflow lines. Also- even epehmeral streams should have a mean annual flow > 0...
  nhd <- vect(nhd)

  nhd_wtd_01 <- extract(wtd$WTD_1, nhd, fun=summariseWTD)
  nhd_wtd_02 <- extract(wtd$WTD_2, nhd, fun=summariseWTD)
  nhd_wtd_03<- extract(wtd$WTD_3, nhd, fun=summariseWTD)
  nhd_wtd_04 <- extract(wtd$WTD_4, nhd, fun=summariseWTD)
  nhd_wtd_05 <- extract(wtd$WTD_5, nhd, fun=summariseWTD)
  nhd_wtd_06<- extract(wtd$WTD_6, nhd, fun=summariseWTD)
  nhd_wtd_07 <- extract(wtd$WTD_7, nhd, fun=summariseWTD)
  nhd_wtd_08 <- extract(wtd$WTD_8, nhd, fun=summariseWTD)
  nhd_wtd_09 <- extract(wtd$WTD_9, nhd, fun=summariseWTD)
  nhd_wtd_10 <- extract(wtd$WTD_10, nhd, fun=summariseWTD)
  nhd_wtd_11<- extract(wtd$WTD_11, nhd, fun=summariseWTD)
  nhd_wtd_12 <- extract(wtd$WTD_12, nhd, fun=summariseWTD)

  nhd_df <- as.data.frame(nhd)
  nhd_df <- select(nhd_df, c('NHDPlusID', 'StreamOrde', 'HydroSeq', 'FromNode', 'ToNode','Q_cms', 'LengthKM'))

  nhd_df$wtd_m_min_01 <- as.numeric(nhd_wtd_01$WTD_1.min)
  nhd_df$wtd_m_median_01 <- as.numeric(nhd_wtd_01$WTD_1.median)
  nhd_df$wtd_m_mean_01 <- as.numeric(nhd_wtd_01$WTD_1.mean)
  nhd_df$wtd_m_max_01 <- as.numeric(nhd_wtd_01$WTD_1.max)
  
  nhd_df$wtd_m_min_02 <- as.numeric(nhd_wtd_02$WTD_2.min)
  nhd_df$wtd_m_median_02 <- as.numeric(nhd_wtd_02$WTD_2.median)
  nhd_df$wtd_m_mean_02 <- as.numeric(nhd_wtd_02$WTD_2.mean)
  nhd_df$wtd_m_max_02 <- as.numeric(nhd_wtd_02$WTD_2.max)
  
  nhd_df$wtd_m_min_03 <- as.numeric(nhd_wtd_03$WTD_3.min)
  nhd_df$wtd_m_median_03 <- as.numeric(nhd_wtd_03$WTD_3.median)
  nhd_df$wtd_m_mean_03 <- as.numeric(nhd_wtd_03$WTD_3.mean)
  nhd_df$wtd_m_max_03 <- as.numeric(nhd_wtd_03$WTD_3.max)
  
  nhd_df$wtd_m_min_04 <- as.numeric(nhd_wtd_04$WTD_4.min)
  nhd_df$wtd_m_median_04 <- as.numeric(nhd_wtd_04$WTD_4.median)
  nhd_df$wtd_m_mean_04 <- as.numeric(nhd_wtd_04$WTD_4.mean)
  nhd_df$wtd_m_max_04 <- as.numeric(nhd_wtd_04$WTD_4.max)
  
  nhd_df$wtd_m_min_05 <- as.numeric(nhd_wtd_05$WTD_5.min)
  nhd_df$wtd_m_median_05 <- as.numeric(nhd_wtd_05$WTD_5.median)
  nhd_df$wtd_m_mean_05 <- as.numeric(nhd_wtd_05$WTD_5.mean)
  nhd_df$wtd_m_max_05 <- as.numeric(nhd_wtd_05$WTD_5.max)
  
  nhd_df$wtd_m_min_06 <- as.numeric(nhd_wtd_06$WTD_6.min)
  nhd_df$wtd_m_median_06 <- as.numeric(nhd_wtd_06$WTD_6.median)
  nhd_df$wtd_m_mean_06 <- as.numeric(nhd_wtd_06$WTD_6.mean)
  nhd_df$wtd_m_max_06 <- as.numeric(nhd_wtd_06$WTD_6.max)
  
  nhd_df$wtd_m_min_07 <- as.numeric(nhd_wtd_07$WTD_7.min)
  nhd_df$wtd_m_median_07 <- as.numeric(nhd_wtd_07$WTD_7.median)
  nhd_df$wtd_m_mean_07 <- as.numeric(nhd_wtd_07$WTD_7.mean)
  nhd_df$wtd_m_max_07 <- as.numeric(nhd_wtd_07$WTD_7.max)
  
  nhd_df$wtd_m_min_08 <- as.numeric(nhd_wtd_08$WTD_8.min)
  nhd_df$wtd_m_median_08 <- as.numeric(nhd_wtd_08$WTD_8.median)
  nhd_df$wtd_m_mean_08 <- as.numeric(nhd_wtd_08$WTD_8.mean)
  nhd_df$wtd_m_max_08 <- as.numeric(nhd_wtd_08$WTD_8.max)
  
  nhd_df$wtd_m_min_09 <- as.numeric(nhd_wtd_09$WTD_9.min)
  nhd_df$wtd_m_median_09 <- as.numeric(nhd_wtd_09$WTD_9.median)
  nhd_df$wtd_m_mean_09 <- as.numeric(nhd_wtd_09$WTD_9.mean)
  nhd_df$wtd_m_max_09 <- as.numeric(nhd_wtd_09$WTD_9.max)
  
  nhd_df$wtd_m_min_10 <- as.numeric(nhd_wtd_10$WTD_10.min)
  nhd_df$wtd_m_median_10 <- as.numeric(nhd_wtd_10$WTD_10.median)
  nhd_df$wtd_m_mean_10 <- as.numeric(nhd_wtd_10$WTD_10.mean)
  nhd_df$wtd_m_max_10 <- as.numeric(nhd_wtd_10$WTD_10.max)
  
  nhd_df$wtd_m_min_11 <- as.numeric(nhd_wtd_11$WTD_11.min)
  nhd_df$wtd_m_median_11 <- as.numeric(nhd_wtd_11$WTD_11.median)
  nhd_df$wtd_m_mean_11 <- as.numeric(nhd_wtd_11$WTD_11.mean)
  nhd_df$wtd_m_max_11 <- as.numeric(nhd_wtd_11$WTD_11.max)
  
  nhd_df$wtd_m_min_12 <- as.numeric(nhd_wtd_12$WTD_12.min)
  nhd_df$wtd_m_median_12 <- as.numeric(nhd_wtd_12$WTD_12.median)
  nhd_df$wtd_m_mean_12 <- as.numeric(nhd_wtd_12$WTD_12.mean)
  nhd_df$wtd_m_max_12 <- as.numeric(nhd_wtd_12$WTD_12.max)

  return(nhd_df) 
}

#' Estimates reach perenniality status for the NHD
#' 
#' @param nhd_df: nhd hydrography with mean monthly water table depths already joined to hydrography
#' @param huc4: huc basin level 4 code
#' @param thresh: threshold for 'persistent surface groundwater'
#' @param err: error tolerance for calculation. This should reflect reisdual model error in the groundwater flow model
#' @param summarizer: metric to summarise wtd along the reach: min, max, mean, or mode. Default is median
#' @param widAHG: width~Q AHG model from Brinkerhoff et al (in review GBC)
#' 
#' @import dplyr
#' @import readr
#' 
#' @return NHD hydrography with perenniality status
getPerenniality <- function(nhd_df, huc4, thresh, err, summarizer, widAHG){
  huc2 <- substr(huc4, 1, 2)
  
  #estimate river width using hydraulic geometry
  nhd_df$width_m <- exp(widAHG$coefficients[1])*nhd_df$Q_cms^(widAHG$coefficients[2])
    
  ######INTIAL PASS AT ASSIGNING PERENNIALITY------------------
  if(summarizer == 'median'){
    nhd_df$perenniality <- mapply(perenniality_func, nhd_df$wtd_m_median_01, nhd_df$wtd_m_median_02, nhd_df$wtd_m_median_03, nhd_df$wtd_m_median_04, nhd_df$wtd_m_median_05, nhd_df$wtd_m_median_06, nhd_df$wtd_m_median_07, nhd_df$wtd_m_median_08, nhd_df$wtd_m_median_09, nhd_df$wtd_m_median_10, nhd_df$wtd_m_median_11, nhd_df$wtd_m_median_12, thresh, err)
  } else if(summarizer == 'mean'){
    nhd_df$perenniality <- mapply(perenniality_func, nhd_df$wtd_m_mean_01, nhd_df$wtd_m_mean_02, nhd_df$wtd_m_mean_03, nhd_df$wtd_m_mean_04, nhd_df$wtd_m_mean_05, nhd_df$wtd_m_mean_06, nhd_df$wtd_m_mean_07, nhd_df$wtd_m_mean_08, nhd_df$wtd_m_mean_09, nhd_df$wtd_m_mean_10, nhd_df$wtd_m_mean_11, nhd_df$wtd_m_mean_12, thresh, err)
  } else if(summarizer == 'min'){
    nhd_df$perenniality <- mapply(perenniality_func, nhd_df$wtd_m_min_01, nhd_df$wtd_m_min_02, nhd_df$wtd_m_min_03, nhd_df$wtd_m_min_04, nhd_df$wtd_m_min_05, nhd_df$wtd_m_min_06, nhd_df$wtd_m_min_07, nhd_df$wtd_m_min_08, nhd_df$wtd_m_min_09, nhd_df$wtd_m_min_10, nhd_df$wtd_m_min_11, nhd_df$wtd_m_min_12, thresh, err)
  } else if(summarizer == 'max'){
    nhd_df$perenniality <- mapply(perenniality_func, nhd_df$wtd_m_max_01, nhd_df$wtd_m_max_02, nhd_df$wtd_m_max_03, nhd_df$wtd_m_max_04, nhd_df$wtd_m_max_05, nhd_df$wtd_m_max_06, nhd_df$wtd_m_max_07, nhd_df$wtd_m_max_08, nhd_df$wtd_m_max_09, nhd_df$wtd_m_max_10, nhd_df$wtd_m_max_11, nhd_df$wtd_m_max_12, thresh, err)
  } else { #default is median
    nhd_df$perenniality <- mapply(perenniality_func, nhd_df$wtd_m_median_01, nhd_df$wtd_m_median_02, nhd_df$wtd_m_median_03, nhd_df$wtd_m_median_04, nhd_df$wtd_m_median_05, nhd_df$wtd_m_median_06, nhd_df$wtd_m_median_07, nhd_df$wtd_m_median_08, nhd_df$wtd_m_median_09, nhd_df$wtd_m_median_10, nhd_df$wtd_m_median_11, nhd_df$wtd_m_median_12, thresh, err)
  }
  
  #drop potential NA perennial streams, i.e. those with NA water table depths. I've come across a single one of these so far....
  nhd_df <- nhd_df[is.na(nhd_df$perenniality)==0,]
    
  #####ROUTING---------------------------
  #now, route through network and identify 'perched perennial rivers', i.e. those supposedly above the water table that are always flowing because of upstream perennial rivers
  #sort rivers from upstream to downstream
  nhd_df <- filter(nhd_df, HydroSeq != 0)
  nhd_df <- nhd_df[order(-nhd_df$HydroSeq),] #sort descending
  
  #vectorize nhd to help with speed
  fromNode_vec <- as.vector(nhd_df$FromNode)
  toNode_vec <- as.vector(nhd_df$ToNode)
  perenniality_vec <- as.vector(nhd_df$perenniality)
  order_vec <- as.vector(nhd_df$StreamOrde)
  Q_vec <- as.vector(nhd_df$Q_cms)
  
  #run vectorized model
  for (i in 1:nrow(nhd_df)) {
    perenniality_vec[i] <- routing_func(fromNode_vec[i], perenniality_vec[i], toNode_vec, perenniality_vec, order_vec[i], Q_vec[i], Q_vec)
  }
  
  nhd_df$perenniality <- perenniality_vec
    
  #save some example HUCs
  if(huc4 %in% c('1103', '1111', '0108', '1603')){
    write_csv(nhd_df, paste0('cache/reaches_', huc4, '.csv'))
  }
  
  out <- nhd_df %>% select('NHDPlusID','ToNode', 'StreamOrde', 'Q_cms', 'width_m', 'LengthKM', 'perenniality')
  return(out)
}

#' Tabulates summary statistics (namely % discharge and % surface area) at the huc 4 level
#' 
#' @param nhd_df: NHD hydrography with river perenniality status
#' @param huc4: huc basin level 4 code
#' 
#' @return summary statistics
collectResults <- function(nhd_df, huc4){
  results_nhd <- data.frame(
    'huc4'=huc4,
    'perennialNetworkSA' = sum(nhd_df[nhd_df$perenniality == 'perennial',]$LengthKM*nhd_df[nhd_df$perenniality == 'perennial',]$width_m*1000, na.rm=T),
    'ephemeralNetworkSA' = sum(nhd_df[nhd_df$perenniality == 'ephemeral',]$LengthKM*nhd_df[nhd_df$perenniality == 'ephemeral',]$width_m*1000, na.rm=T),
    'intermittentNetworkSA' = sum(nhd_df[nhd_df$perenniality == 'intermittent',]$LengthKM*nhd_df[nhd_df$perenniality == 'intermittent',]$width_m*1000, na.rm=T),
    'totalperennialQ' = sum(nhd_df[nhd_df$perenniality == 'perennial',]$Q_cms, na.rm=T),
    'totalephmeralQ' = sum(nhd_df[nhd_df$perenniality == 'ephemeral',]$Q_cm, na.rm=T),
    'totalintermittentQ' = sum(nhd_df[nhd_df$perenniality == 'intermittent',]$Q_cm, na.rm=T))
  
  results_nhd$percQ_eph <- results_nhd$totalephmeralQ / sum(results_nhd$totalperennialQ, results_nhd$totalephmeralQ, results_nhd$totalintermittentQ)
  results_nhd$percQ_int <- results_nhd$totalintermittentQ / sum(results_nhd$totalperennialQ, results_nhd$totalephmeralQ, results_nhd$totalintermittentQ)
  results_nhd$percQ_per <- results_nhd$totalperennialQ / sum(results_nhd$totalperennialQ, results_nhd$totalephmeralQ, results_nhd$totalintermittentQ)
  
  results_nhd$percSA_eph <- results_nhd$ephemeralNetworkSA / sum(results_nhd$ephemeralNetworkSA, results_nhd$intermittentNetworkSA, results_nhd$totalperennialQ)
  results_nhd$percSA_int <- results_nhd$intermittentNetworkSA / sum(results_nhd$ephemeralNetworkSA, results_nhd$intermittentNetworkSA, results_nhd$totalperennialQ)
  results_nhd$percSA_per <- results_nhd$totalperennialQ / sum(results_nhd$ephemeralNetworkSA, results_nhd$intermittentNetworkSA, results_nhd$totalperennialQ)
  
  return(results_nhd)
}
