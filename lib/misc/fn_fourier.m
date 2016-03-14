%% fn_fourier
% subfunction of get_fourier to assign Fourier coefficients

%%
function f = fn_fourier(p, t)
  % Created by Bas Kooijman, 2007/03/27

  %% Description
  % subfunction of get_fourier to assign Fourier coefficients. 
  %
  % Input:
  %
  % * t: (nt,c)-matrix with time points in col 1
  % * p: (2n+2,1)-vector with parameters
  %
  %       - p(1,:): period, mean level
  %       - p(2:n+1,:): fourier coefficients for cosinus, sinus
  %
  % Output
  %
  % * f: (nt,1)-vector with function values
  
  %% Remarks
  % called by nrregr in get_fourier to assign Fourier coefficients

n = length(p);   % number of parameters
period = p(1);   % period of periodic function
a0 = p(2);       % mean level of function
a = p(3:2:n);    % fourier coefficients for cosinus
b = p(4:2:n);    % fourier coefficients for sinus
n = length(a);   % number of Fourier terms

T = (2 * pi * t(:,1)/ period - pi) * (1:n); % matrix of times, order

f = a0 + cos(T) * a + sin(T) * b; % function values
