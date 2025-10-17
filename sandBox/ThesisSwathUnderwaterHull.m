% THESISSWATHUNDERWATERHULL Demonstrates B-spline fitting for SWATH underwater hull
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
xyz = load('swath_underwater_hull.dat');

% 2. Convert the x,y,z offset data to structured station
station_xyz = xyz2station(xyz);
station_xyz = station_xyz(40:55);  % Extract stations 40-55 (16 stations total)

% 3. Fit the dataset and get the control polygon net, [cpX,cpY,cpZ] with
% the stationMSE and waterlineMSE (fitting errors)
station_control_points =10;
longitudinal_control_points = 4;
[cpX,cpY,cpZ,stationMSE,waterlineMSE] = BSplineFit3(station_control_points,longitudinal_control_points,station_xyz);

hold on;


if flag_plotbsplines == 1
    % 4. Take the control points and plot fitted surface and the governing
    % control points
    [u,v,w] = BSplineSurf(cpX,cpY,cpZ);
end

if flag_plotstation == 1
    % Plot the last 6 stations from the extracted subset
    n_stations = length(station_xyz);
    start_idx = max(1, n_stations - 5);  % Last 6 stations or all if less than 6
    for i = start_idx:n_stations
        x = station_xyz(i).x';
        y = station_xyz(i).y';
        z = station_xyz(i).z';
        plot3(x, y, z, 'r.')
    end
end

view([90 0])
