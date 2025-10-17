function [X, Y, Z] = rearrangeSurfacePoints(Px, Py, Pz, numU, numV)
% REARRANGESURFACEPOINTS Reshape flattened surface coordinates to grids.
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
%   [X, Y, Z] = rearrangeSurfacePoints(Px, Py, Pz) infers a square grid from
%   the supplied coordinate vectors and returns matrices compatible with
%   surf().
%
%   [X, Y, Z] = rearrangeSurfacePoints(Px, Py, Pz, numU, numV) reshapes the
%   coordinates using the provided grid dimensions, allowing rectangular
%   grids where numU is the number of samples along the U direction and numV
%   along the V direction.
%
%   This function replaces the local rearrange function previously defined
%   inside visualizeError.m.

validateattributes(Px, {'numeric'}, {'column'}, mfilename, 'Px', 1);
validateattributes(Py, {'numeric'}, {'column', 'numel', numel(Px)}, mfilename, 'Py', 2);
validateattributes(Pz, {'numeric'}, {'column', 'numel', numel(Px)}, mfilename, 'Pz', 3);

numPoints = numel(Px);

if nargin < 4 || isempty(numU) || isempty(numV)
    gridSize = sqrt(numPoints);
    if abs(gridSize - round(gridSize)) > sqrt(eps)
        error('rearrangeSurfacePoints:NonSquareGrid', ...
            'Cannot infer square grid size from %d points.', numPoints);
    end
    numU = round(gridSize);
    numV = numU;
else
    validateattributes(numU, {'numeric'}, {'scalar', 'integer', '>', 0}, mfilename, 'numU', 4);
    validateattributes(numV, {'numeric'}, {'scalar', 'integer', '>', 0}, mfilename, 'numV', 5);
    if numU * numV ~= numPoints
        error('rearrangeSurfacePoints:InconsistentDimensions', ...
            'Provided grid dimensions (%d x %d) do not match %d points.', ...
            numU, numV, numPoints);
    end
end

X = reshape(Px, numU, numV).';
Y = reshape(Py, numU, numV).';
Z = reshape(Pz, numU, numV).';
end
