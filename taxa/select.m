%% select
% gets list of species that belongs to a taxon

%%
function species = select(taxon)
% created 2015/09/18 by Bernd Brandt

%% Syntax
% species = <../select.m *select*> (taxon) 

%% Description
% gets all species in the add_my_pet collection that belong to a particular taxon.
%
% Input:
%
% * character string with name of taxon
%
% Output:
% 
% * cell string with all species in the add_my_pet collection that belong to that taxon

%% Remarks
% The root is Animalia. 
% If chosen as taxon, an ordered list of all species in the collection results.
% The classification follows that of Wikipedia

%% Example of use
% species  = select('Animalia')

  species = textscan(perl('select.pl', taxon), '%s'); 
  species = species{1};
end

