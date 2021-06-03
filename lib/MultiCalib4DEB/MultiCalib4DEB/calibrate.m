%% calibrate
% Runs the calibration procedure

%%
function [best_sol, solutions_set, best_fval] = calibrate
   % created 2020/03/07 by Juan Francisco Robles
   % edited 2021/01/15, 2021/01/19, 2021/03/14, 2021/03/22, 2021/05/12,
   % 2021/05/18, 2021/06/02 (fix by Bas Kooijman) by Juan Francisco Robles
   %% Syntax 
   % [pars, outcome, best_fval] = <../calibrate.m *calibrate*>

   %% Description
   % Runs the entire calibration procedure
   %
   % * gets the parameters
   % * gets the data
   % * initiates the estimation procedure
   % * sends the results for handling
   %
   % Input
   %
   % * no input
   %  
   % Output
   %
   % * par: parameters of the best solution found
   % * outcome: set of different solutions found by the algorithm
   % * best_fval: best function value

   %% Remarks
   % estim_options sets many options;
   % option filter = 0 selects filter_nat, which always gives a pass, but still allows for costomized filters in the predict file
  
   global pets pars_init_method method filter covRules results_filename
   global results_display mat_file

   n_pets = length(pets);

   % get data
   [data, auxData, metaData, txtData, weights] = mydata_pets;

   if n_pets == 1
      pars_initnm = ['pars_init_', pets{1}];
   else
      pars_initnm = 'pars_init_group';
   end
   
   %% set parameters
   if pars_init_method == 0
      if n_pets ~= 1
         error('    For multispecies estimation get_pars cannot be used (pars_init_method cannot be 0)');
      else
         [par, metaPar, txtPar] = get_pars(data.(pets{1}), auxData.(pets{1}), metaData.(pets{1}));
      end
   elseif pars_init_method == 1
      if strcmp(mat_file, '')
         fprintf('The results filename is not properly defined. \n Try to set the filename properly or run the calibration with the options 0 or 2 for the ''pars_init_metod'' option \n');
         return
      else
         load(mat_file, 'par');
         if n_pets == 1
            [par2, metaPar, txtPar] = feval(pars_initnm, metaData.(pets{1}));
         else
            [par2, metaPar, txtPar] = feval(pars_initnm, metaData);
         end
      end
      if length(fieldnames(par.free)) ~= length(fieldnames(par2.free))
         fprintf('The number of parameters in pars.free in the pars_init and in the .mat file are not the same. \n');
         return;
      end
         par.free = par2.free;
   elseif pars_init_method == 2
      if n_pets == 1
         [par, metaPar, txtPar] = feval(pars_initnm, metaData.(pets{1}));
      else
         [par, metaPar, txtPar] = feval(pars_initnm, metaData);
      end
   end

   %% make sure that global covRules exists
   if exist('metaPar.covRules','var')
      covRules = metaPar.covRules;
   else
      covRules = 'no';
   end

   %% set weightsPar in case of n_pets > 1, to minimize scaled variances of parameters
   if n_pets > 1
      fldPar = fieldnames(par.free);
      for i = 1: length(fldPar)
         if isfield(metaPar, 'weights') && isfield(metaPar.weights, fldPar{i})
            weightsPar.(fldPar{i}) = metaPar.weights.(fldPar{i});
         else
            weightsPar.(fldPar{i}) = 0;
         end
      end
   end

   %% check parameter set if you are using a filter
   parPets = parGrp2Pets(par); % convert parameter structure of group of pets to cell string for each pet
   if filter
      pass = 1; filternm = cell(n_pets,1);
      for i = 1:n_pets
         if ~iscell(metaPar.model) % model is a character string
            filternm = ['filter_', metaPar.model];
            [passSpec, flag] = feval(filternm, parPets.(pets{i}));
         elseif length(metaPar.model) == 1 % model could have been a character string
            filternm = ['filter_', metaPar.model{1}];
            [passSpec, flag] = feval(filternm, parPets.(pets{i}));
         else % model is a cell string
            filternm{i} = ['filter_', metaPar.model{i}];
            [passSpec, flag] = feval(filternm{i}, parPets.(pets{i}));
         end
         if ~passSpec
            fprintf(['The seed parameter set for ', pets{i}, ' is not realistic. \n']);
            print_filterflag(flag);
         end
         pass = pass && passSpec;
      end
      if ~pass 
         error('The seed parameter set is not realistic');
      end
   else
      filternm = 'filter_nat'; % this filter always gives a pass
   end

   %% perform the calibration
   if ~strcmp(method, 'no')
      if strcmp(method, 'mm1') % With SHADE
         if n_pets == 1
            [best_sol, solutions_set, best_fval] = shade('predict_pets', par, data, auxData, weights, filternm);   % estimate parameters using overwrite
         else
            fprintf('This mode has not been developed yet. It will be availlable soon \n'); % Not yet
         end
      elseif strcmp(method, 'mm2') % With L-SHADE
         if n_pets == 1
            [best_sol, solutions_set, best_fval] = lshade('predict_pets', par, data, auxData, weights, filternm);   % estimate parameters using overwrite
         else
            fprintf('This mode has not been developed yet. It will be availlable soon \n'); % Not yet
         end
      else
      end
   end

   % Save the best results data into solution set for printing or working
   % with them by using DEB modules.
   % results_pets(best_sol, metaPar, txtPar, data, auxData, metaData, txtData, weights);
   solutions_set = save_results(solutions_set, par, metaPar, txtPar, data, auxData, metaData, txtData, weights);
    %% Save solutions found for a latter analysis
   if exist('solutions_set', 'var') && ~isempty(solutions_set)
      if strcmp(results_filename, 'Default') ~= 0
         dtime = strsplit(datestr(datetime), ' ');
         auxtime = dtime{2}; auxtime([3 6 9]) = 'hms'; % Changing ':' time separators to h/m/s
         filename = ['solutionSet_', pets{1}, '_', dtime{1}, '_', auxtime]; % Filename with calibrated pet name and date; removed: strcat
      else
         filename = results_filename;
      end
      save(filename, 'solutions_set');
      disp('CALIBRATION PROCESS FINISHED CORRECTLY');
   end
   
   %% Print results depeding on results output parameter
   plot_results(solutions_set, ..., 
            solutions_set.results.txtPar, solutions_set.results.data, ...,
            solutions_set.results.auxData, metaData, ..., 
            solutions_set.results.txtData, weights, results_display);
   
   %% check filter
   parPets = parGrp2Pets(best_sol); % convert parameter structure of group of pets to cell string for each pet
   if filter
      for i = 1:n_pets
         if iscell(metaPar.model)
            feval(['warning_', metaPar.model{i}], parPets.(pets{i}));
         else
            feval(['warning_', metaPar.model], parPets.(pets{i}));
         end
      end
   end
end