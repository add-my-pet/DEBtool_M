%% nmsurv
% Calculates max likelihood estimates using Nelder Mead's simplex method

%%
function [q, info] = nmsurv(func, p, varargin)
  %  created: 2001/09/12 by Bas Kooijman; modified 2013/03/13
  
  %% Syntax 
  % [q, info] = <../nmsurv.m *nmsurv*>(func, p, varargin)
  
  %% Description
  % Calculates max likelihood estimates using Nelder Mead's simplex method
  %     similar to nrsurv, but slower and a larger bassin of attraction
  %
  % Input
  %
  % * func: string with name of user-defined function
  %
  %     f = func (p, tn) with
  %       p: k-vector with parameters; tn: (n,c)-matrix; f: n-vector
  %     [f1, f2, ...] = func (p, tn1, tn2, ...) with  p: k-vector  and
  %      tni: (ni,k)-matrix; fi: ni-vector with model predictions
  %     The dependent variable in the output f; For tn see below.
  %
  % * p: (k,2) matrix with
  %
  %     p(:,1) initial guesses for parameter values
  %     p(:,2) binaries with yes or no iteration (optional)
  %
  % * tni (read as tn1, tn2, .. ): (ni,2) matrix with
  %
  %     tni(:,1) time: must be increasing with rows
  %     tni(:,2) number of survivors: must be non-increasing with rows
  %     tni(:,3, 4, ... ) data-pont specific information data (optional)
  %     The number of data matrices tn1, tn2, ... is optional but >0
  %
  % Output
  %
  % * q: matrix like p, but with ml-estimates
  % * info: 1 if convergence has been successful; 0 otherwise
  
  %% Remarks
  % Calls user-defined function 'func'
  % Set options with <nmregr_options. html *nmregr_options*>
  % See <scsurv.html *scsurv*> for the definition of the user-defined function, 
  %   and <scsurv2.html *scsurv2*> and <nmsurv2.html *nmsurv2*> for 2 independent variables 
  %   and <scsurv3.html *scsurv3*> and <nmsurv3.html *nmsurv3*> for 3 independent variables.
  % It is usually a good idea to run <scsurv.html *scsurv*> on the result of nmsurv. 
 
  %% Example of use
  % See <../mydata_surv.m *mydata_surv*>

  global report max_step_number max_fun_evals tol_simplex tol_fun; % option settings

  i = 1; % initiate data set counter
  info = 1; % initiate info setting
  ci = num2str(i); % character string with value of i
  ntn = nargin - 2; % number of data sets
  while (i <= ntn) % loop across data sets
    if i == 1
      listtn = ['tn', ci,',']; % initiate list xyw
      listf = ['f', ci,',']; % initiate list f
    else     
      listtn = [listtn, ' tn', ci,',']; % append list tn
      listf = [listf, ' f', ci,',']; % append list f
    end
    i = i + 1;
    ci = num2str(i); % character string with value of i
  end
  nl = size(listtn,2); listtn = listtn(1:(nl - 1)); % remove last ','
  nl = size(listf,2); listf = listf(1:(nl - 1)); % remove last ','

  global_txt = strrep(['global ', listtn], ',', ' ');
  eval(global_txt); % make data sets global

  N = zeros(ntn, 1); % initiate data counter
  for i = 1:ntn % loop across data sets
    ci = num2str(i); % character string with value of i
    eval(['tn', ci, ' = varargin{i};']); % assing unnamed arguments to xywi
    eval(['[N(', ci, '), k] = size(tn', ci, ');']); % number of data points
    if i == 1
      %% obtain time intervals and numbers of death
      D = tn1(:,2) - [tn1(2:N(i),2);0]; % initiate death count
      n0 =  tn1(1,2) * ones(N(1),1); % initiate start number
    else     
      eval(['D = [D; [tn', ci,'(:,2)] - [tn', ci, '(2:N(i),2);0]];']);
                % append death counts
      eval(['n0 = [n0; tn', ci, '(1,2) * ones(N(', ci,'),1)];']);
				% append initial numbers
    end
  end

  q = p; % copy input parameter matrix into output
  info = 1; % convergence has been successful
  likmax = D' * log(max(1e-10,D./ n0)); % max of log lik function  
  ntot = sum(N); % tot number of time intervals
  prob = zeros(ntot,1);

  [np, k] = size(p); % k: number of parameters
  index = 1:np;
  if k>1
    index = index(0 < p(:,2)); % indices of iterated parameters
  end
  n = max(size(index));  % n: number of parameters that must be iterated
  if (n == 0)
    return; % no parameters to iterate
  end

  %% set options if necessary
  if prod(size(max_step_number)) == 0 
    nmsurv_options('max_step_number', 200*n);
  end
  if prod(size(max_fun_evals)) == 0 
    nmsurv_options('max_fun_evals', 200*n);
  end
  if prod(size(tol_simplex)) == 0 
    nmsurv_options('tol_simplex', 1e-4);
  end
  if prod(size(tol_fun)) == 0
    nmsurv_options('tol_fun', 1e-4);
  end
  if prod(size(report)) == 0
    nmsurv_options('report', 1);
  end

  % Initialize parameters
  rho = 1; chi = 2; psi = 0.5; sigma = 0.5;
  onesn = ones(1,n);
  two2np1 = 2:n+1;
  one2n = 1:n;
  np1 = n+1;

  % Set up a simplex near the initial guess.
  v = zeros(n,np1); fv = zeros(1, np1);
  xin = q(index,1);  v(:,1) = xin;  % Place input guess in the simplex

  eval(['[',listf, '] = ', func, '(q(:,1),', listtn, ');']);
  if ntn == 1
    prob = f1 - [f1(2:N(1));0]; % death probabilities
  else % catenate in the case of multiple samples
    cn = 0;
    for i = 1:ntn
      ci = num2str(i);
      eval(['prob((1:N(', ci, ')) + cn, 1) = f', ci, ' - [f', ci, '(2:N(', ci, '));0];']);
      cn = cn + N(i);
    end 
  end  
  d = 2 * (likmax - D' * log(max(1e-10,prob)));  
  fv(:,1) = d;

  % Following improvement suggested by L.Pfeffer at Stanford
  usual_delta = 0.05;             % 5 percent deltas for non-zero terms
  zero_term_delta = 0.00025;      % Even smaller delta for zero elements of q
  for j = 1:n
    y = xin;
    if y(j) ~= 0
      y(j) = (1 + usual_delta)*y(j);
    else 
      y(j) = zero_term_delta;
    end  
    v(:,j+1) = y;
    q(index,1) = y;
    eval(['[', listf, '] = ', func, '(q(:,1), ', listtn, ');']);
    if ntn == 1
      prob = f1 - [f1(2:N(1));0]; % death probabilities
    else % catenate in the case of multiple samples
      cn = 0;
      for i = 1:ntn
        ci = num2str(i);
        eval(['prob((1:N(', ci, ')) + cn, 1) = f', ci, ' - [f', ci, '(2:N(', ci, '));0];']);
        cn = cn + N(i);
      end 
    end
  
    d = 2 * (likmax - D' * log(max(1e-10,prob)));
    fv(1,j+1) = d;

  end     

  % sort so v(1,:) has the lowest function value 
  [fv,j] = sort(fv);
  v = v(:,j);

  how = 'initial';
  itercount = 1;
  func_evals = n+1;
  if report == 1
    fprintf(['step ', num2str(itercount), ' ssq ', num2str(min(fv)), '-', ...
	    num2str(max(fv)), ' ', how, '\n']);
  end
  info = 1;

  % Main algorithm
  % Iterate until the diameter of the simplex is less than tol_simplex
  %   AND the function values differ from the min by less than tol_fun,
  %   or the max function evaluations are exceeded. (Cannot use OR instead of AND.)
  while func_evals < max_fun_evals & itercount < max_step_number
    if max(max(abs(v(:,two2np1)-v(:,onesn)))) <= tol_simplex & ...
       max(abs(fv(1)-fv(two2np1))) <= tol_fun
    break
  end
  how = '';
   
  % Compute the reflection point
   
  % xbar = average of the n (NOT n+1) best points
  xbar = sum(v(:,one2n)')'/n;
  xr = (1 + rho)*xbar - rho*v(:,np1);
  q(index,1) = xr;
  eval(['[', listf, '] = ', func, '(q(:,1), ', listtn, ');']);
  if ntn == 1
    prob = f1 - [f1(2:N(1));0]; % death probabilities
  else % catenate in the case of multiple samples
    cn = 0;
    for i = 1:ntn
      ci = num2str(i);
      eval(['prob((1:N(', ci, ')) + cn, 1) = f', ci, ' - [f', ci, '(2:N(', ci, '));0];']);
      cn = cn + N(i);
    end 
  end
  
  d = 2 * (likmax - D' * log(max(1e-10,prob)));
  fxr = d;

  func_evals = func_evals+1;
   
   if fxr < fv(:,1)
      % Calculate the expansion point
      xe = (1 + rho*chi)*xbar - rho*chi*v(:,np1);
      q(index,1) = xe;
      eval(['[', listf, '] = ', func, '(q(:,1), ', listtn, ');']);
      if ntn == 1
          prob = f1 - [f1(2:N(1));0]; % death probabilities
      else % catenate in the case of multiple samples
          cn = 0;
          for i = 1:ntn
            ci = num2str(i);
            eval(['prob((1:N(', ci, ')) + cn, 1) = f', ci, ' - [f', ci, '(2:N(', ci, '));0];']);
            cn = cn + N(i);
          end 
      end
  
      d = 2 * (likmax - D' * log(max(1e-10,prob)));
      fxe = d;
      func_evals = func_evals+1;
      if fxe < fxr
         v(:,np1) = xe;
         fv(:,np1) = fxe;
         how = 'expand';
      else
         v(:,np1) = xr; 
         fv(:,np1) = fxr;
         how = 'reflect';
      end
   else % fv(:,1) <= fxr
      if fxr < fv(:,n)
         v(:,np1) = xr; 
         fv(:,np1) = fxr;
         how = 'reflect';
      else % fxr >= fv(:,n) 
         % Perform contraction
         if fxr < fv(:,np1)
            % Perform an outside contraction
            xc = (1 + psi*rho)*xbar - psi*rho*v(:,np1);
            q(index,1) = xc;
	    eval(['[', listf, '] = ', func, '(q(:,1), ', listtn, ');']);
	    if ntn == 1
              prob = f1 - [f1(2:N(1));0]; % death probabilities
            else % catenate in the case of multiple samples
              cn = 0;
              for i = 1:ntn
                ci = num2str(i);
                eval(['prob((1:N(', ci, ')) + cn, 1) = f', ci, ' - [f', ci, '(2:N(', ci, '));0];']);
                cn = cn + N(i);
              end 
            end
  
            d = 2 * (likmax - D' * log(max(1e-10,prob)));
            fxc = d;
            func_evals = func_evals+1;
            
            if fxc <= fxr
               v(:,np1) = xc; 
               fv(:,np1) = fxc;
               how = 'contract outside';
            else
               % perform a shrink
               how = 'shrink'; 
            end
         else
            % Perform an inside contraction
            xcc = (1-psi)*xbar + psi*v(:,np1);
            q(index,1) = xcc;
	    eval(['[', listf, '] = ', func, '(q(:,1), ', listtn, ');']);
	      if ntn == 1
                prob = f1 - [f1(2:N(1));0]; % death probabilities
            else % catenate in the case of multiple samples
              cn = 0;
              for i = 1:ntn
                ci = num2str(i);
                eval(['prob((1:N(', ci, ')) + cn, 1) = f', ci, ' - [f', ci, '(2:N(', ci, '));0];']);
                cn = cn + N(i);
              end 
            end
  
            d = 2 * (likmax - D' * log(max(1e-10,prob)));
            fxcc = d;
            func_evals = func_evals+1;
            
            if fxcc < fv(:,np1)
               v(:,np1) = xcc;
               fv(:,np1) = fxcc;
               how = 'contract inside';
            else
               % perform a shrink
               how = 'shrink';
            end
         end
         if strcmp(how,'shrink')
            for j=two2np1
              v(:,j)=v(:,1)+sigma*(v(:,j) - v(:,1));
              q(index,1) = v(:,j);
              eval(['[', listf, '] = ', func, '(q(:,1), ', listtn, ');']);
              if ntn == 1
                prob = f1 - [f1(2:N(1));0]; % death probabilities
              else % catenate in the case of multiple samples
                cn = 0;
                for i = 1:ntn
                  ci = num2str(i);
                  eval(['prob((1:N(', ci, ')) + cn, 1) = f', ci, ' - [f', ci, '(2:N(', ci, '));0];']);
                  cn = cn + N(i);
                end 
              end
  
              d = 2 * (likmax - D' * log(max(1e-10,prob)));
              fv(:,j) = d;
            end
            func_evals = func_evals + n;
         end
      end
   end
   [fv,j] = sort(fv);
   v = v(:,j);
   itercount = itercount + 1;
   if report == 1
     fprintf(['step ', num2str(itercount), ' dev ', num2str(min(fv)), ...
	     '-', num2str(max(fv)), ' ', how, '\n']);
   end  
   end   % while


   q(index,1) = v(:,1);

   fval = min(fv); 
   if func_evals >= max_fun_evals
     if report > 0
       fprintf(['No convergences with ', ...
		num2str(max_fun_evals), ' function evaluations\n']);
     end
     info = 0;
   elseif itercount >= max_step_number 
     if report > 0
       fprintf(['No convergences with ', num2str(max_step_number), ' steps\n']);
     end
     info = 0; 
   else
     if report > 0
       fprintf('Successful convergence \n');              
     end
     info = 1;
   end
