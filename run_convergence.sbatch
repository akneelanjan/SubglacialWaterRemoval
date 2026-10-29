#!/bin/bash
#SBATCH --job-name=conv
#SBATCH --time=06:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --partition=normal
#SBATCH --output=logs/conv_%x_%A_%a.out
#SBATCH --error=logs/conv_%x_%A_%a.err

# Mesh-convergence and resolvability study (canal baseline, alpha = 0.02383).
# One script, three modes, chosen with --export=ALL,MODE=<mode>:
#
#   MODE=mesh : build (and cache) each mesh once, no solve.      7 tasks, 1 per configuration
#   MODE=on   : WaterRemoval_OnTarget.m, canal cases 1,3,4,5.   28 tasks = 7 configurations x 4 cases
#   MODE=off  : WaterRemoval_OffTarget.m, off-target cases 1-4. 28 tasks = 7 configurations x 4 cases
#
# Configurations (task order matters: the last one, h_bg = 2.5 m, is the heavy one):
#   0 production           h_fine 1,   h_bg 5,   grading 25-100 m, stopping rule 1e-3
#   1 coarser centre       h_fine 2
#   2 finer centre         h_fine 0.5
#   3 coarser background   h_bg 10
#   4 wider grading        grading 50-150 m
#   5 tighter stopping     same mesh as 0, stopping rule 1e-5
#   6 coarser background   h_bg 20    (shows that h_bg = 5 m is already converged)
#
# Usage, run from ~/BasalAnchoring2DNeel_GitHub after the edits to the two .m files:
#   1. meshes (built once, so that parallel solves never write the same mesh file):
#        J=$(sbatch --parsable --export=ALL,MODE=mesh --array=1-7 run_convergence.sbatch)
#   2. solves:
#        sbatch --dependency=afterok:$J --export=ALL,MODE=on  --array=1-28 run_convergence.sbatch
#        sbatch --dependency=afterok:$J --export=ALL,MODE=off --array=1-28 run_convergence.sbatch
#   3. analysis and Fig. S11, from the repository root once the results are in:
#        matlab -batch "AnalyzeMeshConvergence"
# Results go to ResultsConvergence/<configuration>/, never into ResultsMatFiles/.

module load matlab

cd "$HOME/BasalAnchoring2DNeel_GitHub" || exit 1
mkdir -p logs

# hf   hbg   dmin dmax tol
CONFIGS=("1 5 25 100 1e-3"
         "2 5 25 100 1e-3"
         "0.5 5 25 100 1e-3"
         "1 10 25 100 1e-3"
         "1 5 50 150 1e-3"
         "1 5 25 100 1e-5"
         "1 20 25 100 1e-3")
ON_CASES=(1 3 4 5)     # Canal_50kPa, Canal_150kPa, Canal_50.44kPa, Canal_50.89kPa  (caseFiles in WaterRemoval_OnTarget.m)
OFF_CASES=(1 2 3 4)    # rows of offCases in WaterRemoval_OffTarget.m: dQ 0.5 and 1 L/min at y_off = 50 and 100 m

TID=${SLURM_ARRAY_TASK_ID}
case "$MODE" in
  mesh) CFG=$((TID-1));       CASE=1 ;;
  on)   CFG=$(((TID-1)/4));   CASE=${ON_CASES[$(((TID-1)%4))]} ;;
  off)  CFG=$(((TID-1)/4));   CASE=${OFF_CASES[$(((TID-1)%4))]} ;;
  *)    echo "MODE must be mesh, on or off (got '$MODE')"; exit 1 ;;
esac
if [ "$CFG" -ge "${#CONFIGS[@]}" ]; then echo "task $TID is outside the configuration table"; exit 1; fi

read HF HBG DMIN DMAX TOL <<< "${CONFIGS[$CFG]}"
export H_FINE=$HF H_BG=$HBG D_MIN=$DMIN D_MAX=$DMAX RES_TOL=$TOL
TAG="hf${HF}_hbg${HBG}_dmin${DMIN}_dmax${DMAX}_tol${TOL}"
export RESULTS_DIR="ResultsConvergence/${TAG}"
mkdir -p "$RESULTS_DIR"

# the .m scripts read SLURM_ARRAY_TASK_ID as the case number
export SLURM_ARRAY_TASK_ID=$CASE
SCRIPT=WaterRemoval_OnTarget
[ "$MODE" = off ] && SCRIPT=WaterRemoval_OffTarget

echo "MODE=$MODE task=$TID config=$CFG ($TAG) case=$CASE script=$SCRIPT, started $(date)"

if [ "$MODE" = mesh ]; then
    export MESH_ONLY=1
    matlab -batch "$SCRIPT"
else
    matlab -batch "maxNumCompThreads(${SLURM_CPUS_PER_TASK}); cd('$HOME/matlab_addons/cvx'); cvx_setup; cd('$HOME/BasalAnchoring2DNeel_GitHub'); $SCRIPT"
fi
rc=$?

echo "finished $(date), MATLAB exit code ${rc}"
exit ${rc}
