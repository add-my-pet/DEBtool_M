%% printmat
% prints parameters and prediction of results_my_pet.mat 

%%
function printmat(my_pet)
  % created by Starrlight Augustine, Dina Lika, Bas Kooijman, Goncalo Marques and Laure Pecquerie 2015/04/12
  % modified 2015/04/20 by Goncalo Marques
  
  %% Syntax
  % <../printmat.m *printmat*>(my_pet)
  
  %% Description
  % Loads results_my_pet.mat to present results
  %
  % Input
  %
  % * string with name of species
  
  %% Remarks
  % printmat calls mydata_my_pet, predict_my_pet and results_my_pet to present univariate data.
  
  %% Example of use
  % printmat('my_pet')

  global pets results_output pseudodata_pets 
  
  filenm = ['results_', my_pet, '.mat'];
  if ~exist(filenm, 'file')
    fprintf(['Warning from printmat: cannot find ', filenm, '\n']);
    return
  end
      
  eval(['[data, txt_data, metadata] = mydata_', my_pet, ';']); % get data
  load(filenm, 'txt_par', 'par', 'metapar', 'chem');           % load results
  datapl = rmfield_wtxt(data, 'weight');                       % reduce data
 
%   eval(['prd_data = predict_', my_pet, '(par, chem, metapar.T_ref, datapl);']); % get predictions
%   prd_data = predict_pseudodata(prd_data, par, chem, data);    % get predictions
%   printpar_st(txt_par, par);                                   % print parameters
%   fprintf('\n');
%   datapl = rmfield_wtxt(data, 'temp');                         % reduce data
%   printprd_st(txt_data, datapl, prd_data, metapar.RE);         % print predictions
%   fprintf(['\nmean relative error ', num2str(metapar.MRE), '\n']);

 
  filenm = ['results_', my_pet, '.m'];                         % customized presentation for univariate data
  if exist(filenm, 'file')
    eval(['results_', my_pet, '(txt_par, par, chem, metapar, txt_data, data);']); % get predictions
  else
    pets = {my_pet};
    aux = data; clear data; data.pet1 = aux;
    aux = metadata; clear metadata; metadata.pet1 = aux;
    aux = txt_data; clear txt_data; txt_data.pet1 = aux;
    results_pets(txt_par, par, metapar, chem, txt_data, data, metadata); 
  end  
  
  % remove this line when .mat has txt_chem (and edit line 34)
  [CHEM, txt_chem] = addchem(metadata.pet1.phylum, metadata.pet1.class, metapar.T_ref);
  
  printchem(chem, txt_chem);