############
## Craig Brinkerhoff
## aggreagte results outside of Targets pipeline
## Spring 2022
#############

#' Joins all HUC4 shapefiles into a single shapefile
#'
#' @name saveShapefile
#'
#' @param path_to_data: data repo path directory
#' @param codes_huc02: all HUC level 2 regions currently being ran
#' @param combined_results: all model results combined into a single target
#'
#' @import sf
#'
#' @return print statement as it writes to file
saveShapefile <- function(path_to_data, codes_huc02, combined_results){
  #read in all HUC4 basins------------------
  basins_overall <- st_read(paste0(path_to_data, '/HUC2_', codes_huc02[1], '/WBD_', codes_huc02[1], '_HU2_Shape/Shape/WBDHU4.shp')) %>% select(c('huc4', 'name'))
  for(i in codes_huc02[-1]){
    basins <- st_read(paste0(path_to_data, '/HUC2_', i, '/WBD_', i, '_HU2_Shape/Shape/WBDHU4.shp')) %>% select(c('huc4', 'name')) #basin polygons
    basins_overall <- rbind(basins_overall, basins)
  }

  #join model results
  basins_overall <- left_join(basins_overall, combined_results, by='huc4')

  if (!file.exists('cache/results_fin.shp')) {
    st_write(basins_overall, 'cache/results_fin.shp')
    } else {
    st_write(basins_overall, 'cache/results_fin.shp', append=FALSE)
    }

  return('see cache/results_fin.shp')
}
