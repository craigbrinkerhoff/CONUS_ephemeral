# Functions for Monte Carlo uncertainty analysis in test watersheds
# Craig Brinkerhoff
# Fall 2023



#' Run Monte Carlo uncertainty analysis on a given basin
#'
#' @name runMonteCarlo
#'
#' @param huc4: huc4 basin id
#' @param threshold: threshold for initial water table classification
#' @param error: error buffer (here if desired, but set to 0 for the paper results)
#' @param gw_error_model: residuals distribution for gw model (see _targets.R)
#' @param Hb_error_model: residuals distribution for bankfull depth model (see _targets.R)
#' @param seedID: random seed ID for specific MC instance (set using dynamic branching in_targets.R)
#'
#' @return percent water volume ephemeral per reach (for a given MC instance)
runMonteCarlo <- function(huc4, threshold, error, gw_error_model, Hb_error_model, seedID){
  #run model
  extracted <- extractDataMC(path_to_data, huc4, gw_error_model, Hb_error_model) #~src/uncertaintyAnalysis.R
  model <- routeModel(extracted, huc4, threshold, error, NA) #~src/analysis.R
  results <- getResultsExported(model, huc4, NA, NA) #~src/analysis.R #just set num flowing days to NA for this uncertianty exercise

  return(results$percQEph_exported)
}




#' Preps hydrography shapefiles into lightweight routing tables. Also extracts monthly water table depth per streamline
#'
#' @name extractDataMC
#'
#' @note Be aware of the explicit repo structure within the data repo, i.e. even though the user specifies the path to the data repo, there is an assumed internal file structure (see README).
#'
#' @param path_to_data: data repo path directory
#' @param huc4: huc basin level 4 code
#' @param gw_error_model: residuals distribution for gw model
#' @param Hb_error_model: residuals distribution for bankfull depth model
#'
#' @import terra
#' @import sf
#' @import dplyr
#'
#' @return df of NHD-HR routing table with all necessary attributes
extractDataMC <- function(path_to_data, huc4, gw_error_model, Hb_error_model){
  ########SETUP
  indiana_hucs <- c('0508', '0509', '0514', '0512', '0712', '0404', '0405', '0410') #Indiana-effected basins

  sf::sf_use_s2(FALSE)

  huc2 <- substr(huc4, 1, 2)

  #setup physiographic region
  huc4id <- huc4
  shapefile <- sf::st_read(paste0(path_to_data, '/HUC2_', huc2, '/WBD_', huc2, '_HU2_Shape/Shape/WBDHU4.shp')) %>% dplyr::select(c('huc4', 'name')) %>% dplyr::filter(huc4 == huc4id)

  regions <- sf::st_read(paste0(path_to_data, '/other_shapefiles/physio.shp')) #physiographic regions
  regions <- fixGeometries(regions)

  shapefile <- sf::st_join(shapefile, regions, largest=TRUE) #take the physiogrpahic region that the basin is mostly in (dominant intersection)
  physio_region <- shapefile$DIVISION

  # setup CONUS shapefile
  states <- sf::st_read(paste0(path_to_data,'/other_shapefiles/cb_2018_us_state_5m.shp'))
  states <- dplyr::filter(states, !(NAME %in% c('Alaska',
                                         'American Samoa',
                                         'Commonwealth of the Northern Mariana Islands',
                                         'Guam',
                                         'District of Columbia',
                                         'Puerto Rico',
                                         'United States Virgin Islands',
                                         'Hawaii'))) #remove non CONUS states/territories
  states <- sf::st_union(states)

  ########PULL IN DATA
  #Fan et al 2017 water table depth model
  wtd <- terra::rast(paste0(path_to_data, '/for_ephemeral_project/NAMERICA_WTD_monthlymeans.nc'))   #monthly averages of hourly model runs for 2004-2014 at 1km resolution

  #HUC4 basin at hand
  basins <- terra::vect(paste0(path_to_data, '/HUC2_', huc2, '/WBD_', huc2, '_HU2_Shape/Shape/WBDHU4.shp')) #basin polygon
  basin <- basins[basins$huc4 == huc4,]

  #USGS NHD
  dsnPath <- paste0(path_to_data, '/HUC2_', huc2, '/NHDPLUS_H_', huc4, '_HU4_GDB/NHDPLUS_H_', huc4, '_HU4_GDB.gdb')

  #load river network, depending on Indiana-effect or not (see ~/docs/README_Indiana.html for more details)
  if(huc4 %in% indiana_hucs) {
    nhd <- sf::st_read(paste0(path_to_data, '/HUC2_', huc2, '/indiana/indiana_fixed_', huc4, '.shp'))
    nhd <- sf::st_zm(nhd)
    colnames(nhd)[10] <- 'WBArea_Permanent_Identifier'
    nhd$NHDPlusID <- round(nhd$NHDPlusID, 0)  #remove erronous decimals
  }
  else{
    nhd <- sf::st_read(dsn=dsnPath, layer='NHDFlowline', quiet=TRUE)
    nhd <- sf::st_zm(nhd)
    nhd <- fixGeometries(nhd) #~src/utils.R
  }

  #load waterbodies
  lakes <- sf::st_read(dsn=dsnPath, layer='NHDWaterbody', quiet=TRUE)
  lakes <- sf::st_zm(lakes)

  #filter for lakes/reservoirs only
  lakes <- as.data.frame(lakes) %>%
    dplyr::filter(FType %in% c(390, 436)) #lakes/reservoirs only
  colnames(lakes)[6] <- 'LakeAreaSqKm'
  nhd <- left_join(nhd, lakes, by=c('WBArea_Permanent_Identifier'='Permanent_Identifier'))

  #load additional attributes
  NHD_HR_EROM <- sf::st_read(dsn = dsnPath, layer = "NHDPlusEROMMA", quiet=TRUE) #mean annual flow table
  NHD_HR_VAA <- sf::st_read(dsn = dsnPath, layer = "NHDPlusFlowlineVAA", quiet=TRUE) #additional 'value-added' attributes

  #some manual rewriting b/c this columns get doubled from previous joins where data was needed for specific GIS tasks...
  if(huc4 %in% indiana_hucs){
    colnames(nhd)[17] <- 'NHDPlusID'
    nhd$NHDPlusID <- round(nhd$NHDPlusID, 0) #some of these have digits for some reason......
    colnames(nhd)[12] <- 'FCode_riv'
    colnames(nhd)[31] <- 'FCode_waterbody'
  }
  else{
    colnames(nhd)[16] <- 'NHDPlusID'
    colnames(nhd)[11] <- 'FCode_riv'
    colnames(nhd)[27] <- 'FCode_waterbody'
  }

  #join everything into a single shapefile for basin hydrography
  nhd <- dplyr::left_join(nhd, NHD_HR_EROM, by='NHDPlusID')
  nhd <- dplyr::left_join(nhd, NHD_HR_VAA, by='NHDPlusID')

  #Convert to more useful units
  nhd$StreamOrde <- nhd$StreamCalc #stream calc handles divergent streams correctly: https://pubs.usgs.gov/of/2019/1096/ofr20191096.pdf
  nhd$Q_cms <- nhd$QBMA * 0.0283 #USGS discharge model
  nhd$Q_cms_adj <- nhd$QEMA*0.0283 #USGS discharge model adjusted to better match gauges. BUT, this can create 'jumps' in the streamflow simulation, so we don't use it here
  
  #handle Indiana-effected basin stream orders
  if(huc4 %in% indiana_hucs){
    thresh <- c(2,2,2,2,3,2,3,2) #see README file
    thresh <- thresh[which(indiana_hucs == huc4)]
    nhd$StreamOrde <- ifelse(nhd$indiana_fl == 1, nhd$StreamOrde - thresh, nhd$StreamOrde)
  }

  #assign waterbody type for depth modeling
  nhd$waterbody <- ifelse(is.na(nhd$WBArea_Permanent_Identifier)==0 & is.na(nhd$LakeAreaSqKm) == 0 & nhd$LakeAreaSqKm > 0, 'Lake/Reservoir', 'River')

  #fix erronous IDs for matching basins for routing (manually identified in the version of NHD-HR used in this study)
  if(huc4 == '0514'){nhd[nhd$NHDPlusID == 24000100384878,]$StreamOrde <- 8}   #fix erroneous 'divergent' reach in the Ohio mainstem (matching Indiana file upstream)
  if(huc4 == '0514'){nhd[nhd$NHDPlusID == 24000100569580,]$ToNode <- 22000100085737} #from/to node ID typo (from Ohio River to Missouri River) so I manually fix it
  if(huc4 == '0706'){nhd[nhd$NHDPlusID == 22000400022387,]$StreamOrde <- 7} #error in stream order calculation because reach is miss-assigned as stream order 0 (on divergent path) which isn't true. Easiest to just skip over the reach because it's just a connector into the Mississippi River (from Wisconsin river)
  
  #remove divergent channels, i.e. all downstream routing flows into a single downstream reach.
  nhd <- dplyr::filter(nhd, StreamOrde > 0)

  #calculate lake volumes (when appropriate)
  nhd$lakeVol_m3 <- 0.533 * (nhd$LakeAreaSqKm*1e6)^1.204 #https://doi.org/10.1002/2016GL071378

  #Calculate and assign lake percents to each throughflow line so that we have fractional lake surface areas and volumes for each throughflow line
  sumThroughFlow <- dplyr::filter(as.data.frame(nhd), is.na(WBArea_Permanent_Identifier)==0) %>% #This is based on reachLength/total throughflow line reach length
    dplyr::group_by(WBArea_Permanent_Identifier) %>%
    dplyr::summarise(sumThroughFlow = sum(LengthKM))
  nhd <- dplyr::left_join(nhd, sumThroughFlow, by='WBArea_Permanent_Identifier')
  nhd$lakePercent <- nhd$LengthKM / nhd$sumThroughFlow
  nhd$frac_lakeVol_m3 <- nhd$lakeVol_m3 * nhd$lakePercent
  nhd$frac_lakeSurfaceArea_m2 <- nhd$LakeAreaSqKm * nhd$lakePercent * 1e6

  #get river bankfull depth using hydraulic scaling. Stored in ~/data and available at https://doi.org/10.1111/jawr.12282
  a <- Hb_error_model[Hb_error_model$division == physio_region,]$a
  b <- Hb_error_model[Hb_error_model$division == physio_region,]$b
  nhd$depth_m <- mapply(depth_func, nhd$waterbody, nhd$frac_lakeVol_m3, nhd$frac_lakeSurfaceArea_m2*1e6, physio_region, nhd$TotDASqKm, a, b)

  #get error distribution for Hb model (https://doi.org/10.1111/jawr.12282)
  see <- Hb_error_model[Hb_error_model$division == physio_region,]$see
  mean <- Hb_error_model[Hb_error_model$division == physio_region,]$mean_residual

  #apply error model
  error <- rnorm(n= nrow(nhd), mean=mean, sd=see)
  nhd$error <- error
  nhd$depth_m <- ifelse(nhd$waterbody == 'River', 10^(log10(nhd$depth_m) + nhd$error), nhd$depth_m)

  ########EXTRACT DATA TO NHD-HR
  #convert back to terra to do extractions
  nhd <- terra::vect(nhd)

  #clip models to basin at hand
  wtd <- terra::crop(wtd, basin)

  #extract mean monthly water table depths along reach (as summary stats)
  nhd_wtd_01 <- terra::extract(wtd$WTD_1, nhd, fun=summariseWTD)
  nhd_wtd_02 <- terra::extract(wtd$WTD_2, nhd, fun=summariseWTD)
  nhd_wtd_03 <- terra::extract(wtd$WTD_3, nhd, fun=summariseWTD)
  nhd_wtd_04 <- terra::extract(wtd$WTD_4, nhd, fun=summariseWTD)
  nhd_wtd_05 <- terra::extract(wtd$WTD_5, nhd, fun=summariseWTD)
  nhd_wtd_06 <- terra::extract(wtd$WTD_6, nhd, fun=summariseWTD)
  nhd_wtd_07 <- terra::extract(wtd$WTD_7, nhd, fun=summariseWTD)
  nhd_wtd_08 <- terra::extract(wtd$WTD_8, nhd, fun=summariseWTD)
  nhd_wtd_09 <- terra::extract(wtd$WTD_9, nhd, fun=summariseWTD)
  nhd_wtd_10 <- terra::extract(wtd$WTD_10, nhd, fun=summariseWTD)
  nhd_wtd_11 <- terra::extract(wtd$WTD_11, nhd, fun=summariseWTD)
  nhd_wtd_12 <- terra::extract(wtd$WTD_12, nhd, fun=summariseWTD)

  #intersect with CONUS boundary to identify American/non-American rivers
  nhd_conus <- sf::st_intersection(sf::st_as_sf(nhd), states)
  nhd$conus <- ifelse(nhd$NHDPlusID %in% nhd_conus$NHDPlusID, 1,0)

  #Wrangle everything into a lightweight routing table (no spatial info anymore)
  nhd_df <- as.data.frame(nhd)
  nhd_df <- dplyr::select(nhd_df, c('NHDPlusID', 'StreamOrde', 'TerminalPa', 'HydroSeq', 'FromNode','ToNode', 'conus', 'FCode_riv', 'FCode_waterbody', 'waterbody',  'AreaSqKm', 'TotDASqKm','Q_cms', 'Q_cms_adj', 'LengthKM', 'depth_m', 'LakeAreaSqKm'))

  nhd_df$wtd_t_median_01 <- as.numeric(nhd_wtd_01$WTD_1.median)*-1
  nhd_df$wtd_t_median_02 <- as.numeric(nhd_wtd_02$WTD_2.median)*-1
  nhd_df$wtd_t_median_03 <- as.numeric(nhd_wtd_03$WTD_3.median)*-1
  nhd_df$wtd_t_median_04 <- as.numeric(nhd_wtd_04$WTD_4.median)*-1
  nhd_df$wtd_t_median_05 <- as.numeric(nhd_wtd_05$WTD_5.median)*-1
  nhd_df$wtd_t_median_06 <- as.numeric(nhd_wtd_06$WTD_6.median)*-1
  nhd_df$wtd_t_median_07 <- as.numeric(nhd_wtd_07$WTD_7.median)*-1
  nhd_df$wtd_t_median_08 <- as.numeric(nhd_wtd_08$WTD_8.median)*-1
  nhd_df$wtd_t_median_09 <- as.numeric(nhd_wtd_09$WTD_9.median)*-1
  nhd_df$wtd_t_median_10 <- as.numeric(nhd_wtd_10$WTD_10.median)*-1
  nhd_df$wtd_t_median_11 <- as.numeric(nhd_wtd_11$WTD_11.median)*-1
  nhd_df$wtd_t_median_12 <- as.numeric(nhd_wtd_12$WTD_12.median)*-1

  #setup GW errors over time and space (12 months, n reaches). See ge_error_model as specificed in _targets.R
  error <- rnorm(n=nrow(nhd_df), mean=gw_error_model$mean, sd=gw_error_model$sd)
  nhd_df$error <- error

  #randomly sample and apply groundwater model uncertainty
  nhd_df$wtd_k_median_01 <- ifelse(nhd_df$wtd_t_median_01 < 1e-10, 0, log10(nhd_df$wtd_t_median_01)) - nhd_df$error #errors are inverted to match the correct direction
  nhd_df$wtd_k_median_02 <- ifelse(nhd_df$wtd_t_median_02 < 1e-10, 0, log10(nhd_df$wtd_t_median_02)) - nhd_df$error
  nhd_df$wtd_k_median_03 <- ifelse(nhd_df$wtd_t_median_03 < 1e-10, 0, log10(nhd_df$wtd_t_median_03)) - nhd_df$error
  nhd_df$wtd_k_median_04 <- ifelse(nhd_df$wtd_t_median_04 < 1e-10, 0, log10(nhd_df$wtd_t_median_04)) - nhd_df$error
  nhd_df$wtd_k_median_05 <- ifelse(nhd_df$wtd_t_median_05 < 1e-10, 0, log10(nhd_df$wtd_t_median_05)) - nhd_df$error
  nhd_df$wtd_k_median_06 <- ifelse(nhd_df$wtd_t_median_06 < 1e-10, 0, log10(nhd_df$wtd_t_median_06)) - nhd_df$error
  nhd_df$wtd_k_median_07 <- ifelse(nhd_df$wtd_t_median_07 < 1e-10, 0, log10(nhd_df$wtd_t_median_07)) - nhd_df$error
  nhd_df$wtd_k_median_08 <- ifelse(nhd_df$wtd_t_median_08 < 1e-10, 0, log10(nhd_df$wtd_t_median_08)) - nhd_df$error
  nhd_df$wtd_k_median_09 <- ifelse(nhd_df$wtd_t_median_09 < 1e-10, 0, log10(nhd_df$wtd_t_median_09)) - nhd_df$error
  nhd_df$wtd_k_median_10 <- ifelse(nhd_df$wtd_t_median_10 < 1e-10, 0, log10(nhd_df$wtd_t_median_10)) - nhd_df$error
  nhd_df$wtd_k_median_11 <- ifelse(nhd_df$wtd_t_median_11 < 1e-10, 0, log10(nhd_df$wtd_t_median_11)) - nhd_df$error
  nhd_df$wtd_k_median_12 <- ifelse(nhd_df$wtd_t_median_12 < 1e-10, 0, log10(nhd_df$wtd_t_median_12)) - nhd_df$error

  #flip back to model setup (natural space, negative)
  nhd_df$wtd_m_median_01 <- ifelse(nhd_df$wtd_k_median_01 == 0, 0, -1*10^(nhd_df$wtd_k_median_01))
  nhd_df$wtd_m_median_02 <- ifelse(nhd_df$wtd_k_median_02 == 0, 0, -1*10^(nhd_df$wtd_k_median_02))
  nhd_df$wtd_m_median_03 <- ifelse(nhd_df$wtd_k_median_03 == 0, 0, -1*10^(nhd_df$wtd_k_median_03))
  nhd_df$wtd_m_median_04 <- ifelse(nhd_df$wtd_k_median_04 == 0, 0, -1*10^(nhd_df$wtd_k_median_04))
  nhd_df$wtd_m_median_05 <- ifelse(nhd_df$wtd_k_median_05 == 0, 0, -1*10^(nhd_df$wtd_k_median_05))
  nhd_df$wtd_m_median_06 <- ifelse(nhd_df$wtd_k_median_06 == 0, 0, -1*10^(nhd_df$wtd_k_median_06))
  nhd_df$wtd_m_median_07 <- ifelse(nhd_df$wtd_k_median_07 == 0, 0, -1*10^(nhd_df$wtd_k_median_07))
  nhd_df$wtd_m_median_08 <- ifelse(nhd_df$wtd_k_median_08 == 0, 0, -1*10^(nhd_df$wtd_k_median_08))
  nhd_df$wtd_m_median_09 <- ifelse(nhd_df$wtd_k_median_09 == 0, 0, -1*10^(nhd_df$wtd_k_median_09))
  nhd_df$wtd_m_median_10 <- ifelse(nhd_df$wtd_k_median_10 == 0, 0, -1*10^(nhd_df$wtd_k_median_10))
  nhd_df$wtd_m_median_11 <- ifelse(nhd_df$wtd_k_median_11 == 0, 0, -1*10^(nhd_df$wtd_k_median_11))
  nhd_df$wtd_m_median_12 <- ifelse(nhd_df$wtd_k_median_12 == 0, 0, -1*10^(nhd_df$wtd_k_median_12))
  
  return(nhd_df)
}




#' Builds figure summarizing MC analysis
#'
#' @name uncertaintyFigures
#'
#' @param path_to_data: data repo path directory
#' @param shapefile_fin: final HUC4 model results shapeifle (as sf object)
#' @param mc0107: Monte Carlo results for basin 0107
#' @param mc1402: Monte Carlo results for basin 1402
#' @param mc1703: Monte Carlo results for basin 1703
#' @param mc0311: Monte Carlo results for basin 0311
#' @param mc1504: Monte Carlo results for basin 1504
#'
#' @import terra
#' @import sf
#' @import dplyr
#'
#' @return Monte Carlo analysis results figure (written to file)
uncertaintyFigures <- function(path_to_data, shapefile_fin, mc0107, mc1402, mc1703, mc0311, mc1504){
  theme_set(theme_classic())
  
  ##SETUP MAP------------------------------
  results <- shapefile_fin$shapefile
  results <- dplyr::filter(results, is.na(num_flowing_dys)==0) #remove great lakes
  results$flag <- ifelse(results$huc4 =='0107', 'merrimack',
                    ifelse(results$huc4 == '1402', 'gunnison',
                        ifelse(results$huc4 == '1703', 'yakima',
                          ifelse(results$huc4 == '0311', 'suwannee',
                              ifelse(results$huc4 == '1504', 'upper gila', 'zzzzz')))))
  
  # CONUS boundary
  states <- sf::st_read(paste0(path_to_data, '/other_shapefiles/cb_2018_us_state_5m.shp'))
  states <- dplyr::filter(states, !(NAME %in% c('Alaska',
                                                'American Samoa',
                                                'Commonwealth of the Northern Mariana Islands',
                                                'Guam',
                                                'District of Columbia',
                                                'Puerto Rico',
                                                'United States Virgin Islands',
                                                'Hawaii'))) #remove non CONUS states/territories
  states <- st_union(states)

  #setup mc distribution sigmas for plotting----------------------------------------------
  results$sigmas_east <- ifelse(results$huc4 == '0107', paste0(round(sd(mc0107)*100,2),'%'),
                            ifelse(results$huc4 == '0311', paste0(round(sd(mc0311)*100,2),'%'),NA))
  results$sigmas_west <- ifelse(results$huc4 == '1402', paste0(round(sd(mc1402)*100,2),'%'),
                            ifelse(results$huc4 == '1703', paste0(round(sd(mc1703)*100,2),'%'),NA))
  results$sigma_gila <- ifelse(results$huc4 == '1504', paste0(round(sd(mc1504)*100,2),'%'),NA)

  #PLOT---------------------------------------------------------
  map <- ggplot(results) +
    geom_sf(aes(fill=flag),
            size=0.5,
            color='black') +
    geom_sf(data=states,
            color='black',
            size=1.25,
            alpha=0)+
    ggsflabel::geom_sf_label_repel(aes(label=sigmas_east),
                        fontface = "bold",
                        size =18,
                        segment.size=3,
                        segment.color='#564C4D',
                        show.legend = FALSE,
                        ylim=c(25,33),
                        xlim=c(-75,-65))+
    ggsflabel::geom_sf_label_repel(aes(label=sigmas_west),
                        fontface = "bold",
                        size =18,
                        segment.size=3,
                        segment.color='#564C4D',
                        show.legend = FALSE,
                        ylim=c(25,30),
                        xlim=c(-127,-110))+
    ggsflabel::geom_sf_label_repel(aes(label=sigma_gila),
                        fontface = "bold",
                        size =18,
                        segment.size=3,
                        segment.color='#564C4D',
                        show.legend = FALSE,
                        ylim=c(24,26),
                        xlim=c(-110,-100))+                        
    scale_fill_manual(values=c('#fc8d62', '#66c2a5', '#e78ac3', '#8da0cb', '#a6d854', 'white'))+
    theme(axis.text = element_text(family="Futura-Medium", size=20))+ #axis text settings
    theme(legend.position = 'none')+
    theme(text = element_text(family = "Futura-Medium"), #legend text settings
          legend.title = element_text(face = "bold", size = 20),
          legend.text = element_text(family = "Futura-Medium", size = 18),
          plot.tag = element_text(size=26,
                                  face='bold'))+
    xlab('')+
    ylab('')
  
  ggsave('cache/mcUncertaintyPlot.jpg', map, width=22, height=20)
  return('cache/mcUncertaintyPlot.jpg')                                   
}