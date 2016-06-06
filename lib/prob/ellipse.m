%% ellipse
% Calculates the empirical survivor probabilities from a number of random trials

%%
function xy = ellipse(mu,sig,h,n)
  %  created 2005/10/01 by Bas Kooijman; modified 2008/08/08

  %% Syntax
  % xy = <../ellipse.m *ellipse*> (mu,sig,h,n)
  
  %% Description
  % Calculates the empirical survivor probabilities from a number of random trials
  %
  % Input:
  %
  % * mu: (1,2)-vector with coordinates of center
  % * sig: (2,2)-matrix with var-cov (must be symmetric, with pos diag)
  % * h: scalar with height of isocline of bivariate normal density
  %     as fraction of maximum height at center
  % * n: scalar with number of points. Optional; default value 100
  %
  % Output:
  %
  % * xy: (n,2)-matrix with x,y coordinates of points on ellipse
  %   i.e. solutions of h = (xy - mu) sig^-1 (xy - mu)^T
  %   coordinates of the last point equal that of the first

  if sig(1,1) < 0 | sig(2,2) < 0
    fprintf('No positive diagonal elements in cov matrix \n');
    xy = [];
    return
  end
  
  r = sig(1,2)/ sqrt(sig(1,1) * sig(2,2)); % corr coeff
  if r < -1 | r > 1 | abs(sig(1,2) - sig(2,1)) > 1e-3
    fprintf('No proper cov matrix \n');
    xy = [];
    return
  end

  if exist('n') == 0
    n = 100;
  end
  
  %% val = 1 + r * [1, -1]; % eigenvalues of corr-matrix
  [vec val] = eig(sig); % eigenvectors of corr-matrix
  Sig = vec' * sig * vec; % rotated cov matrix along principal axes
  c = - 2 * log(2 * pi * h * sqrt(1 - r^2));
  sdX = sqrt(Sig(1, 1)/ c); sdY = sqrt(Sig(2, 2)/ c); 

  phi = linspace(0, 2 * pi, n)'; % angles
  xy = [sdX * cos(phi), sdY * sin(phi)]; % ellipse
  xy = xy * vec'; % from principal components to original vars
  xy = xy + mu(ones(n,1), :); % back translated ellipse
