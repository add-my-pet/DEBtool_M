%% mre_st
% calculates the mean absolute relative error

%%
function [merr, rerr] = mre_st(func, par, data, auxData, weights)
  % created: 2001/09/07 by Bas Kooijman; 
  % modified: 2013/05/02, 2015/03/30, 2015/04/27 by Goncalo Marques, 2015/07/29 by Starrlight Augustine
  
  %% Syntax 
  % [merr, rerr] = <../mre_st.m *mre_st*>(func, par, data, auxData, weights)
  
  %% Description
  % Calculates the mean absolute relative error, used in add_my_pet
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
  % * rerr: vector with relative error of each of data set

  % this is because pseudo data are appended to the data structure in
  % add-my-pet routines and we are not interested in computing the relative error of pseudo-data :
% if isfield(data, 'psd')
% data = rmfield_wtxt(data, 'psd');
% end

[nm, nst] = fieldnmnst_st(data); % nst: number of data sets
% multiSpecies = isempty(strfind(nm,'pet')); % 
% 
% switch multiSpecies
% 
%     case ~multiSpecies
%     
%     
%     otherwise        
%         
% end

  for i = 1:nst   % removes independant variables from uni-variate data sets
      fieldsInCells = textscan(nm{i},'%s','Delimiter','.');
      auxVar = getfield(data, fieldsInCells{1}{:});   % data in field nm{i}
      k = size(auxVar, 2);
    if k >= 2
%        data.(nm{i}) = data.(nm{i})(:,2);
var = data.(fieldsInCells{1}{1}).(fieldsInCells{1}{2});
var = var(:,2);
data.(fieldsInCells{1}{1}).(fieldsInCells{1}{2}) = var;
% data.(fieldsInCells{1}{1}).(fieldsInCells{1}{2}) = data.(fieldsInCells{1}{1}).(fieldsInCells{1}{2})(:,2);
    end
  end

% call predicted values for all of the data
prdData = feval(func, par, data, auxData);

  rerr = zeros(nst, 2);
  for i = 1:nst
      fieldsInCells = textscan(nm{i},'%s','Delimiter','.');
      var    = data.(fieldsInCells{1}{1}).(fieldsInCells{1}{2});
      prdVar = prdData.(fieldsInCells{1}{1}).(fieldsInCells{1}{2});
      w      = weights.(fieldsInCells{1}{1}).(fieldsInCells{1}{2});
      rerr(i,1) = sum(abs(prdVar - var) .* w ./ max(1e-3, abs(var)), 1)/ sum(max(1e-6, w));
      rerr(i,2) = (sum(w)~=0); % weight 0 if all of the data points in a data set were given wieght zero, meaning that that data set was effectively excluded from the estimation procedure
%       rerr(i,1) = sum(abs(prdData.(nm{i}) - data.(nm{i})) .* weights.(nm{i}) ./ max(1e-3, abs(data.(nm{i}))), 1)/ sum(max(1e-6, weights.(nm{i})));
%       rerr(i,2) = (sum(weights.(nm{i}))~=0); % weight 0 if all of the data points in a data set were given wieght zero, meaning that that data set was effectively excluded from the estimation procedure
  end
    
  merr = sum(prod(rerr,2))/ sum(rerr(:,2));