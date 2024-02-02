## Craig Brinkerhoff
## Fall 2023
## Functions to validate ephemeral flow frequency model




#' Calculates in situ mean annual discharge and Nflw for USGS ephemeral streamgauges
#'
#' @name wrangleUSGSephGages
#'
#' @param other_sites: lookup table of USGS ephemeral streamgauges
#'
#' @import dataRetrieval
#' @import dplyr
#'
#' @return df of all USGS streamgauges with observed Nflw and drainage areas
wrangleUSGSephGages <- function(other_sites){
  #USGS ephemeral gauges
  other_sites$short_name <- substr(other_sites$name, 6,nchar(other_sites$name))
  
  #loop through gauges and calculate Nflw from observed record
  out <- data.frame()
  for(i in other_sites$short_name){
    gageQ <- dataRetrieval::readNWISdv(siteNumbers = i, #check if site mets our date requirements and are in our a priori site list
                        parameterCd = '00060') #discharge
    
    #get mean annual flow
    if(nrow(gageQ)==0){next} #some go these gages don't have their data online (in local USGS offices only.....)
    
    gageQ <- gageQ %>% 
      dplyr::mutate(Q_cms = round(X_00060_00003*0.0283,3))#round to 3 decimals to reduce noise near zero flow (simmilar to https://doi.org/10.1029/2021GL093298,  https://doi.org/10.1029/2020GL090794 but in cms instead of cfs)
      #this is also equivalent to what we do in the discharge model validation
    
    Q_MA <- mean(gageQ$Q_cms, na.rm=T) #mean annual
    numFlow <- (sum(gageQ$Q_cms > 0, na.rm=T)/nrow(gageQ))*365
    
    temp <- data.frame('gageID'=i, #take first row of duplicates
                       'meas_runoff_m3_s'=Q_MA,
                       'num_flowing_dys'=numFlow,
                       'period_of_record_yrs'=nrow(gageQ)/365)
    
    out <- rbind(out, temp)
  }

  #prep output
  out <- out %>%
    dplyr::left_join(other_sites, by=c('gageID'='short_name')) %>% #get the gauge drainage area
    dplyr::select(c('gageID', 'huc4', 'reference','meas_runoff_m3_s', 'drainageArea_km2', 'num_flowing_dys', 'period_of_record_yrs', 'lon', 'lat')) %>%
    dplyr::mutate(type = ifelse(gageID %in% c('06268500', #see ~/docs/README_usgs_eph_gages.html for 'eph_int' vs 'eph' was determined
                                              '06313700',
                                              '06425750',
                                              '06425780',
                                              '08331660',
                                              '08477600',
                                              '08480595',
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
                                              '10250800'), 'eph_int', 'eph')) 
  
  
  return(out)
}







#' Wrangles existing (published) ephemeral field data to calculate in situ Nflw
#'
#' @name wrangleFlowingFieldData
#' @note data comes from the following field studies (some are hardcoded into this function, but most are saved in the data repo):
#'    Duke Forest, NC: https://doi.org/10.1002/hyp.11301 (1 years data)
#'    Robinson Forest, KY: https://doi.org/10.1002/ecs2.2654 (0.58 years of data)
#'    Mohave and Yuma Basins, AZ: https://doi.org/10.1029/2018WR023714 (2-3 years data)
#'    Reynold's Creek, ID: https://doi.org/10.1029/2001WR000413 (29 years of data) Ephemeral site identification within catchment uses https://doi.org/10.1029/2001WR000420
#'    Santa Rita Basin, AZ: https://doi.org/10.1029/2006WR005733 (46 years of data)
#'    Walnut Gulch Basin, AZ: https://doi.org/10.1029/2006WR005733 (45 years of data)
#'    Montoyas Catchment near Albuquerque, NM:  https://doi.org/10.1016/j.ejrh.2022.101089 (6 years of data)
#'    More Arizona data for various arid catchments https://doi.org/10.1016/j.jaridenv.2016.12.004 (2 years of data). This has additional data for Santa Rita basin that gets averaged into the Santa Rita dataset
#'    Geulph Ontario data  https://doi.org/10.1002/hyp.10136 (1/3 year of data)
#'    Gage data from Wyoming, Colorado, and New Mexico per ephemeral gages from USGS reports (data for a few years in the 1970s)
#'
#' @param path_to_data: data repo path directory
#' @param ephemeralQDataset: df of USGS ephemeral streamgauges' in situ Nflw
#'
#' @import readr
#' @import dplyr
#' @import tidyr
#' @import lubridate
#'
#' @return df of all wrangled field data in uniform form and with # flowing days for ephemeral streams calculated
wrangleFlowingFieldData <- function(path_to_data, ephemeralQDataset){
  runoff_thresh <- 0 #It is difficult to get flow thresholds (as well as flow rounding protocols) to be consistent across these datasets, so I don't bother and instead highlight that results are highly uncertain and should be further explored in future work

  #read in data--------------------------------------------------------
  walnutGulch <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/WalnutGulchData.csv'))
  reynoldsCreek <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/ReynoldsCreekData.csv'))
  mohaveYuma <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/MohaveYumaData.csv'))
  santaRita <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/SantaRitaData.csv'))
  kentucky <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/Kentucky.csv'))
  more_arizona <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/stromberg_etal_2017.csv'))
  geulph <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/ontario.csv'))



  #wrangling Mohave Yuma (https://doi.org/10.1029/2018WR023714)-------------------------------
  colnames(mohaveYuma) <- c('site', 'drainage_area_km2', 'elevation_m', 'period_of_record', 'num_flowing_events', 'ma_num_flowing_events', 'reference')
  mohaveYuma$watershed <- substr(mohaveYuma$site, 1, 1)
  mohaveYuma$watershed <- ifelse(mohaveYuma$watershed == 'M', 'mohave', 'yuma')
  mohaveYuma$period_of_record_yrs <- c(3, 2, 4, 2, 3, 1, 3, 2, 4, 1, 4, 2, 4, 1, 2, 4, 3, 2) #(inputted here manually out of necessity)
  mohaveYuma$num_flowing_days <- ifelse(mohaveYuma$num_flowing_events < 1, 1, mohaveYuma$num_flowing_events)
  mohaveYuma$ma_num_flowing_days <- mohaveYuma$num_flowing_days/(mohaveYuma$period_of_record_yrs)
  mohaveYuma <- mohaveYuma %>%
    dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'drainage_area_km2', 'ma_num_flowing_days','reference'))



  #wrangling walnut gulch (https://doi.org/10.1029/2006WR005733)--------------------------
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
    dplyr::mutate(drainage_area_km2 = c(36900, 9.1, 11.2, 2035, 4.6, 13.4, 14.6, 5912, 28100, 2220, 560, 23500, 3340)*0.004) %>% #see source reference for these numbers (inputted here manually out of necessity)
    dplyr::mutate(ma_num_flowing_days = num_flowing_days / (period_of_record_yrs),
                  reference='@stoneLongtermRunoffDatabase2008') %>%
    dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'drainage_area_km2', 'ma_num_flowing_days','reference'))



  #wrangling Santa Rita (https://doi.org/10.1029/2006WR005733)------------------------
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
    dplyr::mutate(drainage_area_km2 = c(4.04, 4.37, 6.81, 4.88, 9.93, 7.6, 2.63, 2.77)*0.004) %>% #see source reference for these numbers (inputted here manually out of necessity)
    dplyr::mutate(ma_num_flowing_days = num_flowing_days / (period_of_record_yrs),
                  reference='@stoneLongtermRunoffDatabase2008') %>%
    dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'drainage_area_km2', 'ma_num_flowing_days','reference'))
  


  #wrangling reynolds creek (https://doi.org/10.1029/2001WR000413)------------------
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
    dplyr::mutate(ma_num_flowing_days = num_flowing_days / (period_of_record_yrs),
                  reference='@slaughterThirtyfiveYearsResearch2001') %>%
    dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'drainage_area_km2', 'ma_num_flowing_days','reference'))



  #wrangling Kentucky Robinson Forest (https://doi.org/10.1002/ecs2.2654)-------------------------
  kentucky$period_of_record_yrs <- kentucky$period_of_record_dys / 365
  kentucky$num_flowing_events <- kentucky$perc_record_w_flow*365
  kentucky$ma_num_flowing_days <- kentucky$num_flowing_events + 2 #field data in catchment only reports 1 or 2 flow events in the non-sampled months (see paper https://doi.org/10.1899/09-060.1)

  kentucky <- kentucky %>%
    dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'drainage_area_km2', 'ma_num_flowing_days', 'reference'))



  #add Duke Forest manually (https://doi.org/10.1002/hyp.11301)---------------------------------------
  dukeForest <- data.frame('watershed'='dukeForest',
                           'site'='a',
                           'period_of_record_yrs'=1,
                           'drainage_area_km2'=3.3*0.01,
                           'ma_num_flowing_days'=(365*0.44), #(inputted here manually out of necessity)
                           'reference'='@zimmerBidirectionalStreamGroundwater2017')



  #add Montoyas watershed, urban system near Albuquerque, New Mexico manually (https://doi.org/10.1016/j.ejrh.2022.101089)-------------------------------------
  montoyas <- data.frame('watershed'='montoyas',
                         'site'='a',
                         'period_of_record_yrs'=7, #2008-2014
                         'drainage_area_km2'=142,
                         'ma_num_flowing_days'=mean(c(2,0,1,0,0,5,2)), #See paper Table 1 for runoff events per year (inputted here manually out of necessity)
                         'reference'='@schoenerImpactUrbanizationStormwater2022')



  #add additional Arizona data https://doi.org/10.1016/j.jaridenv.2016.12.004-----------------------------------------------------
  more_arizona$ma_num_flowing_days <- 365*more_arizona$perc_record_flowing
  more_arizona <- more_arizona %>%
    dplyr::select(c('watershed', 'site', 'drainage_area_km2', 'period_of_record_yrs', 'ma_num_flowing_days', 'reference'))



  #add Ontario data (https://doi.org/10.1002/hyp.10136)-------------------------------------
    #Further, they only sampled July-Oct, so we triple their number assuming that flow frequency is more or less homogeneous across seasons (in lieu of any other knowledge available to us)
  ontario <- data.frame('watershed'=geulph$watershed,
                        'site'=geulph$site,
                        'period_of_record_yrs'=rep(1,nrow(geulph)),
                        'drainage_area_km2'=geulph$drainage_area_km2,
                        'ma_num_flowing_days'=geulph$num_flowing_events * 3, #apply equivalent rate over the rest of the year
                        'reference'=geulph$reference)



  #add USGS ephemeral gage data (already calculated and read into function)-----------------------------
   ephemeralQDataset <- as.data.frame(ephemeralQDataset)
   ephemeralQDataset <- dplyr::filter(ephemeralQDataset, type == 'eph')#remove the ambiguous 'ephemeral/intermittent' rivers flagged in the setupEphemeralQValidation function and manually QAQC'd
  


  #just pass along since I already have mean annual Nflw per site (in setupEphemeralQValidation function)
  eph_gages <- data.frame('watershed'=ephemeralQDataset$huc4,
                          'site'=ephemeralQDataset$gageID,
                          'period_of_record_yrs'=ephemeralQDataset$period_of_record_yrs,
                          'drainage_area_km2'=ephemeralQDataset$drainageArea_km2,
                          'ma_num_flowing_days'=ephemeralQDataset$num_flowing_dys,
                          'reference'=ephemeralQDataset$reference)


  #bring all these data together into single df--------------------------------------
  results_all <- rbind(walnutGulch, santaRita, reynoldsCreek, mohaveYuma, kentucky, dukeForest, more_arizona, montoyas, ontario, eph_gages)

  #wrangle into uniform format
  output <- results_all %>%
    dplyr::group_by(watershed) %>%
    dplyr::summarise(watershed=first(watershed),
                     n_flw_d = mean(ma_num_flowing_days,na.rm=T),  #take catchment average across all flumed reaches (if necessary)
                     num_sample_yrs = round(mean(period_of_record_yrs),0), #mean across catchment reaches (mean of constants, just to propagate value)
                     drainage_area_km2 = mean(drainage_area_km2),
                     n_sites=n(),
                     reference=first(reference)) %>%
    #Here we assign approximate lat/lons for the basins (so these can be mapped in the paper figures)
    #Unfortunately, most of these need to be hardcoded because I had to find most of the sites manually
  dplyr::mutate(lat=c(43.436667,35.8933527,32.31537144,32.5886111,39.783585,36.64778269,36.1027488,35.24500556,33.69421054,33.72920456,36.00475278,36.021599, 43.54667, 32.711123, 31.540278, 33.3333333, 35.228431, 43.187, 37.47305556, 31.83341800, 31.66666667, 33.166667), #pulled from associated papers (general coords- Geulph long is moved ~15km east so it fits in model basin 0427)
                long=c(-106.419722,-107.4167143,-106.7505587,-104.4213889,-108.189805,-108.1256268,-115.2077774,-115.2989889,-111.541802,-112.1198755,-115.6437917,-78.985034,-80.059, -112.831066, -110.334113, -114.50000000, -106.840627, -116.774, -83.14333333, -110.85286400 , -110.00000000, -114.50000000))
            #alphabetical list for data the lat/longs that are manually added
            #1009 USGS
            #1302 USGS
            #1303 USGS
            #1305 USGS
            #1306 USGS
            #1405 USGS
            #1408 USGS
            #1501 USGS
            #1503 USGS
            #1506 USGS
            #1507 USGS
            #1606 USGS
            #Duke Forest
            #Geulph
            #Goldwater
            #Huachuca
            #Mohave
            #Montoyas
            #Reynolds creek
            #Robinson Forest
            #Santa Rita
            #Walnut Gulch
            #Yuma
  
  return(output)
}






#' Spatially joins field Nflw dataset to HUC4 basins (and takes basin average when necessary)
#'
#' @name flowingValidate
#'
#' @param validationData: wrangled flowing days verification dataset
#' @param path_to_data: data repo path directory
#' @param codes_huc02: all HUC2 basin IDs
#' @param combined_results: all HUC4 basin model results
#' @param combined_runoffEff: df of basin-average runoff coefficients
#'
#' @import sf
#' @import dplyr
#'
#' @return df of all wrangled field data spatially joined to HUC4 basin shapefiles
flowingValidate <- function(validationData, path_to_data, codes_huc02, combined_results, combined_runoffEff){
  #read in all HUC4 basins and make combined shapefile
  basins_overall <- sf::st_read(paste0(path_to_data, '/HUC2_', codes_huc02[1], '/WBD_', codes_huc02[1], '_HU2_Shape/Shape/WBDHU4.shp')) %>% select(c('huc4', 'name'))
  for(i in codes_huc02[-1]){
    basins <- sf::st_read(paste0(path_to_data, '/HUC2_', i, '/WBD_', i, '_HU2_Shape/Shape/WBDHU4.shp')) %>% 
      select(c('huc4', 'name')) #basin polygons
    basins_overall <- rbind(basins_overall, basins)
  }

  #join model results
  basins_overall <- dplyr::left_join(basins_overall, combined_results, by='huc4') #actual results
  basins_overall <- dplyr::select(basins_overall, c('huc4','name','geometry', 'num_flowing_dys'))#'num_flowing_dys_sigma',
  
  #join field data to HUC4 basin results
  validationData <- sf::st_as_sf(validationData, coords = c("long", "lat"), crs=sf::st_crs(basins_overall))
  validationData <- sf::st_intersection(basins_overall, validationData)


  return(validationData)
}








#' Calibrates an operational runoff threshold using all of the in situ data (i_min in paper)
#'
#' @name flowingValidateSensitivityWrapper
#'
#' @param flowingFieldData: in situ ephemeral Nflw dataset
#' @param runoffEffScalar_real: runoff scalar parameter
#' @param runoffMemory_real: runoff memory parameter
#' @param runoff_threshs: runoff thresholds to be tested
#' @param path_to_data: data repo path directory
#' @param combined_runoffEff: df of basin-average runoff coefficients
#'
#' @import Metrics
#' @import dplyr
#'
#' @return df of all model results (and performance metrics) for the set of tested runoff thresholds
flowingValidateSensitivityWrapper <- function(flowingFieldData, runoffEffScalar_real, runoffMemory_real, runoff_threshs, path_to_data, combined_runoffEff) {
    #basins with field data (must be hardcoded)
    huc4s = c('1009', '1302', '1303', '1306', '1405', '1408', '1501', '1503', '1506', '1507', '1606','0302', '0427', '1507', '1505', '1503', '1302', '1705', '0510', '1505', '1505', '1503')

    out <- data.frame()
    num_flowing_dys <- rep(NA, length(huc4s))
    for(i in runoff_threshs){
      for(k in 1:length(huc4s)){
        num_flowing_dys[k] <- calcFlowingDays(path_to_data, huc4s[k], combined_runoffEff, i, runoffEffScalar_real, runoffMemory_real) #~src/analysis.R
      }
      temp <- data.frame('huc4'=huc4s,
                         'watershed'=flowingFieldData$watershed,
                         'num_flowing_dys'=num_flowing_dys)
      temp <- dplyr::left_join(flowingFieldData, temp, by='watershed')

      r2 <- summary(lm(num_flowing_dys ~ n_flw_d, data=temp))$r.squared
      mae <- Metrics::mae(temp$num_flowing_dys, temp$n_flw_d)
      rmse <- Metrics::rmse(temp$num_flowing_dys, temp$n_flw_d)

      temp2 <- data.frame('thresh'=i,
                          'r2'=r2,
                          'mae'=mae,
                          'rmse'=rmse)

      out <- rbind(out, temp2)
    }

    out2 <- list('thresh'=out[which.min(out$mae),]$thresh, #[mm/dy]
                'df'=out) #all results

    return(out2)
}