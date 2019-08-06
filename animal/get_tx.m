%% get_tx
% gets scaled age and length at puberty, weaning, birth for foetal development.

%%
function [tau_p, tau_x, tau_b, lp, lx, lb, info] = get_tx(p, f)
  % created 2019/02/04 by Bas Kooijman
  
  %% Syntax
  % [tau_p, tau_x, tau_b, lp, lx, lb, info] = <../get_tx.m *get_tx*> (p, f)
  
  %% Description
  % Obtains scaled age and length at puberty, weaning, birth for foetal development. 
  % An extra optional parameter, the stress coefficient for foetal development can modify the rate of development from fast 
  %    (default, and a large stress coefficient of 1e8) to slow (value 1 gives von Bertalanffy growth of the same rate as post-natal development). 
  % Multiply the result with the somatic maintenance rate coefficient to arrive at age at puberty, weaning and birth. 
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
  % uses integration over scaled age with event detection; this function replaces get_tx_old 

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

  if isempty(get_lp([g, k, lT, vHb, vHp], f))
    tau_p=[]; tau_x=[]; tau_b=[]; lp=[]; lx=[]; lb=[]; info=0;
    return
  end
  
  options = odeset('Events', @event_bxp, 'AbsTol',1e-9, 'RelTol',1e-9); 
  [tau, vHl, tau_bxp, vHl_bxp] = ode45(@dget_lx, [0; 1e20], [1e-20; 1e-20], options, f, g, k, lT, vHb, vHx, vHp, sF);
  tau_b = tau_bxp(1); tau_x = tau_bxp(2); tau_p = tau_bxp(3); lb = vHl_bxp(1,2); lx = vHl_bxp(2,2); lp = vHl_bxp(3,2);
  info = 1;

  if isreal(tau_b) == 0 || isreal(tau_x) == 0 || isreal(tau_p) == 0 || tau_b < 0 || tau_x < 0 || tau_p < 0 % tb, tx and tp must be real and positive
    info = 0;
  end

end

% subfunctions

function dvHl = dget_lx (t, vHl, f, g, k, lT, vHb, vHx, vHp, sF)
  vH = vHl(1); l = vHl(2);
  if vH < vHb
    li = sF * f; % -, scaled ultimate length
    f  = sF * f; % -, scaled functional response
  else
    li = f - lT;
  end
  dl = (g/ 3) * (li - l)/ (f + g);   % d/d tau l
  dvH = 3 * l^2 * dl + l^3 - k * vH; % d/d tau vH
  dvHl = [dvH; dl];                  % pack to output
end


function [value,isterminal,direction] = event_bxp(t, vHl, f, g, k, lT, vHb, vHx, vHp, sF)
  % vHl: 2-vector with [vH; l]
  value = [vHb; vHx; vHp] - vHl(1);
  isterminal = [0; 0; 1];
  direction  = [0; 0; 0]; 
end
