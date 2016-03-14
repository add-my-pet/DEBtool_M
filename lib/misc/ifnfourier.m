%% ifnfourier
% integrates a function that is speciefied in fourier terms

%%
function f = ifnfourier(t, p)
  %  Created by Bas Kooijman, 2007/03/30
  
  %% Syntax
  % f = <../ifnfourier.m *ifnfourier*>(t, p)

  %% Description
  % Works similar to fnfourier but gives a single n-vector with integrated values of the Fourier series. 
  % The first element is zero by definition. 
  %
  % Input:
  %
  % * t: (nt,1)-vector with time points
  % * p: (n+1,2)-matrix with parameters
  %
  %       - p(1,:): period, mean level
  %       - p(2:n+1,:): fourier coefficients for cosinus, sinus
  %
  % Output:
  %
  % * f: (nt,1)-vector with integrated function values, f(1)=0
  %
  %% Remarks
  % Input-output structure similar to <../html/spline.html *spline*>;
  % cf <../html/dfnfourier.html *dfnfourier*> for derivative;
  %    <../html/ifnfourier.html *ifnfourier*> for integration;
  %    <../html/rfnfourier.html *rfnfourier*> for roots;
  %    <../html/get_fnfourier.html *get_fnfourier*>for parameters;
  %    <../html/efnfourier.html *efnfourier*> for local extremes.
  
  %% Example of use 
  % see <mydata_smooth.m *mydata_smooth*>. 

n = size(p,1);   % number of fourier terms +1
period = p(1,1); % period of periodic function
a0 = p(1,2);     % mean level of function
a = p(2:n,1);    % fourier coefficients for cosinus
b = p(2:n,2);    % fourier coefficients for sinus
n = n - 1;       % number of Fourier terms
nt = length(t);

s = 2 * pi * t(:,1)/period - pi;
T = s * (1 ./ (1:n)); % matrix of times, order
ds = s(2:nt) - s(1:nt-1);

f = a0 * ds + (sin(T(2:nt,:)) - sin(T(1:nt-1,:))) * a - ...
              (cos(T(2:nt,:)) - cos(T(1:nt-1,:))) * b;
f = cumsum([0;f]) * period/ (2 * pi);