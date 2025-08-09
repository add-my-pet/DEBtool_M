%% Clear workspace
% Delete an existing progress bar in case it was not properly delete before

clear all
format long

%% Define paths to files
% allSpeciesFolder = '..\..\..\..\..\AmPdata\species';
allSpeciesFolder = 'C:\Users\diogo\OneDrive - Universidade de Lisboa\Terraprima\DEB Resources\DEBtool\AmPdata\species';
% Output file
outputFileName = 'test_init_DEBInitNet_20250706.csv';

%% Get list of species
speciesList = getAllSpeciesNames(allSpeciesFolder);
numSpecies = length(speciesList);

%% Initialize table
columnNames = {
    'amp_loss', 'init_loss', 'final_loss', 'execution_time', ...
    'predict_failed', 'estim_error', 'init_func_error', 'fetch_error', 'debnet_error', 'predict_error', 'lossfun_error', ...
    'error', 'error_message',  ...
    };
numCols = length(columnNames);
varTypes = {
    'double', 'double', 'double', 'double', ...
    'logical', 'logical', 'logical', 'logical', 'logical', 'logical', 'logical', ...
    'logical', 'string', ...
    };
estimationResultsTable = table('Size', [numSpecies, numCols], 'VariableTypes', varTypes, 'VariableNames', columnNames, 'RowNames', speciesList);

%% Settings
saveResultsTableEvery = 30;

% Max execution time per species in seconds
maxTime = 10*60;  
maxRuns = 1;

%% Set up parallel pool
pool = gcp('nocreate');
if isempty(pool)
    pool = parpool('Processes');
end
numWorkers = pool.NumWorkers;

% Initialize variables
i = 1; % Index of species to submit
numCompleted = 0;
inProgressFutures = struct('future', {}, 'i', {}, 'speciesName', {}, 'startTime', {});

% Set global variables used in estimation function
parfevalOnAll(@setGlobalVars, 0);


%% Start the processing loop
while i <= numSpecies || ~isempty(inProgressFutures)
    % Submit new tasks if workers are available
    numJobsInProgress = length(inProgressFutures);
    while numJobsInProgress < numWorkers && i <= numSpecies
        speciesName = speciesList{i};

        % Submit parfeval task
        fut = parfeval(pool, @processSpecies, 4, speciesName, allSpeciesFolder);
        % Record the future, species name, start time
        startTime = tic;
        nFutures = length(inProgressFutures);
        inProgressFutures(nFutures+1).future = fut;
        inProgressFutures(nFutures+1).i = i;
        inProgressFutures(nFutures+1).speciesName = speciesName;
        inProgressFutures(nFutures+1).startTime = startTime;

        numJobsInProgress = length(inProgressFutures);
        fprintf('[%4d / %d | %50s] SUBMIT (%2d/%d) \n', i, numSpecies, speciesName, numJobsInProgress, numWorkers)
        i = i + 1;

        % Write results to .csv file every once in a while
        if mod(i, saveResultsTableEvery) == 0
            writetable(estimationResultsTable, outputFileName,'WriteRowNames',true);
            fprintf('Table saved in %s\n', outputFileName);
        end
    end

    % Check futures for completion or timeout
    idx = 1;
    while idx <= length(inProgressFutures)
        futInfo = inProgressFutures(idx);
        if strcmp(futInfo.future.State, 'finished')
            % Fetch outputs
            try
                [ampLoss, initLoss, finalLoss, predictFailed] = fetchOutputs(futInfo.future);
                executionTime = toc(futInfo.startTime);
                fprintf('[%4d / %d | %50s] RESULT: %.2f PROGRESS (%4d/%d) \n', futInfo.i, numSpecies, futInfo.speciesName, executionTime, numCompleted+1, numSpecies)

                % Store results
                estimationResultsTable{futInfo.speciesName, 'execution_time'} = executionTime;
                estimationResultsTable{futInfo.speciesName, 'amp_loss'} = ampLoss;
                estimationResultsTable{futInfo.speciesName, 'init_loss'} = initLoss;
                estimationResultsTable{futInfo.speciesName, 'final_loss'} = finalLoss;
                estimationResultsTable{futInfo.speciesName, 'predict_failed'} = predictFailed;

            catch ME
                % Handle error
                if isempty(futInfo.future.Error)
                    error_message = ME.message;
                else
                    error_message = futInfo.future.Error.message;
                end
                executionTime = toc(futInfo.startTime);
                fprintf('[%4d / %d | %50s] ERROR: %s %.2f PROGRESS (%4d/%d)\n', futInfo.i, numSpecies, futInfo.speciesName, error_message, executionTime, numCompleted+1, numSpecies)
                estimationResultsTable{futInfo.speciesName, 'execution_time'} = executionTime;
                estimationResultsTable{futInfo.speciesName, 'error'} = true;
                estimationResultsTable{futInfo.speciesName, 'error_message'} = string(error_message);

                % Check where error ocurred
                for e=1:length(futInfo.future.Error.stack)
                    switch futInfo.future.Error.stack(e).name
                        case 'petregr_f'
                            estimationResultsTable{futInfo.speciesName, 'estim_error'} = true;
                        case 'init_DEBInitNet'
                            estimationResultsTable{futInfo.speciesName, 'init_func_error'} = true;
                        case 'fetch_input_for_DEBInitNet'
                            estimationResultsTable{futInfo.speciesName, 'fetch_error'} = true;
                        case 'DEBNet'
                            estimationResultsTable{futInfo.speciesName, 'debnet_error'} = true;
                        case 'lossfun'
                            estimationResultsTable{futInfo.speciesName, 'lossfun_error'} = true;
                    end
                    if strncmp(futInfo.future.Error.stack(e).name, 'predict_', length('predict_'))
                        estimationResultsTable{futInfo.speciesName, 'predict_error'} = true;
                    end
                end

            end
            % Remove future from in-progress list
            inProgressFutures(idx) = [];
            numCompleted = numCompleted + 1;
        else
            % Check for timeout
            elapsedTime = toc(futInfo.startTime);
            if elapsedTime > maxTime
                cancel(futInfo.future);
                fprintf('[%4d / %d | %50s] TIMEOUT: DEBInitNet initalization took longer than %d seconds to execute. PROGRESS (%4d/%d)\n', futInfo.i, numSpecies, futInfo.speciesName, maxTime, numCompleted+1, numSpecies)
                estimationResultsTable{futInfo.speciesName, 'execution_time'} = maxTime;
                estimationResultsTable{futInfo.speciesName, 'error'} = false;
                estimationResultsTable{futInfo.speciesName, 'error_message'} = "Maximum execution time exceeded";
                % Remove future from in-progress list
                inProgressFutures(idx) = [];
                numCompleted = numCompleted + 1;
            else
                idx = idx + 1;
            end
        end
    end

    % Pause for a short time to avoid busy waiting
    pause(0.1);
end

%% Write results to a .csv file
writetable(estimationResultsTable, outputFileName,'WriteRowNames',true);
fprintf('Table saved in %s\n', outputFileName);

%% Functions to set global variables
function setGlobalVars
global lossfunction report max_step_number max_fun_evals tol_simplex tol_fun simplex_size covRules tol_restart;
lossfunction = 'sb';
report = 0;
max_step_number = 5e2;
max_fun_evals = 5e3;
tol_simplex = 1e-4;
tol_fun = 1e-4;
simplex_size = 0.05;
covRules = 0;
tol_restart = 1e-4;
end

function setGlobalPetsVar(speciesName)
global pets
pets = {speciesName};
end

%% Function to process each species
function [ampLoss, initLoss, finalLoss, predictFailed] = processSpecies(speciesName, allSpeciesFolder)

% Initialize output variables
ampLoss = nan;
initLoss = nan;
finalLoss = nan;
predictFailed = false;


% Set up data for the species
speciesFolder = fullfile(allSpeciesFolder, speciesName);
% Check if the species folder exists
if isfolder(speciesFolder)
    % Change directory to the species folder
    cd(speciesFolder);

    % Run mydata.m
    [data, auxData, metaData, txtData, weights] = feval(['mydata_' speciesName]);
    % Get parameters from .mat file
    resultsMatFilename = ['results_' speciesName '.mat'];
    if exist(resultsMatFilename, 'file')
        load(resultsMatFilename, "par")
    else
        [par, ~, ~] = feval(['pars_init_' speciesName], metaData);
    end

    % Compute AmP loss
    [prdData, info] = feval(['predict_' speciesName], par, data, auxData);
    ampLoss = lossfun(data, prdData, weights);

    % Get initial parameters with DEBInitNet
    [par, metaPar, ~] = init_DEBInitNet(data, auxData, metaData, txtData);

    % Compute initial loss
    [prdData, info] = feval(['predict_' speciesName], par, data, auxData);
    if ~info
        predictFailed = true;
        return
    end
    initLoss = lossfun(data, prdData, weights);

    % Format arguments for 'petregr_f'
    dataStruct = struct(speciesName, data);
    auxDataStruct = struct(speciesName, auxData);
    weightsStruct = struct(speciesName, weights);
    filternm = ['filter_' metaPar.model];
    setGlobalPetsVar(speciesName);

    % Run estimation
    [~, ~, ~, finalLoss] = petregr_f('predict_pets', par, dataStruct, auxDataStruct, weightsStruct, filternm);     

else
    error('Folder for species "%s" does not exist.', speciesName);
end
end

%% Helper functions
function speciesList = getAllSpeciesNames(allSpeciesFolder)
% Get a list of all files and folders in the specified directory
allFiles = dir(allSpeciesFolder);

% Filter the list to include only directories
isDir = [allFiles.isdir]; % Logical index for directories
speciesList = {allFiles(isDir).name}; % Extract names of directories

% Remove '.' and '..' from the list (current and parent directory)
speciesList = speciesList(~ismember(speciesList, {'.', '..'}));
end
