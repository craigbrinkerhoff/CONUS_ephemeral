###########################
## Mask WTD model to North America
## Craig Brinkerhoff
## Fall 2022
############################
huc4 <- '0903'
huc2 <- substr(huc4, 1, 2)
path_to_data <- '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data'

wtd <- terra::rast('/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/for_ephemeral_project/NAMERICA_WTD_monthlymeans.nc')
conus <- terra::vect('/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/other_shapefiles/cb_2018_us_nation_20m.shp')
basins <- terra::vect(paste0(path_to_data, '/HUC2_', huc2, '/WBD_', huc2, '_HU2_Shape/Shape/WBDHU4.shp')) #basin polygon
basin <- basins[basins$huc4 == huc4,]

wtd <- terra::crop(wtd, basin)
wtd_mask <- terra::mask(wtd, conus)
