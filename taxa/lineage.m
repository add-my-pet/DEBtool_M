%% classify
% gets list of taxa to which a taxon belongs

%%
function classification = lineage(taxon)
% created 2015/09/18 by Bernd Brandt

%% Syntax
% classification = <../lineage.m *lineage*> (taxon) 

%% Description
% gets all taxa in the add_my_pet collection to which a particular taxon belongs
%
% Input:
%
% * character string with name of taxon
%
% Output:
% 
% * cell string of ordered taxa to which that taxon belongs, starting with Animalia

%% Remarks
% The root is Animalia. 
% The classification follows that of Wikipedia

%% Example of use
% classification  = lineage('Gorilla_gorilla')

  classification = textscan(perl('lineage.pl', taxon), '%s'); 
  classification = classification{1};
end

