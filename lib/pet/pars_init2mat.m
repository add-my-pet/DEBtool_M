%% pars_init2mat
% writes  a .mat file from one or more pars_init files

%%
function pars_init2mat(petsGrp)
% created 2019/03121 by  Bas Kooijman

%% Syntax
% <../pars_init2mat.m *pars_init2mat*> (petsGrp) 

%% Description
% Makes a results_pets.mat file from one or more pars_init_pets files, where 'pets' is replaces by names of entries
% The intended use is to create a pars_init_group.m file from a set of pars_init_my_pet-files and then edit the result:
%
%   pars_init2mat({'pet_1','pet_2','pet_3'}); mat2pars_init
%
% The function assumes the local presence of the mydata and pars_init files of the species mentioned in pets
%
% Input:
%
% * petsGrp: optional cell or character string with the species names (default: all species with mydata and pars_init files in the local directory)

%% Remarks
% Keep in mind that the files will be saved in your local directory; 
% use the cd command BEFORE running this function to save files in the desired place.
% With only one pet, pars_init2mat is inverse to mat2pars_init, and catenated  "pars_init2mat('my_pet'); mat2pars_init;" results in the same file pars_init_my_pet.m.
% If all pets belong to a taxon, and all taxon members are represented in the group, it is possible to use pars_init2mat(select('taxon')); mat2pars_init.
% Warning: this function modifies global pets.
   
  global pets

  if ~exist('petsGrp', 'var')
    mydata = ls('*mydata_*.m'); n_mydata = size(mydata,1); pets_mydata = cell(n_mydata,1);
    for i = 1:n_mydata
      pet = mydata(i,:); pet = strsplit(pet,'.'); pet = pet{1}; pet(1:7) = []; pets_mydata{i} = pet;
    end
    pars_init = ls('*pars_init_*.m'); n_pars_init = size(pars_init,1); pets_pars_init = cell(n_pars_init,1);
    for i = 1:n_pars_init
      pet = pars_init(i,:); pet = strsplit(pet,'.'); pet = pet{1}; pet(1:10) = []; pets_pars_init{i} = pet;
    end
    pets = pets_mydata(ismember(pets_mydata, pets_pars_init)); pets = pets(ismember(pets_mydata, pets));
  elseif ~iscell(petsGrp) % single species
    pets = {petsGrp}; n_pets = 1;
  else % grp memebers are specified
    pets = petsGrp; n_pets = length(pets);
  end

  for i = 1:n_pets
    eval(['[data, auxData, metaDatai] = mydata_', pets{i}, ';']);
    metaData.(pets{i}).phylum = metaDatai.phylum; metaData.(pets{i}).class = metaDatai.class; % required for assinging default chemical parameters via addchem
    if n_pets == 1
      eval(['[par, metaPar, txtPar] = pars_init_', pets{i}, '(metaDatai);']);
    else
      eval(['[par.(pets{i}), metaPar.(pets{i}), txtPar] = pars_init_', pets{i}, '(metaDatai);']);
    end
  end

  if n_pets == 1
    save(['results_', pets{1}, '.mat'], 'par', 'txtPar', 'metaPar', 'metaData');
  else
    par = parPets2Grp(par, metaData);
    % metaPar
    model = cell(n_pets,1);
    for i = 1:n_pets
      model{i} = metaPar.(pets{i}).model;
    end
    metaPar = []; metaPar.model = model; metaPar.cov_rules = '';
    save('results_group.mat', 'par', 'txtPar', 'metaPar', 'metaData');
  end
