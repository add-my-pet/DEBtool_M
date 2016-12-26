%% legend_sauria
% specification of legend for archosauria

%
function legend = legend_sauria
% created at 2016/04/24 by Bas Kooijman

  %% Syntax
  % legend = <legend_sauria.m *legend_sauria*>

  %% Description
  % Specifies a legend for archosauria
  %
  % Output
  %
  % * legend: (10,2) cell matrix with (marker, taxon)-pairs

  % type, size, linewidth, edge color and face color of a marker, taxon
  legend = {...
    {'o', 8, 3, [0 0 0], [0 0 0]}, 'Crocodilia'; ...
    {'o', 8, 3, [0 0 1], [0 0 0]}, 'Pterosauria'; ...
    {'o', 8, 3, [0 0 1], [0 0 1]}, 'Ornithischia'; ...
    {'o', 8, 3, [1 0 1], [1 0 1]}, 'Sauropodomorpha'; ....
    {'o', 8, 3, [1 0 0], [0 0 1]}, 'Tyrannosauridae'; ....
    {'o', 8, 3, [1 0 0], [1 0 1]}, 'Archaeopterygidae'; ...
    {'o', 8, 3, [1 0 0], [1 0 0]}, 'Aves'; ....
    {'.', 8, 3, [0 0 0], [0 0 0]}, 'Synapsida'; ....
  };
end

