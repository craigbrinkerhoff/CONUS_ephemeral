#old functions trying to improve numFlowingDays model

#######_targets file--------------------------
# mapped_temp <- tar_map(
#   unlist=FALSE,
#   values = tibble(
#     method_function = rlang::syms("calcMemory"),
#     huc4 = c( "1009", "1302", "1303", "1306", "1405", "1408", "1501", "1503", "1506", "1507",
#               "1606", "0302", "0427", "1505", "1705", "0510"),
#   ),
#   names = "huc4",
#   tar_target(numFlowingDays_new, method_function(huc4, runoffEffScalar_real, path_to_data, combined_runoffEff, flowingDaysValidation))
# )

# mapped_temp,
#  tar_combine(combined_numFlowingDays_new, list(mapped_temp$numFlowingDays_new), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment='main'),
#  tar_target(combined_numFlowingDays_new_fin, fitJackKnifeRegression(combined_numFlowingDays_new)),

#tar_target(numFlowingDaysRegression, numFlowingDaysModel(flowingDaysValidation, combined_runoffEff)),


########analysis.R functions------------------------------

#' Calculates a first-order runoff-generation threshold [mm/dy] using geomorphic scaling a characteristic minimum headwater stream width from Allen et al. 2018
#' Will run Monte Carlo uncertainty simulation if munge_mc is on
#' 
#' @name calcRunoffThresh
#'
#' @param rivnet: basin hydrography model
#' @param munge_mc: binary indicating whether to run nromal model or MC uncertainty
#'
#' @import readr
#'
#' @return runoff-generation thresholdfor a given HUC4 basin [mm/dy]
# calcRunoffThresh <- function(rivnet, munge_mc) {
#   #Width AHG scaling relation
#   widAHG <- readr::read_rds('/nas/cee-water/cjgleason/craig/RSK600/cache/widAHG.rds') #width AHG model
#   a <- exp(coef(widAHG)[1])
#   b <- coef(widAHG)[2]
#   W_min <- 0.32 #Allen et al 2018 minimum headwater width in meters
#   
#   #Monte Carlo calculation-----------
#   if(munge_mc == 1){
#     set.seed(321)
#     n <- 1000
#     a_distrib <- exp(rnorm(n, coef(widAHG)[1], summary(widAHG)$coef[[3]]))
#     b_distrib <- rnorm(n, coef(widAHG)[2], summary(widAHG)$coef[[4]])
#     width_distrib <- exp(rnorm(n, log(0.32), log(2.3))) #from george's paper
#     runoff_min_distrib <- 1:n
#     for(i in 1:n){
#       runoff_min_distrib[i] <- median(ifelse(rivnet$perenniality == 'ephemeral' & rivnet$TotDASqKm  > 0, ((width_distrib[i]/a_distrib[i])^(1/b_distrib[i]) /( rivnet$TotDASqKm*1e6) ) * 86400000, NA), na.rm=T) #[mm/dy] only use non-0 km2 catchments for this....
#     }
#     return(runoff_min_distrib)
#   }
#   
#   #Normal calculation----------------
#   else{
#     #geomorphic scaling function to get headwater ephemeral runoff generation threshold
#     runoffThresh <- max(ifelse(rivnet$perenniality == 'ephemeral'  & (rivnet$dQdX_cms == rivnet$Q_cms) & rivnet$TotDASqKm  > 0, ((W_min/a)^(1/b) /( rivnet$TotDASqKm*1e6) ) * 86400000, NA), na.rm=T) #[mm/dy] only use non-0 km2 catchments for this....
#     
#     return(runoffThresh)
#   }
# }

#' 
#' 
#' 
#' #' Calculates a first-order 'number flowing days' per HUC4 basin using long-term runoff ratio and daily precip for 1980-2010.
#' #' Will run Monte Carlo analysis for uncertainty if the munge is turned on
#' #'
#' #' @name calcFlowingDays
#' #'
#' #' @param path_to_data: path to data repo
#' #' @param huc4: huc basin level 4 code
#' #' @param runoff_eff: calculated runoff ratio per HUC4 basin
#' #' @param runoff_thresh: [mm] a priori runoff threshold for 'streamflowflow generation'
#' #' @param runoffEffScalar: [percent] sensitivty parameter to use to perturb model sensitivty to runoff efficiency
#' #' @param runoffMemory: sensitivity parameter to test 'runoff memory' in number of flowing days calculation: even if rain stops, there will be some overland flow and interflow that are delayed in their reaching the river
#' #' @param munge_mc: binary indicating whether to run nromal model or MC uncertainty
#' #'
#' #' @import terra
#' #' @import raster
#' #'
#' #' @return number of flowing days for a given HUC4 basin
#' calcFlowingDays <- function(path_to_data, huc4, runoff_eff, runoff_thresh, runoffEffScalar, runoffMemory, munge_mc){
#'   #get basin to clip precip model
#'   huc2 <- substr(huc4, 1, 2)
#'   basins <- terra::vect(paste0(path_to_data, '/HUC2_', huc2, '/WBD_', huc2, '_HU2_Shape/Shape/WBDHU4.shp')) #basin polygon
#'   basin <- basins[basins$huc4 == huc4,]
#' 
#'   #add year gridded precip
#'   precip <- raster::brick(paste0(path_to_data, '/for_ephemeral_project/dailyPrecip_1980_2010.gri')) #daily precip for 1980-2010
#'   precip <- raster::rotate(precip) #convert 0-360 lon to -180-180 lon
#'   basin <- terra::project(basin, '+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0 ')
#'   basin <- as(basin, 'Spatial')
#'   precip <- raster::crop(precip, basin)
#'   
#'   #Monte Carlo calculation------------------------
#'   if(munge_mc == 1){
#'     set.seed(321)
#'     n <- 1000
#'     numFlowingDays_distrib <- 1:n
#'     for(i in 1:n){
#'       thresh <- runoff_thresh[i] / (runoff_eff[runoff_eff$huc4 == huc4,]$runoff_eff + runoff_eff[runoff_eff$huc4 == huc4,]$runoff_eff*runoffEffScalar) #convert runoff thresh to precip thresh using runoff efficiency coefficient
#'       precip_t <- raster::calc(precip, fun=function(x){addingRunoffMemory(x, runoffMemory, thresh)}) #calculate number of days flowing per cell, introducing 'runoff memory' that handles potential double counting (if required)
#'       
#'       numFlowingDays <- (raster::cellStats(precip_t, 'mean')) #average over HUC4 basin DEFAULT FUNCTION IGNORES NAs
#'       numFlowingDays <- (numFlowingDays/(31*365))*365 #average number of dys per year across the record (31 years)
#'       
#'       numFlowingDays_distrib[i] <- numFlowingDays
#'     }
#'     return(sd(numFlowingDays_distrib, na.rm=T))
#'   }
#'   
#'   #Normal calculation-----------------------------
#'   else{
#'     #obtain results for flowing days, given a runoff threshold and huc4-scale runoff efficiency (both calculated per basin previously)
#'     thresh <- runoff_thresh / (runoff_eff[runoff_eff$huc4 == huc4,]$runoff_eff + runoff_eff[runoff_eff$huc4 == huc4,]$runoff_eff*runoffEffScalar) #convert runoff thresh to precip thresh using runoff efficiency coefficient
#'     precip <- raster::calc(precip, fun=function(x){addingRunoffMemory(x, runoffMemory, thresh)}) #calculate number of days flowing per cell, introducing 'runoff memory' that handles potential double counting (if required)
#'     
#'     numFlowingDays <- (raster::cellStats(precip, 'mean')) #average over HUC4 basin DEFAULT FUNCTION IGNORES NAs
#'     numFlowingDays <- (numFlowingDays/(31*365))*365 #average number of dys per year across the record (31 years)
#'     
#'     return(numFlowingDays) 
#'   }
#' }


#######verification_flowingDays.R functions-----------------------------

# #kind of hacky way to re-calculate model number flowing days using the in situ drainage area (a more fair comparison)
# widAHG <- readr::read_rds('/nas/cee-water/cjgleason/craig/RSK600/cache/widAHG.rds') #width AHG model
# a <- exp(coef(widAHG)[1])
# b <- coef(widAHG)[2]
# W_min <- 0.32 #Allen et al 2018 modal headwater width of flowing streams (in meters)
# validationData$runoffThresh_da <- ((W_min/a)^(1/b) /( validationData$drainage_area_km2*1e6) ) * 86400000 #[mm/dy] only use non-0 km2 catchments for this....
# 
# validationData$numFlowingDays_da <- NA
# validationData$memory_da <- NA
# for(k in 1:nrow(validationData)){
#  # validationData[k,]$memory_da <- round(7*combined_runoffEff[combined_runoffEff$huc4 == validationData[k,]$huc4,]$runoff_eff, 0)
#   validationData[k,]$numFlowingDays_da <- calcFlowingDays(path_to_data, validationData[k,]$huc4, combined_runoffEff, validationData[k,]$runoffThresh_da, 0, 4,0)
#   #validationData[k,]$numFlowingDays_sigma_da <- calcFlowingDays(path_to_data, validationData[k,]$huc4, combined_runoffEff, validationData[k,]$runoffThresh_da, 0, 2, 1)
# }

# calcMemory <- function(huc4, runoffEffScalar_real, path_to_data, combined_runoffEff, flowingDaysValidation) {
#   Nflw_obs <- mean(flowingDaysValidation[flowingDaysValidation$huc4 == huc4,]$n_flw_d)
# #  memory <- 1
# #  error <- 1 #initial error value
# #  out <- data.frame()
# #  for(memory in c(1,5,10,25,50)){#while(error >= 0.05){ #go until they are within 5% of one another
#     num_event_dys <- calcFlowingDays(path_to_data, huc4, combined_runoffEff, 1, runoffEffScalar_real, 0,0)
#     theta <- 10*Nflw_obs/num_event_dys
#  #   error <- abs(num_flowing_dys - Nflw_obs) / Nflw_obs
#     
#     temp <- data.frame('huc4'=huc4,
#                        'Nflw_obs'=Nflw_obs,
#                        'num_event_dys'=num_event_dys,
#                        'theta'=theta,
#                        'runoff_coef'=combined_runoffEff[combined_runoffEff$huc4 == huc4,]$runoff_eff,
#                        'drainage_area_km2'=mean(flowingDaysValidation[flowingDaysValidation$huc4 == huc4,]$drainage_area_km2))
#  #   out <- rbind(out, temp)
# #    memory <- memory + 1
# #  }
#   
#   return(temp)
# }




# fitJackKnifeRegression <- function(combined_numFlowingDays){
#   #leave-one-out regression to get model coefficients independent of each point (Prancevic & Kirchner 2019)
#   combined_numFlowingDays$pred_theta <- NA
#   combined_numFlowingDays$pred_Nflw <- NA
#   
#   for(i in 1:nrow(combined_numFlowingDays)){
#     model_jackknife <- lm(log(theta)~log(runoff_coef), data=combined_numFlowingDays[-i,])
#     
#     combined_numFlowingDays[i,]$pred_theta <- exp(coef(model_jackknife)[1])*combined_numFlowingDays[i,]$runoff_coef^(coef(model_jackknife)[2])
#     combined_numFlowingDays[i,]$pred_Nflw <- (combined_numFlowingDays[i,]$num_event_dys*combined_numFlowingDays[i,]$pred_theta)/10
#   }
#   
#   #fit overall model that will be used to make map
#   model <- lm(log(theta)~log(runoff_coef), data=combined_numFlowingDays)
#   
#   #plot validation
#   plot <- ggplot(combined_numFlowingDays, aes(x=Nflw_obs, y=pred_Nflw)) +
#     geom_abline(size=1.25, linetype='dashed', color='darkgrey') +
#     geom_point(size=5)
#   ggsave('test3.jpg', plot)
#   
#   
#   plot2 <- ggplot(combined_numFlowingDays, aes(x=runoff_coef*drainage_area_km2, y=theta)) +
#     geom_point(size=5) +
#     scale_x_log10()+
#     scale_y_log10()
#   ggsave('test4.jpg', plot2)
#   
#   return(list('combined_numFlowingDays'=combined_numFlowingDays,
#               'model'=model))
# }



# flowingValidateGAWrapper <- function(flowingFieldData, runoffEffScalar_real, runoffMemory_real, path_to_data, combined_runoffEff) {
#   # flowingFieldData <- flowingFieldData[1:3,]
#   
#   calibrated <- GA::ga(type = "real-valued", 
#                        fitness = function(x){
#                          huc4s = c('1009', '1302', '1303', '1306', '1405', '1408', '1501', '1503', '1506', '1507', '1606','0302', '0427', '1507', '1505', '1503', '1302', '1705', '0510', '1505', '1505', '1503') #basins with field data
#                          
#                          num_flowing_dys <- rep(NA, length(huc4s))
#                          for(k in 1:length(huc4s)){
#                            num_flowing_dys[k] <- calcFlowingDays(path_to_data, huc4s[k], combined_runoffEff, x[1], runoffEffScalar_real, x[2],0)
#                          }
#                          temp <- data.frame('huc4'=huc4s,
#                                             'watershed'=flowingFieldData$watershed,
#                                             'num_flowing_dys'=num_flowing_dys)
#                          temp <- dplyr::left_join(flowingFieldData, temp, by='watershed')
#                          
#                          r2 <-summary(lm(num_flowing_dys ~ n_flw_d, data=temp))$r.squared  #Metrics::mae(temp$num_flowing_dys, temp$n_flw_d)
#                          
#                          return(r2)
#                        },
#                        lower = c(1e-2, 1), upper = c(24, 10), 
#                        popSize = 25, maxiter = 50, run = 1000,
#                        optim=TRUE, #use L-BFGS-B solver
#                        parallel=TRUE,
#                        seed=352) #reproducibility
#   
#   return(calibrated)
# }



# flowingValidate_regress <- function(validationData, path_to_data, codes_huc02){
#   #read in all HUC4 basins
#   basins_overall <- sf::st_read(paste0(path_to_data, '/HUC2_', codes_huc02[1], '/WBD_', codes_huc02[1], '_HU2_Shape/Shape/WBDHU4.shp')) %>% select(c('huc4', 'name'))
#   for(i in codes_huc02[-1]){
#     basins <- sf::st_read(paste0(path_to_data, '/HUC2_', i, '/WBD_', i, '_HU2_Shape/Shape/WBDHU4.shp')) %>% select(c('huc4', 'name')) #basin polygons
#     basins_overall <- rbind(basins_overall, basins)
#   }
# 
#   #join field data to HUC4 basin results
#   validationData <- sf::st_as_sf(validationData, coords = c("long", "lat"), crs=sf::st_crs(basins_overall))
#   validationData <- sf::st_intersection(basins_overall, validationData)
# 
#   output <- validationData %>%
#     dplyr::group_by(huc4) %>%
#     dplyr::summarise(n_flw_d = median(n_flw_d,na.rm=T),  #take catchment average across all flumed reaches (if necessary)
#                      num_sample_yrs = round(mean(num_sample_yrs),0), #mean across catchment reaches (mean of constants, just to propagate value)
#                      drainage_area_km2 = median(drainage_area_km2),
#                      n_basins=n())
# 
#   return(output)
# }


########utils.R functions-------------------------
#' Adds 'memory days' to number of flowing days timeseries given a lag time.
#' 
#' @note This function specifically avoids double counting flowing days, by only adding memory flowing days if the day is not already tagged as flowing
#'
#' @name addingRunoffMemory
#'
#' @param precip: flowing on/off binary timeseries as a vector [0/1]
#' @param memory: number of days lag that runoff is still being generated from a rain event [days]
#' @param thresh: runoff threshold as set in main analysis [m]
#' #'
#' #' @return updated flowing on/off binary timeseries (with lagged days now flagged as flowing too)
#' addingRunoffMemory <- function(precip, memory, thresh){
#'   precip <- precip[is.na(precip)==0]
#'   if(length(precip)==0){return(NA)}
#'   
#'   orig <- precip
#'   for(i in 1:length(precip)){
#'     if(precip[i] == 1 & orig[i] == 1){
#'       for(k in seq(1+i,memory+i-1,1)){
#'         precip[k] <- 1
#'       }
#'     }
#'   }
#'   precip <- sum(precip >= thresh)
#'   return(precip)
#' }


# numFlowingDaysWrapper <- function(Nflw, path_to_data, huc4, combined_runoffEff, runoffEffScalar_real, memory,munge_mc){
#   runoff <- combined_runoffEff[combined_runoffEff$huc4 == huc4,]$runoff_ma_mm_yr
#   
#   
#   runoffThresh <- runoff / Nflw
#   num_flowing_dys <- calcFlowingDays(path_to_data, huc4, combined_runoffEff, runoffThresh, runoffEffScalar_real, memory,munge_mc)
#   error <- abs(num_flowing_dys - Nflw)/Nflw
#   
#   return(error)
# }




##################figures_additional.R functions-------------

# plot2 <- ggplot(df, aes(theoreticalThresholds)) +
#   geom_density(size=1.25, color='black', fill='lightgreen') +
#   scale_x_log10(limits=c(1e-4,5),
#                 breaks=c(1e-4, 1e-2, 1e-0),
#                 labels=c('0.0001', '0.001', '1'))+
#   labs(tag='B')+
#   xlab('Runoff threshold (estimated via theory per basin) [mm/dy]') +
#   ylab('Density')+
#   theme(axis.text=element_text(size=20),
#         axis.title=element_text(size=22,face="bold"),
#         legend.text = element_text(size=17),
#         plot.title = element_text(size = 30, face = "bold"),
#         legend.position='none',
#         plot.tag = element_text(size=26,
#                                 face='bold'))


##COMBO PLOT
# design <- "
#   AAAA
#   AAAA
#   AAAA
#   AAAA
#   BBBB
#   "
# comboPlot <- patchwork::wrap_plots(A=plot, B=plot2, design=design)