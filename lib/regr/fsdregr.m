function f = fsdregr (p)
  % created: 2001/09/07 by Bas Kooijman
  % routine called by fsregr to calculate numerical derivatives
  % f: (l)-vector with derivatives

  global fn_name par Y W
  global index l n nxyw listx listxyw listf listg;
  eval(['global ', listx,';']); % make data sets global (set in 'fsregr')

  % index: parameter indices that are iterated
  % l: number of parameters that are iterated
  % n: total number of data points
  % listxyw: a character-string with 'xyw1, xyw2 ...'
  % listf: a character-string with 'f1, f2 ...'
  % listg: a character-string with 'g1, g2 ...'

  step = 1e-3; % step in parameter values for numerical differentiation
  
  par (index,1) = p;

  % get function values at evaluation point
  eval(['[', listf,'] = ', fn_name, '(par,', listxyw,' );']); f = f1;
  if nxyw > 1 % catenate in the case of multiple samples
    for i = 2:nxyw
      eval(['f = [f; f', num2str(i), '];']);
    end	    
  end
  
  df = zeros(n,l); % initiate jacobian
  for i = 1 : l % loop across parameters to be iterated
    % make step in a single parameter value
    cpar = par; cpar(index(i)) = cpar(index(i)) + step;
    % get function values at changed parameter value
    eval(['[', listg, '] = ', fn_name, '(cpar, ', listxyw,');']); g = g1;
    
    if nxyw > 1 % catenate in the case of multiple samples
      for j = 2:nxyw
        eval(['g = [g; g', num2str(j), '];']);
      end
    end
    df(:,i) = (g - f)/step; % numerical differentials for parameter i
  end

  f = df'*(W .* (Y - f)); % weighted derivatives which must be set to zero
