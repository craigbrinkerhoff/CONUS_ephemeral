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

options(clustermq.scheduler = "multiprocess") #set up clustermq R parallel scheduler
tar_option_set(packages = c('terra', 'sf', 'dplyr', 'readr', 'ggplot2', 'cowplot', 'dataRetrieval', 'clustermq', 'grwat')) #set up packages to load in. Note that tidyr is specified manually throughout to avoid conflicts with dplyr


#############USER INPUTS-------------------
path_to_data <- 'C:\\Users\\craig\\OneDrive - University of Massachusetts\\Ongoing Projects\\CONUS_CO2_prep' #path to data repo (separate from code repo)
widAHG <- readr::read_rds('C:/Users/craig/OneDrive - University of Massachusetts/Ongoing Projects/RSK600/cache/widAHG.rds') #width AHG model
threshold <- -0.25 #threshold for 'persistent surface saturation' from Fan etal 2013
error <- 0

#SETUP STATIC BRANCHING----------------------------
#Each HUC4 branch gets it's own branch
mapped <- tar_map(
       unlist=FALSE, #to facilitate tar_combine within a mapping scheme (see below)
       values = tibble(
         method_function = rlang::syms("extractWTD"),
         huc4 = c('0101', '0102', '0103', '0104', '0105', '0106', '0107', '0108', '0109', '0110', #huc4 basins to run
               #   '0202', '0203', '0204', '0205', '0206', '0207', '0208',
                  "1101", '1102', '1103', '1104', '1105', '1106', '1107', '1108', '1109', '1110', '1111', '1112', '1113', '1114',
                  '1201', '1202', '1203', '1204', '1205', '1206', '1207', '1208', '1209', '1210', '1211',
                  '1301', '1302', '1303', '1304', '1305', '1306', '1307', '1308', '1309',
               #   '1401', '1402', '1403', '1404', '1405', '1406', '1407', '1408',
              #    '1501', '1502', '1503', '1504', '1505', '1506', '1507', '1508',
                  '1601', '1602', '1603', '1604', '1605', '1606')
       ),
       names = "huc4",
       tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along the river reaches
       tar_target(rivNetFin, getPerenniality(extractedRivNet, huc4, threshold, error, 'mean', widAHG)), #calculate perenniality using mean water table depth along the reach and a summarizing statistic (mean, median, min, max)
       tar_target(rivNetFin_verify, getRivNetverify(rivNetFin, nhdGages, USGS_data)), #trim results to just those reaches with a gage (for model verification)
       tar_target(results, collectResults(rivNetFin, huc4))) #aggregate HUC4 model results

#############ACTUAL PIPLINE, COMBINING STATIC BRANCHING, AGGREGATION TARGETS, AND OTHER NECESSARY TARGETS
list(tar_target(nhdGages, getNHDGages(path_to_data)), #gages joined to NHD a priori
     tar_target(USGS_data, getGageData(path_to_data, nhdGages)), #calculates baseflow and no flow indices for every gage with minimum 20yrs data b/w 1970-2018 and joined to NHD
     mapped, #run actual model (see above)
     tar_combine(combined_verify, mapped$rivNetFin_verify, command = dplyr::bind_rows(!!!.x, .id = "method")), #aggregate HUC4 model verification data
     tar_combine(combined_results, mapped$results, command = dplyr::bind_rows(!!!.x, .id = "method")),  #aggregate HUC4 model results
     tar_target(EROM_figure, eromVerification(USGS_data, nhdGages)), #validate erom discharges using 1970-2018 streamflow
     tar_target(modelVerification, verifyModel(combined_verify))) #final model verification figures

