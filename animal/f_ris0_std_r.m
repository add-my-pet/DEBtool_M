%% f_ris0_std_r
% Gets scaled functional response at with the specific population growth rate is zero

%%
function [f, S_b, S_p, aT_b, tT_p, info] = f_ris0_std_r (par, f_0)
  % created 2019/07/09 by Bas Kooijman
  
  %% Syntax
  % [f, S_b, S_p, aT_b, tT_p, info] = <../f_ris0_std_r.m *f_ris_std_r0*> (par, f_0)
  
  %% Description
  % Obtains the scaled function response at which specific population growth rate for the standard DEB model equals zero, 
  %   by solving the characteristic equation.  
  %
  % Input
  %
  % * par: structure parameter
  % * f_0: optional scalar with func response for which maturation ceases at puberty (see <get_ep_min.html *get_ep_min*>)
  %
  % Output
  %
  % * f: scaled func response at which r = 0 for the std model
  % * S_b: survival prob at birth
  % * S_p: survival prob at puberty
  % * aT_b: age at birth
  % * tT_p: time since birth at puberty
  % * info: scalar with indicator for failure (0) or success (1)
  
  %% Remarks
  % Shell around <sgr_std.html *sgr_std*>, using a bisection method.

  if ~exist('f_0', 'var')
    % unpack par and compute statisitics
    cPar = parscomp_st(par); vars_pull(par);  vars_pull(cPar);  
    
    f_0 = 5e-4 + get_ep_min([k; l_T; v_Hp]);
  end

  % initialize range for f
  f_1 = 1;         % upper boundary (lower boundary is f_0)
  [norm, S_b, S_p, aT_b, tT_p, info] = sgr_std(par, [], f_1);
  if info == 0
    f = NaN; S_b = NaN; S_p = NaN; return
  end
  norm = 1; i = 0; % initialize norm and counter

  while i < 100 && norm^2 > 1e-16 && f_1 - f_0 > 1e-4 % bisection method
    i = i + 1;
    f = (f_0 + f_1)/ 2;
    [norm, S_b, S_p, aT_b, tT_p, info] = sgr_std(par, [], f);
    if norm > 1e-3 && info == 1
        f_1 = f;
    else
        f_0 = f; norm = 1;
    end
  end

  if i == 100
    info = 0;
    fprintf('f_ris0_std_r warning: no convergence for f in 100 steps\n')
  elseif f_1 - f_0 > 1e-4
    info = 0;
    fprintf('f_ris0_std_r warning: interval for f < 1e-4, norm = %g\n', norm)
  else
    info = 1;
  end
