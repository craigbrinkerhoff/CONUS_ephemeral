#########################
## utility functions
## Spring 2022
## Craig Brinkerhoff
#########################

#' Specifies how the water table depth pixels along each river reach are summarized.
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
#' @param waterbody: flag for whether reach is a river or lake/reservoir #[1/0]
#' @param Q: discharge [m3/s]
#' @param widAHG: width~Q AHG model from Brinkerhoff et al (in review GBC)
#'
#' @return river width via hydraulic geometry [m]
width_func <- function(waterbody, Q, a, b){
  if (waterbody == 'River') {
    output <- exp(a)*Q^(b)
  }
  else {
    output <- NA #river width makes no sense in lakes so don't do it!
  }
return(output)
}

#' depth for rivers or lakes/reservoirs
#'
#' @param waterbody: flag for whether reach is a river or lake/reservoir [1/0]
#' @param Q: discharge [m3/s]
#' @param lakeVol: lake/reservoir volume, using fraction assigned to this flowline [m3]
#' @param lakeArea: lake/reservoir surface area, using fraction assigned to this flowline [m2]
#' @param depAHG: depth~Q AHG model from Brinkerhoff et al (in review GBC)
#'
#' @return channel depth via hydraulic geometry [m]
depth_func <- function(waterbody, Q, lakeVol, lakeArea, c, f) {
  if (waterbody == 'River') {
    output <- exp(c)*Q^(f)
  }
  else {
    output <- lakeVol/lakeArea #mean lake depth [m]
  }
  return(output)
}

#' Calculates river perenniality status
#'
#' @param wtd_m_01: Water table depth- January
#' @param wtd_m_01: Water table depth- January
#' @param wtd_m_01: Water table depth- February
#' @param wtd_m_01: Water table depth- March
#' @param wtd_m_01: Water table depth- April
#' @param wtd_m_01: Water table depth- May
#' @param wtd_m_01: Water table depth- June
#' @param wtd_m_01: Water table depth- July
#' @param wtd_m_01: Water table depth- August
#' @param wtd_m_01: Water table depth- September
#' @param wtd_m_01: Water table depth- October
#' @param wtd_m_01: Water table depth- November
#' @param wtd_m_01: Water table depth- December
#' @param depth: depth derived via hydraulic geomtery or lake volume scaling
#' @param thresh: water table depth threshold for 'perennial'
#' @param err: error tolerance for thresholding
#'
#' @return status: perennial, intermittent, or ephemeral
perenniality_func <- function(wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12, depth, thresh, err){
  if(is.na(sum(wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12)) > 0){ #NA handling
    return(NA)
  } else if(any(c(wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12) < (thresh+err+depth))){
      if(all(c(wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12) < (thresh+err+depth))){
        return('ephemeral')
      } else{
        return('nonEph')
      }
    } else{
      return('perennial')
  }
}

#' Use network routing to check for two scenarios that may arise and produce false positive ephemeral streams:
#' 1) 'downstream ephemerak rivers', i.e. modeled ephemeral rivers that have perennial rivers just upstream (physically impossible). These need to be reclassified as perennial.
#' 2) 'gaining ephemeral streams', i.e. modeled ephemeral rivers that have gaining conditions, i.e. groundwater recharge > river outflow. This should be impossible in a truly ephemeral channel as they must be losing streams by nature
#'
#' @param fromNode: upstream-end reach node
#' @param curr_perr: current perenniality status
#' @param toNode_vec: full network vector of downstream-end reach nodes
#' @param perenniality_vec: full network vector of current perenniality statuses. This is amended online (if the river is a perched perennial river)
#'
#' @return updated perenniality status
routing_func <- function(fromNode, curr_perr, toNode_vec, perenniality_vec, order_vec, curr_Q, Q_vec){
  upstream_reaches <- which(toNode_vec == fromNode)

  #implicit routing from other upstream HUC4 basins that flow into this one: if reach order > 1 and no upstream reaches in this huc basin, then set to perennial. Assumption is that it is mainstem and therefore likely perennial
  if(all(is.na(upstream_reaches)) & order_vec > 1){
    return('perennial')
  }
  else if(any(perenniality_vec[upstream_reaches] == 'perennial')) { #if anything directly upstream is 100% perennial, then so is this river!! Handles some noise in the water table model assigning 'ephemeral' to high order streams
    return('perennial')
  }
#  else if(sum(Q_vec[upstream_reaches]) < curr_Q & curr_perr == 'ephemeral'){ #gaining streams must not be ephemeral. This assumes that ephemeral streams must be losing, whether that's due to evaporative or infiltration losses it doesn't matter for this classification
#    return('nonEph')
#  }
  else{
    return(curr_perr) #otherwise, leave as is
  }
}

#' Calculates river perenniality status via Fan + Peckel
#'
#' @name perenniality_func_peckel
#'
#' @param pecekl: Surface water occurence in Landsat record (values are 0-100 corresponding to how much the record is wetted)
#' @param wtd_m_01: Water table depth- January
#' @param wtd_m_01: Water table depth- January
#' @param wtd_m_01: Water table depth- February
#' @param wtd_m_01: Water table depth- March
#' @param wtd_m_01: Water table depth- April
#' @param wtd_m_01: Water table depth- May
#' @param wtd_m_01: Water table depth- June
#' @param wtd_m_01: Water table depth- July
#' @param wtd_m_01: Water table depth- August
#' @param wtd_m_01: Water table depth- September
#' @param wtd_m_01: Water table depth- October
#' @param wtd_m_01: Water table depth- November
#' @param wtd_m_01: Water table depth- December
#' @param depth: depth derived via hydraulic geomtery or lake volume scaling
#' @param thresh: water table depth threshold for 'perennial'
#' @param err: error tolerance for thresholding
#'
#'
#' @note  This model will always overrestimate dry channles and underestaimte ephemeral channels given Peckel resolution. This is why we use scaling later
#'
#' @return status: ephemeral, perennial, not-ephemeral (can't def say which it is), and always dry (no identified water)
perenniality_func_peckel <- function(peckel, wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12, depth, thresh, err){
  if(is.na(sum(wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12)) > 0){ #NA handling
    return(NA)
  }
  else if(any(c(wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12) < (thresh+err+depth))){
    if(all(c(wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12) < (thresh+err+depth))){
      if(peckel > 0){
        return('ephemeral')
      } else{
        return('dry')
      }
    }

    else if(peckel > 0){
      return('nonEph') #stand-in for not def ephemeral and not def perennial, as these ae scenarios where it isn't clear what is genuine and what is model noise. BUT, we can at least say it's not ephemeral
    } else{
      return('dry')
    }
  }
  else {
    if(peckel > 0){
        return('perennial') #stand-in for not def ephemeral and not def perennial, as these ae scenarios where it isn't clear what is genuine and what is model noise. BUT, we can at least say it's not ephemeral
    } else{
      return('dry')
    }
  }
}
