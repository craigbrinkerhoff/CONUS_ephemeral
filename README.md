# Ephemeral Stream Water Contributions to United States Drainage Networks

This repo contains the pipeline for our assessment of ephemeral streams in the contiguous United States. It uses `targets` to launch (and monitor) a fully reproducible pipeline in `R` on an HPC. For more on using `targets`, see [here](https://books.ropensci.org/targets/). Pipeline parameters are described and assigned in the *_targets.R* script.

We also knit the entire manuscript in `RMarkdown` for reproducibility. Note that the actual target objects are not included and so to do this (or generate any results), you would need to rerun the entire pipeline on an HPC.

## To run
```
conda activate env-CONUS_ephemeral
sbatch run.sh
```

## Manuscript
```
R
render('docs/manuscript/CONUS_ephemeral.Rmd')
```

## Usage notes
Our model was developed for continental-scale analysis, and so we caution against over-interpreting results for individual river reaches. Please see the manuscript for more detail.

## Other notes
- Our package environment uses a private R library (via `renv`) within a `conda` environment because we use many requisite R packages that are only available on github (mostly for generating figures). The virtual environment used for the analysis is reproducible using *environment.yml* and *renv.lock*. For more on `renv` see [here](https://rstudio.github.io/renv/).
      
  - In hindsight, we would have more cleanly installed as many R packages within conda as possible, but this is what we've got!

- Parallel job submissions are abstracted in R using *~src/runTargets.R* and either `future.batchtools` or `clustermq`. Note that some of these tasks require very large amounts of memory and you may have to troubleshoot your resource allocations or restart jobs due to out-of-memory events. This depends on the resources available to you. Below are the job templates we use for a SLURM scheduler:

  - *slurm_clustermq.tmpl*: You will need to install the `zeroMQ` libraries for Linux (included in *environment.yml*)

  - *slurm_future.tmpl*: While `clustermq` is faster than transient worker setups, we found it behaves somewhat inconsistently for the jobs in our pipeline that require huge amounts of memory. We ultimately used `futures.batchtools` instead and suggest it for this pipeline.

- The data is assumed to be stored in another repo (*CONUS_ephemeral_data*). While the user specifies the main path to this repo at the top of *_targets.R*, there is an assumed internal directory structure within the functions. Below is a basic schematic of its structure, but consult the functions for more details. Data sources are detailed at *~/docs/data_guide.Rmd* and the manuscript.

```
/CONUS_ephemeral_data
├── /exp_catchments
│   ├── /walnut_gulch
│   ├── ├── *datasets*
│   /for_ephemeral_project
│   ├── /flowingDays_data
│   ├── ├── *datasets*
│   ├── *datasets*
├── /HUC02_01
│   ├── /NHDPlus_H_0101_HU4_GDB
│   │   ├── NHDPlus_H_0101_GDB.gdb
├── /other_shapefiles
│   ├── *datasets*
```

- `targets` (to our knowledge and as of the time of writing) doesn't allow for querying targets by patterns (i.e. a basin ID), so each target name must be hardcoded. Because of this, you will see some duplicated code in certain functions.

- Some manual QAQC was also performed on certain datasets to use as consistent of a definition for ephemeral streams as possible. See *~/docs* and the manuscript for more details.