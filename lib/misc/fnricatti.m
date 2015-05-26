function f = fnricatti(S)
  %% called from ricatti
  global a b n
  S = reshape(S,n,n);
  f = a + S * b' + b * S;
  f = f(:);
