## Utility functions
## Spring 2022
## Craig Brinkerhoff




#' Calculates index for potential for water quality degradation due to NWPR + ephemeral streams
#' 
#' @name ephemeralIndexFunc
#' 
#' @param contribution: dimension 1: ephemeral contribution to streamflow
#' @param contribution: dimension 2: ephemeral flow frequency
#' @param contribution: dimension 3: potential for ephemeral contribution to point-source pollution
#' 
#' @return mean of the three dimensions (equation S9)
ephemeralIndexFunc <- function(contribution, landuse, frequency) {
  #make num flowing days a percent
  frequency <- frequency/365
  
  #return metric
  return(mean(c(contribution, frequency, landuse)))
}




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



#' Calculates river ephemerality status using Fan et al 2017 monthly WTD (accounting for non-CONUS streams)
#'
#' @name perenniality_func_fan
#'
#' @param wtd_m_01: Water table depth- January
#' @param wtd_m_02: Water table depth- February
#' @param wtd_m_03: Water table depth- March
#' @param wtd_m_04: Water table depth- April
#' @param wtd_m_05: Water table depth- May
#' @param wtd_m_06: Water table depth- June
#' @param wtd_m_07: Water table depth- July
#' @param wtd_m_08: Water table depth- August
#' @param wtd_m_09: Water table depth- September
#' @param wtd_m_10: Water table depth- October
#' @param wtd_m_11: Water table depth- November
#' @param wtd_m_12: Water table depth- December
#' @param depth: depth derived via hydraulic geomtery or lake volume scaling
#' @param thresh: water table depth threshold for 'perennial'
#' @param err: error tolerance for thresholding
#' @param conus: flag for foreign or not
#'
#' @return status: perennial, intermittent, or ephemeral
perenniality_func_fan <- function(wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12, width, depth, thresh, err, conus){
  if(conus == 0){ #foreign stream handling
    return('foreign')
  } else if(is.na(sum(wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12)) > 0) { #there are some NA WTDs for very short reaches that consist only of 'perennial boundary conditions' in the water table model, i.e. ocean or great lakes
    return('non_ephemeral')
  } else if(any(c(wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12) < (thresh+err+(-1*depth)))){
      if(all(c(wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12) < (thresh+err+(-1*depth)))){ #all wtd must not intersect river
        return('ephemeral')
      } else{
        return('non_ephemeral')
      }
    }
    else{
      return('non_ephemeral')
  }
}



#' Use network routing to clean up WTD model predicted ephemerality, i.e. those downstream of perennial rivers (that can't happen unless the stream entirely runs dry!!)
#'
#' @name routing_func
#'
#' @param fromNode: upstream-end reach node
#' @param toNode_vec: full network vector of downstream-end reach nodes
#' @param curr_perr: current perenniality status
#' @param perenniality_vec: full network vector of current perenniality statuses. This is amended online during routing.
#' @param curr_order: reach stream order
#' @param order_vec: full network vector of stream orders
#' @param curr_Q: reach discharge [m3/s]
#' @param Q_vec: full network vector of discharges [m3/s]
#'
#' @return updated perenniality status
routing_func <- function(fromNode, toNode_vec, curr_perr, perenniality_vec, curr_order, order_vec, curr_Q, Q_vec){
  upstream_reaches <- which(toNode_vec == fromNode)

  foreignBig <- sum(perenniality_vec[upstream_reaches] == 'foreign' & order_vec[upstream_reaches] > 1) #scenario where incoming foreign reach is likely not ephemeral (used in final else if statement)

  if(all(is.na(upstream_reaches)) & curr_order > 1){ #implicit routing from other upstream HUC4 basins that flow into this one: if reach order > 1 and no upstream reaches in this huc basin, then set to perennial. Assumption is that it is mainstem and therefore likely perennial
    return('non_ephemeral')
  }
  else if(any(perenniality_vec[upstream_reaches] == 'non_ephemeral')) { #if anything directly upstream is 100% perennial, then so is this river!! Conceptually makes sense at annual timescales, annd also handles some noise in the water table model assigning 'ephemeral' to high order streams
    return('non_ephemeral')
  }
  else if(foreignBig > 0 & curr_perr != 'foreign') { #account for perennial rivers inflowing from Canada/Mexico
    return('non_ephemeral')
  }
  else{
    return(curr_perr) #otherwise, leave as is
  }
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



#' Adds 'memory days' to number of flowing days timeseries given a lag time.
#'    This is to account for delayed runoff from precip via a variety of processes (delayed interflow + overland flow mechanisms)
#'    This function specifically avoids double counting flowing days, by only adding memory flowing days if the day is not already tagged as flowing
#'
#' @name addingRunoffMemory
#'
#' @param precip: flowing on/off binary timeseries as a vector [0/1]
#' @param memory: number of days lag that runoff is still being generated from a rain event [days]
#' @param thresh: runoff threshold as set in main analysis [m]
#'
#' @return updated flowing on/off binary timeseries (with lagged days now flagged as flowing too)
addingRunoffMemory <- function(precip, memory, thresh){
    precip <- precip[is.na(precip)==0]
    if(length(precip)==0){return(NA)}

    orig <- precip
    for(i in 1:length(precip)){
      if(precip[i] == 1 & orig[i] == 1){
        for(k in seq(1+i,memory+i-1,1)){
            precip[k] <- 1
        }
      }
    }
    precip <- sum(precip >= thresh)
    return(precip)
}