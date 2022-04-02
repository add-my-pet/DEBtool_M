%% filter_solutions
% This function filters a set of estimation/calibration solutions and saves
% the result in a filterd file. 

function [ ] = filter_solutions(input_result, option, n)
   % Created at 2022/03/29 Juan Francisco Robles; 
   % Modified 2022/03/29, 2022/04/01, 2022/04/02 by Juan Robles  
   %

   %% Syntax
   % [filtered_result, info] = <../filter_solutions.m *filter_solutions*> (result, option, n)

   %% Description
   % This function filters a set of estimation/calibration solutions, discarding 
   % those that do not meet one of the following criteria: 
   % 
   % 1) Radius: A radius is used to discard solutions. Thus, when the Euclidean 
   % distance between the parameters of two solutions falls below the value of
   % the radius, the solution with the smaller value of the loss function is discarded. 
   % 2) Strait path: the creation of a strait path between two solutions is considered 
   % to check if they are different following the following assumption: 
   % "Two solutions (A and B) with loss function values of LF_A and LF_B, 
   % respectively are the same if the associated loss function values of a strait 
   % path between the A's parameters (P_A) and the B's ones (P_B) are all smaller 
   % than LF_B. 
   % There is only one strait path. 
   % The best choice of N might depend on the distance between P_A and P_B. 
   % The simplest choice is obviously N=1, with some risk that the conclusion 
   % that P_A and P_B are the same is wrong. 
   % The conclusion that P_A and P_B are not the same, does not imply that they are different. 
   %
   % Input
   %
   % * result: .mat object with a set of results and the information about
   %           their parameters. 
   % * option: the option to be applied for filtering the solutions: 
   %    'radius': for using a radius and Euclidean distance to filter the
   %              solutions.
   %    'path': for using a strait path between the solutions to discard
   %            those that are equal. 
   % * n: the maxium radius distance allowed (in case of using the 'radius'
   %      option as the filter) OR the steps for splitting the strait path
   %      between two solutions (i.e., the number of trials from the parameters
   %      of one solutions to other) .
   %      Example: if the parameter for one of the solutions being compared 
   %               equals 1, the parameter A1 of the other solution equals 2, 
   %               and the value B1 of n is 10, then the path between
   %               solutions A and B for parameters A1 and B1 is equal to:
   %               (2-1) / 10 = 0.1 so the final path from the solutions for
   %               parameters A1 and B1 is 1.1, 1.2, ..., 1.9
   %  
   % Output
   % 
   % * filtered_solutions: the set with the filtered solution
   % * info: an information struct containing the number of solutions
   %         discarded from the total ones.
   
   global pets
   
   format long
      
   if nargin >= 1 && nargin <= 3
     % Check if the parameters 'option' and 'n' are introduced. If not,
     % introduce their default values. 
     if nargin == 1
       option = 'path';
       n = 5;
     elseif nargin == 2
       if strcmp(option, 'radius')
         n = 0.2;
       else
         n = 5;
       end
     end
   end
   
   if strcmp(option, 'radius') % Filter using the radius defined in the n parameter.
       fprintf('Filtering solution using a radius value of %.2f \n', n);
       [ result ] = radius_filter(input_result, n);
       % Save the filtered results 
       save('filtered_result.mat', 'result');
   else % Filter using the strait path between the solutions.
       fprintf('Filtering solution using a strait path between solutions with %d steps \n', n);
       [ result ] = strait_path(input_result, n);
       % Save the filtered results 
       save('filtered_result.mat', 'result');
   end   
   
   % Filters solutions using the euclidean distance and a radius value. 
   function filtered_result = radius_filter(results_mmea, n)
       % read results_mmea
       load(results_mmea)
  
       if isfield(result, 'solutionsParameters')
         num_solutions = result.numSolutions; % number of solutions
         % Solutions indexes sorted by fitness value
         [~, sort_idxs] = sort(result.lossFunctionValues, 'ascend');
         length(sort_idxs)
         sorted_solutions = result.solutionsParameters(sort_idxs, :);
         % Variable to note the indexes of the discarded solutions
         discarded = false(num_solutions, 1);
         % Info. variable to calculate the average distance between the
         % discarded and not discarded solutions
         discarded_sol_dist = 0;
         non_discarded_sol_dist = 0;
         
         % Loop over the solutions         
         for i = 1:num_solutions-1
             fprintf('Solution %d \n', sort_idxs(i));
             if ~discarded(sort_idxs(i))
                 fs = sorted_solutions(i,:);
                 for j = i+1:num_solutions
                     if ~discarded(sort_idxs(j))
                         fprintf('Solution %d \n', sort_idxs(j));
                         ss = sorted_solutions(j,:);
                         distance = normalized_euclidean_distance(fs, ss, ..., 
                             result.parameterRanges);
                         % Discard the solution with the lowest value of the loss
                         % function (save the index of the solution)
                         fprintf('Distance between %d to %d is: %.4f \n', sort_idxs(i), sort_idxs(j), distance);
                         %disp(sorted_solutions(i,:));
                         %disp(sorted_solutions(j,:));
                         if distance <= n
                             % Add the distance to the accumulator
                             discarded_sol_dist = discarded_sol_dist + distance;
                             if result.lossFunctionValues(sort_idxs(i)) < result.lossFunctionValues(sort_idxs(j))
                                 discarded(sort_idxs(j)) = 1;
                             else
                                 discarded(sort_idxs(i)) = 1;
                             end
                         else
                             non_discarded_sol_dist = non_discarded_sol_dist + distance;
                         end
                     end
                 end
             end
         end
         % Discard the parameters and loss function values of the removed
         % solutions
         filtered_loss_funct_vals = result.lossFunctionValues(~discarded,:);
         filtered_parameterValues = result.solutionsParameters(~discarded,:);
         filtered_result.solutionsParameters = filtered_parameterValues;
         filtered_result.lossFunctionValues = filtered_loss_funct_vals; 
         % Store the same calibrated parameter names & ranges
         filtered_result.parameterNames = result.parameterNames; 
         filtered_result.parameterRanges = result.parameterRanges;
         
         % Loop over the non discarded solutions
         for i = 1:length(discarded)
             if ~discarded(i)
                 fprintf('Save solution %d \n', sort_idxs(i));
                 filtered_result.solutionSet.(strcat('solution_', ..., 
                     int2str(i))) = result.solutionSet.(strcat('solution_', ..., 
                     int2str(sort_idxs(i))));
             end
         end
         % Setting the new results set size
         non_disc_sols = sum(discarded(:) == 0);
         filtered_result.numSolutions = non_disc_sols;
         
         % Save the parameter info. 
         filtered_result.('solutionSet').data = result.solutionSet.data;
         filtered_result.('solutionSet').auxData = result.solutionSet.auxData;
         filtered_result.('solutionSet').txtPar = result.solutionSet.txtPar;
         filtered_result.('solutionSet').metaData = result.solutionSet.metaData;
         filtered_result.('solutionSet').txtData = result.solutionSet.txtData;
         filtered_result.('solutionSet').weights = result.solutionSet.weights;
         
         % Adding information about the discarding process
         filtered_result.discarding_info.discarded_solutions = result.numSolutions - non_disc_sols;
         filtered_result.discarding_info.non_discarded_solutions = non_disc_sols;
         filtered_result.discarding_info.avg_distange_discarded = discarded_sol_dist / (num_solutions - non_disc_sols);
         filtered_result.discarding_info.avg_distange_non_discarded = non_discarded_sol_dist / (non_disc_sols);
         fprintf('Solutions to save: %d \n', non_disc_sols);
       else
         fprintf('There are not values to calculate this measure. \n Please, revise your data before to try again.');
       end
   end

   % Filters solutions using the euclidean distance and a radius value. 
   function filtered_result = strait_path(results_mmea, n)
       % read results_mmea
       load(results_mmea)
   
       % Get the pet's name
       my_pet = strsplit(results_mmea,'_'); my_pet = [my_pet{2}, '_', my_pet{3}];
       pets = {my_pet}; % required for running nm
       [data, auxData, metaData, ~, weights] = eval(['mydata_', my_pet,';']);
       [par, ~, ~] = eval(['pars_init_', my_pet, '(metaData);']);  
       func = ['predict_', my_pet];
       
       if isfield(result, 'solutionsParameters')
           
         num_solutions = result.numSolutions; % number of solutions
         % Solutions indexes sorted by fitness value
         %sort_idxs = [1:length(result.lossFunctionValues)]; 
         [ ~, sort_idxs ] = sort(result.lossFunctionValues, 'ascend');
         disp(sort_idxs);
         sorted_solutions = result.solutionsParameters(sort_idxs, :);
         % Variable to note the indexes of the discarded solutions
         discarded = false(num_solutions, 1);
      
         % Loop over the solutions         
         for i = 1:num_solutions-1
             fprintf('Solution %d \n', sort_idxs(i));
             if ~discarded(sort_idxs(i))
                 fs = sorted_solutions(i,:);
                 for j = i+1:num_solutions
                     if ~discarded(sort_idxs(j))
                         %fprintf('Solution %d \n', sort_idxs(j));
                         ss = sorted_solutions(j,:);
                         to_discard = check_path(result, sort_idxs(i), sort_idxs(j), n, ..., 
                             func, par, data, auxData, weights);
                         if to_discard
                             if result.lossFunctionValues(sort_idxs(i)) < result.lossFunctionValues(sort_idxs(j))
                                 discarded(sort_idxs(j)) = 1;
                             else
                                 discarded(sort_idxs(i)) = 1;
                             end
                         else
                         end
                     end
                 end
             end
         end
         % Discard the parameters and loss function values of the removed
         % solutions
         filtered_loss_funct_vals = result.lossFunctionValues(~discarded,:);
         filtered_parameterValues = result.solutionsParameters(~discarded,:);
         filtered_result.solutionsParameters = filtered_parameterValues;
         filtered_result.lossFunctionValues = filtered_loss_funct_vals; 
         % Store the same calibrated parameter names & ranges
         filtered_result.parameterNames = result.parameterNames; 
         filtered_result.parameterRanges = result.parameterRanges;
         
         % Loop over the non discarded solutions
         for i = 1:length(discarded)
             if ~discarded(i)
                 fprintf('Save solution %d \n', i);
                 filtered_result.solutionSet.(strcat('solution_', ..., 
                     int2str(i))) = result.solutionSet.(strcat('solution_', ..., 
                     int2str(i)));
             end
         end
         % Setting the new results set size
         non_disc_sols = sum(discarded(:) == 0);
         filtered_result.numSolutions = non_disc_sols;
         
         % Save the parameter info. 
         filtered_result.('solutionSet').data = result.solutionSet.data;
         filtered_result.('solutionSet').auxData = result.solutionSet.auxData;
         filtered_result.('solutionSet').txtPar = result.solutionSet.txtPar;
         filtered_result.('solutionSet').metaData = result.solutionSet.metaData;
         filtered_result.('solutionSet').txtData = result.solutionSet.txtData;
         filtered_result.('solutionSet').weights = result.solutionSet.weights;
         
         % Adding information about the discarding process
         filtered_result.discarding_info.discarded_solutions = result.numSolutions - non_disc_sols;
         filtered_result.discarding_info.non_discarded_solutions = non_disc_sols;
         fprintf('Solutions to save: %d \n', non_disc_sols);
       else
         fprintf('There are not values to calculate this measure. \n Please, revise your data before to try again.');
       end
   end

   % Filters solutions using the euclidean distance and a radius value. 
   function discarded = check_path(result, idx_one, idx_two, n, func, par, data, auxData, weights)
       
       %% Setting parameters and loss function values from result data
       sol_one = result.solutionsParameters(idx_one);
       sol_two = result.solutionsParameters(idx_two);
       loss_fun_one = result.lossFunctionValues(idx_one);
       loss_fun_two = result.lossFunctionValues(idx_two);
       
       % Initially the solution is not discarded
       discarded = 0;
       % Parameter names
       parNm = result.parameterNames; 
       num_pars = length(sol_one); % Get the number of parameters
       % Loop over the solution's parameters
       for i = 1:num_pars & ~discarded
           aux = abs(sol_one(i)-sol_two(i));
           path_vals = aux:aux:aux*(n-1);
           auxSol = result.solutionSet.(strcat('solution_', int2str(idx_one))).par;

           % For each step from sol_one to sol_two
           for j = 1:length(path_vals) & ~discarded
               sol_one(i) = sol_one(i) + path_vals(j);
               auxSol = setfield(auxSol, parNm{i}, sol_one(i));
               % Evaluate fitness. 
               fitness = lossFn(func, auxSol, data, auxData, weights);;
               % If the fitness of the best solution if straith reachable
               % from other solutions, then discard them
               if fitness < loss_fun_two
                   fprintf('Discarded \n');
                   fprintf('Fitness sol II: %.5f, fitness sol I: %.5f \n', loss_fun_two, fitness);
                   discarded = 1; return;
               end
           end
           
       end
   end

    function loss_funct_value = evaluate_individual(parameters, qvec, np, nm, parnm, index, filternm, Y, meanY, W, data, auxData)
        %% make sure that global covRules exists
        if exist('metaPar.covRules','var')
           covRules = metaPar.covRules;
        else
           covRules = 'no';
        end
        func = 'predict_pets';
        qvec(index) = parameters';
       
        q = cell2struct(num2cell(qvec, np), parnm);
        f_test = feval(filternm, q);
        fileLossfunc = ['lossfunction_', lossfunction];
        if ~f_test 
           fprintf('The parameter set does not pass the filter. \n');
           loss_funct_value = 1e10; return;
        end
        [f, f_test] = feval(func, q, data, auxData);
        if ~f_test 
           fprintf('The parameter set for the simplex construction is not realistic. \n');
           loss_funct_value = 1e10; return;
        end
        [P, meanP] = struct2vector(f, nm);
        loss_funct_value = feval(fileLossfunc, Y, meanY, P, meanP, W);
    end
end