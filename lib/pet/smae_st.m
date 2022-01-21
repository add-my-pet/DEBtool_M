%% SMAE
% calculates the Symmetric Mean Absolute Error

%%
function [merr, err, prdInfo] = smae_st(func, par, data, auxData, weights)
  % created: 2022/01/19 by Bas Kooijman; 
  
  %% Syntax 
  % [[merr, err, prdInfo] = <../smae_st.m *smae_st*>(func, par, data, auxData, weights)
  
  %% Description
  % Calculates the Symmetric Mean Absolute Error, used in add_my_pet
  %
  % Input
  %
  % * func: character string with name of user-defined predict_my_pet function
  % * par: structure with parameters
  % * data: structure with data
  % * auxData: structure with data
  % * weights: structure with weights for the data
  %  
  % Output
  %
  % * merr: scalar with mean absolute relative error
  % * err: (n,2) matrix  with weighted relative error of each of data set
  %     in first column and 1 or 0 in the second column indicated whether or
  %     not the data set was given weight zero
  % * prdInfo: boolean with success (1) or failure (0) for call to predict-function

  [nm, nst] = fieldnmnst_st(data); % nst: number of data sets   
  [prdData, prdInfo] = feval(func, par, data, auxData); % call predicted values for all of the data
  if prdInfo == 0 % no prediction from func
    merr = {}; err = {};
    return
  end
  prdData = predict_pseudodata(par, data, prdData); % add filed psd to prdData
  
  err = zeros(nst, 2);  % prepare output
  wsum = zeros(nst,1);   % sum of all weights per data-set
  
  for i = 1:nst   % first we remove independent variables from uni- or bi-variate data sets
    fieldsInCells = textscan(nm{i},'%s','Delimiter','.');
    var = getfield(data, fieldsInCells{1}{:});
    if size(var, 2) > 1 % remove dependent variable
      var(:,1) = [];
    end
    prdVar = getfield(prdData, fieldsInCells{1}{:}); 
    diff = abs(prdVar - var); meanval  = (abs(prdVar) + abs(var))/ 2;
    w      = getfield(weights, fieldsInCells{1}{:});    
    wsum(i) = sum(w(:)); 
    
    err(i,1) = sum(sum(w .* (diff ./ max(1e-10, meanval)), 1))/ wsum(i);
    err(i,2) = (sum(w(:))~=0); % weight 0 if all of the data points in a data set were given wieght zero, meaning that that data set was effectively excluded from the estimation procedure
  end
  
  % assume that psd, if present, is the last field name in data
  if isfield(data,'psd') % take contributions from pseudo-data out from overall error.
    n_psd = length(fields(data.psd)); wsum(end-n_psd+1:end) = 0; err(end-n_psd+1:end,2) = 0;
  end
  merr = wsum' * err/ sum(wsum);
  