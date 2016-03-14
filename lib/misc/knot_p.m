%% knot_p 
% calculates knot-coordinates of periodic cubic spline from knot-abcissa and data points

%%
function [xy, info] = knot_p  (x, data)
  %  Created: 2003/03/18 by  Bas Kooijman
  
  %% Syntax
  % [xy, info] <../knot_p.m *knot_p*> (x, data)

  %% Description
  % Calculates knot-coordinates of periodic cubic spline from knot-abcissa and
  %   data points according to weighted least squared criterium
  %   the spline is periodic; x(1), x(end) are start, end of period
  %
  % Input:
  %
  % * x: n-vector with knot-abcissa (n>3)
  % * data: (r,2) or (r,3)-matrix data points and weight coefficients (r>3)
  %
  % Output:
  %
  % * xy: (n,2)-matrix with knot-coordinates;
  %    xy(1,2) = dy(x(1)/dx, with assumption y(1) = y(end)
  % * info: scalar for failure (0) or success (1) of convergence
  
  %% Remarks
  % Meant to be used in combination with <../html/spline_p.html *spline_p*>.
  % See <../html/knot.html *knot*> for the non-periodic spline. 

  global X % transfer to fnknot_p

  x = x(:); nx = length(x);
  if nx < 4
    fprintf('number of knots must be at least 4\n');
    xy = []; info = 0; return
  end
    
  nrregr_options('report',0);
  X = x;
  [y dy] = spline1 (x, data); % initial value for knot ordinates
  %% prepend derivative at first and last point
  %% remove last y-value, because it equals the first one
  y = [(dy(1) + dy(nx))/ 2; y(2:nx)]; 
  
  [y, info] = nrregr('fnknot_p', y, data); % find knot ordinates
  xy = [x,y];
  if info ~= 1
      fprintf('no convergence\n');
  end
  
end

% %% subfunction

function f = fnknot_p(y, data)
  % created at 2003/03/18 by Bas Kooijman
  % subroutine for knot_p to find smoothing periodic spline ordinates
  global X

  f = spline_p(data(:,1),[X,y]);
end

