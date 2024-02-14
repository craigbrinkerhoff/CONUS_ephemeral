## Primary model functions that are leveraged throughout the ~/src/analysis.R functions (that facilitate the actual analysis)
## Craig Brinkerhoff
## Spring 2024





#' Calculates intial classification of river ephemerality using Fan et al 2017 monthly WTD (accounting for non-CONUS streams)
#'
#' @name perenniality_func_fan
#'
#' @param wtd_m_01: Water table depth- January [m]
#' @param wtd_m_02: Water table depth- February [m]
#' @param wtd_m_03: Water table depth- March [m]
#' @param wtd_m_04: Water table depth- April [m]
#' @param wtd_m_05: Water table depth- May [m]
#' @param wtd_m_06: Water table depth- June [m]
#' @param wtd_m_07: Water table depth- July [m]
#' @param wtd_m_08: Water table depth- August [m]
#' @param wtd_m_09: Water table depth- September [m]
#' @param wtd_m_10: Water table depth- October [m]
#' @param wtd_m_11: Water table depth- November [m]
#' @param wtd_m_12: Water table depth- December [m]
#' @param depth: bankfull depth from hydraulic scaling [m]
#' @param thresh: water table depth threshold for 'perennial' [m]
#' @param err: error tolerance for threshold (not actually used in paper)
#' @param conus: flag for foreign or not [0/1]
#' @param lakeAreaSqKm: fractional lake surface area per reach [km2]
#' @param FCode_riv: river code from NHD-HR
#'
#' @return status: ephemeral || non_ephemeral
perenniality_func_fan <- function(wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12, depth, thresh, err, conus, lakeAreaSqKm, FCode_riv){
  if(conus == 0){ #foreign stream handling
    return('foreign')
  } else if(substr(FCode_riv,1,3) == 336){ #canal/ditch handling
      return('canal_ditch')
  } else if(!(is.na(lakeAreaSqKm)) & lakeAreaSqKm < 0.01){ #small ponds handling (https://doi.org/10.1029/2019GL083937)
      return('small_pond')
  } else if(is.na(sum(wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12)) > 0) { #there are some NA WTDs for very short reaches that consist only of 'perennial boundary conditions' in the water table model, i.e. ocean or great lakes
      return('non_ephemeral')
  } else if(any(c(wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12) < (thresh+err+(-1*depth)))){
      if(all(c(wtd_m_01, wtd_m_02, wtd_m_03, wtd_m_04, wtd_m_05, wtd_m_06, wtd_m_07, wtd_m_08, wtd_m_09, wtd_m_10, wtd_m_11, wtd_m_12) < (thresh+err+(-1*depth)))){ #all twelve months to be ephemeral
        if(!(is.na(lakeAreaSqKm)) & lakeAreaSqKm >= 0.01){ #main ponded water following https://doi.org/10.1029/2019GL083937. See Supplementary Materials S1 for more.
          return('non_ephemeral')
        } else{
          return('ephemeral') #if not a main ponded water, then this is ephemeral!
        }
      } else{
        return('non_ephemeral')
      }
    } else{
        return('non_ephemeral')
      }
}






#' Update reach ephemerality/perenniality using downstream routing
#'
#' @name perenniality_func_update
#'
#' @param fromNode: upstream-end reach node
#' @param toNode_vec: full network vector of downstream-end reach nodes
#' @param curr_perr: current perenniality status
#' @param perenniality_vec: full network vector of current perenniality statuses. This is updated online while routing.
#' @param order_vec: full network vector of stream orders
#' @param curr_Q: reach discharge [m3/s]
#' @param Q_vec: full network vector of discharges [m3/s]
#'
#' @return updated perenniality status
perenniality_func_update <- function(fromNode, toNode_vec, curr_perr, perenniality_vec, order_vec, curr_Q, Q_vec){
  upstream_reaches <- which(toNode_vec == fromNode)

  #scenario where incoming foreign reach is likely not ephemeral (operationally defined as > 1st order stream)
  foreignBig <- sum(perenniality_vec[upstream_reaches] == 'foreign' & order_vec[upstream_reaches] > 1)

  out <- curr_perr #otherwise, leave as is
  if(any(perenniality_vec[upstream_reaches] == 'non_ephemeral')) { #Once a river turns "non-ephemeral" (per our definitions), it stays that way downstream. See Supplementary Materials S1 for more on this.
    out <- 'non_ephemeral'
  }
  else if(foreignBig > 0 & curr_perr != 'foreign') { #account for perennial rivers flowing in from Canada/Mexico- if international river is > stream order 1, we conservatively assume it is non-ephemeral and thus influences the downstream domestic reaches
    out <- 'non_ephemeral'
  }

  return(out)
}





#' Calculate lateral discharge / runoff contribution for an individual reach's catchment
#'
#' @name getdQ
#'
#' @param fromNode: upstream-end reach node
#' @param toNode_vec: full network vector of downstream-end reach nodes
#' @param curr_Q: reach discharge [m3/s]
#' @param Q_vec: full network vector of discharges [m3/s]
#'
#' @return dQ per reach
getdQ <- function(fromNode, toNode_vec, curr_Q, Q_vec){
  upstream_reaches <- which(toNode_vec == fromNode)
  upstreamQ <- sum(Q_vec[upstream_reaches], na.rm=T)

  out <- curr_Q - upstreamQ #dQ per stream reach
  return(out)
}




#' Calculates cumulative drainage area for a reach
#'
#' @name getTotDA
#'
#' @param fromNode: upstream-end reach node
#' @param toNode_vec: full network vector of downstream-end reach nodes
#' @param curr_A: reach's individual catchment ares [km2]
#' @param A_vec: full network vector of cumulative drainage areas [km2]
#'
#' @return cumulative drainage area per reach
getTotDA <- function(fromNode, toNode_vec, curr_A, A_vec){
  upstream_reaches <- which(toNode_vec == fromNode)
  upstreamA <- sum(A_vec[upstream_reaches], na.rm=T)

  out <- upstreamA + curr_A #combine upstream drainage areas with current reach's unit catchment area

  return(out)
}






#' Calculate % ephemeral contribution for discharge or drainage area for a given reach in the network. See manuscript eqs S1-S2
#'
#' @name getPercEph
#'
#' @param fromNode: upstream-end reach node
#' @param toNode_vec: full network vector of downstream-end reach nodes
#' @param curr_perr: current perenniality status
#' @param curr_dQ: reach lateral runoff [m3/s]
#' @param curr_dArea: reach catchment area [km2]
#' @param curr_Property: reach accumulated property [m3/s] or [km2]. This is a flag for which property gets run.
#' @param Property_vec: full network vector of accumulated property [m3/s] or [km2]. This is updated online while routing.
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

  #set either discharge or drainage area
  lateralProperty <- ifelse(property == 'discharge', curr_dQ, curr_dArea)

  #Set ephhemeral flag
  Ephflag <- ifelse(curr_perr != 'ephemeral', 0, 1) #implicitly removes any influence from foreign streams, canals, ditches, etc. Anything not classed strictly as 'ephemeral'
  
  #if net losing stream (i.e. dQ < 0), set the weight to zero as it's not contributing anything to the stream channel
  lateralProperty <- ifelse(lateralProperty < 0, 0, lateralProperty)
  
  #weighted mean of the discharge contributions (lateral + n upstream contributions, weighted by discharge) (Eq. S1-S2 in manuscript)
  out <- weighted.mean(c(upstream_percEphs, Ephflag), c(upstreamProperties, lateralProperty))
  
  #handle 0 drainage areas creating infinite values (only a handful across conus)
  out <- ifelse(!(is.finite(out)), 0, out)

  return(out)
}
