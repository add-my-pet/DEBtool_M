%% get_tm_mod
% Gets scaled mean age at death, survival prob at birth and puberty

%%
function [tau_m, S, tau] = get_tm_mod(model, p, f, h_B, thinning)
  % created 2019/10/07 by Bas Kooijman, modified 2022/02/10
  
  %% Syntax
  % [tau_m, S_, tau, info] = <../get_tm_mod.m *get_tm_mod*>(model, p, f, h_B, thinning)
  
  %% Description
  % Obtains scaled mean age at death by integration survival prob over age. 
  % Divide the result by the somatic maintenance rate coefficient to arrive at the mean age at death. 
  %
  % Input
  %
  % * mod: character string with model (e.g. 'std', 'hex')
  % * p: vector with parameters: different for each model, or structure, like par in results_my_pet
  % * f: optional scalar with scaled reserve density at birth (default f = 1)
  % * h_B; optional vector with background hazards for each stage: e.g. for std model h_B0b, h_Bbp, h_Bpi (default: zero's)
  % * thinning: optional boolean with thinning being false/true (default: false)
  %  
  % Output
  %
  % * t_m: scalar with scaled mean life span
  % * S: vector with survival probabilities at life history events 
  % * tau: vector with scaled ages at life history events 
 
  %% Remarks
  % Theory is given in comments on DEB3 Section 6.1.1 
  % See <get_tm_s.html *get_tm_s*> for a short growth period relative to the life span
  
  %% Example of use
  % get_tm_mod('std', [.5, .1, .001, .01, 1e-5, .0001])
    
  if ~exist('f', 'var') || isempty(f)
    f = 1;
  end

  if ~exist('h_B', 'var') || isempty(h_B)
    h_B = zeros(5,1); 
  end

  if ~exist('thinning', 'var')
    thinning = false;
  end
  
  if isstruct(p)
    v2struct(p); cPar = parscomp_st(p); v2struct(cPar); % unpack pars and compute coumpound pars
    h_a = h_a/ k_M^2; % -, remove units from aging accelleration
  else
    switch model
      case 'std'
        g = p(1); k = p(2); v_Hb = p(3); v_Hp = p(4); h_a = p(5); s_G = p(6); %  unpack pars
      case 'stf'
        g = p(1); k = p(2); v_Hb = p(3); v_Hp = p(4); h_a = p(5); s_G = p(6); %  unpack pars
      case 'stx'
        g = p(1); k = p(2); v_Hb = p(3); v_Hx = p(4); v_Hp = p(5); h_a = p(6); s_G = p(7); %  unpack pars
      case 'ssj'
        g = p(1); k = p(2); v_Hb = p(3); v_Hs = p(4); v_Hp = p(5); t_sj = p(6); k_E = p(7); h_a = p(8); s_G = p(9); %  unpack pars
      case 'sbp'
        g = p(1); k = p(2); v_Hb = p(3); v_Hp = p(4); h_a = p(5); s_G = p(6); %  unpack pars
      case 'abj'
        g = p(1); k = p(2); v_Hb = p(3); v_Hj = p(4); v_Hp = p(5); h_a = p(6); s_G = p(7); %  unpack pars
      case 'asj'
        g = p(1); k = p(2); v_Hb = p(3); v_Hs = p(4); v_Hj = p(5); v_Hp = p(6); h_a = p(7); s_G = p(8); %  unpack pars
      case 'abp'
        g = p(1); k = p(2); v_Hb = p(3); v_Hp = p(4); h_a = p(5); s_G = p(6); %  unpack pars
      case 'hep'
        g = p(1); k = p(2); v_Hb = p(3); v_Hp = p(4); v_Rj = p(5); h_a = p(6); s_G = p(7); %  unpack pars
      case 'hax'
        g = p(1); k = p(2); v_Hb = p(3); v_Hp = p(4); v_Rj = p(5); v_He = p(6); kap = p(7); kap_V = p(8); h_a = p(9); s_G = p(10); %  unpack pars
      case 'hex'
        g = p(1); k = p(2); v_Hb = p(3); v_He = p(4); s_j = p(5); kap = p(6); kap_V = p(7); h_a = p(8); s_G = p(9); %  unpack pars
    end          
  end
  
  options = odeset('Events',@dead_for_sure, 'NonNegative',ones(4,1), 'AbsTol',1e-7, 'RelTol',1e-7);  

  switch model
    case 'std'
      [S_b, q_b, h_Ab, tau_b] = get_Sb([g k v_Hb h_a s_G h_B(1)], f);   
      qhSt_b = [max(0,q_b); max(0,h_Ab); S_b; tau_b]; % initial state vars
      [tau_p, ~, l_p, l_b] = get_tp([g k 0 v_Hb v_Hp], f); % -, scaled ages and lengths at puberty, birth
      [tau, qhSt] = ode45(@dget_qhSt_std, [0; tau_p - tau_b; 1e8], qhSt_b, options, f, tau_p - tau_b, l_b, g, s_G, h_a, h_B, thinning);
      tau_m = qhSt(end,4); S_p = qhSt(2,3); S = [S_b; S_p]; tau = [tau_b; tau_p];
    case 'stf'
      [S_b, q_b, h_Ab, tau_b] = get_Sb_foetus([g k v_Hb h_a s_G h_B(1)], f);
      [tau_p, ~, l_p, l_b] = get_tp_foetus([g k 0 v_Hb v_Hp], f); % -, scaled ages and lengths at puberty, birth
      qhSt_b = [max(0,q_b); max(0,h_Ab); S_b; tau_b]; % initial state vars
      [tau, qhSt] = ode45(@dget_qhSt_std, [0; tau_p - tau_b; 1e8], qhSt_b, options, f, tau_p - tau_b, l_b, g, s_G, h_a, h_B, thinning);
      tau_m = qhSt(end,4); S_p = qhSt(2,3); S = [S_b; S_p]; tau = [tau_b; tau_p];
    case 'stx'
      [S_b, q_b, h_Ab, tau_b] = get_Sb_foetus([g k v_Hb h_a s_G h_B(1)], f);
      qhSt_b = [max(0,q_b); max(0,h_Ab); S_b; tau_b]; % initial state vars
      [tau_p, tau_x, ~, l_p, l_x, l_b] = get_tx([g k 0 v_Hb v_Hx v_Hp], f); % -, scaled ages and lengths at puberty, birth
      [tau, qhSt] = ode45(@dget_qhSt_stx, [0; tau_x - tau_b; tau_p - tau_b; 1e8], qhSt_b, options, f, tau_x - tau_b, tau_p - tau_b, l_b, g, s_G, h_a, h_B, thinning);
      tau_m = qhSt(end,4); S_x = qhSt(2,3); S_p = qhSt(3,3); S = [S_b; S_x; S_p]; tau = [tau_b; tau_x; tau_p];
    case 'ssj'
      [S_b, q_b, h_Ab, tau_b] = get_Sb([g k v_Hb h_a s_G h_B(1)], f); 
      qhSt_b = [max(0,q_b); max(0,h_Ab); S_b; tau_b]; % initial state vars
      [tau_s, ~, l_s, l_b] = get_tp([g k 0 v_Hb v_Hs], f); % -, scaled ages and lengths at start skrink
      [tau_p, ~, l_p] = get_tp([g k 0 v_Hs v_Hp], f); % -, scaled ages and lengths at puberty
      tau_j = tau_s + t_sj * k_M; % -, scaled age at end metam
      k_E = k_E/ k_M; % - scaled shrinking rate
      [tau, qhSt] = ode45(@dget_qhSt_ssj, [0; tau_s - tau_b; tau_j - tau_b; tau_p - tau_b; 1e8], qhSt_b, options, f, tau_s - tau_b, tau_p - tau_b, tau_j, l_b, l_s, k_E, g, s_G, h_a, h_B, thinning);
      tau_m = qhSt(end,4); S_s = qhSt(2,3); S_j = qhSt(3,3); S_p = qhSt(4,3); S = [S_b; S_s; S_j; S_p]; tau = [tau_b; tau_s; tau_j; tau_p];
    case 'sbp'
      [S_b, q_b, h_Ab, tau_b] = get_Sb([g k v_Hb h_a s_G h_B(1)], f);
      qhSt_b = [max(0,q_b); max(0,h_Ab); S_b; tau_b]; % initial state vars
      [tau_p, ~, l_p, l_b] = get_tp([g k 0 v_Hb v_Hp], f); % -, scaled ages and lengths at puberty, birth
      [tau, qhSt] = ode45(@dget_qhSt_sbp, [0; tau_p - tau_b; 1e8], qhSt_b, options, f, tau_p - tau_b, l_b, l_p, g, s_G, h_a, h_B, thinning);
      tau_m = qhSt(end,4); S_p = qhSt(2,3); S = [S_b; S_p]; tau = [tau_b; tau_p];
    case 'abj'
      [S_b, q_b, h_Ab, tau_b] = get_Sb([g k v_Hb h_a s_G h_B(1)], f);
      qhSt_b = [max(0,q_b); max(0,h_Ab); S_b; tau_b]; % initial state vars
      [tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B] = get_tj([g k 0 v_Hb v_Hj v_Hp], f); 
      [tau, qhSt] = ode45(@dget_qhSt_abj, [0; tau_j - tau_b; tau_p - tau_b;  1e8], qhSt_b, options, f, tau_j - tau_b, tau_p - tau_b, l_b, l_j, l_i, rho_j, rho_B, g, s_G, h_a, h_B, thinning);
      tau_m = qhSt(end,4); tau = [tau_b; tau_j; tau_p];
      if size(qhSt,1) == 4; S_j = qhSt(2,3); S_p = qhSt(3,3); else; S_j = qhSt(end,3); S_p = qhSt(end,3); end;          
      S = [S_b; S_j; S_p]; 
    case 'asj'
      [S_b, q_b, h_Ab, tau_b] = get_Sb([g k v_Hb h_a s_G h_B(1)], f);
      qhSt_b = [max(0,q_b); max(0,h_Ab); S_b; tau_b]; % initial state vars
      [tau_s, tau_j, tau_p, tau_b, l_s, l_j, l_p, l_b, l_i, rho_j, rho_B] = get_ts([g k 0 v_Hb v_Hs v_Hj v_Hp], f); 
      [tau, qhSt] = ode45(@dget_qhSt_asj, [0; tau_s - tau_b; tau_j - tau_b; tau_p - tau_b; 1e8], qhSt_b, options, f, tau_s - tau_b, tau_j - tau_b, tau_p - tau_b, l_b, l_s, l_j, l_i, rho_j, rho_B, g, s_G, h_a, h_B, thinning);
      tau_m = qhSt(end,4); S_s = qhSt(2,3); S_j = qhSt(3,3); S_p = qhSt(4,3); S = [S_b; S_s; S_j; S_p]; tau = [tau_b; tau_s; tau_j; tau_p];
    case 'abp'
      [S_b, q_b, h_Ab, tau_b] = get_Sb([g k v_Hb h_a s_G h_B(1)], f);
      qhSt_b = [max(0,q_b); max(0,h_Ab); S_b; tau_b]; % initial state vars
      [tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B] = get_tj([g k 0 v_Hb v_Hp v_Hp+1e-9], f); 
      [tau, qhSt] = ode45(@dget_qhSt_abp, [0; tau_p - tau_b; 1e8], qhSt_b, options, f, tau_p - tau_b, l_b, l_p, rho_j, g, s_G, h_a, h_B, thinning);
      tau_m = qhSt(end,4); S_p = qhSt(2,3); S = [S_b; S_p]; tau = [tau_b; tau_p];
    case 'hep' % ignore aging till emergence (fitted data concerns life span as imago)
      S_b = 1; S_p = 1; S_j = 1; qhSt_j = [0 0 1 0]; %[S_b, q_b, h_Ab, tau_b] = get_Sb([g k v_Hb h_a s_G h_B(1)], f);
      %qhSt_b = [max(0,q_b); max(0,h_Ab); S_b; tau_b]; % initial state vars
      [tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B] = get_tj_hep([g, k, v_Hb, v_Hp, v_Rj], f);
      %[tau, qhSt] = ode45(@dget_qhSt_hep, [0; tau_p - tau_b; tau_j - tau_b; 1e8], qhSt_b, options, f, tau_p - tau_b, tau_j- tau_b, l_b, l_p, l_i, rho_j, rho_B, g, s_G, h_a, h_B, thinning);
      [tau, qhSt] = ode45(@dget_qhSt_hex_ji, [0; 1e-6; 1e8], qhSt_j, options, f,  1e-6, l_j, g, s_G, h_a, h_B);
      tau_m = qhSt(end,4); S = [S_b; S_p; S_j]; tau = [tau_b; tau_p; tau_j]; 
    case 'hax' % ignore aging till emergence (fitted data concerns life span as imago)
      S_b = 1; S_p = 1; S_j = 1; qhSt_j = [0 0 1 0]; % [S_b, q_b, h_Ab, tau_b] = get_Sb([g k v_Hb h_a s_G h_B(1)], f);
      [tau_j, tau_e, tau_p, tau_b, l_j, l_e, l_p, l_b, l_i, rho_j, rho_B, u_Ee] = get_tj_hax([g, k, v_Hb, v_Hp, v_Rj, v_He, kap, kap_V], f);
      %qhSt_b = [max(0,q_b); max(0,h_Ab); S_b; tau_b]; % initial state vars
      %[tau, qhSt] = ode45(@dget_qhSt_hep, [0; tau_p-tau_b; tau_j-tau_b; 1e8], qhSt_b, options, f, tau_p-tau_b, tau_j-tau_b, l_b, l_p, l_i, rho_j, rho_B, g, s_G, h_a, h_B, thinning);
      %tau_m = qhSt(end,4); S_p = qhSt(2,3); S_j = qhSt(min(3,end),3); qhSt_j = qhSt(end,:); qhSt_j(1:2) = 0;
      [tau, qhSt] = ode45(@dget_qhSt_hex_ji, [0; tau_e-tau_j; 1e8], qhSt_j, options, f, tau_e-tau_j, l_e, g, s_G, h_a, h_B);
      S_e = qhSt(2,3); S = [S_b; S_p; S_j; S_e]; tau = [tau_b; tau_p; tau_j; tau_e];  tau_m = qhSt(3,4);
    case 'hex' % ignore aging till emergence (fitted data concerns life span as imago)
      S_b = 1; S_j = 1; qhSt_j = [0 0 1 0]; %[S_b, q_b, h_Ab, tau_b] = get_Sb([g k v_Hb h_a s_G h_B(1)], f);
      %qhSt_b = [max(0,q_b); max(0,h_Ab); S_b; tau_b]; % initial state vars
      [tau_j, tau_e, tau_b, l_j, l_e, l_b, rho_j] = get_tj_hex([g, k, v_Hb, v_He, s_j, kap, kap_V], f);
      %[tau, qhSt] = ode45(@dget_qhSt_hex_bj, [0; tau_j - tau_b], qhSt_b, [], f, l_b, rho_j, g, s_G, h_a, h_B, thinning);
      %tau_m = qhSt(end,4); S_j = qhSt(end,3); qhSt_j = qhSt(end,:); qhSt_j(1:2) = 0;
      [tau, qhSt] = ode45(@dget_qhSt_hex_ji, [0; tau_e-tau_j; 1e8], qhSt_j, options, f, tau_e, l_e, g, s_G, h_a, h_B);
      S_e = qhSt(2,3); S = [S_b; S_j; S_e]; tau = [tau_b; tau_j; tau_e]; tau_m = qhSt(3,4);
  end

end

% subfunctions

% event dead_for_sure
function [value,isterminal,direction] = dead_for_sure(~, qhSt, varargin)
  value = qhSt(3) > 1e-6;  % trigger 
  isterminal = 1;  % terminate after the last event
  direction  = [];  % get all the zeros
end

function dqhSt = dget_qhSt_std(tau, qhSt, f, tau_p, l_b, g, s_G, h_a, h_B, thinning)
  % tau: scaled time since birth
  q   = qhSt(1); % -, scaled aging acceleration
  h_A = qhSt(2); % -, scaled hazard rate due to aging
  S   = qhSt(3); % -, survival prob
  %t  = qhSt(4); % -, scaled cumulative survival
  
  if tau < tau_p
    h_B = h_B(2);
  else % adult
    h_B = h_B(3);
  end
  
  rho_B = 1/ 3/ (1 + f/ g); 
  l = f - (f - l_b) * exp(- tau * rho_B);
  r = 3 * rho_B * (f/ l - 1);
  
  dq = f * (q * l^3 * s_G + h_a) * (g/ l - r) - r * q;
  dh_A = q - r * h_A;
  h_X = thinning * r * 2/3;
  h = h_A + h_B + h_X; 
  dS = - h * S;
  dt = S;
  
  dqhSt = [dq; dh_A; dS; dt]; 
end

function dqhSt = dget_qhSt_stx(tau, qhSt, f, tau_x, tau_p, l_b, g, s_G, h_a, h_B, thinning)
  % tau: scaled time since birth
  q   = qhSt(1); % -, scaled aging acceleration
  h_A = qhSt(2); % -, scaled hazard rate due to aging
  S   = qhSt(3); % -, survival prob
  %t  = qhSt(4); % -, scaled cumulative survival
  
  if tau < tau_x
    h_B = h_B(2);
  elseif tau < tau_p
    h_B = h_B(3);
  else % adult
    h_B = h_B(4);
  end
  
  rho_B = 1/ 3/ (1 + f/ g); 
  l = f - (f - l_b) * exp(- tau * rho_B);
  r = 3 * rho_B * (f/ l - 1);

  dq = f * (q * l^3 * s_G + h_a) * (g/ l - r) - r * q;
  dh_A = q - r * h_A;
  h_X = thinning * r * 2/3;
  h = h_A + h_B + h_X; 
  dS = - h * S;
  dt = S;
  
  dqhSt = [dq; dh_A; dS; dt]; 
end

function dqhSt = dget_qhSt_ssj(tau, qhSt, f, tau_s, tau_p, tau_j, l_b, l_s, k_E, g, s_G, h_a, h_B, thinning)
  % tau: scaled time since birth
  q   = qhSt(1); % -, scaled aging acceleration
  h_A = qhSt(2); % -, scaled hazard rate due to aging
  S   = qhSt(3); % -, survival prob
  %t  = qhSt(4); % -, scaled cumulative survival
  
  if tau < tau_s
    rho_B = 1/ 3/ (1 + f/ g); 
    l = f - (f - l_b) * exp(- tau * rho_B);
    r = 3 * rho_B * (f/ l - 1);
    h_B = h_B(2);
  elseif tau < tau_j
    l = l_s * exp( - k_E * (tau - tau_s));  
    r = 0; % 
    h_B = h_B(3);
  elseif tau < tau_p
    l_j = l_s * exp( - k_E * (tau_j - tau_s)); 
    rho_B = 1/ 3/ (1 + f/ g); 
    l = f - (f - l_j) * exp(- (tau - tau_j) * rho_B);
    r = 3 * rho_B * (f/ l - 1);
    h_B = h_B(3);
  else
    l_j = l_s * exp( - k_E * (tau_j - tau_s)); 
    rho_B = 1/ 3/ (1 + f/ g); 
    l = f - (f - l_j) * exp(- (tau - tau_j) * rho_B);
    r = 3 * rho_B * (f/ l - 1);
    h_B = h_B(4);
  end
  
  dq = f * (q * l^3 * s_G + h_a) * (g/ l - r) - r * q;
  dh_A = q - r * h_A;
  h_X = thinning * r * 2/3;
  h = h_A + h_B + h_X; 
  dS = - h * S;
  dt = S;
  
  dqhSt = [dq; dh_A; dS; dt]; 
end

function dqhSt = dget_qhSt_sbp(tau, qhSt, f, tau_p, l_b, l_p, g, s_G, h_a, h_B, thinning)
  % tau: scaled time since birth
  q   = qhSt(1); % -, scaled aging acceleration
  h_A = qhSt(2); % -, scaled hazard rate due to aging
  S   = qhSt(3); % -, survival prob
  %t  = qhSt(4); % -, scaled cumulative survival
  
  if tau < tau_p
    rho_B = 1/ 3/ (1 + f/ g); 
    l = f - (f - l_b) * exp(- tau * rho_B);
    r = 3 * rho_B * (f/ l - 1);
    h_B = h_B(2);
  else % adult
    l = l_p;
    r = 0;
    h_B = h_B(3);
  end
  
  dq = f * (q * l^3 * s_G + h_a) * (g/ l - r) - r * q;
  dh_A = q - r * h_A;
  h_X = thinning * r * 2/3;
  h = h_A + h_B + h_X; 
  dS = - h * S;
  dt = S;
  
  dqhSt = [dq; dh_A; dS; dt]; 
end

function dqhSt = dget_qhSt_abj(tau, qhSt, f, tau_j, tau_p, l_b, l_j, l_i, rho_j, rho_B, g, s_G, h_a, h_B, thinning)
  % tau: scaled time since birth
  q   = qhSt(1); % -, scaled aging acceleration
  h_A = qhSt(2); % -, scaled hazard rate due to aging
  S   = qhSt(3); % -, survival prob
  %t  = qhSt(4); % -, scaled cumulative survival
  
  if tau < tau_j
    h_B = h_B(2);
    l = l_b * exp(tau * rho_j);
    r = rho_j;
  elseif tau < tau_p
    h_B = h_B(3);
    l = l_i - (l_i - l_j) * exp(- (tau - tau_j) * rho_B);
    r = 3 * rho_B * (f/ l - 1);
  else % adult
    h_B = h_B(4);
    l = l_i - (l_i - l_j) * exp(- (tau - tau_j) * rho_B);
    r = 3 * rho_B * (f/ l - 1);
  end
  
  dq = f * (q * l^3 * s_G + h_a) * (g/ l - r) - r * q;
  dh_A = q - r * h_A;
  h_X = thinning * r * 2/3;
  h = h_A + h_B + h_X; 
  dS = - h * S;
  dt = S;
    
  dqhSt = [dq; dh_A; dS; dt]; 
end

function dqhSt = dget_qhSt_asj(tau, qhSt, f, tau_s, tau_j, tau_p, l_b, l_s, l_j, l_i, rho_j, rho_B, g, s_G, h_a, h_B, thinning)
  % tau: scaled time since birth
  q   = max(0,qhSt(1)); % -, scaled aging acceleration
  h_A = max(0,qhSt(2)); % -, scaled hazard rate due to aging
  S   = max(0,qhSt(3)); % -, survival prob
  %t  = max(0,qhSt(4)); % -, scaled cumulative survival
  
  if tau < tau_s
    h_B = h_B(2);
    rho_B = 1/ 3/ (1 + f/ g); 
    l = f - (f - l_b) * exp(- tau * rho_B);
    r = 3 * rho_B * (f/ l - 1);
  elseif tau < tau_j
    h_B = h_B(3);
    l = l_s * exp((tau - tau_s) * rho_j);
    r = rho_j;
  elseif tau < tau_p
    h_B = h_B(4);
    l = l_i - (l_i - l_j) * exp(- (tau - tau_j) * rho_B);
    r = 3 * rho_B * (f/ l - 1);
  else % adult
    h_B = h_B(5);
    l = l_i - (l_i - l_j) * exp(- (tau - tau_j) * rho_B);
    r = 3 * rho_B * (f/ l - 1);
  end
  
  dq = f * (q * l^3 * s_G + h_a) * (g/ l - r) - r * q;
  dh_A = q - r * h_A;
  h_X = thinning * r * 2/3;
  h = h_A + h_B + h_X; 
  dS = - h * S;
  dt = S;
  
  dqhSt = [dq; dh_A; dS; dt]; 
end

function dqhSt = dget_qhSt_abp(tau, qhSt, f, tau_p, l_b, l_p, rho_j, g, s_G, h_a, h_B, thinning)
  % tau: scaled time since birth
  q   = qhSt(1); % -, scaled aging acceleration
  h_A = qhSt(2); % -, scaled hazard rate due to aging
  S   = qhSt(3); % -, survival prob
  %t  = qhSt(4); % -, scaled cumulative survival
  
  if tau < tau_p
    h_B = h_B(2);
    l = l_b * exp(tau * rho_j);
    r = rho_j;
  else % adult
    h_B = h_B(3);
    l = l_p;
    r = 0;
  end
  
  dq = f * (q * l^3 * s_G + h_a) * (g/ l - r) - r * q;
  dh_A = q - r * h_A;
  h_X = thinning * r * 2/3;
  h = h_A + h_B + h_X; 
  dS = - h * S;
  dt = S;
  
  dqhSt = [dq; dh_A; dS; dt]; 
end


function dqhSt = dget_qhSt_hep(tau, qhSt, f, tau_p, tau_j, l_b, l_p, l_i, rho_j, rho_B, g, s_G, h_a, h_B, thinning)
  % tau: scaled time since birth
  q   = qhSt(1); % -, scaled aging acceleration
  h_A = qhSt(2); % -, scaled hazard rate due to aging
  S   = qhSt(3); % -, survival prob
  %t  = qhSt(4); % -, scaled cumulative survival
  
  if tau < tau_p
    h_B = h_B(2);
    l = l_b * exp(tau * rho_j);
    r = rho_j;
  elseif tau < tau_j % adult till metam
    h_B = h_B(3);
    l = l_i - (l_i - l_p) * exp(- (tau - tau_p) * rho_B);
    r = 3 * rho_B * (l_i/ l - 1);
  else % adult imago
    h_B = h_B(4);
    l = l_i - (l_i - l_p) * exp(- (tau - tau_p) * rho_B);
    r = 3 * rho_B * (l_i/ l - 1);
  end
  
  dq = f * (q * l^3 * s_G + h_a) * (g/ l - r) - r * q;
  dh_A = q - r * h_A;
  h_X = thinning * r * 2/3;
  h = h_A + h_B + h_X; 
  dS = - h * S;
  dt = S;
  
  dqhSt = [dq; dh_A; dS; dt]; 
end

function dqhSt = dget_qhSt_hex_bj(tau, qhSt, f, l_b, rho_j, g, s_G, h_a, h_B, thinning)
  % tau: scaled time since birth
  q   = qhSt(1); % -, scaled aging acceleration
  h_A = qhSt(2); % -, scaled hazard rate due to aging
  S   = qhSt(3); % -, survival prob
  %t  = qhSt(4); % -, scaled cumulative survival
  
  h_B = h_B(2);
  l = l_b * exp(tau * rho_j);
  r = rho_j;
  
  dq = f * (q * l^3 * s_G + h_a) * (g/ l - r) - r * q;
  dh_A = q - r * h_A;
  h_X = thinning * r * 2/3;
  h = h_A + h_B + h_X; 
  dS = - h * S;
  dt = S;
  
  dqhSt = [dq; dh_A; dS; dt]; 
end

function dqhSt = dget_qhSt_hex_ji(tau, qhSt, f, tau_e, l_e, g, s_G, h_a, h_B)
  % tau: scaled time since pupation
  q   = qhSt(1); % -, scaled aging acceleration
  h_A = qhSt(2); % -, scaled hazard rate due to aging
  S   = max(0,qhSt(3)); % -, survival prob
  %t  = qhSt(4); % -, scaled cumulative survival
  
  if tau < tau_e
    h_B = h_B(3);
    dq = 0;
    dh_A = 0;
  else
    h_B = h_B(4);
    dq = f * (q * l_e^3 * s_G + h_a) * g/ l_e;
    dh_A = q;
  end
  
  h = h_A + h_B; 
  dS = - h * S;
  dt = S;
  
  dqhSt = [dq; dh_A; dS; dt]; 
end