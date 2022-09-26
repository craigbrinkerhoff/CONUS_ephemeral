############
## Craig Brinkerhoff
## functions to make shapefiles from results (both model and validation results)
## Summer 2022
#############



#' Joins all HUC4 shapefiles + results into a single shapefile for mapping
#'
#' @name saveShapefile
#'
#' @param path_to_data: data repo path directory
#' @param codes_huc02: all HUC level 2 regions currently being ran
#' @param combined_results: all model results combined into a single target
#'
#' @import sf
#' @import dplyr
#'
#' @return print statement as it writes to file + the sf object shapefile
saveShapefile <- function(path_to_data, codes_huc02, combined_results){
  #read in all HUC4 basins------------------
  basins_overall <- sf::st_read(paste0(path_to_data, '/HUC2_', codes_huc02[1], '/WBD_', codes_huc02[1], '_HU2_Shape/Shape/WBDHU4.shp')) %>% dplyr::select(c('huc4', 'name'))
  for(i in codes_huc02[-1]){
    basins <- sf::st_read(paste0(path_to_data, '/HUC2_', i, '/WBD_', i, '_HU2_Shape/Shape/WBDHU4.shp')) %>% dplyr::select(c('huc4', 'name')) #basin polygons
    basins_overall <- rbind(basins_overall, basins)
  }

  #join model results
  basins_overall <- dplyr::left_join(basins_overall, combined_results, by='huc4')

  #round for mapping
  basins_overall$percQ_eph_flowing_scaled <- round(basins_overall$percQ_eph_flowing_scaled, 2)
  basins_overall$num_flowing_dys <- round(basins_overall$num_flowing_dys, 0)

  basins_overall <- select(basins_overall, c('huc4', 'name', 'num_flowing_dys', 'percQ_eph_flowing_scaled', 'percQ_eph_scaled', 'percLength_eph', 'percEph_cult_devp', 'geometry'))

  return(list('note'='see cache/results_fin.shp',
              'shapefile'=basins_overall))
}



#' Joins all HUC4 shapefiles + validation results into a single shapefile for mapping
#'
#' @name saveValShapefile
#'
#' @param path_to_data: data repo path directory
#' @param codes_huc02: all HUC level 2 regions currently being ran
#' @param validationResults: all validation results combined into a single target
#'
#' @import sf
#' @import dplyr
#'
#' @return summary stats for validation + the sf object shapefile
saveValShapefile <- function(path_to_data, codes_huc02, validationResults){
  #read in all HUC2 basins------------------
  basins_overall <- sf::st_read(paste0(path_to_data, '/HUC2_', codes_huc02[1], '/WBD_', codes_huc02[1], '_HU2_Shape/Shape/WBDHU2.shp')) %>% dplyr::select(c('huc2', 'name'))
  for(i in codes_huc02[-1]){ #join HUC04 and HUC09 because of too limited data
    basins <- sf::st_read(paste0(path_to_data, '/HUC2_', i, '/WBD_', i, '_HU2_Shape/Shape/WBDHU2.shp')) %>% dplyr::select(c('huc2', 'name')) #basin polygons
    basins_overall <- rbind(basins_overall, basins)
  }

  #join validation results
  out <- validationResults$validation_fin
  out$TP <- ifelse(out$distinction == 'ephemeral' & out$perenniality == 'ephemeral', 1, 0)
  out$FP <- ifelse(out$distinction == 'non_ephemeral' & out$perenniality == 'ephemeral', 1, 0)
  out$TN <- ifelse(out$distinction == 'non_ephemeral' & out$perenniality == 'non_ephemeral', 1, 0)
  out$FN <- ifelse(out$distinction == 'ephemeral' & out$perenniality == 'non_ephemeral', 1, 0)

  out$huc2 <- substr(out$huc4, 1, 2)

  #calculate classification stats (round for mapping). NA removal is to handle our field measured data that doesn't have values yet
  out <- dplyr::group_by(out, huc2) %>%
            dplyr::summarise(basinAccuracy = round((sum(TP, na.rm=T) + sum(TN, na.rm=T))/(sum(TP, na.rm=T) + sum(TN, na.rm=T) + sum(FN, na.rm=T) + sum(FP, na.rm=T)),2),
                      basinSensitivity = round(sum(TP, na.rm=T)/(sum(TP,na.rm=T)+sum(FN,na.rm=T)),2), #also referred to as recall
                      basinSpecificity = round(sum(TN, na.rm=T)/(sum(TN,na.rm=T)+sum(FP,na.rm=T)),2),
                      n_total=sum(TP, na.rm=T) + sum(TN, na.rm=T) + sum(FN, na.rm=T) + sum(FP, na.rm=T),
                      n_eph = sum(distinction == 'ephemeral', na.rm=T),
                      n_not_eph = sum(distinction == 'non_ephemeral', na.rm=T))
  out$basinTSS = round(out$basinSensitivity + out$basinSpecificity - 1, 2) #Allouche etal 2006, used in CONUS ephemeral mapping by Fesenmyer etal 2021

  basins_overall <- dplyr::left_join(basins_overall, out, by='huc2')
  basins_overall <- dplyr::select(basins_overall, c('huc2', 'name', 'basinAccuracy', 'basinSensitivity', 'basinSpecificity', 'basinTSS', 'n_total', 'n_eph', 'n_not_eph', 'geometry'))

  return(list('note'='see cache/validation_fin.shp',
              'average_regional_acc'=mean(basins_overall$basinAccuracy, na.rm=T),
              'average_regional_sens'=mean(basins_overall$basinSensitivity, na.rm=T),
              'average_regional_spec'=mean(basins_overall$basinSpecificity, na.rm=T),
              'average_regional_TSS'=mean(basins_overall$basinTSS, na.rm=T),
              'shapefile'=basins_overall))
}
