%% rfnfourier
% calculates real roots t of fnfourier(t,p) = y on interval (0,period)

%%
function [t, info] = rfnfourier (ty, y)
  %  created at 2007/03/28 by Bas Kooijman; modified 2009/09/29
  
  %% Syntax
  % f = <../rfnfourier.m *rfnfourier*>(t, p)

  %% Description
  %  calculates real roots t of fnfourier(t,p) = y on interval (0,period)
  %
  % Input:
  %
  % * ty: (r,2)-matrix with parameters; r>3
  % * y: scalar with function value (optional, default is 0)
  %
  % Output:
  %
  % * x: vector with real roots
  
  %% Remarks
  % Input-output structure similar to <../html/spline.html *spline*>;
  % cf <../html/dfnfourier.html *dfnfourier*> for derivative;
  %    <../html/ifnfourier.html *ifnfourier*> for integration;
  %    <../html/rfnfourier.html *rfnfourier*> for roots;
  %    <../html/get_fnfourier.html *get_fnfourier*> for parameters;
  %    <../html/efnfourier.html *efnfourier*> for local extremes.
  
  %% Example of use 
  % see <mydata_smooth.m *mydata_smooth*>. 
  
  if exist('y','var') == 0
    y = 0;
  end

  ty(1,2) = ty(1,2) - y; n = size(ty,1);
  t = linspace(0,ty(1,1), 20 * n)';
  t = rspline1([t, fnfourier(t,ty)]);
  info = 1;
  if isempty(t)
    return
  end
  % Newton Raphson loop to make preliminary estimates more precise
  j = 1; % initiate counter
  f = 1; % make sure to start nr-procedure
  while f' * f > 1e-10 && j < 10
    f = fnfourier(t, ty);
    df = dfnfourier(t, ty);
    t = t - f ./ df;
    j = j + 1;
  end
  if j == 10;
    info = 0;
    fprintf('no convergence\n');
  end
