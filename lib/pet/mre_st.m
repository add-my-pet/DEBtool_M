%% mre_st
% calculates the mean absolute relative error

%%
function [merr, rerr] = mre_st(func, par, data, auxData, weights)
  % created: 2001/09/07 by Bas Kooijman; 
  % modified: 2013/05/02 by Goncalo Marques, 2015/03/30 by Goncalo Marques, 2015/04/27 by Goncalo Marques
  % modified 2015/07/29
  
  %% Syntax 
  % [merr, rerr] = <../mre_st.m *mre_st*>(func, par, data)
  
  %% Description
  % Calculates the mean absolute relative error, used in add_my_pet
  %
  % Input
  %
  % * func: character string with name of user-defined function
  %    see nrregr_st or nrregr
  % * par: structure with parameters
  % * data: structure with data
  % * auxData: structure with data
  % * weights: structure with weights for the data
  %  
  % Output
  %
  % * merr: scalar with mean absolute relative error
  % * rerr: vector with relative error of each of data set

if isfield(data, 'psd')
data = rmfield_wtxt(data, 'psd');
end

[nm, nst] = fieldnmnst_st(data); % nst: number of data sets
  for i = 1:nst   % makes st only with dependent variables
    eval(['[~, k] = size(data.', nm{i}, ');']); 
    if k >= 2
      eval(['data.', nm{i}, ' = data.', nm{i},'(:,2);']);
    end
  end

  % get function values
  f = feval(func, par, data, auxData);

  rerr = [];
  for i = 1:nst
    % rerr = [rerr; sum(abs(fi - yi) .* wi ./ max(1e-3, yi), 1)/ sum(wi) 1];
    eval(['rerr = [rerr; sum(abs(f.', nm{i}, ' - data.', nm{i}, ') .* weights.', nm{i}, ...
          ' ./ max(1e-3, abs(data.', nm{i}, ')), 1)/ sum(max(1e-6, weights.', nm{i}, ')) 1];']);
    eval(['rerr(end,2) = sum(weights.', nm{i}, ') ~= 0;']) % weight 0 if all 0 == yi(:,3)
  end
    
  merr = sum(prod(rerr,2))/ sum(rerr(:,2));