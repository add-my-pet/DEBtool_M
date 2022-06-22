%% shade
% Finds parameter values for a pet that minimizes the lossfunction using the 
% Succes History Adaptation of Differential Evolution (SHADE) using a filter
%%
function [q, result, bsf_fval] = nm_runs(func, par, metaPar, txtPar, data, ..., 
    auxData, metaData, txtData, weights, filternm)
   % created 2020/02/15 by Juan Francisco Robles; 
   % modified 2020/02/17 by Juan Francisco Robles, 2020/02/20, 2020/02/21,
   % 2020/02/24, 2020/02/26, 2020/02/27, 2021/01/14, 2021/03/12,
   % 2021/03/22, 2021/05/11
   %   

   %% Syntax
   % [q, info, result, bsf_fval] = <../lshade.m *lshade*> (func, par, data, auxData, weights, filternm)

   %% Description
   % Finds parameter values for a pet that minimizes the lossfunction using the 
   % SHADE multimodal algorithm using a filter.
   % The filter gives always a pass in the case that no filter has been selected 
   % in <estim_options.html *estim_options*>.
   % The values for SHADE initialization can be modifyed by editing the file
   % <calibration_options.html> *calibration_options*>
   %
   % Input
   %
   % * func: character string with name of user-defined function;
   %      see nrregr_st or nrregr  
   % * par: structure with parameters
   % * data: structure with data
   % * auxData: structure with auxiliary data
   % * weights: structure with weights
   % * filternm: character string with name of user-defined filter function
   %  
   % Output
   % 
   % * q: structure with parameters, result of the algorithm
   % * info: 1 if convergence has been successful; 0 otherwise
   % * archive: the set of solutions found by the multimodal algorithm
   % * bsf_fval: the best fitness value found

   %% Remarks
   % Set options with <calibration_options.html *calibration_options*>.
   % The number of fields in data is variable.
   %%%%%%%%%%%%%%%%%%%
   %% This package is a MATLAB/Octave source code of SHADE which is an improved version of SHADE 1.1.
   %% 
   %% The original code of this algorithm was taken from: https://sites.google.com/site/tanaberyoji/software
   %%
   %% Note that this source code is transferred from the C++ source code version.
   %% About SHADE, please see following papers:
   %%
   %% * Ryoji Tanabe and Alex Fukunaga: Success-History Based Parameter Adaptation for Differential Evolution, Proc. IEEE Congress on Evolutionary Computation (CEC-2013).
   %%
   %%%%%%%%%%%%%%%%%%% 

   global num_results lossfunction pop_size pets
   
   % Option settings   
   fileLossfunc = ['lossfunction_', lossfunction];
   format shortG;
   format compact;
   
   %% Taking data for objective function
   st = data;
   [nm, nst] = fieldnmnst_st(st); % nst: number of data sets

   for i = 1:nst   % makes st only with dependent variables
      fieldsInCells = textscan(nm{i},'%s','Delimiter','.');
      auxVar = getfield(st, fieldsInCells{1}{:});   % data in field nm{i}
      k = size(auxVar, 2);
      if k >= 2
         st = setfield(st, fieldsInCells{1}{:}, auxVar(:,2));
      end
   end

   % Y: vector with all dependent data
   % W: vector with all weights
   [Y, meanY] = struct2vector(st, nm);
   W = struct2vector(weights, nm);

   %% Getting parameters and setting objectives
   parnm = fieldnames(par.free); % Get free parameters names
   np = numel(parnm); % Get number of free parameters
   n_par = sum(cell2mat(struct2cell(par.free)));

   if (n_par == 0) % no parameters to iterate
      fprintf('There are not parameters to iterate. Finishing the calibration process \n');
      return; 
   end

   index = 1:np; % Get indexes of these free parameters which can be modifyed
   index = index(cell2mat(struct2cell(par.free)) == 1);
   free = par.free; % free is here removed, and after execution added again

   %% Auxiliary variables for function evaluation
   q = rmfield(par, 'free'); % copy input parameter matrix into output
   qvec = cell2mat(struct2cell(q));

   %% Initialize the main population
   [popold, ranges] = gen_individuals(func, par, data, auxData, filternm); 
   disp('Ranges');
   disp(ranges);
   
   %% Initialize function evaluations and fitness values
   fitness = zeros(pop_size, 1);

   %% Population size
   pop_size = num_results;
   
   %% Function evaluations counter
   fun_evals_counter = 0; 
   
   for ind = 1:pop_size
      % Evaluate each individual
      qvec(index) = popold(ind,:)';
      q = cell2struct(num2cell(qvec, np), parnm);
      [f, ~] = feval(func, q, data, auxData);
      [P, meanP] = struct2vector(f, nm);    
      fitness(ind) = feval(fileLossfunc, Y, meanY, P, meanP, W); 
   end
   
   % Adding the population individuals evaluation to the function
   % evaluations counter. 
   fun_evals_counter = fun_evals_counter + pop_size;
   
   %% Apply NM iteratively for each solution
   for i = 1 : pop_size 
      fprintf('Aplying Nelder Mead over individual %d. \n', i);
      qvec(index) = popold(i,:)';
      q = cell2struct(num2cell(qvec, np), parnm);
      q.free = free;
      [q, fun_evals, funct_val] = iterative_local_search('predict_pets', q, data, ..., 
          auxData, weights, filternm, 'experimental', fitness(i));
      q = rmfield(q, 'free');
      qvec = cell2mat(struct2cell(q));
      popold(i,:) = qvec(index)';
      fitness(i) = funct_val;
      % Add the function evaluations to the counter
      fun_evals_counter = fun_evals_counter + fun_evals;
   end
            
   [~, idxs] = sort(fitness, 'ascend');
   q = popold(idxs(1), :);
   bsf_fval = fitness(idxs(1));
   
   %% Result file variables
   result.nm_runs.numSolutions = pop_size; % maximum size of the archive
   result.nm_runs.solutionsParameters = popold; % solutions to store in the archive
   result.nm_runs.lossFunctionValues = fitness; % function value for the archived solutions
   result.nm_runs.parameterNames = parnm(index); % Calibrated parameter names
   result.nm_runs.ranges = ranges; % Calibrated parameter ranges
   result.runtime_information.fun_evals = fun_evals_counter;
   %result.nm_runs = updateArchive(result.nm_runs, popold, fitness);
  
  %% Save the results for the current run
  result = save_results(result, 'nm_runs', par, ..., 
      metaPar, txtPar, data, auxData, metaData, txtData, weights);
   
  save(['results_', pets{1}, '_nm_runs'], 'result');
end