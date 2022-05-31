# _targets.R file
###########################################
## Craig Brinkerhoff
## Spring 2022
## main script to launch pipeline for epehemeral streams project.
## see README file
##############################################

library(targets)
library(tarchetypes)
library(tibble)
source('src/utils.R')
source('src/analysis.R')
source('src/getGageData.R')
source('src/eromAssessment.R')
source('src/verify.R')
source('src/shapefiles.R')
source('src/scaling.R')

options(clustermq.scheduler = "multiprocess")#clustermq.scheduler = "slurm", clustermq.template = "slurm.tmpl") #set up clustermq R parallel scheduler
tar_option_set(packages = c('terra', 'sf', 'dplyr', 'readr', 'ggplot2', 'cowplot', 'dataRetrieval', 'clustermq', 'grwat', 'scales', 'mgcv')) #set up packages to load in. Note that tidyr is specified manually throughout to avoid conflicts with dplyr

#############USER INPUTS-------------------
path_to_data <- '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data' #path to data repo (separate from code repo)
codes_huc02 <- c('01','02','11', '12', '13','14','15','16') #HUC2 regions to get gage data. Make sure these match the HUC4s that are being mapped below
threshold <- -0.05 #5cm buffer around 0m depth
error <- 0
ephThresh <- 1e-7 #[m] minimum flow for 'ephemeral flow' in scaling
perc_thresh <- 0.03

#SETUP STATIC BRANCHING----------------------------
#Each HUC4 basin gets it's own branch
mapped <- tar_map(
       unlist=FALSE, #to facilitate tar_combine within a mapping scheme (see below)
       values = tibble(
         method_function = rlang::syms("extractWTD"),
         huc4 = c('0101', '0102', '0103', '0104', '0105', '0106', '0107', '0108', '0109', '0110', #1:10
                  '0203',  '0206', '0207', '0208', '0204','0205','0202', #11:17
                  "1101",'1102', '1103', '1104', '1105', '1106', '1107', '1108', '1109', '1110', '1111', '1112', '1113', '1114', #18:31
                   '1204', '1205',  '1208',  '1211','1209','1210','1201', '1202', '1203','1206', '1207', #32:42
                  '1301', '1302', '1303', '1304', '1305', '1306', '1307', '1308', '1309', #43:51
                   '1402', '1403', '1406', '1407', '1408','1401', '1404', '1405', #52:59
                   '1502',  '1504', '1505', '1506', '1507', '1501','1508', '1503', #60:67
                  '1601', '1602', '1603', '1605','1604', '1606') #68:73
       ),
       names = "huc4",
       tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along the river reaches
       tar_target(rivNetFin, getPerenniality_peckel(extractedRivNet, huc4, threshold, error, 'mean'))) #calculate perenniality using mean water table depth along the reach and a summarizing statistic (mean, median, min, max)
      # tar_target(rivNetFin_verify, getRivNetverify(rivNetFin, nhdGages, USGS_data)), #trim results to just those reaches with a gage (for model verification)
      # tar_target(results, collectResults(rivNetFin, huc4))) #calculate basin statistics

#############ACTUAL PIPLINE, COMBINING STATIC BRANCHING, AGGREGATION TARGETS, AND OTHER TARGETS
list(tar_target(nhdGages, getNHDGages(path_to_data, codes_huc02)), #gages joined to NHD a priori
     tar_target(USGS_data, getGageData(path_to_data, nhdGages, codes_huc02)), #calculates baseflow and no flow indices for every gage with minimum 20yrs data b/w 1970-2018 and joined to NHD
     mapped, #run actual model (see above)
  #   tar_combine(combined_verify, mapped$rivNetFin_verify, command = dplyr::bind_rows(!!!.x, .id = "method")), #aggregate gaged model results across branches (for model verification)
#     tar_combine(combined_results, mapped$results, command = dplyr::bind_rows(!!!.x, .id = "method")),  #aggregate model results across branches (for mapping)
#     tar_target(EROM_figure, eromVerification(USGS_data, nhdGages), deployment='main'), #generate figures for validating discharges (run locally on master process)
    # tar_target(modelVerification, verifyModel(combined_verify), deployment='main'), #generate figures for final model verification (run locally on master process)
#     tar_target(shapefile_fin, saveShapefile(path_to_data, codes_huc02, combined_results)),


     #doing this manually for now.......
     tar_combine(combined_01, mapped$rivNetFin[1:10], command = dplyr::bind_rows(!!!.x, .id='method')),
     tar_target(scaledResult_01, doScaling(combined_01, ephThresh, '01', perc_thresh)),

     tar_combine(combined_02, mapped$rivNetFin[11:17], command = dplyr::bind_rows(!!!.x, .id='method')),
     tar_target(scaledResult_02, doScaling(combined_02, ephThresh, '02', perc_thresh)),

     tar_combine(combined_11_12, mapped$rivNetFin[18:42], command = dplyr::bind_rows(!!!.x, .id='method')),
     tar_target(scaledResult_11_12, doScaling(combined_11_12, ephThresh, '11', perc_thresh)),

  #   tar_combine(combined_12, mapped$rivNetFin[32:42], command = dplyr::bind_rows(!!!.x, .id='method')),
  #   tar_target(scaledResult_12, doScaling(combined_12, ephThresh, '12', perc_thresh)),

     tar_combine(combined_13, mapped$rivNetFin[43:51], command = dplyr::bind_rows(!!!.x, .id='method')),# NOT ENOUGH EPHEMERAL DATA...
     tar_target(scaledResult_13, doScaling(combined_13, ephThresh, '13', perc_thresh)),

     tar_combine(combined_14, mapped$rivNetFin[52:59], command = dplyr::bind_rows(!!!.x, .id='method')),
     tar_target(scaledResult_14, doScaling(combined_14, ephThresh, '14', perc_thresh)),

     tar_combine(combined_15, mapped$rivNetFin[60:67], command = dplyr::bind_rows(!!!.x, .id='method')),
     tar_target(scaledResult_15, doScaling(combined_15, ephThresh, '15', perc_thresh)),

     tar_combine(combined_16, mapped$rivNetFin[68:73], command = dplyr::bind_rows(!!!.x, .id='method')),
     tar_target(scaledResult_16, doScaling(combined_16, ephThresh, '16', perc_thresh))

     #tar_combine(combined_results_scaled, scaledResult_01, scaledResult_02, scaledResult_11, scaledResult_12, scaledResult_14, scaledResult_15, scaledResult_16, command = dplyr::bind_rows(!!!.x, .id = "method"))
   )
