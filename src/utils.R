## Utility functions
## Winter 2023
## Craig Brinkerhoff




#' Summarizes water table depth along each river reach
#'
#' @name summariseWTD
#'
#' @param wtd: vector of water table depths along a stream reach [m]
#'
#' @return out: summary stats for wtd pixels along a reach [m]
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





#' width for rivers or lakes/reservoirs
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
#' @return river depth via hydraulic geometry [m]
depth_func <- function(waterbody, Q, lakeVol, lakeArea, c, f) {
  if (waterbody == 'River') {
    output <- exp(c)*Q^(f) #river depth [m]
  }
  else {
    output <- lakeVol/lakeArea #mean lake depth [m]
  }
  return(output)
}





#' Adds 'memory days' to number of flowing days timeseries given a memory parameter
#' 
#' @note This function specifically avoids double counting flowing days, by only adding memory flowing days if the day is not already tagged as flowing
#'
#' @name addingRunoffMemory
#'
#' @param precip: flowing on/off binary timeseries as a vector [0/1]
#' @param memory: number of days memory that runoff is still being generated from a rain event [days]
#' @param thresh: runoff threshold (expressed as precip using basin runoff efficiency) [m]
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
    #propagate memory for days following runoff events
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





#' Fixes geometries that are saved as multicurves rather than multilines in the NHD-HR
#'
#' @name fixGeometries
#'
#' @param rivnet: sf object for basin hydrography
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








#' Plots and saves mean annual hydrographs so we can manually verify that they are ephemeral and not intermittent
#'
#' @name ephemeralityChecker
#'
#' @param other_sites: df with all the gauge IDs
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
    if(nrow(gageQ)==0){next} #some of these gauges don't have their data online...
    
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