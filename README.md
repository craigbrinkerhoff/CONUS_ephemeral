# Ephemeral Stream Water Contributions to United States Drainage Networks

This repo contains the pipeline for our assessment of ephemeral streams in the contiguous United States. It uses `targets` to launch (and monitor) a fully reproducible pipeline in `R` on an HPC. For more on using `targets`, see [here](https://books.ropensci.org/targets/). Pipeline parameters are described and assigned in the *_targets.R* script.

We also knit the entire manuscript in `RMarkdown` for reproducibility. Note that the actual target objects are not included and so to do this, you would need to rerun the entire pipeline.

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
- Our package environment uses a private R library (via `renv`) within a `conda` environment because a bunch of requisite R packages are only available on github (and not Anaconda). The virtual environment used for the analysis is reproducible using *environment.yml* and *renv.lock*. For more on `renv` see [here](https://rstudio.github.io/renv/).
      
  - In hindsight, we would have more cleanly installed as many R packages within conda as possible, but this is what we've got!

- Parallel job submissions are abstracted in R using *~src/runTargets.R* and either `future.batchtools` or `clustermq`. Note that some of these tasks require very large amounts of memory and you may have to troubleshoot your resource allocations (for example, for some processes we frequently request over 100 Gb of RAM). Below are the job templates we use for a SLURM scheduler:

  - *slurm_clustermq.tmpl*: You will need to install `zeroMQ` libraries for Linux (included in *environment.yml*)

  - *slurm_future.tmpl*: While `clustermq` is faster than transient worker setups, we found it behaves somewhat inconsistently for the jobs in our pipeline that require huge amounts of memory. We've had luck using `futures.batchtools` instead and suggest it for this repo.

- The data is assumed to be stored in another repo (*CONUS_ephemeral_data*). While the user specifies the main path to this repo within *_targets.R*, there is an assumed internal directory structure within the many functions. Below is a basic schematic of its structure. Data sources are detailed at *~/docs/data_guide.html*.

```
├── /exp_catchments
│   ├── /walnut_gulch
│   ├── ├── *our data*
│   /for_ephemeral_project
│   ├── /flowingDays_data
│   ├── ├── *our data*
│   ├── *our data*
├── /HUC02_01
│   ├── /NHDPlus_H_0101_HU4_GDB
│   │   ├── NHDPlus_H_0101_GDB.gdb
├── /other_shapefiles
│   ├── *our data*
```

- `targets` (to our knowledge and as of the time of writing) doesn't allow for querying targets by pattern like a basin ID, i.e. each target name must be hardcoded. Because of this, you will see some duplicated code in certain functions, and will see a lot of similar code in the *~src/_targets.R* script.

- Some manual QAQC was also performed on certain data. See *~/docs* for more details.