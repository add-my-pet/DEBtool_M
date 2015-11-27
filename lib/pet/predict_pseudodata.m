%% predict_pseudodata
% Adds pseudodata predictions into predictions structure 

%%
function prdData = predict_pseudodata(par, data, prdData)
% created 2015/02/04 by Goncalo Marques
% modified 2015/07/29

%% Syntax
% prd = <../predict_pseudodata.m *predict_pseudodata*> (par, data, prdData)

%% Description
% Appends pseudodata predictions to a structure containing predictions for real data. 
% Predictions generated using the par structure
%
% Inputs:
%
% * par : structure with parameters 
% * data : structure with data
% * prdData : structure with data predictions 
%
% Output: 
%
% * prdData : structure with predicted data and pseudodata 

%% Example of use
% prdData = predict_pseudodata(par, data, prdData)

[nm, nst] = fieldnm_wtxt(data, 'psd');

if nst > 0
  % unpack coefficients
  cPar = parscomp_st(par);  allPar = par;
  fieldNames = fieldnames(cPar);
  for i = 1:size(fieldNames,1)
    allPar.(fieldNames{i}) = cPar.(fieldNames{i});
  end
  
  varnm = fieldnames(data.(nm{1}));
  
  % adds pseudodata predictions to structure
  for i = 1:length(varnm)
    prdData.psd.(varnm{i}) = allPar.(varnm{i});
  end
end