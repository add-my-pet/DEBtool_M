%% get_s_s
% Gets supply stress from phylum or class

%%
function [s_s, info] = get_s_s(phylum, class)
  % created 2023/11/27 by Bas Kooijman
  
  %% Syntax
  % [s_s, info] = <../get_s_s.m *get_s_s*> (phylum, class)
  
  %% Description
  % Sets supply stress s_s = p_J*p_M^2/p_A^3 = kap^2*p_J/p_A according to taxonomic classification
  %
  % Input
  %
  % * phylum: name of animal phylum (one of 36 possibilities)
  % * class: name of class, only used for molluscs, arthropods and chordates
  %  
  % Output
  %
  %  s_s: scalar with supply stress
  %  info: 1 if taxon could be identified, 0 otherwise
  
  %% Remarks
  % s_s can take values between 0 and 4/27.
  
info = 1;

if isempty(phylum) % this construct is necessary for multi-species estimation where pars_init is called with empty arguments in parPets2Grp
  s_s = NaN; info = 0; return
end

switch phylum
    case 'Porifera'
        s_s = 3e-5;
    case {'Ctenophora', 'Cnidaria'} % Radiata
        s_s = 3e-5;
    case {'Xenacoelomorpha','Gastrotricha'} % Platyzoa
        s_s = 8e-3;
    case {'Platyhelminthes','Nemertea','Acanthocephala','Chaetognatha','Rotifera'}
        s_s = 1e-4;
    case {'Bryozoa','Entoprocta','Phoronida'} % Spiralia 
        s_s = 2e-4;
    case {'Annelida','Sipuncula','Brachiopoda'}
        s_s = 2e-3;
    case 'Mollusca'
        switch class
            case 'Cephalopoda'
              s_s = 6e-5;
            case 'Gastropoda'
              s_s = 6e-4;
            case 'Bivalvia'
              s_s = 3e-4;
            otherwise
              s_s = 3e-4;
        end
    case {'Tardigrada','Priapulida','Nematoda'} % Ecdysozoa
        s_s = 3e-4;
    case 'Arthropoda'
        switch class
            case 'insecta'
               s_s = 5e-7;
            otherwise
               s_s = 3e-4;
        end
    case {'Echinodermata','Hemichordata'} % Deuterostomata
        s_s = 1e-3; 
    case 'Chordata'
        switch class
            case 'Mammalia'
              s_s = 0.035;
            case 'Aves'
              s_s = 0.04;
            case 'Reptilia'
              s_s = 0.0235;
            case 'Amphibia'
              s_s = 0.0125;
            case {'Chondrichthyes','Elasmobranchii'} 
              s_s = 0.02;
            case 'Actinopterygii'
              s_s = 0.002;
            case 'Sarcopterygii'
              s_s = 0.033;
            case 'Myxini'
              s_s = 0.008;
            case 'Cephalaspidomorphi' 
              s_s = 0.0025;
            case {'Appendicularia','Thaliacea','Ascidiacea','Leptocardii'}
              s_s = 1e-5;
        end 
    case 'my_pet_phylum' % demo mydata_my_pet
        s_s = 0.0001; info = 0;
    otherwise
        fprintf('warning from get_s_s: taxon could not be identified: s_s = 0.0001\n')
        s_s = 0.0001; info = 0;
end
end