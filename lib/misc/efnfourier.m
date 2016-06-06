%% efnfourier
% Finds all local extremes of fnfourier(t,p) within one period.

%%
function [ty_min, ty_max , info] = efnfourier(ty)
  %  created at 2007/03/30 by Bas Kooijman
  
  %% Syntax
  % [ty_min, ty_max , info] = <../efnfourier.m *efnfourier*>(ty)

  %% Description
  % Finds all local extremes of fnfourier(t,p) within one period. 
  % It does so by getting prior estimates using <../html/rspline1.html *rspline1*> applied to the derivatives of the Fourier series, 
  % followed by a Newton Raphson procedure. 
  %
  % Input:
  %
  % * ty: (r,2)-matrix with parameters (fourier coefficients); r>3
  %
  % Output:
  %
  % * ty_min: (n_min,2)-matrix with (t,y)-values of local minima
  % * ty_max: (n_max,2)-matrix with (t,y)-values of local maxima
  % * info: 1 = successful, 0 if not
  
  %% Remarks
  % cf <../html/fnfourier.html *fnfourier*>
  
  %% Example of use 
  % see <mydata_smooth.m *mydata_smooth*>. 
  
  t = linspace(0,ty(1,1),100)';
  t = rspline1([t, dfnfourier(t,ty)]);
  nt = length(t);
  info = 1;
  for i = 1:nt
      % Newton Raphson loop to make preliminary estimates more precise
      j = 1; % initiate counter
      f = 1; % make sure to start nr-procedure
      while f^2 > 1e-10 & j < 10
          f = dfnfourier(t(i), ty);
          df = ddfnfourier(t(i), ty);
          t(i) = t(i) - f/ df;
          j = j + 1;
      end
      if j == 10;
          info = 0;
          fprintf('no convergence\n');
      end
  end
  ddt = ddfnfourier(t, ty); t = [t, fnfourier(t,ty)];
  ty_min = t; ty_min(ddt < 0,:) = [];
  ty_max = t; ty_max(ddt > 0,:) = [];