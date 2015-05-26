%% mre_st
% calculates the mean absolute relative error

%%
function [merr, rerr] = mre_st(func, par, chem, T_ref, data)
  % created: 2001/09/07 by Bas Kooijman; 
  % modified: 2013/05/02 by Goncalo Marques, 2015/03/30 by Goncalo Marques, 2015/04/27 by Goncalo Marques
  
  %% Syntax 
  % [merr, rerr] = <../mre_st.m *mre_st*>(func, par, chem, data)
  
  %% Description
  % Calculates the mean absolute relative error, used in add_my_pet
  %
  % Input
  %
  % * func: character string with name of user-defined function
  %    see nrregr_st or nrregr
  % * par: structure with parameters
  % * chem: structure with biochemical parameters
  % * T_ref: scalar with refeerence temperature
  % * p: (np,nc) matrix with p(:,1) parameter values
  % * data: structure with 
  %  
  % Output
  %
  % * merr: scalar with mean absolute relative error
  % * rerr: vector with relative error of each of data set

  nmweight = fieldnm_wtxt(data, 'weight');
  nmwst = strrep(nmweight, '.weight', '');
  nmwst = strcat('wst.', nmwst);
  for i = 1:length(nmweight)
    eval([nmwst{i}, ' = data.', nmweight{i}, ';']);
  end
  data4pred = rmfield_wtxt(data, 'weight');
  yst = rmfield_wtxt(data4pred, 'temp');
  [nm, nst] = fieldnmnst_st(yst); % nst: number of data sets

  for i = 1:nst   % makes st only with dependent variables
    eval(['[~, k] = size(yst.', nm{i}, ');']); 
    if k >= 2
      eval(['yst.', nm{i}, ' = yst.', nm{i},'(:,2);']);
    end
  end

  % get function values
  eval(['f = ', func, '(par, chem, T_ref, data4pred);']);

  rerr = [];
  for i = 1:nst
    % rerr = [rerr; sum(abs(fi - yi) .* wi ./ max(1e-3, yi), 1)/ sum(wi) 1];
    eval(['rerr = [rerr; sum(abs(f.', nm{i}, ' - yst.', nm{i}, ') .* wst.', nm{i}, ...
          ' ./ max(1e-3, abs(yst.', nm{i}, ')), 1)/ sum(max(1e-6, wst.', nm{i}, ')) 1];']);
    eval(['rerr(end,2) = sum(wst.', nm{i}, ') ~= 0;']) % weight 0 if all 0 == yi(:,3)
  end
    
  merr = sum(prod(rerr,2))/ sum(rerr(:,2));