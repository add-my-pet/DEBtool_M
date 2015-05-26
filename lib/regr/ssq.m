%% ssq
% Calculates sum of squared deviations for univariate data

%%
function  ss = ssq (func, p, varargin)
  %  created: 2001/09/07 by Bas Kooijman
  
  %% Syntax
  % ss = <../ssq.m *ssq*> (func, p, varargin)
  
  %% Description
  % Calculates sum of squared deviations of model predictions with respect to observations
  %
  % Input
  %
  % * func: character string with name of user-defined function
  %    see <nrregr.html *nrregr*>
  % * p: (r,k) matrix with parameter values in p(1,:) 
  % * Xi: (ni,3) matrix with
  %
  %     Xi(:,1) independent variable
  %     Xi(:,2) weight coefficients
  %     Xi(:,3) dependent variable
  %     The number of data matrices X1, X2, ... is optional
  % 
  % Ouput
  %
  % * ss: scalar with weighted sum of squared deviations
  
  %% Example of use
  %  assuming that function_name, pars, and xyw1 (and possibly more data matrices) are defined properly: 
  %  ssq('function_name', pars, xyw1, xyw2, ...). 
  
  %% Code
  i = 1; % initiate data set counter
  ci = num2str(i); % character string with value of i
  nxyw = nargin - 2; % number of data sets
  while (i <= nxyw) % loop across data sets
    if i == 1
      listxyw = ['xyw', ci,',']; % initiate list xyw
      listx = ['xyw', ci]; % initiate list xyw for global declaration
      listf = ['f', ci,',']; % initiate list f
      listg = ['g', ci,',']; % initiate list g
    else     
      listxyw = [listxyw, ' xyw', ci,',']; % append list xyw
      listx = [listx, ' xyw', ci]; % append list xyw for global declaration
      listf = [listf, ' f', ci,',']; % append list f
      listg = [listg, ' g', ci,',']; % append list g
    end
    i = i + 1;
    ci = num2str(i); % character string with value of i
  end
  [i, nl] = size(listxyw); listxyw = listxyw(1:(nl-1)); % remove last ','
  [i, nl] = size(listf); listf = listf(1:(nl-1)); % remove last ','
  [i, nl] = size(listg); listg = listg(1:(nl-1)); % remove last ','
  eval(['global ', listx,';']); % make data sets global

  i = 1; % initiate data set counter
  ci = num2str(i); % character string with value of i
  while (i <= nxyw) % loop across data sets
    eval(['xyw', ci, ' = varargin{i};']); % assing unnamed arguments to xywi
    eval(['[n(', ci, '), k] = size(xyw', ci, ');']); % number of data points
    if i == 1
      eval(['Y = xyw',ci,'(:,2);']); % initiate dependent variables
      if k > 2
	    eval(['W = xyw',ci,'(:,3);']); % initiate weight coefficients
      else
	    W = ones(n(1),1);
      end
    else     
      eval(['Y = [Y;xyw', ci, '(:,2)];']); % append dependent variables
      if k > 2
	    eval(['W = [W;xyw', ci, '(:,3)];']); % append weight coefficients
      else
	    W = [W; ones(n(i),1)]; % append weight coefficients
      end
    end
    i = i + 1;
    ci = num2str(i); % character string with value of i
  end

  W = W/sum(W); % sum of weight coefficients set equal to 1
  p = p(:,1); % remove other rows from parameter vector

  %% get function values
  eval(['[', listf,'] = ', func, '(p,', listxyw,' );']); f = f1;
  if nxyw > 1 % catenate in the case of multiple samples
    for i = 2:nxyw
      eval(['f = [f; f', num2str(i), '];']);
    end	    
  end

  ss = W' * (f - Y).^2;