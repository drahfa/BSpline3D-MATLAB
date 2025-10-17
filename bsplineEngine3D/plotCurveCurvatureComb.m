function plotCurveCurvatureComb(curvePoints, varargin)
% PLOTCURVATURECOMBC Draw curvature combs along a space curve.
%
%   plotCurveCurvatureComb(points) renders a classical curvature comb where
%   comb lengths are proportional to the estimated curvature along the
%   supplied polyline. The input can be an N-by-3 array or a cell array of
%   such arrays.
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
%   Name-value options:
%     'CombSpacing'    : Sampling stride along the curve (default auto)
%     'Scale'          : Global scaling factor for comb length
%     'CurveColor'     : Color of the base curve (default navy tone)
%     'CurveLineWidth' : Width of the base curve line (default 1.8)
%     'CombLineWidth'  : Width of the comb segments (default 1.5)
%     'CombColormap'   : Colormap used for curvature magnitude (default parula)
%     'ShowEnvelope'   : Draw ridge through comb tips (default true)
%     'EnvelopeColor'  : Color of the envelope ridge (default red tone)
%     'Axes'           : Target axes handle (default gca)
%
p = inputParser;
p.FunctionName = mfilename;
p.addParameter('CombSpacing', [], @(x) isempty(x) || (isscalar(x) && x >= 1));
p.addParameter('Scale', [], @(x) isempty(x) || (isscalar(x) && x > 0));
p.addParameter('CurveColor', [0.05 0.25 0.55], @(x) isnumeric(x) && numel(x) == 3);
p.addParameter('CurveLineWidth', 1.8, @(x) isnumeric(x) && isscalar(x) && x > 0);
p.addParameter('CombLineWidth', 1.5, @(x) isnumeric(x) && isscalar(x) && x > 0);
p.addParameter('CombColormap', parula(256), @(x) isnumeric(x) && size(x, 2) == 3);
p.addParameter('ShowEnvelope', true, @(x) islogical(x) && isscalar(x));
p.addParameter('EnvelopeColor', [0.8 0.15 0.15], @(x) isnumeric(x) && numel(x) == 3);
p.addParameter('Axes', [], @(x) isempty(x) || isgraphics(x, 'axes'));
p.parse(varargin{:});
args = p.Results;

if iscell(curvePoints)
    for idx = 1:numel(curvePoints)
        plotCurveCurvatureComb(curvePoints{idx}, varargin{:});
    end
    return;
end

validateattributes(curvePoints, {'numeric'}, {'2d', 'ncols', 3, 'finite'}, ...
    mfilename, 'curvePoints');

numPoints = size(curvePoints, 1);
if numPoints < 3
    warning('%s:InsufficientPoints', mfilename, ...
        'At least three points are required to estimate curvature.');
    return;
end

ax = args.Axes;
if isempty(ax)
    ax = gca;
end

holdState = ishold(ax);
hold(ax, 'on');

plot3(ax, curvePoints(:, 1), curvePoints(:, 2), curvePoints(:, 3), ...
    'Color', args.CurveColor, 'LineWidth', args.CurveLineWidth);

bbox = [max(curvePoints, [], 1) - min(curvePoints, [], 1)];
defaultScale = 0.12 * norm(bbox);
if defaultScale <= 0
    defaultScale = 1;
end

baseScale = defaultScale;
if ~isempty(args.Scale)
    baseScale = args.Scale;
end

[curveNormals, curvatureMag] = estimateCurveGeometry(curvePoints);

validMask = ~any(isnan(curveNormals), 2) & curvatureMag > 0;
validIdx = find(validMask);
if numel(validIdx) < 2
    if ~holdState
        hold(ax, 'off');
    end
    return;
end

maxCurvature = max(curvatureMag(validIdx));
if maxCurvature <= eps
    maxCurvature = 1;
end

if isempty(args.CombSpacing)
    % Target ~25 combs along the curve by default
    stride = max(1, floor(numel(validIdx) / 25));
else
    stride = max(1, round(args.CombSpacing));
end

sampleIdx = validIdx(1:stride:end);
if sampleIdx(end) ~= validIdx(end)
    sampleIdx(end+1) = validIdx(end); %#ok<AGROW>
end

combPatchBase = zeros(0, 3);
combPatchTip = zeros(0, 3);
combColors = zeros(0, 3);

for k = 1:numel(sampleIdx)
    idxSample = sampleIdx(k);
    basePoint = curvePoints(idxSample, :);
    normalVec = curveNormals(idxSample, :);
    if any(isnan(normalVec))
        continue;
    end

    curvatureVal = curvatureMag(idxSample);
    if curvatureVal <= eps
        continue;
    end

    combLength = baseScale * (curvatureVal / maxCurvature);
    tipPoint = basePoint + normalVec * combLength;

    colorIdx = max(1, min(size(args.CombColormap, 1), ...
        round((curvatureVal / maxCurvature) * (size(args.CombColormap, 1) - 1)) + 1));
    combColor = args.CombColormap(colorIdx, :);

    line(ax, [basePoint(1) tipPoint(1)], ...
        [basePoint(2) tipPoint(2)], ...
        [basePoint(3) tipPoint(3)], ...
        'Color', combColor, 'LineWidth', args.CombLineWidth, ...
        'Marker', 'o', 'MarkerIndices', 1, 'MarkerSize', 3, ...
        'MarkerFaceColor', combColor, 'MarkerEdgeColor', 'none');

    combPatchBase(end+1, :) = basePoint; %#ok<AGROW>
    combPatchTip(end+1, :) = tipPoint; %#ok<AGROW>
    combColors(end+1, :) = combColor; %#ok<AGROW>
end

if args.ShowEnvelope && size(combPatchTip, 1) >= 2
    line(ax, combPatchTip(:, 1), combPatchTip(:, 2), combPatchTip(:, 3), ...
        'Color', args.EnvelopeColor, 'LineWidth', args.CombLineWidth * 0.8);
end

if size(combPatchTip, 1) >= 2
    for q = 1:(size(combPatchTip, 1) - 1)
        quad = [combPatchBase(q, :);
                combPatchTip(q, :);
                combPatchTip(q + 1, :);
                combPatchBase(q + 1, :)];
        patch('Parent', ax, ...
            'XData', quad(:, 1), 'YData', quad(:, 2), 'ZData', quad(:, 3), ...
            'FaceColor', mean(combColors(q:q+1, :), 1), ...
            'FaceAlpha', 0.2, 'EdgeColor', 'none');
    end
end

if ~holdState
    hold(ax, 'off');
end

axis(ax, 'equal');
grid(ax, 'on');

end

function [normals, curvatureMag] = estimateCurveGeometry(points)
numPoints = size(points, 1);
normals = nan(numPoints, 3);
curvatureMag = zeros(numPoints, 1);

if numPoints < 3
    return;
end

prevNormal = [];

for i = 2:(numPoints - 1)
    pPrev = points(i - 1, :);
    pCurr = points(i, :);
    pNext = points(i + 1, :);

    d1 = pNext - pPrev;
    d2 = pNext - 2 * pCurr + pPrev;

    if norm(d1) < 1e-8
        continue;
    end

    binormal = cross(d1, d2);
    binormMag = norm(binormal);
    if binormMag < 1e-10
        continue;
    end

    tangent = d1 / norm(d1);
    normalVec = cross(binormal, tangent);
    normalMag = norm(normalVec);
    if normalMag < 1e-10
        continue;
    end

    normalVec = normalVec / normalMag;
    if ~isempty(prevNormal) && dot(normalVec, prevNormal) < 0
        normalVec = -normalVec;
    end

    normals(i, :) = normalVec;
    curvatureMag(i) = binormMag / (norm(d1)^3 + eps);
    prevNormal = normalVec;
end

% Use nearest valid normals for endpoints
firstValid = find(~any(isnan(normals), 2), 1, 'first');
lastValid = find(~any(isnan(normals), 2), 1, 'last');

if ~isempty(firstValid)
    normals(1:firstValid, :) = repmat(normals(firstValid, :), firstValid, 1);
    curvatureMag(1:firstValid) = repmat(curvatureMag(firstValid), firstValid, 1);
end

if ~isempty(lastValid)
    tailCount = numPoints - lastValid + 1;
    normals(lastValid:end, :) = repmat(normals(lastValid, :), tailCount, 1);
    curvatureMag(lastValid:end) = repmat(curvatureMag(lastValid), tailCount, 1);
end

end
