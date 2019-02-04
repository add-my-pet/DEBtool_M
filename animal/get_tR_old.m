%% get_tR_old
% Gets scaled age at 1st brood

%%
function [tR, tp, tx, tb, lR, lp, lx, lb, info] = get_tR_old(p, f, lb0)
  % created at 2016/11/24 by Bas Kooijman
  
  %% Syntax
  % [tR, tp, tx, tb, lR, lp, lx, lb, info] = <../get_tp.m *get_tR_old*>(p, f, lb0)
  
  %% Description
  % Obtains scaled age and length at 1st brood, puberty, fledging, birth.
  % Food density is assumed to be constant.
  % Multiply the result with the somatic maintenance rate coefficient to arrive at ages. 
  %
  % Input
  %
  % * p: 5-vector with parameters: g, k, l_T, v_H^b, v_H^x, v_H^p, tau_N 
  % * f: optional scalar with functional response (default f = 1)
  % * lb0: optional scalar with scaled length at birth
  %
  % Output
  %
  % * tR: scaled with age at 1st brood \tau_R = a_R k_M
  % * tp: scaled with age at puberty \tau_p = a_p k_M
  % * tx: scaled with age at birth \tau_x = a_x k_M
  % * tb: scaled with age at birth \tau_b = a_b k_M
  % * lR: scaler length at 1st brood
  % * lp: scaler length at puberty
  % * lx: scaler length at fledging
  % * lb: scaler length at birth
  % * info: indicator equals 1 if successful
  
  %% Remarks
  % This is an obsolate function, which is replaced by get_tR

  %% Example of use
  % get_tp([.5, .1, .1, .01, .2])

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
    tp = tb + log((li - lb)/ (li - lp))/ rB;
    info = 1;
  elseif f * (f - lT)^2 <= vHx * k % fledging is not reached
    [tb lb] = get_tb ([g, k, vHb], f, lb0); 
    tx = NaN; lx = NaN; % lx is never reached
    tp = NaN; lp = NaN; % lp is never reached
    tR = NaN; lR = NaN; 
    info = 0;
  elseif f * (f - lT)^2 <= vHp * k % reproduction is not possible
    [tb, lb] = get_tb ([g, k, vHb] , f, lb0); 
    li = f - lT; irB = 3 * (1 + f/ g); % k_M/ r_B
    [lx, lb] = get_lp([g, k, lT, vHb, vHx], f, lb);
    tx = tb + irB * log((li - lb)/ (li - lx));
    tp = NaN; lp = NaN; 
    tR = NaN; lR = NaN; 
    info = 0;
  else % reproduction is possible
    [tb lb] = get_tb ([g, k, vHb] , f, lb0); 
    li = f - lT; irB = 3 * (1 + f/ g); % k_M/ r_B
    [lx, lb] = get_lp([g, k, lT, vHb, vHx], f, lb);
    tx = tb + irB * log((li - lb)/ (li - lx));
    [lp, lb, info] = get_lp([g, k, lT, vHb, vHp], f, lb0);
    tp = tb + irB * log((li - lb)/ (li - lp));
    tR = tp + fzero(@fntR, tN, [], f, tp, lp, li, irB, g, lT, k, vHp, tN); 
    lR = li - (li - lp) * exp(- (tR - tp)/ irB);
  end
  
  if ~isreal(tp) % tp must be real and positive
      info = 0;
  elseif tp < 0
      info = 0;
  end
end

%% subfunctions

function f = fntR(tR, f, tp, lp, li, irB, g, lT, k, vHp, tN)
  pR = quad(@fnpR, tp, tp + tR, [], [], f, tp, lp, li, irB, g, lT, k, vHp);
  f = 1 - k * vHp/ f^3 - pR(end)/ tN;
end

function pR = fnpR(t, f, tp, lp, li, irB, g, lT, k, vHp)
  l = li - (li - lp) * exp(- (t- tp)/ irB);
  pR = f * (1 + (g + lT) ./ l)/ (f + g) - k * vHp ./ l .^ 3;
end