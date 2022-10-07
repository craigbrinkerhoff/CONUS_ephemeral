# _targets.R file
## Craig Brinkerhoff
## Spring 2022
## main script to launch pipeline for ephemeral streams project.
## see README file

library(targets)
library(tarchetypes)
library(tibble)
library(future)
library(future.batchtools)
source('src/utils.R')
source('src/analysis.R')
source('src/prep_gagedata.R')
source('src/build_shapefiles.R')
source('src/validation_ephemeral.R')
source('src/verification_flowingDays.R')
source('src/figures_additional.R')
source('src/figures_paper.R')

plan(batchtools_slurm, template = "slurm_future.tmpl") #for parallelization via futures transient workers
#options(clustermq.scheduler = 'slurm', clustermq.template = "slurm_clustermq.tmpl") #for parallelization via clustermq persistent workers
tar_option_set(packages = c('terra', 'sf', 'dplyr', 'readr', 'ggplot2', 'cowplot', 'dataRetrieval', 'clustermq', 'scales', 'tidyr', 'biscale', 'patchwork', 'ggsflabel', 'ggspatial', 'ggrepel')) #set up packages to load in. Note that tidyr is specified manually throughout to avoid conflicts with dplyr

#############USER INPUTS-------------------
#meta parameters
path_to_data <- '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data' #path to data repo (separate from code repo)
codes_huc02 <- c('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18') #HUC2 regions to get gage data. Make sure these match the HUC4s that are being mapped below

#ehemeral mapping parameters
threshold <- -1 #[m] buffer around 0m depth to capture the free surface (west is first & east is second)
error <- 0 #[ignored] to add a bit of an error tolerance to the ephemeral mapping thresholding

#ephemeral mapping validation parameters
noFlowGageThresh <- 0.05 #[percent] no flow fraction for USGS gauge, used to determine which gauges are certainly not-ephemeral and can be included in the validation dataset (set very low to be sure)
snappingThresh <- 10 #[m] see object compareSnappingThreshs for output that informs this 'expert assignment'

#num flowing days parameter
#runoff_thresh <- 0.25 #[mm/dy] a priori runoff threshold for flow generation for a storm event. Equivalent to 0.01mm/hr all day

#flowing days parameters
  #runoffEffScalar [percent]: sensitivity parameter to use to perturb model sensitivity to runoff efficiency: % of runoff ratio to add or subtract
runoffEffScalar_low <- -0.33
runoffEffScalar_med_low <- -0.18
runoffEffScalar_high <- 0.33
runoffEffScalar_med_high <- 0.18
runoffEffScalar_real <- 0

  #runoffMemory [days]: sensitivity parameter to test 'runoff memory' in number of flowing days calculation: number of additional days of streamflow generated from a rain event
runoffMemory_low <- 0
runoffMemory_med_low <- 1
runoffMemory_high <- 10
runoffMemory_med_high <- 6
runoffMemory_real <- 2

#new england field sites data
field_dataset <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/new_england_fieldSites.csv'))
Pdata <- readr::read_csv('/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/for_ephemeral_project/2020jg005684-sup-0002-data.csv')

##############SETUP STATIC BRANCHING FOR MODEL RUNS ACCROSS BASINS----------------------------
#Each HUC4 basin gets it's own branch
mapped <- tar_map(
       unlist=FALSE,
       values = tibble(
         method_function = rlang::syms("extractData"),
         huc4 = c('0101', '0102', '0103', '0104', '0105', '0106', '0107', '0108', '0109', '0110',
                  '0202', '0203', '0206', '0207', '0208', '0204', '0205', #no '0201'
                  '0301', '0302', '0303', '0304', '0305', '0306', '0307', '0308', '0309', '0310', '0311', '0312', '0313', '0314', '0315', '0316', '0317', '0318',
                  '0401', '0402', '0403', '0404', '0405', '0406', '0407', '0408', '0409', '0410', '0411', '0412', '0413', '0414', '0420', '0427', '0429', '0430',
                  '0501', '0502', '0503', '0504', '0505', '0506', '0507', '0508', '0509', '0510', '0511', '0512', '0513', '0514',
                  '0601', '0602', '0603', '0604',
                  '0701', '0702', '0703', '0704', '0705', '0706', '0707', '0708', '0709', '0710', '0711', '0712', '0713', '0714',
                  '0801', '0802', '0803', '0804', '0805', '0806', '0807', '0808', '0809',
                  '0901', '0902', '0903', '0904',
                  '1002', '1003', '1004', '1005', '1006', '1007', '1008', '1009', '1010', '1011', '1012', '1013', '1014', '1015', #no '1001'
                      '1016', '1017', '1018', '1019', '1020', '1021', '1022', '1023', '1024', '1025', '1026', '1027', '1028', '1029', '1030',
                  '1101', '1102', '1103', '1104', '1105', '1106', '1107', '1108', '1109', '1110', '1111', '1112', '1113', '1114',
                  '1204', '1205', '1208', '1211', '1209', '1210', '1201', '1202', '1203', '1206', '1207',
                  '1301', '1302', '1303', '1304', '1305', '1306', '1307', '1308', '1309',
                  '1402', '1403', '1406', '1407', '1408', '1401', '1404', '1405',
                  '1502', '1504', '1505', '1506', '1507', '1501', '1508', '1503',
                  '1601', '1602', '1603', '1605', '1604', '1606',
                  '1701', '1702', '1703', '1704', '1705', '1706', '1707', '1708', '1709', '1710', '1711', '1712',
                  '1801', '1802', '1803', '1804', '1805', '1806', '1807', '1808', '1809', '1810')
       ),
       names = "huc4",
       tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #calculate runoff efficiency per HUC4 basin
       tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
       tar_target(rivNetFin, getPerenniality(extractedRivNet, huc4, threshold, error, 'median')), #calculate perenniality
       tar_target(runoffThresh, calcRunoffThresh(rivNetFin)),
       tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, combined_runoffEff, runoffThresh, runoffEffScalar_real, runoffMemory_real)), #calculate ballpark number of flowing days
       tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, combined_runoffEff, runoffThresh, runoffEffScalar_low, runoffMemory_low)), #calculate ballpark number of flowing days under low runoff scenario
       tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, combined_runoffEff, runoffThresh, runoffEffScalar_high, runoffMemory_high)), #calculate ballpark number of flowing days under high runoff scenario
       tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, combined_runoffEff, runoffThresh, runoffEffScalar_med_low, runoffMemory_med_low)), #calculate ballpark number of flowing days under low runoff scenario
       tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, combined_runoffEff, runoffThresh, runoffEffScalar_med_high, runoffMemory_med_high)), #calculate ballpark number of flowing days under high runoff scenario
       tar_target(results, collectResults(rivNetFin, numFlowingDays, huc4)), #calculate basin statistics using streamflow model
       tar_target(scaledResult, scalingByBasin(scalingModel, rivNetFin, results, huc4)), #scale to additonal ephemeral orders vis Horton Laws
       tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)))

#############ACTUAL PIPLINE, COMBINING STATIC BRANCHING, AGGREGATION TARGETS, AND ALL OTHER TARGETS--------------------------------------
list(
     ##farmed targets
  
     #######GATHER, PREP, AND VALIDATE STREAMFLOWS VIA USGS GAUGES
     tar_target(nhdGages, getNHDGages(path_to_data, codes_huc02)), #gages joined to NHD a priori, used for erom verification
     tar_target(USGS_data, getGageData(path_to_data, nhdGages, codes_huc02)), #calculates mean observed flow 1970-2018 to verify erom model

     #########GATHER AND PREP EPA WOTUS JD VALIDATION SET
     tar_target(validationDF, prepValDF(path_to_data)), #clean WOTUS validation set

     ##########GATHER AND PREP FIELD DATA ON NUMBER OF FLOWING DAYS PER YEAR IN EPHEMERAL CHANNELS
     tar_target(flowingFieldData, wrangleFlowingFieldData(path_to_data)),
     tar_target(flowingDaysValidation, flowingValidate(flowingFieldData, path_to_data, codes_huc02, combined_results)),
     tar_target(flowingDaysCalibrate, flowingValidateSensitivityWrapper(flowingFieldData, runoffEffScalar_real, runoffMemory_real, c(0.001, 0.0025, 0.005, 0.0075, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.50, 0.75, 1), path_to_data, combined_runoffEff)),

     ##########GATHER, PREP, AND VALIDATE OUR EPHEMERAL MAPPING VALIDATION SETP
     tar_target(ourFieldData, addOurFieldData(rivNetFin_0106, rivNetFin_0108, path_to_data, field_dataset)), #wrangle our field-assessed classified streams in northeast US
     tar_target(validationResults, validateModel(combined_validation, ourFieldData, snappingThresh), deployment='main'), #actual validation using validation data from 3 datasets (see manuscript)

     ##########SNAPPING PARAMETER SENSITIVITY ANALYSES
     tar_target(compareSnappingThreshs, snappingSensitivityWrapper(c(1,5,10,15,20,25,30,35,40,45,50), combined_validation, ourFieldData)), #to figure out the ideal snapping threshold by finding the setup that most closesly refelcts horton scaling

     ##########PREP FOR EPHEMERAL SCALING TO ADDITIONAL ORDERS
     tar_target(scalingModel, scalingFunc(validationResults)), #how many additional ephemeral orders we should have (via Horton laws)

     ##########RUN & VALIDATE MODEL PER HUC4 see above tar_map() object). Also runs numFlowingDays 'sensitivty' analysis per HUC4. Also also snaps WOTUS validation data to hydrography per HUC4
     mapped,
     
     
     
     
     ## master targets

     #########AGGREGATE BY-BASIN RESULTS
     tar_combine(combined_runoffEff, mapped$runoffEff, command = dplyr::bind_rows(!!!.x, .id = "method"), deployment='main'),  #aggregate model results across branches
     tar_combine(combined_results, mapped$scaledResult, command = dplyr::bind_rows(!!!.x, .id = "method"), deployment='main'),  #aggregate model results across branches
     tar_combine(combined_numFlowingDays, mapped$numFlowingDays, command = c(!!!.x), deployment='main'),  #aggregate model results across branches
     tar_combine(combined_numFlowingDays_low, mapped$numFlowingDays_low, command = c(!!!.x), deployment='main'),  #aggregate model results across branches
     tar_combine(combined_numFlowingDays_high, mapped$numFlowingDays_high, command = c(!!!.x), deployment='main'),  #aggregate model results across branches
     tar_combine(combined_numFlowingDays_med_low, mapped$numFlowingDays_med_low, command = c(!!!.x), deployment='main'),  #aggregate model results across branches
     tar_combine(combined_numFlowingDays_med_high, mapped$numFlowingDays_med_high, command = c(!!!.x), deployment='main'),  #aggregate model results across branches
     tar_combine(combined_validation, mapped$snappedValidation, command = dplyr::bind_rows(!!!.x, .id = "method"), deployment='main'),  #aggregate model validation results across branches
     tar_combine(combined_runoffThresh, mapped$runoffThresh, command = c(!!!.x), deployment='main'),
     
     ##########MAKE FINAL SHAPEFILES WITH RESULTS
     tar_target(shapefile_fin, saveShapefile(path_to_data, codes_huc02, combined_results), deployment='main'), #model results shapefile
     tar_target(val_shapefile_fin, saveValShapefile(path_to_data, codes_huc02, validationResults), deployment='main'), #validation results shapefile (HUC2 level)

     #########GENERATE MANUSCRIPT FIGURES
     tar_target(fig1, mainFigureFunction(shapefile_fin, rivNetFin_0107, rivNetFin_1009, rivNetFin_1709, rivNetFin_1305), deployment='main'), #fig 1
     tar_target(fig2, flowingFigureFunction(shapefile_fin, flowingDaysValidation), deployment='main'), #fig 2
     tar_target(fig3, landUseMapFunction(shapefile_fin), deployment='main'), #fig 3
     tar_target(fig4, bivariateMapFunction(shapefile_fin, rivNetFin_1025), deployment='main'), #fig 4
     tar_target(fig4_new, combinedMetricPlot(shapefile_fin), deployment='main'), #fig 4 maybe new?

     ##########BUILD SUPPLEMENTRY FIGURES
     tar_target(EROM_figure, eromVerification(USGS_data, nhdGages), deployment='main'), #figures for validating discharges
     tar_target(boxplotsClassification, boxPlots_classification(val_shapefile_fin)),
     tar_target(boxPlotsSensitivity, boxPlots_sensitivity(combined_numFlowingDays, combined_numFlowingDays_low, combined_numFlowingDays_high, combined_numFlowingDays_med_low, combined_numFlowingDays_med_high), deployment='main'), #ephemeral flow frequency sensitivity figure
     tar_target(snappingSensitivityFig, snappingSensitivityFigures(compareSnappingThreshs), deployment='main'), #figures for snapping thresh sensitivity analysis
     tar_target(scalingModelFig, buildScalingModelFig(scalingModel), deployment='main'), #figures for snapping thresh sensitivity analysis
     tar_target(flowingDaysCalibrateFig, runoffThreshCalibPlot(flowingDaysCalibrate, combined_runoffThresh)), #figure for empirical runoff threshold calibration
     tar_target(flowingMap, flowingMapFigureFunction(shapefile_fin), deployment='main'), #ephemeral influence map using 'mean annual flowing Q'
     tar_target(validationMap, mappingValidationFigure(val_shapefile_fin), deployment='main'),

     #########GENERATE GUIDE TO DATA/MODEL INPUTS
     tar_render(data_guide, "docs/data_guide.Rmd", deployment='main') #data guide
)
