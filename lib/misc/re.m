function a = re(c)
  % created at 2002/05/29 by Bas Kooijman
  %
  %% Description
  % calculates the real part of c: a = re(c)
  %
  %% Input
  %  c: matrix with complex numbers
  %
  %% Output
  %  a: matrix with real part of c

  [nr nc] = size (c); c = c(:); ic = c';
  a = (c + ic(:))/2;
  a = reshape(a,nr,nc);
