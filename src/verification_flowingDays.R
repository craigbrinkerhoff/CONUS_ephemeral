## Craig Brinkerhoff
## Functions to validate ephemeral flow frequency model
## Spring 2024



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
      #this is also equivalent to what we do in the discharge model validation (~/src/prep_gagedata.R)
    
    Q_MA <- mean(gageQ$Q_cms, na.rm=T) #mean annual
    numFlow <- (sum(gageQ$Q_cms > 0, na.rm=T)/nrow(gageQ))*365
    
    temp <- data.frame('gageID'=i, #take first row of duplicates
                       'meas_runoff_m3_s'=Q_MA,
                       'num_flowing_dys'=numFlow,
                       'period_of_record_yrs'=nrow(gageQ)/365)
    
    out <- rbind(out, temp)
  }

  #prep lookup table
  not_eph_gauges <- readr::read_csv('docs/usgs_skip_gauges.csv') #lookup for gauges that have been manually identified as not 'strictly' ephemeral (and their associated huc4 basins). See ~/docs/README_usgs_eph_gauges.Rmd for this process and notes.

  #prep output
  out <- out %>%
    dplyr::left_join(other_sites, by=c('gageID'='short_name')) %>% #get the gauge drainage area
    dplyr::select(c('gageID', 'huc4', 'reference','meas_runoff_m3_s', 'drainageArea_km2', 'num_flowing_dys', 'period_of_record_yrs', 'lon', 'lat')) %>%
    dplyr::mutate(type = ifelse(gageID %in% not_eph_gauges$gageID, 'eph_int', 'eph'))
  
  return(out)
}







#' Wrangles existing (published) ephemeral field data into a single copacetic df to calculate in situ Nflw (and compare against our model). Note that there are many numbers manually hardcoded here that were pulled from these studies.
#' When more appropriate, these data re stored in csvs in the data repo. See README and below for structure
#'
#' @name wrangleFlowingFieldData
#' @note data comes from the following field studies (some are hardcoded into this function, but most are saved in the data repo):
#'    Duke Forest, NC: https://doi.org/10.1002/hyp.11301 (1 years data)
#'    Robinson Forest, KY: https://doi.org/10.1002/ecs2.2654 (0.5 years of data)
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
  #It is difficult to get flow thresholds (as well as flow rounding protocols) to be consistent across these datasets given what is availble in the literature.
    #Here, we assume it is zero if the data requires a threshold to calculate, otherwise we use the definitions implicit in the published data. See manuscript, but we confirmed to the best of our ability these defintions are similar.
    #The operational runoff threshold used in our model is one way to be robust against differences in operational definitons: by fitting a global-scope threshold, we somewhat remove the influence of individual study thresholds on overall results, though we stress more data is needed
    #See manuscript for more on this.
  runoff_thresh <- 0

  #read in data--------------------------------------------------------
  walnutGulch <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/WalnutGulchData.csv')) #pulled from paper
  reynoldsCreek <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/ReynoldsCreekData.csv')) #downloaded as is
  mohaveYuma <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/MohaveYumaData.csv')) #pulled from paper
  santaRita <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/SantaRitaData.csv')) #downloaded as is
  kentucky <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/Kentucky.csv')) #pulled from paper
  more_arizona <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/stromberg_etal_2017.csv')) #pulled from paper
  geulph <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/ontario.csv')) #pulled from paper
  montoyas <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/montoyas.csv')) #pulled from paper (10 flow events over 7 years- see csv for numbers)
  dukeForest <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/dukeForest.csv')) #pulled from paper (flowed 44% of the time per one water year- see csv for 365*0.44)

  locations_approx <- readr::read_csv('data/locations_approx.csv') #approximate locations of field sites (for Fig 3a map).



  #wrangling Mohave Yuma (https://doi.org/10.1029/2018WR023714)-------------------------------
  colnames(mohaveYuma) <- c('site', 'drainage_area_km2', 'elevation_m', 'period_of_record', 'num_flowing_events', 'ma_num_flowing_events', 'reference')
  mohaveYuma$watershed <- substr(mohaveYuma$site, 1, 1)
  mohaveYuma$watershed <- ifelse(mohaveYuma$watershed == 'M', 'mohave', 'yuma')
  mohaveYuma$period_of_record_yrs <- c(3, 2, 4, 2, 3, 1, 3, 2, 4, 1, 4, 2, 4, 1, 2, 4, 3, 2) #data (in csv) were downloaded from paper, here we manually add the period of record in yrs for completeness from Table 1 in that paper
  mohaveYuma$num_flowing_days <- ifelse(mohaveYuma$num_flowing_events < 1, 1, mohaveYuma$num_flowing_events)
  mohaveYuma$ma_num_flowing_days <- mohaveYuma$num_flowing_days/(mohaveYuma$period_of_record_yrs)
  mohaveYuma <- mohaveYuma %>%
    dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'ma_num_flowing_days','reference'))



  #wrangling walnut gulch (https://doi.org/10.1029/2006WR005733)--------------------------
  #Note that we only use a subset of instrumented flumes to make analysis quicker. These are manually specified below and are well-distributed across the drainage network.
  walnutGulch <- tidyr::gather(walnutGulch, key=site, value=runoff_mm, c("Flume 1", "Flume 2", "Flume 3","Flume 4","Flume 6","Flume 7","Flume 11","Flume 15","Flume 103","Flume 104", "Flume 112", "Flume 121", "Flume 125"))
  walnutGulch$date <- paste0(walnutGulch$Year, '-', walnutGulch$Month, '-', walnutGulch$Day)
  walnutGulch$date <- lubridate::as_date(walnutGulch$date)

  #wrangle
  walnutGulch <- walnutGulch %>%
    dplyr::mutate(year = lubridate::year(date)) %>%
    dplyr::group_by(site) %>% #get no flow stats per sub watershed
    dplyr::summarise(period_of_record_yrs = length(unique(year)),
                    num_flowing_days = sum(runoff_mm > runoff_thresh),
                    watershed=first(watershed),
                    reference=first(reference)) %>%
    dplyr::mutate(ma_num_flowing_days = num_flowing_days / (period_of_record_yrs),
                  reference='@stoneLongtermRunoffDatabase2008') %>%
      dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'ma_num_flowing_days','reference'))



  #wrangling Santa Rita (https://doi.org/10.1029/2006WR005733)------------------------
  #Note that we only use a subset of instrumented flumes to make analysis quicker. These are manually specified below and are well-distributed across the drainage network.
  santaRita <- tidyr::gather(santaRita, key=site, value=runoff_mm, c("Flume 1", "Flume 2", "Flume 3","Flume 4","Flume 5","Flume 6","Flume 7","Flume 8"))
  santaRita$date <- paste0(santaRita$Year, '-', santaRita$Month, '-', santaRita$Day)
  santaRita$date <- lubridate::as_date(santaRita$date)

  #wrangle
  santaRita <- santaRita %>%
    dplyr::mutate(year = lubridate::year(date)) %>%
    dplyr::group_by(site) %>% #get no flow stats per sub watershed
    dplyr::summarise(period_of_record_yrs = length(unique(year)),
              num_flowing_days = sum(runoff_mm > runoff_thresh),
              watershed=first(watershed),
              reference=first(reference)) %>%
    dplyr::mutate(ma_num_flowing_days = num_flowing_days / (period_of_record_yrs),
                  reference='@stoneLongtermRunoffDatabase2008') %>%
      dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'ma_num_flowing_days','reference'))
  


  #wrangling reynolds creek (https://doi.org/10.1029/2001WR000413)------------------
  reynoldsCreek$date <- paste0(reynoldsCreek$year, '-', reynoldsCreek$month, '-', reynoldsCreek$day)
  reynoldsCreek$date <- lubridate::as_date(reynoldsCreek$date)

  #Add drainage areas to runoff data (to back out discharge)
    #See data repo csv. Drainage areas (in ha) were obtained form Pierson, F. B., Slaughter, C. W., & Cram, Z. K. (2000). Monitoring discharge and suspended sediment, Reynolds Creek experimental watershed, Idaho, USA. Tech. Bull. NWRC‐2000, 8.
  areaLookUp <- readr::read_csv('data/ReynoldsCreekDrainageAreas.csv')
  reynoldsCreek <- dplyr::left_join(reynoldsCreek, areaLookUp, by='site')
  reynoldsCreek$drainage_area_km2 <- reynoldsCreek$drainage_area_ha * 0.01 #ha to km2
  
  #wrangle
  reynoldsCreek <- dplyr::group_by(reynoldsCreek, site, date) %>% #hourly to mean daily flow
    dplyr::summarise(watershed=first(watershed),
              site=first(site),
              runoff_mm = sum(((discharge*1000000000)/(drainage_area_km2*0.01*1000000000000))*60*24)) %>% #m3/s to mm/day
    dplyr::mutate(year = lubridate::year(date)) %>%
    dplyr::group_by(site) %>% #get no flow stats per sub watershed
    dplyr::summarise(period_of_record_yrs = length(unique(year)),
              num_flowing_days = sum(runoff_mm > runoff_thresh),
              watershed=first(watershed)) %>%
    dplyr::mutate(ma_num_flowing_days = num_flowing_days / (period_of_record_yrs),
                  reference='@slaughterThirtyfiveYearsResearch2001') %>%
    dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'ma_num_flowing_days','reference'))



  #wrangling Kentucky Robinson Forest (https://doi.org/10.1002/ecs2.2654)-------------------------
  kentucky$period_of_record_yrs <- kentucky$period_of_record_dys / 365 #only half a year of data
  kentucky$num_flowing_events <- kentucky$perc_record_w_flow*365
  kentucky$ma_num_flowing_days <- kentucky$num_flowing_events + 2 #other field data in catchment only reports 1 or 2 flow events in the non-sampled months (see related paper https://doi.org/10.1899/09-060.1)

  kentucky <- kentucky %>%
    dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'ma_num_flowing_days', 'reference'))



  #add Duke Forest manually (https://doi.org/10.1002/hyp.11301)---------------------------------------
  dukeForest <- dukeForest %>%
    dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'ma_num_flowing_days', 'reference'))



  #add Montoyas watershed, urban system near Albuquerque, New Mexico manually (https://doi.org/10.1016/j.ejrh.2022.101089)-------------------------------------
  montoyas <- montoyas %>%
    dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'ma_num_flowing_days', 'reference'))



  #add additional Arizona data https://doi.org/10.1016/j.jaridenv.2016.12.004-----------------------------------------------------
  more_arizona$ma_num_flowing_days <- 365*more_arizona$perc_record_flowing
  more_arizona <- more_arizona %>%
    dplyr::select(c('watershed', 'site', 'period_of_record_yrs', 'ma_num_flowing_days', 'reference'))



  #add Ontario data (https://doi.org/10.1002/hyp.10136)-------------------------------------
    #Further, they only sampled July-Oct, so we triple their number assuming that flow frequency is more or less homogeneous across seasons (in lieu of any other knowledge available to us)
  ontario <- data.frame('watershed'=geulph$watershed,
                        'site'=geulph$site,
                        'period_of_record_yrs'=rep(1,nrow(geulph)),
                        'ma_num_flowing_days'=geulph$num_flowing_events * 3, #apply equivalent rate over the rest of the year- see manuscript for this assumption (we make a related assumption for kentucky sites above too)
                        'reference'=geulph$reference)



  #add USGS ephemeral gage data (already calculated and read into function)-----------------------------
   ephemeralQDataset <- as.data.frame(ephemeralQDataset)
   ephemeralQDataset <- dplyr::filter(ephemeralQDataset, type == 'eph')#remove the ambiguous 'ephemeral/intermittent' rivers flagged in the setupEphemeralQValidation function and manually QAQC'd
  


  #just pass along since I already have mean annual Nflw per site (in setupEphemeralQValidation() function)
  eph_gages <- data.frame('watershed'=ephemeralQDataset$huc4,
                          'site'=ephemeralQDataset$gageID,
                          'period_of_record_yrs'=ephemeralQDataset$period_of_record_yrs,
                          'ma_num_flowing_days'=ephemeralQDataset$num_flowing_dys,
                          'reference'=ephemeralQDataset$reference)


  #bring all these data together into single df--------------------------------------
  results_all <- rbind(walnutGulch, santaRita, reynoldsCreek, mohaveYuma, kentucky, dukeForest, more_arizona, montoyas, ontario, eph_gages)

  #wrangle into uniform format across all datasets
  output <- results_all %>%
    dplyr::group_by(watershed) %>%
    dplyr::summarise(watershed=first(watershed),
                     n_flw_d = mean(ma_num_flowing_days,na.rm=T),  #take catchment average across all flumed reaches (if necessary)
                     num_sample_yrs = round(mean(period_of_record_yrs),0), #mean across catchment reaches (mean of constants, just to propagate value)
                     n_sites=n(),
                     reference=first(reference)) %>%
    dplyr::left_join(locations_approx, by='watershed')
  
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
    #read in lookup table for basin IDs for this field data
    not_eph_gauges <- readr::read_csv('data/locations_approx.csv') #lookup for gauges that have been manually identified as not 'strictly' ephemeral (and their associated huc4 basins). See ~/docs/README_usgs_eph_gauges.Rmd for this process and notes.
    huc4s <- not_eph_gauges$basin

    #loop through global-scope operational flow thresholds and validate
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

      #calculate strength-of-fit
      r2 <- summary(lm(num_flowing_dys ~ n_flw_d, data=temp))$r.squared
      mae <- Metrics::mae(temp$num_flowing_dys, temp$n_flw_d)
      rmse <- Metrics::rmse(temp$num_flowing_dys, temp$n_flw_d)

      temp2 <- data.frame('thresh'=i,
                          'r2'=r2,
                          'mae'=mae,
                          'rmse'=rmse)

      out <- rbind(out, temp2)
    }

    out2 <- list('thresh'=out[which.min(out$mae),]$thresh, #[mm/dy] use mae to automatically determine operational threshold (conditional on these specific data). 
                'df'=out) #all results

    return(out2)
}