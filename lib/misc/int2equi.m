function  [X, info] = int2equi (fn, X0)
  %  Created: 2000/10/07 by Bas Kooijman 
  %
  %% Description
  %  Integration of a set of ode's specified by 'fn' by 'rkutta'
  %    till equilibrium, but switch to 'newton' if derivetives are small
  %
  %% Input
  %    fn: string, for user-defined function of structure dX = fn (X)
  %        dX, X are vectors of equal lengths
  %    X0: vector, value of vector X at t=0
  %
  %% Remarks
  %  Requires: userdefined function 'fn'
  
  int2equi_imax = 5;   % max number of integration trials
  
  i = 0; X0 = X0(:); X = X0; info = 0;
  while i <= int2equi_imax     % start solve/integration procedure
    [X, info] = newton(fn, X0, 50); % we first try to find value directly
      if info == 1             % successfull stop
        return;                % solution found 
      end
      i=i+1; % if direct search failed, we integrate and try again
      if i == 1
         int2equi_period = 100; % d, integration period before next Newton trial
      else
         int2equi_period = 50; % d, integration period before next Newton trial
      end
      
      [t, X0] = rkutta (fn, X0, int2equi_period); % new start value in X0
      X0 = X0(end,:)';
      fprintf(['integration completed over a period of ', num2str(int2equi_period), ...
          ' d for trial ', num2str(i+1), ' \n']);
  end
 
  if i >= int2equi_imax
    fprintf(['warning: no convergence within ', num2str(int2equi_imax), ...
        ' integration trials \n']);
  else
    info = 1; % successfull stop
  end
 



