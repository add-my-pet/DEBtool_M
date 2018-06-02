%% get_s_Hbp
% Gets maturity ratio from order and family for class Aves (birds)

%%
function [s_Hbp,  score, info] = get_s_Hbp(order, family)
  % created 2017/11/24 by Bas Kooijman
  
  %% Syntax
  % [s_Hbp  score info] = <../get_s_Hbp.m *get_s_Hbp*> (order, family)
  
  %% Description
  % Sets maturity ratio at birth over puberty for birds according to
  % taxonomic classification via the altricial-precocial score of Nice 1962:
  %  1 altricial
  %  2 semialtrical 2
  %  3 semialtrical 1
  %  4 semiprecocial
  %  5 precocial 4
  %  6 precocial 3
  %  7 precocial 2
  %  8 precocial 1 
  %
  % Input
  %
  % * order: name of bird order
  % * family: name of bird family
  %  
  % Output
  %
  % * s_Hbp: scalar with specific maturity ratio
  % * score: integer in range 1 till 8 of altricial-precocial score
  % * info: 1 if taxon could be identified, 0 otherwise
  
  %% Remarks
  % Check spelling if info = 0
  
info = 1;

switch order        
  case 'Struthioniformes'
    score = 6;
  case 'Rheiformes'
    score = 6;
  case 'Tinamiformes'
    score = 6;
  case 'Casuariiformes'
    score = 6;
  case 'Apterygiformes'
    score = 8;
  case 'Galliformes'
      switch family
        case 'Megapodiidae'
          score = 8;
        case 'Cracidae'
          score = 5;
        otherwise
          score = 7;
      end
  case 'Anseriformes'
    score = 7;
  case 'Phoenicopteriformes'
    score = 5;
  case 'Podicipediformes'
    score = 5;
  case 'Columbiformes'
    score = 2;
  case 'Mesitornithiformes'
    score = 5;
  case 'Pteroclidiformes'
    score = 7;
  case 'Apodiformes'
    score = 1;
  case 'Caprimulgiformes'
    score = 3;
  case 'Aegotheliformes'
    score = 3;
  case 'Cuculiformes'
    score = 1;
  case 'Otidiformes'
    score = 5;
  case 'Musophagiformes'
    score = 2;
  case 'Opisthocomiformes'
    score = 5;
  case 'Gruiformes'
    score = 5;
  case 'Charadriiformes'
    switch family
      case {'Alcidae','Laridae','Sternidae','Stercorariidae'}
        score = 4;
      case 'Turnicidae'
        score = 5; 
      otherwise
        score = 7;
    end
  case 'Gaviiformes'
    score = 5;
  case 'Procellariiformes'
    score = 3;
  case 'Sphenisciformes'
    score = 2;
  case 'Ciconiiformes'
    score = 3;
  case 'Suliformes'
    switch family
      case 'Phalacrocoracidae'
        score = 4;
      otherwise
        score = 1;
    end
  case 'Pelecaniformes'
    score = 1;
  case 'Eurypygiformes'
    score = 4;
  case 'Phaethontiformes'
    score = 2;
  case 'Cathartiformes'
    score = 2;
  case 'Accipitriformes'
    score = 2;
  case 'Strigiformes'
    score = 2;
  case 'Coliiformes'
    score = 3;
  case 'Leptosomiformes'
    score = 3;
  case 'Trogoniformes'
    score = 1;
  case 'Bucerotiformes'
    score = 1;
  case 'Coraciiformes'
    score = 1;
  case 'Piciformes'
    score = 1;
  case 'Cariamiformes'
    score = 3;
  case 'Falconiformes'
    score = 3;
  case 'Psittaciformes'
    score = 1;
  case 'Passeriformes'
    score = 1;
  otherwise
    fprintf(['warning from get_s_Hbp: order ', order , 'could not be identified: score = 1\n'])
    score = 1; info = 0;
end

s_Hbp = 10^(-3 + score * 2.7/8);
