%% AmPeps
% the Entry Prepare System of AmP

%%
function AmPeps(infoAmPgui)
% created 2020/06/09 by  Bas Kooijman

%% Syntax
% <../AmPeps.m *AmPeps*>(infoAmPgui)

%% Description
% The function has no explicit input or output. It is a shell around several other functions, that eventually write:
%   mydata_my_pet.m, pars_init_my_pet.m, predict_my_pet.m and run_my_pet.m.
% Guidance is presented at <https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/AmPeps.html *AmPeps.html*>
%
% Input:
%
% * infoAmPgui: optional boolean for skip writing (0) or writing (1) 4 source files

global data metaData txtData auxData

if ~exist('infoAmPgui', 'var')
  web('https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/AmPeps.html','-browser');
  web('https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/AmPeco.html','-browser');
  hclimateLand = figure('Name','Land climate', 'Position',[300 450 500 300]); image(imread('climate_land.png'));
  hclimateSea  = figure('Name','Sea climate',  'Position',[900 450 500 300]); image(imread('climate_sea.jpg'));
  hecozones    = figure('Name','Land ecozone', 'Position',[300  50 500 300]); image(imread('ecozones.png'));
  hoceans      = figure('Name','Sea ecozone',  'Position',[900  50 500 300]); image(imread('oceans.jpg'));
  AmPgui
  
elseif ~infoAmPgui % finish AmPgui and proceed with AmPeps
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

else % proceed to writing 4 AmP source files for new species for AmP
  close all
  path = ['https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries/', metaData.species, '/'];

  [data, metaData] = AmPgui2mydata(data, metaData); % modify data and metaData to mydata format
  prt_mydata(data, auxData, metaData, txtData); % write mydata_my_pet.m file
  prt_run_my_pet(metaData.species); % write run_my_pet.m file

  % get pars_init file of a related species to produce structure par, metaPar, txtPar
  Clade = clade(metaData.species); % identify clade to which species belongs
  Clade = Clade(~ismember(Clade,metaData.species)); % exclude the species itself 
  pars_initFn = ['pars_init_', Clade{1}, '.m']; % take the first clade species for initial par values
  if ismac
    system([path, pars_initFn,  ' -O ', pars_initFn]);
  else
    eval(['!powershell wget ', path, pars_initFn, '.m',  ' -O ', pars_initFn])
  end
  eval(['[par, metaPar, txtPar] = pars_init_', Clade{1}, '(metaData);']); % use pars_init to produce structures par, metaPar, txtPar
  delete(pars_initFn); % delete the pars_init file of the related species
  auxParFld = prt_predict(par, metaPar, data, auxData, metaData); % write prefict file for model type taken from metaPar
  % auxParFld conains names of required auxiliary parameter

  % get auxiliary parameters
  parFields = fields(par); % current par fields
  EparFields = get_parfields(metaPar.model);  % core primary parameter fields for model
  parFields = setdiff(parFields, {'T_ref'});  % remove pararameter T_ref from current-list
  parFields = setdiff(parFields, EparFields); % non-core parameter fields
  chemParFields = fields(addchem([], [], [], [], metaData.phylum, metaData.class)); % par fields for chemical parameters
  otherParFields = setdiff(parFields, chemParFields); % current auxiliary parameter fields
  selPar = ismember(otherParFields, auxParFld);
  par = rmfield(par, otherParFields(~selPar)); % remove unnessasary parameters
  addParFields = auxParFld(~ismember(auxParFld, otherParFields(selPar))); % parameters fields that must be added
  n_add = length(addParFields);

  if n_add > 0
    % edit par & txtPar
    load prdPar
    for i = 1:n_add
      par.(addParFields{i})          = prdPar.value.(addParFields{i});
      par.free.(addParFields{i})     = prdPar.free.(addParFields{i});;
      txtPar.units.(addParFields{i}) = prdPar.units.(addParFields{i});
      txtPar.label.(addParFields{i}) = prdPar.label.(addParFields{i});
    end
  end

  % save results_my_pet.mat write pars_init_my_pet.m file
  save(['results_', metaData.species, '.mat'], 'data', 'auxData', 'metaData', 'txtData', 'par', 'metaPar', 'txtPar');
  mat2pars_init(metaData.species)

  % open 4 AmP source files in Matlab Editor
  edit(['mydata_',    metaData.species, '.m'], ...
       ['pars_init_', metaData.species, '.m'], ...
       ['predict_',   metaData.species, '.m'], ...
       ['run_',       metaData.species, '.m']);
end