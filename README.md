# The Influence of Ephemeral Streams Across the United States
How much river flow is lost to regulation via the Clean Water Act under the Trump-era Navigable Waters Protection Rule?

## Background
In 2020, The Trump administration passed the 'Navigable Waters Protection Act' (NWPA) to define the waters of the United States (WOTUS). WOTUS serves as the definition for waters which fall under Clean Water Act jurisdiction and enable broad freshwater conservation. Previously, there was no clear definition of WOTUS and so the EPA took a liberal approach to defining the WOTUS in order to facilitate broader freshwater conservation.

The Trump-era ruling makes clear these definitions, but explicitly removes 'ephemeral' streams from Clean Water Act jurisdiction. Notably, 'intermittent' streams are still protected. The NWPA is currently at the Supreme Court.

The distinction being made is that 'ephemeral' streams only flow due directly to precipitation events, i.e. they have no baseflow and only support advection of precipitation and not groundwater. 'Intermittent' streams, however, are a byproduct of a seasonally-fluctuating water table such that they episodically run dry, but still have a baseflow signal.

Here, we are interested in modeling how much water (and river network) will lose Clean Water Act regulation under this new ruling.

## Workflow
- This analysis uses `targets` and static branching to pipeline the entire workflow and ensure complete reproducibility. For more on using `targets` for reproducible workflows, see [here](https://books.ropensci.org/targets/). Inputs and setup are described in the `_targets.R` script.

- To view a proper workflow dependency chart, execute `tar_visnetwork(level_separation=500)`. The result of this is also saved in `docs/dag.html`.

- ### To run
  - **Serial:**  execute `tar_make()` from within the project repo.
  - **Parallel on HPC:** Each HUC4 basin is setup as a pipeline branch and can be submitted as independent jobs via an HPC scheduler and the `clustermq` package. From within a small interactive session (be a good steward and don't use login nodes!!!!), execute `tar_make(clustermq(workers=x))` for however many workers you want.
    - Make sure options is setup correctly in `_targets.R`
    - Job specifications are detailed in `slurm.tmpl`. This only works for a SLURM scheduler.
    - Necessary details on using `clustermq` are [here]('https://mschubert.github.io/clustermq/index.html').

## Note
- This analysis uses the `renv` package for reproducibility. It creates a private library of R packages, snapshotted at specific versions so that near complete reproducibility is possible.

- Follow `conda_setup.md` to reproduce the virtual environment used for this analysis. Note some R packages were installed outside of `renv` because of Linux library access issues when using `renv` within a conda environment...

- Note that the data is stored in another repo. While the user specifies the path to this repo within `_targets.R`, there are also hard-coded sub-directories within that repo. Check the functions in `src/analysis.R` to make sure you set up the folder structure correctly.

- Use `src/shapefiles.R` to create HUC2 shapefiles with results

- Use `src/hydrographCheck.R` to plot hydrographs that were ID'd as 'ephemeral' as a gut check
