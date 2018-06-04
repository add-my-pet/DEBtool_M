%% estim_pars
% Runs the entire estimation procedure

%%
function nsteps = estim_pars
  % created 2015/02/10 by Goncalo Marques
  % modified 2015/02/10 by Bas Kooijman, 
  %   2015/03/31, 2015/07/30, 2017/02/03 by Goncalo Marques, 
  %   2018/05/23 by Bas Kooijman
  
  %% Syntax 
  % <../estim_pars.m *estim_pars*>
  
  %% Description
  % Runs the entire estimation procedure
  %
  % * gets the parameters
  % * gets the data
  % * intiates the estimation procedure
  % * sends the results for handling
  %
  % Input
  %
  % * no input
  %  
  % Output
  %
  % * no output
  
  %% Remarks
  % estim_options sets many options;
  % option filter = 0 selects filter_nat, which always gives a pass, but still allows for costomized filters in the predict file
  
global pets toxs pars_init_method method filter covRules

n_pets = length(pets);
n_toxs = length(toxs);

% get data
[data, auxData, metaData, txtData, weights] = mydata_pets;

if n_pets == 1
  pars_initnm = ['pars_init_', pets{1}];
  if n_toxs == 0
    resultsnm = ['results_', pets{1}, '.mat'];
  else
    resultsnm = ['results_', pets{1}, '_', toxs{1}, '.mat'];
  end
else
  pars_initnm = 'pars_init_group';
  resultsnm = 'results_group.mat';
end

% set parameters
if pars_init_method == 0
  if n_pets ~= 1
    error('    For multispecies estimation get_pars cannot be used (pars_init_method cannot be 0)');
  elseif n_toxs ~= 0
    error('    For estimation with toxicant get_pars cannot be used (pars_init_method cannot be 0)');
  else
    [par, metaPar, txtPar] = get_pars(data.(pets{1}), auxData.(pets{1}), metaData.(pets{1}));
  end
elseif pars_init_method == 1
  if n_toxs == 0
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
  else
    load(resultsnm, 'par', 'metaPar', 'txtPar');
  end
elseif pars_init_method == 2
  if n_toxs == 0
    if n_pets == 1
      [par, metaPar, txtPar] = feval(pars_initnm, metaData.(pets{1}));
    else
      [par, metaPar, txtPar] = feval(pars_initnm, metaData);
    end
  else
    [~, ~, metaDataAux, ~, ~] = feval(['mydata_', pets{1}]);   % This is a provisory way of getting metaData for pars_init
    [par, metaPar, txtPar] = feval(pars_initnm, metaDataAux);
    [par, metaPar, txtPar] = feval([pars_initnm, '_', toxs{1}], par, metaPar, txtPar);
  end
end

% make sure that global covRules exists
if exist('metaPar.covRules','var')
  covRules = metaPar.covRules;
else
  covRules = 'no';
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
if ~strcmp(method, 'no')
  if strcmp(method, 'nm') % prepares for future extension to alternative minimazation algorithms
    if n_pets == 1
      [par, info, nsteps] = petregr_f('predict_pets', par, data, auxData, weights, filternm);   % estimate parameters using overwrite
    else
      [par, info, nsteps] = groupregr_f('predict_pets', par, data, auxData, weights, filternm); % estimate parameters using overwrite
    end
  end
end

% Results
results_pets(par, metaPar, txtPar, data, auxData, metaData, txtData, weights);

% check filter
parPets = parGrp2Pets(par); % convert parameter structure of group of pets to cell string for each pet
if filter
  for i = 1:n_pets
    if iscell(metaPar.model)
      feval(['warning_', metaPar.model{i}], parPets.(pets{i}));
    else
      feval(['warning_', metaPar.model], parPets.(pets{i}));
    end
  end
end
