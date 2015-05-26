function txt_taxa(x, y, taxa, col_taxa)
  % created 2013/08/28 by Bas Kooijman
  %
  %% Description
  %  Writes list of taxa names in a plot at a specified location
  %
  %% Input
  %  x: scalar with x-value of text in plot
  %  y: scalar with y-value of text in plot
  %  taxa: n- cell-vector with names of taxa
  %  col_taxa: (n,3)-matrix with RGB colors
  
  n = size(col_taxa,1);        % number of names
  ylim = get(gca, 'ylim');
  dy = (ylim(2) - ylim(1))/20; % scaling of ordinate values
  for i = 1:n % scan types
    text(x, y + dy * (n/2 - i), taxa{i}, 'color', col_taxa(i,:))
  end