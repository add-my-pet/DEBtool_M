%% predict_pseudodata
% Adds pseudodata predictions into predictions structure 

%%
function prd = predict_pseudodata(prd, par, chem, data)
% created 2015/02/04 by Goncalo Marques

%% Syntax
% prd = <../predict_pseudodata.m *predict_pseudodata*> (prd, par, chem)

%% Description
% adds pseudodata predictions into predictions structure
% uses par and chem to compute these predictions
%
% Inputs:
%
% * prd : structure with data predictions 
% * par : structure with parameters 
% * chem : structure with biochemical parameters 
%
% Output: 
%
% * prd : structure with data and pseudodata predictions 

%% Example of use
% prd = predict_pseudodata(prd, par, chem)
% computes the pseudodata predictions and adds them to prd 

[nm, nst] = fieldnm_wtxt(data, 'psd');

if nst > 0
  % unpack coefficients
  cpar = parscomp_st(par, chem);
  v2struct(par); v2struct(chem); v2struct(cpar);
  
  eval(['varnm = fieldnames(data.', nm{1}, ');']);
  
  % adds pseudodata predictions to structure
  for i = 1:length(varnm)
    eval(['prd.psd.', varnm{i}, ' = ', varnm{i},';']);
  end
end