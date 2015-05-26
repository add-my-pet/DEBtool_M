function plot3_vector(data, line, marker)
  %  called from fig_9_4
  %  data: (n,6)-matrix with source and end coordinates of vector
  %  line: string that specifies line type and color, e.g '-b'
  %  marker: string that specifies marker type and color, e.g. '.g' (optional)
  
  hold on;
  [r, k] = size(data);
  for i = 1:r
      X = [data(i, 1); data(i, 1) + data(i, 4)];
      Y = [data(i, 2); data(i, 2) + data(i, 5)];
      Z = [data(i, 3); data(i, 3) + data(i, 6)];
      plot3(X, Y, Z, line)
      if exist('marker','var') == 1
        plot(data(i,1), data(i,2), data(i,3), marker)
      end
  end