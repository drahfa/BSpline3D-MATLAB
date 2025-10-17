function station = halfCylinder (CPs,CPw)
% HALFCYLINDER Generates a 3D B-spline representation of a half cylinder
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
% INPUT: CPs which is the number of control points desired in each individual
%        station
%        CPw whcih is the number of control points desired in longitudinal
%        direction
% say that the file circle1.m~circle10.m eventually giving us a 3D
% representation of a half cylinder

% Assume that the shape is arranged station-wise (YZ), and increment
% towards positive length-wise is deltaX
% CPstation = 8;
% CPwaterline=4;

% Set default parameters
if nargin < 1 || isempty(CPs)
    CPs = 8;
end
if nargin < 2 || isempty(CPw)
    CPw = 4;
end

YZ = load('halfCircle.dat');
sizeYZ = size(YZ);
lengthYZ = sizeYZ(1);
X = ones(lengthYZ,1);
deltaX = 5;
figure; hold on; grid on;
n_station = 30;
% XYZout = [];

for i=1:n_station
    
    XYZ = [X YZ];
    % Store the XYZ data using structure arrays
    station(i).x	= XYZ(:,1)';
    station(i).y	= XYZ(:,2)';
    station(i).z	= XYZ(:,3)';
    
    plot3(XYZ(:,1),XYZ(:,2),XYZ(:,3),'r.-');
    X = X+deltaX;
end
axis equal

%station

 [X,Y,Z] = BSplineFit3(CPs,CPw,station);
 [u,v,w] = BSplineSurf(X,Y,Z);
end