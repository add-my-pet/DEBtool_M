function [prob, dprob] = nrdsurv (func, p)
  %  created: 2002/02/08 by Bas Kooijman
  %
  %  routine called by nrsurv to calculate numerical derivatives
  %  prob: (n,1) vector with death probabilities (catenated across data sets)
  %  dprob: (n,l) matrix with Jacobian (catenated across data sets)

  global index l n ntn listt listtn listf listg;
  eval(['global ', listt,';']); % make data sets global (set in 'nrsurv')

  %  index: parameter indices that are iterated
  %  l: number of parameters that are iterated
  %  n: number of data points per data set
  %  ntn: number of data sets
  %  listtn: a character-string with 'tn1, tn2 ...'
  %  listf: a character-string with 'f1, f2 ...'
  %  listg: a character-string with 'g1, g2 ...'

  step = 1e-6; % step in parameter values for numerical differentiation
  ntot = sum(n); % tot number of time intervals

  % get survivor function values at evaluation point
  prob = zeros(ntot,1);
  eval(['[', listf,'] = ', func, '(p,', listtn,' );']);
  if ntn == 1
    prob = f1 - [f1(2:n(1));0]; % death probabilities
  else % catenate in the case of multiple samples
    cn = 0;
    for i = 1:ntn
      ci = num2str(i);
      eval(['prob((1:n(', ci, ')) + cn,1) = f', ci, ...
	    '- [f', ci, '(2:n(', ci, '),1);0];']);
      cn = cn + n(i)-1;
    end	    
  end
  
  dprob = zeros(ntot,l); % initiate jacobian
  for i = 1 : l % loop across parameters to be iterated
    % make step in a single parameter value
    q = p; q(index(i)) = p(index(i)) + step;
    % get function values at changed parameter value
    eval(['[', listg, '] = ', func, '(q, ', listtn,');']);
    for j = 1:ntn % loop across data sets
      cj = num2str(j);
      eval(['g', cj, ' = (g', cj, ' - f', cj, ')/step;']); % get derivatives
      eval(['g', cj, ' =  g', cj, ' - [g', cj, ...
	    '(2:n(', cj, '));0];']); % diff of deriv. across time points
    end
    if ntn == 1 % single data set
      dprob(:,i) = g1;
    else % catenate in case of more data sets
      eval(['dprob(:,i) = cat(1,', listg, ');']);
    end
    
  end