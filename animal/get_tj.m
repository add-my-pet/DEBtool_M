%% get_tj Gets scaled age at metamorphosis

%%
function [tau_j, tau_p, tau_b, lj, lp, lb, li, rj, rB, info] = get_tj(p, f, lb0)
  % created at 2011/04/25 by Bas Kooijman, 
  % modified 2014/03/03 Starrlight Augustine, 2015/01/18 Bas Kooijman
  % modified 2018/09/10 (t -> tau) Nina Marn
  
  %% Syntax
  % [tau_j, tau_p, tau_b, lj, lp, lb, li, rj, rB, info] = <../get_tj.m *get_tj*> (p, f, lb0)
  
  %% Description
  % Obtains scaled ages at metamorphosis, puberty, birth and the scaled lengths at these ages;
  % Food density is assumed to be constant.
  % Multiply the result with the somatic maintenance rate coefficient to arrive at unscaled ages. 
  % Metabolic acceleration occurs between birth and metamorphosis, see also get_ts. 
  % Notice j-p-b sequence in output, due to the name of the routine
  %
  % Input
  %
  % * p: 5 or 6-vector with parameters: g, k, l_T, v_H^b, v_H^j, v_H^p 
  %
  %     Last value is optional. If ommitted: outputs tp and lp are empty
  %
  % * f: optional scalar with functional response (default f = 1)
  % * lb0: optional scalar with scaled length at birth
  %      or optional 2-vector with scaled length, l, and scaled maturity, vH
  %      for a juvenile that is now exposed to f, but previously at another f
  %  
  % Output
  %
  % * tau_j: scaled age at metamorphosis \tau_j = a_j k_M
  %
  %      if length(lb0)==2, tj is the scaled time till metamorphosis
  %
  % * tau_p: scaled age at puberty \tau_p = a_p k_M
  %
  %      if length(lb0)==2, tp is the scaled time till puberty
  %
  % * tau_b: scaled age at birth \tau_b = a_b k_M
  % * lj: scaled length at end of V1-stage
  % * lp: scaled length at puberty
  % * lb: scaled length at birth
  % * li: ultimate scaled length
  % * rj: scaled exponential growth rate between s and j
  % * rB: scaled von Bertalanffy growth rate between b and s and between j and i
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % See <get_tj_foetus.html *get_tj_foetus*> in case of foetal development
  
  %% Example of use
  %  get_tj([.5, .1, 0, .01, .05, .2])

  n_p = length(p);
  
  % unpack pars
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % scaled heating length {p_T}/[p_M]Lm
  vHb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = E_H^b/ {p_Am}
  vHj = p(5); % v_H^j = U_H^j g^2 kM^3/ (1 - kap) v^2; U_H^j = E_H^j/ {p_Am}
  if n_p > 5
    vHp = p(6); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_H^p = E_H^p/ {p_Am}
  else
    vHp = 0;
  end
    
  if ~exist('f', 'var')
    f = 1;
  elseif isempty(f)
    f = 1;
  end
  if ~exist('lb0','var')
    lb0 = [];
  end

  % no acceleration
  if vHb == vHj 
    if vHp == 0 % no puberty specified
      [tau_b, lb, info] = get_tb(p(1:3), f, lb0);
      tau_j = tau_b; tau_p = []; lp = []; lj = lb; li = f - lT; rj = 0; rB = 1/ 3/ (1 + f/ g);
      return
    else % puberty specified
      [tau_p, tau_b, lp, lb, info] = get_tp(p([1 2 3 4 6]), f, lb0);
      tau_j = tau_b; lj = lb; li = f - lT; rj = 0; rB = 1/ 3/ (1 + f/ g);
      return
    end
  end

  % maintenance ratio k = 1: maturity thresholds coincide with length thresholds
  if k == 1 && f * (f - lT)^2 > vHp * k % constant maturity density, reprod possible
    lb = vHb^(1/3);                  % scaled length at birth
    tau_b = get_tb(p([1 2 4]), f, lb);  % scaled age at birth
    lj = vHj^(1/3);                  % scaled length at metamorphosis
    sM = lj/ lb;                     % acceleration factor
    rj = g * (f/ lb - 1 - lT/ lb)/ (f + g); % scaled exponential growth rate between b and j
    tau_j = tau_b + (log(sM)) * 3/ rj;     % scaled age at metamorphosis
    lp = vHp^(1/3);                  % scaled length at puberty
    li = f * sM - lT;                % scaled ultimate length
    rB = 1/ 3/ (1 + f/ g);           % scaled von Bert growth rate between j and i
    tau_p = tau_j + (log ((li - lj)/ (li - lp)))/ rB; % scaled age at puberty
    info = 1;
    return
  elseif k == 1 && f * (f - lT)^2 > vHj * k % constant maturity density, metam possible
    lb = vHb^(1/3);                  % scaled length at birth
    tau_b = get_tb(p([1 2 4]), f, lb);  % scaled age at birth
    lj = vHj^(1/3);                  % scaled length at metamorphosis
    sM = lj/ lb;                     % acceleration factor
    rj = g * (f/ lb - 1 - lT/ lb)/ (f + g); % scaled exponential growth rate between b and j
    tau_j = tau_b + (log(sM)) * 3/ rj;     % scaled age at metamorphosis
    lp = vHp^(1/3);                  % scaled length at puberty
    li = f * sM - lT;                % scaled ultimate length
    rB = 1/ 3/ (1 + f/ g);           % scaled von Bert growth rate between j and i
    tau_p = 1e20;                    % scaled age at puberty
    info = 1;
    return
  end
  
  if isempty(lb0)
    [tau_b, lb, info_tb] = get_tb (p([1 2 4]), f, lb0); 
  else
    [tau_b, lb, info_tb] = get_tb (p([1 2 4]), f, lb0(1)); 
  end
  [lj, lp, lb, info_tj] = get_lj(p, f, lb);
  if info_tj == 0
     tau_j = [];  tau_p = [];  tau_b = []; lj = []; lp = []; lb = []; li = []; rj = []; rB = [];
     info = 0; return
  end
  sM = lj/ lb;                       % acceleration factor
  rj = g * (f/ lb - 1 - lT/ lb)/ (f + g); % scaled exponential growth rate between b and j
  tau_j = tau_b + log(sM) * 3/ rj;        % scaled age at metamorphosis
  rB = 1/ 3/ (1 + f/ g);             % scaled von Bert growth rate between j and i
  li = f * sM - lT;                  % scaled ultimate length

  if isempty(lp) % length(p) < 6
    tau_p = [];
  elseif  li <=  lp                  % reproduction is not possible
    tau_p = 1e20;                    % tau_p is never reached
    lp = 1;                          % lp is nerver reached
  else % reproduction is possible
    if length(lb0) ~= 2 % lb0 is absent, empty or a scalar
      tau_p = tau_j + log((li - lj)/ (li - lp))/ rB;
    else % lb0 = l and t for a juvenile
      tau_b = NaN;
      l = lb0(1);
      tau_p = log((li - l)/ (li - lp))/ rB;
    end
  end
  
  if isempty(tau_p)
    info = info_tb;
    return
  end
  
  info = min(info_tb, info_tj);
  if ~isreal(tau_p) || ~isreal(tau_j) % tj and tp must be real and positive
    info = 0;
  elseif tau_p < 0 || tau_j < 0 || rj <= 0 || rB <=0
    info = 0;
  end
  