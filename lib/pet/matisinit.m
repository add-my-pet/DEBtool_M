%% matisinit
% checks if parameter values of results_my_pet.mat matches those of pars_init_my_pet

%%
function [info_par, info_metapar, info_txt_par, info_chem] = matisinit(my_pet)
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
      
  eval(['[data, txt_data, metadata] = mydata_', my_pet, ';']); % get data
  load(filenm,'txt_par', 'par', 'metapar', 'chem');            % load results from .mat
  % get outputs from pars_init
  eval(['[par_init, metapar_init, txt_par_init, chem_init] = pars_init_', my_pet, '(metadata);'])
  
  par = rmfield_wtxt(par, 'free');                       
  par_init = rmfield_wtxt(par_init, 'free');   
  info_par = isempty(comp_struct(par, par_init, 0)); 
 
  metapar = rmfield_wtxt(metapar, 'MRE');
  metapar = rmfield_wtxt(metapar, 'RE');
  info_metapar = isempty(comp_struct(metapar, metapar_init, 0)); 

  info_txt_par = isempty(comp_struct(txt_par, txt_par_init, 0)); 

  info_chem = isempty(comp_struct(chem, chem_init, 0)); 
