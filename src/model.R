## Primary model functions that are leveraged throughout the ~/src/analysis.R functions (that facilitate the actual analysis)
## Craig Brinkerhoff
## Fall 2022





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
#' @param lakeAreaSqKm: fractional lake surface area per reach [km2]
#'
#' @return status: perennial, intermittent, or ephemeral
perenniality_func_fan <- function(wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12, width, depth, thresh, err, conus, lakeAreaSqKm){
  if(conus == 0){ #foreign stream handling
    return('foreign')
  } else if(is.na(sum(wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12)) > 0) { #there are some NA WTDs for very short reaches that consist only of 'perennial boundary conditions' in the water table model, i.e. ocean or great lakes
    return('non_ephemeral')
  } else if(any(c(wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12) < (thresh+err+(-1*depth)))){
      if(all(c(wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12) < (thresh+err+(-1*depth)))){ #all wtd must not intersect river
        if(!(is.na(lakeAreaSqKm)) & lakeAreaSqKm >= 0.01){ #main ponded water following Schmadel 2019
          return('non_ephemeral')
        }
        else{
          return('ephemeral') 
        }
      } else{
        return('non_ephemeral')
      }
    }
    else{
      return('non_ephemeral')
  }
}




#' Update reach ephemerality/perenniality using routing
#'
#' @name routing_perenniality_update
#'
#' @param fromNode: upstream-end reach node
#' @param toNode_vec: full network vector of downstream-end reach nodes
#' @param curr_perr: current perenniality status
#' @param perenniality_vec: full network vector of current perenniality statuses. This is amended online during routing.
#' @param order_vec: full network vector of stream orders
#' @param curr_Q: reach discharge [m3/s]
#' @param Q_vec: full network vector of discharges [m3/s]
#'
#' @return updated perenniality status
perenniality_func_update <- function(fromNode, toNode_vec, curr_perr, perenniality_vec, order_vec, curr_Q, Q_vec){
  upstream_reaches <- which(toNode_vec == fromNode)

  foreignBig <- sum(perenniality_vec[upstream_reaches] == 'foreign' & order_vec[upstream_reaches] > 1) #scenario where incoming foreign reach is likely not ephemeral, i.e. a not-headwater (1st order) stream

  out <- curr_perr #otherwise, leave as is
  if(any(perenniality_vec[upstream_reaches] == 'non_ephemeral')) { #assumption: once a river turns non-ephemeral, it stays that way downstream
    out <- 'non_ephemeral'
  }
  else if(foreignBig > 0 & curr_perr != 'foreign') { #account for perennial rivers inflowing from Canada/Mexico
    out <- 'non_ephemeral'
  }

  return(out)
}




#' Calculates lateral discharge / new water / runoff contribution for a reach
#'
#' @name getdQdX
#'
#' @param fromNode: upstream-end reach node
#' @param toNode_vec: full network vector of downstream-end reach nodes
#' @param curr_perr: current perenniality status
#' @param curr_Q: reach discharge [m3/s]
#' @param Q_vec: full network vector of discharges [m3/s]
#'
#' @return dQ per reach
getdQdX <- function(fromNode, toNode_vec, curr_perr, curr_Q, Q_vec){
  upstream_reaches <- which(toNode_vec == fromNode)
  upstreamQ <- sum(Q_vec[upstream_reaches], na.rm=T)

  out <- curr_Q - upstreamQ #dQ per stream reach
  return(out)
}



#' Calculate % ephemeral contribution for some accumulated property in a reach in the network.
#' Used to get % water volume or drainage area ephemeral (calculated for the 'property' param)
#'
#' @name getPercEph
#'
#' @note: set up for either discharge or drainage area (the 'property' param)
#'
#' @param fromNode: upstream-end reach node
#' @param toNode_vec: full network vector of downstream-end reach nodes
#' @param curr_perr: current perenniality status
#' @param curr_dQ: reach lateral runoff [m3/s]
#' @param curr_dArea: reach lateral drainage area [km2]
#' @param curr_Property: reach accumulated property [m3/s] or [km2]
#' @param Property_vec: full network vector of accumulated property [m3/s] or [km2]
#' @param percEph_vec: full network vector of percent property [%]
#' @param property: 'discharge' or 'drainageArea'
#'
#' @return percent water volume ephemeral per reach
getPercEph <- function(fromNode, toNode_vec, curr_perr, curr_dQ, curr_dArea, curr_Property, Property_vec, percEph_vec, property){
  #get upstream reaches
  upstream_reaches <- which(toNode_vec == fromNode)

  #setup upstream parameters
  upstreamProperties <- Property_vec[upstream_reaches]
  upstream_percEphs <- percEph_vec[upstream_reaches]

  #set ethier discharge or drainage area
  lateralProperty <- ifelse(property == 'discharge', curr_dQ, curr_dArea)

  upstream_value <- sum(upstreamProperties * upstream_percEphs, na.rm = T)

  #if non-ephemeral losing stream has no upstream ephemeral value, set flag back to zero (handles ost streamflow too)
  Ephflag <- ifelse(curr_perr == 'non_ephemeral', 0, 1)
  
  #if losing stream, set the weight to zero as it's not contributing anything to the stream
  lateralProperty <- ifelse(lateralProperty < 0, 0, lateralProperty)
  
  #weighted mean of the streamflow contributions (lateral + n upstream contributions, weighted by discharge)
  out <- weighted.mean(c(upstream_percEphs, Ephflag), c(upstreamProperties, lateralProperty))
  
  #handle 0 drainage areas creating infinite values (only a handful)
  out <- ifelse(!(is.finite(out)), 0, out)

  return(out)
}
