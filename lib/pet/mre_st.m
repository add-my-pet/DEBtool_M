%% mre_st
% calculates the mean absolute relative error

%%
function [merr, rerr, prdInfo] = mre_st(func, par, data, auxData, weights)
  % created: 2001/09/07 by Bas Kooijman; 
  % modified: 2013/05/02, 2015/03/30, 2015/04/27 by Goncalo Marques, 2015/07/30 by Starrlight Augustine
  
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

  [nm, nst] = fieldnmnst_st(data); % nst: number of data sets   
  [prdData, prdInfo] = feval(func, par, data, auxData); % call predicted values for all of the data
  if prdInfo == 0 % no prediction from func
      merr = {}; rerr = {};
      return
  end
  prdData = predict_pseudodata(par, data, prdData); % add filed psd to prdData
  
  rerr      = zeros(nst, 2);  % prepare output
  
  for i = 1:nst   % first we remove independent variables from uni- or bi-variate data sets
    fieldsInCells = textscan(nm{i},'%s','Delimiter','.');
    var = getfield(data, fieldsInCells{1}{:});   % scalar, vector or matrix with data in field nm{i}
    k = size(var, 2);
    if k >= 2
      data = setfield(data, fieldsInCells{1}{:}, var(:,2:end));
    end
  end
  
  for i = 1:nst % next we compute the weighted relative error of each data set
    fieldsInCells = textscan(nm{i},'%s','Delimiter','.');
    var    = getfield(data, fieldsInCells{1}{:}); n = size(var,1);
    prdVar = getfield(prdData, fieldsInCells{1}{:}); 
    w      = getfield(weights, fieldsInCells{1}{:});
    meanval = ones(n,1) * abs(mean(var));
    diff = abs(prdVar - var);
    
    if sum(diff) > 0 & all(meanval > 0)
      
      if sum(w(:)) ~= 0
        rerr(i,1) = sum(sum(w .* diff ./ meanval, 1))/ sum(w(:));
      else
        rerr(i,1) = sum(sum(diff ./ meanval, 1));
      end
    else
      rerr(i,1) = 0;
    end
    rerr(i,2) = (sum(w(:))~=0); % weight 0 if all of the data points in a data set were given weight zero, meaning that that data set was effectively excluded from the estimation procedure
  end
    
  merr = sum(prod(rerr,2))/ sum(rerr(:,2));
