## Craig Brinkerhoff
## Summer 2022
## Functions for building verification dataset and testing num flowing days sensitivity



wrangleUSGSephGages <- function(other_sites){
  #USGS ephemeral gages-----------------------------------------------------------
  other_sites$wy_eph_gages <- substr(other_sites$name, 6,nchar(other_sites$name))
  
  out <- data.frame()
  for(i in other_sites$wy_eph_gages){
    gageQ <- readNWISdv(siteNumbers = i, #check if site mets our date requirements
                        parameterCd = '00060') #discharge
    
    #get mean annual flow
    if(nrow(gageQ)==0){next} #some go these gages don't have their data online (in local USGS offices only.....)
    
    gageQ <- gageQ %>% 
      dplyr::mutate(Q_cms = round(X_00060_00003,1)*0.0283) #cfs to cms with zero flow rounding protocol following:  https://doi.org/10.1029/2021GL093298,  https://doi.org/10.1029/2020GL090794
    
    Q_MA <- mean(gageQ$Q_cms, na.rm=T) #mean annual
    numFlow <- (sum(gageQ$Q_cms > 0, na.rm=T)/nrow(gageQ))*365
    
    temp <- data.frame('gageID'=i, #take first row
                       'meas_runoff_m3_s'=Q_MA,
                       'num_flowing_dys'=numFlow,
                       'period_of_record_yrs'=nrow(gageQ)/365)
    
    out <- rbind(out, temp)
  }
  out <- out %>%
    dplyr::left_join(other_sites, by=c('gageID'='wy_eph_gages')) %>% #to get the gage drainage area
    dplyr::select(c('gageID', 'huc4', 'meas_runoff_m3_s', 'drainageArea_km2', 'num_flowing_dys', 'period_of_record_yrs', 'lon', 'lat')) %>%
    dplyr::mutate(type = ifelse(gageID %in% c('06268500', #see /nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/for_ephemeral_project/flowingDays_data/README_usgs_eph_gages.md for how these were determined
                                              '06313700',
                                              '06425750',
                                              '06425780',
                                              '08331660',
                                              '08477600',
                                              '09216527',
                                              '09216545',
                                              '09216562',
                                              '09216565',
                                              '09216750',
                                              '09222300',
                                              '09222400',
                                              '09235300',
                                              '09306235',
                                              '09306240',
                                              '09508300',
                                              '09510200',
                                              '09512450',
                                              '09512600',
                                              '09512830',
                                              '09512860',
                                              '10250800'), 'eph_int', 'eph')) #see exp_catchments/README.txt, but these I manually checked in google earth and they are downstream of a spring/waterfall/dam etc. that artificially creates an intermittent stream
  
  
  return(out)
}



#' wrangles existing (published) ephemeral field data to calculate 'number of flowing days' for their respective basins
#'
#' @name wrangleFlowingFieldData
#' @note data comes from the following field studies (all saved in data repo except the Duke Forest data which is hardcoded here):
#'
#' Duke Forest, NC: https://doi.org/10.1002/hyp.11301 (1 years data)
#' Robinson Forest, KY: https://doi.org/10.1002/ecs2.2654 (0.58 years of data)
#' Mohave and Yuma Basins, AZ: https://doi.org/10.1029/2018WR023714 (2-3 years data)
#' Reynold's Creek, ID: https://doi.org/10.1029/2001WR000413 (29 years of data) Ephemeral site identification within catchment uses https://doi.org/10.1029/2001WR000420
#' Santa Rita Basin, AZ: doi:10.1029/2006WR005733 (46 years of data)
#' Walnut Gulch Basin, AZ: doi:10.1029/2006WR005733 (45 years of data)
#' Montoyas Catchment near Albuquerque, NM:  https://doi.org/10.1016/j.ejrh.2022.101089 (6 years of data)
#' More Arizona data for various arid catchments https://doi.org/10.1016/j.jaridenv.2016.12.004 (2 years of data). This has additional data for Santa Rita basin that gets averaged into the Santa Rita dataset
#' Geulph Ontario data  https://doi.org/10.1002/hyp.10136 (1/3 year of data)
#' Gage data from Wyoming, Colorado, and New Mexico per ephemeral gages from USGS reports (data for a few years in the 1970s)
#'
#' @param path_to_data: path to data repo
#'
#' @import readr
#' @import dplyr
#' @import tidyr
#' @import lubridate
#'
#' @return df of all wrangled field data in uniform form and with # flowing days for ephemeral streams calculated
wrangleFlowingFieldData <- function(path_to_data, ephemeralQDataset){
  runoff_thresh <- 0 #threshold for 'streamflow generation' --> any runoff is flow

  #read in data
  walnutGulch <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/WalnutGulchData.csv'))
  reynoldsCreek <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/ReynoldsCreekData.csv'))
  mohaveYuma <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/MohaveYumaData.csv'))
  santaRita <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/SantaRitaData.csv'))
  kentucky <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/Kentucky.csv'))
  more_arizona <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/stromberg_etal_2017.csv'))
  geulph <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/ontario.csv'))

  #wrangling Mohave Yuma-------------------------------
  colnames(mohaveYuma) <- c('site', 'drainage_area_km2', 'elevation_m', 'period_of_record', 'num_flowing_events', 'ma_num_flowing_events', 'reference')
  mohaveYuma$watershed <- substr(mohaveYuma$site, 1, 1)
  mohaveYuma$watershed <- ifelse(mohaveYuma$watershed == 'M', 'mohave', 'yuma')
  mohaveYuma$period_of_record_yrs <- c(3, 2, 4, 2, 3, 1, 3, 2, 4, 1, 4, 2, 4, 1, 2, 4, 3, 2)
  mohaveYuma$num_flowing_days <- ifelse(mohaveYuma$num_flowing_events < 1, 1, mohaveYuma$num_flowing_events)
  mohaveYuma$ma_num_flowing_days <- mohaveYuma$num_flowing_days/(mohaveYuma$period_of_record_yrs)
  mohaveYuma <- mohaveYuma %>% dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'drainage_area_km2', 'ma_num_flowing_days'))

  #wrangling walnut gulch--------------------------
  walnutGulch <- tidyr::gather(walnutGulch, key=site, value=runoff_mm, c("Flume 1", "Flume 2", "Flume 3","Flume 4","Flume 6","Flume 7","Flume 11","Flume 15","Flume 103","Flume 104", "Flume 112", "Flume 121", "Flume 125"))
  walnutGulch$date <- paste0(walnutGulch$Year, '-', walnutGulch$Month, '-', walnutGulch$Day)
  walnutGulch$date <- lubridate::as_date(walnutGulch$date)
  walnutGulch <- walnutGulch %>%
    dplyr::mutate(year = lubridate::year(date)) %>%
    dplyr::group_by(site) %>% #get no flow stats per sub watershed
    dplyr::summarise(period_of_record_yrs = length(unique(year)),
              num_flowing_days = sum(runoff_mm > runoff_thresh),
              watershed=first(watershed),
              reference=first(reference)) %>%
    dplyr::mutate(drainage_area_km2 = c(36900, 9.1, 11.2, 2035, 4.6, 13.4, 14.6, 5912, 28100, 2220, 560, 23500, 3340)*0.004) %>% #source: see reference and MONITORING DISCHARGE AND SUSPENDED SEDIMENT, REYNOLDS CREEK EXPERIMENTAL WATERSHED, IDAHO, USA
    dplyr::mutate(ma_num_flowing_days = num_flowing_days / (period_of_record_yrs)) %>%
    dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'drainage_area_km2', 'ma_num_flowing_days'))

  #wrangling Santa Rita------------------------
  santaRita <- tidyr::gather(santaRita, key=site, value=runoff_mm, c("Flume 1", "Flume 2", "Flume 3","Flume 4","Flume 5","Flume 6","Flume 7","Flume 8"))
  santaRita$date <- paste0(santaRita$Year, '-', santaRita$Month, '-', santaRita$Day)
  santaRita$date <- lubridate::as_date(santaRita$date)
  santaRita <- santaRita %>%
    dplyr::mutate(year = lubridate::year(date)) %>%
    dplyr::group_by(site) %>% #get no flow stats per sub watershed
    dplyr::summarise(period_of_record_yrs = length(unique(year)),
              num_flowing_days = sum(runoff_mm > runoff_thresh),
              watershed=first(watershed),
              reference=first(reference)) %>%
    dplyr::mutate(drainage_area_km2 = c(4.04, 4.37, 6.81, 4.88, 9.93, 7.6, 2.63, 2.77)*0.004) %>% #source: see reference and MONITORING DISCHARGE AND SUSPENDED SEDIMENT, REYNOLDS CREEK EXPERIMENTAL WATERSHED, IDAHO, USA
    dplyr::mutate(ma_num_flowing_days = num_flowing_days / (period_of_record_yrs)) %>%
    dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'drainage_area_km2', 'ma_num_flowing_days'))
  
  #wrangling reynolds creek------------------
  reynoldsCreek$date <- paste0(reynoldsCreek$year, '-', reynoldsCreek$month, '-', reynoldsCreek$day)
  reynoldsCreek$date <- lubridate::as_date(reynoldsCreek$date)
  reynoldsCreek$drainage_area_km2 <- ifelse(reynoldsCreek$site == 'summitWash', 83*0.01, #km2
                                            ifelse(reynoldsCreek$site == 'flats', 0.9*0.01, #km2
                                                   ifelse(reynoldsCreek$site == 'nancy_gulch',1.3*0.01, 13.4*0.01))) #Km2

  reynoldsCreek <- dplyr::group_by(reynoldsCreek, site, date) %>% #hourly to mean daily flow
    dplyr::summarise(watershed=first(watershed),
              site=first(site),
              runoff_mm = sum(((discharge*1000000000)/(drainage_area_km2*0.01*1000000000000))*60*24), #m3/s to mm/day
              drainage_area_km2 = mean(drainage_area_km2)) %>%
    dplyr::mutate(year = lubridate::year(date)) %>%
    dplyr::group_by(site) %>% #get no flow stats per sub watershed
    dplyr::summarise(period_of_record_yrs = length(unique(year)),
              num_flowing_days = sum(runoff_mm > runoff_thresh),
              drainage_area_km2 = mean(drainage_area_km2),
              watershed=first(watershed)) %>%
    dplyr::mutate(ma_num_flowing_days = num_flowing_days / (period_of_record_yrs)) %>%
    dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'drainage_area_km2', 'ma_num_flowing_days'))

  #wrangling Kentucky Robinson Forest-----------
  kentucky$period_of_record_yrs <- kentucky$period_of_record_dys / 365

  #done separately for different datasets with different sampling frequencies
  kentucky$num_flowing_events <- kentucky$perc_record_w_flow*365# (kentucky$perc_record_w_flow * (kentucky$period_of_record_dys*(60*24/15)))/kentucky$period_of_record_dys #because it's defined as a % of the record, we have to convert 15' data to daily averages
  
  #single year, so no averaging
  kentucky$ma_num_flowing_days <- kentucky$num_flowing_events + 2 #field data in catchment only reports 1 or 2 flow events in the non-sampled months (see paper ad Fritz etal 2010)

  kentucky <- kentucky %>%
    dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'drainage_area_km2', 'ma_num_flowing_days'))

  # #add Duke Forest manually (https://doi.org/10.1002/hyp.11301)---------------------------------------
  dukeForest <- data.frame('watershed'='dukeForest',
                           'site'='a',
                           'period_of_record_yrs'=1,
                           'drainage_area_km2'=3.3*0.01,
                           'ma_num_flowing_days'=(365*0.44))#*0.37)

  #add Montoyas watershed, urban system near Albuquerque, New Mexico manually (https://doi.org/10.1016/j.ejrh.2022.101089)-------------------------------------
  montoyas <- data.frame('watershed'='montoyas',
                         'site'='a',
                         'period_of_record_yrs'=7, #2008-2014
                         'drainage_area_km2'=142,
                         'ma_num_flowing_days'=mean(c(2,0,1,0,0,5,2)))#See paper Table 1 for runoff events per year

  #add additional Arizona data-----------------------------------------------------
  more_arizona$ma_num_flowing_days <- 365*more_arizona$perc_record_flowing#(more_arizona$period_of_record_yrs*365*((24*60/10)*more_arizona$perc_record_flowing))/(more_arizona$period_of_record_yrs*365) #because its defined as a percent of the record, we have to convert 10' sampling frequency to daily average
  more_arizona <- more_arizona %>%
    dplyr::select(c('watershed', 'site', 'drainage_area_km2', 'period_of_record_yrs', 'ma_num_flowing_days'))

  #add Ontario data-------------------------------------
    #already in number of flowing events per rain events (see paper), so no need to convert to 'daily resolution'.
    #Further, they only sampled July-Oct, so we double there number to capture springtime (Mar-June) flow which we assume as ~equivalent frequency. The other third of the year (winter) we assume no streamflow in Ontario.
  ontario <- data.frame('watershed'=geulph$watershed,
                        'site'=geulph$site,
                        'period_of_record_yrs'=rep(1,nrow(geulph)), #130 days, but we account for the other two seasons in our setup (see above)
                        'drainage_area_km2'=geulph$drainage_area_km2,
                        'ma_num_flowing_days'=geulph$num_flowing_events * 3) #2 assumed equivalent in springtime and zero flow in wintertime, so flowing at this frequency 2/3s of the year

  #add USGS ephemeral gage data-----------------------------
   ephemeralQDataset <- as.data.frame(ephemeralQDataset)
   ephemeralQDataset <- dplyr::filter(ephemeralQDataset, type == 'eph')#remove the ambigious 'ephemeral/intermittent' rivers flagged in the setupEphemeralQValidation function
  
  #just pass along since I already got ma num flowing days per site (in setupEphemeralQValidation function)
  eph_gages <- data.frame('watershed'=ephemeralQDataset$huc4,
                      'site'=ephemeralQDataset$huc4,
                      'period_of_record_yrs'=ephemeralQDataset$period_of_record_yrs,
                      'drainage_area_km2'=ephemeralQDataset$drainageArea_km2,
                      'ma_num_flowing_days'=ephemeralQDataset$num_flowing_dys)


  #bring it allllllllll together--------------------------------------
  results_all <- rbind(walnutGulch, santaRita, reynoldsCreek, mohaveYuma, kentucky, dukeForest, more_arizona, montoyas, ontario, eph_gages)
  
  output <- results_all %>%
    dplyr::group_by(watershed) %>%
    dplyr::summarise(n_flw_d = median(ma_num_flowing_days,na.rm=T),  #take catchment average across all flumed reaches (if necessary)
                     num_sample_yrs = round(mean(period_of_record_yrs),0), #mean across catchment reaches (mean of constants, just to propagate value)
                     drainage_area_km2 = median(drainage_area_km2),
                     n_sites=n()) %>%
    #some kind of random coordinates within the basin....
    #also unfortuantely need to be hardocded because I had to find the non-gage sites manually in their papers or online....
  dplyr::mutate(lat=c(43.436667,35.8933527,32.31537144,33.27555556,32.5886111,39.783585,36.64778269,36.1027488,35.24500556,33.69421054,33.72920456,36.00475278,36.021599, 43.54667, 32.711123, 31.540278, 33.3333333, 35.228431, 43.187, 37.47305556, 31.83341800, 31.66666667, 33.166667), #pulled from associated papers (general coords- Geulph long is moved ~15km east so it fits in model basin 0427)
                long=c(-106.419722,-107.4167143,-106.7505587,-106.3972222,-104.4213889,-108.189805,-108.1256268,-115.2077774,-115.2989889,-111.541802,-112.1198755,-115.6437917,-78.985034,-80.059, -112.831066, -110.334113, -114.50000000, -106.840627, -116.774, -83.14333333, -110.85286400 , -110.00000000, -114.50000000))
            #alphabetical list for data lat/longs
            #1009
            #1302
            #1303
            #1305
            #1306
            #1405
            #1408
            #1501
            #1503
            #1506
            #1507
            #1606
            #dukeForest
            #geulph
            #goldwater
            #huachuca
            #mohave
            #montoyas
            #reynolds creek
            #robinson Forest
            #Santa Rita
            #walnut gulch
            #yuma
  
  return(output)
}




#' Spatially joins field flowing days dataset to HUC4 basins (and takes HUC4 average when necessary)
#'
#' @name flowingValidate
#'
#' @param validationData: wrangled flowing days validation dataset
#' @param path_to_data: path to data repo
#' @param codes_huc02: all HUC2 basins
#' @param combined_results: all HUC4 basin model results
#' @param combined_numFlowingDays_mc: vector of number flowing days from monte carlo simulation (to calc sigma)
#' @param combined_runoffEff: df of runoff efficiencies per basin
#' @param combined_runoffThresh: vector of runoff threshs calcutaed per basin
#'
#' @import sf
#' @import dplyr
#'
#' @return df of all wrangled field data spatially joined to HUC4 basin shapefiles
flowingValidate <- function(validationData, path_to_data, codes_huc02, combined_results, combined_runoffEff, combined_runoffThresh){ #combined_numFlowingDays_mc
  #wrangle Monte Carlo simulation
  # mcDF <- data.frame('num_flowing_dys_sigma'=combined_numFlowingDays_mc)
  # mcDF$huc4 <- substr(row.names(mcDF), 19,23)
  # rownames(mcDF) <- NULL

  #read in all HUC4 basins
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
  #   validationData[k,]$numFlowingDays_da <- calcFlowingDays(path_to_data, validationData[k,]$huc4, combined_runoffEff, 2.5, 0, 4,0)
  #   #validationData[k,]$numFlowingDays_sigma_da <- calcFlowingDays(path_to_data, validationData[k,]$huc4, combined_runoffEff, validationData[k,]$runoffThresh_da, 0, 2, 1)
  # }
  basins_overall <- sf::st_read(paste0(path_to_data, '/HUC2_', codes_huc02[1], '/WBD_', codes_huc02[1], '_HU2_Shape/Shape/WBDHU4.shp')) %>% select(c('huc4', 'name'))
  for(i in codes_huc02[-1]){
    basins <- sf::st_read(paste0(path_to_data, '/HUC2_', i, '/WBD_', i, '_HU2_Shape/Shape/WBDHU4.shp')) %>% select(c('huc4', 'name')) #basin polygons
    basins_overall <- rbind(basins_overall, basins)
  }

  #join model results
  basins_overall <- dplyr::left_join(basins_overall, combined_results, by='huc4') #actual results
  #basins_overall <- dplyr::left_join(basins_overall, mcDF, by='huc4') #MC uncertainty
  basins_overall <- dplyr::select(basins_overall, c('huc4','name','geometry', 'num_flowing_dys'))#'num_flowing_dys_sigma',
  
  #join field data to HUC4 basin results
  validationData <- sf::st_as_sf(validationData, coords = c("long", "lat"), crs=sf::st_crs(basins_overall))
  validationData <- sf::st_intersection(basins_overall, validationData)


  return(validationData)
}






#' Calibrates a streamflow threshold for what counts as flow
#'
#' @name flowingValidateSensitivityWrapper
#'
#' @param flowingFieldData: field data on mean annual number of flowing days in ephemeral streams
#' @param runoffEffScalar_real: runoff scalar parameter used in model, held constant here
#' @param runoffMemory_real: runoff memory parameter used in model, held constant here
#' @param runoff_threshs: runoff thresholds to be tested
#' @param path_to_data: path to data repo
#' @param combined_runoffEff: runoff efficiencies for all basins
#'
#' @import Metrics
#' @import dplyr
#'
#' @return df of all model results (and their mean absolute error) using the set of tested runoff thresholds (runoff_threshs)
flowingValidateSensitivityWrapper <- function(flowingFieldData, runoffEffScalar_real, runoffMemory_real, runoff_threshs, path_to_data, combined_runoffEff) {
    huc4s = c('1009', '1302', '1303', '1305', '1306', '1405', '1408', '1501', '1503', '1506', '1507', '1606','0302', '0427', '1507', '1505', '1503', '1302', '1705', '0510', '1505', '1505', '1503') #basins with field data

    out <- data.frame()
    num_flowing_dys <- rep(NA, length(huc4s))
    for(i in runoff_threshs){
      for(k in 1:length(huc4s)){
        num_flowing_dys[k] <- calcFlowingDays(path_to_data, huc4s[k], combined_runoffEff, i, runoffEffScalar_real, runoffMemory_real,0)
      }
      temp <- data.frame('huc4'=huc4s,
                         'watershed'=flowingFieldData$watershed,
                         'num_flowing_dys'=num_flowing_dys)
      temp <- dplyr::left_join(flowingFieldData, temp, by='watershed')

      #group by huc4 (USGS gauges are already pre-grouped by huc4 (in setupEphemeralQValidation function) so this code is redundant for them)
      # temp <- dplyr::group_by(temp, huc4) %>%
      #   dplyr::summarise(name=first(watershed),
      #                    num_flowing_dys = mean(num_flowing_dys),
      #                    n_flw_d = mean(n_flw_d),
      #                    num_sample_yrs = mean(num_sample_yrs),
      #                    n_sites = sum(n_sites))

      mae <- Metrics::mae(temp$num_flowing_dys, temp$n_flw_d)

      temp2 <- data.frame('thresh'=i,
                          'mae'=mae)
      out <- rbind(out, temp2)
    }

    return(out)
}






# 
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