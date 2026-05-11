# Subglacial Water Removal

This repository contains MATLAB code for simulating how localized water removal from the subglacial drainage system modifies basal drag and glacier speed for an idealized mountain glacier sliding through a hard-rock valley with sediment accumulated in the topographic low. The code builds on the coupled thermomechanical free-boundary model of Ortholine v1.0, implements mixed bed drag and hydrology-informed basal-strength parameterizations for different subglacial drainage modes.

Water removal is tested in two scenarios:
1. **On-target flowrate reduction:** water is removed from the selected drainage mode with exact spatial precision, corresponding to zero offset, \(y_{\mathrm{off}} = 0\).
2. **Off-target flux reduction:** water is removed near a sedimentary canal, but the borehole misses the desired target by a non-zero offset, \(y_{\mathrm{off}} \neq 0\).

## Workflow

The recommended workflow is:

1. Install dependencies.
2. Generate hydrology parameter files using scripts in `ParameterGeneratorCodes/`.
3. Save generated parameter files in `InputParameterFiles/`.
4. Run the main water-removal simulations.
5. Save model outputs in `ResultsMatFiles/`.
6. Use the plotting scripts to reproduce the manuscript and supplementary figures.

## Dependencies

Install or make available the following dependencies before running the model:

1. **CVX for MATLAB**  
   Required for the convex optimization solve. Install CVX first and run:

   ```matlab
   cvx_setup
   ```

2. **DistMesh2D**  
   Required for unstructured triangular mesh generation. This repository includes DistMesh-related files in:

   ```text
   DistMesh-main/
   ```

3. **cbrewer2**  
   Required for ColorBrewer colormaps used in plotting. This repository includes:

   ```text
   cbrewer2/
   ```

4. **MATLAB**  
   The scripts are written for MATLAB and use `.mat` input/output files.

Before running the scripts, make sure the relevant dependency folders are on the MATLAB path.

## Repository structure

```text
ParameterGeneratorCodes/                 Generates hydrology parameter files
InputParameterFiles/                     Stores generated input parameter .mat files
ResultsMatFiles/                         Stores simulation output .mat files
DistMesh-main/                           DistMesh2D mesh-generation utilities
cbrewer2/                                ColorBrewer plotting utility
WaterRemoval_OnTarget.m                  Main script for on-target flowrate reduction
WaterRemoval_OffTarget.m                 Main script for off-target flux reduction
FormalFigurePlotting_3_4_5.m             Main plotting script for on-target results
FormalFigure6PlottingOffTarget.m         Plotting script for off-target results
```

## Running on-target flowrate reduction

Use:

```matlab
WaterRemoval_OnTarget
```

This script compares the glacier response across drainage modes, including sedimentary canals, R-channels, linked cavities, and water films.

For each run:

1. Load the desired drainage-mode parameter file from `InputParameterFiles/`.
2. Run `WaterRemoval_OnTarget.m`.
3. Save the resulting case in `ResultsMatFiles/`.

## Running off-target flux reduction

Use:

```matlab
WaterRemoval_OffTarget
```

This script tests off-target water-film flux reduction near a sedimentary canal by comparing different lateral offsets from the intended target.

For each run:

1. Set the desired offset/suction location in `WaterRemoval_OffTarget.m`.
2. Run the script.
3. Save the resulting case in `ResultsMatFiles/`.

## Plotting manuscript figures

Use the plotting scripts after the relevant `.mat` files have been generated:

```matlab
FormalFigurePlotting_3_4_5
FormalFigure6PlottingOffTarget
```

These scripts load saved results from `ResultsMatFiles/` and generate the formal figures used for the manuscript and supplementary information.

## Notes

- Paths are written using `fullfile(...)` where possible for cross-platform compatibility across Windows, macOS, and Linux.
- Although input and output `.mat` files are provided for all considered cases, we strongly recommend running the full workflow locally, from parameter generation to input-file creation, simulation, saving, and plotting, to avoid directory/path issues.
- Third-party dependencies retain their original licenses and citation requirements.

## Citation and acknowledgment

This repository modifies and extends the Ortholine v1.0 modeling framework for subglacial water-removal experiments. Please cite the associated manuscript when available.

The original Ortholine v1.0 repository is: https://github.com/coopere/InstituteIceStream2D

## License

This repository is released under the GNU General Public License v3.0. See `LICENSE` for details.
