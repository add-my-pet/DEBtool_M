%% rspline1
% real roots x of first-order spline(x) = y, given y

%%
function x = rspline1(knots, Dy1, Dyk, y)
  % created at 2007/03/28 by Bas Kooijman; modified 2011/08/15
  
  %% Syntax
  % x = <../rspline1.m *rspline1*> (x, knots, Dy1, Dyk)

  %% Description
  % Calculates real roots x of first-order spline(x) = y, given y
  %
  % Input:
  %
  % * knots: (r,2)-matrix with coordinates of knots; r>3;
  %         knots(:,1) must be ascending
  % * Dy1: scalar with first derivative at first knot (optional);
  %       empty means: no specification and second derivative equals 0
  % * Dyk: scalar with first derivative at last knot (optional);
  %       empty means: no specification and second derivative equals 0
  % * y: scalar with function value (optional, default is 0)
  %
  % Output:
  %
  % * x: vector with real roots 
  
  %% Remarks
  % cf <../html/islpine1.html *spline1*> for first order spline;
  %    <../html/islpine1.html *ispline1*> for integration;
  %    <../html/espline1.html *espline1*> for local extremes.

  %% Example of use
  % See <../mydata_smooth.m *mydata_smooth*>

  nk  = size(knots,1);
  if exist('y','var') == 0
    y = 0;
  end  
  if exist('Dy1','var') == 0 % make sure that left clamp is specified
    Dy1 = 0; % no left clamp; second derivative at first knot is zero
    if knots(1,2) == y
      x = NaN;
      fprintf('warning in rspline1: infinite number of roots\n')
      return
    end
  end
  if exist('Dyk','var') == 0 % make sure that right clamp is specified
    Dyk = 0; % no right clamp; second derivative at last knot is zero
    if knots(nk,2) == y
      x = NaN;
      fprintf('warning in rspline1: infinite number of roots\n')
      return
    end
  end


  knots(:,2) = knots(:,2) - y; 
 
  if (knots(1,2) < 0 && Dy1 < 0) || (knots(1,2) > 0 && Dy1 > 0)
      x = knots(1,1) - knots(1,2)/ Dy1;
  else
      x = [];
  end
  for i = 1:nk - 1
      if (knots(i,2) < 0 && knots(i + 1,2) > 0) || (knots(i,2) > 0 && knots(i + 1,2) < 0)
          dknot = knots(i + 1,:) - knots(i,:);
          x = [x; knots(i,1) - knots(i,2) * dknot(1)/ dknot(2)];
      end
  end
  if knots(nk,2) < 0 && Dyk > 0 || knots(nk,2) > 0 && Dyk < 0
      x = [x; knots(nk,1) - knots(nk,2)/ Dyk];
  end