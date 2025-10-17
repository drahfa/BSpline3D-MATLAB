function [errors, nearestPoints] = computeFittingErrors(surfacePoints, xyzOriginal)
% COMPUTEFITTINGERRORS Calculate nearest-surface errors for sample points.
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
%   [errors, nearestPoints] = computeFittingErrors(surfacePoints, xyzOriginal)
%   computes the Euclidean distance between each point in xyzOriginal and its
%   closest point on the sampled B-spline surface described by surfacePoints.
%   The function returns the vector of distances (errors) and their matching
%   surface coordinates (nearestPoints).
%
%   Inputs:
%     surfacePoints : N-by-3 array describing sampled surface coordinates.
%     xyzOriginal   : M-by-3 array containing original data points.
%
%   Outputs:
%     errors        : M-by-1 vector of Euclidean distances.
%     nearestPoints : M-by-3 array with the closest surface point for each
%                     original point.

validateattributes(surfacePoints, {'numeric'}, {'ncols', 3}, mfilename, 'surfacePoints', 1);
validateattributes(xyzOriginal, {'numeric'}, {'ncols', 3}, mfilename, 'xyzOriginal', 2);

numOriginal = size(xyzOriginal, 1);
errors = zeros(numOriginal, 1);
nearestPoints = zeros(numOriginal, 3);

for idx = 1:numOriginal
    deltas = surfacePoints - xyzOriginal(idx, :);
    distances = sqrt(sum(deltas .^ 2, 2));
    [errors(idx), nearestIdx] = min(distances);
    nearestPoints(idx, :) = surfacePoints(nearestIdx, :);
end
end
