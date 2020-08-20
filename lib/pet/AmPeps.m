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
% 
%   - 0, species is in AmP, skip writing 4 source files
%   - 1, writing 4 source files with species in CoL
%   - 2, writing 4 source files with species not in CoL, but genus is in AmP
%   - 3, writing 4 source files with species not in CoL, genus is not in AmP, but family is
%   - 4, writing 4 source files with species not in CoL, family is not in AmP, but order is
%   - 5, writing 4 source files with species not in CoL, order is not in AmP, but class is
%   - 6, writing 4 source files with species not in CoL, class is not in AmP, but phylum is
%   - 7, writing 4 source files with species not in CoL, phylum is not in AmP

global data metaData txtData auxData pets hclimateLand hecozones

if ~exist('infoAmPgui', 'var') % open webpages, show figures and start AmPgui
  web('https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/AmPeps.html','-browser');
  web('https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/AmPeco.html','-browser');
  hclimateLand = figure('Name','Land climate', 'Position',[300 450 500 300]); image(imread('climate_land.png'));
  hclimateSea  = figure('Name','Sea climate',  'Position',[900 450 500 300]); image(imread('climate_sea.jpg'));
  hecozones    = figure('Name','Land ecozone', 'Position',[300  50 500 300]); image(imread('ecozones.png'));
  hoceans      = figure('Name','Sea ecozone',  'Position',[900  50 500 300]); image(imread('oceans.jpg'));
  AmPgui
  
elseif infoAmPgui == 0 % skip the rest of AmPeps and proceed with opening source files in Matlab editor
  close all
  path = ['https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries/', metaData.species, '/'];

  if ismac
    system(['curl ', path, 'mydata_', metaData.species, '.m',  ' -O ', 'mydata_', metaData.species, '.m']);
    system(['curl ', path, 'pars_init_', metaData.species, '.m',  ' -O ', 'pars_init_', metaData.species, '.m']);
    system(['curl ', path, 'predict_', metaData.species, '.m',  ' -O ', 'predict_', metaData.species, '.m']);
    system(['curl ', path, 'run_', metaData.species, '.m',  ' -O ', 'run_', metaData.species, '.m']);
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

else % infoAmPgui > 0:  proceed to writing 4 AmP source files for new species for AmP

  % check for essential fields
  if isempty(metaData.author)
    fprintf('Warning from AmPeps: please enter author name\n');
    AmPgui('author')
  end
  %
  if isempty(metaData.curator)
    fprintf('Warning from AmPeps:select curator\n');
    AmPgui('curator')
  end
  %
  if isempty(metaData.species)
    fprintf('Warning from AmPeps: please enter species name\n');
    AmPgui('species')
  end
  %
  if isempty(metaData.T_typical)
    fprintf('Warning from AmPeps: please specify typical body temperature\n');
    AmPgui('T_typical')
  end
  %
  if ~isempty(metaData.facts)
    fld_F = fields(metaData.facts); n = length(fld_F);
    for i= 1:n
      if isempty(metaData.bibkey.(fld_F{i}))
        fprintf(['Warning from AmPeps: please enter a bibkey for fact ', fld_F{i}, '\n']);
        AmPgui('facts')
      end
    end
  end
  %
  if isempty(data.data_0)
    fprintf('Warning from AmPeps: please enter at least one 0-variate data point\n');
    AmPgui('data_0')
  else
    fld_0 = fields(data.data_0); n = length(fld_0);
    for i= 1:n
      if isempty(txtData.bibkey.(fld_0{i}))
        fprintf(['Warning from AmPeps: please enter a bibkey for dataset ', fld_0{i}, '\n']);
        AmPgui('data_0')
      end
    end
  end
  %
  fld_1 = {};
  if ~isempty(data.data_1)
    fld_1 = fields(data.data_1); n = length(fld_1);
    for i= 1:n
      if isempty(txtData.bibkey.(fld_1{i}))
        fprintf(['Warning from AmPeps: please enter a bibkey for dataset ', fld_1{i}, '\n']);
        AmPgui('data_1')
      end
    end
  end
  %
  if isempty(metaData.biblist)
    fprintf('Warning from AmPeps: empty biblist, please complete\n');
    AmPgui('biblist')
  else 
    if isempty(metaData.bibkey)
      fld = unique([fld_0; fld_1]);
    else
      fld = unique([fields(metaData.bibkey); fld_0; fld_1]);
    end
    fld = fld(ismember(fld, fields(metaData.biblist)));
    if ~isempty(fld)
      fprintf('Warning from AmPeps: the following bibkey were not found in the biblist\n');
      fld
    end 
    AmPgui('biblist')
  end
  %
  if isempty(metaData.COMPLETE)
    fprintf('Warning from AmPeps: please specify COMPLETE\n');
    AmPgui('COMPLETE')
  end
  
  close all;   % no return from here: write mydata and run files, deleting mat-files

  
  if ~isempty(data.data_1)
    fld_data_1 = fields(data.data_1); % required to add data-specific scaled functional responses
  else
    fld_data_1 = {};
  end
  [data, metaData] = AmPgui2mydata(data, metaData); % modify data and metaData to mydata format
  prt_mydata(data, auxData, metaData, txtData); % write mydata_my_pet.m file
  prt_run_my_pet(metaData.species); % write run_my_pet.m file

  % get pars_init file of a related species to produce structure par, metaPar, txtPar
  model_def = get_model(metaData.phylum, metaData.class, metaData.order); % default model for this taxon
  % park data structures, because they will be overwritten by load(results_my_pet)
  data_my_pet = data; txtData_my_pet = txtData; auxData_my_pet = auxData; metaData_my_pet = metaData;
  switch infoAmPgui
    case 1 % species in CoL, not in AmP
      Clade = clade(metaData.species); % identify clade to which species belongs
    case 2 % species not in CoL, genus in AmP
      genus = strsplit(metaData.species,'_'); genus = genus{1};
      Clade = select(genus);
    case 3 % species not in CoL, genus not in AmP, family in AmP
      Clade = select(metaData.family);
    case 4 % species not in CoL, family not in AmP, order in AmP
      Clade = select(metaData.order);
    case 5 % species not in CoL, order not in AmP, class in AmP
      Clade = select(metaData.order);
    case 6 % species not in CoL, class not in AmP, phylum in AmP
      Clade = select(metaData.class);
    case 7 % species not in CoL, phylum not in AmP
      Clade = select;        
  end 
  Clade = Clade(~ismember(Clade,metaData.species)); % exclude the species itself 
  n_Clade = length(Clade); Clade = Clade(1:min(5,n_Clade)); n_Clade = length(Clade); % set max clade members at 5
  criterion = zeros(n_Clade,1); model_Clade = cell(n_Clade,1); resultsFn = cell(n_Clade,1);
  path = 'https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries/'; % path for results_my_pet.mat files
  for i = 1:n_Clade % scan clade members
    resultsFn{i} = ['results_', Clade{i}, '.mat']; 
    if ismac
      system(['curl ', path, Clade{i}, '/', resultsFn{i},  ' -O ', resultsFn{i}]);
    else
      system(['powershell wget ', path, Clade{i}, '/', resultsFn{i},  ' -O ', resultsFn{i}]);
    end
    load(resultsFn{i});
    criterion(i) = metaData.COMPLETE/ metaPar.MRE; model_Clade{i} = metaPar.model;
  end
  sel_Clade = ismember(model_Clade, model_def); [~, i_Clade] = sort(criterion);
  if any(sel_Clade) % at least 1  clade species with default model
    i_Clade = i_Clade(sel_Clade);
  end
  i_Clade = i_Clade(end); % index of "best" clade species
  load(resultsFn{i_Clade}); 
  fprintf(['Notice from AmPeps: AmP species ', Clade{i_Clade}, ' was used for initial parameter estimates with model ', model_Clade{i_Clade}, '\n']);
  delete *.mat; % delete the results files of the related species
  
  data = data_my_pet; txtData = txtData_my_pet; auxData = auxData_my_pet;  metaData = metaData_my_pet; % result data structures
  auxParFld = prt_predict(par, metaPar, data, auxData, metaData); % write prefict file for model type taken from metaPar
  % auxParFld contains names of required auxiliary parameter

  % get auxiliary parameters
  parFields = fields(par); % current par fields
  EparFields = get_parfields(metaPar.model);  % core primary parameter fields for model
  parFields = setdiff(parFields, {'T_ref'});  % remove parameter T_ref from current-list
  parFields = setdiff(parFields, EparFields); % non-core parameter fields
  chemParFields = fields(addchem([], [], [], [], metaData.phylum, metaData.class)); % par fields for chemical parameters
  otherParFields = setdiff(parFields, chemParFields); % current auxiliary parameter fields
  otherParFields = setdiff(otherParFields, {'free', 'f'});
  selPar = ismember(otherParFields, auxParFld);
  par = rmfield(par, otherParFields(~selPar)); % remove unnessasary parameters
  addParFields = auxParFld(~ismember(auxParFld, otherParFields(selPar))); % parameters fields that must be added
  n_add = length(addParFields);

  if n_add > 0
    % edit par & txtPar
    load auxPar
    for i = 1:n_add
      if ischar(auxPar.(addParFields{i}).value)
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

  % overwrite results_my_pet.mat in a way that it can no longer be used as substrate for AmPgui
  save(['results_', metaData.species, '.mat'], 'data', 'auxData', 'metaData', 'txtData', 'par', 'metaPar', 'txtPar');
  pets = {metaData.species}; mat2pars_init; % this uses results_my_pet.mat to overwrite pars_init_my_pet.m

  % open 4 AmP source files in Matlab Editor
  edit(['mydata_',    metaData.species, '.m'], ...
       ['pars_init_', metaData.species, '.m'], ...
       ['predict_',   metaData.species, '.m'], ...
       ['run_',       metaData.species, '.m']);
end
