function [f, df] = nrdregr2 (func, p, x, y)
  %  created: 2001/09/13 by Bas Kooijman, modified 2010/05/08
  %
  %  routine called by nrregr2 to calculate numerical derivatives
  %
  %% Output
  %  f: (n,m)-matrix with function evaluations
  %  df:(n*m,l)-matrix with derivatives to l parameters, whos indices
  %    are listed in vector 'index', set by 'nrregr'

  global index nxy n_pars;
  
  step = 1e-6;
  eval(['f = ',func,'(p, x, y);']);
  df = zeros(nxy, n_pars);
  for i = 1 : n_pars
    q = p; q(index(i)) = p(index(i)) + step;
    eval(['g =', func,'(q, x, y);']);
    df(:,i) = reshape((g - f)/ step, nxy, 1);
  end