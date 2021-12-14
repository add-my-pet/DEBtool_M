%% get_tx
% gets scaled age and length at puberty, weaning, birth for foetal development.

%%
function [tau_p, tau_x, tau_b, lp, lx, lb, info] = get_tx_old(p, f)
  % created 2012/08/18 by Bas Kooijman, modified 2014/07/22
  % last modified by Dina Lika 2016/03/21
  % modified 2018/09/10 (t -> tau) Nina Marn
  
  %% Syntax
  % [tau_p, tau_x, tau_b, lp, lx, lb, info] = <../get_tx_old.m *get_tx*> (p, f)
  
  %% Description
  % Obtains scaled age and length at puberty, weaning, birth for foetal development. 
  % An extra optional parameter, the stress coefficient for foetal development can modify the rate of development from fast 
  %    (default, and a large stress coefficient of 1e8) to slow (value 1 gives von Bertalanffy growth of the same rate as post-natal development). 
  % Multiply the result with the somatic maintenance rate coefficient to arrive at age at puberty, weaning and birt. 
  % Assumes von Bert growth since age 0
  %
  % Input
  %
  % * p: 6-vector with parameters (see below)
  % * f: scalar with scaled functional response
  %
  % Output
  %
  % * tau_p, tau_x, tau_b: scalars with scaled age at puberty, weaning, birth
  % * lp, lx, lb: scalers with scaled length at puberty, weaning, birth
  % * info: indicator equals 1 if successful, 0 otherwise
  %
  %% Remarks
  % uses dget_lx; this is an obsolate function, now replaced by get_tx, due to inaccuracy if l_p is close to l_i

  % unpack pars
  g   = p(1); % -, energy investment ratio
  k   = p(2); % -, k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % -, scaled heating length
  vHb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_B^b = M_H^b/ {J_EAm}
  vHx = p(5); % v_H^x = U_H^x g^2 kM^3/ (1 - kap) v^2; U_B^x = M_H^x/ {J_EAm}
  vHp = p(6); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_B^p = M_H^p/ {J_EAm}
  if length(p) >= 7
    sF = p(7); % slow development: sF = 1, for sF > 1 intermediate between slow and fast
  else
    sF = 1e10;  % fast development
  end
  options = odeset('AbsTol',1e-10, 'RelTol',1e-10);
  [vH l] = ode45(@dget_lx, [0; vHb; vHx; vHp], 1e-20, options, f, g, k, lT, vHb, sF);
  info = 1;
  l(1) = []; lb = l(1); lx = l(2); lp = l(3); li = f - lT;
  tau_b = - 3 * (1 + sF * f/ g) * log(1 - lb/ sF/ f);
  %tb = 3 * lb/ g;
  tau_x = tau_b + 3 * (1 + f/ g) * log((li - lb)/ (li - lx));
  tau_p = tau_b + 3 * (1 + f/ g) * log((li - lb)/ (li - lp));
  if isreal(tau_b) == 0 || isreal(tau_x) == 0 || isreal(tau_p) == 0 % tb, tx and tp must be real and positive
    info = 0;
  elseif tau_b < 0 || tau_x < 0 || tau_p < 0
    info = 0;
  end

end

% subfuction

function dl = dget_lx (vH, l, f, g, k, lT, vHb, sF)
if vH < vHb
  li = sF * f; % -, scaled ultimate length
  f  = sF * f; % -, scaled functional response
else
  li = f - lT;
end
dl = (g/ 3) * (li - l)/ (f + g);  % d/d tau l
dvH = 3 * l^2 * dl + l^3 - k * vH;% d/d tau vH
dl = dl/ dvH;                     % d/d v_H l
end

