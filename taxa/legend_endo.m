%% legend_endo
% specification of a legend for endotherms

%
function legend = legend_endo
% created at 2016/04/23 by Bas Kooijman

  %% Syntax
  % legend = <legend_endo.m *legend_endo*>

  %% Description
  % Specifies a legend for endotherms
  %
  % Output
  %
  % * legend: (7,2) cell matrix with (marker, taxon)-pairs

  % type, size, linewidth, edge color and face color of a marker, taxon
  legend = {...
    {'o', 8, 3, [0 0 1], [0 0 0]}, 'Prototheria'; ...
    {'o', 8, 3, [0 0 1], [0 0 1]}, 'Marsupialia'; ...
    {'o', 8, 3, [0 0 1], [1 0 1]}, 'Placentalia'; ...
    {'o', 8, 3, [1 0 0], [0 0 0]}, 'Crocodilia'; ...
    {'o', 8, 3, [1 0 0], [1 0 0]}, 'Paleognathae'; ...
    {'o', 8, 3, [1 0 0], [1 .5 .5]}, 'Neognathae'; ...
    {'.', 8, 3, [0 0 0], [0 0 0]}, 'Animalia'; ....
  };
end
