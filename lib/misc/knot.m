%% knot
% calculates knot-coordinates of cubic spline from knot-abcissa and data points

%%
function [xy, info] = knot(x, data, Dy1, Dyk)
  %  Created: 2002/05/25 by  Bas Kooijman, modified 2006/08/11
  
  %% Syntax
  % [xy, info] <../knot.m *knot*> (x, data, Dy1, Dyk)

  %% Description
  % Calculates knot-coordinates of cubic spline from knot-abcissa and
  %    data points according to weighted least squared criterium
  %
  % Input
  %
  % * x: n-vector with knot-abcissa (n>3)
  % * data: (r,2) or (r,3)-matrix data points and weight coefficients (r>3)
  % * Dy1: scalar with first derivative at first knot (optional);
  %       empty means: no specification and second derivative equals 0
  % * Dyk: scalar with first derivative at last knot (optional);
  %       empty means: no specification and second derivative equals 0
  %
  % Output
  %
  % * xy: (n,2)-matrix with knot-coordinates
  
  %% Remarks
  % See <../html/knot_p.html *knot_p*> for the periodic spline. 


  global X DY1 DYk % transfer to fnknot

  x = x(:); nx = length(x);
  if nx < 4
    printf('number of knots must be at least 4\n');
    xy = []; return
  end
  
  if exist('Dy1', 'var') == 0 % make sure that left clamp is specified
    Dy1 = []; % no left clamp; second derivative at first knot is zero
  end
  if exist('Dyk', 'var') == 0 % make sure that right clamp is specified
    Dyk = []; % no right clamp; second derivative at last knot is zero
  end
  X = x; DY1 = Dy1; DYk = Dyk; % for export to 'fnknot'
  
  nrregr_options('report',0); [Y,ix] = unique(data(:,1)); Y = data(ix,:);
  y = spline1 (x, Y); % initial value for knot ordinates
  [y, info] = nrregr('fnknot', y, data); % find knot ordinates
  xy = [x,y(:,1)];
  
  if info ~= 1
    fprintf('no convergence\n');
  end
  
  nrregr_options('report',1);
end

