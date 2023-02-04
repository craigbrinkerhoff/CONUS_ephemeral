# Ephemeral contributions to United States drainage networks

This analysis uses `targets` to launch (and monitor) a fully reproducible pipeline within R. For more on using `targets` for reproducible workflows, see [here](https://books.ropensci.org/targets/). Pipeline parameters are described and assigned in the *_targets.R* script.

## To run
```
conda activate CONUS_ephemeral-env
run.sh
```

## Workflow Notes
- Basins are executed in parallel using a custom routing scheme that handles basin-to-basin routing across 18 levels
  - Parallel job submissions are abstracted in R using either `future.batchtools` or `custermq`. Note this is setup for a Slurm scheduler and our specific cluster dimensions. Your experience WILL vary!! Below are the SLURM job templates we use:
      - *slurm_clustermq.tmpl*: You will need to install `zeroMQ` libraries for Linux.
      - *slurm_future.tmpl*: While `clustermq` is faster than transient worker schemes, we found it behaves somewhat inconsistently for the highest-memory jobs within the pipeline. We've had luck using `futures.batchtools` instead.

- We use a private R library (via `renv`) within a conda virtual environment because 1) some R packages are only available on github (and not anaconda) and 2) some other R packages do not play nice wih `gdal` on our HPC. Your experience on your HPC may vary. The virtual environment used for the analysis is reproducible using `environment.yml` and `renv.lock`. For more on `renv` see [here](https://rstudio.github.io/renv/).
      - There is probably a better way to have done this but it is what we've got!

- The data is stored in another repo (*~/CONUS_ephemeral_data*). While the user specifies the main path to this repo within `_targets.R`, **there are one or two hard-coded sub-directories out of necessity**. Check the functions in the R scripts to make sure you set up the folder structure correctly. Data sources are detailed at *docs/data_guide.Rmd*.

## Manuscript
- Can be built from the main directory by running `render('docs/manuscript/CONUS_ephemeral.Rmd')` within an interactive R session.