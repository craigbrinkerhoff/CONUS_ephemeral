#!/bin/bash
#SBATCH --job-name='ephemeral'
#SBATCH -c 8  # Number of Cores per Task
#SBATCH -p cpu
#SBATCH --mem=128000  #Requested memory
#SBATCH -t 24:00:00  # Job time limit 1 day
#SBATCH -o out.txt  # %j = job ID
#SBATCH -e err.txt

Rscript src/runTargets.R
