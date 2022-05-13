## RECIPE FOR EPHEMERAL PROJECT ENVIRONMENT

### Do all of this from a small interactive session to avoid tying up the login nodes
- `srun -c 10 -p cpu --pty bash`

### Load miniconda
- `module load miniconda`

### Create environment
- `conda create -n CONUS_ephemeral-env`
- `conda activate CONUS_ephemeral-env`

### Install most basic r setup. (we will install all of our packages in another library using renv instead)
- `conda install -c conda-forge r-base r-renv`

### Install some necessary software
- `conda install zeromq` (for clustermq package parallelization)
- `conda install -c conda-forge pandoc` (for saving pipeline graph)

### Install some r packages outside of renv (can't see libcurl for some reason within renv library)
- `conda install -c conda-forge r-curl`
- `conda install -c conda-forge r-units`
- `conda install -c conda-forge r-sf`
- `conda install -c conda-forge r-terra`

### Restore existing library and lockfile or use renv::init() to intiate renv package library and lockfile
- `R`
- `renv::restore()`
- Might have to install grwat yourself from github. If so:
  - `R`
  - `install.packages(devtools)`
  - `devtools::install_github("tsamsonov/grwat")`
