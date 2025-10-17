function plotSectionCurvatureCombs(surfaceData, varargin)
% PLOTSECTIONCURVATURECOMBS Plot curvature combs on planar sections of a surface.
%
%   plotSectionCurvatureCombs(surfaceData) extracts evenly spaced planar
%   sections of the sampled surface contained in surfaceData and renders
%   curvature combs along each intersection curve. The helper complements
%   plotCurvatureCombs by visualising curvature on cross-sectional slices.
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
%   Name-value options:
%     'Axis'           : Section axis 'x', 'y', or 'z' (default 'x')
%     'Values'         : Explicit axis values for the section planes
%     'CombSpacing'    : Sampling stride along each section curve
%     'Scale'          : Global scaling factor for comb length
%     'CurveLineWidth' : Width of section polylines (default 1.8)
%     'CombLineWidth'  : Width of comb segments (default 1.5)
%     'CombColormap'   : Colormap for curvature magnitude (default parula)
%     'ShowEnvelope'   : Draw connecting ridge through comb tips (default true)
%     'EnvelopeColor'  : Colour of envelope ridge (default red tone)
%     'SurfaceColor'   : Base surface colour (default light blue)
%     'SurfaceAlpha'   : Transparency for base surface (default 0.12)
%     'Axes'           : Target axes handle (default gca)
%
p = inputParser;
p.FunctionName = mfilename;
p.addParameter('Axis', 'x', @(c) ischar(c) || (isstring(c) && isscalar(c)));
p.addParameter('Values', [], @(x) isempty(x) || (isnumeric(x) && isvector(x)));
p.addParameter('CombSpacing', [], @(x) isempty(x) || (isscalar(x) && x >= 1));
p.addParameter('Scale', [], @(x) isempty(x) || (isscalar(x) && x > 0));
p.addParameter('CurveLineWidth', 1.8, @(x) isnumeric(x) && isscalar(x) && x > 0);
p.addParameter('CombLineWidth', 1.5, @(x) isnumeric(x) && isscalar(x) && x > 0);
p.addParameter('CombColormap', parula(256), @(x) isnumeric(x) && size(x, 2) == 3);
p.addParameter('ShowEnvelope', true, @(x) islogical(x) && isscalar(x));
p.addParameter('EnvelopeColor', [0.8 0.15 0.15], @(x) isnumeric(x) && numel(x) == 3);
p.addParameter('SurfaceColor', [0.85 0.9 0.95], @(x) isnumeric(x) && numel(x) == 3);
p.addParameter('SurfaceAlpha', 0.12, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x <= 1);
p.addParameter('Axes', [], @(x) isempty(x) || isgraphics(x, 'axes'));
p.parse(varargin{:});
args = p.Results;

points = surfaceData.points;
validateattributes(points, {'numeric'}, {'ndims', 3, 'size', size(surfaceData.points)}, ...
    mfilename, 'surfaceData.points');

[nU, nV, ~] = size(points);
if nU < 2 || nV < 2
    error('%s:InsufficientSampling', mfilename, ...
        'surfaceData.points must contain a regular grid of at least 2x2.');
end

axisChar = char(lower(args.Axis));
axisIdx = find('xyz' == axisChar, 1);
if isempty(axisIdx)
    error('%s:InvalidAxis', mfilename, 'Axis must be ''x'', ''y'', or ''z''.');
end

coordValues = squeeze(points(:, :, axisIdx));
coordMin = min(coordValues, [], 'all');
coordMax = max(coordValues, [], 'all');

if isempty(args.Values)
    sectionValues = linspace(coordMin, coordMax, 5);
    sectionValues = sectionValues(2:end-1);
else
    sectionValues = unique(args.Values(:)');
end

ax = args.Axes;
if isempty(ax)
    ax = gca;
end

hold(ax, 'on');

surf(ax, squeeze(points(:, :, 1)), squeeze(points(:, :, 2)), squeeze(points(:, :, 3)), ...
    'FaceColor', args.SurfaceColor, 'FaceAlpha', args.SurfaceAlpha, ...
    'EdgeColor', [0.85 0.9 0.95], 'LineStyle', '-');

colormap(ax, args.CombColormap);

sectionColors = lines(max(numel(sectionValues), 1));

tol = 1e-5 * max(coordMax - coordMin, 1);
if tol <= 0
    tol = 1e-5;
end

for sIdx = 1:numel(sectionValues)
    planeValue = sectionValues(sIdx);
    curves = extractSectionCurves(points, axisIdx, planeValue, tol);
    if isempty(curves)
        continue;
    end

    thisColor = sectionColors(min(sIdx, size(sectionColors, 1)), :);

    for cIdx = 1:numel(curves)
        curve = curves{cIdx};
        if size(curve, 1) < 3
            continue;
        end
        curve(:, axisIdx) = planeValue; % enforce planarity numerically

        plotCurveCurvatureComb(curve, ...
            'Axes', ax, ...
            'CombSpacing', args.CombSpacing, ...
            'Scale', args.Scale, ...
            'CurveColor', thisColor, ...
            'CurveLineWidth', args.CurveLineWidth, ...
            'CombLineWidth', args.CombLineWidth, ...
            'CombColormap', args.CombColormap, ...
            'ShowEnvelope', args.ShowEnvelope, ...
            'EnvelopeColor', args.EnvelopeColor);
    end
end

axis(ax, 'equal');
grid(ax, 'on');
xlabel(ax, 'X');
ylabel(ax, 'Y');
zlabel(ax, 'Z');
title(ax, sprintf('Section Curvature Combs (%s axis)', upper(axisChar)));

view(ax, 3);

end

function curves = extractSectionCurves(points, axisIdx, planeValue, tol)
[nU, nV, ~] = size(points);
segments = cell(0, 1);

for i = 1:(nU - 1)
    for j = 1:(nV - 1)
        quad = [squeeze(points(i, j, :))';
                squeeze(points(i + 1, j, :))';
                squeeze(points(i + 1, j + 1, :))';
                squeeze(points(i, j + 1, :))'];
        seg = intersectQuadWithPlane(quad, axisIdx, planeValue, tol);
        if ~isempty(seg)
            segments{end + 1, 1} = seg; %#ok<AGROW>
        end
    end
end

curves = assemblePolylines(segments, tol);
end

function segment = intersectQuadWithPlane(quadPts, axisIdx, planeValue, tol)
edges = [1 2; 2 3; 3 4; 4 1];
hits = zeros(0, 3);

for e = 1:size(edges, 1)
    p1 = quadPts(edges(e, 1), :);
    p2 = quadPts(edges(e, 2), :);
    f1 = p1(axisIdx) - planeValue;
    f2 = p2(axisIdx) - planeValue;

    if abs(f1) <= tol && abs(f2) <= tol
        hits = [hits; p1; p2]; %#ok<AGROW>
    elseif abs(f1) <= tol
        hits = [hits; p1]; %#ok<AGROW>
    elseif abs(f2) <= tol
        hits = [hits; p2]; %#ok<AGROW>
    elseif f1 * f2 < 0
        t = f1 / (f1 - f2);
        hits = [hits; p1 + t * (p2 - p1)]; %#ok<AGROW>
    end
end

if isempty(hits)
    segment = [];
    return;
end

hits = uniquetol(hits, tol, 'ByRows', true);

if size(hits, 1) < 2
    segment = [];
    return;
elseif size(hits, 1) == 2
    segment = hits;
else
    % Select the farthest pair to form a stable segment
    maxDist = 0;
    pairIdx = [1 2];
    for a = 1:size(hits, 1)
        for b = (a + 1):size(hits, 1)
            dist = norm(hits(a, :) - hits(b, :));
            if dist > maxDist
                maxDist = dist;
                pairIdx = [a b];
            end
        end
    end
    segment = hits(pairIdx, :);
end
end

function curves = assemblePolylines(segments, tol)
curves = {};
if isempty(segments)
    return;
end

used = false(numel(segments), 1);

while true
    idx = find(~used, 1);
    if isempty(idx)
        break;
    end

    poly = segments{idx};
    used(idx) = true;
    poly = enforceUnique(poly, tol);

    extended = true;
    while extended
        extended = false;
        for sIdx = find(~used)'
            segment = enforceUnique(segments{sIdx}, tol);
            [polyNew, attached] = attachSegment(poly, segment, tol);
            if attached
                poly = polyNew;
                used(sIdx) = true;
                extended = true;
                break;
            end
        end
    end

    poly = enforceUnique(poly, tol);
    if size(poly, 1) >= 3
        if norm(poly(1, :) - poly(end, :)) <= tol
            poly(end, :) = poly(1, :);
        end
        curves{end + 1, 1} = poly; %#ok<AGROW>
    end
end
end

function ptsOut = enforceUnique(pts, tol)
if isempty(pts)
    ptsOut = pts;
    return;
end

mask = true(size(pts, 1), 1);
for i = 2:size(pts, 1)
    if norm(pts(i, :) - pts(i - 1, :)) <= tol
        mask(i) = false;
    end
end
ptsOut = pts(mask, :);

if size(ptsOut, 1) >= 2 && norm(ptsOut(1, :) - ptsOut(end, :)) <= tol
    ptsOut(end, :) = ptsOut(1, :);
end
end

function [polyOut, attached] = attachSegment(poly, segment, tol)
attached = false;
polyOut = poly;

if isempty(segment)
    return;
end

if isempty(poly)
    polyOut = segment;
    attached = true;
    return;
end

% Try appending to the end
if norm(poly(end, :) - segment(1, :)) <= tol
    polyOut = [poly; segment(2, :)]; %#ok<AGROW>
    attached = true;
    return;
elseif norm(poly(end, :) - segment(end, :)) <= tol
    polyOut = [poly; segment(1, :)]; %#ok<AGROW>
    attached = true;
    return;
end

% Try prepending to the start
if norm(poly(1, :) - segment(end, :)) <= tol
    polyOut = [segment(1, :); poly]; %#ok<AGROW>
    attached = true;
elseif norm(poly(1, :) - segment(1, :)) <= tol
    polyOut = [segment(2, :); poly]; %#ok<AGROW>
    attached = true;
end
end
