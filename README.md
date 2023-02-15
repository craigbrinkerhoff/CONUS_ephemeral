# Ephemeral stream water contributions to United States drainage networks

This repo contains the pipeline to reproduce our analysis on ephemeral streams in the contiguous United States. It uses `targets` to launch (and monitor) a fully reproducible pipeline in `R` on an HPC. For more on using `targets`, see [here](https://books.ropensci.org/targets/). Pipeline parameters are described and assigned in the *_targets.R* script.

## To run
```
conda activate CONUS_ephemeral-env
sbatch run.sh
```

## Manuscript
```
R
render('docs/manuscript/CONUS_ephemeral.Rmd')
```

## Notes
- Parallel job submissions are abstracted in R using either `future.batchtools` or `clustermq`. All included files are for a SLURM scheduler. Some of these jobs require very large amounts of memory.  Below are the SLURM job templates we use:

  - *slurm_clustermq.tmpl*: You will need to install `zeroMQ` libraries for Linux (included in *environment.yml*)

  - *slurm_future.tmpl*: While `clustermq` is faster than transient worker setups, we found it behaves somewhat inconsistently for the jobs in our pipeline that require huge amounts of memory. We've had luck using `futures.batchtools` instead.

- Our package environment uses a private R library (via `renv`) within a `conda` environment because many R packages are only available on github (and not anaconda). The virtual environment used for the analysis is reproducible using *environment.yml* and *renv.lock*. For more on `renv` see [here](https://rstudio.github.io/renv/).
      - In hindsight, we would have more cleanly installed as many R packages within conda as possible, but this is what we've got!

- The data is stored in another repo (*~/CONUS_ephemeral_data*). While the user specifies the main path to this repo within *_targets.R*, there is an assumed internal directory structure. Below is a basic schematic of its structure. Data sources are detailed at *~/docs/data_guide.Rmd*.

```
├── /exp_catchments
│   ├── /walnut_gulch
│   ├── ├── data
│   /for_ephemeral_project
│   ├── /flowingDays_data
│   ├── ├── data
│   ├── data
├── /HUC02_01
│   ├── /NHDPlus_H_0101_HU4_GDB
│   │   ├── NHDPlus_H_0101_GDB.gdb
├── /other_shapefiles
```