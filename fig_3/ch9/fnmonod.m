function f = fnmonod (X)
  global T X0 Xi K Y jXm
  a = (X * (Xi - X0))/ (X0 * (Xi - X));
  f = T * Y * jXm - K * Y * log(a)/ Xi - log(X/ X0)/ 2;
