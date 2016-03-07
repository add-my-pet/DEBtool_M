%% list_taxa
% gets ordered list of all taxa

%%
function ol = list_taxa (taxon)
% created 2016/02/25 by Bas Kooijman

%% Syntax
% ol = <../list_taxa.m *list_taxa*> (taxon) 

%% Description
% gets an alphabetically ordered list of all taxa that belong to taxon in the add_my_pet collection 
%
% Output:
% 
% * taxon: optional chracterstrin with name of taxon (default 'Animalia')
%
% Output:
% 
% * ordered list

%% Remarks
% The classification follows that of Wikipedia

%% Example of use
% ol  = list_taxa

  if ~exist('taxon', 'var')
    taxon = 'Animalia';
  end

  WD = pwd;                  % store current path
  taxa = which('list_taxa'); % locate DEBtool_M/taxa/
  taxa = taxa(1:end - 11);   % path to DEBtool_M/taxa/
  cd(taxa)                   % goto taxa

  try
    ol = perl('list_taxa.pl', taxon); ol(end) = [];
    ol = eval(['{''', strrep(ol, char(10), ''';''') , '''}']);
  catch
    disp('taxon not recognized')
  end
  
  cd(WD)                    % goto original path

end

