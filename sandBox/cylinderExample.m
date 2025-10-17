function cylinderExample(CPs, CPw, n_station)
% CYLINDEREXAMPLE Generates a 3D B-spline representation of a cylinder
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
% INPUTS:
%   CPs       - Number of control points in each station (default: 8)
%   CPw       - Number of control points in longitudinal direction (default: 4)
%   n_station - Number of stations along the cylinder (default: 30)
%
% The shape is arranged station-wise (YZ), with increment towards
% positive length-wise direction (deltaX)

% Set default parameters
if nargin < 1 || isempty(CPs)
    CPs = 8;
end
if nargin < 2 || isempty(CPw)
    CPw = 4;
end
if nargin < 3 || isempty(n_station)
    n_station = 30;
end

% Load circular cross-section data
YZ = load('circle.dat');
lengthYZ = size(YZ, 1);

% Initialize
X = ones(lengthYZ, 1);
deltaX = 5;

% Create figure
figure;
hold on;
grid on;

% Generate stations along the cylinder
for i = 1:n_station
    XYZ = [X YZ];

    % Store XYZ data in structure array
    station(i).x = XYZ(:,1)';
    station(i).y = XYZ(:,2)';
    station(i).z = XYZ(:,3)';

    plot3(XYZ(:,1), XYZ(:,2), XYZ(:,3), 'r.-');
    X = X + deltaX;
end
axis equal

% Fit B-spline surface
[X, Y, Z] = BSplineFit3(CPs, CPw, station);
[u, v, w] = BSplineSurf(X, Y, Z);

end