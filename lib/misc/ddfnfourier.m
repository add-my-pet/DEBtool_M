function ddf = ddfnfourier(t, p)
  % Created by Bas Kooijman, 2007/03/30
  %
  %% Input
  %  t: (nt,1)-vector with time points
  %  p: (n+1,2)-matrix with parameters
  %
  %% Output
  %  ddf: (nt,1)-vector with second derivatives of function
  %
  %% Remarks
  %  input-output structure similar to spline
  %  cf fnfourier

n = size(p,1);   % number of fourier terms +1
period = p(1,1); % period of periodic function
a0 = p(1,2);     % mean level of function
a = p(2:n,1);    % fourier coefficients for cosinus
b = p(2:n,2);    % fourier coefficients for sinus
n = n - 1;       % number of Fourier terms

T = (2 * pi * t(:,1)/period - pi) * (1:n); % matrix of times, order

ddf = - cos(T) * (a .* (1:n)'.^2) - sin (T) * (b .* (1:n)'.^2) ; % second derivatives
ddf = 4 * pi^2 * ddf/ period^2; % unscale time in derivative