function [prob, dprob] = scdsurv2 (func, p, t, y)
  %  created: 2002/02/08 by Bas Kooijman
  %  routine called by scsurv2 to calculate numerical derivatives
  %  prob: (n*m,1)-matrix with death probabilities
  %  dprob:(n*m,l)-matrix with derivatives to l parameters, whose indices
  %    are listed in vector 'index', set by 'scsurv2'

  global index  nt ny l;
  
  step = 1e-6;
  nty = nt*ny;

  %% get survivor function values at evaluation point
  eval(['f = ', func, '(p, t, y);']);
  prob = f - [f(2:nt,:);zeros(1, ny)]; % death probabilities
  prob = reshape(prob, nty, 1); 
  
  dprob = zeros(nty,l); % initiate jacobian
  for i = 1 : l % loop across parameters to be iterated
    %% make step in a single parameter value
    q = p; q(index(i)) = p(index(i)) + step;
    %% get function values at changed parameter value
    eval(['g = ', func, '(q, t, y);']);
    g = (g - f)/step; % get derivatives
    g =  g - [g(2:nt,:); zeros(1, ny)]; % diff of deriv. across time points
    dprob(:,i) = reshape(g, nty, 1);    
  end