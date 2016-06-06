%% lineage
% gets all species that are closest related to specified taxa

%%
function [members, taxon] = clade(taxa)
% created 2015/09/18 by Bas Kooijman

%% Syntax
% members = <../clade.m *clade*> (taxa) 

%% Description
% gets all species in the add_my_pet collection that belong to the lowest common taxon of a group of taxa.
% To find this taxon, the lineages of all members of input taxa are obtained, 
% then the taxon of lowest rank is found that is shared by all members of input taxa 
% and all members of this taxon in the add_my_pet collection are selected.
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
% If the input cell string has length 1, clade is similar to <select.html *select*>.
% The classification follows that of Wikipedia.

%% Example of use
% members  = clade({'Gorilla', 'Tupaia'})


  n = length(taxa);
  
  for i = 1:n % obtain lineages for all taxa called lin1, lin2, ..
    lin = lineage(taxa{i});
    if ~isequal('Animalia', lin{1})
      fprintf([taxa{i}, ' is not recognized \n']);
      members = []; taxon = []; return
    end
    eval(['lin', num2str(i), ' = lin;']);
  end
  
  if n == 1 % nothing to compare with
    taxon = taxa{1};
  else      % n > 1
    true = 1; j = 0; % initiate selection process
    while true
      j = j + 1; % step down the lineage
      taxon = lin1{j};
      for i = 2 : n % step through taxa
        eval(['true = isequal(taxon, lin', num2str(i), '{j});']);
        if ~true
          break
        end
      end
    end
    taxon = lin1{j-1};
  end 
  
  members = select(taxon); 

end

