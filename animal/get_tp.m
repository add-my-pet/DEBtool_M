%% get_tp
% Gets scaled age and length at puberty, birth

%%
function varargout = get_tp(p, f, tel_b, tau)
  % created at 2008/06/04 by Bas Kooijman, 
  % modified 2014/03/04 Starrlight Augustine, 2015/01/18 Bas Kooijman
  % modified 2018/09/10 (t -> tau) Nina Marn
  % modified 2021/11/24, 2023/04/05 Bas Kooijman
  
  %% Syntax
  % varargout = <../get_tp.m *get_tp*>(p, f, tel_b, tau)
  
  %% Description
  % Obtains scaled ages, lengths at puberty, birth for the std model at constant food, temperature;
  % Assumes that scaled reserve density e always equals f; if third input is specified and its second
  % element is not equal to second input (if specified), <get_tpm *get_tpm*> is run.
  %
  % Input
  %
  % * p: 5-vector with parameters: g, k, l_T, v_H^b, v_H^p 
  % * f: optional scalar with functional response (default f = 1)
  % * tel_b: optional scalar with scaled length at birth
  %
  %      or 3-vector with scaled age at birth, reserve density and length at 
  % * tau: optional n-vector with scaled times since birth
  %
  % Output
  %
  % * tvel: optional (n,4)-array with scaled time-since-birth, maturity, reserve density and length
  % * tau_p: scaled with age at puberty \tau_p = a_p k_M
  % * tau_b: scaled with age at birth \tau_b = a_b k_M
  % * lp: scaler length at puberty
  % * lb: scaler length at birth
  % * info: indicator equals 1 if successful
  
  %% Remarks
  % Function <get_tp_foetus.html *get_tp_foetus*> does the same for foetal development; the result depends on embryonal development.
  % A previous version of get_tp had as optional 3rd input a 2-vector with scaled length, l, and scaled maturity, vH, for a juvenile that is now exposed to f, but previously at another f.
  % Function <get_tpm *get_tpm*> took over this use.
  % Optional inputs might be empty

  %% Example of use
  % tau_p = get_tp([.5, .1, .1, .01, .2]) or tvel = get_tp([.5, .1, .1, .01, .2],[],[],0:0.014:) 

  %  unpack pars
  g    = p(1); % energy investment ratio
  k    = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  l_T  = p(3); % scaled heating length {p_T}/[p_M]Lm
  v_Hb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = M_H^b/ {J_EAm} = E_H^b/ {p_Am}
  v_Hp = p(5); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_H^p = M_H^p/ {J_EAm} = E_H^p/ {p_Am}
  
  if ~exist('f', 'var')
    f = 1;
  elseif isempty(f)
    f = 1;
  end

  if exist('tel_b', 'var') && ~isempty(tel_b)
    if length(tel_b) == 1
      tau_b = get_tb(p([1 2 4]), f);
%      e_b = f;
      l_b = tel_b;
    elseif ~tel_b(2)==f && exist('tau', 'var')
      varargout = get_tpm(p, f, tel_b, tau);
      return
    elseif ~tel_b(2)==f 
      varargout = get_tpm(p, f, tel_b);
      return
    else
      tau_b = tel_b(1);
%      e_b   = tel_b(2);
      l_b   = tel_b(3);
    end
  else
    [tau_b, l_b, info] = get_tb(p([1 2 4]), f);
  end

  if v_Hp < v_Hb
    fprintf('Warning from get_tp: vHp < vHb\n')
    [tau_b, l_b] = get_tb(p([1 2 4]), f);
    tau_p = []; l_p = [];
    info = 0;
    varargout = {tau_p, tau_b, l_p, l_b, info};
    return
  end

  rho_B = 1 / 3/ (1 + f/ g); % -, scaled von Bert growth rate
  l_i = f - l_T; % -, ultimate scaled length
  l_d = l_i - l_b; % -, scaled length

  % k*v_Hi = f*l_i^2 ultimate v_Hi
  if k == 1 && f * l_I^2 > v_Hp * k 
    l_b = v_Hb^(1/3); 
    tau_b = get_tb(p([1 2 4]), f, l_b);
    l_p = v_Hp^(1/3);
    tau_p = tau_b + log(l_d/ (l_i - l_p))/ rho_B;
    info = 1;
  elseif f * l_i^2 <= v_Hp * k % reproduction is not possible
    [tau_b, l_b] = get_tb (p([1 2 4]), f); 
    tau_p = NaN; % tau_p is never reached
    l_p = NaN;   % l_p is never reached
    info = 0;
  else % reproduction is possible
    [l_p, ~, info] = get_lp1 (p, f, l_b);
    tau_p = tau_b + log(l_d/ (l_i - l_p))/ rho_B;
  end

  if exist('tau','var')
    % help constants for maturity computations
    b3 = 1 / (1 + g/ f); 
    b2 = f - b3 * l_i;
    a0 = - (b2 + b3 * l_i) * l_i^2/ k;
    a1 = - l_i * l_d * (2 * b2 + 3 * b3 * l_i)/ (rho_B - k);
    a2 = l_d^2 * (b2 + 3 * b3 * l_i)/ (2 * rho_B - k);
    a3 = - b3 * l_d^3 / (3 * rho_B - k);
    ak = v_Hb + a0 + a1 + a2 + a3;

    tau = tau(:); n = length(tau); % make sure that tau is a column vector
    ert = exp(-rho_B * tau); ekt = exp(-k * tau);
    l = l_i - l_d * exp(- rho_B * tau);
    v_H = min(v_Hp, - a0 - a1 * ert - a2 * ert.^2 - a3 * ert.^3 + ak * ekt);   
    tvel = [tau, v_H, f*ones(n,1), l];
  end
  
  if ~isreal(tau_p) % tp must be real and positive
    info = 0;
  elseif tau_p < 0
    info = 0;
  end

  if exist('tau','var')
    varargout = {tvel, tau_p, tau_b, l_p, l_b, info};
  else
    varargout = {tau_p, tau_b, l_p, l_b, info};
  end

end
