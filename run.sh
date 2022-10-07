#!/bin/bash
#SBATCH --job-name='ephemeral_master'
#SBATCH -c 20  # Number of Cores per Task
#SBATCH -p gpu-preempt
#SBATCH --mem=64000 #Requested memory
#SBATCH -t 48:00:00  # Job time limit  2 days just in case
#SBATCH -o out_master.txt  # %j = job ID
#SBATCH -e err_master.txt

Rscript src/runTargets.R
