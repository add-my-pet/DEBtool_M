%% fnfourier
% calculates the ordinates of a function that is specified by fourier terms

%%
function f = fnfourier(t, p)
  % Created by Bas Kooijman, 2007/03/30
  
  %% Syntax
  % f = <../fnfourier.m *fnfourier*>(t, p)

  %% Description
  % Fourier series are defined as weighted sum of cosinus and sinus functions plus an additive coefficient (= mean function value). 
  % They are periodic, so the function value and the derivatives at the start and the end of a period are equal.
  % Function fnfourier calculates the ordinates, dfnfourier the derivatives and ddfnfourier the second derivatives. 
  % These functions all have the same input/output structure. 
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
  % * f: (nt,1)-vector with function values
  %
  %% Remarks
  % Input-output structure similar to <../html/spline.html *spline*>;
  % cf <../html/dfnfourier.html *dfnfourier*> for derivative;
  %    <../html/ifnfourier.html *ifnfourier*> for integration;
  %    <../html/rfnfourier.html *rfnfourier*> for roots;
  %    <../html/get_fnfourier.html *get_fnfourier*> for parameters;
  %    <../html/efnfourier.html *efnfourier*> for local extremes.
  
  %% Example of use 
  % see <mydata_smooth.m *mydata_smooth*>. 

n = size(p,1);   % number of fourier terms +1
period = p(1,1); % period of periodic function
a0 = p(1,2);     % mean level of function
a = p(2:n,1);    % fourier coefficients for cosinus
b = p(2:n,2);    % fourier coefficients for sinus
n = n - 1;       % number of Fourier terms

T = (2 * pi * t(:,1)/period - pi) * (1:n); % matrix of times, order

f = a0 + cos(T) * a + sin(T) * b; % function values
