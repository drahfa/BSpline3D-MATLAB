function exhaustCurvatureCombs(CPs, CPw)
% EXHAUSTCURVATURECOMBS Exhaust pipe surface with curvature comb visuals.
%
% Builds on exhaustExample by fitting the tapered pipe offsets and rendering
% curvature combs for (1) a representative station curve, (2) surface
% iso-parametric directions including the edges, and (3) cross-sectional
% planes along the length of the pipe.
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
% INPUTS:
%   CPs - Number of control points desired in each station (default: 8)
%   CPw - Number of control points desired along the longitudinal direction
%         (default: 8)

if nargin < 1 || isempty(CPs)
    CPs = 8;
end
if nargin < 2 || isempty(CPw)
    CPw = 8;
end

YZ = load('circle.dat');
numSamples = size(YZ, 1);
YZscaled = YZ;

nStation1 = 10;
nStation2 = 15;
nStation3 = 20;

station = struct('x', cell(1, nStation3), ...
                 'y', cell(1, nStation3), ...
                 'z', cell(1, nStation3));

X = ones(numSamples, 1);
deltaX = 5;

% Region 1: uniform diameter
for s = 1:nStation1
    XYZ = [X YZ];
    station(s).x = XYZ(:, 1)';
    station(s).y = XYZ(:, 2)';
    station(s).z = XYZ(:, 3)';
    X = X + deltaX;
end

% Region 2: taper down the diameter
scaleMat = eye(2);
scaleDelta = 1;
for s = (nStation1 + 1):nStation2
    YZscaled = YZ * scaleMat;
    XYZ = [X YZscaled];
    station(s).x = XYZ(:, 1)';
    station(s).y = XYZ(:, 2)';
    station(s).z = XYZ(:, 3)';

    X = X + deltaX;
    scaleMat = scaleMat * scaleDelta;
    scaleDelta = max(scaleDelta - 0.1, 0.1);
end

% Region 3: constant reduced diameter
for s = (nStation2 + 1):nStation3
    XYZ = [X YZscaled];
    station(s).x = XYZ(:, 1)';
    station(s).y = XYZ(:, 2)';
    station(s).z = XYZ(:, 3)';
    X = X + deltaX;
end

[cpX, cpY, cpZ, stationMSE, waterlineMSE] = BSplineFit3(CPs, CPw, station);
fprintf('Exhaust fit metrics -> Station MSE: %.4f | Waterline MSE: %.4f\n', ...
    stationMSE, waterlineMSE);

[~, ~, surfaceData] = analyzeSmoothness(cpX, cpY, cpZ);
colormapChoice = parula(256);

fig = figure('Name', 'Exhaust Curvature Combs', 'Position', [90 90 1400 480]);
t = tiledlayout(fig, 1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

% Mode 1: Curvature comb on a mid-pipe station
ax1 = nexttile(t, 1);
stationIdx = round((nStation1 + nStation3) / 2);
stationCurve = [station(stationIdx).x', station(stationIdx).y', station(stationIdx).z'];
plotCurveCurvatureComb(stationCurve, ...
    'Axes', ax1, ...
    'CombSpacing', max(4, round(numSamples / 18)), ...
    'CombColormap', colormapChoice, ...
    'CurveLineWidth', 2.0);
view(ax1, [90 0]);
axis(ax1, 'equal');
ax1.Box = 'on';
ax1.Title.String = sprintf('Station Curve Comb (Station %d)', stationIdx);

% Mode 2: Surface iso-parametric combs
ax2 = nexttile(t, 2);
axes(ax2);
plotCurvatureCombs(surfaceData, ...
    'Direction', 'both', ...
    'NumCurves', 8, ...
    'IncludeEdges', true, ...
    'CombSpacing', 6, ...
    'SurfaceAlpha', 0.18, ...
    'CombColormap', colormapChoice, ...
    'BaseCurveLineWidth', 1.4, ...
    'CombLineWidth', 1.6);
view(ax2, [-40 18]);
ax2.Box = 'on';
ax2.Title.String = 'Surface Iso-curve Combs';

% Mode 3: Section planes intersecting the pipe
ax3 = nexttile(t, 3);
lengthAxis = surfaceData.points(:, :, 1);
sectionPlanes = linspace(min(lengthAxis, [], 'all'), max(lengthAxis, [], 'all'), 5);
sectionPlanes = sectionPlanes(2:4);
plotSectionCurvatureCombs(surfaceData, ...
    'Axis', 'x', ...
    'Values', sectionPlanes, ...
    'Axes', ax3, ...
    'CombSpacing', 6, ...
    'SurfaceAlpha', 0.08, ...
    'CombColormap', colormapChoice, ...
    'CurveLineWidth', 1.6, ...
    'CombLineWidth', 1.5);
view(ax3, [-40 18]);
ax3.Box = 'on';
ax3.Title.String = 'Section Plane Combs';

title(t, 'Curvature Comb Modes on Exhaust Surface');
end
