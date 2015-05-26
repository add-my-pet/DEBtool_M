%% nrdregr
% Routine called by nrregr to calculate numerical derivatives

%%
function [f, df] = nrdregr (func, p)
  % created: 2001/09/07 by Bas Kooijman, modified 2010/10/10
  
  %% Syntax 
  % [f, df] = <../nrdregr.m *nrdregr*> (func, p)
  
  %% Description
  % Routine called by nrregr to calculate numerical derivatives%
  %
  % Input
  %
  % * f: (n,1) vector with function evaluations
  % * df: (n,l) matrix with Jacobian;
  %    results from all data sets are catenated in f and df

  global index nxyw listx listxyw listf listg global_txt
  
  eval(global_txt); % make data sets global (set in 'nrregr')

  %  index: parameter indices that are iterated
  %  nxyw: number of data sets
  %  listxyw: a character-string with 'xyw1, xyw2 ...'
  %  listf: a character-string with 'f1, f2 ...'
  %  listg: a character-string with 'g1, g2 ...'

  step = 1.05; % step factor in parameter values for numerical differentiation

  %  get function values at evaluation point
  eval(['[', listf,'] = ', func, '(p,', listxyw,');']); f = f1;
  if nxyw > 1 % catenate in the case of multiple samples
    for i = 2:nxyw
      eval(['f = [f; f', num2str(i), '];']);
    end	    
  end
  n = length(f); % total number of data points
  l = length(index); % number of parameters that are iterated
  
  df = zeros(sum(n),l); % initiate jacobian
  for i = 1 : l % loop across parameters to be iterated
    % make step in a single parameter value
    q = p; q(index(i)) = p(index(i)) * step;
    % get function values at changed parameter value
    eval(['[', listg, '] = ', func, '(q, ', listxyw,');']); g = g1;
    
    if nxyw > 1 % catenate in the case of multiple samples
      for j = 2:nxyw
        eval(['g = [g; g', num2str(j), '];']);
      end
    end
    df(:,i) = (g - f)/ (step - 1)/ p(index(i)); % numerical differentials for parameter i
  end
  