function result = group_mmea_runs(results_file, species, dist_tolerance, fitness_tolerance)
% created 2022/03/05 by Juan Francisco Robles
% edited 2022/04/10, 2022/05/15 by Juan Francisco Robles
%% Syntax 
% result = <../group_mmea_runs.m *group_mmea_runs*> (results_file, dist_tolerance, fitness_tolerance)

%% Description
% Groups the results obtained in each SHADE MMEA run in a single result
% file. 
% This methods also filters the solutions discarding the following ones: 
% 1) Repeated solutions (same parameter values). 
% 2) Proximal solutions (a tolerance value is used to discard those
% solutions that are under a certain distance). 
% 3) Quality (a tolerance value in defined to discard those solutions with
% a fitness far from the best fitness).
%
% Input
%
% * results: filename to be grouped.
% * dist_tolerance: the maximum tolerance value used for discarding 
% * solutions using their parameter (genotype) distance. 
% * fitness_tolerance: the maximum tolerance value used for discarding
% * solutions using their fitness (phenotype) distance. 
% - TIP: With the dist_tolerance and the fitness_tolerance parameters it is
% - possible to control how many solutions to keep/discard from the mmea
% - calibration so they need to be used carefully. The default values are
% - 1.05 (i.e., 5% of tolerance) for each parameter. 
% 
% Output
%
% * result: file containing the grouped result of all the runs performed 
% * through the calibration process (the file and the result has the same
% * format than the calibration result file)
%

if isa(results_file, 'char')
    %% Load results file
    load(results_file);
    %% Load species values 
    my_pet = strsplit(results_file,'_'); my_pet = [my_pet{2}, '_', my_pet{3}];
else
    result = results_file;
    if isempty(species)
       fprintf('The species name to which the result belongs is not defined. \n');
       fprintf('Please, enter the species name as the second function parameter \n.');
       return;
    end
    my_pet = species;
end

% Check if tolerance values are defined and set default values if not. 
if ~exist('dist_tolerance', 'var')
   dist_tolerance = 1.05;
end
if ~exist('fitness_tolerance', 'var')
   fitness_tolerance = 1.05;
end

pets = {my_pet}; % required for running nm
n_pets = length(pets);

eval(['[data, auxData, metaData, txtData, weights] = mydata_', my_pet,';']);
eval(['[par, metaPar, txtPar] = pars_init_', my_pet, '(metaData);']);
  
%% Get the number of runs
num_runs = sum(contains(fieldnames(result), 'run_'));

%% Run over the results
res.lossFunctionValues = [];
res.solutionsParameters = [];
res.parameterNames = result.('run_1').parameterNames;
res.ranges = result.('run_1').ranges;

%% Group the loss funtion and parameter values
for run=1:num_runs
    res.lossFunctionValues = [res.lossFunctionValues; result.(['run_', num2str(run)]).lossFunctionValues];
    res.solutionsParameters = [res.solutionsParameters; result.(['run_', num2str(run)]).solutionsParameters];
end

%% Filter the results

%% 1) Discard equal solutions.
unique_paramas = res.solutionsParameters;
unique_lfs = res.lossFunctionValues;
[~, IX]= unique(unique_paramas, 'rows');
if length(IX) < size(unique_paramas, 1) % There exist some duplicate solutions
   res.solutionsParameters = unique_paramas(IX, :);
   res.lossFunctionValues = unique_lfs(IX, :);
end

%% 2) Filter the solutions by their space (parameter) distance
prev_num_sols = size(res.solutionsParameters, 1);
[res.solutionsParameters, res.lossFunctionValues] = params_distance_filter(res.solutionsParameters, ..., 
    res.lossFunctionValues, dist_tolerance);
n_sol = size(res.solutionsParameters,1);
fprintf('Filtering solutions by their space or parameter (genotype) distance. \n');
fprintf('%g out of %g solutions removed from the solutions set (%.2f%%)\n', (prev_num_sols-n_sol), ..., 
    prev_num_sols, ((prev_num_sols-n_sol)/prev_num_sols * 100));

%% 3) Filter the solutions by their fitness threshold (+5% of the minimum fitness value). 
prev_num_sols = size(res.solutionsParameters, 1);
[res.solutionsParameters, res.lossFunctionValues] = val_distance_filter(res.solutionsParameters, ..., 
    res.lossFunctionValues, fitness_tolerance);
n_sol = size(res.solutionsParameters,1);
fprintf('Filtering solutions by their fitness (phenotype) distance. \n');
fprintf('%g out of %g solutions removed from the solutions set (%.2f%%)\n', (prev_num_sols-n_sol), ..., 
    prev_num_sols, ((prev_num_sols-n_sol)/prev_num_sols * 100));
res.numSolutions = length(res.lossFunctionValues);

par_set = res.solutionsParameters; % set with the best parameters found in multimodal calibration
n_pars = size(par_set,1);

%% Variables to compose the solutions to calculate MRE and SMSE.
parnm = fieldnames(par.free); % Get free parameters names
np = numel(parnm); % Get number of free parameters
index = 1:np; % Get indexes of these free parameters which can be modifyed
index = index(cell2mat(struct2cell(par.free)) == 1);
free = par.free; % free is here removed, and after execution added again
aux = rmfield(par, 'free'); % copy input parameter matrix into output
auxvec = cell2mat(struct2cell(aux));

%% Compose the solutions from results and calculate errors
for sol=1:n_pars
  auxvec(index) = par_set(sol,:)';
  aux = cell2struct(num2cell(auxvec, np), parnm);
  aux.free = free; % add substructure free to q
  % convert parameter structure of group of pets to cell string for each pet
  parPets = parGrp2Pets(aux); 
  % get (mean) relative errors and symmetric mean squared errors
  weightsMRE = weights;  % define a weights structure with weight 1 for every data point and 0 for the pseudodata 

  for i = 1:n_pets    
    if isfield(weights, 'psd')
      psdSets = fields(weights.psd);
      for j = 1:length(psdSets)
        weightsMRE.psd.(psdSets{j}) = zeros(length(weightsMRE.psd.(psdSets{j})), 1);
      end
    end
    [metaPar.MRE, metaPar.RE, info] = mre_st(['predict_', pets{i}], parPets.(pets{i}), data, auxData, weightsMRE);
    [metaPar.SMSE, metaPar.SSE] = smse_st(['predict_', pets{i}], parPets.(pets{i}), data, auxData, weightsMRE);
    if info == 0
      error('One parameter set did not pass the customized filters in the predict file')
    end
    clear('dataTemp', 'auxDataTemp', 'weightsMRETemp');
  end

  % save results to result_group.mat or result_my_pet.mat
  if n_pets > 1
      res.solutionSet.strcat('solution_', int2str(sol)).par = aux;
      res.solutionSet.strcat('solution_', int2str(sol)).txtPar = txtPar;
      res.solutionSet.strcat('solution_', int2str(sol)).metaPar = metaPar;
      res.solutionSet.strcat('solution_', int2str(sol)).metaData = metaData;
  else % n_pets == 1
      metaPar.MRE = metaPar.MRE;   metaPar.RE = metaPar.RE;
      metaPar.SMSE = metaPar.SMSE; metaPar.SSE = metaPar.SSE;

      res.('solutionSet').(strcat('solution_', int2str(sol))).par = aux;
      res.('solutionSet').(strcat('solution_', int2str(sol))).metaPar = metaPar;
  end
end
res.('solutionSet').data = data;
res.('solutionSet').auxData = auxData;
res.('solutionSet').txtPar = txtPar;
res.('solutionSet').metaData = metaData;
res.('solutionSet').txtData = txtData;
res.('solutionSet').weights = weights;
 
result = res;

filename = ['results_', my_pet, '_mmea_grouped.mat'];
save(filename, 'result');

end

function [sol_red, val_red] = params_distance_filter(sol, val, tol)
  [n_sol, ~] = size(sol); sel=true(n_sol,1);
  for i=1:n_sol-1
    for j=i+1:n_sol
      ratio = max(sol([i;j],:),[],1)./min(sol([i;j],:),[],1);
      if all(ratio<tol)
        if val(i) < val(j)
          sel(j) = false;
        else
          sel(i) = false;
        end 
      end
    end
    sol_red = sol(sel,:); val_red = val(sel);
  end
end

function [sol_red, val_red] = val_distance_filter(sol, val, tol)
  [n_sol, ~] = size(sol); sel=true(n_sol,1);
  min_val = min(val);
  for i=1:n_sol
     if val(i) > min_val * tol
        sel(i) = false;
      end 
  end
  sol_red = sol(sel,:); val_red = val(sel);
end