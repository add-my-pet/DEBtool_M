%% printmat
% prints parameters and prediction of results_my_pet.mat 

%%
function printmat(my_pet)
% created by Starrlight Augustine, Dina Lika, Bas Kooijman, Goncalo Marques and Laure Pecquerie 2015/04/12
% modified 2015/04/20, 2015/08/03 by Goncalo Marques
  
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
 
 
  filenm = ['results_', my_pet, '.m'];                % customized presentation for univariate data
  if exist(filenm, 'file')
    feval(['results_', my_pet], par, metaPar, txtPar, data, auxData, metaData, txtData, weights); % get predictions
  else
    pets = {my_pet};
    aux = data; clear data; data.pet1 = aux;
    aux = auxData; clear auxData; auxData.pet1 = aux;
    aux = metaData; clear metaData; metaData.pet1 = aux;
    aux = txtData; clear txtData; txtData.pet1 = aux;
    aux = weights; clear weights; weights.pet1 = aux;
    results_pets(par, metaPar, txtPar, data, auxData, metaData, txtData, weights); 
  end  
  