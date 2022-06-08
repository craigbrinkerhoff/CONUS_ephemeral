dsnPath <- paste0(path_to_data, '/HUC2_', huc2, '/NHDPLUS_H_', huc4, '_HU4_GDB/NHDPLUS_H_', huc4, '_HU4_GDB.gdb')
nhd <- sf::st_read(dsn=dsnPath, layer='NHDFlowline', quiet=TRUE)
nhd <- sf::st_zm(nhd)
temp <- which(is.na(sf::st_is_valid(nhd, NA_on_exception=TRUE))==0) #handle GEOS errors
nhd2 <- nhd[temp,]
return(list('nhd'=nhd, 'temp'=temp, 'out'=nhd2))
nhd <- sf::st_make_valid(nhd) #repair geometries

lakes <- sf::st_read(dsn=dsnPath, layer='NHDWaterbody', quiet=TRUE)
lakes <- sf::st_zm(lakes)
temp <- which(is.na(sf::st_is_valid(lakes, NA_on_exception=TRUE))==0) #handle GEOS errors
lakes <- lakes[temp,]
lakes <- sf::st_make_valid(lakes) #repair geometries
