## Craig Brinkerhoff
## Summer 2022
## Gathers and builds verification figure for the numFlowingDays model, compared against gathered field data



#' wrangles existing (published) ephemeral field data to calculate 'number of flowing days' for their respective basins
#'
#' @name wrangleFlowingFieldData
#' data comes from the following field studies (all saved in data repo except the Duke Forest data which is hardcoded here):
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
#'
#' @param path_to_data: path to data repo
#'
#' @import readr
#' @import dplyr
#' @import tidyr
#' @import lubridate
#'
#' @return df of all wrangled field data in uniform form and with # flowing days for ephemeral streams calculated
wrangleFlowingFieldData <- function(path_to_data){
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
  mohaveYuma$watershed <- substr(mohaveYuma$site, 1, 1) #'mohave_yuma'
  mohaveYuma$watershed <- ifelse(mohaveYuma$watershed == 'M', 'mohave', 'yuma')
  mohaveYuma$period_of_record_yrs <- c(3, 2, 4, 2, 3, 1, 3, 2, 4, 1, 4, 2, 4, 1, 2, 4, 3, 2)
  mohaveYuma$num_flowing_days <- ifelse(mohaveYuma$num_flowing_events < 1, 1, mohaveYuma$num_flowing_events)
  mohaveYuma$ma_num_flowing_days <- mohaveYuma$num_flowing_days/(mohaveYuma$period_of_record_yrs)
  mohaveYuma$sd_num_flowing_days <- sd(mohaveYuma$num_flowing_days/mohaveYuma$period_of_record_yrs, na.rm=T)
  mohaveYuma <- mohaveYuma %>% dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'drainage_area_km2', 'ma_num_flowing_days', 'sd_num_flowing_days'))

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
    dplyr::mutate(sd_num_flowing_days = sd(num_flowing_days/period_of_record_yrs, na.rm=T)) %>%
    dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'drainage_area_km2', 'ma_num_flowing_days', 'sd_num_flowing_days'))

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
    dplyr::mutate(sd_num_flowing_days = sd(num_flowing_days/period_of_record_yrs, na.rm=T)) %>%
    dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'drainage_area_km2', 'ma_num_flowing_days', 'sd_num_flowing_days'))

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
    dplyr::mutate(sd_num_flowing_days = sd(num_flowing_days/period_of_record_yrs, na.rm=T)) %>%
    dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'drainage_area_km2', 'ma_num_flowing_days', 'sd_num_flowing_days'))

  #wrangling Kentucky Robinson Forest-----------
  kentucky$period_of_record_yrs <- kentucky$period_of_record_dys / 365

  #done separately for different datasets with different sampling frequencies
  kentucky$num_flowing_events <- (kentucky$perc_record_w_flow * (kentucky$period_of_record_dys*(60*24/15)))/kentucky$period_of_record_dys #convert 15' data to daily averages
  
  #single year, so no averaging
  kentucky$ma_num_flowing_days <- kentucky$num_flowing_events + 2 #field data in catchment only reports 1 or 2 flow events in the non-sampled months (see paper ad Fritz etal 2010)
  kentucky$sd_num_flowing_days <- NA #only 1 year of sampling
  
  kentucky <- kentucky %>%
    dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'drainage_area_km2', 'ma_num_flowing_days', 'sd_num_flowing_days'))

  # #add Duke Forest manually (https://doi.org/10.1002/hyp.11301)---------------------------------------
  dukeForest <- data.frame('watershed'='dukeForest',
                           'site'='a',
                           'period_of_record_yrs'=1,
                           'drainage_area_km2'=3.3*0.01,
                           'ma_num_flowing_days'=(365*0.44)*0.37,
                           'sd_num_flowing_days' = NA) #only 1 year of sampling

  #add Montoyas watershed, urban system near Albuquerque, New Mexico manually (https://doi.org/10.1016/j.ejrh.2022.101089)-------------------------------------
  montoyas <- data.frame('watershed'='montoyas',
                         'site'='a',
                         'period_of_record_yrs'=7, #2008-2014
                         'drainage_area_km2'=142,
                         'ma_num_flowing_days'=mean(c(2,0,1,0,0,5,2)),#See paper Table 1 for runoff events per year
                         'sd_num_flowing_days'=sd(c(2,0,1,0,0,5,2)))

  #add additional Arizona data-----------------------------------------------------
  more_arizona$ma_num_flowing_days <- (more_arizona$period_of_record_yrs*365*((24*60/10)*more_arizona$perc_record_flowing))/(more_arizona$period_of_record_yrs*365) #have to convert 10' sampling frequency to daily average
  more_arizona <- more_arizona %>%
    dplyr::select(c('watershed', 'site', 'drainage_area_km2', 'period_of_record_yrs', 'ma_num_flowing_days')) %>%
    dplyr::mutate(sd_num_flowing_days = NA) #percent of record with flow can't be converted to SD

  #add Ontario data-------------------------------------
    #already in number of flowing events per rain events (see paper), so no need to convert to 'daily resolution'.
    #Further, they only sampled July-Oct, so we double there number to capture springtime (Mar-June) flow which we assume as ~equivalent frequency. The other third of the year (winter) we assume no streamflow in Ontario.
  ontario <- data.frame('watershed'='geulph',
                        'site'='a',
                        'period_of_record_yrs'=1, #130 days, but we account for the other two seasons in our setup (see above)
                        'drainage_area_km2'=mean(geulph$drainage_area_km2),
                        'ma_num_flowing_days'=mean(geulph$num_flowing_events) * 2, #assumed equivalent in springtime and zero flow in wintertime, so flowing at this frequency 2/3s of the year
                        'sd_num_flowing_days'=NA) #only 1 year of sampling

  #bring it allllllllll together--------------------------------------
  results_all <- rbind(walnutGulch, santaRita, reynoldsCreek, mohaveYuma, kentucky, dukeForest, more_arizona, montoyas, ontario)

  output <- results_all %>%
    dplyr::group_by(watershed) %>%
    dplyr::summarise(n_flw_d = mean(ma_num_flowing_days,na.rm=T),  #take catchment average across all flumed reaches (if necessary)
                     sd_flw_d = mean(sd_num_flowing_days, na.rm=T), #catchment-average of sd of num flowing days (over time)
                     num_sample_yrs = round(mean(period_of_record_yrs),0)) %>% #mean across catchment reaches (mean of constants, just to propagate value)
  dplyr::mutate(lat=c(36.020631, 43.54667, 32.711123, 31.540278, 33.3333333, 35.228431, 43.187, 37.47305556, 31.83341800, 31.66666667, 33.166667), #pulled from associated papers (general coords- Geulph long is moved ~15km east so it fits in model basin 0427)
           long=c(-78.982789, -80.059, -112.831066, -110.334113, -114.50000000, -106.840627, -116.774, -83.14333333, -110.85286400 , -110.00000000, -114.50000000))
            #alphabetical list for data lat/longs
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

  write_csv(output, file='cache/numFlowingDay_data.csv')
}



#' Sptially joins field flowing days dataset to HUC4 basins (and takes HUC4 average when necessary)
#'
#' @name flowingValidate
#'
#' @param validationData: wrangled flowing days validation dataset
#' @param path_to_data: path to data repo
#' @param codes_huc02: all HUC2 basins
#' @param combined_results: all HUC4 basin model results
#'
#' @import sf
#' @import dplyr
#'
#' @return df of all wrangled field data spatially joined to HUC4 basin shapefiles
flowingValidate <- function(validationData, path_to_data, codes_huc02, combined_results, combined_numFlowingDays_mc){
  #wrangle Monte Carlo simulation
  mcDF <- data.frame('num_flowing_dys_sigma'=combined_numFlowingDays_mc)
  mcDF$huc4 <- substr(row.names(mcDF), 19,23)
  rownames(mcDF) <- NULL
  
  #field data
  og_data <- validationData

  #read in all HUC4 basins
  basins_overall <- sf::st_read(paste0(path_to_data, '/HUC2_', codes_huc02[1], '/WBD_', codes_huc02[1], '_HU2_Shape/Shape/WBDHU4.shp')) %>% select(c('huc4', 'name'))
  for(i in codes_huc02[-1]){
    basins <- sf::st_read(paste0(path_to_data, '/HUC2_', i, '/WBD_', i, '_HU2_Shape/Shape/WBDHU4.shp')) %>% select(c('huc4', 'name')) #basin polygons
    basins_overall <- rbind(basins_overall, basins)
  }

  #join model results
  basins_overall <- dplyr::left_join(basins_overall, combined_results, by='huc4') #actual results
  basins_overall <- dplyr::left_join(basins_overall, mcDF, by='huc4') #MC uncertainty
  basins_overall <- dplyr::select(basins_overall, c('huc4','name','num_flowing_dys','num_flowing_dys_sigma','geometry'))

  #join field data to HUC4 basin results
  validationData <- sf::st_as_sf(validationData, coords = c("long", "lat"), crs=sf::st_crs(basins_overall))
  validationData <- sf::st_intersection(basins_overall, validationData)

  return(validationData)
}



#' Pseudo-calibrates a streamflow threshold for what counts as flow
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
    huc4s = c('0302', '0427', '1507', '1505', '1503', '1302', '1705', '0510', '1505', '1505', '1503') #basins with field data

    out <- data.frame()
    num_flowing_dys <- rep(NA, length(huc4s))
    for(i in runoff_threshs){
      for(k in 1:length(huc4s)){
        num_flowing_dys[k] <- calcFlowingDays(path_to_data, huc4s[k], combined_runoffEff, i, runoffEffScalar_real, runoffMemory_real,0) #calculate ballpark number of flowing days
      }
      temp <- data.frame('huc4'=huc4s,
                         'watershed'=flowingFieldData$watershed,
                         'num_flowing_dys'=num_flowing_dys)
      temp <- dplyr::left_join(flowingFieldData, temp, by='watershed')
      mae <- Metrics::mae(temp$num_flowing_dys, temp$n_flw_d)

      temp2 <- data.frame('thresh'=i,
                          'mae'=mae)
      out <- rbind(out, temp2)
    }

    return(out)
}
