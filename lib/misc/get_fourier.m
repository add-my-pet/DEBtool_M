function p = get_fourier(period, n, ty)
  %  created by Bas Kooijman, 2007/03/27
  %
  %% Description
  %  The function get_fourier obtains the parameters of the fourier series
  %    that minimizes the weighted sum of squared deviations of data points, given a period and the number of fourier terms. 
  %  (The number of parameters equals one + two times the number of Fourier terms.) 
  %  It does so by first obtaining the coefficient using Euler's formulas with ispline, followed by a Newton Raphson procedure. 
  %
  %% Input
  %  period: scalar with period
  %  n: scalar with order
  %  ty: (k,2)-matrix with time, function values
  %
  %% Output
  %  p: (n+1,2)-matrix with 
  %  row 1: period, mean function,
  %  row 2,.,n+1: fourier coefficients
  %
  %% Remarks
  %  input-output structure similar to knot
  %  cf fnfourier

  %% Code
  % force independent variable on interval (-pi,pi)
  t = 2 * pi * ty(:,1)/ period - pi;
  y = ty(:,2); % unpack function values

  % Euler formulas for Fourier coefficients
  a0 = ispline1([-pi;pi],ty); a0 = a0(2)/ (2 * pi);
  p = [period 0; a0 1]; % fix period in later least squares procedure
  for i = 1:n % n Fourier terms
    ai = ispline1([-pi;pi], [t, y .* cos(i * t)]);
    ai = ai(2)/ pi;
    bi = ispline1([-pi;pi], [t, y .* sin(i * t)]);
    bi = bi(2)/ pi;
    p = [p; ai 1; bi 1]; % append parameters
  end

  % improve Euler formulas by least squares minimasation
  nrregr_options('report',0);
  nrregr_options('max_step_number',500);
  [p, info] = nrregr('fn_fourier',p,ty); 
  p = wrap(p(:,1), n + 1, 2); % compose output

  if info ~= 1
    fprintf('convergence problems\n');
  end
