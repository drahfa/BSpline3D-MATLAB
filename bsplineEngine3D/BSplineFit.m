function [PMatrix, QSpline] = BSplineFit(Q,maxU)
% BSPLINEFIT B-spline least squares data fitting
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
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

% plot results
% plot(Q(:,1),Q(:,2),'r*'); % Ahmad: Q is our value, so no need to return
% this again

QSpline = zeros(maxuQ+1,2);
for uQIndex = 1:maxuQ+1
    [iInterval,N] = NValue(uQ(uQIndex),UKnot,1e-5);
    QSpline(uQIndex,1) = N(1)*PMatrix(iInterval-2,1) + N(2)*PMatrix(iInterval-1,1) + N(3)*PMatrix(iInterval,1) + N(4)*PMatrix(iInterval+1,1);  
    QSpline(uQIndex,2) = N(1)*PMatrix(iInterval-2,2) + N(2)*PMatrix(iInterval-1,2) + N(3)*PMatrix(iInterval,2) + N(4)*PMatrix(iInterval+1,2);  
end

end

    