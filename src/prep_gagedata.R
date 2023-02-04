## Craig Brinkerhoff
## Winter 2023
## Functions for getting mean annual flow and flow frequency at USGS streamgages along the NHD



#' Returns set of USGS gages that are joined to the NHD-HR a priori (that meet USGS QA/QC requirements)
#'
#' @name getNHDGages
#'
#' @param path_to_data: data repo path
#' @param codes_huc02: HUC2 basins to get gages for
#'
#' @import dplyr
#' @import sf
#'
#' @return df of USGS gages on the NHD with flows converted to metric
getNHDGages <- function(path_to_data, codes_huc02){
  #get USGS stations joined to NHD that meet USGS QA/QC requirements (i.e. IDs already matched to NHD-HR)
  codes <- c(NA)
  for(code_huc2 in codes_huc02){
    code <- list.dirs(paste0(path_to_data, '/HUC2_', code_huc2), full.names = FALSE, recursive = FALSE)
    code <- code[grepl('NHDPLUS_H_', code)] #only keep geodatabase folders
    code <- substr(code, 11, nchar(code)-8)

    codes <- c(codes, code)
  }
  codes <- codes[-1]

  assessmentDF <- data.frame()
  for (i in codes){
    m <- substr(i, 1,2)
    dsnPath <- paste0(path_to_data, "/HUC2_", m, "/NHDPLUS_H_", i, "_HU4_GDB/NHDPLUS_H_", i, "_HU4_GDB.gdb")
    NHD_HR_EROM_gage <- st_read(dsn = dsnPath, layer = "NHDPlusEROMQAMA") #Quality controlled gauges joined to NHD-HR reaches a priori by USGS
    NHD_HR_EROM <- sf::st_read(dsn = dsnPath, layer = "NHDPlusEROMMA") #mean annual flow table
    NHD_HR_EROM <- dplyr::filter(NHD_HR_EROM, GageIDMA %in% NHD_HR_EROM_gage$GageID)
    temp <- NHD_HR_EROM %>%
      dplyr::select(c('NHDPlusID', 'QBMA', 'QEMA', 'GageQMA', 'GageIDMA'))

    assessmentDF <- rbind(assessmentDF, temp)
  }

  assessmentDF$QBMA <- assessmentDF$QBMA * 0.0283 #cfs to cms
  assessmentDF$QEMA <- assessmentDF$QEMA * 0.0283 #cfs to cms
  assessmentDF$GageQMA <- assessmentDF$GageQMA * 0.0283 #cfs to cms

  return(assessmentDF)
}






#' Gather streamflow data at gauges and calculate 1) mean annual flow and 2) no flow fractions
#'
#' @name getGageData
#'
#' @param path_to_data: path to data working directory
#' @param nhdGages: list of USGS streamgauges joined to NHD-HR
#' @param codes_huc02: HUC2 basins to get gage data for
#'
#' @import dataRetrieval
#' @import readr
#' @import dplyr
#'
#' @return df of USGS gaueg IDs + long term mean annual flow data + % of annual record with no flow (river runs dry)
getGageData <- function(path_to_data, nhdGages, codes_huc02){
  for(m in codes_huc02){
    #NOTE::::: will be longer than the final sites b/c some of them don't have 20 yrs of data  within the bounds.
        #This function only finds gages that intersect our time domain, but not necessarily 20 yrs of data within the domain.
        #Further, some gages have errors in data or are missing data and we throw them out later
    if(!file.exists(paste0('cache/training/siteNos_', m, '.rds'))){ #only do HUC2 if it hasn't been done yet
      #get usgs gages by
      sites_full <- whatNWISdata(huc=m,
                                 parameterCd ='00060',
                                 service='dv',
                                 startDate = '1970-10-01', #water year
                                 endDate = '2018-09-30')

      write_rds(sites_full, paste0('cache/training/siteNos_', m, '.rds'))
      sites <- unique(sites_full$site_no)
      sites <- sites[which(sites %in% nhdGages$GageIDMA)] #filter for only gages joined to NHD-HR a priori
    }
    else{
      sites_full <- read_rds(paste0('cache/training/siteNos_', m, '.rds')) #will be longer than the final sites b/c some of them throw errors and are removed or don't have 20 yrs of data
      sites <- unique(sites_full$site_no)
      sites <- sites[which(sites %in% nhdGages$GageIDMA)] #filter for only gages joined to NHD a priori
    }
    if(length(sites)==0){next} #some zones don't have gages joined to NHD-HR after QA/QC (HUC04 for example)

    ##########CALCUALTE MEAN ANNUAL FLOW
    results <- data.frame()
    k <- 1
    if(!file.exists(paste0('cache/training/trainingData_', m, '.rds'))){ #check if site has already been run
      for(i in sites){
        #GRAB GAUGE DATA
        gageQ <- tryCatch(readNWISstat(siteNumbers = i, #check if site mets our date requirements
                                       parameterCd = '00060', #discharge
                                       startDate = '1970-10-01',
                                       endDate = '2018-09-30'),
                          error = function(m){
                            print('no site')
                            next})

        if(nrow(gageQ) == 0){next} #sometimes these are empty

        if(gageQ[1,]$count_nu <= 20){next}#minimum 20 years of measurements
        if(nrow(gageQ)!= 366){next} #needs data for every day of the year

        gageQ$Q_cms <- gageQ$mean_va*0.0283 #cfs to cms
        gageQ$Q_cms <- round(gageQ$Q_cms, 3) #round to 1 decimal to handle low-flow errors following Zipper et al 2021

        #ACTUALLY CALCULATE MEAN ANNUAL FLOW
        gageQ <- select(gageQ, c('site_no', 'Q_cms', 'month_nu')) %>%
          mutate(Q_MA = mean(gageQ$Q_cms, na.rm=T),
                 date=1:nrow(gageQ),
                 month=month_nu) #cfs to cms.

        if(gageQ$Q_MA == 0){next} #avoid gages with literally no flow

        temp <- data.frame('gageID'=gageQ[1,]$site_no,
                           'no_flow_fraction'=sum(gageQ$Q_cms == 0)/nrow(gageQ),
                           'Q_MA'=gageQ[1,]$Q_MA)

        results <- rbind(results, temp)
      }
    results <- select(results, c('gageID', 'Q_MA', 'no_flow_fraction')) %>%
      distinct(.keep_all = TRUE)

    write_rds(results, paste0('cache/training/trainingData_', m, '.rds'))

    Sys.sleep(60) #wait 1 minute to USGS doesn't get angry :)
   }
  }

  #concatenate all into single target object (janky but works)
  results_all <- data.frame()
  for(i in codes_huc02){
    temp_d <- tryCatch(read_rds(paste0('cache/training/trainingData_', i, '.rds')),error=function(k){'none'})
    if(temp_d == 'none'){
      next
    } else{
      temp_d$huc2 <- i
      results_all <- rbind(results_all, temp_d)
    }
  }

  out <- results_all
  return(out)
}