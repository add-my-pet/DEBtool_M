%% lineage
% gets all species that are closest related to specified taxa

%%
function [members, taxon] = clade(taxa)
% created 2015/09/18 by Bas Kooijman

%% Syntax
% members = <../clade.m *clade*> (taxa) 

%% Description
% gets all species in the add_my_pet collection that belong to the lowest common taxon of a group of taxa
%
% Input:
%
% * cell string with names of taxa
%
% Output:
% 
% * cell string with all species in the add_my_pet collection that belong to that taxon
% * character string with the name of the lowest taxon all taxa belong

%% Remarks
% The root is Animalia. 
% If this is the lowest common taxon, the output contains all species in the collection.
% The classification follows that of Wikipedia

%% Example of use
% members  = clade({'Gorilla', 'Tupaia'})

  n = length(taxa);
  
  for i = 1:n % obtain lineages for all taxa
    lin = lineage(taxa{i});
    if ~isequal('Animalia', lin{1})
      fprintf([taxa{i}, ' is not recognized \n']);
      members = []; taxon = []; return
    end
    eval(['lin', num2str(i), ' = lin;']);
  end
  
  true = 1; j = 0;
  while true
    j = j + 1; % step down the lineage
    lower_taxon = lin1{j};
    for i = 2 : n % step through taxa
      eval(['true = isequal(lower_taxon, lin', num2str(i), '{j});']);
      if ~true
          break
      end
    end
    if true
      taxon = lower_taxon;
    end
  end
  
  members = select(taxon); 
  
end

