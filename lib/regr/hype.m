function f = hype(p, x, y)
  % example function definition for mydata_regr2
  % p:(1) etc ..
  
  f = (x./ (p(1) + x)) * (p(2) * exp(p(3) * y))';