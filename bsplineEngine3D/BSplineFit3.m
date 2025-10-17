function [X,Y,Z,stationMSE,waterlineMSE] = BSplineFit3 (latitud,longitud,station)
% BSPLINEFIT3 3D B-spline surface fitting with error analysis
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs

number_of_stations = length(station); 
% Manipulating the value of the stations directions to produce control points in
% waterlines directions
stationError = zeros(number_of_stations,1);

for i = 1:number_of_stations
    X = station(i).x;
    Y = station(i).y;
    Z = station(i).z;
    temp = [X' Y' Z'];

    [CP_s,Qspline] = BSplineFit(temp,latitud);
    % Error checking in stations direction
    [Diff,statMaxDiff,idMax] = calcError(Qspline,temp);
    stationError(i) = statMaxDiff;

    waterline(i).x = (CP_s(:,1)');
    waterline(i).y = (CP_s(:,2)');
    waterline(i).z = (CP_s(:,3)');
end  

% Move on to the waterlines directions.
waterlineError = zeros(latitud,1);
CP = [];
for j = 1:latitud
    Xn = [];
    Yn = [];
    Zn = [];
    for k = 1:number_of_stations
        x_temp = waterline(k).x(j);
        y_temp = waterline(k).y(j);
        z_temp = waterline(k).z(j);
        Xn = [Xn; x_temp];
        Yn = [Yn; y_temp];
        Zn = [Zn; z_temp];
    end
    temp = [Xn Yn Zn];
    [CP_w,Qspline] = BSplineFit(temp,longitud);
    % Error checking in waterline direction
    [Diff,waterlMaxDiff,idMax] = calcError(Qspline,temp);
    waterlineError(j) = waterlMaxDiff;
    
    
    CP = [CP; CP_w];
end

x = CP(:,1);
y = CP(:,2);
z = CP(:,3);

X = reshape (x,longitud,latitud);
Y = reshape (y,longitud,latitud);
Z = reshape (z,longitud,latitud);

stationErrorSquared = stationError.^2;
waterlineErrorSquared = waterlineError.^2;
stationMSE = mean(stationErrorSquared);
waterlineMSE = mean(waterlineErrorSquared);
return

function [PMatrix, QSpline] = BSplineFit(Q,maxU) 
% B-spline least squares data fitting example
% maxU = 7 recommended
% ADAPTED BY AHMAD FROM B-SPLINES NOTES
% INPUT = Q         : which is n by 2 matrix
%         maxU      : which is the maximum n control points permissible
% OUTPUT= PMATRIX   : which is the output control points
%         QSPLINE  : whics is the control points


maxU = maxU - 3;
% knots (use uniform spacing for simplicity)
UKnot=[0:maxU]/maxU;
UKnot=[0 0 0 UKnot 1 1 1];

% sample parameters
sizeQ = size(Q);
sizeQ = sizeQ(1);
maxuQ = sizeQ - 1;
uQ = [0 1:maxuQ]/maxuQ;

NMatrix = zeros(maxuQ+1,maxU+3);
for uQIndex = 1:maxuQ+1
    [iInterval,N] = NValue(uQ(uQIndex),UKnot,1e-5);
    NMatrix(uQIndex,iInterval-2) = N(1);
    NMatrix(uQIndex,iInterval-1) = N(2);
    NMatrix(uQIndex,iInterval) = N(3);
    NMatrix(uQIndex,iInterval+1) = N(4);
end
% PMatrix = inv(transpose(NMatrix)*NMatrix)*transpose(NMatrix)*Q;
% implement with SVD

[U,W,V]=svd(NMatrix);
for uQIndex = 1:maxU+3
    W(uQIndex,uQIndex) = 1/W(uQIndex,uQIndex);
end
PMatrix = V*transpose(W)*transpose(U)*Q;


QSpline = zeros(maxuQ+1,3);
for uQIndex = 1:maxuQ+1
    [iInterval,N] = NValue(uQ(uQIndex),UKnot,1e-5);
    QSpline(uQIndex,1) = N(1)*PMatrix(iInterval-2,1) + N(2)*PMatrix(iInterval-1,1) + N(3)*PMatrix(iInterval,1) + N(4)*PMatrix(iInterval+1,1);  
    QSpline(uQIndex,2) = N(1)*PMatrix(iInterval-2,2) + N(2)*PMatrix(iInterval-1,2) + N(3)*PMatrix(iInterval,2) + N(4)*PMatrix(iInterval+1,2); 
    QSpline(uQIndex,3) = N(1)*PMatrix(iInterval-2,3) + N(2)*PMatrix(iInterval-1,3) + N(3)*PMatrix(iInterval,3) + N(4)*PMatrix(iInterval+1,3); 
end

return

