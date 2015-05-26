function plot_vector(data, line, marker)
  %  called from fig_9_2
  %  data: (n,4)-matrix with source and end coordinates of vector
  %  line: string that specifies line type and color, e.g '-b'
  %  marker: string that specifies marker type and color, e.g. '.g' (optional)
  
  hold on;
  r = size(data);
  for i = 1:r
      X = [data(i, 1); data(i, 1) + data(i, 3)];
      Y = [data(i, 2); data(i, 2) + data(i, 4)];
      plot(X, Y, line)
      if exist('marker','var') == 1
        plot(data(i,1), data(i,2), marker)
      end
  end