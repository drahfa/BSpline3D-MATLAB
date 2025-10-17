% DEMOSTEPYACTH Demonstrates 3D B-spline surface fitting for yacht hull
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
% This file will demonstrate the step of;
% 1. Loading data
% 2. Structuring data
% 3. 3D surface fitting
% 4. 3D surface representation,
% given an input file containing n by 3 xyz offset data

close all

% 1. Load the .dat file
% xyz=load ('halfcylinder.dat');
xyz=load('yatch_offset3.dat');
% xyz=load ('cylinder.dat');

% 2. Convert the x,y,z offset data to structured station
station_xyz = xyz2station(xyz);

% 3. Fit the dataset and get the control polygon net, [cpX,cpY,cpZ] with
% the stationMSE and waterlineMSE (fitting errors)
station_control_points =6;
longitudinal_control_points = 4;
[cpX,cpY,cpZ,stationMSE,waterlineMSE] = BSplineFit3(station_control_points,longitudinal_control_points,station_xyz);
 
% Automatic post-processing: since we know the keel value of the yacth,
% we need it to be closed, thus the solution is as presented below. Other
% way to do this is through the application of flag such as chine flag and
% keel flag
% Referring to Dugald Thesis
cpY(:,end) = 0; % the rightmost column represent bottom keel
cpY(end,:) = 0; % the forwardmost column represent forward keel

% 4. Take the control points and plot fitted surface and the governing
% control points
 [u,v,w] = BSplineSurf(cpX,cpY,cpZ);
 
 % OPTIONAL
 % 5. View the comparison of the offset data and the approximated
 % datapoints
 hold on;
 plot3(xyz(:,1), xyz(:,2), xyz(:,3),'.')
%  colormap gray
 view([90 -0])
 
