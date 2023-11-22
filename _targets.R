# _targets.R file
## Craig Brinkerhoff
## This is the master pipeline

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
source('src/validation_wtd.R')
source('src/uncertaintyAnalysis.R')

plan(batchtools_slurm, template = "slurm_future.tmpl") #for parallelization via futures transient workers
#options(clustermq.scheduler = 'slurm', clustermq.template = "slurm_clustermq.tmpl") #for parallelization via clustermq persistent workers
tar_option_set(packages = c('terra', 'sf', 'dplyr', 'readr', 'ggplot2', 'cowplot', 'dataRetrieval', 'clustermq', 'scales', 'tidyr', 'patchwork', 'ggsflabel', 'ggspatial', 'ggrepel', 'captioner')) #set up packages to load in. Some packages are manually specified throughout

#############USER INPUTS-------------------
#meta parameters
path_to_data <- '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data' #path to data repo (separate from code repo)
codes_huc02 <- c('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18') #HUC2 regions to get gauge data.
lookUpTable <- readr::read_csv('data/HUC4_lookup.csv') #basin routing lookup table (manually verified)
usgs_eph_sites <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/flowingDays_data/usgs_gages_eph.csv')) #USGS gauges that are 'ephemeral' per USGS reports. Manual QAQC was done to these to identify mis-classified rivers (see ~docs/README_usgs_eph_gages.md)

#ephemeral mapping parameters
threshold <- -0.01 #[m] buffer of 1cm depth to capture the free surface
error <- 0 #[NOT USED] if you wanted to add a bit of an error tolerance to ephemeral classification. Not used in paper results.

#ephemeral mapping validation parameters
noFlowGageThresh <- 0.05 #[percent] maximum no flow fraction for streamgauges that are considered 'certainly not ephemeral'
snappingThresh <- 10 #[m] see compareSnappingThreshs() for output that informs this parameter setting

#flowing days parameters
runoffEffScalar_low <- -0.33 #runoffEffScalar_x [percent] sensitivity parameter to use to perturb Nflw sensitivity to runoff efficiency: % of runoff ratio to add or subtract
runoffEffScalar_med_low <- -0.18
runoffEffScalar_high <- 0.33
runoffEffScalar_med_high <- 0.18
runoffEffScalar_real <- 0

runoffMemory_real <- 4 #[dys] bulk memory parameter that represents delayed arrival of streamflow (lumped to represent all mechanisms- Hortonian, Dunnian, and/or interflow). Informed by https://doi.org/10.1029/2021WR030186

#New England field sites data (most other data is accessed from within function calls FYI)
field_dataset <- readr::read_csv(paste0(path_to_data, '/for_ephemeral_project/new_england_fieldSites.csv')) #our in situ ephemeral classifications in northeastern US

#for Monte Carlo dynamic branching uncertainty analysis
set.seed(546)

#### SETUP STATIC BRANCHING FOR PARALLEL ROUTING WITHIN PROCESSING LEVELS-----------------------------------------------------
#Headwater basins that export into the next level of basins
mapped_lvl0 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 0,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4, validated_Hb)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, NA)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays, datesFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution paired with IDs for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order and headwater streams that are ephemeral
      tar_target(percEph_tokunaga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunaga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral validation reaches
  tar_target(hydroMap, hydrographyFigureSmall(path_to_data, shapefile_fin, rivNetFin, huc4)), #build hydrography map for the basin
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
      tar_target(datesFlowingDays, calcDatesFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate mean flowing month
      tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate number of flowing days
      tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_low, runoffMemory_real)), #calculate number of flowing days under low runoff scenario
      tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_high, runoffMemory_real)), #calculate number of flowing days under high runoff scenario
      tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_low, runoffMemory_real)), #calculate number of flowing days under med-low runoff scenario
      tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_high, runoffMemory_real)), #calculate number of flowing days under med-high runoff scenario
  tar_target(meanLengthKM, getMeanReachLen(rivNetFin, huc4)), #calculate mean reach length [km] by basin
  tar_target(written, exportResults(rivNetFin, huc4)) #write model results to file
)


# #level 1 downstream basins
mapped_lvl1 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 1,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4, validated_Hb)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, exported_percEph_lvl0)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays, datesFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution paired with IDs for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order and headwater streams that are ephemeral
      tar_target(percEph_tokunaga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunaga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral validation reaches
  tar_target(hydroMap, hydrographyFigureSmall(path_to_data, shapefile_fin, rivNetFin, huc4)), #build hydrography map for the basin
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
      tar_target(datesFlowingDays, calcDatesFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate mean flowing month
      tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate number of flowing days
      tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_low, runoffMemory_real)), # calculate number of flowing days under low runoff scenario
      tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_high, runoffMemory_real)), #calculate number of flowing days under high runoff scenario
      tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_low, runoffMemory_real)), #calculate number of flowing days under med-low runoff scenario
      tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_high, runoffMemory_real)), #calculate number of flowing days under med-high runoff scenario
  tar_target(meanLengthKM, getMeanReachLen(rivNetFin, huc4)), #calculate mean reach length [km] by basin
  tar_target(written, exportResults(rivNetFin, huc4)) #write model results to file
)

#level 2 downstream basins
mapped_lvl2 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 2,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4, validated_Hb)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, exported_percEph_lvl1)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays, datesFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution paired with IDs for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order and headwater streams that are ephemeral
      tar_target(percEph_tokunaga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunaga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral validation reaches
  tar_target(hydroMap, hydrographyFigureSmall(path_to_data, shapefile_fin, rivNetFin, huc4)), #build hydrography map for the basin
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
      tar_target(datesFlowingDays, calcDatesFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate mean flowing month
      tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate number of flowing days
      tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_low, runoffMemory_real)), #calculate number of flowing days under low runoff scenario
      tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_high, runoffMemory_real)), #calculate number of flowing days under high runoff scenario
      tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_low, runoffMemory_real)), #calculate number of flowing days under med-low runoff scenario
      tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_high, runoffMemory_real)), #calculate number of flowing days under med-high runoff scenario
  tar_target(meanLengthKM, getMeanReachLen(rivNetFin, huc4)), #calculate mean reach length [km] by basin
  tar_target(written, exportResults(rivNetFin, huc4)) #write model results to file
)

#level 3 downstream basins
mapped_lvl3 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 3,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4, validated_Hb)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, exported_percEph_lvl2)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays, datesFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution paired with IDs for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order and headwater streams that are ephemeral
      tar_target(percEph_tokunaga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunaga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral validation reaches
  tar_target(hydroMap, hydrographyFigureSmall(path_to_data, shapefile_fin, rivNetFin, huc4)), #build hydrography map for the basin
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
      tar_target(datesFlowingDays, calcDatesFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate mean flowing month
      tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate number of flowing days
      tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_low, runoffMemory_real)), #calculate number of flowing days under low runoff scenario
      tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_high, runoffMemory_real)), #calculate number of flowing days under high runoff scenario
      tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_low, runoffMemory_real)), #calculate number of flowing days under med-low runoff scenario
      tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_high, runoffMemory_real)), #calculate number of flowing days under med-high runoff scenario
  tar_target(meanLengthKM, getMeanReachLen(rivNetFin, huc4)), #calculate mean reach length [km] by basin
  tar_target(written, exportResults(rivNetFin, huc4)) #write model results to file
)

#level 4 downstream basins
mapped_lvl4 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 4,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4, validated_Hb)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, exported_percEph_lvl3)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays, datesFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution paired with IDs for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order and headwater streams that are ephemeral
      tar_target(percEph_tokunaga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunaga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral validation reaches
  tar_target(hydroMap, hydrographyFigureSmall(path_to_data, shapefile_fin, rivNetFin, huc4)), #build hydrography map for the basin
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
      tar_target(datesFlowingDays, calcDatesFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate mean flowing month
      tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate number of flowing days
      tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_low, runoffMemory_real)), #calculate number of flowing days under low runoff scenario
      tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_high, runoffMemory_real)), #calculate number of flowing days under high runoff scenario
      tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_low, runoffMemory_real)), #calculate number of flowing days under med-low runoff scenario
      tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_high, runoffMemory_real)), #calculate number of flowing days under med-high runoff scenario
  tar_target(meanLengthKM, getMeanReachLen(rivNetFin, huc4)), #calculate mean reach length [km] by basin
  tar_target(written, exportResults(rivNetFin, huc4)) #write model results to file
)

#level 5 downstream basins
mapped_lvl5 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 5,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4, validated_Hb)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, exported_percEph_lvl4)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays, datesFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution paired with IDs for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order and headwater streams that are ephemeral
      tar_target(percEph_tokunaga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunaga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral validation reaches
  tar_target(hydroMap, hydrographyFigureSmall(path_to_data, shapefile_fin, rivNetFin, huc4)), #build hydrography map for the basin
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
      tar_target(datesFlowingDays, calcDatesFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate mean flowing month
      tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate number of flowing days
      tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_low, runoffMemory_real)), #calculate number of flowing days under low runoff scenario
      tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_high, runoffMemory_real)), #calculate number of flowing days under high runoff scenario
      tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_low, runoffMemory_real)), #calculate number of flowing days under med-low runoff scenario
      tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_high, runoffMemory_real)), #calculate number of flowing days under med-high runoff scenario
  tar_target(meanLengthKM, getMeanReachLen(rivNetFin, huc4)), #calculate mean reach length [km] by basin
  tar_target(written, exportResults(rivNetFin, huc4)) #write model results to file
)

#level 6 downstream basins
mapped_lvl6 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 6,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4, validated_Hb)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, exported_percEph_lvl5)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays, datesFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution paired with IDs for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order and headwater streams that are ephemeral
      tar_target(percEph_tokunaga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunaga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral validation reaches
  tar_target(hydroMap, hydrographyFigureSmall(path_to_data, shapefile_fin, rivNetFin, huc4)), #build hydrography map for the basin
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
      tar_target(datesFlowingDays, calcDatesFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate mean flowing month
      tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate number of flowing days
      tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_low, runoffMemory_real)), #calculate number of flowing days under low runoff scenario
      tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_high, runoffMemory_real)), #calculate number of flowing days under high runoff scenario
      tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_low, runoffMemory_real)), #calculate number of flowing days under med-low runoff scenario
      tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_high, runoffMemory_real)), #calculate number of flowing days under med-high runoff scenario
  tar_target(meanLengthKM, getMeanReachLen(rivNetFin, huc4)), #calculate mean reach length [km] by basin
  tar_target(written, exportResults(rivNetFin, huc4)) #write model results to file
)

#level 7 downstream basins
mapped_lvl7 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 7,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4, validated_Hb)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, exported_percEph_lvl6)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays, datesFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution paired with IDs for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order and headwater streams that are ephemeral
      tar_target(percEph_tokunaga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunaga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral validation reaches
  tar_target(hydroMap, hydrographyFigureSmall(path_to_data, shapefile_fin, rivNetFin, huc4)), #build hydrography map for the basin
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
      tar_target(datesFlowingDays, calcDatesFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate mean flowing month
      tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate number of flowing days
      tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_low, runoffMemory_real)), #calculate number of flowing days under low runoff scenario
      tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_high, runoffMemory_real)), #calculate number of flowing days under high runoff scenario
      tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_low, runoffMemory_real)), #calculate number of flowing days under med-low runoff scenario
      tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_high, runoffMemory_real)), #calculate number of flowing days under med-high runoff scenario
  tar_target(meanLengthKM, getMeanReachLen(rivNetFin, huc4)), #calculate mean reach length [km] by basin
  tar_target(written, exportResults(rivNetFin, huc4)) #write model results to file
)

#level 8 downstream basins
mapped_lvl8 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 8,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4, validated_Hb)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, exported_percEph_lvl7)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays, datesFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution paired with IDs for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order and headwater streams that are ephemeral
      tar_target(percEph_tokunaga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunaga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral validation reaches
  tar_target(hydroMap, hydrographyFigureSmall(path_to_data, shapefile_fin, rivNetFin, huc4)), #build hydrography map for the basin
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
      tar_target(datesFlowingDays, calcDatesFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate mean flowing month
      tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate number of flowing days
      tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_low, runoffMemory_real)), #calculate number of flowing days under low runoff scenario
      tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_high, runoffMemory_real)), #calculate number of flowing days under high runoff scenario
      tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_low, runoffMemory_real)), #calculate number of flowing days under med-low runoff scenario
      tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_high, runoffMemory_real)), #calculate number of flowing days under med-high runoff scenario
  tar_target(meanLengthKM, getMeanReachLen(rivNetFin, huc4)), #calculate mean reach length [km] by basin
  tar_target(written, exportResults(rivNetFin, huc4)) #write model results to file
)


#level 9 downstream basins
mapped_lvl9 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 9,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4, validated_Hb)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, exported_percEph_lvl8)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays, datesFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution paired with IDs for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order and headwater streams that are ephemeral
      tar_target(percEph_tokunaga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunaga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral validation reaches
  tar_target(hydroMap, hydrographyFigureSmall(path_to_data, shapefile_fin, rivNetFin, huc4)), #build hydrography map for the basin
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
      tar_target(datesFlowingDays, calcDatesFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate mean flowing month
      tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate number of flowing days
      tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_low, runoffMemory_real)), #calculate number of flowing days under low runoff scenario
      tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_high, runoffMemory_real)), #calculate number of flowing days under high runoff scenario
      tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_low, runoffMemory_real)), #calculate number of flowing days under med-low runoff scenario
      tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_high, runoffMemory_real)), #calculate number of flowing days under med-high runoff scenario
  tar_target(meanLengthKM, getMeanReachLen(rivNetFin, huc4)), #calculate mean reach length [km] by basin
  tar_target(written, exportResults(rivNetFin, huc4)) #write model results to file
)


#level 10 downstream basins
mapped_lvl10 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 10,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4, validated_Hb)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, exported_percEph_lvl9)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays, datesFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution paired with IDs for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order and headwater streams that are ephemeral
      tar_target(percEph_tokunaga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunaga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral validation reaches
  tar_target(hydroMap, hydrographyFigureSmall(path_to_data, shapefile_fin, rivNetFin, huc4)), #build hydrography map for the basin
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
      tar_target(datesFlowingDays, calcDatesFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate mean flowing month
      tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate number of flowing days
      tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_low, runoffMemory_real)), #calculate number of flowing days under low runoff scenario
      tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_high, runoffMemory_real)), #calculate number of flowing days under high runoff scenario
      tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_low, runoffMemory_real)), #calculate number of flowing days under med-low runoff scenario
      tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_high, runoffMemory_real)), #calculate number of flowing days under med-high runoff scenario
  tar_target(meanLengthKM, getMeanReachLen(rivNetFin, huc4)), #calculate mean reach length [km] by basin
  tar_target(written, exportResults(rivNetFin, huc4)) #write model results to file
)


#level 11 downstream basins
mapped_lvl11 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 11,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4, validated_Hb)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, exported_percEph_lvl10)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays, datesFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution paired with IDs for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order and headwater streams that are ephemeral
      tar_target(percEph_tokunaga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunaga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral validation reaches
  tar_target(hydroMap, hydrographyFigureSmall(path_to_data, shapefile_fin, rivNetFin, huc4)), #build hydrography map for the basin
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
      tar_target(datesFlowingDays, calcDatesFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate mean flowing month
      tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate number of flowing days
      tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_low, runoffMemory_real)), #calculate number of flowing days under low runoff scenario
      tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_high, runoffMemory_real)), #calculate number of flowing days under high runoff scenario
      tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_low, runoffMemory_real)), #calculate number of flowing days under med-low runoff scenario
      tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_high, runoffMemory_real)), #calculate number of flowing days under med-high runoff scenario
  tar_target(meanLengthKM, getMeanReachLen(rivNetFin, huc4)), #calculate mean reach length [km] by basin
  tar_target(written, exportResults(rivNetFin, huc4)) #write model results to file
)


#level 12 downstream basins
mapped_lvl12 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 12,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4, validated_Hb)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, exported_percEph_lvl11)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays, datesFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution paired with IDs for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order and headwater streams that are ephemeral
      tar_target(percEph_tokunaga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunaga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral validation reaches
  tar_target(hydroMap, hydrographyFigureSmall(path_to_data, shapefile_fin, rivNetFin, huc4)), #build hydrography map for the basin
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
      tar_target(datesFlowingDays, calcDatesFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate mean flowing month
      tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate number of flowing days
      tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_low, runoffMemory_real)), #calculate number of flowing days under low runoff scenario
      tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_high, runoffMemory_real)), #calculate number of flowing days under high runoff scenario
      tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_low, runoffMemory_real)), #calculate number of flowing days under med-low runoff scenario
      tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_high, runoffMemory_real)), #calculate number of flowing days under med-high runoff scenario
  tar_target(meanLengthKM, getMeanReachLen(rivNetFin, huc4)), #calculate mean reach length [km] by basin
  tar_target(written, exportResults(rivNetFin, huc4)) #write model results to file
)


#level 13 downstream basins
mapped_lvl13 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 13,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4, validated_Hb)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, exported_percEph_lvl12)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays, datesFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution paired with IDs for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order and headwater streams that are ephemeral
      tar_target(percEph_tokunaga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunaga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral validation reaches
  tar_target(hydroMap, hydrographyFigureSmall(path_to_data, shapefile_fin, rivNetFin, huc4)), #build hydrography map for the basin
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
      tar_target(datesFlowingDays, calcDatesFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate mean flowing month
      tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate number of flowing days
      tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_low, runoffMemory_real)), #calculate number of flowing days under low runoff scenario
      tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_high, runoffMemory_real)), #calculate number of flowing days under high runoff scenario
      tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_low, runoffMemory_real)), #calculate number of flowing days under med-low runoff scenario
      tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_high, runoffMemory_real)), #calculate number of flowing days under med-high runoff scenario
  tar_target(meanLengthKM, getMeanReachLen(rivNetFin, huc4)), #calculate mean reach length [km] by basin
  tar_target(written, exportResults(rivNetFin, huc4)) #write model results to file
)


#level 14 downstream basins
mapped_lvl14 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 14,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4, validated_Hb)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, exported_percEph_lvl13)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays, datesFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution paired with IDs for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order and headwater streams that are ephemeral
      tar_target(percEph_tokunaga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunaga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral validation reaches
  tar_target(hydroMap, hydrographyFigureSmall(path_to_data, shapefile_fin, rivNetFin, huc4)), #build hydrography map for the basin
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
      tar_target(datesFlowingDays, calcDatesFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate mean flowing month
      tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate number of flowing days
      tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_low, runoffMemory_real)), #calculate number of flowing days under low runoff scenario
      tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_high, runoffMemory_real)), #calculate number of flowing days under high runoff scenario
      tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_low, runoffMemory_real)), #calculate number of flowing days under med-low runoff scenario
      tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_high, runoffMemory_real)), #calculate number of flowing days under med-high runoff scenario
  tar_target(meanLengthKM, getMeanReachLen(rivNetFin, huc4)), #calculate mean reach length [km] by basin
  tar_target(written, exportResults(rivNetFin, huc4)) #write model results to file
)


#level 15 downstream basins
mapped_lvl15 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 15,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4, validated_Hb)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, exported_percEph_lvl14)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays, datesFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution paired with IDs for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order and headwater streams that are ephemeral
      tar_target(percEph_tokunaga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunaga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral validation reaches
  tar_target(hydroMap, hydrographyFigureSmall(path_to_data, shapefile_fin, rivNetFin, huc4)), #build hydrography map for the basin
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
      tar_target(datesFlowingDays, calcDatesFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate mean flowing month
      tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate number of flowing days
      tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_low, runoffMemory_real)), #calculate number of flowing days under low runoff scenario
      tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_high, runoffMemory_real)), #calculate number of flowing days under high runoff scenario
      tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_low, runoffMemory_real)), #calculate number of flowing days under med-low runoff scenario
      tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_high, runoffMemory_real)), #calculate number of flowing days under med-high runoff scenario
  tar_target(meanLengthKM, getMeanReachLen(rivNetFin, huc4)), #calculate mean reach length [km] by basin
  tar_target(written, exportResults(rivNetFin, huc4)) #write model results to file
)


#level 16 downstream basins
mapped_lvl16 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 16,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4, validated_Hb)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, exported_percEph_lvl15)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays, datesFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution paired with IDs for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order and headwater streams that are ephemeral
      tar_target(percEph_tokunaga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunaga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral validation reaches
  tar_target(hydroMap, hydrographyFigureSmall(path_to_data, shapefile_fin, rivNetFin, huc4)), #build hydrography map for the basin
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
      tar_target(datesFlowingDays, calcDatesFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate mean flowing month
      tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate number of flowing days
      tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_low, runoffMemory_real)), #calculate number of flowing days under low runoff scenario
      tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_high, runoffMemory_real)), #calculate number of flowing days under high runoff scenario
      tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_low, runoffMemory_real)), #calculate number of flowing days under med-low runoff scenario
      tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_high, runoffMemory_real)), #calculate number of flowing days under med-high runoff scenario
  tar_target(meanLengthKM, getMeanReachLen(rivNetFin, huc4)), #calculate mean reach length [km] by basin
  tar_target(written, exportResults(rivNetFin, huc4)) #write model results to file
)


#level 17 downstream basins
mapped_lvl17 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 17,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4, validated_Hb)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, exported_percEph_lvl16)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays, datesFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution paired with IDs for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order and headwater streams that are ephemeral
      tar_target(percEph_tokunaga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunaga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral validation reaches
  tar_target(hydroMap, hydrographyFigureSmall(path_to_data, shapefile_fin, rivNetFin, huc4)), #build hydrography map for the basin
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
      tar_target(datesFlowingDays, calcDatesFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate mean flowing month
      tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate number of flowing days
      tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_low, runoffMemory_real)), #calculate number of flowing days under low runoff scenario
      tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_high, runoffMemory_real)), #calculate number of flowing days under high runoff scenario
      tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_low, runoffMemory_real)), #calculate number of flowing days under med-low runoff scenario
      tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_high, runoffMemory_real)), #calculate number of flowing days under med-high runoff scenario
  tar_target(meanLengthKM, getMeanReachLen(rivNetFin, huc4)), #calculate mean reach length [km] by basin
  tar_target(written, exportResults(rivNetFin, huc4)) #write model results to file
)


#level 18 downstream basins
mapped_lvl18 <- tar_map(
  unlist=FALSE,
  values = tibble(
    method_function = rlang::syms("extractData"),
    huc4 = lookUpTable[lookUpTable$level == 18,]$HUC4,
  ),
  names = "huc4",
  tar_target(extractedRivNet, method_function(path_to_data, huc4, validated_Hb)), #extract water table depths along river reaches
      tar_target(rivNetFin, routeModel(extractedRivNet, huc4, threshold, error, exported_percEph_lvl17)), #calculate perenniality
  tar_target(results, getResultsExported(rivNetFin, huc4, numFlowingDays, datesFlowingDays)), #get results at basin exporting reaches
      tar_target(results_by_order, getResultsByOrder(rivNetFin, huc4)), #get results by stream order
      tar_target(exported_percEph, getExportedQ(rivNetFin, huc4, lookUpTable)), #get exported ephemeral contribution paired with IDs for basins downstream
      tar_target(percEph_firstOrder, ephemeralFirstOrder(rivNetFin, huc4)), #get percent of first order and headwater streams that are ephemeral
      tar_target(percEph_tokunaga, tokunaga_eph(rivNetFin, results, huc4)), #get ephemeral contribution via tokunaga scaling
  tar_target(snappedValidation, snapValidateToNetwork(path_to_data, validationDF, USGS_data, nhdGages, rivNetFin, huc4, noFlowGageThresh)), #setup ephemeral validation reaches
  tar_target(hydroMap, hydrographyFigureSmall(path_to_data, shapefile_fin, rivNetFin, huc4)), #build hydrography map for the basin
  tar_target(runoffEff, calcRunoffEff(path_to_data, huc4)), #runoff efficiency calculation
      tar_target(datesFlowingDays, calcDatesFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate mean flowing month
      tar_target(numFlowingDays, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_real, runoffMemory_real)), #calculate number of flowing days
      tar_target(numFlowingDays_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_low, runoffMemory_real)), #calculate number of flowing days under low runoff scenario
      tar_target(numFlowingDays_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_high, runoffMemory_real)), #calculate number of flowing days under high runoff scenario
      tar_target(numFlowingDays_med_low, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_low, runoffMemory_real)), #calculate number of flowing days under med-low runoff scenario
      tar_target(numFlowingDays_med_high, calcFlowingDays(path_to_data, huc4, runoffEff, flowingDaysCalibrate$thresh, runoffEffScalar_med_high, runoffMemory_real)), #calculate number of flowing days under med-high runoff scenario
  tar_target(meanLengthKM, getMeanReachLen(rivNetFin, huc4)), #calculate mean reach length [km] by basin
  tar_target(written, exportResults(rivNetFin, huc4)) #write model results to file
)





####ACTUAL PIPELINE
list(
  #GATHER, PREP, AND VALIDATE MODEL COMPONENTS USING IN SITU DATA------------------
  #EPHEMERAL CLASSIFICATION MODEL
  tar_target(validationDF, prepValDF(path_to_data)), #clean and prep WOTUS EPA in situ ephemeral classifications (and USGS streamgauges)
  tar_target(ourFieldData, addOurFieldData(rivNetFin_0106, rivNetFin_0108, path_to_data, field_dataset)), #clean and prep our in situ classified streams in northeast US
  tar_target(validationResults, validateModel(combined_validation, ourFieldData, snappingThresh), deployment='main'), #validate across all three datasets
  
  ##DISCHARGE MODEL
  tar_target(nhdGages, getNHDGages(path_to_data, codes_huc02)), #find gauges joined to NHD-HR a priori (used for discharge validation)
  tar_target(USGS_data, getGageData(path_to_data, nhdGages, codes_huc02)), #calculate mean observed flow 1970-2018 per gauge to validate discharge model
  tar_target(ephemeralQDataset_all, wrangleUSGSephGages(usgs_eph_sites)), #get mean annual flow for USGS ephemeral gauges to validate discharge model
  tar_target(checkUSGSephHydrographs, ephemeralityChecker(usgs_eph_sites)), #builds hydrographs for USGS 'ephemeral' gauges to aid in manual QAQC of these data
  tar_target(ephemeralQDataset, setupEphemeralQValidation(path_to_data, walnutGulch$df, ephemeralQDataset_all, rivNetFin_1008, rivNetFin_1009, rivNetFin_1012, rivNetFin_1404, rivNetFin_1408, rivNetFin_1405, rivNetFin_1507, rivNetFin_1506,rivNetFin_1809, rivNetFin_1501,rivNetFin_1503,rivNetFin_1606,rivNetFin_1302,rivNetFin_1306,rivNetFin_1303,rivNetFin_1305), deployment='main'), #gather and prep Nflw data from USGS ephemeral gauges 

  ##VALIDATE GROUNDWATER MODEL
  tar_target(conus_wells, getWellDepths(codes_huc02)), #get USGS NWIS well depths and summarize to mean monthly depths
  tar_target(gauge_wtds, getGaugewtd(USGS_data)), #get permanently flowing gauges (i.e. wtd approximates 0)
  tar_target(validated_wells, join_wtd(path_to_data, conus_wells, gauge_wtds)), #validated model and build figure

  ##VALIDATE BANKFULL DEPTH MODELS
  tar_target(validated_Hb, validateHb()), #validate bakfull depth models using in situ bankfull depth measurements

  #Nflw MODEL
  tar_target(flowingFieldData, wrangleFlowingFieldData(path_to_data, ephemeralQDataset_all)), #gather and prep Nflw data from 1) field studies and 2) USGS ephemeral gauges
  tar_target(flowingDaysValidation, flowingValidate(flowingFieldData, path_to_data, codes_huc02,combined_results, combined_runoffEff)), #verifies Nflw model on all data from field studies and streamgauges
  tar_target(flowingDaysCalibrate, flowingValidateSensitivityWrapper(flowingFieldData, runoffEffScalar_real, runoffMemory_real, c(0.001, 0.005,0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.50, 0.75, 1, 2.5, 5, 10, 50), path_to_data, combined_runoffEff)), #calibration procedure for operational runoff threshold (i_min)
  
  #SNAPPING PARAMETER ANALYSIS
  tar_target(compareSnappingThreshs, snappingSensitivityWrapper(c(5,10,15,20,25,30,35,40,45,50), combined_validation, ourFieldData)), #test a range of snapping thresholds on ephemeral classification accuracy
  tar_target(scalingModel, scalingFunc(validationResults)), #calculate how many additional ephemeral orders we should have (via Hortonian scaling)
  
  ####PARALLEL MODEL RUNS WITHIN EACH PROCESSING LEVEL----------------------------
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

  #AGGREGATE BY-BASIN RESULTS-----------------
  tar_combine(combined_results, list(mapped_lvl0$results, mapped_lvl1$results, mapped_lvl2$results, mapped_lvl3$results, mapped_lvl4$results, mapped_lvl5$results, mapped_lvl6$results,
                                     mapped_lvl7$results, mapped_lvl8$results, mapped_lvl9$results, mapped_lvl10$results, mapped_lvl11$results, mapped_lvl12$results, mapped_lvl13$results,
                                     mapped_lvl14$results, mapped_lvl15$results, mapped_lvl16$results, mapped_lvl17$results, mapped_lvl18$results), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment='main'), #aggregate model targets across branches
 
  tar_combine(combined_results_by_order, list(mapped_lvl0$results_by_order, mapped_lvl1$results_by_order, mapped_lvl2$results_by_order, mapped_lvl3$results_by_order, mapped_lvl4$results_by_order, mapped_lvl5$results_by_order, mapped_lvl6$results_by_order,
                                    mapped_lvl7$results_by_order, mapped_lvl8$results_by_order, mapped_lvl9$results_by_order, mapped_lvl10$results_by_order, mapped_lvl11$results_by_order, mapped_lvl12$results_by_order, mapped_lvl13$results_by_order,
                                    mapped_lvl14$results_by_order, mapped_lvl15$results_by_order, mapped_lvl16$results_by_order, mapped_lvl17$results_by_order, mapped_lvl18$results_by_order), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment='main'), #aggregate model targets across branches
  
  tar_combine(combined_validation, list(mapped_lvl0$snappedValidation, mapped_lvl1$snappedValidation, mapped_lvl2$snappedValidation, mapped_lvl3$snappedValidation, mapped_lvl4$snappedValidation,
                                        mapped_lvl5$snappedValidation, mapped_lvl6$snappedValidation, mapped_lvl7$snappedValidation, mapped_lvl8$snappedValidation, mapped_lvl9$snappedValidation,
                                        mapped_lvl10$snappedValidation, mapped_lvl11$snappedValidation, mapped_lvl12$snappedValidation, mapped_lvl13$snappedValidation, mapped_lvl14$snappedValidation,
                                        mapped_lvl15$snappedValidation, mapped_lvl16$snappedValidation, mapped_lvl17$snappedValidation, mapped_lvl18$snappedValidation), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment='main'), #aggregate model targets across branches
  
  tar_combine(combined_runoffEff, list(mapped_lvl0$runoffEff, mapped_lvl1$runoffEff, mapped_lvl2$runoffEff, mapped_lvl3$runoffEff, mapped_lvl4$runoffEff, mapped_lvl5$runoffEff,
                                       mapped_lvl6$runoffEff, mapped_lvl7$runoffEff, mapped_lvl8$runoffEff, mapped_lvl9$runoffEff, mapped_lvl10$runoffEff, mapped_lvl11$runoffEff,
                                       mapped_lvl12$runoffEff, mapped_lvl13$runoffEff, mapped_lvl14$runoffEff, mapped_lvl15$runoffEff, mapped_lvl16$runoffEff, mapped_lvl17$runoffEff, mapped_lvl18$runoffEff), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment='main'), #aggregate model targets across branches

  tar_combine(combined_datesFlowingDays, list(mapped_lvl0$datesFlowingDays, mapped_lvl1$datesFlowingDays, mapped_lvl2$datesFlowingDays, mapped_lvl3$datesFlowingDays, mapped_lvl4$datesFlowingDays, mapped_lvl5$datesFlowingDays,
                                            mapped_lvl6$datesFlowingDays, mapped_lvl7$datesFlowingDays, mapped_lvl8$datesFlowingDays, mapped_lvl9$datesFlowingDays, mapped_lvl10$datesFlowingDays, mapped_lvl11$datesFlowingDays,
                                            mapped_lvl12$datesFlowingDays, mapped_lvl13$datesFlowingDays, mapped_lvl14$datesFlowingDays, mapped_lvl15$datesFlowingDays, mapped_lvl16$datesFlowingDays, mapped_lvl17$datesFlowingDays, mapped_lvl18$datesFlowingDays), command = c(!!!.x), deployment='main'), #aggregate model targets across branches

  tar_combine(combined_numFlowingDays, list(mapped_lvl0$numFlowingDays, mapped_lvl1$numFlowingDays, mapped_lvl2$numFlowingDays, mapped_lvl3$numFlowingDays, mapped_lvl4$numFlowingDays, mapped_lvl5$numFlowingDays,
                                            mapped_lvl6$numFlowingDays, mapped_lvl7$numFlowingDays, mapped_lvl8$numFlowingDays, mapped_lvl9$numFlowingDays, mapped_lvl10$numFlowingDays, mapped_lvl11$numFlowingDays,
                                            mapped_lvl12$numFlowingDays, mapped_lvl13$numFlowingDays, mapped_lvl14$numFlowingDays, mapped_lvl15$numFlowingDays, mapped_lvl16$numFlowingDays, mapped_lvl17$numFlowingDays, mapped_lvl18$numFlowingDays), command = c(!!!.x), deployment='main'), #aggregate model targets across branches

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

  tar_combine(combined_percEph_tokunaga, list(mapped_lvl0$percEph_tokunaga, mapped_lvl1$percEph_tokunaga, mapped_lvl2$percEph_tokunaga, mapped_lvl3$percEph_tokunaga, mapped_lvl4$percEph_tokunaga, mapped_lvl5$percEph_tokunaga,
                                                   mapped_lvl6$percEph_tokunaga, mapped_lvl7$percEph_tokunaga, mapped_lvl8$percEph_tokunaga, mapped_lvl9$percEph_tokunaga, mapped_lvl10$percEph_tokunaga, mapped_lvl11$percEph_tokunaga,
                                                   mapped_lvl12$percEph_tokunaga, mapped_lvl13$percEph_tokunaga, mapped_lvl14$percEph_tokunaga, mapped_lvl15$percEph_tokunaga, mapped_lvl16$percEph_tokunaga, mapped_lvl17$percEph_tokunaga, mapped_lvl18$percEph_tokunaga), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment='main'),
  
  tar_combine(combined_percEph_firstOrder, list(mapped_lvl0$percEph_firstOrder, mapped_lvl1$percEph_firstOrder, mapped_lvl2$percEph_firstOrder, mapped_lvl3$percEph_firstOrder, mapped_lvl4$percEph_firstOrder, mapped_lvl5$percEph_firstOrder,
                                             mapped_lvl6$percEph_firstOrder, mapped_lvl7$percEph_firstOrder, mapped_lvl8$percEph_firstOrder, mapped_lvl9$percEph_firstOrder, mapped_lvl10$percEph_firstOrder, mapped_lvl11$percEph_firstOrder,
                                             mapped_lvl12$percEph_firstOrder, mapped_lvl13$percEph_firstOrder, mapped_lvl14$percEph_firstOrder, mapped_lvl15$percEph_firstOrder, mapped_lvl16$percEph_firstOrder, mapped_lvl17$percEph_firstOrder, mapped_lvl18$percEph_firstOrder), command = dplyr::bind_rows(!!!.x, .id = "method"), deployment='main'),
  
  tar_combine(combined_meanLengthKM, list(mapped_lvl0$meanLengthKM, mapped_lvl1$meanLengthKM, mapped_lvl2$meanLengthKM, mapped_lvl3$meanLengthKM, mapped_lvl4$meanLengthKM, mapped_lvl5$meanLengthKM,
                                             mapped_lvl6$meanLengthKM, mapped_lvl7$meanLengthKM, mapped_lvl8$meanLengthKM, mapped_lvl9$meanLengthKM, mapped_lvl10$meanLengthKM, mapped_lvl11$meanLengthKM,
                                             mapped_lvl12$meanLengthKM, mapped_lvl13$meanLengthKM, mapped_lvl14$meanLengthKM, mapped_lvl15$meanLengthKM, mapped_lvl16$meanLengthKM, mapped_lvl17$meanLengthKM, mapped_lvl18$meanLengthKM), deployment='main'),
  

  #MAKE FINAL SHAPEFILES WITH RESULTS
  tar_target(shapefile_fin, saveShapefile(path_to_data, codes_huc02, combined_results), deployment='main'), #model results shapefile (HUC4 level)
  tar_target(val_shapefile_fin, saveValShapefile(path_to_data, codes_huc02, validationResults), deployment='main'), #validation results shapefile (HUC2 level)

  #UNCERTAINTY ANALYSIS--------------------------------------
  tar_target(mc_samples, seq(1,1000,1)), #setup 1000 monte carlo runs
  tar_target(mcUncertainty_0107, runMonteCarlo('0107', threshold, error, validated_wells, validated_Hb, mc_samples), pattern=mc_samples), #Merrimack River basin
  tar_target(mcUncertainty_1703, runMonteCarlo('1703', threshold, error, validated_wells,validated_Hb, mc_samples), pattern=mc_samples), #Yakima River basin
  tar_target(mcUncertainty_1402, runMonteCarlo('1402', threshold, error, validated_wells, validated_Hb, mc_samples), pattern=mc_samples), #Gunnison River basin
  tar_target(mcUncertainty_0311, runMonteCarlo('0311', threshold, error, validated_wells,validated_Hb, mc_samples), pattern=mc_samples), #Suwanee River basin
  tar_target(mcUncertainty_1504, runMonteCarlo('1504', threshold, error, validated_wells,validated_Hb, mc_samples), pattern=mc_samples), #Upper Gila River basin
  tar_target(mcUncertaintyResults, uncertaintyFigures(path_to_data, shapefile_fin, mcUncertainty_0107, mcUncertainty_1402, mcUncertainty_1703, mcUncertainty_0311, mcUncertainty_1504), deployment="main"), #uncertainty figures and numbers

  #GENERATE MANUSCRIPT FIGURES--------------
  tar_target(fig1, mainFigureFunction(path_to_data, shapefile_fin, rivNetFin_0107, rivNetFin_0701, rivNetFin_1407, rivNetFin_1305), deployment='main'), #fig 1
  tar_target(fig2, streamOrderPlot(combined_results_by_order, combined_results), deployment='main'), #fig 2
  tar_target(fig3, flowingFigureFunction(path_to_data, shapefile_fin, flowingDaysValidation), deployment='main'), #fig 3
  tar_target(fig4, lengthMapFunction(path_to_data, shapefile_fin), deployment='main'), #fig 4

  #BUILD SUPPLEMENTRY FIGURES (exc. MC and groundwater plots, which were built above)
  tar_target(boxplotsClassification, boxPlots_classification(val_shapefile_fin)), #snapping threshold vs. classification accuracy
  tar_target(boxPlotsSensitivity, boxPlots_sensitivity(combined_numFlowingDays, combined_numFlowingDays_low, combined_numFlowingDays_high, combined_numFlowingDays_med_low, combined_numFlowingDays_med_high), deployment='main'), #Nflw sensitivity
  tar_target(snappingSensitivityFig, snappingSensitivityFigures(compareSnappingThreshs), deployment='main'), #snapping threshold vs Horton scaling
  tar_target(scalingModelFig, buildScalingModelFig(scalingModel), deployment='main'), #Horton scaling model
  tar_target(flowingDaysCalibrateFig, runoffThreshCalibPlot(flowingDaysCalibrate)), #operational runoff threshold calibration
  tar_target(validationPlotMain, validationPlot(path_to_data, combined_percEph_tokunaga, USGS_data, nhdGages, ephemeralQDataset, walnutGulch, val_shapefile_fin), deployment='main'), #primary model validation figure
  tar_target(validationMap, mappingValidationFigure(path_to_data, val_shapefile_fin), deployment='main'), #second set of validation maps
  tar_target(validationMap2, mappingValidationFigure2(path_to_data, val_shapefile_fin), deployment='main'), #third set of validation maps
  tar_target(drainageAreaMap, areaMapFunction(path_to_data, shapefile_fin), deployment='main'), #% ephemeral drainage area map
  tar_target(walnutGulch, walnutGulchQualitative(rivNetFin_1505, path_to_data), deployment='main'), #walnut gulch additional validation figure
  tar_target(meanFlowingMonth, flowingDatesFigureFunction(path_to_data, shapefile_fin), deployment='main'), #average flowing day of the year map
  tar_target(streamOrderPlot_by_physiographicRegion, streamOrderPlotPhysiographic(path_to_data, shapefile_fin, combined_results_by_order, combined_results), deployment='main'), #results by stream order and physiographic region
  tar_target(comboHydrographyMaps_1, comboHydroSmalls(hydroMap_0101, hydroMap_0102, hydroMap_0103, hydroMap_0104,
                                                     hydroMap_0105, hydroMap_0106, hydroMap_0107, hydroMap_0108,
                                                     hydroMap_0109, hydroMap_0110, hydroMap_0202, hydroMap_0203,
                                                     hydroMap_0204, hydroMap_0205, hydroMap_0206, hydroMap_0207,1)), #hydrography map 1
  tar_target(comboHydrographyMaps_2, comboHydroSmalls(hydroMap_0208, hydroMap_0301, hydroMap_0302, hydroMap_0303,
                                                     hydroMap_0304, hydroMap_0305, hydroMap_0306, hydroMap_0307,
                                                     hydroMap_0308, hydroMap_0309, hydroMap_0310, hydroMap_0311,
                                                     hydroMap_0312, hydroMap_0313, hydroMap_0314, hydroMap_0315,2)), #hydrography map 2
  tar_target(comboHydrographyMaps_3, comboHydroSmalls(hydroMap_0316, hydroMap_0317, hydroMap_0318, hydroMap_0401,
                                                     hydroMap_0402, hydroMap_0403, hydroMap_0404, hydroMap_0405,
                                                     hydroMap_0406, hydroMap_0407, hydroMap_0408, hydroMap_0409,
                                                     hydroMap_0410, hydroMap_0411, hydroMap_0412, hydroMap_0413,3)), #hydrography map 3
  tar_target(comboHydrographyMaps_4, comboHydroSmalls(hydroMap_0414, hydroMap_0420, hydroMap_0427, hydroMap_0429,
                                                     hydroMap_0430, hydroMap_0501, hydroMap_0502, hydroMap_0503,
                                                     hydroMap_0504, hydroMap_0505, hydroMap_0506, hydroMap_0507,
                                                     hydroMap_0508, hydroMap_0509, hydroMap_0510, hydroMap_0511,4)), #hydrography map 4
  tar_target(comboHydrographyMaps_5, comboHydroSmalls(hydroMap_0512, hydroMap_0513, hydroMap_0514, hydroMap_0601,
                                                     hydroMap_0602, hydroMap_0603, hydroMap_0604, hydroMap_0701,
                                                     hydroMap_0702, hydroMap_0703, hydroMap_0704, hydroMap_0705,
                                                     hydroMap_0706, hydroMap_0707, hydroMap_0708, hydroMap_0709, 5)), #hydrography map 5
  tar_target(comboHydrographyMaps_6, comboHydroSmalls(hydroMap_0710, hydroMap_0711, hydroMap_0712, hydroMap_0713,
                                                     hydroMap_0714, hydroMap_0801, hydroMap_0802, hydroMap_0803,
                                                     hydroMap_0804, hydroMap_0805, hydroMap_0806, hydroMap_0807,
                                                     hydroMap_0808, hydroMap_0809, hydroMap_0901, hydroMap_0902, 6)), #hydrography map 6
  tar_target(comboHydrographyMaps_7, comboHydroSmalls(hydroMap_0903, hydroMap_0904, hydroMap_1002, hydroMap_1003,
                                                     hydroMap_1004, hydroMap_1005, hydroMap_1006, hydroMap_1007,
                                                     hydroMap_1008, hydroMap_1009, hydroMap_1010, hydroMap_1011,
                                                     hydroMap_1012, hydroMap_1013, hydroMap_1014, hydroMap_1015, 7)), #hydrography map 7
  tar_target(comboHydrographyMaps_8, comboHydroSmalls(hydroMap_1016, hydroMap_1017, hydroMap_1018, hydroMap_1019,
                                                     hydroMap_1020, hydroMap_1021, hydroMap_1022, hydroMap_1023,
                                                     hydroMap_1024, hydroMap_1025, hydroMap_1026, hydroMap_1027,
                                                     hydroMap_1028, hydroMap_1029, hydroMap_1030, hydroMap_1101, 8)), #hydrography map 8
  tar_target(comboHydrographyMaps_9, comboHydroSmalls(hydroMap_1102, hydroMap_1103, hydroMap_1104, hydroMap_1105,
                                                     hydroMap_1106, hydroMap_1107, hydroMap_1108, hydroMap_1109,
                                                     hydroMap_1110, hydroMap_1111, hydroMap_1112, hydroMap_1113,
                                                     hydroMap_1114, hydroMap_1201, hydroMap_1202, hydroMap_1203, 9)), #hydrography map 9
  tar_target(comboHydrographyMaps_10, comboHydroSmalls(hydroMap_1204, hydroMap_1205, hydroMap_1206, hydroMap_1207,
                                                     hydroMap_1208, hydroMap_1209, hydroMap_1210, hydroMap_1211,
                                                     hydroMap_1301, hydroMap_1302, hydroMap_1303, hydroMap_1304,
                                                     hydroMap_1305, hydroMap_1306, hydroMap_1307, hydroMap_1308, 10)), #hydrography map 10
  tar_target(comboHydrographyMaps_11, comboHydroSmalls(hydroMap_1309, hydroMap_1401, hydroMap_1402, hydroMap_1403,
                                                      hydroMap_1404, hydroMap_1405, hydroMap_1406, hydroMap_1407,
                                                      hydroMap_1408, hydroMap_1501, hydroMap_1502, hydroMap_1503,
                                                      hydroMap_1504, hydroMap_1505, hydroMap_1506, hydroMap_1507, 11)), #hydrography map 11
  tar_target(comboHydrographyMaps_12, comboHydroSmalls(hydroMap_1508, hydroMap_1601, hydroMap_1602, hydroMap_1603,
                                                      hydroMap_1604, hydroMap_1605, hydroMap_1606, hydroMap_1701,
                                                      hydroMap_1702, hydroMap_1703, hydroMap_1704, hydroMap_1705,
                                                      hydroMap_1706, hydroMap_1707, hydroMap_1708, hydroMap_1709,12)), #hydrography map 12
  tar_target(comboHydrographyMaps_13, comboHydroSmalls_13(hydroMap_1710, hydroMap_1711, hydroMap_1712, hydroMap_1801,
                                                      hydroMap_1802, hydroMap_1803, hydroMap_1804, hydroMap_1805,
                                                      hydroMap_1806, hydroMap_1807, hydroMap_1808, hydroMap_1809, hydroMap_1810,13)), #hydrography map 13


  #GENERATE SOME DOCS
  tar_render(data_guide, "docs/data_guide.Rmd", deployment='main'), #data guide
  tar_render(README_indiana, "docs/README_indiana.Rmd", deployment='main'), #guide to Indiana pre-processing
  tar_render(README_usgs_eph_gauges, "docs/README_usgs_eph_gauges.Rmd", deployment='main') #Ephemeral gauges data guide
)
