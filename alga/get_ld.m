function [ld, info] = get_ld (p, f, ld0)
  %  created at 2014/10/10 by Bas Kooijman
  %
  %% Description
  %  Obtains scaled length at division at constant food density. 
  %
  %% Input
  %  p: 3-vector with parameters: g, k, v_H^d 
  %  f: optional scalar with scaled functional responses (default 1)
  %  ld0: optional scalar with scaled length at division
  %  
  %% Output
  %  ld: scalar with scaled length at division
  %  info: indicator equals 1 if successful, 0 otherwise
  %
  %% Example of use
  %    get_ld([.5, .1, .2])
  
  %% Code
  % unpack pars
  g   = p(1); % -, energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  vHd = p(3); % v_H^d = U_H^d g^2 kM^3/ (1 - kap) v^2; U_H^d = M_H^d/ {J_EAm} = E_H^d/ {p_Am}

  if exist('f', 'var') == 0 
    f = 1; 
  elseif  isempty(f)
    f = 1; 
  end

  if exist('ld0', 'var') == 0
    ld0 = vHd^(1/3);
  elseif isempty(ld0)
    ld0 = vHd^(1/3);
  end
  
  if k == 1
    ld = vHd^(1/3);
    info = 1;
    return
  end
  
  [ld fval info] = fzero(@fnget_ld, ld0, [], f, g, k, vHd);
  
end

%% subfunctions

function fn = fnget_ld(ld, f, g, k, vHd)
 [vH l] = ode45(@dget_ld, [vHd/ 2; vHd], ld/ 2^(1/3), [], f, g, k); 
 fn = ld - l(end); 
end
  
function dl = dget_ld(vH, l, f, g, k)
 dl = (f - l) * g/ (3 * f * l^2 * (g + l) - k * vH * (g + f));  
end
  