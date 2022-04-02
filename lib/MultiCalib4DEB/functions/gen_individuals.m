%% gen_individuals
% Generates a set of individuals from the set of parameteres being
% calibrated and species pseudodata. 

function [inds, bounds] = gen_individuals(func, par, data, auxData, filternm)
   % Created at 2020/02/15 Juan Francisco Robles; 
   % Modified 2020/02/22 by Juan Francisco Robles, 2020/02/24, 2020/02/27, 
   %

   %% Syntax
   % [inds, bounds] = <../gen_individuals.m *gen_individuals*> (func, par, data, auxData, weights, filternm)

   %% Description
   % Generates a set of individuals for multimodal calibration starting from
   % historical data values. 
   %
   % Input
   %
   % * func: character string with name of user-defined function;
   %      see nrregr_st or nrregr  
   % * par: structure with parameters
   % * data: structure with data
   % * auxData: structure with auxiliary data
   % * filternm: character string with name of user-defined filter function
   %  
   % Output
   % 
   % * inds: the set of individuals generated
   % * bounds: the ranges generated

   %% Remarks
   % Set options with <calibration_options.html *calibration_options*>.
   % The number of fields in data is variable.

   global gen_factor factor_type pop_size bounds_from_ind add_initial ranges

   % prepare variable
   %   st: structure with dependent data values only
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

   % Getting only free parameter names
   parnm = fieldnames(par.free);
   np = numel(parnm);
   n_par = sum(cell2mat(struct2cell(par.free)));
   if (n_par == 0)
      return; % no parameters to iterate
   end

   % Getting free parameter indexes.
   index = 1:np;
   index = index(cell2mat(struct2cell(par.free)) == 1);  % indices of free parameters

   % Getting the names of the set of parameters to calibrate
   calibnm = parnm(index);
   n_calibpar = length(calibnm);

   fprintf('Parameters to calibrate: %d \n', n_calibpar);
   fprintf('Parameter names: ');
   disp(calibnm');
   fprintf('\n');
   
   % set options if necessary
   if ~exist('gen_factor','var') || isempty(gen_factor)
      calibration_options('gen_factor', 0.25);
   end
   if ~exist('bounds_from_ind','var') || isempty(bounds_from_ind)
      calibration_options('bounds_from_ind', 1);
   end

   q = rmfield(par, 'free'); % copy input parameter matrix into output
   qvec = cell2mat(struct2cell(q));

   fprintf('Original parameter values \n');
   disp(qvec(index)');
   
   % Getting these pseudovalues which are into the set of parameters being calibrated
   cell_data = struct2cell(data); % Transforming data to cell
   % Chechking if pseudodata is available
   if ~(isempty(find(strcmp(fieldnames(cell_data{1}), 'psd'), 1)))
      psdnm = fieldnames(cell_data{1}.psd);
      pseudodata = cell_data{1}.('psd');
   else
      fprintf('Pseudodata is not available. Estimating maximum and minimums using a factor. \n');
   end

   % Setting default maximums and minimums for random individual
   % initialization ranges. 
   if strcmp(factor_type, 'sum')
       par_maxs = qvec(index) + gen_factor;
       par_mins = qvec(index) - gen_factor;
       par_mins(par_mins < 0) = 0;
       disp(qvec(index)');
   else
       par_maxs = qvec(index) * (1.0 + gen_factor);
       par_mins = qvec(index) * (1.0 - gen_factor);
       par_mins(par_mins < 0) = 0;
   end
   % Check if some range is defined from calibration options and set the
   % range if true.
   if ~isempty(fieldnames(ranges))
       orig_values = qvec(index);
       par_range_names = fieldnames(ranges);
       length_range = length(par_range_names);
       for i = 1: length_range
           par_pos = find(ismember(calibnm, par_range_names(i)));
           par_name = char(par_range_names(i));
           % If to exist the parameter into calibration parameters then...
           if ~isempty(par_pos)
               % If two ranges, then there exist a minimum and maximum
               % value for the parameter
               if length(ranges.(par_name)) > 1
                   if ranges.(par_name)(2) >= ranges.(par_name)(1)
                       par_maxs(par_pos) = ranges.(char(par_range_names(i)))(2);
                       par_mins(par_pos) = ranges.(char(par_range_names(i)))(1);
                   end
               else % If one range value then to apply a factor to the original range value
                   factor = ranges.(par_name);
                   % Set range values depeinding on factor_type
                   if strcmp(factor_type, 'sum')
                       par_maxs(par_pos) = orig_values(par_pos) + gen_factor;
                       if orig_values(par_pos) - gen_factor < 0
                           par_mins(par_pos) = 0;
                       else
                           par_mins(par_pos) = orig_values(par_pos) - gen_factor;
                       end
                   else
                       par_maxs(par_pos) = orig_values(par_pos) * (1.0 + factor);
                       if orig_values(par_pos) - gen_factor <= 0
                           par_mins(par_pos) = 0;
                       else
                           par_mins(par_pos) = orig_values(par_pos) * (1.0 - factor);
                       end
                   end
               end
           end
       end
   end
   
   % If pseudodata is found
   if (~isempty(psdnm) && ~bounds_from_ind)
      % For each calibration parameter, check if it has an associated pseudo
      % parameter and then change the value for its minimum and maximum
      % range. 
      for i = 1:n_calibpar
         if ~isempty(fieldnames(ranges))
            if (~isempty(find(strcmp(psdnm, calibnm(i)), 1)) && isempty(find(par_range_names, calibnm(i), 1)))
                % Set pseudo-parameters's ranges. 
                if strcmp(factor_type, 'sum')
                   par_maxs(i) = pseudodata.(char(calibnm(i))) + gen_factor;
                   if pseudodata.(char(calibnm(i))) - gen_factor < 0
                       par_mins(i) = 0;
                   else
                       par_mins(i) = pseudodata.(char(calibnm(i))) - gen_factor;
                   end
               else
                   par_maxs(i) = pseudodata.(char(calibnm(i))) * (1.0 + factor);
                   if pseudodata.(char(calibnm(i))) - gen_factor <= 0
                       par_mins(i) = 0;
                   else
                       par_mins(i) = pseudodata.(char(calibnm(i))) * (1.0 - factor);
                   end
               end
            end
         else
            if (~isempty(find(strcmp(psdnm, calibnm(i)), 1)))
               par_maxs(i) = pseudodata.(char(calibnm(i))) * (1.0 + gen_factor);
               par_mins(i) = pseudodata.(char(calibnm(i))) * (1.0 - gen_factor);
            end
         end
      end
   end

   % Set bounds
   bounds = [par_mins'; par_maxs'];

   % Generate individuals.
   inds = zeros(pop_size, n_calibpar);
   auxvec = qvec;

   % If we want to introduce a Nerled Med refined infividual into population
   % then set the maximum number of individuals to genrate to population size
   % less two. Thus, the two last individuals of population will be the
   % initial guest and the refined one
   if add_initial
      inds_to_gen = pop_size-1;
      inds(inds_to_gen+1,:) = qvec(index);
   else
      inds_to_gen = pop_size;
   end

   for ind = 1:inds_to_gen
      for param = 1:n_calibpar
         inds(ind, param) = (par_maxs(param)-par_mins(param)) * rand(1) + par_mins(param);
      end
      % Check if the new individual generated pass the filter
      auxvec(index) = inds(ind,:); 
      aux = cell2struct(num2cell(auxvec, np), parnm);
      f_test = feval(filternm, aux);
      % If does not pass the filter then try to reduce the maximum and
      % minimums for the random parameter values and try again till obtain a
      % feasible individual. 
      if ~f_test 
         % Reduce maximum and minimum range using the user-defined reduction
         % factor and generate the individual parameters. 
         while ~f_test
            % Generate new parameters
            for param = 1:n_calibpar
               inds(ind, param) = (par_maxs(param)-par_mins(param)) * rand(1) + par_mins(param);
            end
            % Check if the individual pass the filter...
            auxvec(index) = inds(ind,:); 
            aux = cell2struct(num2cell(auxvec, np), parnm);
            f_test = feval(filternm, aux);
         end
         % Check if the parameter set can be evaluated by the DEB function. 
         [~, f_test] = feval(func, q, data, auxData);
         if ~f_test 
            fprintf('The parameter set is not real. \n');
         end
      else
         [~, f_test] = feval(func, q, data, auxData);
         if ~f_test 
            fprintf('The parameter set is not real. \n');
         end
      end
   end
end
