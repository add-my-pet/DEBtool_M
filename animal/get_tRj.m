%% get_tRj
% Gets scaled age at 1st brood for abj model

%%
function [tau_R, tau_p, tau_j, tau_b, lR, lp, lj, lb, info] = get_tRj(p, f)
  % created at 2020/07/30 by Bas Kooijman
  
  %% Syntax
  % [tR, tp, tj, tb, lR, lp, lj, lb, info] = <../get_tRj.m *get_tRj*>(p, f)
  
  %% Description
  % Obtains scaled age and length at 1st brood, puberty, metam, birth for abj model.
  % Food density is assumed to be constant.
  % Multiply the result with the somatic maintenance rate coefficient to arrive at ages. 
  %
  % Input
  %
  % * p: 6-vector with parameters: g, k, v_H^b, v_H^j, v_H^p, tau_N 
  % * f: optional scalar with functional response (default f = 1)
  %
  % Output
  %
  % * tau_R: scaled with age at 1st brood \tau_R = a_R k_M
  % * tau_p: scaled with age at puberty \tau_p = a_p k_M
  % * tau_j: scaled with age at metam \tau_j = a_j k_M
  % * tau_b: scaled with age at birth \tau_b = a_b k_M
  % * lR: scaler length at 1st brood
  % * lp: scaler length at puberty
  % * lj: scaler length at metam
  % * lb: scaler length at birth
  % * info: indicator equals 1 if successful
  
  %% Remarks
  % Notice that scaled time between litters, tau_N = t_N * k_M, depends on temperature, so does lR
  
  %% Example of use
  % get_tRj([.5, .1, .01, .02, .2, .6])

  %  unpack pars
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  vHb = p(3); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = M_H^b/ {J_EAm} = E_H^b/ {p_Am}
  vHj = p(4); % v_H^j = U_H^j g^2 kM^3/ (1 - kap) v^2; U_H^j = M_H^j/ {J_EAm} = E_H^j/ {p_Am}
  vHp = p(5); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_H^p = M_H^p/ {J_EAm} = E_H^p/ {p_Am}
  tN  = p(6); % tau_N = t_N * k_M, where t_N is time between clutches
  
  if ~exist('f', 'var') || isempty(f)
    f = 1;
  end

  [tau_b, lb, info] = get_tb ([g, k, vHb] , f); 
  if info == 0
    tau_R = []; tau_p = []; tau_j = []; tau_b =[]; lR = []; lp = [];  lj = []; lb = []; return
  end
  options = odeset('Events', @event_jpR, 'RelTol', 1e-8, 'AbsTol', 1e-8); 
  [tau, vHlR, tau_jpR, vHlR_jpR] = ode45(@dget_vHlR, [0; 1e20], [vHb; lb; 0], options, f, lb, g, k, vHj, vHp, tN);
  if length(tau_jpR)<3
    tau_R = []; tau_p = []; tau_j = []; tau_b =[]; lR = []; lp = []; lj = []; lb = []; info = 0; return
  end

  tau_j = tau_b + tau_jpR(1); tau_p = tau_b + tau_jpR(2); tau_R = tau_b + tau_jpR(3); 
  lj = vHlR_jpR(1,2); lp = vHlR_jpR(2,2); lR = vHlR_jpR(3,2);
  
  if isreal(tau_b) == 0 || isreal(tau_j) == 0 || isreal(tau_p) == 0 || isreal(tau_R) == 0 % tb, tx, tp and tR must be real and positive
    info = 0;
  elseif tau_b < 0 || tau_j < 0 || tau_p < 0 || tau_R < 0 
    info = 0;
  end
  
end

%% subfunctions

function dvHlR = dget_vHlR (t, vHlR, f, lb, g, k, vHj, vHp, tN)
  vH = vHlR(1); l = vHlR(2); R = vHlR(3);
  if vH <= vHj
    rho_j = (f/ lb - 1)/ (1 + f/ g);
    dl = l * rho_j/ 3;  % d/d tau l
    dvH = 3 * l^2 * dl + l^3 - k * vH; % d/d tau vH
    dR = 0;
  elseif vH <= vHp
    dl = (g/ 3) * (f - l)/ (f + g);  % d/d tau l
    dvH = 3 * l^2 * dl + l^3 - k * vH; % d/d tau vH
    dR = 0;
  else
    dl = (g/ 3) * (f - l)/ (f + g);  % d/d tau l
    dvH = 0;
    dR = f * (1 + g/ l)/ (f + g) - k * vHp/ l^3;
  end
  dvHlR = [dvH; dl; dR]; % pack to output
end

function [value,isterminal,direction] = event_jpR(t, vHlR, f, lb, g, k, vHj, vHp, tN)
  % vHlR: 3-vector with [vH; l; R]
  value = [[vHj; vHp] - vHlR(1); vHlR(3) - tN * (1 - k * vHp/ f^3)];
  isterminal = [0; 0; 1];
  direction = [0; 0; 0]; 
end