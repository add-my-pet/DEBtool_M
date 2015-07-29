%% predict_pets
% Catenates predictions from predict files

%%
function [prdData, info] = predict_pets(parGrp, data, auxData)
% created 2015/01/17 by Goncalo Marques, modified 2015/03/30 by Goncalo Marques
% modified 2015/07/29 by Starrlight

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
%
% Output
%
% * prdData: structure with predictions for several species
% * info: scalar with combined success (1) or failure (0) of predictions
 
global pets pseudodata_pets 

info = 0;

% unpack par
v2struct(parGrp);

% produce pars for species and predict
for i = 1:length(pets)
 % for the case with no zoom factor transformation
  ci = num2str(i); 
  eval(['[prdData.pet', ci,', info] = predict_', pets{i},'(parGrp, data.pet', ci,', auxData.pet', ci,');']);
  if ~info
    return;
  end
  
  % predict pseudodata
  if pseudodata_pets == 0 % option of estim
    eval(['prdData.pet', ci,' = predict_pseudodata(parGrp, data.pet', ci,', prdData.pet', ci,');']);
  end
end

if pseudodata_pets == 1
  % predicts pseudodata
  prdData = predict_pseudodata(parGrp, data, prdData);
end

info = 1;