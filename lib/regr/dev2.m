%% dev2
% Calculates deviance for bivariate data 

%%
function d = dev2(func, p, t, y, N)
  %  created: 2001/09/13 by Bas Kooijman; modified 2006/03/07
  
  %% Syntax
  % d = <../dev2. *dev2*>(func, p, t, y, N)
  
  %% Description
  % Calculates deviance for bivariate data 
  %
  % Input
  %
  % % func: string with name of user-defined function
  %
  %     f = func (p, t, y) with p: np-vector; t: nt-vector; y: ny-vector
  %     f: (nt,ny)-matrix with model-predictions for surviving numbers
  %
  % * p: (np,2) matrix with
  %
  %     p(:,1) initial guesses for parameter values
  %     p(:,2) binaries with yes or no iteration (optional)
  %
  % * t: (nt,1)-vector with first independent variable (time)
  % * y: (ny,1)-vector with second independent variable
  % * N: (nt,ny)-matrix with surviving numbers
  %
  % Output
  %
  % * d: scalar with deviance

  %% Remarks
  % See <dev.html *dev*>.
  % Calls user-defined function 'func'

  %  set independent variables to column vectors, 
  %  t = reshape(t, max(size(t)), 1);
  %  y = reshape(y, max(size(y)), 1);
  
  [nt ny] = size(N); % nt,ny is number of values of surviving individuals
  nty = nt*ny;
  D = N - [N(2:nt,:); zeros(1,ny)]; D = reshape(D, nty, 1);
  n0 = ones(nt,1) * N(1,:); n0 = reshape(n0, nty, 1);
  likmax = D' * log(max(1e-10, D./ n0)); % max of log lik function

  eval([ 'f = ', func, '(p(:,1), t, y);']);
				% obtain survival probabilities
  prob = reshape(f - [f(2:nt,:);zeros(1,ny)], nty, 1);
  d = 2 * (likmax - D' * log(max(1e-10,prob)));
				% deviance: 2* log lik minus its supremum
