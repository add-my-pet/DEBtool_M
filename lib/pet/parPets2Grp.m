%% parPets2Grp
% converts parameter-structure for each pet to that for a group of pets

%%
function parGrp = parPets2Grp(parPets, metaData)
% created 2018/05/23 by Bas Kooijman, modified 2019/03/12

%% Syntax
% parGrp = <../parPets2Grp.m *parPets2Grp*> (parPets, metaData)

%% Description
% Converts parameter-structure for each pet to that of a group of pets. 
% First level field names of output-structure are that of the parameters.
%
% Input:
%
% * parPets: structure with structures of parameters for each pet that are all scalar
% * metaData: structure with field phylum and class for addchem, which adds chemical parameters
%
% Output: 
%
% * parGrp: stucture with parameters for the group of pets that can be either scalar or vector-valued of length n_pets

%% Remarks
% Uses parameter specification in pars_init_group for scalar or vector representation of each parameter.
% If pars_init_group.m does not exist, all parameters are vector-represented, except T_ref, whch is always scalar-represented.
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
  if exist('pars_init_group.m', 'file')
    parGrp = pars_init_group(metaData);           % initiate output; will be overwritten 
    parNms = fieldnames(parGrp.free); n_parNms = length(parNms);
  else % no pars_init_group: all pars and free's are vector-valued
    parNms = [];
    for i = 1:n_pets
      parNmsi = fieldnames(parPets.(pets{i}).free); % prameter names of pets i
      parNms = [parNms; parNmsi]; % catenate all parameter names of all pets
    end
    parNms = unique(parNms, 'stable'); n_parNms = length(parNms); % remove all double names
    for i = 1:n_parNms
      parGrp.(parNms{i}) = zeros(1, n_pets); 
      parGrp.free.(parNms{i}) = zeros(1, n_pets); 
    end
  end

  % pack single-species specification to group specification
  for j = 1:n_parNms                       % scan parameters for each pet
      n_parj = length(parGrp.(parNms{j}));
      if n_parj == 1 || strcmp(parNms{j},'T_ref') % scalar-valued parameter and free specification
        parGrp.(parNms{j}) = parPets.(pets{1}).(parNms{j});
        parGrp.free.(parNms{j}) = parPets.(pets{1}).free.(parNms{j});
      else % vector-valued parameter and free specification
        vec = zeros(1,n_pets); % initiate vector-valued parameter specification
        fvec = zeros(1,n_pets); % initiate vector-valued parameter-free specification
        for i = 1:n_pets
          vec(i) = parPets.(pets{i}).(parNms{j});
          fvec(i) = parPets.(pets{i}).free.(parNms{j});
        end
        parGrp.(parNms{j}) = vec; 
        parGrp.free.(parNms{j}) = fvec;
     end
  end

