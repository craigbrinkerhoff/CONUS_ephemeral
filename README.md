# Quantifying the Impact of the Proposed Navigatable Waters Protection Act

## Background
In 2020, The Trump administration passed the 'Navigable Waters Protection Act' (NWPA) to define the waters of the United States (WOTUS). WOTUS serves as the definition for waters which fall under Clean Water Act jurisdiction and enable broad freshwater conservation. Previously, there was no clear definition of WOTUS and so the EPA took a liberal approach to defining the WOTUS in order capture the entire stream-to-ocean continumn

The Trump-era ruling makes clear these definitions by explicitly removing 'ephemeral' streams from Clean Water Act jurisdiction. Notably, 'intermittent' streams are still protected. In *Pascua Yaqui Tribe v. U.S. Environmental Protection Agency*, the legality of the NWPA was questioned and has risen to the United States Supreme Court. Because of this, implementation of the NWPA has currently halted.

Here, we model where these ephemeral streams are across the United States, and quantify the impact that the NWPA would

## To run
The workflow is executed independently for each HUC4 in parallel using `clustermq` SLURM scheduling on the Unity Cluster at the Massachusetts Green High Performance Computing Center. We use `clustermq` as implemented within the `targets` package. Necessary details on using `clustermq` are [here]('https://mschubert.github.io/clustermq/index.html').

## Workflow Notes
- This analysis uses `targets` and static branching to pipeline the entire workflow and ensure complete reproducibility. For more on using `targets` for reproducible workflows, see [here](https://books.ropensci.org/targets/). Inputs and setup are described in the `_targets.R` script.

- To view a proper workflow dependency chart, execute `tar_visnetwork(level_separation=500)`. The result of this is also saved in `docs/dag.html`.

- The virtual environment is reproducible using `environment.yml` for the conda environment and `renv.lock` to reproduce the R package library. For more on `renv` see [here](https://rstudio.github.io/renv/).

- Note that the data is stored in another repo. While the user specifies the path to this repo within `_targets.R`, there are also hard-coded sub-directories within that repo. Check the functions in `src/analysis.R` to make sure you set up the folder structure correctly.
