function station = xyz2station(xyz)
% XYZ2STATION Converts 3D XYZ offset data to structured station format
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
% This function will take 3 by n XYZ data and give a set of structure of
% station.x, station.y and station.z
% Ahmad Faisal Mohamad Ayob | 5 July 2010
%
% Updated December 2014 for MATLAB 2013b+ compatibility
% Uses 'legacy' flag in unique() function for backward compatibility

% xyz=load ('halfcylinder.dat');

% checking the station sequence, must start with small. Standard Nav. Arch.
% practice where station 0 is noted from the aft
% 27 October 2010
data_start = xyz(1,1);
data_end = xyz(end,1);
if data_end < data_start
    xyz = flipud(xyz);
end

x = xyz(:,1);
[b,n_occur] = unique(x,'legacy'); % b is the unique values, n_occur is the number of occurence.
% Dec 2014 | note the word 'legacy' there? Unique has changed since 2013b.


% So how many number of stations?
n_station = length(b);
dummy_n_occur = [1;n_occur];

 %figure; hold on;
for i=1:n_station
    if i==1
    X = xyz(dummy_n_occur(i):dummy_n_occur(i+1),1);
    Y = xyz(dummy_n_occur(i):dummy_n_occur(i+1),2);
    Z = xyz(dummy_n_occur(i):dummy_n_occur(i+1),3);
    %plot3(X,Y,Z)
  
    % pause
    else
    X = xyz(dummy_n_occur(i)+1:dummy_n_occur(i+1),1);
    Y = xyz(dummy_n_occur(i)+1:dummy_n_occur(i+1),2);
    Z = xyz(dummy_n_occur(i)+1:dummy_n_occur(i+1),3);
    % plot3(X,Y,Z)
    % pause
    % close
    end
%     % 28 October 2010: A fix so that the Y-Z sequence can be ensured
%     XYZ = [X Y Z]
%     XYZ_sorted = sortrows(XYZ,3);
%     X = XYZ_sorted(:,1);
%     Y = XYZ_sorted(:,2);
%     Z = XYZ_sorted(:,3);
%     % Done fixing
    station(i).x = X';
    station(i).y = Y';
    station(i).z = Z';
end
return





