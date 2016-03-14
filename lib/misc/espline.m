%% espline
% finds all local extremes of a cubic spline

%%
function [xy_min, xy_max , info] = espline(xy, Dy1, Dyk)
  % created at 2007/04/01 by Bas Kooijman
  
  %% Syntax
  % [xy_min, xy_max , info] = <../espline.m *espline*> (xy, Dy1, Dyk)

  %% Description
  % The function espline finds all local extremes of a cubic spline. 
  % It does so by getting prior estimates using rspline1 applied to the derivatives of the spline, followed by a Newton Raphson procedure.
  %
  % Input:
  %
  % * xy: (r,2)-matrix with knots (r>3)
  %
  % Output:
  %
  % * xy_min: (n_min,2)-matrix with (x,y)-values of local minima
  % * xy_max: (n_max,2)-matrix with (x,y)-values of local maxima
  % * info: 1 = successful, 0 if not
  
  %% Remarks
  % cf <spline.html *spline*>
  
  %% Example of use
  % See <../mydata_smooth.m *mydata_smooth*>
  
  n = size(xy,1); 
  if n < 4
    fprintf('number of knots must be at least 4\n');
    xy_min = []; xy_max = []; info = 0; return
  end
  
  if ~exist('Dy1','var') % make sure that left clamp is specified
    Dy1 = []; % no left clamp; second derivative at first knot is zero
  end
  if ~exist('Dyk','var') % make sure that right clamp is specified
    Dyk = []; % no right clamp; second derivative at last knot is zero
  end
  
  x = linspace(xy(1,1),xy(n,1),10 * n)';
  [y, dy] = spline(x, xy, Dy1, Dyk);
  x = rspline1([x,dy]);
  nx = length(x);
  info = 1;
  for i = 1:nx
      % Newton Raphson loop to make preliminary estimates more precise
      j = 1; % initiate counter
      dy = 1; % make sure to start nr-procedure
      while dy^2 > 1e-10 & j < 10
          [y, dy, ddy] = spline(x(i), xy, Dy1, Dyk);
          x(i) = x(i) - dy/ ddy;
          j = j + 1;
      end
      if j == 10;
          info = 0;
          fprintf('no convergence\n');
      end
  end
  [y, dy, ddy] = spline(x, xy, Dy1, Dyk);
  xy_min = [x, y]; xy_min(ddy < 0,:) = [];
  xy_max = [x, y]; xy_max(ddy > 0,:) = [];