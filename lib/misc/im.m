function a = im(c)
  %  created at 2002/21/05 by Bas Kooijman
  
  %% Syntax
  % a = <../im.m *im*>(c)

  %% Decription
  % Calculates the imaginary part of c: a = im(c)
  %
  % Input:
  %
  % * c: matrix with complex numbers
  %
  % Output:
  %
  % * a: matrix with imaginary part of c
  
  %% Example of use:
  % After e.g. x = rand(2,3) + i * rand(2,3): re(x) + i * im(x) - x. 
  % This should give a (2,3)-matrix of zeros. 

  [nr, nc] = size (c); c = c(:); ct = c';
  a = -i * (c - ct(:))/ 2;
  a = reshape(a, nr, nc);