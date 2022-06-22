%% estim_pars
% Runs the AmP estimation procedure 

%%
function [nsteps, info, fval] = estim_pars
  % created 2015/02/10 by Goncalo Marques
  % modified 2015/02/10 by Bas Kooijman, 
  %   2015/03/31, 2015/shade07/30, 2017/02/03 by Goncalo Marques, 
  %   2018/05/23 by Bas Kooijman,  
  %   2018/08/17 by Starrlight Augustine,
  %   2019/03/20, 2019/12/16, 2019/12/20, 2021/06/02 by Bas kooijman
  
  %% Syntax 
  % [nsteps, info, fval] = <../estim_pars.m *estim_pars*>
  
  %% Description
  % Runs the entire estimation procedure, see Marques et al 2018, PLOS computational biology  https://doi.org/10.1371/journal.pcbi.1006100
  % See also Robles et al 2021, (in prep) for the ea-method.
  % 
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
  % * nsteps: scalar with number of steps
  % * info: boolean with succussful convergence (true)
  % * fval: minimum of loss function
  
  %% Remarks
  % estim_options sets many options;
  % Option filter = 0 selects filter_nat, which always gives a pass, but
  % still allows for costomized filters in the predict file;
  % Option output >= 5 allow the filling of global refPets to choose
  % comparison species, otherwise this is done automatically.
  
global pets pars_init_method method filter covRules

n_pets = length(pets);

% get data
[data, auxData, metaData, txtData, weights] = mydata_pets;

if n_pets == 1
  pars_initnm = ['pars_init_', pets{1}];
  resultsnm   = ['results_', pets{1}, '.mat'];
  calibration_options('results_filename', resultsnm);
else
  pars_initnm = 'pars_init_group';
  resultsnm = 'results_group.mat';
end

% set parameters
if pars_init_method == 0
  if n_pets ~= 1
    error('    For multispecies estimation get_pars cannot be used (pars_init_method cannot be 0)');
  else
    [par, metaPar, txtPar] = get_pars(data.(pets{1}), auxData.(pets{1}), metaData.(pets{1}));
  end
elseif pars_init_method == 1
    load(resultsnm, 'par');
    if n_pets == 1
      [par2, metaPar, txtPar] = feval(pars_initnm, metaData.(pets{1}));
    else
      [par2, metaPar, txtPar] = feval(pars_initnm, metaData);
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

% make sure that global covRules exists
if exist('metaPar.covRules','var')
  covRules = metaPar.covRules;
else
  covRules = 'no';
end

% set weightsPar in case of n_pets > 1, to minimize scaled variances of parameters
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

% check parameter set if you are using a filter
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
  pass = 1;
end

% perform the actual estimation
switch method
  case 'nm'
    if n_pets == 1
      [par, info, nsteps, fval] = petregr_f('predict_pets', par, data, auxData, weights, filternm);   % estimate parameters using overwrite
    else
      [par, info, nsteps, fval] = groupregr_f('predict_pets', par, data, auxData, weights, weightsPar, filternm); % estimate parameters using overwrite
    end
    
  case 'mmea'
    [par, solutions_set, fval] = calibrate; 
    info = ~isempty(solutions_set); 
    nsteps = solutions_set.runtime_information.run_1.fun_evals;
  case 'nr'
    [par, solutions_set, fval] = calibrate; 
    info = ~isempty(solutions_set); 
    nsteps = solutions_set.runtime_information.fun_evals;
  otherwise % do not estimate
end

% Results
switch method
  case {'nm','no'}
    results_pets(par, metaPar, txtPar, data, auxData, metaData, txtData, weights);
  case 'mmea'
    mmea_name =  strsplit(resultsnm, '.');
    resultsnm = [mmea_name{1}, '_mmea.', mmea_name{2}];
    calibration_options('results_filename', resultsnm);
    result_pets_mmea(solutions_set, par, metaPar, txtPar, data, auxData, metaData, txtData, weights);
  case 'nr'
    mmea_name =  strsplit(resultsnm, '.');
    resultsnm = [mmea_name{1}, '_mmea.', mmea_name{2}];
    calibration_options('results_filename', resultsnm);
    result_pets_mmea(solutions_set, par, metaPar, txtPar, data, auxData, metaData, txtData, weights);
end

% check filter
%parPets = parGrp2Pets(par); % convert parameter structure of group of pets to cell string for each pet
%if filter
%  for i = 1:n_pets
%    if iscell(metaPar.model)
%      feval(['warning_', metaPar.model{i}], parPets.(pets{i}));
%    else
%      feval(['warning_', metaPar.model], parPets.(pets{i}));
%    end
%  end
end
