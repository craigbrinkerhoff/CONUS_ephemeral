# _targets.R file
## Craig Brinkerhoff
## Winter 2023

library(targets)
library(tarchetypes)
library(tibble)
#library(clustermq)
library(future)
library(future.batchtools)
source('src/model.R')
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
lookUpTable <- readr::read_csv('data/HUC4_lookup.csv') #basin routing lookup table
usgs_eph_sites <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/usgs_gages_eph.csv'))

#ehemeral mapping parameters
threshold <- -0.01 #[m] buffer around 10cm depth to capture the free surface
error <- 0 #[not used] to add a bit of an error tolerance to the ephemeral mapping thresholding

#ephemeral mapping validation parameters
noFlowGageThresh <- 0.05 #[percent] no flow fraction for USGS gauge, used to determine which gauges are certainly not-ephemeral and can be included in the validation dataset (set very low to be sure)
snappingThresh <- 10 #[m] see compareSnappingThreshs for output that informs this 'expert assignment'

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
runoffMemory_real <- 4

runoffThresh_scalar <- 2.5 #[mm/dy] the calibrated value (see flowingDaysCalibrate)

#new England field sites data
field_dataset <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/new_england_fieldSites.csv'))

#### SETUP STATIC BRANCHING FOR PARALLEL ROUTING-----------------------------------------------------
#Headwater basins that export into the next level of basins
mapped_lvl0 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 0,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, 'median', NA)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order streams that are ephemeral
      tar_target(percEph_tokunga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral classification reaches
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
    tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_real, runoffMemory_real, 0)), #calculate number of flowing days
    tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under low runoff scenario
    tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_high, runoffMemory_real, 0)), #calculate ballpark number of flowing days under high runoff scenario
    tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under med-low runoff scenario
    tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_high, runoffMemory_real, 0)) #calculate ballpark number of flowing days under med-high runoff scenario
)


# #level 1 downstream basins
mapped_lvl1 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 1,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, 'median', exported_percEph_lvl0)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order streams that are ephemeral
      tar_target(percEph_tokunga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral classification reaches
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
    tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_real, runoffMemory_real, 0)), #calculate number of flowing days
    tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under low runoff scenario
    tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_high, runoffMemory_real, 0)), #calculate ballpark number of flowing days under high runoff scenario
    tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under med-low runoff scenario
    tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_high, runoffMemory_real, 0)) #calculate ballpark number of flowing days under med-high runoff scenario
)

#level 2 downstream basins
mapped_lvl2 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 2,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, 'median', exported_percEph_lvl1)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order streams that are ephemeral
      tar_target(percEph_tokunga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral classification reaches
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
    tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_real, runoffMemory_real, 0)), #calculate number of flowing days
    tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under low runoff scenario
    tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_high, runoffMemory_real, 0)), #calculate ballpark number of flowing days under high runoff scenario
    tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under med-low runoff scenario
    tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_high, runoffMemory_real, 0)) #calculate ballpark number of flowing days under med-high runoff scenario
)

#level 3 downstream basins
mapped_lvl3 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 3,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, 'median', exported_percEph_lvl2)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order streams that are ephemeral
      tar_target(percEph_tokunga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral classification reaches
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
    tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_real, runoffMemory_real, 0)), #calculate number of flowing days
    tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under low runoff scenario
    tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_high, runoffMemory_real, 0)), #calculate ballpark number of flowing days under high runoff scenario
    tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under med-low runoff scenario
    tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_high, runoffMemory_real, 0)) #calculate ballpark number of flowing days under med-high runoff scenario
)

#level 4 downstream basins
mapped_lvl4 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 4,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, 'median', exported_percEph_lvl3)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order streams that are ephemeral
      tar_target(percEph_tokunga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral classification reaches
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
    tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_real, runoffMemory_real, 0)), #calculate number of flowing days
    tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under low runoff scenario
    tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_high, runoffMemory_real, 0)), #calculate ballpark number of flowing days under high runoff scenario
    tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under med-low runoff scenario
    tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_high, runoffMemory_real, 0)) #calculate ballpark number of flowing days under med-high runoff scenario
)

#level 5 downstream basins
mapped_lvl5 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 5,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, 'median', exported_percEph_lvl4)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order streams that are ephemeral
      tar_target(percEph_tokunga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral classification reaches
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
    tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_real, runoffMemory_real, 0)), #calculate number of flowing days
    tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under low runoff scenario
    tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_high, runoffMemory_real, 0)), #calculate ballpark number of flowing days under high runoff scenario
    tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under med-low runoff scenario
    tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_high, runoffMemory_real, 0)) #calculate ballpark number of flowing days under med-high runoff scenario
)

#level 6 downstream basins
mapped_lvl6 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 6,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, 'median', exported_percEph_lvl5)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order streams that are ephemeral
      tar_target(percEph_tokunga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral classification reaches
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
    tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_real, runoffMemory_real, 0)), #calculate number of flowing days
    tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under low runoff scenario
    tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_high, runoffMemory_real, 0)), #calculate ballpark number of flowing days under high runoff scenario
    tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under med-low runoff scenario
    tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_high, runoffMemory_real, 0)) #calculate ballpark number of flowing days under med-high runoff scenario
)

#level 7 downstream basins
mapped_lvl7 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 7,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, 'median', exported_percEph_lvl6)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order streams that are ephemeral
      tar_target(percEph_tokunga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral classification reaches
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
    tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_real, runoffMemory_real, 0)), #calculate number of flowing days
    tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under low runoff scenario
    tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_high, runoffMemory_real, 0)), #calculate ballpark number of flowing days under high runoff scenario
    tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under med-low runoff scenario
    tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_high, runoffMemory_real, 0)) #calculate ballpark number of flowing days under med-high runoff scenario
)

#level 8 downstream basins
mapped_lvl8 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 8,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, 'median', exported_percEph_lvl7)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order streams that are ephemeral
      tar_target(percEph_tokunga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral classification reaches
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
    tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_real, runoffMemory_real, 0)), #calculate number of flowing days
    tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under low runoff scenario
    tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_high, runoffMemory_real, 0)), #calculate ballpark number of flowing days under high runoff scenario
    tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under med-low runoff scenario
    tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_high, runoffMemory_real, 0)) #calculate ballpark number of flowing days under med-high runoff scenario
)


#level 9 downstream basins
mapped_lvl9 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 9,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, 'median', exported_percEph_lvl8)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order streams that are ephemeral
      tar_target(percEph_tokunga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral classification reaches
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
    tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_real, runoffMemory_real, 0)), #calculate number of flowing days
    tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under low runoff scenario
    tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_high, runoffMemory_real, 0)), #calculate ballpark number of flowing days under high runoff scenario
    tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under med-low runoff scenario
    tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_high, runoffMemory_real, 0)) #calculate ballpark number of flowing days under med-high runoff scenario
)


#level 10 downstream basins
mapped_lvl10 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 10,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, 'median', exported_percEph_lvl9)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order streams that are ephemeral
      tar_target(percEph_tokunga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral classification reaches
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
    tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_real, runoffMemory_real, 0)), #calculate number of flowing days
    tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under low runoff scenario
    tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_high, runoffMemory_real, 0)), #calculate ballpark number of flowing days under high runoff scenario
    tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under med-low runoff scenario
    tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_high, runoffMemory_real, 0)) #calculate ballpark number of flowing days under med-high runoff scenario
)


#level 11 downstream basins
mapped_lvl11 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 11,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, 'median', exported_percEph_lvl10)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order streams that are ephemeral
      tar_target(percEph_tokunga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral classification reaches
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
    tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_real, runoffMemory_real, 0)), #calculate number of flowing days
    tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under low runoff scenario
    tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_high, runoffMemory_real, 0)), #calculate ballpark number of flowing days under high runoff scenario
    tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under med-low runoff scenario
    tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_high, runoffMemory_real, 0)) #calculate ballpark number of flowing days under med-high runoff scenario
)


#level 12 downstream basins
mapped_lvl12 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 12,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, 'median', exported_percEph_lvl11)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order streams that are ephemeral
      tar_target(percEph_tokunga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral classification reaches
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
    tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_real, runoffMemory_real, 0)), #calculate number of flowing days
    tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under low runoff scenario
    tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_high, runoffMemory_real, 0)), #calculate ballpark number of flowing days under high runoff scenario
    tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under med-low runoff scenario
    tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_high, runoffMemory_real, 0)) #calculate ballpark number of flowing days under med-high runoff scenario
)


#level 13 downstream basins
mapped_lvl13 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 13,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, 'median', exported_percEph_lvl12)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order streams that are ephemeral
      tar_target(percEph_tokunga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral classification reaches
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
    tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_real, runoffMemory_real, 0)), #calculate number of flowing days
    tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under low runoff scenario
    tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_high, runoffMemory_real, 0)), #calculate ballpark number of flowing days under high runoff scenario
    tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under med-low runoff scenario
    tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_high, runoffMemory_real, 0)) #calculate ballpark number of flowing days under med-high runoff scenario
)


#level 14 downstream basins
mapped_lvl14 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 14,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, 'median', exported_percEph_lvl13)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order streams that are ephemeral
      tar_target(percEph_tokunga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral classification reaches
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
    tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_real, runoffMemory_real, 0)), #calculate number of flowing days
    tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under low runoff scenario
    tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_high, runoffMemory_real, 0)), #calculate ballpark number of flowing days under high runoff scenario
    tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under med-low runoff scenario
    tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_high, runoffMemory_real, 0)) #calculate ballpark number of flowing days under med-high runoff scenario
)


#level 15 downstream basins
mapped_lvl15 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 15,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, 'median', exported_percEph_lvl14)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order streams that are ephemeral
      tar_target(percEph_tokunga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral classification reaches
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
    tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_real, runoffMemory_real, 0)), #calculate number of flowing days
    tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under low runoff scenario
    tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_high, runoffMemory_real, 0)), #calculate ballpark number of flowing days under high runoff scenario
    tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under med-low runoff scenario
    tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_high, runoffMemory_real, 0)) #calculate ballpark number of flowing days under med-high runoff scenario
)

#level 16 downstream basins
mapped_lvl16 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 16,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, 'median', exported_percEph_lvl15)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order streams that are ephemeral
      tar_target(percEph_tokunga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral classification reaches
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
    tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_real, runoffMemory_real, 0)), #calculate number of flowing days
    tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under low runoff scenario
    tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_high, runoffMemory_real, 0)), #calculate ballpark number of flowing days under high runoff scenario
    tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under med-low runoff scenario
    tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_high, runoffMemory_real, 0)) #calculate ballpark number of flowing days under med-high runoff scenario
)

#level 17 downstream basins
mapped_lvl17 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 17,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, 'median', exported_percEph_lvl16)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order streams that are ephemeral
      tar_target(percEph_tokunga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral classification reaches
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
    tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_real, runoffMemory_real, 0)), #calculate number of flowing days
    tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under low runoff scenario
    tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_high, runoffMemory_real, 0)), #calculate ballpark number of flowing days under high runoff scenario
    tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under med-low runoff scenario
    tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_high, runoffMemory_real, 0)) #calculate ballpark number of flowing days under med-high runoff scenario
)


#level 18 downstream basins
mapped_lvl18 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 18,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, 'median', exported_percEph_lvl17)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order streams that are ephemeral
      tar_target(percEph_tokunga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral classification reaches
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
    tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_real, runoffMemory_real, 0)), #calculate number of flowing days
    tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under low runoff scenario
    tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_high, runoffMemory_real, 0)), #calculate ballpark number of flowing days under high runoff scenario
    tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_low, runoffMemory_real, 0)), #calculate ballpark number of flowing days under med-low runoff scenario
    tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, runoffThresh_scalar, runoffEffScalar_med_high, runoffMemory_real, 0)) #calculate ballpark number of flowing days under med-high runoff scenario
)





list(
  ####INTIAL TARGETS--------------
  #GATHER, PREP, AND VALIDATE STREAMFLOWS VIA USGS GAUGES
  tar_target(nhdGages, getNHDGages(path_to_data, codes_huc02)), #gages joined to NHD a priori, used for erom verification
  tar_target(USGS_data, getGageData(path_to_data, nhdGages, codes_huc02)), #calculates mean observed flow 1970-2018 to verify erom model
  
  #GATHER AND PREP EPA WOTUS JD VALIDATION SET
  tar_target(validationDF, prepValDF(path_to_data)), #clean WOTUS validation set
  
  #GATHER AND PREP FIELD DATA ON NUMBER OF FLOWING DAYS PER YEAR IN EPHEMERAL CHANNELS
  tar_target(ephemeralQDataset_all, wrangleUSGSephGages(usgs_eph_sites)),
  tar_target(ephemeralQDataset, setupEphemeralQValidation(path_to_data, walnutGulch$df, ephemeralQDataset_all, rivNetFin_1008, rivNetFin_1009, rivNetFin_1012, rivNetFin_1404, rivNetFin_1408, rivNetFin_1405, rivNetFin_1507, rivNetFin_1506,rivNetFin_1809, rivNetFin_1501,rivNetFin_1503,rivNetFin_1606,rivNetFin_1302,rivNetFin_1306,rivNetFin_1303,rivNetFin_1305), deployment='main'),
  tar_target(flowingFieldData, wrangleFlowingFieldData(path_to_data, ephemeralQDataset_all)), #uses all USGS ephemeral gages
  tar_target(flowingDaysValidation, flowingValidate(flowingFieldData, path_to_data, codes_huc02,combined_results, combined_runoffEff)), #combined_numFlowingDays_mc
  tar_target(flowingDaysCalibrate, flowingValidateSensitivityWrapper(flowingFieldData, runoffEffScalar_real, runoffMemory_real, c(0.001, 0.005,0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.50, 0.75, 1, 2.5, 5, 10, 50), path_to_data, combined_runoffEff)),
  tar_target(checkUSGSephHydrographs, ephemeralityChecker(usgs_eph_sites)),
  
  #GATHER, PREP, AND VALIDATE OUR EPHEMERAL MAPPING VALIDATION SETP
  tar_target(ourFieldData, addOurFieldData(rivNetFin_0106, rivNetFin_0108, path_to_data, field_dataset)), #wrangle our field-assessed classified streams in northeast US
  tar_target(validationResults, validateModel(combined_validation, ourFieldData, snappingThresh), deployment='main'), #actual validation using validation data from 3 datasets (see manuscript)
  
  #SNAPPING PARAMETER SENSITIVITY ANALYSES
  tar_target(compareSnappingThreshs, snappingSensitivityWrapper(c(5,10,15,20,25,30,35,40,45,50), combined_validation, ourFieldData)), #to figure out the ideal snapping threshold by finding the setup that most closesly refelcts horton scaling
  
  #PREP FOR EPHEMERAL SCALING TO ADDITIONAL ORDERS
  tar_target(scalingModel, scalingFunc(validationResults)), #how many additional ephemeral orders we should have (via Horton laws)
  
  ####PARALLEL MODEL RUNS BY BASIN LEVEL----------------------------
  #level 0
  mapped_lvl0,
  tar_combine(exported_percEph_lvl0, mapped_lvl0$exported_percEph, command = dplyr::bind_rows(!!!.x, .id = "method"), deployment = "main"),  #aggregate model results across branches
  
  #level 1
  mapped_lvl1,
  tar_combine(exported_percEph_lvl1, list(mapped_lvl0$exported_percEph,
                                      mapped_lvl1$exported_percEph), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment = "main"),  #aggregate model results across branches

  #level 2
  mapped_lvl2,
  tar_combine(exported_percEph_lvl2, list(mapped_lvl0$exported_percEph,
                                     mapped_lvl1$exported_percEph,
                                     mapped_lvl2$exported_percEph), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment = "main"),  #aggregate model results across branches

  #LEVEL 3
  mapped_lvl3,
  tar_combine(exported_percEph_lvl3, list(mapped_lvl0$exported_percEph,
                                     mapped_lvl1$exported_percEph,
                                     mapped_lvl2$exported_percEph,
                                     mapped_lvl3$exported_percEph), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment = "main"),  #aggregate model results across branches

  #LEVEL 4
  mapped_lvl4,
  tar_combine(exported_percEph_lvl4, list(mapped_lvl0$exported_percEph,
                                     mapped_lvl1$exported_percEph,
                                     mapped_lvl2$exported_percEph,
                                     mapped_lvl3$exported_percEph,
                                     mapped_lvl4$exported_percEph), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment = "main"),  #aggregate model results across branches

  #LEVEL 5
  mapped_lvl5,
  tar_combine(exported_percEph_lvl5, list(mapped_lvl0$exported_percEph,
                                     mapped_lvl1$exported_percEph,
                                     mapped_lvl2$exported_percEph,
                                     mapped_lvl3$exported_percEph,
                                     mapped_lvl4$exported_percEph,
                                     mapped_lvl5$exported_percEph), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment = "main"),  #aggregate model results across branches

  #LEVEL 6
  mapped_lvl6,
  tar_combine(exported_percEph_lvl6, list(mapped_lvl0$exported_percEph,
                                     mapped_lvl1$exported_percEph,
                                     mapped_lvl2$exported_percEph,
                                     mapped_lvl3$exported_percEph,
                                     mapped_lvl4$exported_percEph,
                                     mapped_lvl5$exported_percEph,
                                     mapped_lvl6$exported_percEph), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment = "main"),  #aggregate model results across branches

  #LEVEL 7
  mapped_lvl7,
  tar_combine(exported_percEph_lvl7, list(mapped_lvl0$exported_percEph,
                                     mapped_lvl1$exported_percEph,
                                     mapped_lvl2$exported_percEph,
                                     mapped_lvl3$exported_percEph,
                                     mapped_lvl4$exported_percEph,
                                     mapped_lvl5$exported_percEph,
                                     mapped_lvl6$exported_percEph,
                                     mapped_lvl7$exported_percEph), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment = "main"),  #aggregate model results across branches

  #LEVEL 8
  mapped_lvl8,
  tar_combine(exported_percEph_lvl8, list(mapped_lvl0$exported_percEph,
                                     mapped_lvl1$exported_percEph,
                                     mapped_lvl2$exported_percEph,
                                     mapped_lvl3$exported_percEph,
                                     mapped_lvl4$exported_percEph,
                                     mapped_lvl5$exported_percEph,
                                     mapped_lvl6$exported_percEph,
                                     mapped_lvl7$exported_percEph,
                                     mapped_lvl8$exported_percEph), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment = "main"),  #aggregate model results across branches

  #LEVEL 9
  mapped_lvl9,
  tar_combine(exported_percEph_lvl9, list(mapped_lvl0$exported_percEph,
                                     mapped_lvl1$exported_percEph,
                                     mapped_lvl2$exported_percEph,
                                     mapped_lvl3$exported_percEph,
                                     mapped_lvl4$exported_percEph,
                                     mapped_lvl5$exported_percEph,
                                     mapped_lvl6$exported_percEph,
                                     mapped_lvl7$exported_percEph,
                                     mapped_lvl8$exported_percEph,
                                     mapped_lvl9$exported_percEph), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment = "main"),  #aggregate model results across branches

  #LEVEL 10
  mapped_lvl10,
  tar_combine(exported_percEph_lvl10, list(mapped_lvl0$exported_percEph,
                                      mapped_lvl1$exported_percEph,
                                      mapped_lvl2$exported_percEph,
                                      mapped_lvl3$exported_percEph,
                                      mapped_lvl4$exported_percEph,
                                      mapped_lvl5$exported_percEph,
                                      mapped_lvl6$exported_percEph,
                                      mapped_lvl7$exported_percEph,
                                      mapped_lvl8$exported_percEph,
                                      mapped_lvl9$exported_percEph,
                                      mapped_lvl10$exported_percEph), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment = "main"),  #aggregate model results across branches

  #LEVEL 11
  mapped_lvl11,
  tar_combine(exported_percEph_lvl11, list(mapped_lvl0$exported_percEph,
                                      mapped_lvl1$exported_percEph,
                                      mapped_lvl2$exported_percEph,
                                      mapped_lvl3$exported_percEph,
                                      mapped_lvl4$exported_percEph,
                                      mapped_lvl5$exported_percEph,
                                      mapped_lvl6$exported_percEph,
                                      mapped_lvl7$exported_percEph,
                                      mapped_lvl8$exported_percEph,
                                      mapped_lvl9$exported_percEph,
                                      mapped_lvl10$exported_percEph,
                                      mapped_lvl11$exported_percEph), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment = "main"),  #aggregate model results across branches

  #LEVEL 12
  mapped_lvl12,
  tar_combine(exported_percEph_lvl12, list(mapped_lvl0$exported_percEph,
                                      mapped_lvl1$exported_percEph,
                                      mapped_lvl2$exported_percEph,
                                      mapped_lvl3$exported_percEph,
                                      mapped_lvl4$exported_percEph,
                                      mapped_lvl5$exported_percEph,
                                      mapped_lvl6$exported_percEph,
                                      mapped_lvl7$exported_percEph,
                                      mapped_lvl8$exported_percEph,
                                      mapped_lvl9$exported_percEph,
                                      mapped_lvl10$exported_percEph,
                                      mapped_lvl11$exported_percEph,
                                      mapped_lvl12$exported_percEph), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment = "main"),  #aggregate model results across branches

  #LEVEL 13
  mapped_lvl13,
  tar_combine(exported_percEph_lvl13, list(mapped_lvl0$exported_percEph,
                                      mapped_lvl1$exported_percEph,
                                      mapped_lvl2$exported_percEph,
                                      mapped_lvl3$exported_percEph,
                                      mapped_lvl4$exported_percEph,
                                      mapped_lvl5$exported_percEph,
                                      mapped_lvl6$exported_percEph,
                                      mapped_lvl7$exported_percEph,
                                      mapped_lvl8$exported_percEph,
                                      mapped_lvl9$exported_percEph,
                                      mapped_lvl10$exported_percEph,
                                      mapped_lvl11$exported_percEph,
                                      mapped_lvl12$exported_percEph,
                                      mapped_lvl13$exported_percEph), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment = "main"),  #aggregate model results across branches

  #LEVEL 14
  mapped_lvl14,
  tar_combine(exported_percEph_lvl14, list(mapped_lvl0$exported_percEph,
                                      mapped_lvl1$exported_percEph,
                                      mapped_lvl2$exported_percEph,
                                      mapped_lvl3$exported_percEph,
                                      mapped_lvl4$exported_percEph,
                                      mapped_lvl5$exported_percEph,
                                      mapped_lvl6$exported_percEph,
                                      mapped_lvl7$exported_percEph,
                                      mapped_lvl8$exported_percEph,
                                      mapped_lvl9$exported_percEph,
                                      mapped_lvl10$exported_percEph,
                                      mapped_lvl11$exported_percEph,
                                      mapped_lvl12$exported_percEph,
                                      mapped_lvl13$exported_percEph,
                                      mapped_lvl14$exported_percEph), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment = "main"),  #aggregate model results across branches

  #LEVEL 15
  mapped_lvl15,
  tar_combine(exported_percEph_lvl15, list(mapped_lvl0$exported_percEph,
                                      mapped_lvl1$exported_percEph,
                                      mapped_lvl2$exported_percEph,
                                      mapped_lvl3$exported_percEph,
                                      mapped_lvl4$exported_percEph,
                                      mapped_lvl5$exported_percEph,
                                      mapped_lvl6$exported_percEph,
                                      mapped_lvl7$exported_percEph,
                                      mapped_lvl8$exported_percEph,
                                      mapped_lvl9$exported_percEph,
                                      mapped_lvl10$exported_percEph,
                                      mapped_lvl11$exported_percEph,
                                      mapped_lvl12$exported_percEph,
                                      mapped_lvl13$exported_percEph,
                                      mapped_lvl14$exported_percEph,
                                      mapped_lvl15$exported_percEph), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment = "main"),  #aggregate model results across branches

  #LEVEL 16
  mapped_lvl16,
  tar_combine(exported_percEph_lvl16, list(mapped_lvl0$exported_percEph,
                                      mapped_lvl1$exported_percEph,
                                      mapped_lvl2$exported_percEph,
                                      mapped_lvl3$exported_percEph,
                                      mapped_lvl4$exported_percEph,
                                      mapped_lvl5$exported_percEph,
                                      mapped_lvl6$exported_percEph,
                                      mapped_lvl7$exported_percEph,
                                      mapped_lvl8$exported_percEph,
                                      mapped_lvl9$exported_percEph,
                                      mapped_lvl10$exported_percEph,
                                      mapped_lvl11$exported_percEph,
                                      mapped_lvl12$exported_percEph,
                                      mapped_lvl13$exported_percEph,
                                      mapped_lvl14$exported_percEph,
                                      mapped_lvl15$exported_percEph,
                                      mapped_lvl16$exported_percEph), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment = "main"),  #aggregate model results across branches

  #LEVEL 17
  mapped_lvl17,
  tar_combine(exported_percEph_lvl17, list(mapped_lvl0$exported_percEph,
                                      mapped_lvl1$exported_percEph,
                                      mapped_lvl2$exported_percEph,
                                      mapped_lvl3$exported_percEph,
                                      mapped_lvl4$exported_percEph,
                                      mapped_lvl5$exported_percEph,
                                      mapped_lvl6$exported_percEph,
                                      mapped_lvl7$exported_percEph,
                                      mapped_lvl8$exported_percEph,
                                      mapped_lvl9$exported_percEph,
                                      mapped_lvl10$exported_percEph,
                                      mapped_lvl11$exported_percEph,
                                      mapped_lvl12$exported_percEph,
                                      mapped_lvl13$exported_percEph,
                                      mapped_lvl14$exported_percEph,
                                      mapped_lvl15$exported_percEph,
                                      mapped_lvl16$exported_percEph,
                                      mapped_lvl17$exported_percEph), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment = "main"),  #aggregate model results across branches

  #LEVEL 18
  mapped_lvl18,

  #AGGREGATE BY-BASIN RESULTS into combined targets-----------------
  tar_combine(combined_results, list(mapped_lvl0$results, mapped_lvl1$results, mapped_lvl2$results, mapped_lvl3$results, mapped_lvl4$results, mapped_lvl5$results, mapped_lvl6$results,
                                     mapped_lvl7$results, mapped_lvl8$results, mapped_lvl9$results, mapped_lvl10$results, mapped_lvl11$results, mapped_lvl12$results, mapped_lvl13$results,
                                     mapped_lvl14$results, mapped_lvl15$results, mapped_lvl16$results, mapped_lvl17$results, mapped_lvl18$results), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment='main'),
 
  tar_combine(combined_results_by_order, list(mapped_lvl0$results_by_order, mapped_lvl1$results_by_order, mapped_lvl2$results_by_order, mapped_lvl3$results_by_order, mapped_lvl4$results_by_order, mapped_lvl5$results_by_order, mapped_lvl6$results_by_order,
                                    mapped_lvl7$results_by_order, mapped_lvl8$results_by_order, mapped_lvl9$results_by_order, mapped_lvl10$results_by_order, mapped_lvl11$results_by_order, mapped_lvl12$results_by_order, mapped_lvl13$results_by_order,
                                    mapped_lvl14$results_by_order, mapped_lvl15$results_by_order, mapped_lvl16$results_by_order, mapped_lvl17$results_by_order, mapped_lvl18$results_by_order), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment='main'),
  
  tar_combine(combined_validation, list(mapped_lvl0$snappedValidation, mapped_lvl1$snappedValidation, mapped_lvl2$snappedValidation, mapped_lvl3$snappedValidation, mapped_lvl4$snappedValidation,
                                        mapped_lvl5$snappedValidation, mapped_lvl6$snappedValidation, mapped_lvl7$snappedValidation, mapped_lvl8$snappedValidation, mapped_lvl9$snappedValidation,
                                        mapped_lvl10$snappedValidation, mapped_lvl11$snappedValidation, mapped_lvl12$snappedValidation, mapped_lvl13$snappedValidation, mapped_lvl14$snappedValidation,
                                        mapped_lvl15$snappedValidation, mapped_lvl16$snappedValidation, mapped_lvl17$snappedValidation, mapped_lvl18$snappedValidation), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment='main'),
  
  tar_combine(combined_runoffEff, list(mapped_lvl0$runoffEff, mapped_lvl1$runoffEff, mapped_lvl2$runoffEff, mapped_lvl3$runoffEff, mapped_lvl4$runoffEff, mapped_lvl5$runoffEff,
                                       mapped_lvl6$runoffEff, mapped_lvl7$runoffEff, mapped_lvl8$runoffEff, mapped_lvl9$runoffEff, mapped_lvl10$runoffEff, mapped_lvl11$runoffEff,
                                       mapped_lvl12$runoffEff, mapped_lvl13$runoffEff, mapped_lvl14$runoffEff, mapped_lvl15$runoffEff, mapped_lvl16$runoffEff, mapped_lvl17$runoffEff, mapped_lvl18$runoffEff), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment='main'),

  tar_combine(combined_numFlowingDays, list(mapped_lvl0$numFlowingDays, mapped_lvl1$numFlowingDays, mapped_lvl2$numFlowingDays, mapped_lvl3$numFlowingDays, mapped_lvl4$numFlowingDays, mapped_lvl5$numFlowingDays,
                                            mapped_lvl6$numFlowingDays, mapped_lvl7$numFlowingDays, mapped_lvl8$numFlowingDays, mapped_lvl9$numFlowingDays, mapped_lvl10$numFlowingDays, mapped_lvl11$numFlowingDays,
                                            mapped_lvl12$numFlowingDays, mapped_lvl13$numFlowingDays, mapped_lvl14$numFlowingDays, mapped_lvl15$numFlowingDays, mapped_lvl16$numFlowingDays, mapped_lvl17$numFlowingDays, mapped_lvl18$numFlowingDays), command = c(!!!.x), deployment='main'),  #aggregate model targets across branches

  tar_combine(combined_numFlowingDays_low, list(mapped_lvl0$numFlowingDays_low, mapped_lvl1$numFlowingDays_low, mapped_lvl2$numFlowingDays_low, mapped_lvl3$numFlowingDays_low, mapped_lvl4$numFlowingDays_low, mapped_lvl5$numFlowingDays_low,
                                               mapped_lvl6$numFlowingDays_low, mapped_lvl7$numFlowingDays_low, mapped_lvl8$numFlowingDays_low, mapped_lvl9$numFlowingDays_low, mapped_lvl10$numFlowingDays_low, mapped_lvl11$numFlowingDays_low,
                                               mapped_lvl12$numFlowingDays_low, mapped_lvl13$numFlowingDays_low, mapped_lvl14$numFlowingDays_low, mapped_lvl15$numFlowingDays_low, mapped_lvl16$numFlowingDays_low, mapped_lvl17$numFlowingDays_low, mapped_lvl18$numFlowingDays_low), command = c(!!!.x), deployment='main'),  #aggregate model targets across branches

  tar_combine(combined_numFlowingDays_high, list(mapped_lvl0$numFlowingDays_high, mapped_lvl1$numFlowingDays_high, mapped_lvl2$numFlowingDays_high, mapped_lvl3$numFlowingDays_high, mapped_lvl4$numFlowingDays_high, mapped_lvl5$numFlowingDays_high,
                                                mapped_lvl6$numFlowingDays_high, mapped_lvl7$numFlowingDays_high, mapped_lvl8$numFlowingDays_high, mapped_lvl9$numFlowingDays_high, mapped_lvl10$numFlowingDays_high, mapped_lvl11$numFlowingDays_high,
                                                mapped_lvl12$numFlowingDays_high, mapped_lvl13$numFlowingDays_high, mapped_lvl14$numFlowingDays_high, mapped_lvl15$numFlowingDays_high, mapped_lvl16$numFlowingDays_high, mapped_lvl17$numFlowingDays_high, mapped_lvl18$numFlowingDays_high), command = c(!!!.x), deployment='main'),  #aggregate model targets across branches

  tar_combine(combined_numFlowingDays_med_low, list(mapped_lvl0$numFlowingDays_med_low, mapped_lvl1$numFlowingDays_med_low, mapped_lvl2$numFlowingDays_med_low, mapped_lvl3$numFlowingDays_med_low, mapped_lvl4$numFlowingDays_med_low, mapped_lvl5$numFlowingDays_med_low,
                                                 mapped_lvl6$numFlowingDays_med_low, mapped_lvl7$numFlowingDays_med_low, mapped_lvl8$numFlowingDays_med_low, mapped_lvl9$numFlowingDays_med_low, mapped_lvl10$numFlowingDays_med_low, mapped_lvl11$numFlowingDays_med_low,
                                                 mapped_lvl12$numFlowingDays_med_low, mapped_lvl13$numFlowingDays_med_low, mapped_lvl14$numFlowingDays_med_low, mapped_lvl15$numFlowingDays_med_low, mapped_lvl16$numFlowingDays_med_low, mapped_lvl17$numFlowingDays_med_low, mapped_lvl18$numFlowingDays_med_low), command = c(!!!.x), deployment='main'),  #aggregate model targets across branches

  tar_combine(combined_numFlowingDays_med_high, list(mapped_lvl0$numFlowingDays_med_high, mapped_lvl1$numFlowingDays_med_high, mapped_lvl2$numFlowingDays_med_high, mapped_lvl3$numFlowingDays_med_high, mapped_lvl4$numFlowingDays_med_high, mapped_lvl5$numFlowingDays_med_high,
                                                 mapped_lvl6$numFlowingDays_med_high, mapped_lvl7$numFlowingDays_med_high, mapped_lvl8$numFlowingDays_med_high, mapped_lvl9$numFlowingDays_med_high, mapped_lvl10$numFlowingDays_med_high, mapped_lvl11$numFlowingDays_med_high,
                                                 mapped_lvl12$numFlowingDays_med_high, mapped_lvl13$numFlowingDays_med_high, mapped_lvl14$numFlowingDays_med_high, mapped_lvl15$numFlowingDays_med_high, mapped_lvl16$numFlowingDays_med_high, mapped_lvl17$numFlowingDays_med_high, mapped_lvl18$numFlowingDays_med_high), command = c(!!!.x), deployment='main'),  #aggregate model targets across branches

  tar_combine(combined_percEph_tokunga, list(mapped_lvl0$percEph_tokunga, mapped_lvl1$percEph_tokunga, mapped_lvl2$percEph_tokunga, mapped_lvl3$percEph_tokunga, mapped_lvl4$percEph_tokunga, mapped_lvl5$percEph_tokunga,
                                                   mapped_lvl6$percEph_tokunga, mapped_lvl7$percEph_tokunga, mapped_lvl8$percEph_tokunga, mapped_lvl9$percEph_tokunga, mapped_lvl10$percEph_tokunga, mapped_lvl11$percEph_tokunga,
                                                   mapped_lvl12$percEph_tokunga, mapped_lvl13$percEph_tokunga, mapped_lvl14$percEph_tokunga, mapped_lvl15$percEph_tokunga, mapped_lvl16$percEph_tokunga, mapped_lvl17$percEph_tokunga, mapped_lvl18$percEph_tokunga), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment='main'),
  
  tar_combine(combined_percEph_firstOrder, list(mapped_lvl0$percEph_firstOrder, mapped_lvl1$percEph_firstOrder, mapped_lvl2$percEph_firstOrder, mapped_lvl3$percEph_firstOrder, mapped_lvl4$percEph_firstOrder, mapped_lvl5$percEph_firstOrder,
                                             mapped_lvl6$percEph_firstOrder, mapped_lvl7$percEph_firstOrder, mapped_lvl8$percEph_firstOrder, mapped_lvl9$percEph_firstOrder, mapped_lvl10$percEph_firstOrder, mapped_lvl11$percEph_firstOrder,
                                             mapped_lvl12$percEph_firstOrder, mapped_lvl13$percEph_firstOrder, mapped_lvl14$percEph_firstOrder, mapped_lvl15$percEph_firstOrder, mapped_lvl16$percEph_firstOrder, mapped_lvl17$percEph_firstOrder, mapped_lvl18$percEph_firstOrder), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment='main'),
  
  #MAKE FINAL SHAPEFILES WITH RESULTS
  tar_target(shapefile_fin, saveShapefile(path_to_data, codes_huc02, combined_results), deployment='main'), #model results shapefile
  tar_target(val_shapefile_fin, saveValShapefile(path_to_data, codes_huc02, validationResults), deployment='main'), #validation results shapefile (HUC2 level)
  
  #GENERATE MANUSCRIPT FIGURES--------------
  tar_target(fig1, mainFigureFunction(shapefile_fin, rivNetFin_0107, rivNetFin_0701, rivNetFin_1407, rivNetFin_1305), deployment='main'), #fig 1
  tar_target(fig2, streamOrderPlot(combined_results_by_order, combined_results), deployment='main'), #fig 2
  tar_target(fig3, flowingFigureFunction(shapefile_fin, flowingDaysValidation), deployment='main'), #fig 3
   
  #BUILD SUPPLEMENTRY FIGURES
   tar_target(boxplotsClassification, boxPlots_classification(val_shapefile_fin)),
   tar_target(boxPlotsSensitivity, boxPlots_sensitivity(combined_numFlowingDays, combined_numFlowingDays_low, combined_numFlowingDays_high, combined_numFlowingDays_med_low, combined_numFlowingDays_med_high), deployment='main'), #ephemeral flow frequency sensitivity figure
   tar_target(snappingSensitivityFig, snappingSensitivityFigures(compareSnappingThreshs), deployment='main'), #figures for snapping thresh sensitivity analysis
   tar_target(scalingModelFig, buildScalingModelFig(scalingModel), deployment='main'), #figures for snapping thresh sensitivity analysis
   tar_target(flowingDaysCalibrateFig, runoffThreshCalibPlot(flowingDaysCalibrate)), #figure for empirical runoff threshold calibration
   tar_target(validationPlotMain, validationPlot(combined_percEph_tokunga, USGS_data, nhdGages, ephemeralQDataset, walnutGulch, val_shapefile_fin), deployment='main'), #uses only USGS ephemeral gages on the NHD
   tar_target(validationMap, mappingValidationFigure(val_shapefile_fin), deployment='main'),
   tar_target(validationMap2, mappingValidationFigure2(val_shapefile_fin), deployment='main'),
   tar_target(drainageAreaMap, areaMapFunction(shapefile_fin), deployment='main'), #fig 3new
   tar_target(comboHydrographyMaps, hydrographyFigure(shapefile_fin, rivNetFin_0108, rivNetFin_1023, rivNetFin_0313, rivNetFin_1503,
                                                      rivNetFin_1306, rivNetFin_0804, rivNetFin_0501, rivNetFin_1703,
                                                      rivNetFin_0703, rivNetFin_0304, rivNetFin_1605, rivNetFin_1507,
                                                      rivNetFin_0317, rivNetFin_0506, rivNetFin_0103, rivNetFin_1709), deployment='main'),
  tar_target(walnutGulch, walnutGulchQualitative(rivNetFin_1505, path_to_data), deployment='main'),

  #GENERATE GUIDE TO DATA/MODEL INPUTS
  tar_render(data_guide, "docs/data_guide.Rmd", deployment='main') #data guide
)
