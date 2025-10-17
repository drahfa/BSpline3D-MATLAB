function [X, Y, Z, surfacePoints] = generateBSplineSurface(CPx, CPy, CPz, uStep, vStep)
% GENERATEBSPLINESURFACE Produce a sampled B-spline surface from control points.
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
%   [X, Y, Z, surfacePoints] = generateBSplineSurface(CPx, CPy, CPz) returns
%   gridded surface coordinates (X, Y, Z) and the flattened list of sampled
%   surface points (surfacePoints) computed from the supplied control point
%   matrices CPx, CPy, and CPz. The surface is sampled on a uniform grid with
%   default step size 0.05 for both the U and V parametric directions.
%
%   [...] = generateBSplineSurface(..., uStep, vStep) allows custom sampling
%   step sizes along the U and V directions respectively. If vStep is omitted,
%   it defaults to uStep.
%
%   This helper isolates the surface generation logic that previously lived as
%   a local function inside visualizeError.m so it can be reused without
%   redefining functions.
%
%   Inputs:
%     CPx, CPy, CPz : Control point matrices as returned by BSplineFit3.
%     uStep         : Optional parametric sampling interval along U.
%     vStep         : Optional parametric sampling interval along V.
%
%   Outputs:
%     X, Y, Z       : Matrices describing the surface suitable for surf().
%     surfacePoints : Flattened N-by-3 array of sampled surface coordinates.

if nargin < 4 || isempty(uStep)
    uStep = 0.05;
end

if nargin < 5 || isempty(vStep)
    vStep = uStep;
end

validateattributes(CPx, {'numeric'}, {'2d', 'nonempty'}, mfilename, 'CPx', 1);
validateattributes(CPy, {'numeric'}, {'size', size(CPx)}, mfilename, 'CPy', 2);
validateattributes(CPz, {'numeric'}, {'size', size(CPx)}, mfilename, 'CPz', 3);
validateattributes(uStep, {'numeric'}, {'scalar', '>', 0, '<=', 1}, mfilename, 'uStep', 4);
validateattributes(vStep, {'numeric'}, {'scalar', '>', 0, '<=', 1}, mfilename, 'vStep', 5);

% Construct uniform knot vectors matching the original implementation.
maxU = size(CPx, 1) - 3;
maxV = size(CPx, 2) - 3;
if maxU <= 0 || maxV <= 0
    error('generateBSplineSurface:InvalidControlPointGrid', ...
        'Control point matrices must be at least 4-by-4 to define a surface.');
end
UKnot = [0 0 0 ((0:maxU) ./ maxU) 1 1 1];
VKnot = [0 0 0 ((0:maxV) ./ maxV) 1 1 1];

% Sample parameter grid.
uSamples = 0:uStep:1;
vSamples = 0:vStep:1;
numUSamples = numel(uSamples);
numVSamples = numel(vSamples);

surfacePoints = zeros(numUSamples * numVSamples, 3);
S_counter = 1;
ABS_TOL = 1e-5;

for vParam = vSamples
    [vInterval, Nv] = NValue(vParam, VKnot, ABS_TOL);
    for uParam = uSamples
        [uInterval, Nu] = NValue(uParam, UKnot, ABS_TOL);

        patchIndicesU = (uInterval-2):(uInterval+1);
        patchIndicesV = (vInterval-2):(vInterval+1);

        controlPatchX = CPx(patchIndicesU, patchIndicesV);
        controlPatchY = CPy(patchIndicesU, patchIndicesV);
        controlPatchZ = CPz(patchIndicesU, patchIndicesV);

        surfTempX = Nu * controlPatchX * Nv';
        surfTempY = Nu * controlPatchY * Nv';
        surfTempZ = Nu * controlPatchZ * Nv';

        surfacePoints(S_counter, :) = [surfTempX, surfTempY, surfTempZ];
        S_counter = S_counter + 1;
    end
end

[X, Y, Z] = rearrangeSurfacePoints(surfacePoints(:, 1), surfacePoints(:, 2), ...
    surfacePoints(:, 3), numUSamples, numVSamples);
end
