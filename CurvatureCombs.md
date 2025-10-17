<!-- Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs -->

# Curvature Combs in BSpline3D-MATLAB

Curvature combs are a visual analytic that plot short line segments ("teeth") normal to a curve or surface. Each tooth is scaled by the local curvature magnitude, giving an immediate sense of bending intensity, smoothness, and potential inflection regions. In naval architecture and reverse-engineering workflows, these diagnostics help confirm that reconstructed hull surfaces respect fairness requirements before manufacturing or CFD analysis.

## Why Curvature Combs Matter
- **Fairness assessment** – Naval hulls demand smooth curvature transitions; exaggerated comb lengths expose unfair regions instantly.
- **Inflection and kink detection** – Sign flips in the comb orientation reveal where curvature changes sign, flagging potential modelling artifacts.
- **Control net validation** – Overlaying combs on fitted B-spline surfaces confirms that the chosen control net density is adequate.
- **Comparison across datasets** – Combs normalise curvature magnitudes, making it easy to compare different hull forms across stations or section planes.

## Comb Modalities Implemented
We expose three complementary modes that echo common CAD practice:

1. **Curve Combs** (`plotCurveCurvatureComb`)
   - Operate on any sampled 3D polyline (e.g., a hull station or waterline).
   - Estimate curvature using neighbouring samples and plot combs along the curve.
   - Ideal for close inspection of specific sections before committing to a full surface fit.

2. **Surface Iso-curve Combs** (`plotCurvatureCombs`)
   - Draw combs along selected parametric directions of a reconstructed surface.
   - Supports inclusion of the surface boundary so edge behaviour is assessed alongside interior iso-curves.
   - Colour-maps encode relative curvature magnitude, helping prioritise hot spots.

3. **Section Plane Combs** (`plotSectionCurvatureCombs`)
   - Intersect the surface with arbitrary axis-aligned planes, build polylines through the intersection curves, and render curve combs on those sections.
   - Useful for interrogating interior regions or highlighting curvature distribution along transverse cuts of the hull.

## How These Fit Into the Workflow
1. Load raw offsets, convert them to stations (`xyz2station`), and fit the B-spline surface (`BSplineFit3`).
2. Call `analyzeSmoothness` to obtain sampled point grids, normals, and curvature magnitudes.
3. Pick the visualization that matches the current investigation:
   - Spot-check a suspect station with `plotCurveCurvatureComb`.
   - Survey the full surface using `plotCurvatureCombs` with `'Direction','both'`.
   - Slice the surface with `plotSectionCurvatureCombs` to inspect internal fairness.
4. Iterate on control point counts or data conditioning until the combs reflect the desired smoothness.

## Demo Scripts
To reproduce the visuals quickly, launch MATLAB, run `startup`, and execute one of the sandbox demos:
- `demoCurvatureCombModes` – Shows all three modes on the `yatch_offset3.dat` hull.
- `cylinderCurvatureCombs` – Demonstrates combs on a canonical cylindrical surface.
- `exhaustCurvatureCombs` – Applies comb diagnostics to a tapered exhaust geometry.

These scripts can be adapted for your own datasets by swapping the input offsets or parameter settings.

## Interpretation Tips
- Short, uniform combs imply low curvature variation and good fairness.
- Rapid oscillations or alternating orientations indicate inflection-prone geometry that may need smoothing or re-fitting.
- When comparing surfaces, normalise comb scaling with the `'Scale'` parameter so differences reflect genuine curvature changes, not plotting artefacts.

Curvature comb visualisation is a proven, intuitive tool for hull reconstruction, blending geometric rigour with quick interpretability. Integrating these diagnostics into the BSpline3D-MATLAB workflow makes it easier to produce high-quality, production-ready surfaces from archival offset data.
