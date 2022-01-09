%% elas_lossfun
% gets elasticity coefficient of loss function

%%
function [elas2, elas, nm] = elas2_lossfun(my_pet, del)
% created by Bas Kooijman 2022/01/09

%% Syntax
% [elas2, elas, nm] = <../elas2_lossfun.m *elas2_lossfun*> (my_pet, del)

%% Description
% Gets the second order elasticity coefficients of loss function for free parameters.
% Assumes local existence of mydata_my_pet.m, predict_my_pet.m and results_my_pet.mat
%
% Input:
%
% * my_pet: character string with name of entry
% * del: optional scalar with mutiplication factor for perturbation of parameters (default 1e-6)
%
% Output:
%
% * elas2: vector of 2nd order elasticity coefficients of loss function
% * elas: vector of elasticity coefficients of loss function
% * nm: cel-string with names of free parameters
%
%% Remarks
% the output does not include contributions from the augmented term or from pseudo-data.
% Uses indirectly global "lossfunction" with strings re, sb or su, see DEBtool_M/lib/regr, default lossfunction = 'sb'
% Takes the mean of foreward and backward perturbations of parameters.
  
  if ~exist('del','var')
    del = 1e-6;
  end
  
  load(['results_', my_pet], 'par'); 
  eval(['[data, auxData, ~, ~, weights] = mydata_', my_pet, ';']); data = rmfield(data,'psd');
  eval(['prdData = predict_', my_pet, '(par, data, auxData);']);
  
  lf = lossfun(data, prdData, weights); % loss function 
  
  % get free settings
  nm = fieldnames(par); nm(end) = []; n_par = length(nm); 
  free = zeros(n_par,1); for i=1:n_par; free(i)=par.free.(nm{i}); end
  nm = nm(free == 1); n_free = length(nm); % names of free parameters
  
  % perturbations
  lf_f = zeros(n_free,1); lf_b = lf_f; % initiate foreward and backward perturbed loss functions
  lf_f2 = zeros(n_free, n_free); lf_b2 = lf_f; % initiate foreward and backward 2nd perturbed loss functions
  elas_f = lf_f; elas_b = lf_b; % initiate forward and backward elasticities
  elas2_f = lf_f; elas2_b = lf_b; % initiate forward and backward 2nd order elasticities
  for i = 1:n_free
    % foreward
    par_fi = par; par_fi.(nm{i}) =  par.(nm{i}) * (1 + del); % perturb parameter
    eval(['prdData_fi = predict_', my_pet, '(par_fi, data, auxData);']);
    lf_f(i) = lossfun(data, prdData_fi, weights); % loss function 
    elas_f(i) = (lf_f(i)/ lf - 1)/ del;
    % backward
    par_bi = par; par_bi.(nm{i}) =  par.(nm{i}) * (1 - del); % perturb parameter
    eval(['prdData_bi = predict_', my_pet, '(par_bi, data, auxData);']);
    lf_b(i) = lossfun(data, prdData_bi, weights); % loss function 
    elas_b(i) = (1 - lf_b(i)/ lf)/ del;
    for j = 1:n_free
      % foreward
      par_fi2 = par_fi; par_fi2.(nm{j}) =  par_fi2.(nm{j}) * (1 + del); % perturb parameter
      eval(['prdData_fi2 = predict_', my_pet, '(par_fi2, data, auxData);']);
      lf_f2(i,j) = lossfun(data, prdData_fi2, weights); % loss function 
      elas2_f(i,j) = (lf_f2(i,j)/ lf - 1)/ del;
      % backward
      par_bi2 = par_bi; par_bi2.(nm{j}) =  par_bi2.(nm{j}) * (1 - del); % perturb parameter
      eval(['prdData_bi2 = predict_', my_pet, '(par_bi2, data, auxData);']);
      lf_b2(i,j) = lossfun(data, prdData_bi2, weights); % loss function 
      elas2_b(i,j) = (1 - lf_b2(i,j)/ lf)/ del;
    end
  end
  
  % ideally, the foreward and backward variants should be the same
  elas  = (elas_f + elas_b)/2;   % mean of foreward and backward elasticities
  elas2 = (elas2_f + elas2_b)/2; % mean of foreward and backward 2nd order elasticities
 
  %prt_tab({nm, elas2}, [' ';nm], ['del = ', num2str(del)]); % temporary output
 