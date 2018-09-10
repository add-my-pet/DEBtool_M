%% get_ts
% Get scaled age at start acceleration

%%
function [tau_s, tau_j, tau_p, tau_b, ls, lj, lp, lb, li, rj, rB, info] = get_ts(p, f, lb0)
  % created at 2011/07/21 by Bas Kooijman
  % modified 2014/03/03 Starrlight Augustine, 2015/01/18 Bas Kooijman
  % modified 2018/09/10 (t -> tau) Nina Marn
  
  %% Syntax
  % [tau_s, tau_j, tau_p, tau_b, ls, lj, lp, lb, li, rj, rB, info] = <../get_ts.m *get_ts*> (p, f, lb0)
  
  %% Description
  % Obtains scaled ages at settlement, metamorphosis, puberty, birth and the scaled lengths at these ages. 
  % Metabolic acceleration occurs between settlement and metamorphosis, see also get_tj. 
  % Multiply the result with the somatic maintenance rate coefficient to arrive at unscaled ages.
  % Notice s-j-p-b sequence in output, due to the name of the routine
  %
  % Input
  %
  % * p: 7-vector with parameters: g, k, l_T, v_H^b, v_H^s, v_H^j, v_H^p 
  % * f: optional scalar with functional response (default f = 1)
  % * lb0: optional scalar with scaled length at birth
  %  
  % Output
  %
  % * tau_s: scaled with age at start of V1-stage \tau_s = a_s k_M 
  % * tau_j: scaled with age at end of V1-stage \tau_j = a_j k_M 
  % * tau_p: scaled with age at puberty \tau_p = a_p k_M
  % * tau_b: scaled with age at birth \tau_b = a_b k_M
  % * ls: scaled length at start of V1-stage
  % * lj: scaled length at end of V1-stage
  % * lp: scaled length at puberty
  % * lb: scaled length at birth
  % * li: ultimate scaled length
  % * rj: scaled exponential growth rate between s and j
  % * rB: scaled von Bertalanffy growth rate between b and s and between j and i
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Example of use
  % See <../mydata_get_ts.m *mydata_get_ts*>
  
  % unpack pars
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % scaled heating length {p_T}/[p_M]Lm
  vHb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_B^b = M_H^b/ {J_EAm}
  vHs = p(5); % v_H^s = U_H^s g^2 kM^3/ (1 - kap) v^2; U_B^s = M_H^s/ {J_EAm}
  vHj = p(6); % v_H^j = U_H^j g^2 kM^3/ (1 - kap) v^2; U_B^j = M_H^j/ {J_EAm}
  vHp = p(7); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_B^p = M_H^p/ {J_EAm}
  
  if ~exist('f','var')
    f = 1;
  elseif isempty(f)
    f = 1;
  end
  if ~exist('lb0','var')
    lb0 = [];
  end

  if k == 1 && f * (f - lT)^2 > vHp * k % constant maturity density, reprod possible
    lb = vHb^(1/3);                  % scaled length at birth
    tau_b = get_tb(p([1 2 4]), f, lb);  % scaled age at birth
    ls = vHs^(1/3);                  % scaled length at settlement
    rB = 1/ 3/ (1 + f/ g);           % scaled von Bert growth rate 
    li = f - lT;                     % scaled ultimate length
    tau_s = tau_b + log ((li - lb)/ (li - ls))/ rB; % scaled age at settlement
    lj = vHj^(1/3);                  % scaled length at metamorphosis
    sM = lj/ ls;                     % acceleration factor
    rj = g * (f/ ls - 1 - lT/ ls)/ (f + g); % scaled exponential growth rate between s and j
    tau_j = tau_s + log(sM) * 3/ rj;       % scaled age at metamorphosis
    lp = vHp^(1/3);                  % scaled length at puberty
    li = f * sM - lT;                % scaled ultimate length
    tau_p = tau_j + log ((li - lj)/ (li - lp))/ rB; % scaled age at puberty
    info = 1;
    return
  elseif k == 1 && f * (f - lT)^2 > vHj * k % constant maturity density, metam possible
    lb = vHb^(1/3);                  % scaled length at birth
    tau_b = get_tb(p([1 2 4]), f, lb);  % scaled age at birth
    ls = vHs^(1/3);                  % scaled length at settlement
    sM = lj/ ls;                     % acceleration factor
    rB = 1/ 3/ (1 + f/ g);           % scaled von Bert growth rate 
    li = f - lT;                     % scaled ultimate length
    tau_s = tau_b + log ((li - lb)/ (li - ls))/ rB; % scaled age at settlement
    lj = vHj^(1/3);                  % scaled length at metamorphosis
    rj = g * (f/ ls - 1 - lT/ ls)/ (f + g); % scaled exponential growth rate between b and j
    tau_j = tau_s + (log(sM)) * 3/ rj;     % scaled age at metamorphosis
    lp = vHp^(1/3);                  % scaled length at puberty
    li = f * sM - lT;                % scaled ultimate length
    tau_p = 1e20;                       % scaled age at puberty
    info = 1;
    return
  elseif k == 1 && f * (f - lT)^2 > vHs * k % constant maturity density, settlement possible
    lb = vHb^(1/3);                  % scaled length at birth
    tau_b = get_tb(p([1 2 4]), f, lb);  % scaled age at birth
    ls = vHs^(1/3);                  % scaled length at settlement
    rB = 1/ 3/ (1 + f/ g);           % scaled von Bert growth rate 
    li = f - lT;                     % scaled ultimate length
    tau_s = tau_b + log ((li - lb)/ (li - ls))/ rB; % scaled age at settlement
    lj = vHj^(1/3);                  % scaled length at metamorphosis
    sM = lj/ ls;                     % acceleration factor
    rj = g * (f/ ls - 1 - lT/ ls)/ (f + g);   % scaled exponential growth rate between b and j
    tau_j = 1e20;                       % scaled age at metamorphosis
    lp = vHp^(1/3);                  % scaled length at puberty
    li = f * sM - lT;                % scaled ultimate length
    tau_p = 1e20;                       % scaled age at puberty
    info = 1;
    return
  end
  
  [tau_b, lb, info_tb] = get_tb (p([1 2 4]), f, lb0);
  [ls, lj, lp, lb, info_ts] = get_ls(p, f, lb);
  sM = lj/ ls;                       % acceleration factor
  rj = g * (f/ ls - 1 - lT/ ls)/ (f + g); % scaled exponential growth rate between s and j
  rB = 1/ 3/ (1 + f/ g);             % scaled von Bert growth rate 
  li = f - lT;                       % scaled ultimate length
  tau_s = tau_b + log((li - lb)/ (li - ls))/ rB; % scaled age at start acceleration
  tau_j = tau_s + log(sM) * 3/ rj;         % scaled age at metamorphosis
  rB = 1/ 3/ (1 + f/ g);             % scaled von Bert growth rate between j and i
  li = f * sM - lT;                  % scaled ultimate length

  if li <=  lp                       % reproduction is not possible
    tau_p = 1e20;                       % tau_p is never reached
    lp = 1;                          % lp is nerver reached
  else % reproduction is possible
    tau_p = tau_j + log((li - lj)/ (li - lp))/ rB;
  end
  
  info = min(info_tb, info_ts);
  if isreal(tau_p) == 0 || isreal(tau_j) == 0 || isreal(tau_s) == 0 % tau_s, tau_j and tau_p must be real and positive
    info = 0;
  elseif tau_p < 0 || tau_j < 0 || tau_s < 0
    info = 0;
  end
  