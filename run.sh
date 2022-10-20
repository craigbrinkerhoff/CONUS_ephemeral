#!/bin/bash
#SBATCH --job-name='ephemeral_master'
#SBATCH -c 10  # Number of Cores per Task
#SBATCH -p ceewater_cjgleason-cpu
#SBATCH --mem=20000 #Requested memory
#SBATCH -t 24:00:00  # Job time limit  2 days just in case
#SBATCH -o out_master.txt  # %j = job ID
#SBATCH -e err_master.txt

Rscript src/runTargets.R
