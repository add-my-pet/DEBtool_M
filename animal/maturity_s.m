%% maturity_s
% Gets maturity as function of length for delayed type M acceleration

%%
function [H, a, info] = maturity_s(L, f, p)
  %  created 2024/07/13 by Bas Kooijman
  
  %% Syntax
  % [H, a, info] = <../maturity_s.m *maturity_s*> (L, f, p)
  
  %% Description
  % Calculates the scaled maturity U_H = M_H/ {J_EAm} at constant food density 
  % in the case of delayed acceleration between UHs and UHj
  % and U_Hb < U_Hs < U_Hj < U_Hp
  %
  % Input
  %
  % * L: n-vector with length 
  % * p: 11-vector with parameters: kap kap_R g k_J k_M L_T v H_b H_s H_j H_p
  % * f: scalar with (constant) scaled functional response
  %
  % Output
  %
  % * H: n-vector with scaled maturities: H = M_H/{J_EAm} = E_H/{p_Am}
  % * a: n-vector with ages
  % * info: scalar for 1 for success, 0 otherwise
  
  %% Remarks
  % See <maturity.html *maturity*> in absence of acceleration and
  % <maturity_j.html *maturity_j*> if accleration is not delayed
  
  %% Example of use
  % [H, a, info] = maturity_s(.4, 1, [.8,.95, .2, .002, .01, 0, .02, .2, .3, .4, 2])
 
  % unpack parameters
  kap = p(1); % -, fraction allocated to growth + som maint
  %kap_R = p(2);% -, fraction of reprod flux that is fixed in embryo reserve 
  g   = p(3);  % -, energy investment ratio
  k_J = p(4);  % 1/d, maturity maint rate coeff
  k_M = p(5);  % 1/d, somatic maint rate coeff
  L_T = p(6);  % cm, heating length
  v   = p(7);  % cm/d, energy conductance
  H_b = p(8);  % d cm^2, scaled maturity at birth
  H_s = p(9);  % d cm^2, scaled maturity at start acceleration
  H_j = p(10); % d cm^2, scaled maturity at end acceleration
  H_p = p(11); % d cm^2, scaled maturity at puberty
  % kap_R is not used, but kept for consistency with iget_pars_r, reprod_rate

  if isempty(f)
    f = 1; % abundant food
  end

  L_m = v/ k_M/ g; l_T = L_T/ L_m; k = k_J/ k_M; L = L(:);
 
  u_Hb = H_b * g^2 * k_M^3/ v^2; v_Hb = u_Hb/ (1 - kap);
  u_Hs = H_s * g^2 * k_M^3/ v^2; v_Hs = u_Hs/ (1 - kap);
  u_Hj = H_j * g^2 * k_M^3/ v^2; v_Hj = u_Hj/ (1 - kap);
  u_Hp = H_p * g^2 * k_M^3/ v^2; v_Hp = u_Hp/ (1 - kap);

  [tau_s, tau_j, tau_p, tau_b, l_s, l_j, l_p, l_b, l_i, rho_j, rho_B, info] = get_ts([g; k; l_T; v_Hb; v_Hs; v_Hj; v_Hp], f);
  L_i = L_m * l_i; L_j = L_m * l_j; L_s = L_m * l_s; L_b = L_m * l_b; % cm, structural lengths
  s_M = l_j/ l_s;  r_j = k_M * rho_j; r_B = k_M * rho_B; % 1/d, von Bert growth rate
    
  L_0b = L(L<=L_b);  L_bs = L(L>L_b&L<=L_s); L_sj = L(L>L_s&L<=L_j); L_ji = L(L>L_j);
  n_0b = length(L_0b); n_bs = length(L_bs); n_sj = length(L_sj); n_ji = length(L_ji);
  a_0b = []; H_0b = []; a_bs = []; H_bs = []; a_sj = []; H_sj = []; a_ji = []; H_ji = []; % initiate values for a and H
  %options = odeset('RelTol',1e-6, 'AbsTol',1e-6); 

  % integrate [l, u_E, u_H] in time (0, tau_b) and find u_H via spline-interpolation in the trajectory
  if n_0b > 0 % embryo values
    u_E0 = get_ue0([g, k, v_Hb], f);
    [tau, luEuH] = ode45(@dget_luEuH, [0;tau_b], [1e-6;u_E0;1e-6], [], kap, g, k);
    a = tau/ k_M; La = L_m * luEuH(:,1); H = luEuH(:,3)*v^2/g^2/k_M^3;
    a_0b = spline1(L_0b,[La,a]); H_0b = spline1(L_0b,[La,H]);
  end
  
  % first find times before acceleration for L, then integrate [L, U_H] in time
  if n_bs > 0 % values before acceleration
    t_bs = log((f * L_m - L_b)./(f * L_m - L_bs))/ r_B; % d, time since b
    [t, LH] = ode45(@dget_LH_ji,[-1e-8;t_bs],[L_b;H_b],[],f, kap, v, g, k_M, k_J);
    if n_bs==1; t = t([1 end]); LH = LH([1 end],:); end
    t(1) = []; LH(1,:) = []; a_bs = tau_b/ k_M + t; H_bs = LH(:,2);
  end
  
  % first find times during acceleration for L, then integrate [L, U_H] in time
  if n_sj > 0 % values during acceleration
    t_sj = log(L_sj ./ L_s) * 3/ r_j; % d, time since s
    [t, LH] = ode45(@dget_LH_sj,[-1e-8;t_sj],[L_s;H_s],[],f, L_s, kap, v, g, k_M, k_J);
    if n_sj==1; t = t([1 end]); LH = LH([1 end],:); end
    t(1) = []; LH(1,:) = []; a_sj = tau_s/ k_M + t; H_sj = LH(:,2);
  end
  
  % then find times since acceleration for L, then integrate [L, U_H] in time
  % allow to integrate past puberty, but clip U_H in trajectory
  if n_ji > 0 % post-acceleration values
    t_ji = log((L_i - L_j)./ max(1e-6,L_i - L_ji))/ r_B; % d, time since j
    [t, LH] = ode45(@dget_LH_ji,[-1e-8;t_ji],[L_j;H_j],[],f, kap, v * s_M, g, k_M, k_J);
    if n_ji==1; t = t([1 end]); LH = LH([1 end],:); end
    t(1) = []; LH(1,:) = []; a_ji = tau_j/ k_M + t; H_ji = min(H_p,LH(:,2));
  end

  % catenate values
  H = [H_0b; H_bs; H_sj; H_ji]; a = [a_0b; a_bs; a_sj; a_ji];

end

% subfunctions
function dluEuH = dget_luEuH(tau, luEuH, kap, g, k)
  % tau: a k_M; scaled age
  % luEuH: 3-vector with (l, u_E, u_H) 
  %   l = L g k_M/ v; scaled length
  %   u_E = (g^2 k_M^3/ v^2) M_E/ {J_EAm}; scaled reserve
  %   u_H = (g^2 k_M^3/ v^2) M_H/ {J_EAm}; scaled maturity
  % dluEuH: 3-vector with (dl/dtau, du_E/dtau, du_H/dtau)
  
  l = luEuH(1); l2 = l * l; l3 = l2 * l; % scaled length
  u_E = max(1e-10,luEuH(2)); % scaled reserve
  u_H = luEuH(3); % scaled maturity
  
  r = (g * u_E/ l - l3)/ (u_E + l3); % -, spec growth rate in scaled time
  dl = l * r/ 3;
  du_E =  - u_E * (g/ l - r);
  du_H = (1 - kap) * u_E * (g/ l - r) - k * u_H;

  dluEuH = [dl; du_E; du_H]; % pack output
end

function dLH = dget_LH_sj(t, LH, f, L_s, kap, v, g, k_M, k_J)
  % t: time since birth during acceleration (v is value before acceleration)
  % LH: 2-vector with (L, H) 
  % dLH: 2-vector with (dL/dt, dH/dt)
  
  L = LH(1); % cm, structural length
  H = LH(2); % d.cm^2, scaled maturity
  s_M = L/ L_s; % -, acceleration factor
  r = (f * s_M * v/ L - g * k_M)/ (f + g); % 1/d, spec growth rate in real time
  dL = r * L/ 3; % cm/d
  pCpAm = f * L^2 * (1 - L * r/ v/ s_M);  % cm^2, p_C/{p_Am}
  dH =  (1 - kap) * pCpAm - k_J * H; % cm, d/dt E_H/{p_Am}
  
  dLH = [dL; dH]; % pack output
end

function dLH = dget_LH_ji(t, LH, f, kap, v, g, k_M, k_J)
  % t: time since end acceleration (v is value after acceleration)
  % LH: 2-vector with (L, H) 
  % dLH: 2-vector with (dL/dt, dH/dt)
  
  L = LH(1); % cm, structural length
  H = LH(2); % d.cm^2, scaled maturity
  r = (f * v/ L - g * k_M)/ (f + g); % 1/d, spec growth rate in real time
  dL = r * L/ 3; % cm/d
  pCpAm = f * L^2 * (1 - L * r/ v);  % cm^2, p_C/ {p_Am}
  dH =  (1 - kap) * pCpAm - k_J * H; % cm, d/dt E_H/{p_Am}
  
  dLH = [dL; dH]; % pack output
end