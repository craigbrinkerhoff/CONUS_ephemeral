# Quantifying the Impact of the Proposed Navigatable Waters Protection Act on America's Rivers

## Background
In 2020, the Trump administration passed the 'Navigable Waters Protection Act' (NWPA) to "more clearly define" the waters of the United States (WOTUS). WOTUS serves as the definition for waters which fall under Clean Water Act jurisdiction and enable broad freshwater conservation.

The Trump-era ruling makes clear these definitions by explicitly removing 'ephemeral' streams from Clean Water Act jurisdiction. Traditionally navigatble rivers and all of their perennial and intermittent tributaries are still protected, though 'ephemeral' streams which only flow after precipitation events, are not. In *Pascua Yaqui Tribe v. U.S. Environmental Protection Agency*, the legality of the NWPA was questioned and has risen to the United States Supreme Court. Because of this, implementation of the NWPA has currently halted.

Here, we model where these ephemeral streams are across the United States, and quantify the downstream impact that the NWPA would have on streamflow, nitrogen, and phosphorous. See `docs/workflow.tif` for a study overview.

## To run
The workflow (entirely written in R) is executed in parallel across the 100+ basins using the Unity Cluster at the Massachusetts Green High Performance Computing Center. We use `clustermq` as implemented within the `targets` package. Necessary details on using `clustermq` are [here]('https://mschubert.github.io/clustermq/index.html'), which requires the installation of `zeroMQ` libraries for Linux.

## Workflow Notes
- This analysis uses `targets` and static branching to pipeline the entire workflow and ensure complete reproducibility. For more on using `targets` for reproducible workflows, see [here](https://books.ropensci.org/targets/). Model input parameters are described and assigned in the `_targets.R` script.

- To view a proper workflow dependency chart, execute `tar_visnetwork(level_separation=500)`. The result of this is saved in `docs/dag.html`.

- The virtual environment used for the analyses is reproducible using `environment.yml` for the conda environment and `renv.lock` for the private R library used within the conda environment. For more on `renv` see [here](https://rstudio.github.io/renv/).

- Note that the data is stored in another repo. While the user specifies the path to this repo within `_targets.R`, there are also a handful of hard-coded sub-directories out of neceessity. More specifically, check the functions in `src/analysis.R` to make sure you set up the folder structure correctly.
