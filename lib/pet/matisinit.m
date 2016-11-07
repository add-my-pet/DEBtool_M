%% matisinit
% checks if parameter values of results_my_pet.mat matches those of pars_init_my_pet

%%
function [infoPar, infoMetaPar, infoTxtPar] = matisinit(my_pet)
  % created by Starrlight Augustine, Dina Lika, Bas Kooijman, Goncalo, Marques and Laure Pecquerie 2015/07/19

  %% Syntax
  % <../matisinit.m *matisinit*>(my_pet)
  
  %% Description
  % Loads results_my_pet.mat and calls pars_init_my_pet to check if all outputs of the latter matches the contents of the .mat file. 
  % If so, the results are not obtained by estimation with estim.
  %
  % Input
  %
  % * string with name of species
  %
  % Output
  %
  % * identifyer for equality of all parameters
  % * identifyer for equality of all meta parameters
  % * identifyer for equality of all text of parameters
  % * identifyer for equality of all chemical parameters
  
  %% Remarks
  % calls mydata_my_pet to fill metapar. 
  % The checking excludes the free-setting of the parameters. 
  
  %% Example of use
  % matisinit('my_pet')

  filenm = ['results_', my_pet, '.mat'];
  if ~exist(filenm, 'file')
    fprintf(['Warning from printmat: cannot find ', filenm, '\n']);
    return
  end
      
  [data, auxData, metaData, txtData, weights] = feval(['mydata_', my_pet]); % get data
  load(filenm,'txtPar', 'par', 'metaPar');                % load results from .mat
  % get outputs from pars_init
  [parInit, metaParInit, txtParInit] = feval(['pars_init_', my_pet], metaData);
  
  par = rmfield_wtxt(par, 'free');                       
  parInit = rmfield_wtxt(parInit, 'free');   
  infoPar = isequaln(par, parInit);  % isempty(comp_struct()) -> isequal()
 
  metaPar = rmfield_wtxt(metaPar, 'MRE');
  metaPar = rmfield_wtxt(metaPar, 'RE');
  metaPar = rmfield_wtxt(metaPar, 'SMSE');
  metaPar = rmfield_wtxt(metaPar, 'SSE'); 
  infoMetaPar = isequaln(metaPar, metaParInit); 

  infoTxtPar = isequaln(txtPar, txtParInit); 
