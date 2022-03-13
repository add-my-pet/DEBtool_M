%% spline1
% Calculates ordinates and first derivatives of a first order spline

%%
function [y, dy, index] = spline1(x, knots, Dy1, Dyk)
  %  created at 2007/03/29 by Bas Kooijman; modified 2009/09/29, modified 2022/02/11, 2022/03/04
  
  %% Syntax
  % [y, dy, index] <../spline1.m *spline1*>(x, knots, Dy1, Dyk)

  %% Description
  % First order splines connect knots by straight lines, and is linear outside the knots.
  % Calculates the ordinates and the first derivatives of a first order spline, given abcissa and knot coordinates. 
  % The spline is interpolating. The knot-matrix can have 2 or more columns 
  %
  % Input:
  %
  % * x: n-vector with abcissa values
  % * knots: (nr,nc)-matrix with coordinates of knots; we must have nk > 3 and nc >1; 
  %         knots(:,1) must be ascending
  % * Dy1: scalar with first derivative at first knot (optional); 
  %       absent means: zero; empty means derivative as for first knot
  % * Dyk: scalar with first derivative at last knot (optional); 
  %       absent means: zero; empty means derivative as for last knot
  %
  % Ouput:
  %
  % * y: (n,nc-1)-matrix with spline values (ordinates)
  % * dy: (n,nc-1)-matrix with derivatives
  % * index: n-vector with indices of first knot-abcissa smaller than x
  
  %% Remarks
  % cf <../html/islpine1.html *ispline1*> for integration;
  %    <../html/rspline1.html *rspline1*> for roots;
  %    <../html/espline1.html *espline1*> for local extremes.
  
  %% Example of use
  % x = (1:10)'; y = 3*(x+.1*rand(10,1)).^2; [Y, dY] = spline1([x,y],k); iY = ispline1(x,k); rspline1(k,5). 
  % See <../mydata_smooth.m *mydata_smooth*> for further illustration. 

  x = x(:); nx = length(x); nr = size(knots,1); nc = size(knots,2)-1; % # of dim
  y = zeros(nx,nc); dy = y; index = zeros(nx,nc); % initiate output
  
  if exist('Dy1','var') == 0 % make sure that left clamp is specified
    Dy1 = zeros(1,nc);
  end
  if exist('Dyk','var') == 0 % make sure that right clamp is specified
    Dyk = zeros(1,nc); 
  end
  if isempty(Dy1)
    Dy1 = (knots(2,2:end) - knots(1,2:end))./(knots(2,ones(1,nc)) - knots(1,ones(1,nc)));
  end
  if isempty(Dyk)
    Dyk = (knots(nr,2:end) - knots(nr-1,2:end))./(knots(nr,ones(1,nc)) - knots(nr-1,ones(1,nc)));
  end

  % derivatives right of knot-abcissa
  Dy =[(knots(2:nr,2:end) - knots(1:nr-1,2:end)) ./ ...
       (knots(2:nr,ones(1,nc)) - knots(1:nr-1,ones(1,nc))); Dyk];
  for i = 1:nx % loop across abcissa values
    j = 1;
    while x(i) > knots(min(nr,j),1) && j <= nr
      j = j + 1;
    end
    j = j - 1;
    if j == 0      
      y(i,:) = knots(1,2:end) - Dy1 * (knots(1,1) - x(i));
      dy(i,:) = Dy1;
    else
      y(i,:) = knots(j,2:end) - Dy(j,:) * (knots(j,1) - x(i));
      dy(i,:) = Dy(j);
    end
    index(i) = j;
  end
