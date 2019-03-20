%% addVarPar
% computer a term that is added to the augmented loss function

%%
function vp = addVarPar(par, weightsPar)
% created 2019/03/20 by by Bas Kooijman

%% Syntax
% vp = <../addVarPar.m *addVarPar*> (par, weightsPar)

%% Description
% computes weighted sum of scaled variances of parameters, to be added to loss function in groupregr_f.
%
% Input
%
% * par: structure with parameters in the format as specified in pars_init_group
% * weightsPar: structure with weights for parameters to minimize scaled variances
%  
% Output
% 
% * vp: scalar with weighted variances

%% Remarks
% the first-level field names of par and weightsPar should match

vp = 0; fldPar = fieldnames(par);
for i = 1:length(fldPar)
  meanPari = mean(par.(fldPar{i}));
  if meanPari ~= 0
    vp = vp + weightsPar.(fldPar{i}) * var(par.(fldPar{i}))/ meanPari^2;
  end
end

