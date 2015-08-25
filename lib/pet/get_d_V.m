%% get_d_V
% Gets specific density of structure from phylum or class

%%
function [d_V info] = get_d_V(phylum, class)
  % created 2015/01/18 by Bas Kooijman, modified 2015/08/24
  
  %% Syntax
  % d_V = <../get_d_V.m *get_d_V*>
  
  %% Description
  % Sets specific density d_V according to taxonomic classification
  %
  % Input
  %
  % * phylum: name of animal phylum (one of 36 possibilities)
  % * class: name of class, only used for molluscs and chordates
  %  
  % Output
  %
  %  d_V: scalar with specific density in g/cm^3 of dry mass
  %  info: 1 if taxon could be identified, 0 otherwise
  
  %% Remarks
  % d_V has units g/cm^3 and refers to dry mass.
  % Since the specific density of wet mass is taken to be 1 g/cm^3,
  % it can also be considered as a dry/wet mass ratio
  % Check spelling if info = 0
  
info = 1;
switch phylum
    case 'Porifera'
        d_V = 0.11;
    case {'Ctenophora', 'Cnidaria'}
        d_V = 0.01;
    case 'Gastrotricha'                              % Platyzoa
        d_V = 0.05;
    case 'Rotifera'
        d_V = 0.06;
    case 'Platyhelminthes'
        d_V = 0.25;
    case {'Ectoprocta', 'Entoprocta'}                % Spiralia 
        d_V = 0.07;
    case 'Annelida'
        d_V = 0.16;
    case 'Sipuncula'
        d_V = 0.11;
    case 'Mollusca'
        switch class
            case 'Cephalopoda'
              d_V = 0.21;
            case 'Gastropoda'
              d_V = 0.15;
            case 'Bivalvia'
              d_V = 0.09;
            otherwise
              d_V = 0.1;
        end
    case {'Tardigrada', 'Chaetognata', 'Priapulida'} % Ecdysozoa
        d_V = 0.07;
    case 'Arthropoda'
        d_V = 0.17;
    case 'Echinodermata'                             % deuterostomata
        d_V = 0.09;
    case 'Hemichordata'
        d_V = 0.07;
    case 'Chordata'
        switch class
            case {'Mammalia', 'Reptilia'}
              d_V = 0.3;
            case {'Aves', 'Amphibia'}
              d_V = 0.28;
            case {'Chondrichthyes', 'Actinopterygii', 'Sarcopterygii'}
              d_V = 0.2;
            case 'Myxini'
              d_V = 0.17;
            case 'Cephalaspidomorphi'
              d_V = 0.125;
            case 'Appendicularia'
              d_V = 0.045;
            case 'Thaliacea'
              d_V = 0.08;
            otherwise % Ascidiacea
              d_V = 0.06;
        end 
    case 'my_pet_phylum'
        d_V = 0.1;
    otherwise
        fprintf('warning from get_d_V: taxon could not be identified: d_V = 0.1 g/cm^3\n')
        d_V = 0.1; info = 0;
end
end