%% predict_pets
% Catenates predictions from predict files

%%
function [Prd_data, info] = predict_pets(pargrp, chem, T_ref, data)
% created 2015/01/17 by Goncalo Marques, modified 2015/03/30 by Goncalo Marques

%% Syntax
% [Prd_data, info] = <../predict_pets.m *predict_pets*>(pargrp, chem, T_ref, data)

%% Description
% Catenates predictions from predict files
%
% Input
% 
% * pargrp: structure with par for several species
% * chem: structure with chemical parameters
% * T_ref: scalar with refeerence temperature
% * data: structure with data for several species
%
% Output
%
% * Prd_data: structure with predictions for several species
% * info: scalar with combined success (1) or failure (0) of predictions
 
global pets pseudodata_pets 

info = 0;

% unpack par
v2struct(pargrp);

% produce pars for species and predict
for i = 1:length(pets)
  par = pargrp;   % for the case with no zoom factor transformation
  ci = num2str(i);
  eval(['[Prd_data.pet', ci,', info] = predict_', pets{i},'(par, chem, T_ref, data.pet', ci,');']);
  if ~info
    return;
  end
  
  % predict pseudodata
  if pseudodata_pets == 0 % option of estim
    eval(['Prd_data.pet', ci,' = predict_pseudodata(Prd_data.pet', ci,', par, chem, data.pet', ci,');']);
  end
end

if pseudodata_pets == 1
  % predicts pseudodata
  Prd_data.psduni = predict_pseudodata([], pargrp, chem, data);
end

info = 1;