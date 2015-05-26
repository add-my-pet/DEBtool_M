function G = Gamma(x, a)
  % created at 2009/08/04 by Bas Kooijman
  %
  %% Description
  %  incomplete Gamma function
  
  if exist('a','var') == 0
    a = 0;
  end
    
  G = gamma(a) * (1 - gammainc(x, a));