%% parGrp2Pets
% converts parameter-structure for a group of pets to a structure of parameters for each pet

%%
function parPets = parGrp2Pets(parGrp)
% created 2018/05/23 by Bas Kooijman

%% Syntax
% parPets = <../parGrp2Pets.m *parGrp2Pets*> (parGrp)

%% Description
% Converts parameter-structure for a group of pets to a structure of parameters for each pet. 
% First-level field names of output-structure are the pets.
% parPets.my_pet is the single-species parameter specification for my_pet, where all parameters are scalar
%
% Input:
%
% * parGrp: stucture with parameters for the group of pets (as in pars_init_group) that can be either scalar or vector-valued of length n_pets
%
% Output: 
%
% * parPets: structure with structures of parameters for each pet that are all scalar

%% Remarks
% In the case of no covariation rule, this function only copies group-specifications to single-species specifications.
% In other cases, however, the total number of parameters can be further reduced by assuming relationships between parameters for different species.
% Function <parPets2Grp.html *parPets2Grp*> maps from structure of parameters for each pet to that of a group

%% Example of use
% parPets = parGrp2Pets(parGrp)

  global pets covRules

  n_pets = length(pets);
  if n_pets == 1
    parPets.(pets{1}) = parGrp;
    return
  end
  
  parNms = fieldnames(parGrp); n_parNms = length(parNms);
  vec_zeros = zeros(n_pets,1); % for expansion of free settings
  
  % map group-specification to single-species specification
  for i = 1:n_pets         % scan pets
    pari = parGrp;         % prepare pararameters for pet i
    % parameter value setting (skipping free setting)
    for j = 1:n_parNms     % scan parameters for each pet
      if ~strcmp(parNms{j},'free') 
        val = parGrp.(parNms{j}); n_val = length(val); % determine length 1 or n_pets
        pari.(parNms{j}) =  val(min(n_val,i));         % select value i for pet i
      end
    end
    % free setting
    if exist('pari.free','var') % if called from groupregr_f, parGrp has no field 'free'
      freeNms = fieldnames(pari.free); n_freeNms = length(freeNms);
      for k = 1:n_freeNms
        % in the case of scalar setting, use free = 0 for all species other than the first one
        % the corresponding parameter can still change, since this function is called after each change in any parameter, before predictions are computed
        val = pari.free.(freeNms{k}) + vec_zeros; % make sure that element j is defined
        pari.free.(freeNms{k}) =  val(i);         % select value i for pet i 
      end
    end
    parPets.(pets{i}) = pari; % copy parameters for pet i to output
  end

  switch covRules % global cov_rules specifies the co-variation rules that should be applied
  
    case 'no'
    % do nothing 
  
    case 'maturities' % modify maturity levels according to zoom factor z, using pets{1} as reference
    % the free-setting and the initial values of these parameters for pets{2} till pets.{n_pets} are ignored with this covRule
    for i = 2:n_pets         % scan pets, using pets{1} as reference
      for j = 1:n_parNms     % scan parameters for each pet
        if strcmp(parNms{j},'E_H') % identify maturity levels
          parPets.(pets{i}).(parNms{j}) = parPets.(pets{1}).(parNms{j}) * parPets.(pets{i}).z^3/ parPets.(pets{1}).z^3; 
        end
      end
    end
    
    case 'bla'
    % add here your user-defined co-variation rules (replacing 'bla'), using case 'maturities' as example
    % insert 'estim_options('cov_rules','bla');' in the run-file for the group to actually use them
            
  end

  