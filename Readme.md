# BSpline3D-MATLAB

Comprehensive MATLAB toolbox for fitting, analysing, and visualising 3D B-spline surfaces from naval architecture offset data. The codebase grew out of VSG Labs research on hull form reconstruction and now bundles reproducible demos, sample datasets, and diagnostic tooling for surface evaluation.

## Highlights
- Cubic B-spline surface fitting with station and waterline error metrics via `BSplineFit3`.
- Surface interrogation utilities: smoothness/curvature analysis, curvature comb plots, and fitted-surface sampling helpers.
- Rich visualization suite for comparing raw offsets against fitted surfaces and for highlighting local fitting error.
- Ready-to-run demo scripts covering the full workflow from raw offsets to engineering plots.
- Curated hull-form datasets and synthetic benchmarks for quick experimentation.

## Repository Layout
- `startup.m` – adds all toolbox folders and data directories to the MATLAB path.
- `bsplineEngine3D/` – core algorithms (fitting, sampling, error metrics, curvature analysis, plotting helpers).
- `sandBox/` – step-by-step demo scripts and thesis-era experiments; ideal starting points for exploration.
- `data/` – curated hull offset datasets used in the thesis case studies (catamaran, SWATH, etc.).
- `testData/` – additional sample geometries (cylinder, bone, yacht, synthetic stations) for quick trials.

## Requirements
- MATLAB R2018b or later (tested with recent releases; visualization scripts fall back gracefully if colourmaps like `turbo` are unavailable).
- All functions rely solely on base MATLAB; no external toolboxes are required.

## Getting Started
1. Clone or download the repository and open it in MATLAB.
2. Run `startup` from the repo root to register all subfolders and data directories.
3. Open any script in `sandBox/` (for example `demoErrorAnalysis.m`) and execute it section-by-section (`Ctrl`+`Enter`) or run the whole file to reproduce the published figures.

## Typical Workflow
```matlab
% 1. Load offsets (NX3) and convert to structured stations
xyz = load('yatch_offset3.dat');
station_xyz = xyz2station(xyz);

% 2. Fit a cubic B-spline surface
[cpX, cpY, cpZ, stationMSE, waterlineMSE] = BSplineFit3(6, 6, station_xyz);

% 3. Visualise the fitted surface and diagnostics
[u, v, w] = BSplineSurf(cpX, cpY, cpZ);
[curvature, smoothnessScore, surfaceData] = analyzeSmoothness(cpX, cpY, cpZ);
visualizeError(cpX, cpY, cpZ, xyz, station_xyz);
plotCurvatureCombs(surfaceData, 'Direction', 'both');
```
The demo scripts encapsulate identical steps while adding narration, figure styling, and logging.

## Included Data
- `data/` contains thesis case studies, e.g. `catamaran_offset.dat`, `swath_underwater_hull.dat`.
- `testData/` offers canonical shapes (`cylinder.dat`, `halfCircle.dat`, `bone.dat`) and stationised MATLAB datasets for regression testing.
Bring your own offsets by matching the simple three-column (X,Y,Z) format expected by `xyz2station`.

## Support & Attribution
This archive consolidates work authored by Ahmad Faisal Mohamad Ayob (2008–2025) at VSG Labs. If you extend the toolbox or publish results, please acknowledge the original author and cite the associated thesis/publications when available.
