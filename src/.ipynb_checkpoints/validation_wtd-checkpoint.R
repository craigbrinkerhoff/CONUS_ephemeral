## Craig Brinkerhoff
## Functions that use USGS NWIS sites to validate the groundwater model used in this study
## Spring 2024





#' Extract mean monthly well depths from USGS wells
#'
#' @name getWellDepths
#'
#' @param codes_huc2: huc2 regional codes to get NWIS wells
#' 
#' @import readr
#' @import dplyr
#' @import dataRetrieval
#'
#' @return df of mean monthly groundwater depths
getWellDepths <- function(codes_huc2){

    out <- data.frame() #results holder
    for(i in codes_huc02){
        sites <- whatNWISdata(huc=i,
                              parameterCd ='72019',
                              startDate = '1970-10-01', #water year
                              endDate = '2018-09-30')

        #filter for at least 20 years of data
        sites <- dplyr::filter(sites, count_nu/365 >= 20) %>%
            dplyr::select(c('site_no', 'dec_lat_va', 'dec_long_va', 'count_nu'))

        #loop through sites and query NWIS for data
        for(k in 1:nrow(sites)){
            dtw <-   tryCatch(readNWISstat(siteNumbers = sites[k,]$site_no, #check if site meets our date requirements
                                  parameterCd = '72019', #depth to water table, feet below land surface
                                  startDate = '1970-10-01',
                                  endDate = '2018-09-30'),
                            error = function(m){
                                print('no site')
                                next})
            
            if(!('month_nu' %in% colnames(dtw))){next}
            
            dtw <- dtw %>%
                dplyr::group_by(month_nu) %>%
                dplyr::summarise(dtw_ft = mean(mean_va, na.rm=T)) %>%
                dplyr::mutate(dtw_m = dtw_ft * 0.3048) %>% #ft to meter
                dplyr::filter(dtw_m < 100) #filter for wells less than 100m deep. To avoid validating in deeper aquifers that this model doesn't reflect (Following 10.1126/science.1229881 and 10.1038/s41586-021-03311-x)
            
            if(nrow(dtw) == 0){next}
            
            temp <- data.frame('site_no'=sites[k,]$site_no,
                               'lat'=sites[k,]$dec_lat_va,
                               'long'=sites[k,]$dec_long_va,
                               'month'=dtw$month_nu,
                               'dtw_m'=dtw$dtw_m)

            out <- rbind(out, temp)
        }
        readr::write_rds(out, 'cache/training/groundwater_well_depths.rds')        
        Sys.sleep(60) #wait 1 minute so that USGS doesn't get pinged up the wazoo :)
    }
    readr::write_rds(out, 'cache/training/groundwater_well_depths.rds')

    return(out)
}






#' Extract 'groundwater depths' from USGS streamgauges in perennial rivers (i.e. depth of ~0m)
#'
#' @name getGaugewtd
#'
#' @param USGS_data: huc2 regional codes to get NWIS wells
#' 
#' @import readr
#' @import dplyr
#' @import dataRetrieval
#'
#' @return df of mean monthly groundwater depths at perennial rivers
getGaugewtd <- function(USGS_data){

    USGS_data <- dplyr::filter(USGS_data, no_flow_fraction == 0) #only keep the gages that flow year round (perennial) to be conservative. Later code keeps all twelve values.

    out <- data.frame() #results holder
    for(i in USGS_data$gageID){        
        sites <- dataRetrieval::whatNWISdata(siteNumbers =i, parameterCd ='00060')

        sites <- dplyr::filter(sites, count_nu/365 >= 20) %>%
            dplyr::select(c('site_no', 'dec_lat_va', 'dec_long_va'))
        
        if(nrow(sites)==0){next} #if less than 20 years of data
        
        sites$month <- NA
        sites$dtw_m <- 0 #stream gauges in perennial rivers have a water table depth of approximately zero

        colnames(sites) <- c('site_no', 'lat', 'long', 'month', 'dtw_m')
        
        out <- rbind(out, sites)
    }
    out <- out %>% distinct(.keep_all = TRUE)

    return(out)
}




#' Does three things
#'  (1) sptially extracts the gridded groundwater model values at each of the in situ wells
#'  (2) fits the log error model
#'  (3) creates the groundwater model validation figures
#'
#' @name join_wtd
#'
#' @param path_to_data: data repo path directory
#' @param conus_well_depths: df of well depths
#' @param gauge_wtds: df of perennial river groundwater depths
#' 
#' @import readr
#' @import dplyr
#' @import terra
#' @import ggplot2
#'
#' @return df of mean monthly groundwater depths at perennial rivers
join_wtd <- function(path_to_data, conus_well_depths, gauge_wtds){
    #these have already been filtered for only gages that flow 100% of the time, i.e. perennial rivers where the water table will be ~0m year round (so just assign the 0m to all 12 months)
    gauge_wtds$month <- 1

    gauge_wtds_2 <- gauge_wtds
    gauge_wtds_2$month <- 2

    gauge_wtds_3 <- gauge_wtds
    gauge_wtds_3$month <- 3

    gauge_wtds_4 <- gauge_wtds
    gauge_wtds_4$month <- 4

    gauge_wtds_5 <- gauge_wtds
    gauge_wtds_5$month <- 5

    gauge_wtds_6 <- gauge_wtds
    gauge_wtds_6$month <- 6

    gauge_wtds_7 <- gauge_wtds
    gauge_wtds_7$month <- 7

    gauge_wtds_8 <- gauge_wtds
    gauge_wtds_8$month <- 8

    gauge_wtds_9 <- gauge_wtds
    gauge_wtds_9$month <- 9

    gauge_wtds_10 <- gauge_wtds
    gauge_wtds_10$month <- 10

    gauge_wtds_11 <- gauge_wtds
    gauge_wtds_11$month <- 11

    gauge_wtds_12 <- gauge_wtds
    gauge_wtds_12$month <- 12

    #bring all in situ data together
    for_shape <- rbind(conus_well_depths, gauge_wtds, gauge_wtds_2, gauge_wtds_3, gauge_wtds_4, gauge_wtds_5, gauge_wtds_6, gauge_wtds_7, gauge_wtds_8, gauge_wtds_9, gauge_wtds_10, gauge_wtds_11, gauge_wtds_12)

    #make shapefile of wells and their depths
    shape <- sf::st_as_sf(for_shape, coords = c("long","lat"), crs = st_crs(4326))

    #read in the groundwater model
    wtd <- terra::rast(paste0(path_to_data, '/for_ephemeral_project/NAMERICA_WTD_monthlymeans.nc'))   #monthly averages of hourly model runs for 2004-2014 at 1km resolution

    #extract mean monthly water table depths at each well point (by month)
    wtd_01 <- dplyr::filter(for_shape, month==1) #jan
    shape_01 <- dplyr::filter(shape, month==1)
    shape_01 <- terra::vect(shape_01)
    wtd_model_01 <- terra::extract(wtd$WTD_1, shape_01)
    wtd_01$wtd_model_m <- as.numeric(wtd_model_01$WTD_1 * -1) #flip to match orientation of the model

    wtd_02 <- dplyr::filter(for_shape, month==2) #feb
    shape_02 <- dplyr::filter(shape, month==2)
    shape_02 <- terra::vect(shape_02)
    wtd_model_02 <- terra::extract(wtd$WTD_2, shape_02)
    wtd_02$wtd_model_m <- as.numeric(wtd_model_02$WTD_2 * -1)

    wtd_03 <- dplyr::filter(for_shape, month==3) #mar
    shape_03 <- dplyr::filter(shape, month==3)
    shape_03 <- terra::vect(shape_03)
    wtd_model_03 <- terra::extract(wtd$WTD_3, shape_03)
    wtd_03$wtd_model_m <- as.numeric(wtd_model_03$WTD_3 * -1)

    wtd_04 <- dplyr::filter(for_shape, month==4) #apr
    shape_04 <- dplyr::filter(shape, month==4)
    shape_04 <- terra::vect(shape_04)
    wtd_model_04 <- terra::extract(wtd$WTD_4, shape_04)
    wtd_04$wtd_model_m <- as.numeric(wtd_model_04$WTD_4 * -1)

    wtd_05 <- dplyr::filter(for_shape, month==5) #may
    shape_05 <- dplyr::filter(shape, month==5)
    shape_05 <- terra::vect(shape_05)
    wtd_model_05 <- terra::extract(wtd$WTD_5, shape_05)
    wtd_05$wtd_model_m <- as.numeric(wtd_model_05$WTD_5 * -1)

    wtd_06 <- dplyr::filter(for_shape, month==6) #jun
    shape_06 <- dplyr::filter(shape, month==6)
    shape_06 <- terra::vect(shape_06)
    wtd_model_06 <- terra::extract(wtd$WTD_6, shape_06)
    wtd_06$wtd_model_m <- as.numeric(wtd_model_06$WTD_6 * -1)

    wtd_07 <- dplyr::filter(for_shape, month==7) #jul
    shape_07 <- dplyr::filter(shape, month==7)
    shape_07 <- terra::vect(shape_07)
    wtd_model_07 <- terra::extract(wtd$WTD_7, shape_07)
    wtd_07$wtd_model_m <- as.numeric(wtd_model_07$WTD_7 * -1)

    wtd_08 <- dplyr::filter(for_shape, month==8) #aug
    shape_08 <- dplyr::filter(shape, month==8)
    shape_08 <- terra::vect(shape_08)
    wtd_model_08 <- terra::extract(wtd$WTD_8, shape_08)
    wtd_08$wtd_model_m <- as.numeric(wtd_model_08$WTD_8 * -1)

    wtd_09 <- dplyr::filter(for_shape, month==9) #sep
    shape_09 <- dplyr::filter(shape, month==9)
    shape_09 <- terra::vect(shape_09)
    wtd_model_09 <- terra::extract(wtd$WTD_9, shape_09)
    wtd_09$wtd_model_m <- as.numeric(wtd_model_09$WTD_9 * -1)

    wtd_10 <- dplyr::filter(for_shape, month==10) #oct
    shape_10 <- dplyr::filter(shape, month==10)
    shape_10 <- terra::vect(shape_10)
    wtd_model_10 <- terra::extract(wtd$WTD_10, shape_10)
    wtd_10$wtd_model_m <- as.numeric(wtd_model_10$WTD_10 * -1)

    wtd_11 <- dplyr::filter(for_shape, month==11) #nov
    shape_11 <- dplyr::filter(shape, month==11)
    shape_11 <- terra::vect(shape_11)
    wtd_model_11 <- terra::extract(wtd$WTD_11, shape_11)
    wtd_11$wtd_model_m <- as.numeric(wtd_model_11$WTD_11 * -1)

    wtd_12 <- dplyr::filter(for_shape, month==12) #dec
    shape_12 <- dplyr::filter(shape, month==12)
    shape_12 <- terra::vect(shape_12)
    wtd_model_12 <- terra::extract(wtd$WTD_12, shape_12)
    wtd_12$wtd_model_m <- as.numeric(wtd_model_12$WTD_12 * -1)

    #bring model moths togheter
    out <- rbind(wtd_01, wtd_02, wtd_03, wtd_04, wtd_05, wtd_06, wtd_07, wtd_08, wtd_09, wtd_10, wtd_11, wtd_12)

    #Calculate the log error model-----------------------------------------------------------------
    out$log10_dtw_m <- ifelse(out$dtw_m < 1e-10, 0, log10(out$dtw_m)) #set lower significance limit to 1e-10 meters
    out$log10_wtd_model_m <- ifelse(out$wtd_model_m < 1e-10, 0, log10(out$wtd_model_m)) #force this boundary condition to just equal zero for log diffs
    out$residual <- (out$log10_wtd_model_m - out$log10_dtw_m)
   

    #MAKE VALIDATION PLOT------------------------------------
    theme_set(theme_classic())

    gw_validation <- ggplot(out, aes(x=residual)) +
        geom_histogram(size=0.75, color='black', fill='#99d8c9', binwidth=0.1)+
        stat_function(fun = dnorm, args = list(mean =mean(out$residual, na.rm=T), sd = sd(out$residual, na.rm=T)), aes(y = after_stat(y * 0.1 * nrow(out))), size=1.5, color='darkred') +
        xlab('Log10 Water table depth residuals [m]')+ 
        ylab('Count')+
        annotate('text', label=expr(mu: ~ !!round(mean(out$residual, na.rm=T),3)), x=-2.4, y=13000, size=7)+
        annotate('text', label=expr(sigma: ~ !!round(sd(out$residual, na.rm=T),3)), x=-2.4, y=12000, size=7)+
        annotate('text', label=paste0('n = ', nrow(out), ' observations\n(', nrow(out)/12, ' sites over 12 months)'), x=2.5, y=5000, size=7, color='black')+
        theme(axis.text=element_text(size=20),
            axis.title=element_text(size=24,face="bold"),
            legend.text = element_text(size=20),
            legend.position='bottom',
            plot.title = element_text(size = 30, face = "bold"),
            plot.tag = element_text(size=26,
                                    face='bold'))

    #MAKE INSET MAP
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
    states <- sf::st_union(states)

    #make inset map of well locations----------------------------------
    forMap <- dplyr::filter(shape, month==1)
    insetMap <- ggplot(forMap) +
        geom_sf(aes(color=dtw_m), #actual map
                color='#99d8c9',
                size=0) +
        geom_sf(data=states, #CONUS boundary
            color='black',
            size=0.75,
            alpha=0)+
        scale_fill_brewer(name='', palette='GnBu') +
        theme(legend.position='none') +
        theme(axis.title = element_text(size=22, face='bold'),
              axis.text = element_text(size=20,face='bold'),
              plot.tag = element_text(size=22,face='bold'),
              axis.text.x = element_text(angle = 90))

    gw_validation <- gw_validation + 
          patchwork::inset_element(insetMap, right = 0.99, bottom = 0.4, left = 0.5, top = 0.99)
    
    ggsave('cache/gw_validation.jpg', gw_validation, width=10, height=10)

    #return the log error model (for downstream MC analysis)
    return(list('mean'=round(mean(out$residual, na.rm=T),3),
                'sd'=round(sd(out$residual, na.rm=T),3),
                'df'=out))
}