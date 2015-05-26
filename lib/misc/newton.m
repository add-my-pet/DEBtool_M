function [x, info] = newton (fn, x0, newton_imax, newton_stm)
  % Created: 2000/10/05 by Bas Kooijman; modified 2009/09/29
  %
  %% Description
  %  solves x from 0 = fn(x) by Newton Raphson; starting from x0
  %
  %% Remarks
  %  Requires: numdif, user-defined function 'fn'
    
  newton_norm = 1e-10; % norm for successful stop of routine
  if exist('newton_imax','var') == 0
    newton_imax = 5000; % max step number
  end
  if exist('newton_stm','var') == 0
    newton_stm = 1e3; % max step size
  end
  
  x = x0;    % initiate output var
  crit = 1 + newton_norm; i = 1;
  
  while crit > newton_norm && i <= newton_imax 
    eval(['f = ', fn, '(x);']);
    dfx = numdif(fn, x, f)\f;
    st = dfx'*dfx;
    c = min(newton_stm,st)/st;
    x = x - c*dfx;
    crit = f.'*f; i=i+1; % criterion is sum of squared derivetives
  end
  if crit < newton_norm && i < newton_imax
    info = 1; % successfull stop
  else
    info = 0; % unsuccessfull stop
    fprintf(['warning: no convergence within ', num2str(newton_imax), ...
        ' Newton steps \n']);
  end
  