%% cov_rules_basic
% computes parameter set of a species from the parameter set of the group using the basic rules

%%
function pSpec = cov_rules_basic(p, specNm)
% created 2015/08/24 by Goncalo Marques

%% Syntax
% pSpec = <../cov_rules_basic.m *cov_rules_basic*> (p, specNm)

%% Description
% Computes the parameter set of a species from the parameter set of the
%    group using the basic covariance  rules. The rules are that all core 
%    parameters are the same except the maturity levels that vary with z^3
%
% Input
%
% * p: structure with parameters of the group
% * specNm: number with the species to be computed
%  
% Output
%
% * pSpec: structure with parameters of the species

%% Remarks
%  The theory behind the co-variation of parameters is presented in 
%    <http://www.bio.vu.nl/thb/research/bib/Kooy2010.html Kooy2010>.

parFields = fields(p);

for i = 1:length(parFields)
  if length(p.(parFields{i})) == 1
    if strfind(parFields{i}, 'E_H') == 1
      pSpec.(parFields{i}) = p.(parFields{i}) * p.z(specNm)^3;
    else
      pSpec.(parFields{i}) = p.(parFields{i});
    end    
  elseif length(p.(parFields{i})) < specNm
    error(['    The parameter ', parFields{i}, ' as more than one value, but does not have a value for species ', num2str(specNm), '.\n']);
  elseif ~isnan(p.(parFields{i})(specNm)) % if NaN assume the parameter does not exist for the species
    pSpec.(parFields{i}) = p.(parFields{i})(specNm) ;
  end
end