%% mre_st
% calculates the mean absolute relative error

%%
function [merr, rerr, prdInfo] = mre_st(func, par, data, auxData, weights)
  % created: 2001/09/07 by Bas Kooijman; 
  % modified: 2013/05/02, 2015/03/30, 2015/04/27 by Goncalo Marques,
  % 2015/07/30 by Starrlight Augustine, 2022/01/26 by Bas Kooijman
  
  %% Syntax 
  % [merr, rerr, prdInfo] = <../mre_st.m *mre_st*>(func, par, data, auxData, weights)
  
  %% Description
  % Calculates the mean absolute relative error for each data set, used in add_my_pet.
  % Contributions of errors for pseudo data are excluded from the overall mean relative error.
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
  % * rerr: (n-2) matrix  with weighted relative error of each of data set
  %     in first column and 1 or 0 in the second column indicated whether or
  %     not the data set was given weight zero
  % * prdInfo: boolean with success (1) or failure (0) for call to predict-function
  %
  %% Remarks
  % Bi-variate data can have NaN's (= missing data).
  % Uni- and bi-variate data have the (first) independent variable in the first column
  % First output merr excludes contributions from pseudo-data.

  [nm, nst] = fieldnmnst_st(data); % nst: number of data sets   
  [prdData, prdInfo] = feval(func, par, data, auxData); % call predicted values for all of the data
  if prdInfo == 0 % no prediction from func
      merr = {}; rerr = {};
      return
  end
  prdData = predict_pseudodata(par, data, prdData); % add filed psd to prdData
  rerr      = zeros(nst, 2);  % prepare output
  wsum = zeros(nst,1);   % sum of all weights per data-set

  for i = 1:nst   % scan data sets
    fieldsInCells = textscan(nm{i},'%s','Delimiter','.');
    var = getfield(data, fieldsInCells{1}{:});   % scalar, vector or matrix with data in field nm{i}
    [r, k, npage] = size(var);
    if npage==1 && k>1 % uni- or bivariate data set
      var(:,1) = []; % remove independent variable
    end
    prdVar = getfield(prdData, fieldsInCells{1}{:});
    w      = getfield(weights, fieldsInCells{1}{:});
    sel = ~isnan(var); diff = zeros(r,max(1,k-1)); meanval = diff; 
    if npage==1 && k > 1
      for j = 1:k-1
        meanval(:,j) = ones(r,1) * abs(mean(var(sel(:,j),j)));
        diff(sel(:,j),j) = abs(prdVar(sel(:,j),j) - var(sel(:,j),j));
      end
    elseif npage>1
      meanval = mean(var,3); meanval = meanval(:,:,ones(npage,1));
      diff = abs(prdVar - var);
    else
      meanval = abs(var); diff = abs(prdVar - var);
    end
    wsum(i) = sum(w(sel));

    
    if all(meanval > 0)
      
      if wsum(i) ~= 0 && npage==1
        rerr(i,1) = w(sel)' * (diff(sel) ./ meanval(sel))/ wsum(i);
      elseif npage>1
        er= w .* diff ./ meanval; rerr(i,1) = sum(er(sel))/ wsum(i);
      else
        rerr(i,1) = sum(sum(diff ./ meanval, 1));
      end
    else
      rerr(i,1) = 0;
    end
    rerr(i,2) = (wsum(i)~=0); % weight 0 if all of the data points in a data set were given weight zero, meaning that that data set was effectively excluded from the estimation procedure

  end
      
  % assume that psd, if present, is the last field name in data
  if isfield(data,'psd') % take contributions from pseudo-data out from overall error.
    n_psd = length(fields(data.psd)); wsum(end-n_psd+1:end) = 0; rerr(end-n_psd+1:end,2) = 0;
  end
  merr = wsum' * rerr(:,1)/ sum(wsum);
 
