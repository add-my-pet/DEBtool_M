function [q, info] = fsregr(func, p, varargin)
  % created: 2001/09/07 by Bas Kooijman
  %
  %% Description
  %  calculates least squares estimates using Octaves' fsolve method
  %     on numerical derivatives; multiple-sample case
  %
  %% Input
  %  func: string with name of user-defined function
  %     f = func (p, xyw) with
  %       p: k-vector with parameters; xyw: (n,c)-matrix; f: n-vector
  %     [f1, f2, ...] = func (p, xyw1, xyw2, ...) with  p: k-vector  and
  %      xywi: (ni,k)-matrix; fi: ni-vector with model predictions
  %     The dependent variable in the output f; For xyw see below.
  %  p: (k,2) matrix with
  %     p(:,1) initial guesses for parameter values
  %     p(:,2) binaries with yes or no iteration (optional)
  %  xyzi (read as xyw1, xyw2, .. ): (ni,3) matrix with
  %     xywi(:,1) independent variable i
  %     xywi(:,2) dependent variable i
  %     xywi(:,3) weight coefficients i (optional)
  %     xywi(:,>3) data-pont specific information data (optional)
  %     The number of data matrices xyw1, xyw2, ... is optional but >0
  %
  %% Output
  %  q: matrix like p, but with least squares estimates
  %  info: 1 if convergence has been successful; 0 otherwise
  %
  %% Remarks
  %  calls fsdregr, and user-defined function 'func'
  %  set options with 'fsolve_options'

  %% Code
  global index l n nxyw listx listxyw listf listg;
  global fn_name par Y W;

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

  n = sum(n); % total number of data points in all samples
  W = W/sum(W); % sum of weight coefficients set equal to 1

  [np k] = size(p); % k: number of parameters
  index = 1:np;
  if k>1
    index = index(1 == p(:,2)); % indices of iterated parameters
  end
  l = max(size(index));  % l: number of parameters that must be iterated
  if (l == 0)
    return; % no parameters to iterate
  end

  fn_name = func; % for use in fsdregr
  par = p(:,1); % for use in fsdregr
  q = p; % copy input parameter matrix into output
  
  [q(index,1), val, info] = fsolve('fsdregr', par(index,1));
  
  if info ~= 1
    fprintf('no convergence to requested tolerance \n');
  end