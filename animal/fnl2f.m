function F = fnl2f(f)
  % called by function l2f
  % F = fnl2f(f)
  % f: scalar with scaled functional response
  % F: scalar with function value that has to be set equal to zero
  global dt l0 ln g 

  F = log(max(1e-8,(f - l0)/ (f - ln))) - dt/ 3/ (1 + f/ g);
