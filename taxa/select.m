%% select
% gets list of species that belongs to a taxon

%%
function species = select(taxon)
% created 2015/09/18 by Bernd Brandt
% modified 2015/10/07 by Dina Lika; 2016/11/08 by Bas Kooijman

%% Syntax
% species = <../select.m *select*> (taxon) 

%% Description
% gets all species in the add_my_pet collection that belong to a particular taxon.
%
% Input:
%
% * taxon: optional character string with name of taxon (default: 'Animalia')
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

  if ~exist('taxon', 'var')
    taxon = 'Animalia';
  end
  
  WD = pwd;                % store current path
  taxa = which('select');  % locate DEBtool_M/taxa/
  taxa = taxa(1:end - 8);  % path to DEBtool_M/taxa/
  cd(taxa)                 % goto taxa
  
  try
    species = textscan(perl('select.pl', taxon), '%s'); 
    species = species{1};
  catch
    disp('Name of taxon is not recognized')
  end
  
  cd(WD)                   % goto original path
  
  if ~0 == sum(cellfun(@isempty, strfind(species,'_')))
    fprintf('Warning from select: not all cells are entry names\n')
  end
end

