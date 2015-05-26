%% get_lp_md
% Gest scaled length at puberty

%%
function [lp, lb, info] = get_lp_md (p, f, lb0)
  % created at 2015/03/31 by Bas Kooijman, 

  %% Syntax
  % [lp, lb, info] = <../get_lp_md.m *get_lp_md*> (p, f, lb0)
  
  %% Description
  % Obtains scaled length at puberty at constant food density for specified maturity density. 
  %
  % Input
  %
  % * p: 5-vector with parameters: kap, g, k, e_H^b, e_H^p 
  % * f: optional scalar with scaled functional responses (default 1)
  % * lb0: optional scalar with scaled length at birth
  %
  % Output
  %
  % * lp: scalar with scaled length at puberty
  % * lb: scalar with scaled length at birth
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % See <get_lp.html *get_lp*>, for pubert at specified maturity 

  %% Example of use
  % get_lp_md([.5, .1, 0, .6, 1.9])
  
  % unpack pars
  g   = p(1); % -, energy investment ratio
  k   = p(2); % -, k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % -, scaled heating length {p_T}/[p_M]
  gHb = p(4); % -, g_H^b = E_H^b/ L_b^3/ [E_m]/ (1 - kap)
  gHp = p(5); % -, g_H^p = E_H^p/ L_p^3/ [E_m]/ (1 - kap)

  if gHb < g || gHb > gHp || gHp > g/k
    info = 0;
    lb = []; lp = [];
    fprintf('warning get_lp_md: gHb or gHp outside range \n');
    return
  end

  if ~exist('f', 'var') || isempty(f)
    f = 1; 
  end
  
  if ~exist('lb0', 'var')
    lb0 = [];
  end
  [lb, info] = get_lb_md([g; k; gHb], f, lb0);
  
  [gH l] = ode45(@dfn_l, [gHb; gHp], lb, [], g, k, lT, f);
  lp = l(end); 

end
  
function dl = dfn_l(gH, l, g, k, lT, f)

  dl = (f - lT - l) * g/ 3/ (f + g);
  dgH = g * f * (l + g)/ l/ (f + g) - gH * (k + g * (f - l)/ l/ (f + g));
  dl = dl/ dgH;
end
