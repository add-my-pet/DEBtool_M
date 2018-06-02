%% get_N_waste
% Gets chemical indices and chemical potential of N-waste from phylum, class

%%
function [n_CN n_HN n_ON n_NN mu_N info] = get_N_waste(phylum, class)
  % created 2018/03/27 by Bas Kooijman, modified 2018/05/25
  
  %% Syntax
  % [n_CN n_HN n_ON n_NN mu_N info] = <../get_N_waste.m *get_N_waste*> (phylum, class)
  
  %% Description
  % Sets chemical indices and chemical potential of N-waste according to taxonomic classification
  %
  % Input
  %
  % * phylum: name of animal phylum (one of 36 possibilities)
  % * class: name of class, only used for annelids, arthropods and chordates
  %  
  % Output
  %
  % * n_CN, n_HN, n_ON, n_NN: scalars with chemical indices
  % * mu_N: scalar with chemical potential in J/C-mol
  % * info: 1 if taxon could be identified, 0 otherwise
  
  %% Remarks
  % Check spelling if info = 0
  % Three possible N-wastes are delineated: Ammonia, urea, uric acid, mixtures are ignorned
  % Data from Withers, P.C. (1992): Comparative Animal Physiology. Saunders College Publishing
  
info = 1;

if isempty(phylum) % this construct is necessary for multi-species estimation where pars_init is called with empty arguments in parPets2Grp
  n_CN = NaN; n_HN = NaN; n_ON = NaN; n_NN = NaN; mu_N = NaN; info = 0; return
end

switch phylum
    case 'Porifera'
        N_waste = 'ammonoletic';
    case {'Ctenophora', 'Cnidaria'}                              % Radiata
        N_waste = 'ammonoletic';
    case 'Xenacoelomorpha'                          
        N_waste = 'ammonoletic';
    case 'Gastrotricha'                                          % Platyzoa
        N_waste = 'ammonoletic';
    case 'Rotifera'
        N_waste = 'ammonoletic';
    case {'Platyhelminthes', 'Acanthocephala', 'Chaetognatha'}
        N_waste = 'ammonoletic';
    case {'Bryozoa', 'Entoprocta', 'Phoronida', 'Brachiopoda'}   % Spiralia 
        N_waste = 'ammonoletic';
    case 'Annelida' % terrestrial species are ureotelic, aquatic ones ammonoletic
        switch class
            case 'Clitellata'
                N_waste = 'ureotelic';
            otherwise
                N_waste = 'ammonoletic';
        end
    case 'Sipuncula'
        N_waste = 'ammonoletic';
    case 'Mollusca' % terrestrial species are ureotelic
        N_waste = 'ammonoletic';
    case {'Tardigrada', 'Priapulida', 'Nematoda'}                % Ecdysozoa
        N_waste = 'ammonoletic';
    case 'Arthropoda' % terrestrial species are uricotelic, aquatic ones ammonoletic 
        switch class
            case {'Arachnida','Entognatha','Insecta'}
                N_waste = 'uricotelic';
            otherwise
                N_waste = 'ammonoletic';
        end
    case {'Echinodermata','Hemichordata'}                        % Deuterostomata
        N_waste = 'ammonoletic';
    case 'Chordata'
        switch class
            case {'Leptocardii','Appendicularia','Thaliacea','Ascidiacea'}
                N_waste = 'ammonoletic';
            case {'Myxini','Cephalaspidomorphi'}
                N_waste = 'ammonoletic';
            case 'Chondrichthyes'
                N_waste = 'ureotelic';
            case 'Actinopterygii'
                N_waste = 'ammonoletic';
            case 'Sarcopterygii'
                N_waste = 'ureotelic';
            case 'Amphibia'
                N_waste = 'ureotelic'; % ammonoletic in water 
            case 'Reptilia'
                N_waste = 'uricotelic';
                % crocs and aquatic snakes partly ammonoletic, 
                % turtles and leguanas partly ureotelic
            case 'Aves'
                N_waste = 'uricotelic';
            case 'Mammalia'
                N_waste = 'ureotelic';
        end
    case 'my_pet_phylum' % demo mydata_my_pet
        N_waste = 'ammonoletic';
    otherwise
        fprintf('warning from get_N_waste: taxon could not be identified: ammonoletic\n')
        N_waste = 'ammonoletic'; info = 0;
end

switch N_waste
    case 'ammonoletic'
        n_CN = 0; n_HN = 3; n_ON = 0; n_NN = 1; % ammonia: H3N
        mu_N = 0;
    case 'ureotelic'
        n_CN = 1; n_HN = 2; n_ON = 1; n_NN = 2; % urea: CH2ON2
        mu_N = 122e3;   % J/C-mol  synthesis from NH3, Withers page 119     
    case 'uricotelic'
        n_CN = 1; n_HN = 0.8; n_ON = 0.6; n_NN = 0.8; % uric acid: C5H4O3N4
        mu_N = 244e3/5; % J/C-mol  synthesis from NH3, Withers page 119           
end

end