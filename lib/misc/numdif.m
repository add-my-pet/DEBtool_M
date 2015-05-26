function df = numdif(fn, x, f)
  %  Created: 2000/10/04 by Bas Kooijman, modifoed 2009/09/29
  %
  %% Description
  %  numerical differiation of user defined function 'fn' with respect to
  %    vector-valued argument x, and f = fn(x); size(x) = size(f)
  %
  %% Remarks
  %  Requires: user-defined function 'fn'
  %  Only forward differences are used to avoid negative argument values
  %  df(i,j) = df(i)/dx(j) is a (n,n)-matrix
  
  if exist('f','var')==0 % get function value at x, if it is not given
    eval(['f = ', fn, '(x);']);
  end

  n = max(size(x)); % number of variables
  h = 1e-6; % fixed interval, so very primitive, but fast and usually works
  df = zeros(n); % initiate output matrix
  for i = 1:n
    y = x; 
    y(i) = y(i) + h; % increase i-th argument only
   % z = x; z(i) = z(i) - h; % use this for forward and backward diff
   %   eval(['df(:,i) = (', fn, '(y) - ', fn, '(z))/(2*h);']);
   eval(['df(:,i) = (', fn, '(y) - f)/h;']);
  end


