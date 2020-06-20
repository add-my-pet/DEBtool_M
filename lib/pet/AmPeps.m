%% AmPeps
% the Entry Prepare System of AmP

%%
function AmPeps(infoAmPgui)
% created 2020/06/09 by  Bas Kooijman

%% Syntax
% <../AmPeps.m *AmPeps*>(infoAmPgui)

%% Description
% The function is a shell around several other functions, including AmPgui, that eventually write:
%   mydata_my_pet.m, pars_init_my_pet.m, predict_my_pet.m and run_my_pet.m.
% Guidance is presented at <https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/AmPeps.html *AmPeps.html*>
%
% Input:
%
% * infoAmPgui: optional boolean for skip writing (0) or writing (1) 4 source files

global data metaData txtData auxData pets hclimateLand hecozone

if ~exist('infoAmPgui', 'var') % open webpages, show figures and start AmPgui
  web('https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/AmPeps.html','-browser');
  web('https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/AmPeco.html','-browser');
  hclimateLand = figure('Name','Land climate', 'Position',[300 450 500 300]); image(imread('climate_land.png'));
  hclimateSea  = figure('Name','Sea climate',  'Position',[900 450 500 300]); image(imread('climate_sea.jpg'));
  hecozone    = figure('Name','Land ecozone', 'Position',[300  50 500 300]); image(imread('ecozones.png'));
  hoceans      = figure('Name','Sea ecozone',  'Position',[900  50 500 300]); image(imread('oceans.jpg'));
  AmPgui
  
elseif ~infoAmPgui % skip the rest of AmPeps and proceed with opening source files in Matlab editor
  close all
  path = ['https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries/', metaData.species, '/'];

  if ismac
    system([path, 'mydata_', metaData.species, '.m',  ' -O ', 'mydata_', metaData.species, '.m']);
    system([path, 'pars_init_', metaData.species, '.m',  ' -O ', 'pars_init_', metaData.species, '.m']);
    system([path, 'predict_', metaData.species, '.m',  ' -O ', 'predict_', metaData.species, '.m']);
    system([path, 'run_', metaData.species, '.m',  ' -O ', 'run_', metaData.species, '.m']);
  else
    system(['powershell wget ', path, 'mydata_', metaData.species, '.m',  ' -O ', 'mydata_', metaData.species, '.m']);
    system(['powershell wget ', path, 'pars_init_', metaData.species, '.m',  ' -O ', 'pars_init_', metaData.species, '.m'])
    system(['powershell wget ', path, 'predict_', metaData.species, '.m',  ' -O ', 'predict_', metaData.species, '.m'])
    system(['powershell wget ', path, 'run_', metaData.species, '.m',  ' -O ', 'run_', metaData.species, '.m'])
  end
  edit(['mydata_', metaData.species, '.m'], ...
       ['pars_init_', metaData.species, '.m'], ...
       ['predict_', metaData.species, '.m'], ...
       ['run_', metaData.species, '.m'])

else % indoAmPgui=true:  proceed to writing 4 AmP source files for new species for AmP
  close all
  %path = ['https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries/', metaData.species, '/'];

  fld_data_1 = fields(data.data_1); % required to add data-specific scaled functional responses
  [data, metaData] = AmPgui2mydata(data, metaData); % modify data and metaData to mydata format
  prt_mydata(data, auxData, metaData, txtData); % write mydata_my_pet.m file
  prt_run_my_pet(metaData.species); % write run_my_pet.m file

  % get pars_init file of a related species to produce structure par, metaPar, txtPar
  Clade = clade(metaData.species); % identify clade to which species belongs
  Clade = Clade(~ismember(Clade,metaData.species)); % exclude the species itself 
  pars_initFn = ['pars_init_', Clade{1}, '.m']; % take the first clade species for initial par values
  path = ['https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries/', Clade{1}, '/'];
  if ismac
    system([path, pars_initFn,  ' -O ', pars_initFn]);
  else
    system(['powershell wget ', path, pars_initFn,  ' -O ', pars_initFn]);
  end
  eval(['[par, metaPar, txtPar] = pars_init_', Clade{1}, '(metaData);']); % use pars_init to produce structures par, metaPar, txtPar
  delete(pars_initFn); % delete the pars_init file of the related species
  auxParFld = prt_predict(par, metaPar, data, auxData, metaData); % write prefict file for model type taken from metaPar
  % auxParFld conains names of required auxiliary parameter

  % get auxiliary parameters
  parFields = fields(par); % current par fields
  EparFields = get_parfields(metaPar.model);  % core primary parameter fields for model
  parFields = setdiff(parFields, {'T_ref'});  % remove parameter T_ref from current-list
  parFields = setdiff(parFields, EparFields); % non-core parameter fields
  chemParFields = fields(addchem([], [], [], [], metaData.phylum, metaData.class)); % par fields for chemical parameters
  otherParFields = setdiff(parFields, chemParFields); % current auxiliary parameter fields
  otherParFields = setdiff(otherParFields, 'free');
  selPar = ismember(otherParFields, auxParFld);
  par = rmfield(par, otherParFields(~selPar)); % remove unnessasary parameters
  addParFields = auxParFld(~ismember(auxParFld, otherParFields(selPar))); % parameters fields that must be added
  n_add = length(addParFields);

  if n_add > 0
    % edit par & txtPar
    load auxPar
    for i = 1:n_add
      if isstr(auxPar.(addParFields{i}).value)
        par.(addParFields{i})        = eval(auxPar.(addParFields{i}).value);
      else
        par.(addParFields{i})        = auxPar.(addParFields{i}).value;
      end
      par.free.(addParFields{i})     = auxPar.(addParFields{i}).free;
      txtPar.units.(addParFields{i}) = auxPar.(addParFields{i}).units;
      txtPar.label.(addParFields{i}) = auxPar.(addParFields{i}).label;
    end
  end
  n_add = length(fld_data_1); % add scaled functional responses
  for i = 1:n_add
    nm = ['f_', fld_data_1{i}];
    par.(nm)      = 1;
    par.free.(nm) = 1;
    txtPar.units.(nm) = '-';
    txtPar.label.(nm) = ['scaled functional response for ',fld_data_1{i}, ' data'];
  end

  save(['results_', metaData.species, '.mat'], 'data', 'auxData', 'metaData', 'txtData', 'par', 'metaPar', 'txtPar');
  pets = {metaData.species}; mat2pars_init; % this uses results_my_pet.mat to overwrite pars_init_my_pet.m

  % open 4 AmP source files in Matlab Editor
  edit(['mydata_',    metaData.species, '.m'], ...
       ['pars_init_', metaData.species, '.m'], ...
       ['predict_',   metaData.species, '.m'], ...
       ['run_',       metaData.species, '.m']);
end