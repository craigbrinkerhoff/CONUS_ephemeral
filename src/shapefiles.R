############
## Craig Brinkerhoff
## aggreagte results outside of Targets pipeline
## Spring 2022
#############

library(targets)
library(dplyr)
library(sf)

#user settings------------------------------------------
huc2 <- '11'
path_to_data <- 'C:\\Users\\craig\\OneDrive - University of Massachusetts\\Ongoing Projects\\CONUS_CO2_prep' #path to data repo (seperate from code repo)

df <- tar_read(combined_results)

#svae to shapefile-----------------------------------
basins <- st_read(paste0(path_to_data, '\\HUC2_', huc2, '\\WBD_', huc2, '_HU2_Shape\\Shape\\WBDHU4.shp')) #basin polygons
basins <- select(basins, 'huc4')
basins <- left_join(basins, df, by='huc4')

if (!file.exists(paste0('cache/shapefiles/results_', huc2, '.shp'))){
  st_write(basins, paste0('cache/shapefiles/results_', huc2, '.shp'))
  } else {
  st_write(basins, paste0('cache/shapefiles/results_', huc2, '.shp'), append=FALSE)
  }