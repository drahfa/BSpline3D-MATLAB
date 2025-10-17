function plotCurvatureCombs(surfaceData, varargin)
% PLOTCURVATURECOMBS Visualize curvature combs on a sampled B-spline surface.
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
%   plotCurvatureCombs(surfaceData) renders stylized curvature combs by
%   drawing surface normals whose lengths are proportional to the local
%   Gaussian curvature magnitude. The combs are drawn along a set of iso-
%   curves, producing a visualization similar to traditional curve combs.
%
%   plotCurvatureCombs(surfaceData, Name, Value, ...) customizes appearance:
%     'Direction'         : 'u', 'v', or 'both' (default: 'v')
%     'NumCurves'         : Number of iso-curves per direction (default: 6)
%     'CurveIndices'      : Explicit indices of iso-curves (overrides NumCurves)
%     'CombSpacing'       : Sampling stride along each iso-curve (default auto)
%     'Scale'             : Manual scaling factor for comb length
%     'SurfaceColor'      : Base color for surface patch
%     'SurfaceAlpha'      : Transparency for surface patch (0-1)
%     'BaseCurveColor'    : Color of the iso-curve centerlines
%     'BaseCurveLineWidth': Line width for iso-curve centerlines
%     'CombLineWidth'     : Line width for comb segments
%     'CombColormap'      : Colormap array for mapping curvature magnitudes
%     'ShowEnvelope'      : Whether to draw a connecting ridge through comb tips
%     'EnvelopeColor'     : Color for the envelope ridge
%
%   Comb orientations flip automatically when the discrete curvature sign
%   changes, highlighting inflection regions.
%
%   surfaceData must contain the fields:
%     - points   : nU-by-nV-by-3 array of sampled surface coordinates
%     - normals  : nU-by-nV-by-3 array of unit normals
%     - curvature: nU-by-nV array of (non-negative) curvature magnitudes
%
p = inputParser;
p.FunctionName = mfilename;
p.addParameter('Direction', 'v', @(c) any(strcmpi(c, {'u', 'v', 'both'})));
p.addParameter('NumCurves', 6, @(x) isnumeric(x) && isscalar(x) && x >= 1);
p.addParameter('CurveIndices', [], @(x) isnumeric(x) && isvector(x));
p.addParameter('CombSpacing', [], @(x) isempty(x) || (isscalar(x) && x >= 1));
p.addParameter('Scale', [], @(x) isempty(x) || (isscalar(x) && x > 0));
p.addParameter('SurfaceColor', [0.85 0.9 0.95], @(x) isnumeric(x) && numel(x) == 3);
p.addParameter('SurfaceAlpha', 0.15, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x <= 1);
p.addParameter('BaseCurveColor', [0.05 0.25 0.55], @(x) isnumeric(x) && numel(x) == 3);
p.addParameter('BaseCurveLineWidth', 1.2, @(x) isnumeric(x) && isscalar(x) && x > 0);
p.addParameter('CombLineWidth', 1.5, @(x) isnumeric(x) && isscalar(x) && x > 0);
p.addParameter('CombColormap', parula(256), @(x) isnumeric(x) && size(x, 2) == 3);
p.addParameter('ShowEnvelope', true, @(x) islogical(x) && isscalar(x));
p.addParameter('EnvelopeColor', [0.8 0.15 0.15], @(x) isnumeric(x) && numel(x) == 3);
p.addParameter('IncludeEdges', true, @(x) islogical(x) && isscalar(x));
% Backwards-compatibility alias for legacy 'Spacing' parameter
p.addParameter('Spacing', [], @(x) isempty(x) || (isscalar(x) && x >= 1));
p.parse(varargin{:});
args = p.Results;

if isempty(args.CombSpacing) && ~isempty(args.Spacing)
    args.CombSpacing = args.Spacing;
end

points = surfaceData.points;
normals = surfaceData.normals;
curvature = surfaceData.curvature;

validateattributes(points, {'numeric'}, {'ndims', 3, 'nonempty'}, mfilename, 'surfaceData.points');
validateattributes(normals, {'numeric'}, {'size', size(points)}, mfilename, 'surfaceData.normals');
validateattributes(curvature, {'numeric'}, {'size', [size(points, 1), size(points, 2)]}, mfilename, 'surfaceData.curvature');

[nU, nV, ~] = size(points);
maxCurvature = max(abs(curvature(:)));
if maxCurvature <= eps
    maxCurvature = 1;
end

bbox = [max(points(:, :, 1), [], 'all') - min(points(:, :, 1), [], 'all'), ...
        max(points(:, :, 2), [], 'all') - min(points(:, :, 2), [], 'all'), ...
        max(points(:, :, 3), [], 'all') - min(points(:, :, 3), [], 'all')];
defaultScale = 0.12 * norm(bbox);
if defaultScale <= 0
    defaultScale = 1;
end

baseScale = defaultScale;
if ~isempty(args.Scale)
    baseScale = args.Scale;
end

if isempty(args.CombSpacing)
    sampleLength = min(nU, nV);
    args.CombSpacing = max(2, floor(sampleLength / 25));
else
    args.CombSpacing = max(1, round(args.CombSpacing));
end

holdState = ishold;
hold on;

surf(squeeze(points(:, :, 1)), squeeze(points(:, :, 2)), squeeze(points(:, :, 3)), ...
    'FaceColor', args.SurfaceColor, 'FaceAlpha', args.SurfaceAlpha, ...
    'EdgeColor', [0.8 0.85 0.9]);

axis equal;
grid on;
colormap(args.CombColormap);

plotDirection(args.Direction, 'u');
plotDirection(args.Direction, 'v');

if ~holdState
    hold off;
end

view(3);
xlabel('X');
ylabel('Y');
zlabel('Z');
title('Curvature Combs (Normals Scaled by Gaussian Curvature)');

    function plotDirection(userDir, currentDir)
        if strcmpi(userDir, 'both') || strcmpi(userDir, currentDir)
            if strcmpi(currentDir, 'u')
                primaryLen = nV;
                secondaryLen = nU;
            else
                primaryLen = nU;
                secondaryLen = nV;
            end

            curveIdx = args.CurveIndices;
            interiorStart = 2;
            interiorEnd = primaryLen - 1;

            if isempty(curveIdx)
                interiorCount = max(0, interiorEnd - interiorStart + 1);
                curveIdx = [];
                if interiorCount > 0
                    numCurves = min(interiorCount, max(1, round(args.NumCurves)));
                    if numCurves == 1
                        curveIdx = round((interiorStart + interiorEnd) / 2);
                    else
                        interiorSamples = linspace(interiorStart, interiorEnd, numCurves);
                        curveIdx = unique(round(interiorSamples));
                    end
                end
            else
                curveIdx = unique(round(curveIdx));
                if args.IncludeEdges
                    keepMask = curveIdx >= 1 & curveIdx <= primaryLen;
                else
                    keepMask = curveIdx >= interiorStart & curveIdx <= interiorEnd;
                end
                curveIdx = curveIdx(keepMask);
            end

            if args.IncludeEdges && primaryLen >= 1
                curveIdx = unique([curveIdx(:); 1; primaryLen]); %#ok<AGROW>
            end

            curveIdx = curveIdx(:)';
            if isempty(curveIdx)
                return;
            end

            combSpacing = args.CombSpacing;

            for c = curveIdx
                if strcmpi(currentDir, 'u')
                    curvePts = squeeze(points(c, :, :));
                    curveNormals = squeeze(normals(c, :, :));
                    curveCurvature = curvature(c, :);
                else
                    curvePts = squeeze(points(:, c, :));
                    curveNormals = squeeze(normals(:, c, :));
                    curveCurvature = curvature(:, c);
                end

                curvePts = ensureRowMajor(curvePts, secondaryLen);
                curveNormals = ensureRowMajor(curveNormals, secondaryLen);

                plot3(curvePts(:, 1), curvePts(:, 2), curvePts(:, 3), ...
                    'Color', args.BaseCurveColor, 'LineWidth', args.BaseCurveLineWidth);

                sampleIdx = 1:combSpacing:secondaryLen;
                if sampleIdx(end) ~= secondaryLen
                    sampleIdx = [sampleIdx, secondaryLen]; %#ok<AGROW>
                end
                combEnvelope = zeros(0, 3);
                combBase = zeros(0, 3);
                combColors = zeros(0, 3);
                for idxSample = sampleIdx
                    startPoint = curvePts(idxSample, :);
                    normalVec = curveNormals(idxSample, :);

                    if any(isnan(startPoint)) || any(isnan(normalVec))
                        continue;
                    end

                    normalMag = norm(normalVec);
                    if normalMag < 1e-8
                        continue;
                    end
                    normalVec = normalVec / normalMag;

                    if idxSample == 1
                        prevPoint = startPoint - (curvePts(min(idxSample + 1, secondaryLen), :) - startPoint);
                    else
                        prevPoint = curvePts(idxSample - 1, :);
                    end

                    if idxSample == secondaryLen
                        nextPoint = startPoint + (startPoint - curvePts(max(idxSample - 1, 1), :));
                    else
                        nextPoint = curvePts(idxSample + 1, :);
                    end

                    tanPrev = startPoint - prevPoint;
                    tanNext = nextPoint - startPoint;
                    if norm(tanPrev) < 1e-8 || norm(tanNext) < 1e-8
                        continue;
                    end
                    tanPrev = tanPrev / norm(tanPrev);
                    tanNext = tanNext / norm(tanNext);

                    binormal = cross(tanPrev, tanNext);
                    signVal = sign(dot(binormal, normalVec));
                    if signVal == 0
                        signVal = 1;
                    end

                    curvatureMag = abs(curveCurvature(idxSample));
                    if curvatureMag < eps
                        continue;
                    end

                    combLength = baseScale * (curvatureMag / maxCurvature);
                    endPoint = startPoint + normalVec * combLength * signVal;
                    combEnvelope(end+1, :) = endPoint; %#ok<AGROW>
                    combBase(end+1, :) = startPoint; %#ok<AGROW>

                    colorIdx = max(1, min(size(args.CombColormap, 1), ...
                        round((curvatureMag / maxCurvature) * (size(args.CombColormap, 1) - 1)) + 1));
                    combColor = args.CombColormap(colorIdx, :);
                    if signVal < 0
                        combColor = min(1, combColor * 0.6 + 0.4);
                    end
                    combColors(end+1, :) = combColor; %#ok<AGROW>

                    line([startPoint(1) endPoint(1)], ...
                         [startPoint(2) endPoint(2)], ...
                         [startPoint(3) endPoint(3)], ...
                         'Color', combColor, 'LineWidth', args.CombLineWidth, ...
                         'Marker', 'o', 'MarkerIndices', 1, ...
                         'MarkerSize', 3, 'MarkerFaceColor', combColor, ...
                         'MarkerEdgeColor', 'none');
                end

                if args.ShowEnvelope && size(combEnvelope, 1) >= 2
                    plot3(combEnvelope(:, 1), combEnvelope(:, 2), combEnvelope(:, 3), ...
                        'Color', args.EnvelopeColor, 'LineWidth', args.CombLineWidth * 0.8, ...
                        'LineStyle', '-');
                end

                if size(combEnvelope, 1) >= 2
                    for segIdx = 1:(size(combEnvelope, 1) - 1)
                        quad = [combBase(segIdx, :);
                                combEnvelope(segIdx, :);
                                combEnvelope(segIdx + 1, :);
                                combBase(segIdx + 1, :)];
                        quadColor = mean(combColors(segIdx:segIdx + 1, :), 1);
                        patch('XData', quad(:, 1), 'YData', quad(:, 2), 'ZData', quad(:, 3), ...
                            'FaceColor', quadColor, 'FaceAlpha', 0.18, 'EdgeColor', 'none');
                    end
                end
            end
        end
    end

    function dataOut = ensureRowMajor(dataIn, expectedRows)
        dataOut = squeeze(dataIn);
        if isempty(dataOut)
            dataOut = zeros(expectedRows, 3);
            return;
        end
        if size(dataOut, 2) ~= 3 && size(dataOut, 1) == 3
            dataOut = dataOut.';
        end
        if size(dataOut, 2) ~= 3
            error('plotCurvatureCombs:InvalidDataShape', ...
                'Expected data with three coordinate columns.');
        end
        if size(dataOut, 1) ~= expectedRows
            if numel(dataOut) ~= expectedRows * 3
                error('plotCurvatureCombs:InvalidDataShape', ...
                    'Data cannot be reshaped to the expected size.');
            end
            dataOut = reshape(dataOut, expectedRows, 3);
        end
    end
end
