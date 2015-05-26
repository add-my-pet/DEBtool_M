%% printprd_st
% prints data of a species to screen

%%
function printprd_st(txt_data, data, prd_data, RE)
% created 2015/04/01 by Goncalo Marques & Bas Kooijman

  %% Syntax
  % <../printprd_st.m *printprd_st*> (txt_data, data, MRE, prd)

  %% Description
  % Prints the data of a species to screen
  %
  % Input 
  %
  % * txt_data: text for data
  % * data: data structure
  % * prd: structure with predictions
  % * RE: relative error
  
  %% Remarks
  % Data values are printed first, followed by prediction and relative error
  % The relative error of pseudo date are set to zero, irrespective of the diffference between value and prediction

  datapl = rmfield_wtxt(data, 'weight');
  datapl = rmfield_wtxt(datapl, 'temp');
  dtsets = fieldnames(data.weight);
  [nm nst] = fieldnmnst_st(datapl);
    
  fprintf('data and predictions (relative error) \n');
  for j = 1:nst
    eval(['[aux, k] = size(data.', nm{j}, ');']); % number of data points per set
    if k == 1
      eval(['str = [nm{j}, '', '', txt_data', '.units.', nm{j},', '', '', txt_data.label.', nm{j},'];']);
      str = ['%3.4g %3.4g (%3.4g) ', str, '\n'];
      eval(['fprintf(str, datapl.', nm{j},', prd_data.', nm{j},', RE(j));']);
    else
      eval(['str = [dtsets{j}, '', '', txt_data.label.', nm{j},'{1}, '' vs. '', txt_data.label.', nm{j},'{2}];']);
      str = ['see figure (%3.4g) ', str, '\n'];
      eval(['fprintf(str, RE(j));']);
    end
  end
