% Unified startup script for bsplines3D - works on both Mac and PC
% Automatically detects the operating system and uses relative paths

% Get the directory where this startup script is located
scriptDir = fileparts(mfilename('fullpath'));

% Add paths relative to the script directory
addpath(scriptDir);
addpath(fullfile(scriptDir, 'testData'));

dataDirCandidates = {"data", "Data"};
for candidate = dataDirCandidates
    candidatePath = fullfile(scriptDir, candidate{1});
    if exist(candidatePath, 'dir')
        addpath(candidatePath);
    end
end

addpath(fullfile(scriptDir, 'sandBox'));
addpath(fullfile(scriptDir, 'optimization'));
addpath(fullfile(scriptDir, 'bsplineEngine3D'));

fprintf('bsplines3D paths configured successfully for %s\n', computer);

