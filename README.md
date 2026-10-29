# Subglacial Water Removal

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.20324378.svg)](https://doi.org/10.5281/zenodo.20324378)

This repository contains MATLAB code for simulating how localized water removal from the subglacial drainage system modifies basal drag and glacier speed for an idealized mountain glacier sliding through a hard-rock valley with sediment accumulated in the topographic low. The code builds on the coupled thermomechanical free-boundary model of Ortholine v1.0 and implements mixed-bed drag and hydrology-informed basal-strength parameterizations for different subglacial drainage modes.

It accompanies the manuscript *Engineered removal of water from beneath glaciers could slow or accelerate them* (Akuli and Suckale), submitted to *Science Advances*.

Water removal is tested in two scenarios:

1. **On-target flowrate reduction:** water is removed from the selected drainage mode with exact spatial precision, corresponding to zero offset, `y_off = 0`.
2. **Off-target flux reduction:** a borehole aimed at a sedimentary canal misses it and withdraws the same flowrate (`dQ = 0.5` or `1 L/min`) from the adjacent water film at an offset `y_off = 50` or `100 m`. The matched on-target cases are `Canal_50.44kPa` and `Canal_50.89kPa`.

## Workflow

The recommended workflow is:

1. Install dependencies.
2. Generate hydrology parameter files using scripts in `ParameterGeneratorCodes/`.
3. Save generated parameter files in `InputParameterFiles/`.
4. Run the main water-removal simulations.
5. Save model outputs in `ResultsMatFiles/`.
6. Use the plotting scripts to reproduce the manuscript and supplementary figures.
7. Optionally, run the mesh-convergence study and reproduce Fig. S11.

## Files

### Executable scripts

- `WaterRemoval_OnTarget.m`  
  Main script for on-target flowrate-reduction experiments. The list `caseFiles` at the top of the script holds all 25 cases (canal, wider central canal, R-channel, linked cavity, water film, central canal without side canals for Fig. S5, and the shared-slope cases for Fig. S9). `caseID` selects the case, and in batch runs it is taken from `SLURM_ARRAY_TASK_ID`. The script loads the matching parameter file from `InputParameterFiles/`, solves the coupled thermomechanical model, and saves the result as `TempBedG100mW_<case>.mat` in `ResultsMatFiles/`.

- `WaterRemoval_OffTarget.m`  
  Main script for the matched-rate off-target experiments. The matrix `offCases` lists the four cases (`dQ` = 0.5 and 1 L/min, each at `Xsuction` = 1050 and 1100 m, that is `y_off` = 50 and 100 m from the canal at 1000 m). Results are saved as `TempBedG100mW_OffTarget_dQ<dQ>Lmin_Blip<N>Pa_Y<Xsuction>.mat`.

- `ParameterGeneratorCodes/RegenerateAllParameterFiles.m`  
  Regenerates every input parameter file in one run, with the slopes and effective pressures used in the manuscript.

- `FormalFigurePlotting_Fig2Main_SIFigs.m`  
  Plots Fig. 2 and SI Figs. S2 (profile column), S3, S4, S5, S6, S7 and S9 from the on-target results.

- `FormalFigure3PlottingOffTarget.m`  
  Plots Fig. 3, the matched-rate on-target and off-target comparison.

- `AnalyzeMeshConvergence.m`  
  Analyzes the mesh-convergence study, prints the tables, and reproduces SI Fig. S11.

- `run_ontarget.sbatch`, `run_offtarget.sbatch`, `run_convergence.sbatch`  
  Slurm array scripts used for the production runs on Stanford's Sherlock cluster.

- `Damsgaard2017_1d-canal_fixedgeometry.py`  
  Python script, adapted from Damsgaard et al. (2017), that computes the canal effective pressure N_c as a function of flowrate Q (SI section 3, Fig. S8). Its output is `Nc_vs_Q.txt`.

### Folders and supporting files

```text
ParameterGeneratorCodes/      Generates hydrology-informed input .mat files
InputParameterFiles/          Stores generated input parameter .mat files
ResultsMatFiles/              Stores simulation output .mat files
Final Manuscript Figures/     Final PDF versions of the manuscript and SI figures
Mesh_hf1_hbg5_dmin25_dmax100.mat   Cached production mesh (h_fine = 1 m, h_bg = 5 m)
Nc_vs_Q.txt                   Canal N_c versus Q table (Fig. S8)
conv_tables.txt               Mesh-convergence tables behind Fig. S11
DistMesh-main/                DistMesh2D mesh-generation utilities
cbrewer2/                     ColorBrewer plotting utility
iceColorMap.mat               Colormap for temperature plots
setFontSize.m                 Helper function for figure formatting
```

## Dependencies

Install or make available the following before running the model.

### 1. MATLAB

The scripts are written in MATLAB and use `.mat` input/output files.

### 2. CVX for MATLAB

CVX is required for solving the convex optimization problem. Before running any script, first download and install CVX from: http://cvxr.com/cvx/

or from the CVX GitHub release page: https://github.com/cvxr/CVX/releases

Install CVX in a clean, permanent location outside this repository. Then open MATLAB, go to the CVX folder, and run:

```matlab
cvx_setup
savepath
cvx_version
```

A good default location is:

```text
macOS/Linux: ~/MATLAB/cvx
Windows:     C:\Users\<username>\Documents\MATLAB\cvx
```

Avoid using a copied CVX folder inside this repository, because it may be incomplete or incompatible with the current computer.

### 3. MOSEK

The scripts call `cvx_solver mosek`. MOSEK is free for academic use, and a license file is required: https://www.mosek.com/products/academic-licenses/

### 4. cbrewer2

`cbrewer2` is required for perceptually balanced ColorBrewer colormaps used in plotting. Before running any script, download and install cbrewer2 from the MATLAB File Exchange page: https://www.mathworks.com/matlabcentral/fileexchange/58350-cbrewer2


Following installation, this repository includes cbrewer2-related supporting files in:

```text
cbrewer2/
```

### 5. DistMesh2D

DistMesh2D is required for unstructured triangular mesh generation. This repository includes DistMesh-related files in:

```text
DistMesh-main/
```

- Original DistMesh resource: http://persson.berkeley.edu/distmesh/
- Latest DistMesh v1.2 version: https://github.com/popersson/DistMesh


### Add paths in MATLAB

From the repository root, run:

```matlab
addpath("DistMesh-main")
addpath(fullfile("DistMesh-main","src"))
addpath(fullfile("DistMesh-main","examples"))
addpath("cbrewer2")
```

## Usage

### 1. Generate input parameter files

The parameter-generation scripts are stored in:

```text
ParameterGeneratorCodes/
```

Run them from inside that folder because the scripts save files to `../InputParameterFiles/`. The recommended way to regenerate all input files with the manuscript values is:

```matlab
cd ParameterGeneratorCodes
RegenerateAllParameterFiles
cd ..
```

Each generator creates a `.mat` file containing the basal-drag functions, hydrology parameters, flowrate label, slope, and plotting colors for one drainage-mode case. The individual generators (`CreateParameterMATFiles_Canal`, `_RChannel`, `_LinkedCavity`, `_WaterFilm`) can also be run on their own after editing the effective-pressure and flowrate values inside them.

The downstream slopes `alpha` are tuned per drainage mode so that every baseline reaches a maximum surface speed of about 100 m/yr (SI Table S2):

```text
Water film:      0.02327
Linked cavity:   0.02372
R-channel:       0.04585
Canal:           0.02383
```

The main cases are:

```text
Canal:           N_c = 50, 100, 150 kPa (plus 50.44 and 50.89 kPa for the matched-rate off-target comparison)
R-channel:       N_ch = 550, 520 kPa
Linked cavity:   N_lc = 250, 500 kPa
Water film:      N_wf = 4000, 4444, 5000, 8000 Pa
```

The generated files are saved in `InputParameterFiles/` with names such as:

```text
Canal_50kPa.mat
Canal_50.44kPa.mat
RChannel_550kPa.mat
LinkedCavity_250kPa.mat
WaterFilm_4000Pa.mat
```

### 2. Run on-target flowrate reduction

From the repository root, open `WaterRemoval_OnTarget.m` and set the default case in the line

```matlab
caseID = 1;   % interactive default: index into caseFiles
```

where `caseID` indexes the list `caseFiles` defined just above it. Then run:

```matlab
WaterRemoval_OnTarget
```

The script generates the mesh, solves the coupled thermomechanical model, plots the 2D ice-speed field, surface-speed profile, temperature field, and basal-drag profile, and saves the output as:

```matlab
filename = fullfile(filepath,"TempBedG100mW_"+modeCase+".mat");
```

On a Slurm cluster, the full set of 25 cases runs as one job array:

```bash
sbatch --array=1-25 run_ontarget.sbatch
```

### 3. Run off-target flux reduction

From the repository root, open `WaterRemoval_OffTarget.m`. The matrix `offCases` lists the four cases (flowrate withdrawal `dQ`, film strength perturbation `N_wfblip`, and suction location `Xsuction`):

```text
dQ = 0.5 L/min, N_wfblip = 264.6 Pa, Xsuction = 1050, 1100 m
dQ = 1.0 L/min, N_wfblip = 617 Pa,   Xsuction = 1050, 1100 m
```

Choose a row with `caseID` (default 1) and run:

```matlab
WaterRemoval_OffTarget
```

The off-target script uses the baseline canal effective pressure `N_c = 50 kPa` and a localized exponentially decaying film-strength perturbation over a spatial length scale `delta = 10 m`. The output is saved as `TempBedG100mW_OffTarget_dQ<dQ>Lmin_Blip<N>Pa_Y<Xsuction>.mat`. On a Slurm cluster:

```bash
sbatch run_offtarget.sbatch      # 4 array tasks, one per row of offCases
```

### 4. Plot manuscript and SI figures

After the relevant output `.mat` files exist in `ResultsMatFiles/`, run:

```matlab
FormalFigurePlotting_Fig2Main_SIFigs
FormalFigure3PlottingOffTarget
```

The first script loads the on-target cases (canal, wider canal, central canal only, R-channel, linked cavity, water film, and the shared-slope cases) and produces Fig. 2 and SI Figs. S2 (profile column), S3 to S7 and S9. The second loads the matched on-target canal cases and the off-target cases and produces Fig. 3. The final PDF versions are in `Final Manuscript Figures/`.

### 5. Mesh-convergence study (SI Fig. S11)

The convergence study reruns the canal baseline and the matched off-target cases on seven mesh configurations. `WaterRemoval_OnTarget.m` and `WaterRemoval_OffTarget.m` read the environment variables `H_FINE`, `H_BG`, `D_MIN`, `D_MAX`, `RES_TOL`, `RESULTS_DIR` and `MESH_ONLY`; with none set, the production settings are used. On Slurm:

```bash
J=$(sbatch --parsable --export=ALL,MODE=mesh --array=1-7 run_convergence.sbatch)
sbatch --dependency=afterok:$J --export=ALL,MODE=on  --array=1-28 run_convergence.sbatch
sbatch --dependency=afterok:$J --export=ALL,MODE=off --array=1-28 run_convergence.sbatch
```

Then, from the repository root, run `AnalyzeMeshConvergence` in MATLAB. It reads `ResultsConvergence/<configuration>/`, prints the convergence tables, and writes `FigS11_convergence.pdf` and `mesh_convergence_summary.csv`. The study uses the nominal mesh noise floor `zeta`, the largest departure of the smallest off-target signal from its production value among all configurations at or finer than `h_bg = 10 m`.



## Output

The main simulation scripts generate:

1. 2D ice-speed field
2. Ice-surface speed profile
3. 2D temperature field
4. Basal-drag profile
5. Saved MATLAB workspace/output variables in `ResultsMatFiles/`

Although input and output `.mat` files are provided for all considered cases, we strongly recommend running the full workflow locally, from parameter generation to input-file creation, simulation, saving, and plotting, to avoid directory/path issues.

## Notes

- Paths are written using `fullfile(...)` where possible for cross-platform compatibility across Windows, macOS, and Linux.
- Third-party dependencies retain their original licenses and citation requirements.
- CVX should be installed separately and not copied into this repository.

## Citation and Acknowledgment

- The coupled thermomechanical/free-boundary model is adapted from Ortholine v1.0:
  ```text
  Suckale, J. and Elsworth, C. W.: An antiplane strain model for evaluating shear-margin stability (Ortholine v1.0), EGUsphere [preprint], https://doi.org/10.5194/egusphere-2026-67, 2026.
  ```
  Original Ortholine v1.0 repository: https://github.com/coopere/InstituteIceStream2D
- This repository is archived on Zenodo: https://doi.org/10.5281/zenodo.20324378
  - For use of this code, please also cite the associated manuscript: N. Akuli and J. Suckale, *Engineered removal of water from beneath glaciers could slow or accelerate them*, submitted to *Science Advances*.
- CVX optimization toolbox developers
- distmesh2d developers
- cbrewer2 developers

## License

This repository is released under the GNU General Public License v3.0. See `LICENSE` for details.

## Contact

For questions, please contact the authors at akneelanjan@gmail.com.
