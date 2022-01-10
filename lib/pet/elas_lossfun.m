%% elas_lossfun
% gets elasticity coefficient of loss function

%%
function [elas, nm_elas] = elas_lossfun(my_pet, del)
% created by Bas Kooijman 2022/01/09

%% Syntax
% [elas, nm_elas] = <../elas_lossfun.m *elas_lossfun*> (my_pet, del)

%% Description
% Gets the elasticity coefficients of loss function for free parameters.
% Assumes local existence of mydata_my_pet.m, predict_my_pet.m and results_my_pet.mat
%
% Input:
%
% * my_pet: character string with name of entry
% * del: optional scalar with mutiplication factor for perturbation of parameters (default 1e-6)
%
% Output:
%
% * elas: vector of elasticity coefficients of loss function
% * nm_elas: cell-string with names of free parameters
%
%% Remarks
% the output does not include contributions from augmented terms.
% Uses global "lossfunction" with strings re, sb or su, see DEBtool_M/lib/regr, default lossfunction = 'sb'
% Takes the mean of foreward and backward perturbations of parameters.

  global lossfunction
  
  fileLossfunc = ['lossfunction_', lossfunction];

  if ~exist('del','var')
    del = 1e-6;
  end
  
  load(['results_', my_pet], 'par'); 
  [data, auxData, ~, ~, weights] = feval(['mydata_', my_pet]);  
  prdData = feval(['predict_', my_pet], par, data, auxData);
  prdData = predict_pseudodata(par, data, prdData); % append speudo-data predictions
  
  % prepare variable st: structure with dependent data values only
  st = data;
  [nm, nst] = fieldnmnst_st(st); % nst: number of data sets
  %  
  for i = 1:nst   % makes st only with dependent variables
    fieldsInCells = textscan(nm{i},'%s','Delimiter','.');
    auxVar = getfield(st, fieldsInCells{1}{:});   % data in field nm{i}
    k = size(auxVar, 2);
    if k >= 2
      st = setfield(st, fieldsInCells{1}{:}, auxVar(:,2));
    end
  end  
  
  [Y, meanY] = struct2vector(st, nm); % Y: vector with all dependent data
  W = struct2vector(weights, nm); % W: vector with all weights
  
  % loss function as used in petreg_f
  [P, meanP] = struct2vector(prdData, nm);
  lf = feval(fileLossfunc, Y, meanY, P, meanP, W);

  % get free settings
  nm_elas = fieldnames(par); nm_elas(end) = []; n_par = length(nm_elas); 
  free = zeros(n_par,1); for i=1:n_par; free(i)=par.free.(nm_elas{i}); end
  nm_elas = nm_elas(free == 1); n_free = length(nm_elas); % names of free parameters
  
  % perturbations
  lf_f = zeros(n_free,1); lf_b = lf_f; % initiate foreward and backward perturbed loss functions
  elas_f = lf_f; elas_b = lf_b; % initiate forward and backward elasticities
  for i = 1:n_free
    % foreward
    par_fi = par; par_fi.(nm_elas{i}) =  par.(nm_elas{i}) * (1 + del); % perturb parameter
    prdData_fi = feval(['predict_', my_pet], par_fi, data, auxData);
    prdData_fi = predict_pseudodata(par, data, prdData_fi);
    [P, meanP] = struct2vector(prdData_fi, nm);
    lf_f(i) = feval(fileLossfunc, Y, meanY, P, meanP, W);
    elas_f(i) = (lf_f(i)/ lf - 1)/ del;
    % backward
    par_bi = par; par_bi.(nm_elas{i}) =  par.(nm_elas{i}) * (1 - del); % perturb parameter
    prdData_bi = feval(['predict_', my_pet], par_bi, data, auxData);
    prdData_bi = predict_pseudodata(par, data, prdData_bi);
    [P, meanP] = struct2vector(prdData_bi, nm);
    lf_b(i) = feval(fileLossfunc, Y, meanY, P, meanP, W);
    elas_b(i) = (1 - lf_b(i)/ lf)/ del;
  end
  
  % ideally, the foreward and backward variants should be the same
  elas = (elas_f + elas_b)/2; % mean of foreward and backward elasticities
  
  %prt_tab({nm_elas, elas, elas_f, elas_b}, {' ';'elas';'elas_f';'elas_b'}, ['del = ', num2str(del)]); % temporary output
 