%% legend_moll
% specification of a legend for mollusca

%
function legend = legend_moll
% created at 2016/04/28 by Bas Kooijman

  %% Syntax
  % legend = <legend_moll.m *legend_moll*>

  %% Description
  % Specifies a legend for mollusca
  %
  % Output
  %
  % * legend: (7,2) cell matrix with (marker, taxon)-pairs

  % type, size, linewidth, edge color and face color of a marker, taxon
  legend = {...
    {'o', 8, 3, [0 0 1], [0 0 0]}, 'Lophophorata'; ...
    {'o', 8, 3, [1 0 1], [1 0 1]}, 'Annelida'; ...
    {'o', 8, 3, [1 0 0], [0 0 1]}, 'Bivalvia'; ...
    {'o', 8, 3, [1 0 0], [1 0 1]}, 'Gastropoda'; ....
    {'o', 8, 3, [1 0 0], [1 0 0]}, 'Cephalopoda'; ....
    {'.', 16, 3, [0 0 1], [0 0 1]}, 'Spiralia'; ....
    {'.', 8, 3, [0 0 0], [0 0 0]}, 'Animalia'; ....
  };
end
