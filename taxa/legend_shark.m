%% legend_shark
% specification of a legend for shark

%
function legend = legend_shark
% created at 2016/09/05 by Bas Kooijman

  %% Syntax
  % legend = <legend_shark.m *legend_shark*>

  %% Description
  % Specifies a legend for shark
  %
  % Output
  %
  % * legend: (6,2) cell matrix with (marker, taxon)-pairs

  % type, size, linewidth, edge color and face color of a marker, taxon
  legend = {...
    {'o', 3, 3, [0 0 0], [0 0 0]}, 'Holocephali'; ...
    {'o', 3, 3, [0 0 1], [0 0 1]}, 'Batoidea'; ...
    {'o', 8, 3, [1 0 0], [0 0 1]}, 'Galeomorphi'; ....
    {'o', 8, 3, [1 0 0], [0 0 1]}, 'Squatiniformes'; ....
    {'o', 8, 3, [1 0 0], [0 1 0]}, 'Pristiophoriformes'; ....
    {'o', 8, 3, [1 0 0], [1 0 0]}, 'Squaliformes'; ....
    {'o', 8, 3, [1 0 0], [1 0 1]}, 'Hexanchiformes'; ....
  };
end
