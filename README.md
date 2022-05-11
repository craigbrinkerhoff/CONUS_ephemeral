# The Influence of Ephemeral Streams Across the United States
How much river flow is lost to regulation via the Clean Water Act under the Trump-era Navigable Waters Protection Rule?

## Background
In 2020, The Trump administration passed the 'Navigable Waters Protection Act' (NWPA) to define the waters of the United States (WOTUS). WOTUS serves as the definition for waters which fall under Clean Water Act jurisdiction and enable broad freshwater conservation. Previously, there was no clear definition of WOTUS and so the EPA took a liberal approach to defining the WOTUS in order to facilitate broader freshwater conservation.

The Trump-era ruling makes clear these definitions, but explicitly removes 'ephemeral' streams from Clean Water Act jurisdiction. Notably, 'intermittent' streams are still protected. The NWPA is currently at the Supreme Court.

The distinction being made is that 'ephemeral' streams only flow due directly to precipitation events, i.e. they have no baseflow and only support advection of precipitation and not groundwater. 'Intermittent' streams, however, are a byproduct of a seasonally-fluctuating water table such that they episodically run dry, but still have a baseflow signal.

Here, we are interested in modeling how much water (and river network) will lose Clean Water Act regulation under this new ruling.

## Workflow
- This analysis uses `targets` to pipeline the entire workflow and ensure complete reproducibility. For more on using `targets` for reproducible workflows, see [here](https://books.ropensci.org/targets/).

- To run the analysis in serial, execute `tar_make()` from within the project repo. `tar_watch()` will enable a Shiny app to track progress as the analysis is performed. Inputs and setup are designated as a workflow in the `_targets.R` script. Specify the level 4 HUC basins to run using the `huc4` object within the `values` tibble.

- While this repo has not been setup to run in parallel across nodes on an HPC, it was built to run across cores on a single node within an HPC. To do this, make sure that the `clustermq` package is installed and use `tar_make_clustermq(workers = 24)` with your desired number of cores.

- To view a proper workflow dependency chart, execute `tar_visnetwork()`.

- The `src/aggregate.R` script will aggregate results stored as target objects into summary data frames and shapefiles (outside of the pipline) and build figures too. These shapefiles are then used in QGIS to build the maps.


## Note
- Make sure your working directory is set to the project repo!!!

- This analysis uses the `renv` package for reproducibility. It creates a private library of R packages, snapshotted at specific versions so that near complete reproducibility is possible.

- `renv` is used to build R libraries for `R 4.1.2`. Only this version of R is guaranteed to work.

- Note that the data is stored in another repo. While the user specifies the path to this repo within `_targets.R`, there are also hard-coded sub-directories within that repo. Check the functions in `src/analysis.R` to make sure you set up the folder structure correctly.

- Use `src/shapefiles.R` to create HUC2 shapefiles with results

- Use `src/hydrographCheck.R` to plot hydrographs that were ID'd as 'ephemeral' as a gut check
