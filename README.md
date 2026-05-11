# Subglacial Water Removal

This repository contains MATLAB code for simulating how localized water removal from the subglacial drainage system modifies basal drag and glacier speed for an idealized mountain glacier sliding through a hard-rock valley with sediment accumulated in the topographic low. The code builds on the coupled thermomechanical free-boundary model of Ortholine v1.0 and implements mixed-bed drag and hydrology-informed basal-strength parameterizations for different subglacial drainage modes.

Water removal is tested in two scenarios:

1. **On-target flowrate reduction:** water is removed from the selected drainage mode with exact spatial precision, corresponding to zero offset, `y_off = 0`.
2. **Off-target flux reduction:** water is removed near a sedimentary canal, but the borehole misses the desired target by a non-zero offset, `y_off ≠ 0`.

## Workflow

The recommended workflow is:

1. Install dependencies.
2. Generate hydrology parameter files using scripts in `ParameterGeneratorCodes/`.
3. Save generated parameter files in `InputParameterFiles/`.
4. Run the main water-removal simulations.
5. Save model outputs in `ResultsMatFiles/`.
6. Use the plotting scripts to reproduce the manuscript and supplementary figures.

## Files

### Executable scripts

- `WaterRemoval_OnTarget.m`  
  Main script for on-target flowrate-reduction experiments. It loads one drainage-mode parameter file from `InputParameterFiles/`, solves the coupled thermomechanical model, and saves the result as `HighRes_<modeCase>.mat` in `ResultsMatFiles/`.

- `WaterRemoval_OffTarget.m`  
  Main script for off-target flux-reduction experiments near a sedimentary canal. It compares different offsets by changing the suction location `Xsuction`.

- `WaterRemoval_OnTarget_Only1CentralCanal.m`  
  Optional test script for an on-target case with only one central canal.

- `FormalFigurePlotting_3_4_5.m`  
  Plotting script for the on-target drainage-mode comparison figures.

- `FormalFigure6PlottingOffTarget.m`  
  Plotting script for the off-target spatial-imprecision figure.

### Folders and supporting files

```text
ParameterGeneratorCodes/      Generates hydrology-informed input .mat files
InputParameterFiles/          Stores generated input parameter .mat files
ResultsMatFiles/              Stores simulation output .mat files
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

### 3. cbrewer2

`cbrewer2` is required for perceptually balanced ColorBrewer colormaps used in plotting. Before running any script, download and install cbrewer2 from the MATLAB File Exchange page: https://www.mathworks.com/matlabcentral/fileexchange/58350-cbrewer2


Following installation, this repository includes cbrewer2-related supporting files in:

```text
cbrewer2/
```

### 4. DistMesh2D

DistMesh2D is required for unstructured triangular mesh generation. This repository includes DistMesh-related files in:

```text
DistMesh-main/
```

Original DistMesh resource: http://persson.berkeley.edu/distmesh/
Latest DistMesh v1.2 version: https://github.com/popersson/DistMesh


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

Run them from inside that folder because the scripts save files to `../InputParameterFiles/`.

```matlab
cd ParameterGeneratorCodes

CreateParameterMATFiles_Canal
CreateParameterMATFiles_RChannel
CreateParameterMATFiles_LinkedCavity
CreateParameterMATFiles_WaterFilm

cd ..
```

Each generator creates a `.mat` file containing the basal-drag functions, hydrology parameters, flowrate label, slope, and plotting colors for one drainage-mode case.

To generate a different case, edit the relevant effective-pressure/flowrate values inside the generator script before running it again. The main cases are:

```text
Canal:        N_canal_center = 50, 100, 150, 200 kPa
R-channel:    N_ch = 550, 520 kPa
Linked cavity: N_lc = 250, 500 kPa
Water film:   N_wfmod = 4000, 4444, 5333, 8000 Pa
```

The generated files are saved in `InputParameterFiles/` with names such as:

```text
Canal_50kPa.mat
RChannel_550kPa.mat
LinkedCavity_250kPa.mat
WaterFilm_4000Pa.mat
```

### 2. Run on-target flowrate reduction

From the repository root, open:

```text
WaterRemoval_OnTarget.m
```

Choose exactly one input case by uncommenting the corresponding `load(...)` command. For example:

```matlab
load(fullfile("InputParameterFiles","Canal_150kPa.mat"));
modeCase = "Canal_"+string(N_canal_center/1000)+"kPa";
```

Then run:

```matlab
WaterRemoval_OnTarget
```

The script generates the mesh, solves the coupled thermomechanical model, plots the 2D ice-speed field, surface-speed profile, temperature field, and basal-drag profile, and constructs an output filename:

```matlab
filename = fullfile("ResultsMatFiles","HighRes_"+modeCase+".mat");
```

To save a regenerated result, make sure the final `save(filename)` command is active.

### 3. Run off-target flux reduction

From the repository root, open:

```text
WaterRemoval_OffTarget.m
```

Set the suction location:

```matlab
Xsuction = 1010; % [m]
```

The main offset cases are:

```text
Xsuction = 1010, 1020, 1050, 1100 m
```

Then run:

```matlab
WaterRemoval_OffTarget
```

For each offset, update the matching diagnostic variable names near the bottom of the script, for example:

```matlab
IceFluxXSuction1010 = trapz(x_surf,u_surf);
basaltauc_Canal50kPaY1010 = basal_tau_c_specific;
```

The output filename is constructed as:

```matlab
filename = fullfile("ResultsMatFiles","OffTarget_Canal50kPa_Blip1333Pa_XSuction",string(Xsuction),".mat");
```

To save a regenerated result, make sure the final `save(filename)` command is active.

### 4. Plot manuscript and SI figures

After the relevant output `.mat` files exist in `ResultsMatFiles/`, run:

```matlab
FormalFigurePlotting_3_4_5
FormalFigure6PlottingOffTarget
```

The first script loads the on-target canal, R-channel, linked-cavity, and water-film cases. The second script loads the on-target canal baseline/reduction cases and the off-target offset cases.

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

- Ortholine v1.0 developers. Please cite the associated manuscript when available. The original Ortholine v1.0 repository is: https://github.com/coopere/InstituteIceStream2D
- CVX optimization toolbox developers
- distmesh2d developers
- cbrewer2 developers

## License

This repository is released under the GNU General Public License v3.0. See `LICENSE` for details.

## Contact

For questions, please contact the authors at akneelanjan@gmail.com.
