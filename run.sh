#!/bin/bash
#SBATCH --job-name='ephemeral_master'
#SBATCH -c 10  # Number of Cores per Task
#SBATCH -p ceewater_cjgleason-cpu
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=cbrinkerhoff@umass.edu
#SBATCH --mem=128000 #Requested memory
#SBATCH -t 200:00:00  # Job time limit
#SBATCH -o out_master.txt  # %j = job ID
#SBATCH -e err_master.txt

Rscript src/runTargets.R
