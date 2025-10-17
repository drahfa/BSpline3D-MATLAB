function visualizeError(CPx, CPy, CPz, xyz_original, station_xyz)
% VISUALIZEERROR Visualizes fitting errors on B-spline surface with error bars
%
% Copyright (c) 2008-2025 Ahmad Faisal Mohamad Ayob, VSG Labs
%
% INPUTS:
%   CPx, CPy, CPz   - Control point matrices from BSplineFit3
%   xyz_original    - Original XYZ offset data (n x 3)
%   station_xyz     - Structured station data
%
% Creates a visualization showing:
%   - Fitted B-spline surface
%   - Original data points
%   - Error bars showing fitting discrepancies
%   - Color-coded surface based on local fitting error

% Generate fitted surface
[u, v, w, surface_pts] = generateBSplineSurface(CPx, CPy, CPz);

% Compute errors between original data and fitted surface
[errors, nearest_pts] = computeFittingErrors(surface_pts, xyz_original);

% Create figure
figure('Name', 'B-Spline Surface Fitting Error Analysis', 'Position', [100 100 1200 800]);

% Plot 1: Surface with color-coded errors
subplot(2, 2, 1);
hold on; grid on;
surf(u, v, w, 'FaceAlpha', 0.7, 'EdgeColor', 'none');
colormap(jet);
title('Fitted B-Spline Surface');
xlabel('X'); ylabel('Y'); zlabel('Z');
axis equal;
view([-135 30]);

% Plot 2: Original data with error bars
subplot(2, 2, 2);
hold on; grid on;

% Plot fitted surface
surf(u, v, w, 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'FaceColor', [0.8 0.8 0.8]);

% Plot original points
scatter3(xyz_original(:,1), xyz_original(:,2), xyz_original(:,3), ...
    20, errors, 'filled');

% Plot error bars for points with significant errors
error_threshold = mean(errors) + std(errors);
significant_errors = errors > error_threshold;

for i = 1:size(xyz_original, 1)
    if significant_errors(i)
        % Draw line from original point to nearest surface point
        line([xyz_original(i,1) nearest_pts(i,1)], ...
             [xyz_original(i,2) nearest_pts(i,2)], ...
             [xyz_original(i,3) nearest_pts(i,3)], ...
             'Color', 'r', 'LineWidth', 1.5);
    end
end

colorbar;
title(sprintf('Original Data with Error Bars\n(Red lines show errors > threshold)'));
xlabel('X'); ylabel('Y'); zlabel('Z');
axis equal;
view([-135 30]);

% Plot 3: Error distribution histogram
subplot(2, 2, 3);
histogram(errors, 30, 'FaceColor', [0.3 0.5 0.8]);
hold on;
xline(mean(errors), 'r--', 'LineWidth', 2, 'Label', 'Mean');
xline(mean(errors) + std(errors), 'g--', 'LineWidth', 2, 'Label', 'Mean+Std');
xlabel('Fitting Error (Euclidean Distance)');
ylabel('Frequency');
title('Error Distribution');
grid on;

% Plot 4: Error statistics per station
subplot(2, 2, 4);
n_stations = length(station_xyz);
station_errors = zeros(n_stations, 1);

for i = 1:n_stations
    % Get points for this station
    station_pts = [station_xyz(i).x' station_xyz(i).y' station_xyz(i).z'];

    % Find corresponding errors
    station_indices = [];
    for j = 1:size(station_pts, 1)
        % Find matching points in original data
        distances = sqrt(sum((xyz_original - station_pts(j,:)).^2, 2));
        [~, idx] = min(distances);
        if distances(idx) < 1e-6  % Close enough match
            station_indices = [station_indices; idx];
        end
    end

    if ~isempty(station_indices)
        station_errors(i) = mean(errors(station_indices));
    end
end

bar(1:n_stations, station_errors, 'FaceColor', [0.5 0.7 0.9]);
xlabel('Station Number');
ylabel('Mean Error');
title('Average Fitting Error by Station');
grid on;

% Print summary statistics
fprintf('\n=== Fitting Error Analysis ===\n');
fprintf('Total data points: %d\n', size(xyz_original, 1));
fprintf('Mean error: %.6f\n', mean(errors));
fprintf('Std deviation: %.6f\n', std(errors));
fprintf('Max error: %.6f\n', max(errors));
fprintf('Min error: %.6f\n', min(errors));
fprintf('RMS error: %.6f\n', sqrt(mean(errors.^2)));
fprintf('Points above threshold (mean+std): %d (%.1f%%)\n', ...
    sum(significant_errors), 100*sum(significant_errors)/length(errors));

end
