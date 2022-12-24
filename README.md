# Ephemeral contributions to United States drainage networks

## To run
- In short, use *src/runTargets.R* and *run.sh* to actually execute the pipeline non-interactively.

- The workflow (entirely written in R) is executed in parallel across 205 basins. We use `clustermq` to run in parallel via persistent workers to speed up processing. Necessary details on using `clustermq` are [here]('https://mschubert.github.io/clustermq/index.html'), which requires the installation of `zeroMQ` libraries for Linux.
  - Use *slurm_clustermmq.tmpl* to specify your HPC scheduler needs. Other schedulers will need a different recipe. See [here]('https://mschubert.github.io/clustermq/articles/userguide.html#scheduler-templates').
  - While `clustermq` is faster than transient worker schemes, we found it behaving somewhat inconsistently in the most memory intensive actions. We've had luck using `futures.batchtools` instead. The associated slurm template is *slurm_future.tmpl* but know that it will be a bit slower (but requires less memory on the master process). You will also have to amend `_targets.R`.

## Workflow Notes
- This analysis uses `targets` to launch (and monitor) a fully reproducible pipeline within R. For more on using `targets` for reproducible workflows, see [here](https://books.ropensci.org/targets/). Model input parameters are described and assigned in the *_targets.R* script. This script will only make sense after familiarizing yourself with `targets` syntax.

- We use a private R library (via `renv`) within a conda virtual environment because 1) some R packages are only available on github (and not anaconda) and 2) some other R packages (mostly those requiring access to specific `gdal` libraries) could not be installed via `renv`. These `gdal` situations are unique to our cluster and your experience on your HPC may vary. The virtual environment used for the analysis is reproducible using `environment.yml` and `renv.lock`. For more on `renv` see [here](https://rstudio.github.io/renv/).

- Note that the data is stored in another repo (`CONUS_ephemeral_data`). While the user specifies the main path to this repo within `_targets.R`, **there are also a handful of hard-coded sub-directories out of necessity**. Check the functions in the R scripts to make sure you set up the folder structure correctly. Data sources are detailed at *docs/data_guide.Rmd*.

## Manuscript
- Can be built from the main directory by running `render('docs/manuscript/CONUS_ephemeral.Rmd')` within an interactive R session.