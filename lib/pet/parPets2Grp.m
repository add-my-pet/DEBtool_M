%% parPets2Grp
% converts parameter-structure for each pet to that for a group of pets

%%
function parGrp = parPets2Grp(parPets)
% created 2018/05/23 by Bas Kooijman

%% Syntax
% parGrp = <../parPets2Grp.m *parPets2Grp*> (parPets)

%% Description
% Converts parameter-structure for each pet to that of a group of pets. 
% First level field names of output-structure are that of the parameters.
%
% Input:
%
% * parPets: structure with structures of parameters for each pet that are all scalar
%
% Output: 
%
% * parGrp: stucture with parameters for the group of pets that can be either scalar or vector-valued of length n_pets

%% Remarks
% Uses parameter specification in pars_init_group for scalar or vector representation of each parameter
% Function <parGrp2Pets.html *parGrp2Pets*> maps from structure of parameters for a group to that for each pet.

%% Example of use
% parGrp = parPets2Grp(parPets)

  global pets 

  n_pets = length(pets);
  if n_pets == 1
    parGrp = parPets.pets{1};
    return
  end
  
  % get parameter template from pars_init_group to get scalar or vector specification for each parameter
  % copy free-setting from template
  metaData.phylum = []; metaData.class = [];      % metadata as input for pars_init_group
  parGrp = pars_init_group(metaData);             % initiate output; will be overwritten 
  parNms = fieldnames(parGrp); n_parNms = length(parNms);

  % pack single-species specification to group specification
  for j = 1:n_parNms                       % scan parameters for each pet
    if ~strcmp(parNms{j},'free')
      n_parj = length(parGrp.(parNms{j}));
      if n_parj == 1 % scalar-valued parameter specification
        parGrp.(parNms{j}) = parPets.(pets{1}).(parNms{j});
      else           % n_parj == n_pets
        vec = zeros(1,n_pets); % initiate vector-valued parameter specification
        for i = 1:n_pets
          vec(i) = parPets.(pets{i}).(parNms{j});
        end
        parGrp.(parNms{j}) = vec;
      end
    end
  end

