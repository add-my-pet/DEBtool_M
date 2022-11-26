%% get_tR
% Gets scaled age at 1st brood

%%
function [tau_R, tau_p, tau_x, tau_b, lR, lp, lx, lb, info] = get_tR(p, f, lb0)
  % created at 2016/11/24 by Bas Kooijman
  
  %% Syntax
  % [tau_R, tau_p, tau_x, tau_b, lR, lp, lx, lb, info] = <../get_tR.m *get_tR*>(p, f, lb0)
  
  %% Description
  % Obtains scaled age and length at 1st brood, puberty, fledging, birth.
  % Food density is assumed to be constant.
  % Multiply the result with the somatic maintenance rate coefficient to arrive at ages. 
  %
  % Input
  %
  % * p: 7-vector with parameters: g, k, l_T, v_H^b, v_H^x, v_H^p, tau_N 
  % * f: optional scalar with functional response (default f = 1)
  % * lb0: optional scalar with scaled length at birth
  %
  % Output
  %
  % * tau_R: scaled with age at 1st brood \tau_R = a_R k_M
  % * tau_p: scaled with age at puberty \tau_p = a_p k_M
  % * tau_x: scaled with age at fledge \tau_x = a_x k_M
  % * tau_b: scaled with age at birth \tau_b = a_b k_M
  % * lR: scaler length at 1st brood
  % * lp: scaler length at puberty
  % * lx: scaler length at fledging
  % * lb: scaler length at birth
  % * info: indicator equals 1 if successful
  
  %% Remarks
  % Notice that scaled time between litters, tau_N = t_N * k_M, depends on temperature, so does lR

  %% Example of use
  % get_tR([.5, .1, 0, .01, .02, .2, .6])

  %  unpack pars
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % scaled heating length {p_T}/[p_M]Lm
  vHb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = M_H^b/ {J_EAm} = E_H^b/ {p_Am}
  vHx = p(5); % v_H^x = U_H^x g^2 kM^3/ (1 - kap) v^2; U_H^x = M_H^x/ {J_EAm} = E_H^x/ {p_Am}
  vHp = p(6); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_H^p = M_H^p/ {J_EAm} = E_H^p/ {p_Am}
  tN  = p(7); % tau_N = t_N * k_M, where t_N is time between clutches
  
  if ~exist('f', 'var')
    f = 1;
  elseif isempty(f)
    f = 1;
  end
  if ~exist('lb0', 'var')
    lb0 = [];
  end

  if k == 1 && f * (f - lT)^2 > vHp * k
    lb = vHb^(1/3); 
    tb = get_tb([g, k, v_Hb], f, lb);
    lp = vHp^(1/3);
    li = f - lT;
    rB = 1 / 3/ (1 + f/g);
    tau_p = tb + log((li - lb)/ (li - lp))/ rB;
    info = 1;
  elseif f * (f - lT)^2 <= vHx * k % fledging is not reached
    [tau_b lb] = get_tb ([g, k, vHb], f, lb0); 
    tau_x = NaN; lx = NaN; % lx is never reached
    tau_p = NaN; lp = NaN; % lp is never reached
    tau_R = NaN; lR = NaN; 
    info = 0;
  elseif f * (f - lT)^2 <= vHp * k % reproduction is not possible
    [tau_b, lb] = get_tb ([g, k, vHb] , f, lb0); 
    li = f - lT; irB = 3 * (1 + f/ g); % k_M/ r_B
    [lx, lb] = get_lp([g, k, lT, vHb, vHx], f, lb);
    tau_x = tau_b + irB * log((li - lb)/ (li - lx));
    tau_p = NaN; lp = NaN; 
    tau_R = NaN; lR = NaN; 
    info = 0; 
  else % reproduction is possible
    [tau_b, lb, info] = get_tb ([g, k, vHb], f, lb0); 
    options = odeset('Events', @event_xpR); 
    [tau, vHlR, tau_xpR, vHlR_xpR] = ode45(@dget_vHlR, [0; 1e20], [vHb; lb; 0], options, f, g, k, lT, vHx, vHp, tN);
    if length(tau_xpR)<3
       tau_R = []; tau_p = []; tau_x = []; tau_b =[]; lR = [];  lp = [];  lx = [];  lb = [];  info = 0;
       return
    end
    tau_x = tau_b + tau_xpR(1); tau_p = tau_b + tau_xpR(2); tau_R = tau_b + tau_xpR(3); 
    lx = vHlR_xpR(1,2); lp = vHlR_xpR(2,2); lR = vHlR_xpR(3,2);
    if ~isreal(tau_b) || ~isreal(tau_x) || ~isreal(tau_p) || ~isreal(tau_R) || ...
       isempty(tau_b) || isempty(tau_x) || isempty(tau_p) || isempty(tau_R) || ... 
       tau_b < 0 || tau_x < 0 || tau_p < 0 || tau_R < 0 % tb, tx, tp and tR must be real and positive and non-empty
      info = 0;
    end
  end
end

%% subfunctions

function dvHlR = dget_vHlR (t, vHlR, f, g, k, lT, vHx, vHp, tN)
  vH = vHlR(1); l = vHlR(2); R = vHlR(3);
  li = f - lT;
  dl = (g/ 3) * (li - l)/ (f + g);  % d/d tau l
  if vH <= vHp
    dvH = 3 * l^2 * dl + l^3 - k * vH;% d/d tau vH
    dR = 0;
  else
    dvH = 0;
    dR = f * (1 + (g + lT)/ l)/ (f + g) - k * vHp/ l^3;
  end
  dvHlR = [dvH; dl; dR];                 % pack to output
end

function [value,isterminal,direction] = event_xpR(t, vHlR, f, g, k, lT, vHx, vHp, tN)
  % vHlR: 3-vector with [vH; l; R]
  value = [[vHx; vHp] - vHlR(1); vHlR(3) - tN * (1 - k * vHp/ f^3)];
  isterminal = [0; 0; 1];
  direction = [0; 0; 0]; 
end