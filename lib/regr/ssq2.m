%% ssq2
% Calculates sum of squared deviations for bivariate data


%%
function  ss = ssq2 (func, p, x, y, Z, W)
  %  created: 2001/09/07 by Bas Kooijman
  
  %% Syntax
  % ss = <../ssq2.m *ssq2*> (func, p, x, y, Z, W)
  
  %% Description
  % Calculates sum of squared deviations of model
  %   predictions with respect to observations for bivariate data
  %
  % Input
  %
  % * func: string with name of user-defined function
  %
  %    f = func (x, y, p) with x: n-vector; y: m-vector; p: k-vector
  %    f: (n,m)-matrix with model-predictions for dependent variable
  %
  % * p: (r,k) matrix with parameter values in p(1,:) 
  % * x: n-vector with first independent variable
  % * y: m-vector with second independent variable
  % * Z: (n,m)-matrix with dependent variable
  % * W: (n,m)-matrix with weight coefficients
  %
  % Output
  %
  % * ss: scalar with weighted sum of squared deviations
  
  %% Remarks
  % See <ssq.html *ssq*> for univariate data.
  
  %% Example of use
  % Assuming that function_name, pars, xvalues, yvalues, zdata, and weights are defined properly: 
  % ssq2('function_name', pars, xvalues, yvalues, zdata, weights). 
  
  [nx, ny] = size(Z); % nx,ny is number of values of dependent variables
  if exist('W', 'var') ~= 1
    W = ones(nx, ny);
  end

  eval(['f = ',func, '(p(:,1), x, y);']);
  ss = sum(sum(W.*(f - Z).^2))/ sum(sum(W));