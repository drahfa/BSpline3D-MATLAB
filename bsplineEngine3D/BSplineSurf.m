function [u,v,w] = BSplineSurf(CPx,CPy,CPz)
% BSPLINESURF Calculates B-spline surface from control points
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
% B-Spline Surface Module: To calculate B-Spline Surface given a set of
% Control Points in non-Square Matrix form
% By: Ahmad Faisal Mohamad Ayob, 5/6/2008
reflection_flag = 0;
cp_flag = 0;


A = size(CPx);
% Calculating Knots in U direction
maxU = A(1,1);
maxU = maxU - 3;
% knots (use uniform spacing for simplicity)
UKnot=(0:maxU)/maxU;
UKnot=[0 0 0 UKnot 1 1 1];

% Calculating Knots in V direction
maxV = A(1,2);
maxV = maxV - 3;
% knots (use uniform spacing for simplicity)
VKnot=(0:maxV)/maxV;
VKnot=[0 0 0 VKnot 1 1 1];


%Surface = [];
vParameterInterval = 0.05;
uParameterInterval = 0.05;
temp = length(0:vParameterInterval:1)*length(0:uParameterInterval:1);
Surface = zeros(temp,3);
S_counter = 1;
for vParameter = 0:vParameterInterval:1
    [vInterval,Nv] = NValue(vParameter,VKnot);
    for uParameter = 0:uParameterInterval:1
        [uInterval,Nu] = NValue(uParameter,UKnot);

        surfTempX = [Nu(1) Nu(2) Nu(3) Nu(4)]*...
            [CPx(uInterval-2,vInterval-2) CPx(uInterval-2,vInterval-1) CPx(uInterval-2,vInterval) CPx(uInterval-2,vInterval+1);
             CPx(uInterval-1,vInterval-2) CPx(uInterval-1,vInterval-1) CPx(uInterval-1,vInterval) CPx(uInterval-1,vInterval+1);
             CPx(uInterval  ,vInterval-2) CPx(uInterval  ,vInterval-1) CPx(uInterval  ,vInterval) CPx(uInterval  ,vInterval+1);
             CPx(uInterval+1,vInterval-2) CPx(uInterval+1,vInterval-1) CPx(uInterval+1,vInterval) CPx(uInterval+1,vInterval+1)]*...
            [Nv(1);Nv(2);Nv(3);Nv(4)];

        surfTempY = [Nu(1) Nu(2) Nu(3) Nu(4)]*...
            [CPy(uInterval-2,vInterval-2) CPy(uInterval-2,vInterval-1) CPy(uInterval-2,vInterval) CPy(uInterval-2,vInterval+1);
             CPy(uInterval-1,vInterval-2) CPy(uInterval-1,vInterval-1) CPy(uInterval-1,vInterval) CPy(uInterval-1,vInterval+1);
             CPy(uInterval  ,vInterval-2) CPy(uInterval  ,vInterval-1) CPy(uInterval  ,vInterval) CPy(uInterval  ,vInterval+1);
             CPy(uInterval+1,vInterval-2) CPy(uInterval+1,vInterval-1) CPy(uInterval+1,vInterval) CPy(uInterval+1,vInterval+1)]*...
            [Nv(1);Nv(2);Nv(3);Nv(4)];
        
        surfTempZ = [Nu(1) Nu(2) Nu(3) Nu(4)]*...
            [CPz(uInterval-2,vInterval-2) CPz(uInterval-2,vInterval-1) CPz(uInterval-2,vInterval) CPz(uInterval-2,vInterval+1);
             CPz(uInterval-1,vInterval-2) CPz(uInterval-1,vInterval-1) CPz(uInterval-1,vInterval) CPz(uInterval-1,vInterval+1);
             CPz(uInterval  ,vInterval-2) CPz(uInterval  ,vInterval-1) CPz(uInterval  ,vInterval) CPz(uInterval  ,vInterval+1);
             CPz(uInterval+1,vInterval-2) CPz(uInterval+1,vInterval-1) CPz(uInterval+1,vInterval) CPz(uInterval+1,vInterval+1)]*...
            [Nv(1);Nv(2);Nv(3);Nv(4)];
        
        Surface(S_counter,:) = [surfTempX surfTempY surfTempZ];
        % Surface = [Surface; surfTempX surfTempY surfTempZ]
        S_counter = S_counter+1;
        % pause;        
    end
end
size(Surface)
hold on; grid on;
if reflection_flag == 1
    B = reflection (Surface,3);
    [a,b,c] = rearrange(B(:,1),B(:,2),B(:,3));
    surf(a,b,c);
end
[u,v,w] = rearrange(Surface(:,1),Surface(:,2),Surface(:,3));
% plot3(Surface(:,1),Surface(:,2),Surface(:,3),'b.')

surf(u,v,w);
if cp_flag ==1
plot3(CPx,CPy,CPz,'k-');
plot3(CPx,CPy,CPz,'ko','markersize',10,'markerfacecolor','k');
plot3(CPx',CPy',CPz','k-');
plot3(CPx',CPy',CPz','ko','markersize',10,'markerfacecolor','k');
end

axis equal;
return

function [iInterval,N] = NValue(u,UKnot)
% calculate B-spline basis values (degree 3 cubic) parameterized on [0,1),
% this function is to be accompanied together with the BSplineFit and
% BSplineSurf function
Nabs = 1e-5;
UKnotMax = size(UKnot);
UKnotMax = UKnotMax(2);

if (u>.999999)
    u = .999999;
end

% find interval
iInterval = 0;
while (iInterval < UKnotMax)
    if (u < UKnot(iInterval+1))
        break
    end
    iInterval = iInterval + 1;
end
iInterval = iInterval - 1;
N0 = zeros(1,7);
N0(4) = 1;

% N1 level interpolation
N1 = zeros(1,6);
for i = -1:0
    if (abs(UKnot(iInterval+2+i)-UKnot(iInterval+1+i)) < Nabs)
        N1(i+4) = 0;
    else
        N1(i+4) = (u-UKnot(iInterval+1+i))/(UKnot(iInterval+2+i)-UKnot(iInterval+1+i))*N0(i+4);
    end
    if (abs(UKnot(iInterval+3+i)-UKnot(iInterval+2+i)) < Nabs)
        N1(i+4) = N1(i+4);
    else
        N1(i+4) = N1(i+4) + (UKnot(iInterval+3+i)-u)/(UKnot(iInterval+3+i)-UKnot(iInterval+2+i))*N0(i+5);
    end
end

% N2 level interpolation
N2 = zeros(1,5);
for i = -2:0
    if (abs((UKnot(iInterval+3+i)-UKnot(iInterval+1+i))) < Nabs)
        N2(i+4) = 0;
    else
        N2(i+4) = (u-UKnot(iInterval+1+i))/(UKnot(iInterval+3+i)-UKnot(iInterval+1+i))*N1(i+4);
    end
    if (abs((UKnot(iInterval+4+i)-UKnot(iInterval+2+i))) < Nabs)
        N2(i+4) = N2(i+4);
    else
        N2(i+4) = N2(i+4) + (UKnot(iInterval+4+i)-u)/(UKnot(iInterval+4+i)-UKnot(iInterval+2+i))*N1(i+5);
    end
end

%N3 level interpolation
N3 = zeros(1,4);
for i = -3:0
    if (abs((UKnot(iInterval+4+i)-UKnot(iInterval+1+i))) < Nabs)
        N3(i+4) = 0;
    else
        N3(i+4) = (u-UKnot(iInterval+1+i))/(UKnot(iInterval+4+i)-UKnot(iInterval+1+i))*N2(i+4);
    end
    if (abs((UKnot(iInterval+5+i)-UKnot(iInterval+2+i))) < Nabs)
        N3(i+4) = N3(i+4);
    else
        N3(i+4) = N3(i+4) + (UKnot(iInterval+5+i)-u)/(UKnot(iInterval+5+i)-UKnot(iInterval+2+i))*N2(i+5);
    end
end

N = N3;
return

function [X,Y,Z] = rearrange (Px,Py,Pz)
% A module to rearrange Coordinate Points to Square Matrices
% By: Ahmad Faisal Mohamad Ayob, 5/6/2008
flagvector = round(sqrt(length (Px)));

X = []; 
A = 1;
for i = 1:flagvector
    B = i*flagvector;
    tempX = Px(A:B);
    X = [X;tempX'];
    A = 1;
    A = A+B;
end

Y = []; 
A = 1;
for i = 1:flagvector
    B = i*flagvector;
    tempY = Py(A:B);
    Y = [Y;tempY'];
    A = 1;
    A = A+B;
end

Z = []; 
A = 1;
for i = 1:flagvector
    B = i*flagvector;
    tempZ = Pz(A:B);
    Z = [Z;tempZ'];
    A = 1;
    A = A+B;
end

return
function b = reflection (A,axs)
% ROTATION (A, AXIS)
% A = n x 3 (x,y,z matrix)
% AXIS 1.x-axis, 2.y-axis, 3. z-axis
%
% Demonstrating Matrix Reflection
% By: Ahmad Faisal Mohamad Ayob
%     UNSW@ADFA, 16/6/2008

a = transpose(A);

if axs == 1    % XY axis
    b = [1 0 0 ; 0 1 0;0 0 -1] * a; 
elseif axs == 2 % YZ axis
    b = [-1 0 0 ; 0 1 0;0 0 1] * a;
elseif axs == 3 % XZ axis
    b = [1 0 0 ; 0 -1 0;0 0 1] * a;
end
b = transpose(b);

return




    

