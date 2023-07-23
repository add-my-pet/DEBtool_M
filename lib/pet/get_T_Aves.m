%% get_T_Aves
% get body temperature of a bird order
%%
function T = get_T_Aves(order)
% created 2023/07/22 by Bas Kooijman

%% Syntax
% T = <get_T_Aves  *get_T_Aves*>(order)

%% Description
% get the typical body temperature of a bird order based on PrinPres1991.
% They are thought to apply post-natal or post-fledging; embryos are ectothermic.
% Mean embryo body temperature depends on environmental conditions and parental care.
%
% bibkey = 'PrinPres1991'; type = 'Article'; bib = [ ... 
% 'doi = {10.1016/0300-9629(91)90122-S}, ' ...
% 'author = {R. Prinzinger and A.Pre{\ss}mar and E. Schleucher}, ' ... 
% 'year = {1991}, ' ...
% 'title = {BODY TEMPERATURE IN BIRDS}, ' ...
% 'journal = {Comp. Biochem. Physiol.}, ' ...
% 'volume = {99A(4)}, ' ...
% 'pages = {499-506}'];
% metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
% Input:
%
% * order: character string with name of bird order, as accepted by AmP
%
% Output:
%
% T: scalar with typical body temperature in C

%% Remarks
% PrinPres1991 lists 26 of the 45 orders that are presently recognized.
% The remaining temperatures are copied from orders to which they belonged in 1991.
% The Phoenicopteriformes and the now-related Podicipediformes made wild taxonomic associations over the years;
% This also applies to the Opisthocomiformes. 
% The Falconiformes, splitted of the Accipitriformes, Cariamiformes and Cathartiformes and associated with the Psittaciformes.
% The Trogoniformes and Leptosomiformes are now more associated with the Coliiformes. 
% What this means in terms of typical body temperature is not certain.

%% Example
% get_T_Aves('Coliiformes')

Torder = { ...
  40.0  'Accipitriformes'    % copied from Falconiformes   
  39.7  'Aegotheliformes'    % copied from Caprimulgiformes   
  41.3  'Anseriformes'       
  38.1  'Apodiformes'        % incl Trochiliformes 38.1; Apodiformes 40.0
  38.3  'Apterygiformes'     
  40.0  'Bucerotiformes'     % copied from Coraciiformes    
  39.7  'Caprimulgiformes'   
  40.0  'Cariamiformes'      % copied from Falconiformes     
  38.8  'Casuariiformes'     
  40.0  'Cathartiformes'     % copied from Falconiformes    
  40.9  'Charadriiformes'    
  40.5  'Ciconiiformes'      
  39.5  'Coliiformes'        
  40.9  'Columbiformes'      
  40.0  'Coraciiformes'      
  41.3  'Cuculiformes'       
  40.4  'Eurypygiformes'     % copied from Gruiformes    
  40.0  'Falconiformes'      
  41.4  'Galliformes'        
  39.3  'Gaviiformes'        
  40.4  'Gruiformes'         
  39.5  'Leptosomiformes'    % copied from Coliiformes   
  41.3  'Mesitornithiformes' % copied from Cuculiformes
  41.3  'Musophagiformes'    % copied from Cuculiformes
  40.0  'Nyctibiiformes'     % copied from Apodiformes   
  41.3  'Opisthocomiformes'  % copied from Cuculiformes 
  40.4  'Otidiformes'        % copied from Gruiformes       
  41.6  'Passeriformes'      
  40.6  'Pelecaniformes'     
  40.9  'Phaethontiformes'   % copied from Charadriiformes 
  39.5  'Phoenicopteriformes'% copied from Podicipediformes (?)
  41.8  'Piciformes'         
  39.7  'Podargiformes'      % copied from Caprimulgiformes     
  39.5  'Podicipediformes'   
  39.4  'Procellariiformes'  
  41.3  'Psittaciformes'     
  40.9  'Pteroclidiformes'   % copied from Columbiformes  
  39.3  'Rheiformes'         % copied from Struthioniformes        
  38.2  'Sphenisciformes'    
  39.7  'Steatornithiformes' % copied from Caprimulgiformes
  40.2  'Strigiformes'       
  39.3  'Struthioniformes'   
  40.6  'Suliformes'         % copied from Pelecaniformes       
  40.4  'Tinamiformes'       
  40.0  'Trogoniformes'      % copied from Coraciiformes     
};
T = Torder{strcmp(order, Torder(:,2)),1};

