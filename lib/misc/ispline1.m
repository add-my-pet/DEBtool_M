function Y = ispline1(x, knots, Dy1, Dyk)
  %  created at 2007/03/29 by Bas Kooijman
  %
  %% Description
  %  calculates interal over a first-order spline
  %  works similar to spline1 but gives a single n-vector with integrated values of the cubic spline. 
  %  The first element is zero by definition. 
  %
  %% Input
  %  x: n-vector with abcissa; must be ascending; n > 1
  %  knots: (r,2)-matrix with coordinates of knots;
  %         knots(:,1) must be ascending
  %  Dy1: scalar with first derivative at first knot (optional)
  %       empty means: no specification and second derivative equals 0
  %  Dyk: scalar with first derivative at last knot (optional)
  %       empty means: no specification and second derivative equals 0
  %
  %% Output
  %  Y: n-vector with integrated spline values
  %     Y(1) = 0 by definition
  %
  %% Example of use
  %  see mydata_smooth

  x = x(:); nx = length(x); nk = size(knots,1); Y = zeros(nx,1);

  if exist('Dy1','var') == 0 % make sure that left clamp is specified
    Dy1 = 0; 
  end
  if exist('Dyk','var') == 0 % make sure that right clamp is specified
    Dyk = 0;
  end

  [y, dy, ind] = spline1(x, knots, Dy1, Dyk);
  %% cumulative integration between knot abcissa
  cs = cumsum([0;(knots(2:nk,1) - knots(1:nk-1,1)) .* ...
      (knots(2:nk,2) + knots(1:nk-1,2))/ 2]);
  for i = 2:nx
      Y(i) = Y(i - 1);
      if ind(i) == ind(i - 1) 
        Y(i) = Y(i) + (x(i) - x(i - 1)) * (y(i) + y(i - 1))/ 2;
      else
        Y(i) = Y(i) + (knots(1 + ind(i - 1),1) - x(i - 1)) * ...
            (knots(1 + ind(i - 1),2) + y(i - 1))/ 2;
        Y(i) = Y(i) + (x(i) - knots(ind(i),1)) * ...
            (y(i) + knots(ind(i),2))/ 2;
        if ind(i) > ind(i - 1) + 1
           Y(i) = Y(i) + cs(ind(i)) - cs(max(1,ind(i-1)));
        end
      end
  end