%% printmat
% prints parameters and prediction of results_my_pet.mat 

%%
function printmat(my_pet)
  % created by Starrlight Augustine, Dina Lika, Bas Kooijman, Goncalo Marques and Laure Pecquerie 2015/04/12

  %% Syntax
  % <../printmat.m *printmat*>(my_pet)
  
  %% Description
  % Loads results_my_pet.mat to present results
  %
  % Input
  %
  % * string with name of species
  
  %% Remarks
  % printmat calls resesults_my_pet to present univariate data.
  
  %% Example of use
  % printmat('my_pet')

  filenm = ['results_', my_pet, '.mat'];
  if ~exist(filenm, 'file')
    fprintf(['Warning from printmat: cannot find ', filenm, '\n']);
    return
  end
      
  eval(['[data, txt_data, metadata] = mydata_', my_pet, ';']); % get data
  load(filenm,'txt_par', 'par', 'metapar', 'chem');            % load results
  datapl = rmfield_wtxt(data, 'weight');                       % reduce data
  eval(['prd_data = predict_', my_pet, '(par, chem, metapar.T_ref, datapl);']); % get predictions
  
  prd_data = predict_pseudodata(prd_data, par, chem, data);    % get predictions
  printpar_st(txt_par, par, chem);                             % print parameters
  fprintf('\n');
  datapl = rmfield_wtxt(data, 'temp');                         % reduce data
  printprd_st(txt_data, datapl, prd_data, metapar.RE);         % print predictions
  fprintf(['\nmean relative error ', num2str(metapar.MRE), '\n']);
 
  filenm = ['results_', my_pet, '.m'];                         % customized presentation for univariate data
  if exist(filenm, 'file')
    eval(['results_', my_pet, '(txt_par, par, chem, metapar, txt_data, data);']); % get predictions
  end  