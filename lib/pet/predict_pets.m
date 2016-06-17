%% predict_pets
% Catenates predictions from predict files

%%
function [prdData, info] = predict_pets(parGrp, data, auxData)
% created 2015/01/17 by Goncalo Marques, modified 2015/03/30 by Goncalo Marques
% modified 2015/08/03 by Starrlight, modified 2015/08/26 by Goncalo Marques

%% Syntax
% [prdData, info] = <../predict_pets.m *predict_pets*>(parGrp, data, auxData)

%% Description
% Catenates predictions from predict files
%
% Input
% 
% * parGrp: structure with par for several species
% * data: structure with data for several species
% * auxData: structure with auxiliary data for several species
% * covRulesnm: character string with name of user-defined covariation rules function
%
% Output
%
% * prdData: structure with predictions for several species
% * info: scalar with combined success (1) or failure (0) of predictions
 
global pets toxs pseudodata_pets cov_rules

info = 0;

petsnumber = length(pets);
covRulesnm = ['cov_rules_', cov_rules];

% produce pars for species and predict
for i = 1:petsnumber
 % for the case with no zoom factor transformation
  par = feval(covRulesnm, parGrp, i);
  currentPet = pets{i};
  toxsnumber = length(toxs);
  if toxsnumber == 0
    [prdData.(currentPet), info] = feval(['predict_', pets{i}], par, data.(currentPet), auxData.(currentPet));
    if ~info
      return;
    end
  else
    for j = 1:toxsnumber
      currentTox = toxs{j};
      [prdData.(currentPet).(currentTox), info] = feval(['predict_', currentPet, '_', currentTox], par, data.(currentPet).(currentTox), auxData.(currentPet).(currentTox));
      if ~info
        return;
      end
    end
  end
  
  % predict pseudodata
  if pseudodata_pets == 0 % option of estim
    prdData.(currentPet) = predict_pseudodata(par, data.(currentPet), prdData.(currentPet));
  end
end

if pseudodata_pets == 1
  % predicts pseudodata
  prdData = predict_pseudodata(feval(covRulesnm, parGrp, 1), data, prdData);
end

info = 1;

function par = cov_rules_1species(par, i)
% cov_rules family of functions takes the parameters of the group and
%   computes the parameters of each pet for the multispecies estimation
% This is the simplest case (to be used when we have only one species) 
%   where there is no transformation, i.e. it receives par and it returns par