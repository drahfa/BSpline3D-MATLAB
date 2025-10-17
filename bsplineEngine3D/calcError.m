function [Diff,maxDiff,idMax] = calcError(datapointSpline,datapoint)
% CALCERROR Calculates fitting error using Euclidean distance
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
% Since B-splines fitting problem is an inverse problem, we are expecting
% that the number of elements in the 'datapoint' and 'datapointSpline' are
% same. Thus euqlidian distance is used in this calculation

sizeQ = size(datapoint);
sizeQ = sizeQ(1);
maxdatapointSpline = sizeQ;

% calculate the maximum fit error
maxDiff = 0; % initiate thisDiff

Diff = zeros(sizeQ,1);
for i = 1:maxdatapointSpline
    thisDiff = sqrt((datapointSpline(i,1)-datapoint(i,1))^2+(datapointSpline(i,2)-datapoint(i,2))^2);
    Diff(i) = thisDiff;
    if (thisDiff>maxDiff)
        maxDiff = thisDiff; % replace the maxDiff with thisDiff
    end
end

[val,idMax] = max(Diff);

return