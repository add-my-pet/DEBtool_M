%% printprd_st
% prints data of a species to screen

%%
function printprd_st(data, txtData, prdData, RE)
% created 2015/04/01 by Goncalo Marques & Bas Kooijman
% modified 2015/07/29

  %% Syntax
  % <../printprd_st.m *printprd_st*> (data, txtData, prdData, RE)

  %% Description
  % Prints the data of a species to screen
  %
  % Input 
  %
  % * txtData: text for data
  % * data: data structure
  % * prd: structure with predictions
  % * RE: relative error
  
  %% Remarks
  % Data values are printed first, followed by prediction and relative error
  % The relative error of pseudo date are set to zero, irrespective of the diffference between value and prediction

%   data = rmfield_wtxt(data, 'weight');
%   data = rmfield_wtxt(data, 'temp');
%   dtsets = fieldnames(data.weight);
%   [nm nst] = fieldnmnst_st(data);
    
  [nm nst] = fieldnmnst_st(data);
    dtsets = fieldnames(data);

  fprintf('data and predictions (relative error) \n');
  for j = 1:nst

    eval(['[aux, k] = size(data.', nm{j}, ');']); % number of data points per set
    if k == 1
      
      eval(['str = [nm{j}, '', '', txtData', '.units.', nm{j},', '', '', txtData.label.', nm{j},'];']);
      str = ['%3.4g %3.4g (%3.4g) ', str, '\n'];
      eval(['fprintf(str, data.', nm{j},', prdData.', nm{j},', RE(j));']);
    else
      eval(['str = [dtsets{j}, '', '', txtData.label.', nm{j},'{1}, '' vs. '', txtData.label.', nm{j},'{2}];']);
      str = ['see figure (%3.4g) ', str, '\n'];
      eval(['fprintf(str, RE(j));']);
    end
  end
