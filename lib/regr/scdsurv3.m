%% scdsurv2
%

%%
function [prob, dprob] = scdsurv2 (func, p, t, x, y)
  %  created: 2006/03/07 by Bas Kooijman
  
  %% Description
  % Routine called by scsurv3 to calculate numerical derivatives
  % 
  % Output
  %
  % * prob: (n*m,1)-matrix with death probabilities
  % * dprob:(n*m,l)-matrix with derivatives to l parameters, whose indices
  %   are listed in vector 'index', set by 'scsurv'

  global index  nt nx ny l;
  
  step = 1e-6;
  nxy = nx * ny; ntxy = nt * nxy;

  %% get survivor function values at evaluation point
  eval(['f = ', func, '(p, t, x, y);']);
  prob = f - [f(2:nt,:);zeros(1, nxy)]; % death probabilities
  prob = reshape(prob, ntxy, 1); 
  
  dprob = zeros(ntxy,l); % initiate jacobian
  for i = 1 : l % loop across parameters to be iterated
    % make step in a single parameter value
    q = p; q(index(i)) = p(index(i)) + step;
    %% get function values at changed parameter value
    eval(['g = ', func, '(q, t, x, y);']);
    g = (g - f)/step; % get derivatives
    g =  g - [g(2:nt,:); zeros(1, nxy)]; % diff of deriv. across time points
    dprob(:,i) = reshape(g, ntxy, 1);    
  end