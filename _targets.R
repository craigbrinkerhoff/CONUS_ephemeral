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
source('src/shapefiles.R')
source('src/dischargeScaling.R')
source('src/validation.R')

#options(clustermq.scheduler = 'multiprocess')#, clustermq.template = "slurm.tmpl") #set up R parallel scheduler options: slurm vs multiprocess
tar_option_set(packages = c('terra', 'sf', 'dplyr', 'readr', 'ggplot2', 'cowplot', 'dataRetrieval', 'clustermq', 'scales', 'tidyr')) #set up packages to load in. Note that tidyr is specified manually throughout to avoid conflicts with dplyr

#############USER INPUTS-------------------
path_to_data <- '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data' #path to data repo (separate from code repo)
codes_huc02 <- c('01','02','06','08','09','11','12','13','14','15','16','18') #HUC2 regions to get gage data. Make sure these match the HUC4s that are being mapped below
threshold <- -0.1 #10cm buffer around 0m depth
error <- 0
snappingThresh <- 10 #[m] for snapping valiation data to river network
runoff_thresh <- 0.24 #[mm/dy] a priori runoff threshold for flow generation for a storm event. Equivalent to 0.01mm/hr

#SETUP STATIC BRANCHING FOR MODEL RUNS ACCROSS BASINS----------------------------
#Each HUC4 basin gets it's own branch
mapped <- tar_map(
       unlist=FALSE,
       values = tibble(
         method_function = rlang::syms("extractWTD"),
         huc4 = c('0101', '0102', '0103', '0104', '0105', '0106', '0107', '0108', '0109', '0110',
                  '0203', '0206', '0207', '0208', '0204', '0205', '0202',
                  '0602', '0603', '0604', #0601 not working
                  '0801', '0802', '0803', '0804', '0805', '0806', '0807', '0808', '0809',
                  '0901', '0902', '0903', '0904',
                  '1101', '1102', '1103', '1104', '1105', '1106', '1107', '1108', '1109', '1110', '1111', '1112', '1113', '1114',
                  '1204', '1205', '1208', '1211', '1209', '1210', '1201', '1202', '1203', '1206', '1207',
                  '1301', '1302', '1303', '1304', '1305', '1306', '1307', '1308', '1309',
                  '1402', '1403', '1406', '1407', '1408', '1401', '1404', '1405',
                  '1502', '1504', '1505', '1506', '1507', '1501', '1508', '1503',
                  '1601', '1602', '1603', '1605', '1604', '1606',
                  '1801', '1802', '1803', '1804', '1805', '1806', '1807', '1808', '1809', '1810')
       ),
       names = "huc4",
       tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
       tar_target(rivNetFin, getPerenniality(extractedRivNet, huc4, threshold, error, 'mean')), #calculate perenniality
       tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoff_thresh)), #calculate ballpark number of flowing days
       tar_target(results, collectResults(rivNetFin, numFlowingDays, huc4)), #calculate basin statistics using streamflow model
       tar_target(scaledResult, scalingByBasin(scalingModel, rivNetFin, results)), #scale to additonal ephemeral orders vis Horton Laws
       tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4))) #snap WOTUS descisions to modeled river network for later validation

#############ACTUAL PIPLINE, COMBINING STATIC BRANCHING, AGGREGATION TARGETS, AND OTHER TARGETS
list(
     #######GATHER AND VALIDATE STREAMFLOWS VIA USGS GAUGES
     tar_target(nhdGages, getNHDGages(path_to_data, codes_huc02)), #gages joined to NHD a priori, used for erom verification
     tar_target(USGS_data, getGageData(path_to_data, nhdGages, codes_huc02)), #calculates mean observed flow 1970-2018 to verify erom model

     #########GATHER WOTUS JD VALIDATION SET
     tar_target(validationDF, prepValDF(path_to_data)), #clean WOTUS validation set
     tar_target(runoffEff, calcRunoffEff(path_to_data, codes_huc02)), #calculate runoff efficiency

     ##########PREP FOR ADDITIONAL EPHEMERAL SCALING
     tar_target(scalingModel, scalingFunc(validationResults)), #how many additional ephemeral orders we should have (via Horton laws)

     ##########RUN & VALIDATE MODEL PER HUC4
     mapped, #run actual model (see above)

     #########AGGREGATE RESULTS
     tar_combine(combined_results, mapped$scaledResult, command = dplyr::bind_rows(!!!.x, .id = "method")),  #aggregate model results across branches
     tar_combine(combined_validation, mapped$snappedValidation, command = dplyr::bind_rows(!!!.x, .id = "method")),  #aggregate model validation results across branches

     ##########BUILD FIGURES AND SHAPEFILES
     tar_target(EROM_figure, eromVerification(USGS_data, nhdGages), deployment='main'), #figures for validating discharges
     tar_target(validationResults, validateModel(combined_validation, snappingThresh), deployment='main'), #validation confusion matrix
     tar_target(shapefile_fin, saveShapefile(path_to_data, codes_huc02, combined_results), deployment='main'), #model results shapefile
     tar_target(val_shapefile_fin, saveValShapefile(path_to_data, codes_huc02, validationResults), deployment='main'), #validation results shapefile (HUC2 level)
     tar_target(boxplots, boxPlots(combined_results), deployment='main') #build boxplots comparing flowing vs non flowing importance
)






# tar_target(flowQmodel, flowingQ(USGS_data)),


#ephThresh <- 1e-7 #[m] minimum flow for 'ephemeral flow' in scaling
#perc_thresh <- 0.03

#tar_target(modelVerification, verifyModel(combined_verify), deployment='main'), #generate figures for final model verification (run locally on master process)
# tar_target(rivNetFin_verify, getRivNetverify(rivNetFin, nhdGages, USGS_data)), #trim results to just those reaches with a gage (for model verification)
#   tar_combine(combined_verify, mapped$rivNetFin_verify, command = dplyr::bind_rows(!!!.x, .id = "method")), #aggregate gaged model results across branches (for model verification)

     #doing this manually for now.......
#     tar_combine(combined_01, mapped$rivNetFin[1:10], command = dplyr::bind_rows(!!!.x, .id='method')),
#     tar_target(scaledResult_01, doScaling(combined_01, ephThresh, '01', perc_thresh)),

#     tar_combine(combined_02, mapped$rivNetFin[11:17], command = dplyr::bind_rows(!!!.x, .id='method')),
#     tar_target(scaledResult_02, doScaling(combined_02, ephThresh, '02', perc_thresh)),

#     tar_combine(combined_11_12, mapped$rivNetFin[18:42], command = dplyr::bind_rows(!!!.x, .id='method')),
#     tar_target(scaledResult_11_12, doScaling(combined_11_12, ephThresh, '11', perc_thresh)),

  #   tar_combine(combined_12, mapped$rivNetFin[32:42], command = dplyr::bind_rows(!!!.x, .id='method')),
  #   tar_target(scaledResult_12, doScaling(combined_12, ephThresh, '12', perc_thresh)),

#     tar_combine(combined_13, mapped$rivNetFin[43:51], command = dplyr::bind_rows(!!!.x, .id='method')),# NOT ENOUGH EPHEMERAL DATA...
#     tar_target(scaledResult_13, doScaling(combined_13, ephThresh, '13', perc_thresh)),

#     tar_combine(combined_14, mapped$rivNetFin[52:59], command = dplyr::bind_rows(!!!.x, .id='method')),
#     tar_target(scaledResult_14, doScaling(combined_14, ephThresh, '14', perc_thresh)),

#     tar_combine(combined_15, mapped$rivNetFin[60:67], command = dplyr::bind_rows(!!!.x, .id='method')),
#     tar_target(scaledResult_15, doScaling(combined_15, ephThresh, '15', perc_thresh)),

#     tar_combine(combined_16, mapped$rivNetFin[68:73], command = dplyr::bind_rows(!!!.x, .id='method')),
#     tar_target(scaledResult_16, doScaling(combined_16, ephThresh, '16', perc_thresh)),

#     tar_combine(combined_06, mapped$rivNetFin[74:77], command = dplyr::bind_rows(!!!.x, .id='method')),
#     tar_target(scaledResult_06, doScaling(combined_06, ephThresh, '06', perc_thresh))

     #tar_combine(combined_results_scaled, scaledResult_01, scaledResult_02, scaledResult_11, scaledResult_12, scaledResult_14, scaledResult_15, scaledResult_16, command = dplyr::bind_rows(!!!.x, .id = "method"))
