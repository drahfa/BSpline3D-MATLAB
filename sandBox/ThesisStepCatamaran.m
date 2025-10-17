% THESISSTEPCATAMARAN Demonstrates B-spline fitting for catamaran hull
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
% This file will demonstrate the step of;
% 1. Loading data
% 2. Structuring data
% 3. 3D surface fitting
% 4. 3D surface representation,
% given an input file containing n by 3 xyz offset data
flag_plotbsplines = 1;
flag_plotstation = 1;

%close all

% 1. Load the .dat file
xyz=load('catamaran_offset_roof.dat');

% 2. Convert the x,y,z offset data to structured station
station_xyz = xyz2station(xyz);

% 3. Fit the dataset and get the control polygon net, [cpX,cpY,cpZ] with
% the stationMSE and waterlineMSE (fitting errors)
station_control_points =4;
longitudinal_control_points = 8;
[cpX,cpY,cpZ,stationMSE,waterlineMSE] = BSplineFit3(station_control_points,longitudinal_control_points,station_xyz);

hold on;


if flag_plotbsplines == 1
    % 4. Take the control points and plot fitted surface and the governing
    % control points
    [u,v,w] = BSplineSurf(cpX,cpY,cpZ);
end

if flag_plotstation ==1
    for i=1:length(station_xyz)
        x = station_xyz(i).x';
        y = station_xyz(i).y';
        z = station_xyz(i).z';
        plot3(x,y,z,'r-')
    end
end

view([90 0])
