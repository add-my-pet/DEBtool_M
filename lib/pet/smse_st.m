%% smse_st
% calculates the symmetric mean squared relative error

%%
function [smserr, sserr, prdInfo] = smse_st(func, par, data, auxData, weights)
  % created: 2016/09/03 by Goncalo Marques
  
  %% Syntax 
  % [smserr, sserr] = <../smse_st.m *smse_st*>(func, par, data, auxData, weights)
  
  %% Description
  % Calculates the mean symmetric squared relative error, used in add_my_pet
  %    (d_ij - p_ij)^2/ (d_i^2 + p_i^2)
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
  % * smserr: scalar with symmetric mean squared relative error
  % * sserr: (n-2) matrix with weighted symmetric relative squared error of 
  % each of data set in first column and 1 or 0 in the second column indicated 
  % whether or not the data set was given weight zero

  [nm, nst] = fieldnmnst_st(data); % nst: number of data sets   
  [prdData, prdInfo] = feval(func, par, data, auxData); % call predicted values for all of the data
  if prdInfo == 0 % no prediction from func
    smserr = {}; sserr = {};
    return
  end
  prdData = predict_pseudodata(par, data, prdData); % add filed psd to prdData

  
  rserr      = zeros(nst, 2);  % prepare output
  
  for i = 1:nst   % first we remove independent variables from uni-variate data sets
    fieldsInCells = textscan(nm{i},'%s','Delimiter','.');
    var = getfield(data, fieldsInCells{1}{:});   % scaler, vector or matrix with data in field nm{i}
    k = size(var, 2);
    if k >= 2
      data = setfield(data, fieldsInCells{1}{:}, var(:,2));
    end
  end
  
  for i = 1:nst % next we compute the weighted relative error of each data set
    fieldsInCells = textscan(nm{i},'%s','Delimiter','.');
    var    = getfield(data, fieldsInCells{1}{:}); 
    prdVar = getfield(prdData, fieldsInCells{1}{:}); 
    w      = getfield(weights, fieldsInCells{1}{:});
    meanVar = abs(mean(var));
    meanPrdVar = abs(mean(prdVar));
    diff = abs(prdVar - var);
    
    if sum(diff) > 0 && meanVar > 0
      if sum(w) ~= 0
        sserr(i,1) = sum(w .* abs(prdVar - var).^2/ (meanVar^2 + meanPrdVar^2), 1)/ sum(w);
      else
        sserr(i,1) = sum(abs(prdVar - var).^2/ (meanVar^2 + meanPrdVar^2), 1);
      end
    else
      sserr(i,1) = 0;
    end
    sserr(i,2) = (sum(w)~=0); % weight 0 if all of the data points in a data set were given wieght zero, meaning that that data set was effectively excluded from the estimation procedure
  end
    
  smserr = sqrt(sum(prod(sserr,2))/ sum(sserr(:,2)));
  
  
  
  