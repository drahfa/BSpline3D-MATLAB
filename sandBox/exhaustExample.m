function exhaustExample (CPs,CPw)
% EXHAUSTEXAMPLE Generates a 3D B-spline representation with variable diameter
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
% INPUT: CPs which is the number of control points desired in each individual
%        station
%        CPw whcih is the number of control points desired in longitudinal
%        direction
% say that the file circle1.m~circle10.m eventually giving us a 3D
% representation of a cylinder

% Assume that the shape is arranged station-wise (YZ), and increment
% towards positive length-wise is deltaX
% CPstation = 8;
% CPwaterline=4;
% Set default parameters
if nargin < 1 || isempty(CPs)
    CPs = 8;
end
if nargin < 2 || isempty(CPw)
    CPw = 8;
end

YZ = load('circle.dat');
sizeYZ = size(YZ);
lengthYZ = sizeYZ(1);
X = ones(lengthYZ,1);
deltaX = 5;
figure; hold on; grid on;
n_station1 = 10;
n_station2 = 15;
n_station3 = 20;
% n_station4 = 45;
% n_station5 = 60;

for i=1:n_station1
    XYZ = [X YZ];
    % Store the XYZ data using structure arrays
    station(i).x	= XYZ(:,1)';
    station(i).y	= XYZ(:,2)';
    station(i).z	= XYZ(:,3)';
    
%     plot3(XYZ(:,1),XYZ(:,2),XYZ(:,3),'r.-');
    X = X+deltaX;
end
scaledown = [1 0;0 1];
deltadown = 1;
for i=n_station1:n_station2
    YZdown = YZ*scaledown;
    XYZ = [X YZdown];
    % Store the XYZ data using structure arrays
    station(i).x	= XYZ(:,1)';
    station(i).y	= XYZ(:,2)';
    station(i).z	= XYZ(:,3)';
    
%     plot3(XYZ(:,1),XYZ(:,2),XYZ(:,3),'b.-');
    X = X+deltaX;
    scaledown = scaledown*deltadown;
    deltadown = deltadown-0.1;
end
for i=n_station2:n_station3
    XYZ = [X YZdown];
    % Store the XYZ data using structure arrays
    station(i).x	= XYZ(:,1)';
    station(i).y	= XYZ(:,2)';
    station(i).z	= XYZ(:,3)';
  
%     plot3(XYZ(:,1),XYZ(:,2),XYZ(:,3),'r.-');
    X = X+deltaX;
end

length(station)
axis equal

 [X,Y,Z] = BSplineFit3 (CPs,CPw,station);
 [u,v,w] = BSplineSurf(X,Y,Z);
end