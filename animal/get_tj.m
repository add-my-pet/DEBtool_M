%% get_tj 
% Gets scaled age at metamorphosis

%%
function varargout = get_tj(p, f, tel_b, tau)
  % created at 2011/04/25 by Bas Kooijman, 
  % modified 2014/03/03 Starrlight Augustine, 2015/01/18 Bas Kooijman
  % modified 2018/09/10 (t -> tau) Nina Marn, 2023/04/05 Bas Kooijman 
  
  %% Syntax
  % varargout = <../get_tj.m *get_tj*> (p, f, tel_b, tau)
  
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
  % * tel_b: optional scalar with scaled length at birth
  %
  %      or 3-vector with scaled age at birth, reserve density and length at 
  %
  % * tau: optional n-vector with scaled times since birth
  %  
  % Output
  %
  % * tvel: optional (n,4)-array with scaled time-since-birth, maturity, reserve density and length
  %
  % * tau_j: scaled age at metamorphosis \tau_j = a_j k_M
  %
  %      if length(lb0)==2, tj is the scaled time till metamorphosis
  %
  % * tau_p: scaled age at puberty \tau_p = a_p k_M
  %
  %      if length(lb0)==2, tp is the scaled time till puberty
  %
  % * tvel: optional (n,4)-array with scaled time-since-birth, maturity, reserve density and length
  % * tau_b: scaled age at birth \tau_b = a_b k_M
  % * l_j: scaled length at end of V1-stage
  % * l_p: scaled length at puberty
  % * l_b: scaled length at birth
  % * l_i: ultimate scaled length
  % * rho_j: scaled exponential growth rate between s and j
  % * rho_B: scaled von Bertalanffy growth rate between b and s and between j and i
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % See <get_tj_foetus.html *get_tj_foetus*> in case of foetal development
  % A previous version of get_tj had as optional 3rd input a 2-vector with scaled length, l, and scaled maturity, vH, for a juvenile that is now exposed to f, but previously at another f.
  % Function <get_tjm *get_tjm*> took over this use.
  
  %% Example of use
  %  get_tj([.5, .1, 0, .01, .05, .2])

  n_p = length(p); 
  
  % unpack pars
  g    = p(1); % energy investment ratio
  k    = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  l_T  = p(3); % scaled heating length {p_T}/[p_M]Lm
  v_Hb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = E_H^b/ {p_Am}
  v_Hj = p(5); % v_H^j = U_H^j g^2 kM^3/ (1 - kap) v^2; U_H^j = E_H^j/ {p_Am}
  if n_p > 5
    v_Hp = p(6); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_H^p = E_H^p/ {p_Am}
  else
    v_Hp = NaN;
  end
    
  if ~exist('f', 'var') || isempty(f)
    f = 1;
  end
  
  if exist('tel_b', 'var') && ~isempty(tel_b)
    if length(tel_b) == 1
      tau_b = get_tb(p([1 2 4]), f);
%      e_b = f;
      l_b = tel_b;
    elseif ~tel_b(2)==f && exist('tau', 'var')
      varargout = get_tjm(p, f, tel_b, tau);
      return
    elseif ~tel_b(2)==f 
      varargout = get_tjm(p, f, tel_b);
      return
    else
      tau_b = tel_b(1);
 %     e_b   = tel_b(2);
      l_b   = tel_b(3);
    end
  else
    tel_b = [];
    [tau_b, l_b, info] = get_tb(p([1 2 4]), f);
  end

  % no acceleration
  if v_Hb == v_Hj 
    if exist('tau','var')
      [tvel, tau_p, tau_b, l_p, l_b, info] = get_tp(p([1 2 3 4 6]), f, tel_b, tau);
      tau_j = tau_b; l_j = l_b; l_i = f - l_t; rho_j = NaN; rho_B = 1/ 3/ (1 + f/ g);
      varargout = {tvel, tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B, info};    
    else
      [tau_p, tau_b, l_p, l_b, info] = get_tp(p([1 2 3 4 6]), f, tel_b);
      tau_j = tau_b; l_j = l_b; l_i = f - l_t; rho_j = NaN; rho_B = 1/ 3/ (1 + f/ g);
      varargout = {tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B, info};    
    end
    return
  end

  % maintenance ratio k = 1: maturity thresholds coincide with length thresholds
  if k == 1 && f * (f - l_T)^2 > v_Hp * k % constant maturity density, reprod possible
    l_b = v_Hb^(1/3);                   % scaled length at birth
    tau_b = get_tb(p([1 2 4]), f, l_b); % scaled age at birth
    l_j = v_Hj^(1/3);                   % scaled length at metamorphosis
    s_M = l_j/ l_b;                     % acceleration factor
    rho_j = g * (f/ l_b - 1 - l_T/ l_b)/ (f + g); % scaled exponential growth rate between b and j
    tau_j = tau_b + (log(s_M)) * 3/ rho_j; % scaled age at metamorphosis
    l_p = v_Hp^(1/3);                   % scaled length at puberty
    l_i = f * s_M - l_T;                % scaled ultimate length
    rho_B = 1/ 3/ (1 + f/ g);           % scaled von Bert growth rate between j and i
    tau_p = tau_j + (log ((l_i - l_j)/ (l_i - l_p)))/ rho_B; % scaled age at puberty
    info = 1;
  elseif k == 1 && f * (f - l_T)^2 > v_Hj * k % constant maturity density, metam possible but pub not
    l_b = v_Hb^(1/3);                   % scaled length at birth
    tau_b = get_tb(p([1 2 4]), f, l_b); % scaled age at birth
    l_j = v_Hj^(1/3);                   % scaled length at metamorphosis
    s_M = l_j/ l_b;                     % acceleration factor
    rho_j = (f/ l_b - 1 - l_T/ l_b)/ (1 + f/ g); % scaled exponential growth rate between b and j
    tau_j = tau_b + (log(s_M)) * 3/ rho_j;     % scaled age at metamorphosis
    l_p = v_Hp^(1/3);                   % scaled length at puberty
    l_i = f * s_M - l_T;                % scaled ultimate length
    rho_B = 1/ 3/ (1 + f/ g);           % scaled von Bert growth rate between j and i
    tau_p = NaN;                        % pubert cannot be reached
    info = 1;
  else
    [l_j, l_p, l_b, info_lj] = get_lj(p, f, l_b);
    s_M = l_j/ l_b;                     % acceleration factor
    rho_j = (f/ l_b - 1 - l_T/ l_b)/ (1 + f/ g); % scaled exponential growth rate between b and j
    tau_j = tau_b + log(s_M) * 3/ rho_j;% scaled age at metamorphosis
    rho_B = 1/ 3/ (1 + f/ g);           % scaled von Bert growth rate between j and i
    l_i = f * s_M - l_T;                % scaled ultimate length
    if isempty(l_p) % length(p) < 6
      tau_p = [];
    elseif  l_i <=  l_p                % reproduction is not possible
      tau_p = NaN;                     % tau_p is never reached
      l_p = NaN;                       % lp is never reached
    else % reproduction is possible
      tau_p = tau_j + log((l_i - l_j)/ (l_i - l_p))/ rho_B;
    end
    info = 1;
  end
  
  if exist('tau','var')
    tau = tau(:); tau_bj = tau_j - tau_b; n_bi = length(tau); n_bj = sum(tau <= tau_bj); n_ji = n_bi - n_bj; l = []; v_H = [];
    if n_bj > 0
      t = tau(tau <= tau_bj);
      l = l_b * exp(rho_j * t/ 3); 
      v_H = f*l_b^3*(1/l_b-rho_j/g)/(k+rho_j)*(exp(rho_j*t)-exp(-k*t)) + v_Hb*exp(-k*t);
    end
    if n_ji > 0
      t = tau(tau > tau_bj);
      l = [l; l_i - (l_i - l_j) * exp(-rho_B * (t - tau_bj))]; 

      % help constants for maturity computations
      l_d = l_i - l_j;
      b3 = 1 / (1 + g/ f); 
      b2 = f - b3 * l_i;
      a0 = - (b2 + b3 * l_i) * l_i^2/ k;
      a1 = - l_i * l_d * (2 * b2 + 3 * b3 * l_i)/ (rho_B - k);
      a2 = l_d^2 * (b2 + 3 * b3 * l_i)/ (2 * rho_B - k);
      a3 = - b3 * l_d^3 / (3 * rho_B - k);
      ak = v_Hj + a0 + a1 + a2 + a3;

      ert = exp(-rho_B * t); ekt = exp(-k * t);
      v_H = [v_H; min(v_Hp, - a0 - a1 * ert - a2 * ert.^2 - a3 * ert.^3 + ak * ekt)];   
    end
    tvel = [tau, v_H, f*ones(n_bi,1), l];
    info = 1;
  end
    
  if exist('info_tb','var') && exist('info_lj','var'); info = min(info_tb, info_lj); end
  if isempty(tau_p) || ~isreal(tau_p) || ~isreal(tau_j) % tj and tp must be real and positive
    info = 0;
  elseif tau_p < 0 || tau_j < 0 || rho_j <= 0 || rho_B <=0
    info = 0;
  end

  if exist('tau','var')
    varargout = {tvel, tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B, info};
  else
    varargout = {tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B, info};
  end

  