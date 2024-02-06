## Utility functions
## Craig Brinkerhoff
## Spring 2024




#' Summarizes water table depth along each river reach
#'
#' @name summariseWTD
#'
#' @param wtd: vector of water table depths along a stream reach [m]
#'
#' @return summary stats for wtd pixels along a reach [m]
summariseWTD <- function(wtd){
  median <- median(wtd, na.rm=T)
  mean <- mean(wtd, na.rm=T)
  min <- min(wtd, na.rm=T)
  max <- max(wtd, na.rm=T)
  return(list('median'=median,
              'mean'=mean,
              'min'=min,
              'max'=max))
}




#' depth for rivers or lakes/reservoirs
#'
#' @name depth_func
#'
#' @param waterbody: flag for whether reach is a river or lake/reservoir [1/0]
#' @param lakeVol: lake/reservoir volume, using fraction assigned to this flowline [m3]
#' @param lakeArea: lake/reservoir surface area, using fraction assigned to this flowline [m2]
#' @param physio_region: physiographic region from lookup table
#' @param a: depth~DA model intercept from lookup table
#' @param b: depth~DA model coefficient from lookup table
#'
#' @return river depth via hydraulic geometry [m]
depth_func <- function(waterbody, lakeVol, lakeArea, physio_region, drainageArea, a, b) {
  if (waterbody == 'River') {
    output <- a*drainageArea^b # bankfullriver depth [m]
  }
  else {
    output <- lakeVol/lakeArea #mean lake depth [m]
  }
  return(output)
}




#' get appropriate UTM zone from longitude
#'
#' @name long2UTM
#'
#' @param long: Longitude
#'
#' @return UTM zone (N) as numeric
long2UTM <- function(long) {
    out <- (floor((long + 180)/6) %% 60) + 1
    return(out)
}





#' Fixes geometries that are saved as multicurves rather than multilines in the NHD-HR
#'
#' @name fixGeometries
#'
#' @param rivnet: sf object for basin hydrography
#'
#' @import dplyr
#' @import sf
#'
#' @return updated (if necessary) river network object
fixGeometries <- function(rivnet){
  curveLines <- dplyr::filter(rivnet, sf::st_geometry_type(rivnet) == 'MULTICURVE')
  if(nrow(curveLines) > 0){ #if saved as a curve, recast geometry as a line
    rivnet <- sf::st_cast(rivnet, 'MULTILINESTRING')
  }

  return(rivnet)
}








#' Plots and saves mean annual hydrographs so we can manually verify whether they are ephemeral and not intermittent
#'
#' @name ephemeralityChecker
#'
#' @param other_sites: df with all of the gauge IDs
#' 
#' @import ggplot2
#' @import dplyr
#' @import dataRetrieval
#'
#' @return writes plots to file
ephemeralityChecker <- function(other_sites) {
  other_sites$wy_eph_gages <- substr(other_sites$name, 6,nchar(other_sites$name))
  
  wy_eph_Q <- data.frame()
  for(i in other_sites$wy_eph_gages){
    gageQ <- readNWISstat(siteNumbers = i, #check if site mets our date requirements
                        parameterCd = '00060') #discharge
    
    #get mean annual flow
    if(nrow(gageQ)==0){next} #some of these gauges are empty because data isn't online....
    
    gageQ <- gageQ %>% 
      dplyr::mutate(Q_cms = mean_va*0.0283)#cfs to cms
    
    gageQ$index <- 1:nrow(gageQ)
    
    end <- gageQ[1,]$end_yr
    begin <- gageQ[1,]$begin_yr

    #PLOT-----------------------------------------
    plot <- ggplot(gageQ, aes(x=index, y=Q_cms)) +
      geom_line() +
      ggtitle(paste0(begin, '-', end)) +
      xlab('Date') +
      ylab('Q [cms]')
    
    #write to file for manual assessment. See ~/docs/README_usgs_eph_gauges.Rmd for more
    ggsave(paste0('cache/check_usgs_eph_hydrographs/', i, '.jpg'),plot, width=15, height=7)
    
  }
  return(wy_eph_Q)
}




#' Write results to file
#'
#' @name exportResults
#'
#' @param rivNetFin: final model results table, with results per reach
#' @param huc4: 4 digit basin ID
#' 
#' @import readr
#' @import dplyr
#'
#' @return writes model results to file
exportResults <- function(rivNetFin, huc4){

  rivNetFin <- dplyr::select(rivNetFin, c('NHDPlusID', 'perenniality', 'percQEph_reach'))

  readr::write_csv(rivNetFin, paste0('cache/results_written/results_', huc4, '.csv'))

  return('written to file at ~/cache/results_written')
}





#' Build and validate the Hb~DA models using their paper's source data ( https://doi.org/10.1111/jawr.12282)
#'
#' @name validateHb
#' 
#' @import readr
#' @import dplyr
#'
#' @return suite of models by physiographic region
validateHb <- function(){
  dataset <- readr::read_csv('data/bhg_us_database_bieger_2015.csv') %>% #available by searching for paper at https://swat.tamu.edu/search
    dplyr::select(c('Physiographic Division', '...9', '...15')) #some necessary manual munging for colnames from dataset
  
  colnames(dataset) <- c('DIVISION', 'DA_km2', 'Hb_m')

  dataset$Hb_m <- as.numeric(dataset$Hb_m)
  dataset$DA_km2 <- as.numeric(dataset$DA_km2)

  dataset <- tidyr::drop_na(dataset)

  division <- toupper(sort(unique(dataset$DIVISION))) #make lowercase and sort

  #build models, grouped by physiographic region
  models <- dplyr::group_by(dataset, DIVISION) %>%
    dplyr::do(model = lm(log10(Hb_m)~log10(DA_km2), data=.)) %>% #fit models by physiographic regions
    dplyr::summarise(a = 10^(model$coef[1]), #model intercept
                     b = model$coef[2], #model exponent
                     r2 = summary(model)$r.squared, #model performance
                     mean_residual = mean(model$residuals, na.rm=T),
                     sd_residual = sd(model$residuals, na.rm=T),
                     see = sd(model$residuals, na.rm=T)) %>%
    dplyr::mutate(division = division)


  models[models$division == "INTERMONTANE PLATEAU",]$division <- "INTERMONTANE PLATEAUS" #make sure names line up
  
  return(models)
}