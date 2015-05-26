function [q, info] = fsregr2(func, p, x, y, Z, W)
  % created: 2001/09/07 by Bas Kooijman
  %
  %% Description
  %  calculates least squares estimates using Octave's fsolve method
  %
  %% Input
  %  func: string with name of user-defined function
  %     f = func (p, x, y) with p: np-vector; x: nx-vector; y: ny-vector
  %     f: (nx,ny)-matrix with model-predictions for dependent variable
  %  p: (np,2) matrix with
  %     p(:,1) initial guesses for parameter values
  %     p(:,2) binaries with yes or no iteration (optional)
  %  x: (nx,1)-vector with first independent variable
  %  y: (ny,1)-vector with second independent variable
  %  Z: (nx,ny)-matrix with dependent variable
  %  W: (nx,ny)-matrix with weight coefficients (optional)
  %
  %% Ouput
  %  q: matrix like p, but with least squares estimates
  %  info: 1 if convergence has been successful; 0 otherwise
  %
  %% Remarks
  % calls fsdregr2, and user-defined function 'func'
  
  %% Code
  opt = optimset('display',off');
 
  global index nxy l;
  global fn_name par X Y ZZ WW;

  %% set independent variables to column vectors, 
  x = reshape(x, max(size(x)), 1);
  y = reshape(y, max(size(y)), 1);
  
  [np, k] = size(p); % np is number of parameters
  index = 1:np;
  if k>1
    index = index(1 == p(:,2)); % indices of iterated parameters
  end
  l = max(size(index)); % l is number of parameters that must be iterated
  if (l == 0)
    return; % no parameters to iterate
  end

  [nx, ny] = size(Z); % nx,ny is number of values of dependent variables
  nxy = nx * ny; % total number of data points
  if exist('W') ~= 1
    W = ones(nx, ny);
  end

  if 2 ~= sum([nx ny]==size(W)) | 2 ~= sum([nx 1]==size(x)) | ...
	2 ~= sum([ny 1]==size(y))
    printf('sizes of arguments do not match \n');
    return;
  end
  
  q = p; % copy input into output
  par = p(:,1); % for use in fsdregr2
  fn_name = func; % for use in fsdregr2
  WW = reshape(W/sum(sum(W)), nxy, 1); % for use in fsdregr2
  ZZ = reshape(Z, nxy, 1); % for use in fsdregr2
  X = x; % for use in fsdregr2
  Y = y; % for use in fsdregr2
  [q(index,1), val, info] = fsolve('fsdregr2', par(index,1),opt);

  if info ~= 1
    fprintf('no convergence to requested tolerance')
  end