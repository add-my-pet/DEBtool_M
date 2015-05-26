%% ssqvc
% Calculates 2 ln lik vor constant variation coefficient

%%
function  ss = ssqvc (func, p, varargin)
  % created: 2010/10/31 by Bas Kooijman
  
  %% Syntax
  % ss = <../ssqvc.m *ssqvc*> (func, p, varargin)
  
  %% Description
  % Calculates 2 times log likelihood function of regression model
  %   where normally distributed scatter has sd proportional to mean
  %   for observations y_i, expectations f_i, variation coeff v_c
  %
  %   - 2 ln likelihood = n  + n ln (2 pi v_c^2) + 2 sum_i ln f_i
  %   v_c^2 = sum_i (y_i/ f_i - 1)^2/ n
  %
  % Input
  %
  % * func: character string with name of user-defined function;
  %   see <nrvcregr.html *nrvcregr*>
  % * p: (r,k) matrix with parameter values in p(1,:) 
  % * : (ni,3) matrix with
  %
  %    Xi(:,1) independent variable
  %    Xi(:,2) weight coefficients
  %    Xi(:,3) dependent variable
  %    The number of data matrices X1, X2, ... is optional
  %
  % Output
  %
  % * ss: scalar with 2 times log likelihood function
  
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
  n = sum(W ~= 0); % number of data points
  p = p(:,1); % remove other rows from parameter vector

  %% get function values
  eval(['[', listf,'] = ', func, '(p,', listxyw,' );']); f = f1;
  if nxyw > 1 % catenate in the case of multiple samples
    for i = 2:nxyw
      eval(['f = [f; f', num2str(i), '];']);
    end	    
  end
 
  vc2 = W' * (Y ./ f - 1) .^2; % squared total variation coefficient
  ss = - n * log(2 * pi + vc2) - W' * (2 * log(f) + (Y ./ f - 1) .^2/ vc2