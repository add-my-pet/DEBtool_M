%% spline1
% Calculates ordinates and first derivatives of a first order spline

%%
function [y, dy, index] = spline1(x, knots, Dy1, Dyk)
  %  created at 2007/03/29 by Bas Kooijman; modified 2009/09/29
  
  %% Syntax
  % [y, dy, index] <../spline1.m *spline1*>(x, knots, Dy1, Dyk)

  %% Description
  % First order splines connect knots by straight lines, and is linear outside the knots.
  % Calculates the ordinates and the first derivatives of a first order spline, given abcissa and knot coordinates. 
  % The spline is interpolating. 
  %
  % Input:
  %
  % * x: n-vector with abcissa values
  % * knots: (nk,2)-matrix with coordinates of knots; we must have nk > 3; 
  %         knots(:,1) must be ascending
  % * Dy1: scalar with first derivative at first knot (optional); 
  %       empty means: zero
  % * Dyk: scalar with first derivative at last knot (optional); 
  %       empty means: zero
  %
  % Ouput:
  %
  % * y: n-vector with spline values (ordinates)
  % * dy: n-vector with derivatives
  % * index: n-vector with indices of first knot-abcissa smaller than x
  
  %% Remarks
  % cf <../html/islpine1.html *ispline1*> for integration;
  %    <../html/rspline1.html *rspline1*> for roots;
  %    <../html/espline1.html *espline1*> for local extremes.
  
  %% Example of use
  % x = (1:10)'; y = 3*(x+.1*rand(10,1)).^2; [Y, dY] = spline1([x,y],k); iY = ispline1(x,k); rspline1(k,5). 
  % See <../mydata_smooth.m *mydata_smooth*> for further illustration. 

  x = x(:); nx = length(x); nk = size(knots,1);
  y = zeros(nx,1); dy = y; index = zeros(nx,1); % initiate output
  
  if exist('Dy1','var') == 0 % make sure that left clamp is specified
    Dy1 = 0;
  end
  if exist('Dyk','var') == 0 % make sure that right clamp is specified
    Dyk = 0; 
  end

  % derivatives right of knot-abcissa
  Dy =[(knots(2:nk,2) - knots(1:nk-1,2)) ./ ...
       (knots(2:nk,1) - knots(1:nk-1,1)); Dyk];
  for i = 1:nx % loop across abcissa values
    j = 1;
    while x(i) > knots(min(nk,j),1) && j <= nk
      j = j + 1;
    end
    j = j - 1;
    if j == 0      
      y(i) = knots(1,2) - Dy1 * (knots(1,1) - x(i));
      dy(i) = Dy1;
    else
      y(i) = knots(j,2) - Dy(j) * (knots(j,1) - x(i));
      dy(i) = Dy(j);
    end
    index(i) = j;
  end
