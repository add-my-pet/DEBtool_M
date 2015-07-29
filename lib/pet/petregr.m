%% petregr
% Calculates least squares estimates using Nelder Mead's simplex

%%
function [q, info] = petregr(func, par, data, auxData, weights)
% created 2001/09/07 by Bas Kooijman; 
% modified 2015/03/30, 2015/07/29 by Goncalo Marques

%% Syntax
% [q, info] = <../petregr.m *petregr*> (func, par, data, auxData, weights)

%% Description
% Calculates least squares estimates using Nelder Mead's simplex method.
%
% Input
%
% * func: character string with name of user-defined function;
%      see nrregr_st or nrregr  
% * par: structure with parameters
% * data: structure with data
% * auxData: structure with auxiliary data
% * weights: structure with weights
% * filter: character string with name of user-defined filter function
%  
% Output
% 
% * q: structure with parameters, result of the least squares estimates
% * info: 1 if convergence has been successful; 0 otherwise

%% Remarks
% Set options with <nmregr_options.html *nmregr_options*>.
% Similar to <nrregr_st.html *nrregr_st*>, but slower and a larger bassin of attraction.
% The number of fields in data is variable
   
   
  global report max_step_number max_fun_evals tol_simplex tol_fun simplex_size

  % option settings
  info = 1; % initiate info setting
  
  % prepare variable
  %   st: structure with dependent data values only
  st = data;
  [nm nst] = fieldnmnst_st(st); % nst: number of data sets
  
  listst = strjoin(strcat('st.', nm)', '; ');
  listweights = strjoin(strcat('weights.', nm)', '; ');
  listf = strjoin(strcat('f.', nm)', '; ');
  
  for i = 1:nst   % makes st only with dependent variables
    eval(['[~, k] = size(st.', nm{i}, ');']); 
    if k == 2
      eval(['st.', nm{i}, ' = st.', nm{i},'(:,2);']);
    end
  end
  
  % Y: vector with all dependent data
  % W: vector with all weights
  eval(['Y = [', listst, '];']);
  eval(['W = [', listweights, '];']);
  
  parnm = fieldnames(par.free);
  np = numel(parnm);
  n_par = sum(cell2mat(struct2cell(par.free)));
  if (n_par == 0)
    return; % no parameters to iterate
  end
  index = 1:np;
  index = index(cell2mat(struct2cell(par.free)) == 1);  % indices of free parameters

  free = par.free; % free is here removed, and after iteration added again
  q = rmfield(par, 'free'); % copy input parameter matrix into output
  qvec = cell2mat(struct2cell(q));
  info = 1; % convergence has been successful
  
  % set options if necessary
  if ~exist('max_step_number','var') || isempty(max_step_number)
    nmregr_options('max_step_number', 200 * n_par);
  end
  if ~exist('max_fun_evals','var') || isempty(max_fun_evals)
    nmregr_options('max_fun_evals', 200 * n_par);
  end
  if ~exist('tol_simplex','var') || isempty(tol_simplex)
    nmregr_options('tol_simplex', 1e-4);
  end
  if ~exist('tol_fun','var') || isempty(tol_fun)
    nmregr_options('tol_fun', 1e-4);
  end
  if ~exist('simplex_size','var') || isempty(simplex_size)
    nmregr_options('simplex_size', 0.05);
  end
  if ~exist('report','var') || isempty(report)
    nmregr_options('report', 1);
  end

  % Initialize parameters
  rho = 1; chi = 2; psi = 0.5; sigma = 0.5;
  onesn = ones(1, n_par);
  two2np1 = 2:n_par + 1;
  one2n = 1:n_par;
  np1 = n_par + 1;

  % Set up a simplex near the initial guess.
  xin = qvec(index);    % Place input guess in the simplex
  v(:,1) = xin;
  eval(['f = ', func, '(q, data, auxData);']);
  eval(['fv(:,1) = W'' * ([', listf, '] - Y).^2;']);
  % Following improvement suggested by L.Pfeffer at Stanford
  usual_delta = simplex_size;     % 5 percent deltas is the default for non-zero terms
  zero_term_delta = 0.00025;      % Even smaller delta for zero elements of q
  for j = 1:n_par
    y = xin;
    if y(j) ~= 0
      y(j) = (1 + usual_delta) * y(j);
    else 
      y(j) = zero_term_delta;
    end
    qvec(index) = y; q = cell2struct(mat2cell(qvec, ones(np, 1), [1]), parnm);
    eval(['[f, f_test] = ', func, '(q, data, auxData);']);
    v(:,j+1) = y;
    eval(['fv(:,j+1) = W'' * ([', listf, '] - Y).^2;']);
  end     

  % sort so v(1,:) has the lowest function value 
  [fv,j] = sort(fv);
  v = v(:,j);

  how = 'initial';
  itercount = 1;
  func_evals = n_par + 1;
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
  xbar = sum(v(:,one2n), 2)/ n_par;
  xr = (1 + rho) * xbar - rho * v(:,np1);
  qvec(index) = xr; q = cell2struct(mat2cell(qvec, ones(np, 1), [1]), parnm);
  eval(['[f, f_test] = ', func, '(q, data, auxData);']);
  eval(['fxr = W'' * ([', listf, '] - Y).^2;']);
  func_evals = func_evals + 1;
   
   if fxr < fv(:,1)
      % Calculate the expansion point
      xe = (1 + rho * chi) * xbar - rho * chi * v(:, np1);
      qvec(index) = xe; q = cell2struct(mat2cell(qvec, ones(np, 1), [1]), parnm);
      eval(['[f, f_test] = ', func, '(q, data, auxData);']);
      eval(['fxe = W'' * ([', listf, '] - Y).^2;']);
      func_evals = func_evals + 1;
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
      if fxr < fv(:,n_par)
         v(:,np1) = xr; 
         fv(:,np1) = fxr;
         how = 'reflect';
      else % fxr >= fv(:,n_par) 
         % Perform contraction
         if fxr < fv(:,np1)
            % Perform an outside contraction
            xc = (1 + psi * rho) * xbar - psi * rho * v(:,np1);
            qvec(index) = xc; q = cell2struct(mat2cell(qvec, ones(np, 1), [1]), parnm);
            eval(['[f, f_test] = ', func, '(q, data, auxData);']);
            eval(['fxc = W'' * ([', listf, '] - Y).^2;']);
            func_evals = func_evals + 1;
            
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
            xcc = (1 - psi) * xbar + psi * v(:,np1);
            qvec(index) = xcc; q = cell2struct(mat2cell(qvec, ones(np, 1), [1]), parnm);
            eval(['[f, f_test] = ', func, '(q, data, auxData);']);
            eval(['fxcc = W'' * ([', listf, '] - Y).^2;']);
            func_evals = func_evals + 1;
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
            for j = two2np1
               f_test = 0;
               step_reducer = 1;             % step_reducer will serve to reduce usual_delta if the parameter set does not pass the filter
               while ~f_test
                  v_test = v(:,1) + sigma / step_reducer * (v(:,j) - v(:,1));
                  qvec(index) = v_test; q = cell2struct(mat2cell(qvec, ones(np, 1), [1]), parnm);
                  eval(['[f, f_test] = ', func, '(q, data, auxData);']);
               end
               v(:,j) = v_test;
               eval(['fv(:,j) = W'' * ([', listf, '] - Y).^2;']);
            end
            func_evals = func_evals + n_par;
         end
      end
   end
   [fv,j] = sort(fv);
   v = v(:,j);
   itercount = itercount + 1;
   if report == 1
     fprintf(['step ', num2str(itercount), ' ssq ', num2str(min(fv)), ...
	     '-', num2str(max(fv)), ' ', how, '\n']);
   end  
   end   % while


   qvec(index) = v(:,1); q = cell2struct(mat2cell(qvec, ones(np, 1), [1]), parnm);
   q.free = free; % add substructure free to q,

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