%% lshade
% Finds parameter values for a pet that minimizes the lossfunction using the 
% Linear Succes History Adaptation of Differential Evolution (L-SHADE) using a filter
%%
function [q, result, bsf_fval] = lshade(func, par, data, auxData, weights, filternm)
   % created 2020/02/15 by Juan Francisco Robles; 
   % modified 2020/02/17 by Juan Francisco Robles, 2020/02/20, 2020/02/21,
   % 2020/02/24, 2020/02/26, 2020/02/27, 2021/03/12,2021/03/22, 2021/05/11
   % 2022/04/24 by Juan Francisco Robles

   %% Syntax
   % [q, info, archive, bsf_fval] = <../lshade.m *lshade*> (func, par, data, auxData, weights, filternm)

   %% Description
   % Finds parameter values for a pet that minimizes the lossfunction using the 
   % L-SHADE multimodal algorithm using a filter.
   % The filter gives always a pass in the case that no filter has been selected 
   % in <estim_options.html *estim_options*>.
   % The values for L-SHADE initialization can be modifyed by editing the file
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
   %% This package is a MATLAB/Octave source code of L-SHADE which is an improved version of SHADE 1.1.
   %% 
   %% The original code of this algorithm was taken from: https://sites.google.com/site/tanaberyoji/software
   %%
   %% Note that this source code is transferred from the C++ source code version.
   %% About L-SHADE, please see following papers:
   %%
   %% * Ryoji Tanabe and Alex Fukunaga: Improving the Search Performance of SHADE Using Linear Population Size Reduction,  Proc. IEEE Congress on Evolutionary Computation (CEC-2014), Beijing, July, 2014.
   %%
   %%%%%%%%%%%%%%%%%%% 

    global num_results lossfunction max_fun_evals num_runs  
    global pop_size refine_running refine_run_prob refine_best
    global verbose verbose_options random_seeds max_calibration_time
    global activate_niching sigma_share min_convergence_threshold 
    global max_pop_dist

    % Option settings
    % initiate info setting
    info = struct;

    fileLossfunc = ['lossfunction_', lossfunction];
    format long;
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
    pen_val = 1e10;

    %% Population size
    pop_size = num_results;
   
    %%  parameter settings for L-SHADE
    problem_size = length(index);
    max_nfes = max_fun_evals; 
    p_best_rate = 0.11;
    arc_rate = 1.4;
    memory_size = 5;
    max_pop_size = pop_size;
    min_pop_size = 4.0;

    %% Result file variables 
    result.numSolutions = pop_size;
    result.solutionsParameters = zeros(0, problem_size);
    result.lossFunctionValues = zeros(0, 1); 
    result.parameterNames = parnm(index); % Calibrated parameter names

    %% Take initial time
    time_start = tic;

    %% Runs loop
    fprintf('Launching calibration. \n');
    fprintf('Using SHADE multimodal algorithm. \n');
    fprintf('Total calibration runs: %d \n', num_runs);
    if max_fun_evals ~= Inf
      fprintf('Calibration defined with evaluations as stop criteria \n');
      fprintf('The total number of evaluations is: %d for each run \n', max_fun_evals);
      fprintf('The total number of evaluations for the whole calibration is %d \n', max_fun_evals * num_runs);
    elseif max_calibration_time ~= Inf
      fprintf('Calibration defined with time as stop criteria \n');
      fprintf('The total calibration time is: %d minutes for each run \n', max_calibration_time);
      fprintf('The total calibration time for the whole calibration is %d minutes \n', max_calibration_time * num_runs);
    else
      fprintf('Calibration defined with convergence as stop criteria \n');
      fprintf('The minimum convergence is: %.5f \n', min_convergence_threshold);
      fprintf('The total calibration time and the maximum fun evals are set to infinite \n');
    end
    for run = 1:(min(num_runs, length(random_seeds)))
      %% Take run initial time
      run_time_start = tic; 
      fprintf('Run %d. \n', run);
      % Initializing random number generator.
      rng(random_seeds(run), 'twister'); 

      %% Archive file variables
      archive.numSolutions = arc_rate * pop_size; % maximum size of the archive
      archive.solutionsParameters = zeros(0, problem_size); % solutions to store in the archive
      archive.lossFunctionValues = zeros(0, 1); % function value for the archived solutions

      %% Initialize the main population
      [popold, ranges] = gen_individuals(func, par, data, auxData, filternm); 
      disp('Ranges');
      disp(ranges);

      pop = popold; % the old population becomes the current population
      
      %% Initialize function evaluations and fitness values
      nfes = 0;
      fitness = zeros(pop_size, 1);
      bsf_fit_var = 1e+30;
      bsf_solution = zeros(1, problem_size);
      
      for ind = 1:pop_size
         % Evaluate each individual
         qvec(index) = pop(ind,:)';
         q = cell2struct(num2cell(qvec, np), parnm);
         f_test = feval(filternm, q);
         
         % If the function evaluation does not pass the filter then 
         % punish the individual (in order to discard it later) 
         if ~f_test 
            fprintf('The parameter set does not pass the filter. \n');
         end
         try
            [f, f_test] = feval(func, q, data, auxData);
         catch
            f_test = 1;
         end
         if ~f_test 
            fprintf('The parameter set for the simplex construction is not realistic. \n');
            fitness(ind) = pen_val;
         else
            [P, meanP] = struct2vector(f, nm);
            try 
               fitness(ind) = feval(fileLossfunc, Y, meanY, P, meanP, W);
            catch
               fitness(ind) = pen_val;
            end
         end
         
         nfes = nfes + 1; % Update the evaluations counter
         if fitness(i) < bsf_fit_var
            bsf_fit_var = fitness(i);
            bsf_solution = pop(i, :);
         end
         % Check stopping criteria
         if max_calibration_time ~= Inf
            current_time = toc(time_start)/60;
            if current_time > max_calibration_time; break; end
         elseif max_nfes ~= Inf
            if nfes > max_nfes; break; end
         end
      end
      
      %% Initialize memory for SHADE
      memory_sf = 0.5 .* ones(memory_size, 1);
      memory_cr = 0.5 .* ones(memory_size, 1);
      memory_pos = 1;

      %% Main loop
      while nfes < max_nfes
         fprintf('Num func evals %d | Total progress %.2f %%\n', ..., 
             nfes, (nfes/max_nfes) * 100.0);
         if activate_niching
            length(pop)
            length(fitness)
            fit_sharing = fitness_sharing(pop, fitness, ranges, sigma_share);
            [~, sorted_index] = sort(fit_sharing, 'ascend');
         end
         [temp_fit, ~] = sort(fitness, 'ascend');
         if verbose
            fprintf('Best %d loss function values: \n', verbose_options);
            disp(temp_fit(1:verbose_options).');
            fprintf('Last %d loss function values: \n', verbose_options);
            disp(temp_fit(length(temp_fit)-verbose_options:length(temp_fit)).');
         end
         pop = popold; % the old population becomes the current population

         mem_rand_index = ceil(memory_size * rand(pop_size, 1));
         mu_sf = memory_sf(mem_rand_index);
         mu_cr = memory_cr(mem_rand_index);

         %% Generating crossover rate
         cr = mu_cr + 0.1 .* rand(size(mu_cr,1),1);  % alternative with base Matlab
         term_pos = mu_cr == -1;
         cr(term_pos) = 0;
         cr = min(cr, 1);
         cr = max(cr, 0);

         %% Generating scaling factor
         sf = mu_sf + 0.1 * tan(pi * (rand(pop_size, 1) - 0.5));
         pos = find(sf <= 0);

         while ~isempty(pos)
            sf(pos) = mu_sf(pos) + 0.1 * tan(pi * (rand(length(pos), 1) - 0.5));
            pos = find(sf <= 0);
         end

         sf = min(sf, 1); 

         r0 = 1 : pop_size;
         popAll = [pop; archive.solutionsParameters];
         [r1, r2] = gnR1R2(pop_size, size(popAll, 1), r0);

         %% Generate children
         pNP = max(round(p_best_rate * pop_size), 2); %% choose at least two best solutions
         randindex = ceil(rand(1, pop_size) .* pNP); %% select from [1, 2, 3, ..., pNP]
         randindex = max(1, randindex); %% to avoid the problem that rand = 0 and thus ceil(rand) = 0
         
         pbest = pop(sorted_index(randindex), :); %% randomly choose one of the top 30% of the total solutions

         vi = pop + sf(:, ones(1, problem_size)) .* (pbest - pop + pop(r1, :) - popAll(r2, :));
         vi = boundConstraint(vi, pop, ranges);
         mask = rand(pop_size, problem_size) > cr(:, ones(1, problem_size)); % mask is used to indicate which elements of ui comes from the parent
         rows = (1 : pop_size).'; cols = floor(rand(pop_size, 1) * problem_size)+1; % choose one position where the element of ui doesn't come from the parent
         jrand = sub2ind([pop_size problem_size], rows, cols); mask(jrand) = false;
         ui = vi; ui(mask) = pop(mask);

         % Initialize children fitness
         children_fitness = zeros(size(ui,1), 1);
         
         %% Evaluate children
         penalized_individuals = 0; 
         for child = 1:size(ui,1)
            qvec(index) = ui(child,:)';
            q = cell2struct(num2cell(qvec, np), parnm);
            f_test = feval(filternm, q);
            non_feasible = 0;
            % If does not pass the filter then try to reduce the maximum and
            % minimums for the random parameter values and try again till obtain a
            % feasible individual. 
            if ~f_test
               non_feasible = 1;
            end
            % If solution is feasible then evaluate it.  
            if ~non_feasible
               try
                  [f, f_test] = feval(func, q, data, auxData);
               catch
                  f_test = 1;
               end
               if ~f_test % If DEB function is not feasible then set an extreme fitness value.
                  penalized_individuals = penalized_individuals + 1;
                  children_fitness(child) = pen_val;
               else % If not set the fitness
                  ui(child,:) = qvec(index)';
                  [P, meanP] = struct2vector(f, nm);
                  try
                     children_fitness(child) = feval(fileLossfunc, Y, meanY, P, meanP, W);
                  catch
                     fprintf('Penalizing non feasible individual. \n'); 
                     children_fitness(child) = pen_val;
                  end
               end
            % If solution is not feasible then set an extreme fitness value.  
            else
              penalized_individuals = penalized_individuals + 1;
              children_fitness(child) = pen_val;
            end
         end
         % Display information about the number of non-feasible childrens
         % generated in the previous step. 
         if penalized_individuals > 0 && verbose
           fprintf('% d out of %d solutions (%.2f%%) have been penalized for not-passing the species filters. \n', ..., 
               penalized_individuals, pop_size, (penalized_individuals / pop_size) * 100.0); 
         end

         %% Update best fitness found so far
         for i = 1 : pop_size
            nfes = nfes + 1;
            % Check if better than actual best
            if children_fitness(i) < bsf_fit_var
              bsf_fit_var = children_fitness(i);
              bsf_solution = ui(i, :);
            end
            % Check if stopping criteria has been achieved
            if max_calibration_time ~= Inf
               current_time = toc(time_start)/60;
               if current_time > max_calibration_time; break; end
            elseif max_nfes ~= Inf
               if nfes > max_nfes; break; end
            end
         end

         %% Comparison between parents and children
         % Compare parents and children fitness. Then...
         dif = abs(fitness - children_fitness);
         % .. if I == 1: the parent is better; I == 2: the offspring is better
         I = (fitness > children_fitness);
         goodCR = cr(I == 1);  
         goodF = sf(I == 1);
         dif_val = dif(I == 1);

         % Update the archive of solutions
         archive = updateArchive(archive, popold(I == 1, :), fitness(I == 1));

         [fitness, I] = min([fitness, children_fitness], [], 2);

         popold = pop;
         popold(I == 2, :) = ui(I == 2, :);
         
         %% Apply refinement over the solutions if the option is activated.
         if refine_running
            % Check if local search is active an if it is then check if to
            % apply to the current individual
            for i = 1 : pop_size
               randVal = rand(1);
               if randVal < refine_run_prob
                  qvec(index) = popold(i,:)';
                  q = cell2struct(num2cell(qvec, np), parnm);
                  q.free = free;
                  refine = 1;
                  try
                     [f, f_test] = feval(func, q, data, auxData);
                  catch
                     f_test = 1;
                  end
                  % refine only feasible individuals and the penalize 
                  % non-feasible ones
                  if ~f_test
                     funct_val = pen_val;
                     iters = 1;
                  else
                     fprintf('Refining individual using local search \n');
                     [q, iters, funct_val] = iterative_local_search('predict_pets', q, data, auxData, weights, filternm, 'running', fitness(i));
                  end                 
                  q = rmfield(q, 'free');
               else
                  refine = 0;
               end
               if refine
                  % The number of function evaluations are not considered thus
                  % it is necessary for the population resize procedure of the
                  % algorithm.
                  nfes = nfes + iters;
                  qvec = cell2mat(struct2cell(q));
                  popold(i,:) = qvec(index)';
                  fitness(i) = funct_val;
               end
            end
            % Check if stopping criteria has been achieved
            if max_calibration_time ~= Inf
               current_time = toc(time_start)/60;
               if current_time > max_calibration_time; break; end
            elseif max_nfes ~= Inf
               if nfes > max_nfes; break; end
            end
         end
         num_success_params = numel(goodCR);

         if num_success_params > 0 
            sum_dif = sum(dif_val);
            dif_val = dif_val / sum_dif;

            %% for updating the memory of scaling factor 
            memory_sf(memory_pos) = (dif_val' * (goodF .^ 2)) / (dif_val' * goodF);

            %% for updating the memory of crossover rate
            if max(goodCR) == 0 || memory_cr(memory_pos)  == -1
               memory_cr(memory_pos)  = -1;
            else
               memory_cr(memory_pos) = (dif_val' * (goodCR .^ 2)) / (dif_val' * goodCR);
            end

            memory_pos = memory_pos + 1;
            if memory_pos > memory_size;  memory_pos = 1; end
         end
         % Check if stopping criteria has been achieved
         if max_calibration_time ~= Inf
            current_time = round(toc(run_time_start)/60);
            if current_time > max_calibration_time; break; end
            % If verbose is activated, the completion status of the 
            % calibration process is printed according to the stop 
            % criterion.
            if verbose
               fprintf('Time accomplished: %d of %d minutes (%d %%) for the run  %d \n', ...,
                  current_time, max_calibration_time, ..., 
                  round((current_time/max_calibration_time)*100.0), run);
               if num_runs > 1
                   current_time = round(toc(time_start)/60);
                   fprintf('The time accomplished for the whole calibration: %d of %d minutes (%d %%) \n', ...,
                       current_time, max_calibration_time*num_runs, ..., 
                       round((current_time/(max_calibration_time*num_runs))*100.0));
               end
            end
         elseif max_nfes ~= Inf
            if nfes > max_nfes; break; end
         elseif min_convergence_threshold ~= Inf
            avg_prev_fitness = mean(temp_fit);
            avg_new_fitness = mean(fitness);
            improvement = avg_prev_fitness - avg_new_fitness; 
            fprintf('Previous avg. loss funtion: %.5f, Current avg. loss function: %.5f. Improvement: %.5f \n', ..., 
                avg_prev_fitness, avg_new_fitness, improvement);
            if improvement < min_convergence_threshold; break; end
         else
             dist = population_distance(popold);
             fprintf('Avg. normalized distance: %.5f \n', dist);
             if dist < max_pop_dist || nfes > 100000; break; end
         end

         %% for resizing the population size
         plan_pop_size = round((((min_pop_size - max_pop_size) / max_nfes) * nfes) + max_pop_size);
         if pop_size > plan_pop_size
            reduction_ind_num = pop_size - plan_pop_size;
            if pop_size - reduction_ind_num <  min_pop_size; reduction_ind_num = pop_size - min_pop_size;end
            pop_size = pop_size - reduction_ind_num;
            for r = 1 : reduction_ind_num
               [~, indBest] = sort(fitness, 'ascend');
               worst_ind = indBest(end);
               popold(worst_ind,:) = [];
               pop(worst_ind,:) = [];
               fitness(worst_ind,:) = [];
            end

            archive.numSolutions = round(arc_rate * pop_size); 
            if size(archive.solutionsParameters, 1) > archive.numSolutions
               rndpos = randperm(size(archive.solutionsParameters, 1));
               rndpos = rndpos(1 : archive.numSolutions);
               archive.solutionsParameters = archive.solutionsParameters(rndpos, :);
            end
         end
      end

      if verbose
         % Print the best result values and finish
         fprintf('Best-so-far error value = %1.8e\n', bsf_fit_var);
         fprintf('Best-so-far configuration values: \n');
         disp(bsf_solution);
      end

      bsf_fval = bsf_fit_var;
      qvec(index) = bsf_solution';
      q = cell2struct(num2cell(qvec, np), parnm);
      q.free = free; % add substructure free to q 

      %% If best one wants to be refined with the Nelder Mead's simplex method
      if refine_best
         fprintf('Refining best individual found using local search \n');
         [q, fun_cals, fval] = iterative_local_search('predict_pets', q, data, auxData, weights, filternm, 'best', bsf_fval);
         nfes = nfes + fun_cals;
         while (1.0 - (fval / bsf_fval)) > 0.0000001
            if verbose
               % Print the best and finish
               fprintf('Improved from = %1.8e to %1.8e \n', bsf_fval, fval);
            end
            % Update the best fitness
            bsf_fval = fval;
            % Launch the local search again
            [q, fun_cals, fval] = iterative_local_search('predict_pets', q, data, auxData, weights, filternm, 'best', bsf_fval);
            nfes = nfes + fun_cals;
         end
      end
      % Update best solution set
      result = updateArchive(result, popold, fitness);

      %% Setting run information
      tEnd = datevec(toc(run_time_start)./(60*60*24));
      tEnd = tEnd(3:6);
      info.(['run_', num2str(run)]).run_time = tEnd;
      info.(['run_', num2str(run)]).fun_evals = nfes;
    end
    tEnd = datevec(toc(time_start)./(60*60*24));
    tEnd = tEnd(3:6);
    info.('total_time') = tEnd;
    %% Add best to solutions archive and finish
    if refine_best
      aux = q; 
      aux = rmfield(aux, 'free');
      auxvec = cell2mat(struct2cell(aux));
      result = updateArchive(result, auxvec(index)', fval);
    end
    %% Store the information structure into the results set
    result.runtime_information = info;
    %% Save also the parameter ranges into the final result
    result.parameterRanges = ranges; 
end
