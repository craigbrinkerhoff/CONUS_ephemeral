library(targets)
library(dplyr)
library(sf)

path_to_data <- '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data' #path to data repo (separate from code repo)
codes_huc02 <- c('01','02','11', '12', '13','14','15','16') #HUC2 regions to get gage data. Make sure these match the HUC4s that are being mapped below

nhd01 <- tar_read(scaledResult_01)
nhd02 <- tar_read(scaledResult_02)
nhd06 <- tar_read(scaledResult_06)
#nhd11 <- tar_read(scaledResult_11)
#nhd12 <- tar_read(scaledResult_12)
nhd11_12 <- tar_read(scaledResult_11_12)
nhd13 <- tar_read(scaledResult_13)
nhd14 <- tar_read(scaledResult_14)
nhd15 <- tar_read(scaledResult_15)
#nhd14_15 <- tar_read(scaledResult_14_15)
nhd16 <- tar_read(scaledResult_16)

df <- rbind(nhd01, nhd02, nhd06, nhd11_12, nhd13, nhd14, nhd15, nhd16)
df[3,]$HUC2 <- '11_12'

print(sum(df$ephemeralQ)/sum(df$totalQ))

#read in all HUC4 basins------------------
basins_overall <- st_read(paste0(path_to_data, '/HUC2_', codes_huc02[1], '/WBD_', codes_huc02[1], '_HU2_Shape/Shape/WBDHU2.shp')) %>% select(c('huc2', 'name'))
for(i in codes_huc02[-1]){
  basins <- st_read(paste0(path_to_data, '/HUC2_', i, '/WBD_', i, '_HU2_Shape/Shape/WBDHU2.shp')) %>% select(c('huc2', 'name')) #basin polygons
  if(i == '11'){
    temp <- basins
    next
  }
  if (i == '12'){
    temp2 <- st_union(temp, basins) %>%
        select(c('huc2', 'name'))
    temp2$huc2 <- '11_12'
    temp2$name <- 'Arkansas-White-red region & Texas-Gulf region'
    basins_overall <- rbind(basins_overall, temp2)
    next
  }
  basins_overall <- rbind(basins_overall, basins)
}

#join model results
basins_overall <- left_join(basins_overall, df, by=c('huc2'='HUC2'))



if (!file.exists('cache/results_fin.shp')) {
  st_write(basins_overall, 'cache/results_fin.shp')
  } else {
  st_write(basins_overall, 'cache/results_fin.shp', append=FALSE)
  }

#write.csv(df, 'cache/currResults.csv')
