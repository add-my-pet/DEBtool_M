%% estim_pars
% Estimates parameters

%%
function estim_pars
  % created 2015/02/10 by Goncalo Marques
  % modified 2015/02/10 by Bas Kooijman, 2015/03/31 by Goncalo Marques
  
  %% Syntax 
  % <../estim_pars.m *estim_pars*>
  
  %% Description
  % Runs the entire estimation procedures
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
  % estim_options sets many options
  
global pets pars_init_method method filter

% set data
[data, auxData, metaData, txtData, weights] = mydata_pets;

% set parameters
if pars_init_method == 0
  [par, metaPar, txtPar, flag] = get_pars(data.pet1, auxData.pet1, metaData.pet1);
elseif pars_init_method == 1
  filenm = ['results_', pets{1}, '.mat'];
  load(filenm, 'par');
  [par2, metapar, txt_par, chem] = feval(['pars_init_', pets{1}], metadata.pet1);
  if length(fieldnames(par.free)) ~= length(fieldnames(par2.free))
    fprintf('The number of parameters in pars.free in the pars_init and in the .mat file are not the same. \n');
    return;
  end
  par.free = par2.free;
elseif pars_init_method == 2
  [par, metaPar, txtPar] = feval(['pars_init_', pets{1}], metaData.pet1);
end
% check parameter set if you are using a filter
if filter
  filternm = ['filter_', metaPar.model];
  [pass, flag]  = feval(filternm, par);
  if ~pass 
    fprintf('The seed parameter set is not realistic. \n');
    print_filterflag(flag);
    return;
  end
end

if ~strcmp(method, 'no')
  if strcmp(method, 'nm')
    if filter
      par = petregr_f('predict_pets', par, data, auxData, weights, filternm); % WLS estimate parameters using overwrite
    else
      par = petregr('predict_pets', par, data, auxData, weights); % WLS estimate parameters using overwrite
    end
  end
end

% Results
results_pets(par, metaPar, txtPar, data, auxData, metaData, txtData, weights);

if filter
  eval(['warning_', metaPar.model,'(par)';]);
end
