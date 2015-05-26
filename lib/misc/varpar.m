function [p, equi] = varpar (fn, X0, par, start, stop, np)
  %% Created at 2000/08/01 by Bas Kooijman
  %
  %% Description
  %  Finds equilibrium of a set of ode's as a function of one parameter
  %
  %% Input
  %  fn: name of function that defines a set of ode's (see lsode)
  %  X0: initial_values, row-matrix of values of variables for which ode's
  %      are given; used to obtain equilibrium value by integration 
  %  par: name of parameter that is changed
  %  start: first value of parameter that is changed
  %  stop: last value of parameter that is changed
  %  np: number of parameter values for which equilibrium is evaluated 
  %
  %% Output
  %  p: (n, 1)-matrix of parameter values
  %  equi: (n, k)-matrix of equilibrium values
  %
  %% Remarks
  %  The ode's are first integrated to obtain an initial guess for the
  %    equilibrium values, given parameter value equals `start'.
  %  The equilibrium values serve as initial guesses for the next parameter value. 
  %  This assumes that the system has a point attractor at parameter value `start'. 
  %  The used-defined function fn_name should define the parameter as global.
  %  Requires: 
  %   int2equi, newton, numdif
  %   user-defined function 'fn_name' for ode's, see lsode
  %   global parameter 'par_name'
  %  See also: varpar2

  %% Code
  eval(['global ', par, ';']);
  eval(['value = ', par, ';']); % grab current value of parameter

  % fill output for p, and initiate equi
  p = linspace (start, stop, np); p = p.';
  [nr, nc] = size(X0); equi = zeros (np, nc);

 
  eval([par, ' = start;']);   %% set par values at start 
  Xi = int2equi (fn, X0);     %% the start value is now contained in Xi

  for i = 1:np
    eval([par, ' = p(i);']);
    [Xi, info] = fsolve (fn, Xi);
    equi(i,:) = Xi.';

    if info ~= 1
      perror('fsolve', info);
    end

  end
  eval([par, ' = value;']);    % restore value of parameter
