## Utility functions
## Spring 2022
## Craig Brinkerhoff




#' Specifies how the water table depth pixels along each river reach are summarized.
#'
#' @name summariseWTD
#'
#' @param wtd: vector of water table depths along a stream reach
#'
#' @return out: summarized water table depth
summariseWTD <- function(wtd){
  median <- median(wtd, na.rm=T)
  mean <- mean(wtd, na.rm=T)
  min <- min(wtd, na.rm=T)
  max <- max(wtd, na.rm=T)
  return(list('median'=median,
              'mean'=mean,
              'min'=min,
              'max'=max))
}





#' width for rivers
#'
#' @name width_func
#'
#' @param waterbody: flag for whether reach is a river or lake/reservoir #[1/0]
#' @param Q: discharge [m3/s]
#' @param a: width~Q AHG model intercept
#' @param b: width~Q AHG model coefficient
#'
#' @return river width via hydraulic geometry [m]
width_func <- function(waterbody, Q, a, b){
  if (waterbody == 'River') {
    output <- exp(a)*Q^(b) #river width [m]
  }
  else {
    output <- NA #river width makes no sense in lakes so don't do it!
  }
  return(output)
}






#' depth for rivers or lakes/reservoirs
#'
#' @name depth_func
#'
#' @param waterbody: flag for whether reach is a river or lake/reservoir [1/0]
#' @param Q: discharge [m3/s]
#' @param lakeVol: lake/reservoir volume, using fraction assigned to this flowline [m3]
#' @param lakeArea: lake/reservoir surface area, using fraction assigned to this flowline [m2]
#' @param c: depth~Q AHG model intercept
#' @param f: depth~Q AHG model coefficient
#'
#' @return channel depth via hydraulic geometry [m]
depth_func <- function(waterbody, Q, lakeVol, lakeArea, c, f) {
  if (waterbody == 'River') {
    output <- exp(c)*Q^(f) #river depth [m]
  }
  else {
    output <- lakeVol/lakeArea #mean lake depth [m]
  }
  return(output)
}





#' Adds 'memory days' to number of flowing days timeseries given a lag time.
#' 
#' @note This function specifically avoids double counting flowing days, by only adding memory flowing days if the day is not already tagged as flowing
#'
#' @name addingRunoffMemory
#'
#' @param precip: flowing on/off binary timeseries as a vector [0/1]
#' @param memory: number of days lag that runoff is still being generated from a rain event [days]
#' @param thresh: runoff threshold (expressed as precip) as set in main analysis [m]
#'
#' @return updated flowing on/off binary timeseries (with lagged days now flagged as flowing too)
addingRunoffMemory <- function(precip, memory, thresh){
  precip <- precip[is.na(precip)==0]
  if(length(precip)==0){return(NA)}
  
  #set up binary vectors
  precip <- precip >= thresh
  orig <- precip

  if(memory == 0){
    out <- sum(precip)
  }
  else{
    #propogate memory for days following runoff events
    for(i in 1:length(precip)){
      if(precip[i] == 1 & orig[i] == 1){
        for(k in seq(1+i,memory+i,1)){
          precip[k] <- 1
        }
      }
    }

    #sum up flowing days
    out <- sum(precip)
  }

  return(out)
}





#' Propagates linear combination of uniform Q errors given a sample size and sigma term. Returns in km3/yr
#'
#' @name QlaterrorPropogation
#'
#' @param sigma: uniform uncertainty term (1 sigma)
#' @param n: number of reaches/terms to sum
#'
#' @return linear, uniform, error propagation [km3/yr]
# QlaterrorPropogation <- function(sigma, n) {
#   out <- sqrt(sigma^2*n)*365*86400*1e-9 #km3/yr equivalent: sqrt(n)*sigma*86400*365*1e-9
#   return(out)
# }





#' get appropriate UTM zone from longitude
#'
#' @name long2UTM
#'
#' @param long: Longitude
#'
#' @return UTM zone (N) as numeric
long2UTM <- function(long) {
    out <- (floor((long + 180)/6) %% 60) + 1
    return(out)
}





#' Fixes geometries that are saved as multicurves rather than multilines
#'
#' @name fixGeometries
#'
#' @param rivnet: river network hydrography object
#'
#' @import dplyr
#' @import sf
#'
#' @return updated (if necessary) river network object
fixGeometries <- function(rivnet){
  curveLines <- dplyr::filter(rivnet, sf::st_geometry_type(rivnet) == 'MULTICURVE')
  if(nrow(curveLines) > 0){ #if saved as a curve, recast geometry as a line
    rivnet <- sf::st_cast(rivnet, 'MULTILINESTRING')
  }

  return(rivnet)
}



#' calculates mode of distribution
#' 
#' @name getMode
#' 
#' @param v: vector of values
#' 
#' @return mode of distribution of v
getMode <- function(v){
  v <- v[!is.na(v)]
  uniqv <- unique(v)
  out <- uniqv[which.max(tabulate(match(v, uniqv)))]
  
  return(out)
}





#' Aggregates combined targets at each processing level into a single dataset of basin results
#'
#' @name aggregateAllLevels
#'
#' @param combined_levels_lvlx: combined targets for each processing level
#'
#' @return data frame of all combined targets at each processing level into a single dataset of basin flux results
aggregateAllLevels <- function(combined_lvl0, combined_lvl1, combined_lvl2, combined_lvl3, combined_lvl4,
                               combined_lvl5, combined_lvl6, combined_lvl7, combined_lvl8, combined_lvl9,
                               combined_lvl10, combined_lvl11, combined_lvl12, combined_lvl13, combined_lvl14,
                               combined_lvl15, combined_lvl16, combined_lvl17, combined_lvl18){
  
  #aggregate our model results at huc4
  out <- rbind(combined_lvl0, combined_lvl1, combined_lvl2, combined_lvl3, combined_lvl4,
               combined_lvl5, combined_lvl6, combined_lvl7, combined_lvl8, combined_lvl9,
               combined_lvl10, combined_lvl11, combined_lvl12, combined_lvl13, combined_lvl14,
               combined_lvl15, combined_lvl16, combined_lvl17, combined_lvl18)
  
  out$huc4 <- substr(out$method, 11, 16)
  out$huc2 <- substr(out$huc4, 1, 2)
  
  return(out)
}





#' Plots and saves mean annual hydrographs so we can manually verify these are 'more ephemeral than intermittent' (and vice versa)
#'
#' @name ephemeralityChecker
#'
#' @param other_sites: df with all the gage IDs
#' 
#' @import ggplot2
#' @import dplyr
#' @import dataRetrieval
#'
#' @return writes plots to file
ephemeralityChecker <- function(other_sites) {
  other_sites$wy_eph_gages <- substr(other_sites$name, 6,nchar(other_sites$name))
  
  wy_eph_Q <- data.frame()
  for(i in other_sites$wy_eph_gages){
    gageQ <- readNWISstat(siteNumbers = i, #check if site mets our date requirements
                        parameterCd = '00060') #discharge
    
    #get mean annual flow
    if(nrow(gageQ)==0){next} #some go these gages don't have their data online (in local USGS offices only.....)
    
    gageQ <- gageQ %>% 
      dplyr::mutate(Q_cms = mean_va*0.0283)#cfs to cms with zero flow rounding protocol following:  https://doi.org/10.1029/2021GL093298,  https://doi.org/10.1029/2020GL090794
    
    gageQ$index <- 1:nrow(gageQ)
    
    end <- gageQ[1,]$end_yr
    begin <- gageQ[1,]$begin_yr

    plot <- ggplot(gageQ, aes(x=index, y=Q_cms)) +
      geom_line() +
      ggtitle(paste0(begin, '-', end)) +
      xlab('Date') +
      ylab('Q [cms]')
    
    ggsave(paste0('cache/check_usgs_eph_hydrographs/', i, '.jpg'),plot, width=15, height=7)
    
  }
  return(wy_eph_Q)
}