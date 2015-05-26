function [equi, p1, p2, info] = varpar2 (fn, Xi, par1, ...
   start1, stop1, np1, par2, start2, stop2, np2)
  %  Created by Bas Kooijman at 2000/08/01
  %
  %% Description
  %  Finds equilibrium of a set of ode's as a function of two parameters

  %% Usage: [par1, par2, equi] =
  %%   varpar2 ('fn_name', initial_values, 'par1_name', start1, stop1, n1,
  %%            'par2_name', start2, stop2, n2)
  %
  %% Input
  %    fn: name of function that defines a set of ode's (see lsode)
  %    Xi: initial_values, row-matrix of values of variables for which ode's are given; 
  %      used to obtain equilibrium value by integration 
  %    par1: name of first parameter that is changed
  %    start1: first value of first parameter that is changed
  %    stop1: last value of first parameter that is changed
  %    n1: number of first-parameter values for which equilibrium is evaluated
  %    par2: name of second parameter that is changed
  %    start2: first value of second parameter that is changed
  %    stop2: last value of second parameter that is changed
  %    n2: number of second-parameter values for which equilibrium is evaluated
  %
  %% Output
  %    equi: (k, n1, n2)-array of equilibrium values organized in a data-structure:
  %      equi._4 is a (n1, n2) matrix that relates to variable number 4
  %      (assuming that there are at least 4 variables defined in 'fn_name').
  %    p1: (n1, 1)-matrix of parameter values
  %    p2: (n2, 1)-matrix of parameter values
  %
  %% Remarks
  %  The ode's are first integrated to obtain an initial guess for the
  %    equilibrium values, given parameter value equals `start'.
  %  The equilibrium values serve as initial guesses for the next parameter value. 
  %  This assumes that the system has a point attractor at parameter value `start'. 
  %  The used-defined function fn_name should define the parameter as global.
  %  Requires
  %     wrap
  %     user-defined function 'fn_name' for ode's, see lsode
  %     global parameters 'par1_name', 'par2_name'
  %     int2equi
  %  See also: varpar
  
  %% Code
  eval(['global ', par1, ' ', par2,';'])

  % grab current values of parameters, to be restored on return
  eval(['value1 = ', par1,'; value2 = ', par2, ';']);

  % fill output for p1 and p2, and initiate equi  
  p1 = linspace (start1, stop1, np1); p1 = p1.';
  p2 = linspace (start2, stop2, np2); p2 = p2.';
  nc = max(size(Xi));          % number of variables
  equi = zeros (np1, np2, nc); % initiate output matrix

  eval([par1, ' = start1; ', par2, ' = start2;']); % set par values


  Xj = Xi;    % the start value is contained in Xi
  for i = 1:np1    
    eval([par1, ' = p1(i);']);   
    for j = 1:np2
      eval([par2,' = p2(j);']);
      if (i == 1)  % start new row in mesh
        [Xj, info] = int2equi (fn, Xj);	% use last new-row value as start
        Xi = Xj;   % copy result in start value for the rest of new row 
      else	
        [Xi, info] = int2equi (fn, Xi);	% use last new-column value as start
      end
      if (info == 0)
        fprintf(['no convergence for mesh-point (', num2str(i),', ', ...
            num2str(j), ') \n']);
        return
      else
        equi(i,j,:) = Xi.'; % fill result matrix
        fprintf(['mesh-point (', num2str(i),', ', num2str(j), ') done \n']);
      end 
   
    end
  end

 
  % restore values of parameters
  eval([par1, ' = value1; ', par2, ' = value2;']);
 