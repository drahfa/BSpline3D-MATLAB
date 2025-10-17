% DEMOSTEP_BOTTOM Demonstrates 3D B-spline surface fitting (bottom surface)
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
% This file will demonstrate the step of;
% 1. Loading data
% 2. Structuring data
% 3. 3D surface fitting
% 4. 3D surface representation,
% given an input file containing n by 3 xyz offset data



% 1. Load the .dat file
% xyz=load ('halfcylinder.dat');
xyz=load('data_bottom.dat');
% xyz=load ('cylinder.dat');

% 2. Convert the x,y,z offset data to structured station
station_xyz = xyz2station(xyz);

% 3. Fit the dataset and get the control polygon net, [cpX,cpY,cpZ] with
% the stationMSE and waterlineMSE (fitting errors)
station_control_points =5;
longitudinal_control_points = 8;
[cpX,cpY,cpZ,stationMSE,waterlineMSE] = BSplineFit3(station_control_points,longitudinal_control_points,station_xyz);
 
% 4. Take the control points and plot fitted surface and the governing
% control points
 [u,v,w] = BSplineSurf(cpX,cpY,cpZ);
 
 % OPTIONAL
 % 5. View the comparison of the offset data and the approximated
 % datapoints
 hold on;
 plot3(xyz(:,1), xyz(:,2), xyz(:,3),'.')
 colormap gray
 view([90 -0])
 
 p = mesh(cpX,cpY,cpZ);
 set(p,'facealpha',0)
 set(p,'edgecolor','k')
 
 
X = reshape(cpX,40,1);
Y = reshape(cpY,40,1);
Z = reshape(cpZ,40,1);
plot3(X,Y,Z,'ko','MarkerFaceColor','k')

cpX_bottom = cpX;
cpY_bottom = cpY;
cpZ_bottom = cpZ;