%% get_FAS
% Gets Factorial Aerobic Scope from phylum, class

%%
function [FAS, info] = get_FAS(phylum, class, order)
  % created 2018/03/27 by Bas Kooijman, modified 2018/05/25
  
  %% Syntax
  % [FAS, info] = <../get_FAS.m *get_FAS*> (phylum, class, order)
  
  %% Description
  % Get Factorial Aerobic Scope from taxonomic classification
  %
  % Input
  %
  % * phylum: name of animal phylum (one of 36 possibilities)
  % * class: name of class, only used for annelids, arthropods and chordates
  %  
  % Output
  %
  % * FAS: Factorial Aerobic Scope
  % * info: 1 if taxon could be identified, 0 otherwise
  
  %% Remarks
  % Check spelling if info = 0
  % Data from Verhille & Kooijman (2025), see SI
  % FAS is thought to apply to the result of get_FMR and is restricted to the interval (10^0.5, 10^1.5)
  
info = 1;

if isempty(phylum) % this construct is necessary for multi-species estimation where pars_init is called with empty arguments in parPets2Grp
  FAS = NaN; info = 0; return
end

switch phylum
  case 'Chordata'        
    switch class
    case {'Leptocardii','Appendicularia','Thaliacea','Ascidiacea','Myxini','Cephalaspidomorphi'}
      FAS = 3.2;
    case {'Chondrichthyes','Elasmobranchii'}
      FAS = 4.9;
    case 'Actinopterygii'
      FAS = 3.5;
    case 'Sarcopterygii' % needs renaming
      FAS = 4;
    case 'Amphibia'
      FAS = 7; 
    case 'Reptilia'
      FAS = 10;
    case 'Aves'
      FAS = 15;
    case 'Mammalia'
      FAS = 20;
    end

  otherwise
    FAS = 10^0.5;
end

end