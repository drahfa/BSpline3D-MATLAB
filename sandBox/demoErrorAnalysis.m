% DEMOERRORANALYSIS Demonstrates B-spline fitting with smoothness and error analysis
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
% This example demonstrates:
% 1. Loading 3D offset data
% 2. B-spline surface fitting
% 3. Smoothness analysis (curvature-based)
% 4. Curvature comb visualization
% 5. Error visualization with error bars
% 6. Statistical error metrics

close all;
clc;

fprintf('=== B-Spline Surface Fitting with Error Analysis ===\n\n');

%% 1. Load the data
fprintf('Step 1: Loading yacht offset data...\n');
xyz = load('yatch_offset3.dat');
fprintf('  Loaded %d data points\n\n', size(xyz, 1));

%% 2. Convert to station structure
fprintf('Step 2: Converting to station structure...\n');
station_xyz = xyz2station(xyz);
fprintf('  Created %d stations\n\n', length(station_xyz));

%% 3. Fit B-spline surface
fprintf('Step 3: Fitting B-spline surface...\n');
station_control_points = 6;
longitudinal_control_points = 6;

[cpX, cpY, cpZ, stationMSE, waterlineMSE] = BSplineFit3(...
    station_control_points, longitudinal_control_points, station_xyz);

fprintf('  Station MSE: %.6f\n', stationMSE);
fprintf('  Waterline MSE: %.6f\n\n', waterlineMSE);

%% 4. Generate fitted surface
fprintf('Step 4: Generating fitted surface...\n');
figure('Name', 'Standard B-Spline Surface Visualization', 'Position', [50 50 800 600]);
[u, v, w] = BSplineSurf(cpX, cpY, cpZ);
view([-90 -4]);
axis equal;
title('Standard B-Spline Surface Fit');
fprintf('  Surface generated successfully\n\n');

%% 5. Analyze surface smoothness
fprintf('Step 5: Analyzing surface smoothness...\n');
[curvature, smoothness_metric, smoothness_data] = analyzeSmoothness(cpX, cpY, cpZ);

% Visualize curvature
figure('Name', 'Surface Smoothness Analysis', 'Position', [100 100 1000 400]);

subplot(1, 2, 1);
imagesc(curvature);
colorbar;
colormap(jet);
title('Gaussian Curvature Distribution');
xlabel('V Parameter');
ylabel('U Parameter');
axis equal tight;

subplot(1, 2, 2);
histogram(curvature(:), 50);
xlabel('Curvature Value');
ylabel('Frequency');
title('Curvature Distribution Histogram');
grid on;

fprintf('\n');

%% 6. Plot curvature combs
fprintf('Step 6: Plotting curvature combs...\n');
figure('Name', 'Curvature Combs Visualization', 'Position', [120 120 900 600]);
if exist('turbo', 'builtin') || exist('turbo', 'file')
    combMap = turbo(256);
else
    combMap = parula(256);
end
plotCurvatureCombs(smoothness_data, ...
    'Direction', 'u', ...
    'NumCurves', 30, ...
    'CombSpacing', 10, ...
    'SurfaceAlpha', 0.2, ...
    'SurfaceColor', [0.92 0.95 1.0], ...
    'BaseCurveColor', [0.15 0.25 0.55], ...
    'BaseCurveLineWidth', 1.6, ...
    'CombLineWidth', 1.8, ...
    'EnvelopeColor', [0.86 0.2 0.2], ...
    'CombColormap', combMap);
view([-120 25]);
fprintf('  Curvature combs plotted successfully\n\n');

%% 7. Visualize fitting errors with error bars
fprintf('Step 7: Computing and visualizing fitting errors...\n');
visualizeError(cpX, cpY, cpZ, xyz, station_xyz);

fprintf('\n=== Analysis Complete ===\n');
fprintf('Generated figures:\n');
fprintf('  1. Standard B-Spline Surface Visualization\n');
fprintf('  2. Surface Smoothness Analysis\n');
fprintf('  3. Curvature Combs Visualization\n');
fprintf('  4. B-Spline Surface Fitting Error Analysis\n');
fprintf('\nCheck the figures for detailed visualizations!\n');
