%% get_model
% Gets model from phylum or class

%%
function [model, info] = get_model(phylum, class, order)
  % created 2017/01/04 by Bas Kooijman
  
  %% Syntax
  % [model, info] = <../get_model.m *get_model*> (phylum, class, order)
  
  %% Description
  % Sets model according to taxonomic classification
  %
  % Input
  %
  % * phylum: string with name of animal phylum (one of 36 possibilities)
  % * class:  string with name of class
  % * order:  string with name of order
  %  
  % Output
  %
  % * model: string with name of typified model
  % * info: 1 if taxon could be identified, 0 otherwise
  
  %% Remarks
  % A few taxa have a deviating model.
  % Check spelling if info = 0
  
info = 1; model = [];
switch phylum
    case 'Cnidaria'
        switch class
            case {'Cubozoa', 'Scyphozoa'}                 
                model = 'abj';
            case {'Hydrozoa'}
                model = 'stf';
            case {'Anthozoa'}
               model = 'std';
        end
    case {'Ctenophora', 'Chaetognatha'}                 
        model = 'abj';
    case {'Acanthocephala', 'Rotifera', 'Gastrotricha'}                  
        model = 'std';
    case 'Platyhelminthes'
        model = 'abj';
    case {'Brachiopoda', 'Phoronida', 'Bryozoa', 'Annelida'}
        model = 'std';
    case {'Mollusca', 'Tardigrada', 'Nematoda'}
        model = 'abj';
    case 'Arthropoda'
        switch class
            case 'Branchiopoda'
                model = 'std';
            case {'Pycnogonida', 'Arachnida', 'Ostracoda', 'Ichthyostraca', 'Hexanauplia'}
                model = 'abj';
            case 'Malacostraca'
                switch order
                    case {'Isopoda', 'Euphausiacea'}
                        model = 'std';
                    case {'Amphipoda', 'Mysida', 'Decapoda'}
                        model = 'abj';
                end
            case 'Entomobryomorpha'
                model = 'abj';
            case 'Insecta'
                switch order
                    case 'Thysanura'
                        model = 'abj';
                    case 'Ephemeroptera'
                        model = 'hep';
                    case {'Orthoptera', 'Hemiptera'}
                        model = 'abp';
                    case {'Diptera'}
                        model = 'hax';
                    case {'Lepidoptera', 'Hymenoptera', 'Coleoptera'}
                        model = 'hex';
                    otherwise 
                        model = 'hex';
                end
        end
    case 'Echinodermata'                          
         model = 'abj';
    case 'Chordata'
        switch class
            case 'Leptocardii'
                model = 'abj';
            case {'Appendicularia', 'Ascidiacea', 'Myxini', 'Cephalaspidomorphi', 'Chondrichthyes', 'Elasmobranchii'}
                model = 'std';
            case 'Thaliacea'
                model = 'stf';
            case 'Actinopterygii'
                switch order
                    case {'Polypteriformes', 'Acipenseriformes', 'Lepisosteiformes', 'Amiiformes'}
                        model = 'std';
                    case {'Elopiformes', 'Albuliformes', 'Anguilliformes'}
                        model = 'ssj';
                    case {'Osteoglossiformes', 'Hiodontiformes'}
                        model = 'std';
                    case {'Clupeiformes', 'Alepocephaliformes', 'Gonorynchiformes', 'Cypriniformes', 'Characiformes'}
                        model = 'abj';
                    case 'Gymnotiformes'
                        model = 'std';
                    case {'Siluriformes','Lepidogalaxiiformes','Argentiniformes','Galaxiiformes','Salmoniformes'}
                        model = 'abj';
                    case {'Esociformes', 'Osmeriformes'}
                        model = 'std';
                    case {'Stomiiformes', 'Aulopiformes', 'Myctophiformes'}
                        model = 'abj';
                    case {'Lampriformes', 'Percopsiformes', 'Zeiformes'}
                        model = 'std';
                    case {'Gadiformes', 'Polymixiiformes'}
                        model = 'abj';
                    case {'Beryciformes', 'Holocentriformes'}
                        model = 'std';
                    case {'Ophidiiformes'}
                        model = 'ssj';
                    case {'Batrachoidiformes'}
                        model = 'std';
                    case {'Kurtiformes'}
                        model = 'abj';
                    case {'Gobiiformes', 'Syngnathiformes'}
                        model = 'std';
                    case {'Scombriformes'}
                        model = 'abj';
                    case {'Synbranchiformes', 'Anabantiformes'}
                        model = 'std';
                    case{'Polynemiformes', 'Carangiformes', 'Sphyraeniformes', 'Istiophoriformes', 'Centropomiformes', 'Pleuronectiformes'}
                        model = 'abj';
                    case {'Cichliformes', 'Beloniformes', 'Cyprinodontiformes'} 
                        model = 'std';
                    case{'Atheriniformes',  'Pomacentriformes'}
                        model = 'abj';
                    case {'Mugiliformes'}
                        model = 'std';
                    case {'Embiotociformes', 'Pseudochromiformes'}
                        model = 'abj';
                    case {'Gobiesociformes'}
                        model = 'std';
                    case {'Blenniiformes', 'Gerreiformes', 'Uranoscopiformes', 'Labriformes', ...
                          'Moroniformes', 'Ephippiformes', 'Gasterosteiformes', 'Chaetodontiformes', 'Sciaeniformes', ...
                          'Acanthuriformes', 'Pomacanthiformes', 'Lutjaniformes', 'Lobotiformes', ...
                          'Spariformes', 'Siganiformes', 'Scatophagiformes', 'Priacanthiformes', ...
                          'Caproiformes', 'Lophiiformes', 'Tetraodontiformes', 'Pempheriformes', 'Centrarchiformes', 'Perciformes', 'Scorpaeniformes'}
                        model = 'abj';
                end
          case {'Sarcopterygii', 'Amphibia', 'Reptilia', 'Aves'}
              model = 'std';
          case {'Mammalia'}
              switch order
                  case 'Monotremata'
                      model = 'std';
                  otherwise
                      model = 'stx';
              end
        end 
    otherwise
        fprintf('warning from get_model: taxon could not be identified\n')
        model = []; info = 0;
end