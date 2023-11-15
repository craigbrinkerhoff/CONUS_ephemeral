## Map functions for Stanford job talk
## Craig Brinkerhoff
## Spring 2023




#' prepping sf object for easy in-memory mapping
#'
#' @name indvRiverMaps
#'
#' @param results: data repo directory path
#' @param huc4: huc4 id code
#'
#' @import sf
#' @import dplyr
#' @import ggplot2
#' @import cowplot
#'
#' @return land use results figure (also writes figure to file)
indvRiverMaps <- function(results, huc4){
	 huc2 <- substr(huc4, 1, 2)
	 huc4 <- ifelse(nchar(huc4)==5,substr(huc4,1,4),huc4)

	 if(huc4 %in% c('0418', '0419', '0424', '0426', '0428')){
	 	return(NA)
	 }
	else{
    	# Import shapefile
  		shapefile <- sf::st_read(dsn = paste0(path_to_data, '/HUC2_', huc2, '/NHDPLUS_H_', huc4, '_HU4_GDB/NHDPLUS_H_', huc4, '_HU4_GDB.gdb'), layer='NHDFlowline') %>%
  			sf::st_zm() %>%
  			dplyr::left_join(results, by='NHDPlusID') %>%
  			dplyr::filter(!is.na(percQEph_reach))

  		#fix multicurves (if necessary)
  		shapefile <- fixGeometries(shapefile)


    	#remove foreign streams
    	if('foreign' %in% unique(shapefile$perenniality)) {
    		states <- sf::st_read(paste0(path_to_data, '/other_shapefiles/cb_2018_us_state_5m.shp'))
    		states <- dplyr::filter(states, !(NAME %in% c('Alaska',
                                                'American Samoa',
                                                'Commonwealth of the Northern Mariana Islands',
                                                'Guam',
                                                'District of Columbia',
                                                'Puerto Rico',
                                                'United States Virgin Islands',
                                                'Hawaii'))) #remove non CONUS states/territories
  			states <- sf::st_union(states)

    		shapefile <- sf::st_intersection(shapefile, states)
    	}
  	
  		# Adding column based on other column:
  		fin<-shapefile %>%
  			dplyr::filter(percQEph_reach < 1) %>% #remove the uplan ephemeral reaches that are of course 100%...
    		dplyr::mutate(percQEph_cat_3 = dplyr::case_when(
      			percQEph_reach <= 0.60 ~ '0-60'
      			,percQEph_reach <= 0.80 ~ '60-80'
      			,percQEph_reach <= 0.90 ~ '80-90'
      			,percQEph_reach <= 0.95 ~ '90-95'
      			,TRUE ~ '95-100'
    			)) %>%
    		dplyr::mutate(percQEph_cat_2 = dplyr::case_when(
      			percQEph_reach <= 0.60 ~ '0-60'
      			,percQEph_reach <= 0.70 ~ '60-70'
      			,percQEph_reach <= 0.80 ~ '70-80'
      			,percQEph_reach <= 0.90 ~ '80-90'
      			,TRUE ~ '90-100'
    			)) %>%  
    		dplyr::mutate(percQEph_cat = dplyr::case_when(
      			percQEph_reach <= 0.20 ~ '0-20'
      			,percQEph_reach <= 0.40 ~ '20-40'
      			,percQEph_reach <= 0.60 ~ '40-60'
      			,percQEph_reach <= 0.80 ~ '60-80'
      			,TRUE ~ '80-100'
    			)) %>%    		
    		dplyr::select(c('percQEph_cat', 'percQEph_cat_2', 'percQEph_cat_3', 'Q_cms'))


    	fin$percQEph_cat_3 <- factor(fin$percQEph_cat_3, levels = c('0-60', '60-80', '80-90', '90-95', '95-100'))
    	fin$percQEph_cat_2 <- factor(fin$percQEph_cat_2, levels = c('0-60', '60-70', '70-80', '80-90', '90-100'))
    	fin$percQEph_cat <- factor(fin$percQEph_cat, levels = c('0-20', '20-40', '40-60', '60-80', '80-100'))
  	return(fin)
	}
}






#' actual mapping of entire US river network
mainMapFunction <- function(mapList, map_0107, map_0108,map_0109,map_0110,map_0106, map_0104, map_0430, map_0202){
	#remove NAs (great lakes)
	mapList <- mapList[!is.na(mapList)]

	theme_set(theme_classic())

	states <- sf::st_read('/nas/cee-water/cjgleason/craig/canada_shapefile/na_shp_fin.shp')

	# CONUS boundary--------------------------------------
  	# states <- sf::st_read(paste0(path_to_data, '/other_shapefiles/cb_2018_us_state_5m.shp'))
  	# states <- dplyr::filter(states, !(NAME %in% c('Alaska',
    #                                             'American Samoa',
    #                                             'Commonwealth of the Northern Mariana Islands',
    #                                             'Guam',
    #                                             'District of Columbia',
    #                                             'Puerto Rico',
    #                                             'United States Virgin Islands',
    #                                             'Hawaii'))) #remove non CONUS states/territories
  	# states <- sf::st_union(states)

	# #Canada boundary
	# canada <- sf::st_read('/nas/cee-water/cjgleason/craig/canada_shapefile/lpr_000b16a_e.shp')
	# canada <- sf::st_make_valid(canada)
	# canada <- sf::st_transform(canada, crs=4326)
	# canada <- sf::st_union(canada)
	# # canada <- sf::st_crop(canada, xmin = -140, xmax = -60,
    # #                          ymin = 30, ymax = 55)

	# #Mexico boundary
	# Mexico <- sf::st_read('/nas/cee-water/cjgleason/craig/canada_shapefile/mex_admbnda_adm0_govmex_20210618.shp')
	# Mexico <- sf::st_make_valid(Mexico)
	# Mexico <- sf::st_transform(Mexico, crs=4326)
	# Mexico <- sf::st_union(Mexico)
	# # Mexico <- sf::st_crop(Mexico, xmin = -140, xmax = -60,
    #                          ymin = 25, ymax = 55)	

  	#BIG MAIN MAP------------------------------------------
	bigMap <- ggplot()+
		geom_sf(data=mapList[[1]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[2]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[3]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[4]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[5]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[6]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[7]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[8]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[9]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[10]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[11]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[12]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[13]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[14]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[15]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[16]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[17]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[18]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[19]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[20]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[21]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[22]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[23]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[24]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[25]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[26]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[27]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[28]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[29]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[30]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[31]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[32]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[33]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[34]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[35]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[36]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[37]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[38]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[39]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[40]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[41]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[42]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[43]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[44]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[45]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[46]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[47]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[48]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[49]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[50]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[51]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[52]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[53]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[54]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[55]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[56]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[57]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[58]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[59]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[60]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[61]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[62]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[63]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[64]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[65]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[66]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[67]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[68]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[69]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[70]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[71]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[72]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[73]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[74]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[75]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[76]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[77]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[78]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[79]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[80]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[81]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[82]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[83]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[84]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[85]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[86]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[87]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[88]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[89]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[90]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[91]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[92]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[93]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[94]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[95]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[96]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[97]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[98]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[99]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[100]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[101]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[102]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[103]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[104]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[105]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[106]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[107]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[108]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[109]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[110]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[111]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[112]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[113]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[114]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[115]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[116]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[117]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[118]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[119]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[120]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[121]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[122]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[123]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[124]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[125]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[126]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[127]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[128]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[129]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[130]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[131]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[132]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[133]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[134]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[135]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[136]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[137]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[138]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[139]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[140]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[141]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[142]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[143]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[144]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[145]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[146]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[147]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[148]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[149]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[150]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[151]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[152]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[153]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[154]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[155]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[156]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[157]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[158]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[159]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[160]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[161]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[162]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[163]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[164]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[165]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[166]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[167]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[168]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[169]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[170]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[171]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[172]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[173]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[174]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[175]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[176]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[177]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[178]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[179]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[180]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[181]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[182]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[183]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[184]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[185]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[186]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[187]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[188]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[189]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[190]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[191]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[192]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[193]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[194]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[195]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[196]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[197]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[198]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[199]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[200]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[201]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[202]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[203]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[204]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data = mapList[[205]], aes(color = percQEph_cat_2),linewidth=0.1) +
		geom_sf(data=states, #conus boundary
        	    color='black',
            	size=0.75,
            	alpha=0)+
		# geom_sf(data=canada, #canada boundary
        # 	    color='black',
        #  	  	size=0.75,
        #     	alpha=0)+
		# geom_sf(data=Mexico, #Mexico boundary
        # 	    color='black',
      	#      	size=0.75,
        #     	alpha=0)+				
	#	scale_color_brewer(palette='YlGnBu', direction=-1,name='% Ephemeral discharge')+
		scale_color_manual(name='% Ephemeral discharge', values=c('#082F6B', '#8D99AE', '#CCDAE0', '#EF233C', '#D90429'))+
	#	scale_alpha_discrete(guide='none')+
	#	scale_size_binned(name='Discharge [cms]',
    #    	breaks=c(0.1, 1,10,100,1000),
    #        range=c(0.2,5),
    #    	guide = 'none')+
	#	scale_alpha_binned(name='Discharge [cms]',
    #    	breaks=c(0.01,1,100,1000),
    #        range=c(0.2,1),
    #    	guide = 'none')+
 		theme(plot.title = element_text(face = "italic", size = 26),
    	  	axis.text = element_text(size = 22),
        	plot.tag = element_text(size=26,
             	                  face='bold'),
        	legend.position=c(0.9,0.15),
 			legend.text = element_text(size=18),
 			legend.title = element_text(size=22,face="bold"),
 			legend.spacing.y = unit(0.1, 'cm'))+
 		guides(color = guide_legend(override.aes = list(size=8), byrow = TRUE))

  	#INSET CENTERING----------------------------------
   	zoom_to <- c( -71.9465,42.9722)#-77.87450,39.52966 71.9505

   	#set up zoom bounds
  	zoom_level <- 3
 	lon_span <- 360 / 5^zoom_level
 	lat_span <- 360 / 5^zoom_level
 	lon_bounds_1 <- c(zoom_to[1] - lon_span / 2, zoom_to[1] + lon_span / 2)
 	lat_bounds_1 <- c(zoom_to[2] - lat_span / 2, zoom_to[2] + lat_span / 2)

 	#set up inset box
     df <- data.frame(lon_bounds_1, lat_bounds_1)
 	box_1 <- df %>% 
   		sf::st_as_sf(coords = c("lon_bounds_1", "lat_bounds_1"), 
            		crs = 4326) %>% 
   		sf::st_bbox() %>% 
   		sf::st_as_sfc()

  	#set up zoom bounds
 	zoom_level <- 4
	lon_span <- 360 / 5^zoom_level
	lat_span <- 360 / 5^zoom_level
	lon_bounds_2 <- c(zoom_to[1] - lon_span / 2, zoom_to[1] + lon_span / 2)
	lat_bounds_2 <- c(zoom_to[2] - lat_span / 2, zoom_to[2] + lat_span / 2)

	#set up inset box
    df <- data.frame(lon_bounds_2, lat_bounds_2)
	box_2 <- df %>% 
  		sf::st_as_sf(coords = c("lon_bounds_2", "lat_bounds_2"), 
           		crs = 4326) %>% 
  		sf::st_bbox() %>% 
  		sf::st_as_sfc()

  	#set up zoom bounds
 	zoom_level <- 5
	lon_span <- 360 / 5^zoom_level
	lat_span <- 360 / 5^zoom_level
	lon_bounds_3 <- c(zoom_to[1] - lon_span / 2, zoom_to[1] + lon_span / 2)
	lat_bounds_3 <- c(zoom_to[2] - lat_span / 2, zoom_to[2] + lat_span / 2)

	#set up inset box
    df <- data.frame(lon_bounds_3, lat_bounds_3)
	box_3 <- df %>% 
  		sf::st_as_sf(coords = c("lon_bounds_3", "lat_bounds_3"), 
           		crs = 4326) %>% 
  		sf::st_bbox() %>% 
  		sf::st_as_sfc()

  	#set up zoom bounds
 	zoom_level <- 6
	lon_span <- 360 / 5^zoom_level
	lat_span <- 360 / 5^zoom_level
	lon_bounds_4 <- c(zoom_to[1] - lon_span / 2, zoom_to[1] + lon_span / 2)
	lat_bounds_4 <- c(zoom_to[2] - lat_span / 2, zoom_to[2] + lat_span / 2)

	#set up inset box
    df <- data.frame(lon_bounds_4, lat_bounds_4)
	box_4 <- df %>% 
  		sf::st_as_sf(coords = c("lon_bounds_4", "lat_bounds_4"), 
           		crs = 4326) %>% 
  		sf::st_bbox() %>% 
  		sf::st_as_sfc()  		


  	#for insets
  	insetNet <- rbind(map_0107, map_0108,map_0109,map_0110,map_0106, map_0104, map_0430, map_0202)

  	#CUSTOM COLOR SCALE-------------------
	myColors <- c('#082F6B', '#8D99AE', '#CCDAE0', '#EF233C', '#D90429') #rev(RColorBrewer::brewer.pal(5,"YlGnBu"))
	names(myColors) <- levels(insetNet$percQEph_cat_2)
	colScale <- scale_colour_manual(name = "percQEph_cat_2",values = myColors)

  	#INSET 1--------------------------------------------------
  	insetShp1 <- sf::st_crop(insetNet, xmin=lon_bounds_1[1], xmax=lon_bounds_1[2], ymin=lat_bounds_1[1], ymax=lat_bounds_1[2])
  	inset1 <- ggplot() +
  		geom_sf(data = insetShp1, aes(color = percQEph_cat_2,size=Q_cms)) +
	  	scale_size_binned(name='Discharge [cms]',
        	breaks=c(0.01,0.1, 1, 10,100,1000),
            range=c(0.3,2.5))+  		
  		geom_sf(data=box_2,
    		color='#fca311',
    		size=3,
    		alpha=0) +
    	ggspatial::annotation_scale(location = "bl",
    							text_col = 'white',
                                height = unit(0.5, "cm"),
                                text_cex = 1,
                            	bar_cols = c("white", "red"))+    		
  		xlab('')+
  		ylab('')+
  		coord_sf(datum=NA) +
    	theme(legend.position='none',
    		  panel.background = element_rect(fill = "black"))

   	#INSET 2--------------------------------------------------
  	insetShp2 <- sf::st_crop(insetNet, xmin=lon_bounds_2[1], xmax=lon_bounds_2[2], ymin=lat_bounds_2[1], ymax=lat_bounds_2[2])    
  	inset2 <- ggplot() +
  		geom_sf(data = insetShp2, aes(color = percQEph_cat_2,size=Q_cms)) +
	  	scale_size_binned(name='Discharge [cms]',
        	breaks=c(0.01,0.1, 1, 10,100,1000),
            range=c(0.3,2.5))+  		
  		geom_sf(data=box_3,
    		color='#fca311',
    		size=3,
    		alpha=0) +
     	ggspatial::annotation_scale(location = "bl",
     							text_col = 'white',
                                height = unit(0.5, "cm"),
                                text_cex = 1,
                            	bar_cols = c("white", "red"))+ 
  		xlab('')+
  		ylab('')+  		
  		coord_sf(datum=NA) +
     	theme(legend.position='none',
     		  panel.background = element_rect(fill = "black"))

  	#INSET 3--------------------------------------------------
  	insetShp3 <- sf::st_crop(insetNet, xmin=lon_bounds_3[1], xmax=lon_bounds_3[2], ymin=lat_bounds_3[1], ymax=lat_bounds_3[2])
 # 	waterbodies <- sf::st_read(dsn = paste0(path_to_data, '/HUC2_03/NHDPLUS_H_0316_HU4_GDB/NHDPLUS_H_0316_HU4_GDB.gdb'), layer='NHDWaterbody') %>%
 # 		dplyr::filter(FType %in% c(390, 436))
 #   waterbodies <- sf::st_crop(waterbodies, xmin=lon_bounds_3[1], xmax=lon_bounds_3[2], ymin=lat_bounds_3[1], ymax=lat_bounds_3[2])
    #waterbodies <- sf::st_join(waterbodies, insetShp3)

  	inset3 <- ggplot() +
  		geom_sf(data = insetShp3, aes(color = percQEph_cat_2,size=Q_cms)) +
#  		geom_sf(data = waterbodies, alpha=0, color='grey',size=1) +  		
	  	scale_size_binned(name='Discharge [cms]',
        	breaks=c(0.01,0.1, 1, 10,100,1000),
            range=c(0.3,2.5))+  		
  		geom_sf(data=box_4,
    		color='#fca311',
    		size=3,
    		alpha=0) +
    	ggspatial::annotation_scale(location = "bl",
    							text_col = 'white',
                                height = unit(0.5, "cm"),
                                text_cex = 1,
                            	bar_cols = c("white", "red"))+   		
    	xlab('')+
  		ylab('')+
  		coord_sf(datum=NA) +
     	theme(legend.position='none',
     		  panel.background = element_rect(fill = "black"))

  	#INSET 4-------------------------------------------------
  	insetShp4 <- sf::st_crop(insetNet, xmin=lon_bounds_4[1], xmax=lon_bounds_4[2], ymin=lat_bounds_4[1], ymax=lat_bounds_4[2])
 # 	waterbodies <- sf::st_read(dsn = paste0(path_to_data, '/HUC2_03/NHDPLUS_H_0316_HU4_GDB/NHDPLUS_H_0316_HU4_GDB.gdb'), layer='NHDWaterbody') %>%
  #		dplyr::filter(FType %in% c(390, 436))
   # waterbodies <- sf::st_crop(waterbodies, xmin=lon_bounds_4[1], xmax=lon_bounds_4[2], ymin=lat_bounds_4[1], ymax=lat_bounds_4[2])
  #  waterbodies <- sf::st_join(waterbodies, insetShp4,  join = st_contains)

  	inset4 <- ggplot() +
  		geom_sf(data = insetShp4, aes(color = percQEph_cat_2,size=Q_cms)) +
	#	geom_sf(data = waterbodies, aes(fill = percQEph_cat)) +  		
	  	scale_size_binned(name='Discharge [cms]',
        	breaks=c(0.01,0.1, 1, 10,100,1000),
            range=c(0.3,2.5))+
    	ggspatial::annotation_scale(location = "bl",
    							text_col = 'white',
                                height = unit(0.5, "cm"),
                                text_cex = 1,
                            	bar_cols = c("white", "red"))+             	
  		xlab('')+
  		ylab('')+
  		coord_sf(datum=NA) +  
     	theme(legend.position='none',
     		  panel.background = element_rect(fill = "black"))

   #ADD INSET 1 BOUNDING BOXES---------------------------------
   bigMap <- bigMap +
   	geom_sf(data=box_1,
   			color='#fca311',
   			size=3,
   			alpha=0)

  	#COMBO PLOT---------------------------------------------
  	 design <- "
  	 	BCDE
  	 "

  	 comboPlot <- patchwork::wrap_plots(B=inset4 + colScale, C=inset3 + colScale, D=inset2 + colScale, E=inset1 + colScale, design=design)

	ggsave(filename="cache/paper_figures/mainMap_1.jpg",plot=bigMap,width=20,height=15)
	ggsave(filename="cache/paper_figures/mainMap_2.jpg",plot=comboPlot,width=20,height=5)
	
	return('see cache/paper_figures/')
}