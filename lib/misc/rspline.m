function [x, info] = rspline(knots, Dy1, Dyk, y)
  %  recreated at 2007/04/01 by Bas Kooijman, modified 2009/10/25
  %
  %% Description
  %  Calculates real roots x of cubic spline(x) = y, given y
  %  It does so by getting prior estimates using rspline1, followed by a Newton Raphson procedure. 
  %
  %% Input
  %  knots: (r,2)-matrix with coordinates of knots; r>3
  %         knots(:,1) must be ascending
  %  Dy1: scalar with first derivative at first knot (optional)
  %       empty means: no specification and second derivative equals 0
  %  Dyk: scalar with first derivative at last knot (optional)
  %       empty means: no specification and second derivative equals 0
  %  y: scalar with spline value (optional, default is 0)
  %
  %% Output
  %  x: vector with real roots (maximum length 3 * r - 1)
  %  info: 1 if successsful, 0 if not
  %
  %% Example of application
  %  see mydata_smooth
  
  if exist('y','var') == 0
    y = 0;
  end
  knots(:,2) = knots(:,2) - y; nk  = size(knots,1);

  if nk < 4
    fprintf('number of knots must be at least 4\n');
    x = []; return
  end

  if exist('Dy1','var') == 0 % make sure that left clamp is specified
    [y1, Dy1] = spline(knots(1,1), knots);
  end
  if exist('Dyk','var') == 0 % make sure that right clamp is specified
    [yk, Dyk] = spline(knots(nk,1), knots);
  end

  X = linspace(knots(1,1), knots(nk,1), 10 * nk)';
  x = rspline1([X, spline(X, knots, Dy1, Dyk)], Dy1, Dyk, 0);
  info = 1;
  if isempty(x)
    return
  end
  % Newton Raphson loop to make preliminary estimates more precise
  j = 1; % initiate counter
  f = 1; % make sure to start nr-procedure
  while f' * f > 1e-10 && j < 10
    [f, df] = spline(x, knots);
    x = x - f ./ df;
    j = j + 1;
  end
  if j == 10;
    info = 0;
    fprintf('rspline warning no convergence \n');
  end