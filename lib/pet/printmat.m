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

  global pets  
  
      
  [data, auxData, metaData, txtData, weights] = feval(['mydata_', my_pet]); % get data
  filenm = ['results_', my_pet,'.mat'];                         
  load(filenm, 'par', 'metaPar', 'txtPar');           % load results
 
 
  filenm = ['results_', my_pet, '.m'];                         % customized presentation for univariate data
  if exist(filenm, 'file')
    eval(['results_', my_pet, '(par, metaPar, txtPar, data, auxData, metaData, txtData, weights);']); % get predictions
  else
    pets = {my_pet};
    aux = data; clear data; data.pet1 = aux;
    aux = metaData; clear metaData; metaData.pet1 = aux;
    aux = txtData; clear txtData; txtData.pet1 = aux;
    results_pets(par, metaPar, txtPar, data, auxData, metaData, txtData, weights); 
  end  
  
  % remove this line when .mat has txt_chem (and edit line 34)
  %[CHEM, txt_chem] = addchem(metaData.pet1.phylum, metaData.pet1.class, metaPar.T_ref);
  
  printchem(chem, txt_chem);