function [curvature, smoothness_metric, surfaceData] = analyzeSmoothness(CPx, CPy, CPz)
% ANALYZESMOOTHNESS Analyzes surface smoothness using curvature measures
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
% INPUTS:
%   CPx, CPy, CPz - Control point matrices
%
% OUTPUTS:
%   curvature        - Gaussian curvature at each surface point
%   smoothness_metric - Overall smoothness score (lower = smoother)
%   surfaceData      - Struct containing sampled surface points, normals,
%                      parameter values, and curvature (for visualization)
%
% Smoothness is measured by analyzing the variation in surface normals
% and computing Gaussian curvature

% Generate dense surface points for analysis
vParameterInterval = 0.05;
uParameterInterval = 0.05;

A = size(CPx);
maxU = A(1,1) - 3;
maxV = A(1,2) - 3;

% Create knot vectors
UKnot = (0:maxU)/maxU;
UKnot = [0 0 0 UKnot 1 1 1];
VKnot = (0:maxV)/maxV;
VKnot = [0 0 0 VKnot 1 1 1];

% Storage for surface points and derivatives
u_vals = 0:uParameterInterval:1;
v_vals = 0:vParameterInterval:1;
n_u = length(u_vals);
n_v = length(v_vals);

% Initialize storage
surf_pts = zeros(n_u, n_v, 3);
normals = zeros(n_u, n_v, 3);
curvature = zeros(n_u, n_v);

% Compute surface points and approximate curvature
for i = 1:n_u
    for j = 1:n_v
        uParameter = u_vals(i);
        vParameter = v_vals(j);

        [vInterval, Nv] = NValue(vParameter, VKnot, 1e-5);
        [uInterval, Nu] = NValue(uParameter, UKnot, 1e-5);

        % Surface point
        surfX = [Nu(1) Nu(2) Nu(3) Nu(4)] * ...
            [CPx(uInterval-2,vInterval-2) CPx(uInterval-2,vInterval-1) CPx(uInterval-2,vInterval) CPx(uInterval-2,vInterval+1);
             CPx(uInterval-1,vInterval-2) CPx(uInterval-1,vInterval-1) CPx(uInterval-1,vInterval) CPx(uInterval-1,vInterval+1);
             CPx(uInterval  ,vInterval-2) CPx(uInterval  ,vInterval-1) CPx(uInterval  ,vInterval) CPx(uInterval  ,vInterval+1);
             CPx(uInterval+1,vInterval-2) CPx(uInterval+1,vInterval-1) CPx(uInterval+1,vInterval) CPx(uInterval+1,vInterval+1)] * ...
            [Nv(1); Nv(2); Nv(3); Nv(4)];

        surfY = [Nu(1) Nu(2) Nu(3) Nu(4)] * ...
            [CPy(uInterval-2,vInterval-2) CPy(uInterval-2,vInterval-1) CPy(uInterval-2,vInterval) CPy(uInterval-2,vInterval+1);
             CPy(uInterval-1,vInterval-2) CPy(uInterval-1,vInterval-1) CPy(uInterval-1,vInterval) CPy(uInterval-1,vInterval+1);
             CPy(uInterval  ,vInterval-2) CPy(uInterval  ,vInterval-1) CPy(uInterval  ,vInterval) CPy(uInterval  ,vInterval+1);
             CPy(uInterval+1,vInterval-2) CPy(uInterval+1,vInterval-1) CPy(uInterval+1,vInterval) CPy(uInterval+1,vInterval+1)] * ...
            [Nv(1); Nv(2); Nv(3); Nv(4)];

        surfZ = [Nu(1) Nu(2) Nu(3) Nu(4)] * ...
            [CPz(uInterval-2,vInterval-2) CPz(uInterval-2,vInterval-1) CPz(uInterval-2,vInterval) CPz(uInterval-2,vInterval+1);
             CPz(uInterval-1,vInterval-2) CPz(uInterval-1,vInterval-1) CPz(uInterval-1,vInterval) CPz(uInterval-1,vInterval+1);
             CPz(uInterval  ,vInterval-2) CPz(uInterval  ,vInterval-1) CPz(uInterval  ,vInterval) CPz(uInterval  ,vInterval+1);
             CPz(uInterval+1,vInterval-2) CPz(uInterval+1,vInterval-1) CPz(uInterval+1,vInterval) CPz(uInterval+1,vInterval+1)] * ...
            [Nv(1); Nv(2); Nv(3); Nv(4)];

        surf_pts(i, j, :) = [surfX, surfY, surfZ];
    end
end

% Compute approximate Gaussian curvature using finite differences
for i = 2:n_u-1
    for j = 2:n_v-1
        % Get neighboring points
        p_center = squeeze(surf_pts(i, j, :));
        p_up = squeeze(surf_pts(i, j+1, :));
        p_down = squeeze(surf_pts(i, j-1, :));
        p_right = squeeze(surf_pts(i+1, j, :));
        p_left = squeeze(surf_pts(i-1, j, :));

        % Compute tangent vectors
        du = (p_right - p_left) / 2;
        dv = (p_up - p_down) / 2;

        % Normal vector
        normal = cross(du, dv);
        normal_mag = norm(normal);

        if normal_mag > 1e-10
            normal = normal / normal_mag;

            % Approximate second derivatives
            p_uu = p_right - 2*p_center + p_left;
            p_vv = p_up - 2*p_center + p_down;

            % Gaussian curvature approximation (simplified)
            curvature(i, j) = abs(dot(normal, p_uu)) * abs(dot(normal, p_vv));
            normals(i, j, :) = normal;
        end
    end
end

% Compute overall smoothness metric
% Lower values indicate smoother surface
smoothness_metric = std(curvature(:));

% Extend curvature and normal fields to boundaries for visualization helpers
if n_u >= 2
    curvature(1, :) = curvature(min(2, n_u), :);
    curvature(end, :) = curvature(max(n_u-1, 1), :);
    normals(1, :, :) = normals(min(2, n_u), :, :);
    normals(end, :, :) = normals(max(n_u-1, 1), :, :);
end
if n_v >= 2
    curvature(:, 1) = curvature(:, min(2, n_v));
    curvature(:, end) = curvature(:, max(n_v-1, 1));
    normals(:, 1, :) = normals(:, min(2, n_v), :);
    normals(:, end, :) = normals(:, max(n_v-1, 1), :);
end

fprintf('Surface Smoothness Analysis:\n');
fprintf('  Mean Curvature: %.6f\n', mean(curvature(:)));
fprintf('  Max Curvature: %.6f\n', max(curvature(:)));
fprintf('  Smoothness Metric (Std Dev): %.6f\n', smoothness_metric);

if nargout > 2
    surfaceData.points = surf_pts;
    surfaceData.normals = normals;
    surfaceData.u = u_vals;
    surfaceData.v = v_vals;
    surfaceData.curvature = curvature;
end

end

function [iInterval, N] = NValue(u, UKnot, Nabs)
% Calculate B-spline basis values (degree 3 cubic)
UKnotMax = size(UKnot, 2);

if u > 0.999999
    u = 0.999999;
end

% Find interval
iInterval = 0;
while iInterval < UKnotMax
    if u < UKnot(iInterval+1)
        break
    end
    iInterval = iInterval + 1;
end
iInterval = iInterval - 1;

N0 = zeros(1, 7);
N0(4) = 1;

% N1 level interpolation
N1 = zeros(1, 6);
for i = -1:0
    if abs(UKnot(iInterval+2+i) - UKnot(iInterval+1+i)) < Nabs
        N1(i+4) = 0;
    else
        N1(i+4) = (u - UKnot(iInterval+1+i)) / (UKnot(iInterval+2+i) - UKnot(iInterval+1+i)) * N0(i+4);
    end
    if abs(UKnot(iInterval+3+i) - UKnot(iInterval+2+i)) < Nabs
        N1(i+4) = N1(i+4);
    else
        N1(i+4) = N1(i+4) + (UKnot(iInterval+3+i) - u) / (UKnot(iInterval+3+i) - UKnot(iInterval+2+i)) * N0(i+5);
    end
end

% N2 level interpolation
N2 = zeros(1, 5);
for i = -2:0
    if abs(UKnot(iInterval+3+i) - UKnot(iInterval+1+i)) < Nabs
        N2(i+4) = 0;
    else
        N2(i+4) = (u - UKnot(iInterval+1+i)) / (UKnot(iInterval+3+i) - UKnot(iInterval+1+i)) * N1(i+4);
    end
    if abs(UKnot(iInterval+4+i) - UKnot(iInterval+2+i)) < Nabs
        N2(i+4) = N2(i+4);
    else
        N2(i+4) = N2(i+4) + (UKnot(iInterval+4+i) - u) / (UKnot(iInterval+4+i) - UKnot(iInterval+2+i)) * N1(i+5);
    end
end

% N3 level interpolation
N3 = zeros(1, 4);
for i = -3:0
    if abs(UKnot(iInterval+4+i) - UKnot(iInterval+1+i)) < Nabs
        N3(i+4) = 0;
    else
        N3(i+4) = (u - UKnot(iInterval+1+i)) / (UKnot(iInterval+4+i) - UKnot(iInterval+1+i)) * N2(i+4);
    end
    if abs(UKnot(iInterval+5+i) - UKnot(iInterval+2+i)) < Nabs
        N3(i+4) = N3(i+4);
    else
        N3(i+4) = N3(i+4) + (UKnot(iInterval+5+i) - u) / (UKnot(iInterval+5+i) - UKnot(iInterval+2+i)) * N2(i+5);
    end
end

N = N3;
end
