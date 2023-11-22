## Craig Brinkerhoff
## functions to build shapefiles from results (both model and validation results)
## Fall 2023



#' Joins all HUC4 shapefiles + results into a single shapefile for mapping
#'
#' @name saveShapefile
#'
#' @param path_to_data: data repo path directory
#' @param codes_huc02: all HUC level 2 regions
#' @param combined_results: all model results aggregated into single target
#'
#' @import sf
#' @import dplyr
#'
#' @return print statement + the sf object
saveShapefile <- function(path_to_data, codes_huc02, combined_results){
  #read in all HUC4 basins
  basins_overall <- sf::st_read(paste0(path_to_data, '/HUC2_', codes_huc02[1], '/WBD_', codes_huc02[1], '_HU2_Shape/Shape/WBDHU4.shp')) %>% dplyr::select(c('huc4', 'name'))
  for(i in codes_huc02[-1]){
    basins <- sf::st_read(paste0(path_to_data, '/HUC2_', i, '/WBD_', i, '_HU2_Shape/Shape/WBDHU4.shp')) %>% dplyr::select(c('huc4', 'name')) #basin polygons
    basins_overall <- rbind(basins_overall, basins)
  }

  #join model results
  basins_overall <- dplyr::left_join(basins_overall, combined_results, by='huc4')

  #round for mapping
  basins_overall <- dplyr::select(basins_overall, c('huc4', 'name', 'num_flowing_dys', 'mean_date_flowing', 'percQEph_exported', 'percAreaEph_exported', 'perc_length_eph', 'QEph_exported_cms', 'AreaEph_exported_km2', 'geometry'))
  basins_overall <- dplyr::filter(basins_overall, is.na(percQEph_exported)==0) #remove international basins that don't flow into US at all
  
  #return shapefile
  return(list('note'='see cache/results_fin.shp',
              'shapefile'=basins_overall))
}








#' Joins all HUC2 shapefiles + validation results into a single shapefile for mapping
#'
#' @name saveValShapefile
#'
#' @param path_to_data: data repo path directory
#' @param codes_huc02: all HUC level 2 regions
#' @param validationResults: all validation results aggregated into single target
#'
#' @import sf
#' @import dplyr
#'
#' @return summary stats for validation + the sf object shapefile
saveValShapefile <- function(path_to_data, codes_huc02, validationResults){
  #read in all HUC2 basins and make a single shapefile
  basins_overall <- sf::st_read(paste0(path_to_data, '/HUC2_', codes_huc02[1], '/WBD_', codes_huc02[1], '_HU2_Shape/Shape/WBDHU2.shp')) %>%
      dplyr::select(c('huc2', 'name'))
  for(i in codes_huc02[-1]){
    basins <- sf::st_read(paste0(path_to_data, '/HUC2_', i, '/WBD_', i, '_HU2_Shape/Shape/WBDHU2.shp')) %>%
        dplyr::select(c('huc2', 'name')) #basin polygons
    basins_overall <- rbind(basins_overall, basins)
  }

  #join validation results
    #distinction == ground truth, perenniality == model prediction
  out <- validationResults$validation_fin
  out$TP <- ifelse(out$distinction == 'ephemeral' & out$perenniality == 'ephemeral', 1, 0)
  out$FP <- ifelse(out$distinction == 'non_ephemeral' & out$perenniality == 'ephemeral', 1, 0)
  out$TN <- ifelse(out$distinction == 'non_ephemeral' & out$perenniality == 'non_ephemeral', 1, 0)
  out$FN <- ifelse(out$distinction == 'ephemeral' & out$perenniality == 'non_ephemeral', 1, 0)

  out$huc2 <- substr(out$huc4, 1, 2)

  #calculate classification stats (round for mapping).
  out <- dplyr::group_by(out, huc2) %>%
            dplyr::summarise(basinAccuracy = round((sum(TP) + sum(TN))/(sum(TP) + sum(TN) + sum(FN) + sum(FP)),2),
                      basinSensitivity = round(sum(TP)/(sum(TP)+sum(FN)),2), #also referred to as recall
                      basinSpecificity = round(sum(TN)/(sum(TN)+sum(FP)),2),
                      n_total=sum(TP) + sum(TN) + sum(FN) + sum(FP),
                      n_eph = sum(distinction == 'ephemeral'),
                      n_not_eph = sum(distinction == 'non_ephemeral'))
  out$basinTSS = round(out$basinSensitivity + out$basinSpecificity - 1, 2) #https://doi.org/10.1111/j.1365-2664.2006.01214.x, https://doi.org/10.1086/713084

  basins_overall <- dplyr::left_join(basins_overall, out, by='huc2')
  basins_overall <- dplyr::select(basins_overall, c('huc2', 'name', 'basinAccuracy', 'basinSensitivity', 'basinSpecificity', 'basinTSS', 'n_total', 'n_eph', 'n_not_eph', 'geometry'))

  #prep output
  out <- list('note'='see cache/validation_fin.shp',
              'average_regional_acc'=mean(basins_overall$basinAccuracy, na.rm=T),
              'average_regional_sens'=mean(basins_overall$basinSensitivity, na.rm=T),
              'average_regional_spec'=mean(basins_overall$basinSpecificity, na.rm=T),
              'average_regional_TSS'=mean(basins_overall$basinTSS, na.rm=T),
              'shapefile'=basins_overall)
  
  return(out)
}
