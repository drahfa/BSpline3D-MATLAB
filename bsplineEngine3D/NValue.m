function [iInterval,N] = NValue(u,UKnot,Nabs)
% NVALUE Calculates B-spline basis values (degree 3 cubic)
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
% calculate B-spline basis values (degree 3 cubic) parameterized on [0,1)

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
N0 = [zeros(1,7)];
N0(4) = 1;

% N1 level interpolation
N1 = [zeros(1,6)];
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
N2 = [zeros(1,5)];
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
N3 = [zeros(1,4)];
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
end


    