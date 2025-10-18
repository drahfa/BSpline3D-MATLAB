% DEMOSERIES60 Demonstrates B-spline fitting and surface plotting for Series 60 offsets
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
% This demo showcases how to:
%   1. Load the Series 60 station offsets
%   2. Convert the offsets into the station struct format
%   3. Fit a B-spline surface using BSplineFit3
%   4. Visualise the raw data, fitted surface, and control net

close all;

% Locate repository root and data folder
thisFileDir = fileparts(mfilename('fullpath'));
if isempty(thisFileDir)
    thisFileDir = pwd;
end
repoRoot = fileparts(thisFileDir);
addpath(fullfile(repoRoot, 'bsplineEngine3D'));

dataDir = fullfile(repoRoot, 'testData', 'Series60_offset');
offsetX = load(fullfile(dataDir, 'Series60Offset_x.dat'));
offsetY = load(fullfile(dataDir, 'Series60Offset_y.dat'));
offsetZ = load(fullfile(dataDir, 'Series60Offset_z.dat'));

[numStations, samplesPerStation] = size(offsetX);

% Convert matrices into the station struct expected by BSplineFit3
station = struct('x', cell(1, numStations), ...
                 'y', cell(1, numStations), ...
                 'z', cell(1, numStations));
for idx = 1:numStations
    station(idx).x = offsetX(idx, :);
    station(idx).y = offsetY(idx, :);
    station(idx).z = offsetZ(idx, :);
end

% Visualise the raw offset stations
figure('Name', 'Series 60 Offset Stations');
hold on; grid on;
for idx = 1:numStations
    plot3(station(idx).x, station(idx).y, station(idx).z, 'k.-', 'MarkerSize', 8);
end
axis equal;
xlabel('X (longitudinal)');
ylabel('Y (transverse)');
zlabel('Z (vertical)');
title('Series 60 Station Offsets');
view([-125 20]);
hold off;

% Choose control point counts (ensure at least cubic order)
stationControlPoints = max(6, min(9, numStations));
waterlineControlPoints = max(6, min(9, samplesPerStation));

% Fit the B-spline surface
[cpX, cpY, cpZ, stationMSE, waterlineMSE] = BSplineFit3(...
    stationControlPoints, waterlineControlPoints, station);

fprintf('Series 60 fit using %d x %d control points\n', ...
    stationControlPoints, waterlineControlPoints);
fprintf('  Station MSE   : %.6f\n', stationMSE);
fprintf('  Waterline MSE : %.6f\n', waterlineMSE);

% Generate a dense surface for visualisation
[surfX, surfY, surfZ] = generateBSplineSurface(cpX, cpY, cpZ, 0.02);

% Plot fitted surface, control net, and sample points
figure('Name', 'Series 60 B-spline Surface Fit');
colormap(parula);
sh = surf(surfX, surfY, surfZ, 'FaceColor', [0.82 0.88 0.98], ...
    'EdgeColor', 'none', 'FaceAlpha', 0.95);
hold on; grid on;
plot3(offsetX(:), offsetY(:), offsetZ(:), '.', 'Color', [0.2 0.2 0.2], ...
    'MarkerSize', 6);
plot3(cpX, cpY, cpZ, 'r-', 'LineWidth', 1.2);
plot3(cpX', cpY', cpZ', 'r-', 'LineWidth', 1.2);
plot3(cpX, cpY, cpZ, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 4);
axis equal;
xlabel('X (longitudinal)');
ylabel('Y (transverse)');
zlabel('Z (vertical)');
title('Series 60 B-spline Surface Fit');
view([-140 24]);
camlight headlight;
lighting gouraud;
hold off;

disp('Figures generated:');
disp('  1. Series 60 Station Offsets');
disp('  2. Series 60 B-spline Surface Fit');
