#!/bin/bash
#SBATCH --job-name=ontarget
#SBATCH --array=1-16
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --partition=normal
#SBATCH --output=logs/ontarget_%A_%a.out
#SBATCH --error=logs/ontarget_%A_%a.err
##SBATCH --mail-type=END,FAIL
##SBATCH --mail-user=neel2021@stanford.edu

# One array task per entry of caseFiles in WaterRemoval_OnTarget.m:
# the script reads SLURM_ARRAY_TASK_ID as caseID.

module load matlab

cd "$HOME/BasalAnchoring2DNeel_GitHub" || exit 1

echo "Task ${SLURM_ARRAY_TASK_ID} on $(hostname), started $(date)"

# CVX preferences live in a node-local /lscratch folder on Sherlock, so each task
# initialises CVX (solver detection, including MOSEK) before running the case.
matlab -batch "maxNumCompThreads(${SLURM_CPUS_PER_TASK}); cd('$HOME/matlab_addons/cvx'); cvx_setup; cd('$HOME/BasalAnchoring2DNeel_GitHub'); WaterRemoval_OnTarget"
rc=$?

echo "Task ${SLURM_ARRAY_TASK_ID} finished $(date), MATLAB exit code ${rc}"
exit ${rc}
