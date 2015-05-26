%% dev3
% Calculates deviance for trivariate data

%%
function d = dev3(func, p, t, x, y, N)
  %  created: 2006/03/07 by Bas Kooijman, modified 2008/30/12
  
  %% Syntax
  % d = <../dev3.m *dev3*>(func, p, t, x, y, N)
  
  %% Description
  % Calculates deviance for trivariate data
  %
  % Input
  %
  % * func: string with name of user-defined function
  %
  %     f = func (p, t, y) with
  %     p: np-vector; t: nt-vector; x: nx-vector; y: ny-vector
  %     f: (nt,nx*ny)-matrix with model-predictions for surviving numbers
  %
  % * p: (np,2) matrix with
  %
  %     p(:,1) initial guesses for parameter values
  %     p(:,2) binaries with yes or no iteration (optional)
  %
  % * t: (nt,1)-vector with first independent variable (time)
  % * x: (nx,1)-vector with second independent variable
  % * y: (ny,1)-vector with third independent variable
  % * N: (nt,ny)-matrix with surviving numbers
  %
  % Output
  %
  % * d: scalar with deviance, see dev
  % * calls user-defined function 'func'
  
  %% Remarks
  % See <dev.html *dev*>.
  % Calls user-defined function 'func'.
 
  %% Example of use
  % Assuming that function_name, pars, tvalues, xvalues, yvalues, numbers are defined properly: 
  % dev3('function_name', pars, tvalues, xvalues, yvalues, numbers).

  % t = t(:); x = x(:); y = y(:); % set independent vars to column vectors
  nt = length(t); % number of time points
  nx = length(x); % number of values for second independent vars
  ny = length(y); % number of values for third independent vars
  [nNt nNxy] = size(N); % number data points
  if nNt ~= nt & nNxy ~= nx * ny % test size data matrix
    fprintf('size of data matrix does not match specification of arguments \n');
    q = []; info = 0;
    return
  end
  nxy = nx * ny; ntxy = nt * nxy; 
  
  D = N - [N(2:nt,:); zeros(1,nxy)]; D = reshape(D, ntxy, 1);
  n0 = ones(nt,1) * N(1,:); n0 = reshape(n0, ntxy, 1);
  likmax = D' * log(max(1e-10, D ./ n0)); % max of log lik function

  eval([ 'f = ', func, '(p(:,1), t, x, y);']);
				% obtain survival probabilities
  prob = reshape(f - [f(2:nt,:);zeros(1,nxy)], ntxy, 1);
  d = 2 * (likmax - D' * log(max(1e-10,prob)));
				% deviance: 2* log lik minus its supremum
