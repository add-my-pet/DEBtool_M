%% smse_st
% calculates the symmetric mean squared error

%%
function [mserr, rserr, prdInfo] = smse_st(func, par, data, auxData, weights)
  % created: 2016/05/05 by Goncalo Marques, modified 2022/01/26 by Bas Kooijman
  
  %% Syntax 
  % [mserr, rserr, prdInfo] = <../mse_st.m *smse_st*>(func, par, data, auxData, weights)
  
  %% Description
  % Calculates the symmetric mean squared  error, used in add_my_pet:
  %    2 \sum_ij w_ij/ w_i+ (d_ij - p_ij)^2/ (d_i^2 + p_i^2) 
  %
  % Input
  %
  % * func: character string with name of user-defined predict_my_pet function
  % * par: structure with parameters
  % * data: structure with data
  % * auxData: structure with data
  % * weights: structure with weights for the data
  % * prdInfo: boolean with success (1) or failure (0) for call to predict-function
  %  
  % Output
  %
  % * mserr: scalar with mean squared relative error
  % * rserr: (n-2) matrix  with weighted relative squared error of each of data set
  % in first column and 1 or 0 in the second column indicated whether or
  % not the data set was given weight zero
  %
  %% Remarks
  % Bi-variate data can have NaN's (= missing data).
  % Uni- and bi-variate data have the (first) independent variable in the first column
  % First output mserr excludes contributions from pseudo-data.

  [nm, nst] = fieldnmnst_st(data); % nst: number of data sets   
  [prdData, prdInfo] = feval(func, par, data, auxData); % call predicted values for all of the data
  if prdInfo == 0 % no prediction from func
    mserr = {}; rserr = {};
    return
  end
  prdData = predict_pseudodata(par, data, prdData);
  
  rserr      = zeros(nst, 2);  % prepare output
  wsum = zeros(nst,1);   % sum of all weights per data-set
  
  for i = 1:nst   % scan data sets
    fieldsInCells = textscan(nm{i},'%s','Delimiter','.');
    var = getfield(data, fieldsInCells{1}{:});   % scalar, vector or matrix with data in field nm{i}
    [n, k] = size(var);
    if k > 1 % uni- or bivariate dsta set
      var(:,1) = []; % remove independent variable
    end
    sel = ~isnan(var); % selection of non-Nan's
    prdVar = getfield(prdData, fieldsInCells{1}{:}); 
    w      = getfield(weights, fieldsInCells{1}{:});
    diff2 = (prdVar - var).^2;
    if k > 1
      meanVar = zeros(n, k-1); meanPrd = zeros(n, k-1);
      for j = 1:k-1
        meanVar(:,j) = ones(n,1) * mean(var(sel(:,j),j)); 
        meanPrd(:,j) = ones(n,1) * mean(prdVar(sel(:,j),j));
      end
    else % zero-variate data set
      meanVar = var; meanPrd = prdVar;
    end
    meanVarPrd2 = (meanVar.^2 + meanPrd.^2)/2;
    wsum(i) = sum(w(sel)); 
   
    if all(meanVar > 0)
      if wsum(i) ~= 0
        rserr(i,1) = w(sel)' * (diff2(sel) ./ meanVarPrd2(sel)) / wsum(i);
      else
        rserr(i,1) = sum(diff2(sel) ./ meanVarPrd2(sel));
      end
    else
      rserr(i,1) = 0;
    end
    
    rserr(i,2) = (wsum(i)~=0); % weight 0 if all of the data points in a data set were given weight zero, meaning that that data set was effectively excluded from the estimation procedure

    if wsum(i) == 0
      rserr(i,1) = sum(diff2(sel) ./ max(1e-10, meanVarPrd2(sel)), 1);
    else
      rserr(i,1) = w(sel)' * (diff2(sel) ./ max(1e-10, meanVarPrd2(sel)))/ wsum(i);
    end
    rserr(i,2) = (wsum(i)~=0); % weight 0 if all of the data points in a data set were given wieght zero, meaning that that data set was effectively excluded from the estimation procedure

  end
      
  % assume that psd, if present, is the last field name in data
  if isfield(data,'psd') % take contributions from pseudo-data out from overall error.
    n_psd = length(fields(data.psd)); wsum(end-n_psd+1:end) = 0; rserr(end-n_psd+1:end,2) = 0;
  end
  mserr = wsum' * rserr(:,1)/ sum(wsum);
  
  