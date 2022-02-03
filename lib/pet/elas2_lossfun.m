%% elas2_lossfun
% gets first and second order elasticity coefficients of loss function

%%
function [elas2, elas, nm_elas, lf] = elas2_lossfun(my_pet, del)
% created by Bas Kooijman 2022/01/09, modified by Dina Lika 2022/01/15

%% Syntax
% [elas2, elas, nm_elas, lf] = <../elas2_lossfun.m *elas2_lossfun*> (my_pet, del)

%% Description
% Gets the first and second order elasticity coefficients of loss function for free parameters.
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
% * nm_elas: cell-string with names of free parameters
% * lf: value of the loss function
%
%% Remarks
% the output does not include contributions from augmented terms.<br>
% Uses global "lossfunction" with strings re, sb or su, see DEBtool_M/lib/regr, default lossfunction = 'sb'
% Takes the mean of foreward and backward perturbations of parameters.
% See <elas_lossfun.html *elas_lossfun*> for first order elasticities only.
% See <prt_elas.html *prt_elas*> for printing elasticities to html
  
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
      st = setfield(st, fieldsInCells{1}{:}, auxVar(:,2:end));
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
  lf_f2 = zeros(n_free, n_free); lf_b2 = lf_f; % initiate foreward and backward 2nd perturbed loss functions
  elas_f = lf_f; elas_b = lf_b; % initiate forward and backward elasticities
  elas2_f = lf_f; elas2_b = lf_b; % initiate forward and backward 2nd order elasticities
  for i = 1:n_free
    % foreward
    par_fi = par; par_fi.(nm_elas{i}) = par.(nm_elas{i}) * (1 + del); % perturb parameter
    prdData_fi = feval(['predict_', my_pet], par_fi, data, auxData);
    prdData_fi = predict_pseudodata(par_fi, data, prdData_fi);
    [P, meanP] = struct2vector(prdData_fi, nm);
    lf_f(i) = feval(fileLossfunc, Y, meanY, P, meanP, W);
    elas_f(i) = (lf_f(i)/ lf - 1)/ del;
    % backward
    par_bi = par; par_bi.(nm_elas{i}) = par.(nm_elas{i}) * (1 - del); % perturb parameter
    prdData_bi = feval(['predict_', my_pet], par_bi, data, auxData);
    prdData_bi = predict_pseudodata(par_bi, data, prdData_bi);
    [P, meanP] = struct2vector(prdData_bi, nm);
    lf_b(i) = feval(fileLossfunc, Y, meanY, P, meanP, W);
    elas_b(i) = (1 - lf_b(i)/ lf)/ del;
    for j = i:n_free % only upper-triangle
      % foreward
      par_fj = par; par_fj.(nm_elas{j}) = par.(nm_elas{j}) * (1 + del); % perturb parameter
      prdData_fj = feval(['predict_', my_pet], par_fj, data, auxData);
      prdData_fj = predict_pseudodata(par_fj, data, prdData_fj);
      [P, meanP] = struct2vector(prdData_fj, nm);
      if strcmp(lossfunction, 'SMAE')
        lf_f(j) = feval(fileLossfunc, Y, P, W);
      else
        lf_f(j) = feval(fileLossfunc, Y, meanY, P, meanP, W);
      end
    
      %
      par_fi2 = par_fi; par_fi2.(nm_elas{j}) = par_fi2.(nm_elas{j}) * (1 + del); % perturb parameter
      prdData_fi2 = feval(['predict_', my_pet], par_fi2, data, auxData);
      prdData_fi2 = predict_pseudodata(par_fi2, data, prdData_fi2);
      [P, meanP] = struct2vector(prdData_fi2, nm);
      if strcmp(lossfunction, 'SMAE')
        lf_f2(i,j) = feval(fileLossfunc, Y, P, W);
      else
        lf_f2(i,j) = feval(fileLossfunc, Y, meanY, P, meanP, W);
      end
      elas2_f(i,j) = (lf_f2(i,j)/ lf -  lf_f(i)/ lf - lf_f(j)/ lf + 1)/ del^2;
      % backward
      par_bj = par; par_bj.(nm_elas{j}) =  par.(nm_elas{j}) * (1 - del); % perturb parameter
      prdData_bj = feval(['predict_', my_pet], par_bj, data, auxData);
      prdData_bj = predict_pseudodata(par_bj, data, prdData_bj);
      [P, meanP] = struct2vector(prdData_bj, nm);
      if strcmp(lossfunction, 'SMAE')
        lf_b(j) = feval(fileLossfunc, Y, P, W);
      else
        lf_b(j) = feval(fileLossfunc, Y, meanY, P, meanP, W);
      end
      %
      par_bi2 = par_bi; par_bi2.(nm_elas{j}) =  par_bi2.(nm_elas{j}) * (1 - del); % perturb parameter
      prdData_bi2 = feval(['predict_', my_pet], par_bi2, data, auxData);
      prdData_bi2 = predict_pseudodata(par_bi2, data, prdData_bi2);
      [P, meanP] = struct2vector(prdData_bi2, nm);
      if strcmp(lossfunction, 'SMAE')
        lf_b2(i,j) = feval(fileLossfunc, Y, P, W);
      else
        lf_b2(i,j) = feval(fileLossfunc, Y, meanY, P, meanP, W);
      end
      elas2_b(i,j) = (lf_b2(i,j)/ lf - lf_b(i)/ lf - lf_b(j)/ lf + 1)/ del^2;
    end
  end
  
  % ideally, the foreward and backward variants should be the same
  elas  = (elas_f + elas_b)/2;   % mean of foreward and backward elasticities
  elas2_f = elas2_f + elas2_f' .* (1-eye(n_free)); % convert upper triangle to symmetric
  elas2_b = elas2_b + elas2_b' .* (1-eye(n_free)); % convert upper triangle to symmetric
  elas2 = (elas2_f + elas2_b)/2; % mean of foreward and backward 2nd order elasticities
end

function [vec, meanVec] = struct2vector(struct, fieldNames)
  vec = []; meanVec = [];
  for i = 1:size(fieldNames, 1)
    fieldsInCells = textscan(fieldNames{i},'%s','Delimiter','.');
    aux = getfield(struct, fieldsInCells{1}{:}); [n,k] = size(aux);
    sel = ~isnan(aux);
    vec = [vec; aux(:)];
    maux = zeros(1,k);
    for j=1:k
        maux(j) = mean(aux(sel(:,j),j));
    end
    meanAux = ones(n,1) * maux;
    meanVec = [meanVec; meanAux(:)];
  end
end