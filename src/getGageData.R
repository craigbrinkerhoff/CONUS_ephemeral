#####################
## Craig Brinkerhoff
## Spring 2022
## Functions for getting baseflow indices at USGS streamgages on the NHD
#####################

#' Returns set of USGS gages that are joined to the NHD a priori (that meet USGS QA/QC requirements)
#'
#' @param path_to_data: data repo path
#' @param codes_huc02: HUC2 basins to get gages for
#'
#' @return set of USGS gages on the NHD with flows converted to metric
getNHDGages <- function(path_to_data, codes_huc02){
  #get USGS stations joined to NHD that meet thier QA/QC requirements
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
    NHD_HR_EROM_gage <- st_read(dsn = dsnPath, layer = "NHDPlusEROMQAMA") #Quality controlled gauges joined to NHD reaches a priori by USGS
    NHD_HR_EROM <- st_read(dsn = dsnPath, layer = "NHDPlusEROMMA") #mean annual flow table
    NHD_HR_EROM <- filter(NHD_HR_EROM, GageIDMA %in% NHD_HR_EROM_gage$GageID)
    temp <- NHD_HR_EROM %>%
      dplyr::select(c('NHDPlusID', 'QDMA', 'QEMA', 'GageQMA', 'GageIDMA'))

    assessmentDF <- rbind(assessmentDF, temp)
  }

  assessmentDF$QDMA <- assessmentDF$QDMA * 0.0283 #cfs to cms
  assessmentDF$QEMA <- assessmentDF$QEMA * 0.0283 #cfs to cms
  assessmentDF$GageQMA <- assessmentDF$GageQMA * 0.0283 #cfs to cms

  return(assessmentDF)
}

#' Gather streamflow data at gages and calculate no flow fractions and baseflow fractions
#'
#' @param nhdGages: list of USGS streamgauges joined to the NHD with their Q info
#' @param codes_huc02: HUC2 basins to get gage data for
#'
#' @return NULL but writes results to file
getGageData <- function(path_to_data, nhdGages, codes_huc02){
  for(m in codes_huc02){
    #NOTE::::: will be longer than the final sites b/c some of them don't have 20 yrs of data  within the bounds.
        #This function only finds gages that intersect our time domain, but not necessarily 20 yrs of data within the domain.
        #Further, some gages have errors in data or are missing data and we throw them out.
    if(!file.exists(paste0('cache/training/siteNos_', m, '.rds'))){ #only do HUC2 if it hasn't been done yet
      #get usgs gages by
      sites_full <- whatNWISdata(huc=m,
                                 parameterCd ='00060',
                                 service='dv',
                                 startDate = '1970-10-01',
                                 endDate = '2018-09-30')

      write_rds(sites_full, paste0('cache/training/siteNos_', m, '.rds'))
      sites <- unique(sites_full$site_no)
      sites <- sites[which(sites %in% nhdGages$GageIDMA)] #filter for only gages joined to NHD a priori
    }
    else{
      sites_full <- read_rds(paste0('cache/training/siteNos_', m, '.rds')) #will be longer than the final sites b/c some of them throw errors and are removed or don't have 20 yrs of data
      sites <- unique(sites_full$site_no)
      sites <- sites[which(sites %in% nhdGages$GageIDMA)] #filter for only gages joined to NHD a priori
    }
    if(length(sites)==0){next} #some zones don't have gages joined to NHD after QA/QC (HUC04 for example)

    ##########CALCUALTE BASEFLOW AND MEAN ANNUAL FLOW------------------------------
    results <- data.frame()
    k <- 1
    if(!file.exists(paste0('cache/training/trainingData_', m, '.rds'))){
      for(i in sites){
        gageQ <- tryCatch(readNWISstat(siteNumbers = i,
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

        #CALCULATE RIVER-SPECIFIC ALPHA PARAMETER FOLLOWING SINGH ET AL 2019---------------------------------
        Q0 <- median(gageQ$Q_cms) #median flow
        Q_plus <- (gageQ$Q_cms)/Q0
        dQplus_dt <- diff(Q_plus)/1
        Q_plus <- Q_plus[-1]

        Q_plus <- Q_plus[dQplus_dt < 0] #filter only for 'recession flows', i.e. dQ/dt is negative
        dQplus_dt <- dQplus_dt[dQplus_dt < 0]#filter only for 'recession flows', i.e. dQ/dt is negative

        Q_plus[which(Q_plus == 0)] <- 1e-6 #dummy to not be zero
        dQplus_dt[which(dQplus_dt == 0)] <- 1e-6 #dummy to not be zero

        lm <- tryCatch(lm(log(-1*dQplus_dt)~log(Q_plus)), error=function(m){NA}) #error handling if lm doesn't work b/c of poor gage data or something
        if(is.na(lm)){
          print('all NAs')
          alpha <- 0.925} #default for algorithm
        else{
          To <- exp(summary(lm)$coefficients[1])^-1
          alpha <- exp(-1/To)
        } #filtering exponent

        #ACTUALLY CALCULATE BASEFLOW-------------------------------------
        gageQ <- select(gageQ, c('site_no', 'Q_cms', 'month_nu')) %>%
          mutate(Qbase_chapman_singh = gr_baseflow(Q_cms, method='chapman', a=alpha),
                 Qbase_jakeman_singh = gr_baseflow(Q_cms, method='jakeman', a=alpha),
                 Qbase_lynehollick_singh = gr_baseflow(Q_cms, method='lynehollick', a=alpha),
                 Qbase_lynehollick = gr_baseflow(Q_cms, method='lynehollick'),
                 Qbase_chapman = gr_baseflow(Q_cms, method='chapman'),
                 Qbase_jakeman = gr_baseflow(Q_cms, method='jakeman'),
                 Qbase_maxwell = gr_baseflow(Q_cms, method='maxwell'), #Chapman-maxwell, our preferred method
                 Q_MA = mean(gageQ$Q_cms, na.rm=T),
                 date=1:nrow(gageQ),
                 month=month_nu) #cfs to cms.

        if(gageQ$Q_MA == 0){next} #avoid gages with literally no flow

        #round to 1 decimal place to reduce low-flow errors (Zipper et al 2021))
        temp <- data.frame('gageID'=gageQ[1,]$site_no,
                           'alpha'=alpha,
                           'no_flow_fraction'=sum(gageQ$Q_cms == 0)/nrow(gageQ),
                           'baseflow_fraction_lynehollick'=sum(gageQ$Qbase_lynehollick*60*60*24)/sum(gageQ$Q_cms*60*60*24),
                           'baseflow_fraction_lynehollick_singh'=sum(gageQ$Qbase_lynehollick_singh*60*60*24)/sum(gageQ$Q_cms*60*60*24),
                           'baseflow_fraction_chapman'=sum(gageQ$Qbase_chapman*60*60*24)/sum(gageQ$Q_cms*60*60*24),
                           'baseflow_fraction_chapman_singh'=sum(gageQ$Qbase_chapman_singh*60*60*24)/sum(gageQ$Q_cms*60*60*24),
                           'baseflow_fraction_jakeman'=sum(gageQ$Qbase_jakeman*60*60*24)/sum(gageQ$Q_cms*60*60*24),
                           'baseflow_fraction_jakeman_singh'=sum(gageQ$Qbase_jakeman_singh*60*60*24)/sum(gageQ$Q_cms*60*60*24),
                           'baseflow_fraction_maxwell'=sum(gageQ$Qbase_maxwell*60*60*24)/sum(gageQ$Q_cms*60*60*24),
                           'Q_MA'=gageQ[1,]$Q_MA)

        results <- rbind(results, temp)
      }
    results <- select(results, c('gageID', 'alpha', 'Q_MA', 'no_flow_fraction', 'baseflow_fraction_lynehollick', 'baseflow_fraction_chapman', 'baseflow_fraction_jakeman', 'baseflow_fraction_maxwell', 'baseflow_fraction_lynehollick_singh', 'baseflow_fraction_chapman_singh', 'baseflow_fraction_jakeman_singh')) %>%
      distinct(.keep_all = TRUE)

    write_rds(results, paste0('cache/training/trainingData_', m, '.rds'))

    Sys.sleep(60) #wait 1 minute to USGS doesn't get overwhelmed :)
   }
  }

  #concatenate all into single target object
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
