%% pedigree
% gets classification tree of a taxon

%%
function tree = pedigree(taxon)
% created 2015/09/18 by Bernd Brandt

%% Syntax
% tree = <../pedigree.m *pedigree*> (taxon) 

%% Description
% gets a tree of all species in the add_my_pet collection that belong to a particular taxon
%
% Input:
%
% * character string with name of taxon
%
% Output:
% 
% * character string with a tree of all species in the add_my_pet collection that belong to that taxon

%% Remarks
% The root is Animalia. 
% If chosen as taxon, an tree of all species in the collection results.
% The classification follows that of Wikipedia

%% Example of use
% tree  = pedigree('Animalia')

  tree = perl('pedigree.pl', taxon); 
  
end

