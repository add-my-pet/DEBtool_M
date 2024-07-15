%% maturity_j
% Gets maturity as function of length for type M acceleration

%%
function [H, a, info] = maturity_j(L, f, p)
  %  created 2024/07/12 by Bas Kooijman
  
  %% Syntax
  % [H, a, info] = <../maturity_j.m *maturity_j*> (L, f, p)
  
  %% Description
  % Life history events b (birth), j (and of acceleration), p (puberty).
  % Acceleration between b and j.
  % Calculates the scaled maturity U_H = M_H/ {J_EAm} = E_H/ {p_Am} at constant food
  %  density in the case of acceleration between UHb and UHj with UHb < UHj < UHp
  %
  % Input
  %
  % * L: n-vector with length 
  % * f: scalar with (constant) scaled functional response
  % * p: 10-vector with parameters: kap kapR g kJ kM LT v Hb Hj Hp
  %
  % Output
  %
  % * H: n-vector with scaled maturities: H = M_H/ {J_EAm} = E_H/ {p_Am}
  % * a: n-vector with ages at which lengths are reached 
  % * info: scalar for 1 for success, 0 otherwise
  
  %% Remarks
  % See <maturity.html *maturity*> in absence of acceleration and
  % <maturity_s.html *maturity_s*> if accleration is delayed

  %% Example of use
  % [H, a, info] = maturity_j(.4, 1, [.8,.95, .2, .002, .01, 0, .02, .2, .4, 2])
 
  % unpack parameters
  kap = p(1); % -, fraction allocated to growth + som maint
  %kapR = p(2);% -, fraction of reprod flux that is fixed in embryo reserve 
  g  = p(3);  % -, energy investment ratio
  k_J = p(4); % 1/d, maturity maint rate coeff
  k_M = p(5); % 1/d, somatic maint rate coeff
  L_T = p(6); % cm, heating length (not used)
  v  = p(7);  % cm/d, energy conductance
  H_b = p(8); % d.cm^2, scaled maturity at birth
  H_j = p(9); % d.cm^2, scaled maturity at metamorphosis
  H_p = p(10);% d.cm^2, scaled maturity at puberty
  % kapR is not used, but kept for consistency with iget_pars_r, reprod_rate
    
  if isempty(f)
    f = 1; % abundant food
  end

  L_m = v/ k_M/ g; l_T = L_T/ L_m; k = k_J/ k_M; L = L(:);

  u_Hb = H_b * g^2 * k_M^3/ v^2; v_Hb = u_Hb/ (1 - kap); % -, scaled maturity at birth
  u_Hj = H_j * g^2 * k_M^3/ v^2; v_Hj = u_Hj/ (1 - kap); % -, scaled maturity at end acceleration
  u_Hp = H_p * g^2 * k_M^3/ v^2; v_Hp = u_Hp/ (1 - kap); % -, scaled maturity at puberty
  [tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B, info] = get_tj([g; k; l_T; v_Hb; v_Hj; v_Hp], f);
  L_j = L_m * l_j; L_b = L_m * l_b; L_i = L_m * l_i; r_j = rho_j *  k_M; r_B = rho_B * k_M; s_M = l_j/ l_b;
 
  L_0b = L(L<=L_b); L_bj = L(L>L_b&L<=L_j); L_ji = L(L>L_j);
  n_0b = length(L_0b); n_bj = length(L_bj); n_ji = length(L_ji);
  a_0b = []; H_0b = []; a_bj = []; H_bj = []; a_ji = []; H_ji = []; % initiate values for a and H
  options = odeset('RelTol',1e-6, 'AbsTol',1e-6); 

  % integrate [l, u_E, u_H] in time (0, tau_b) and find u_H via spline-interpolation in the trajectory
  if n_0b > 0 % embryo values
    u_E0 = get_ue0([g, k, v_Hb], f);
    [tau, luEuH] = ode45(@dget_luEuH, [0;tau_b], [1e-6;u_E0;1e-6], options, kap, g, k);
    a = tau/ k_M; La = L_m * luEuH(:,1); H = luEuH(:,3)*v^2/g^2/k_M^3;
    a_0b = spline1(L_0b,[La,a]); H_0b = spline1(L_0b,[La,H]);
  end
  
  % first find times during acceleration for L, then integrate [L, U_H] in time
  if n_bj > 0 % values during acceleration
    t_bj = log(L_bj./ L_b)*3/ r_j;
    [t, LH] = ode45(@dget_LH_bj,[-1e-8;t_bj],[L_b;H_b],options,f, L_b, kap, v, g, k_M, k_J);
    if n_bj==1; t = t([1 end]); LH = LH([1 end],:); end
    t(1) = []; LH(1,:) = []; a_bj = tau_b/ k_M + t; H_bj = LH(:,2);
  end
  
  % first find times since acceleration for L, then integrate [L, U_H] in time
  % allow to integrate past puberty, but clip U_H in trajectory
  if n_ji > 0 % post-acceleration values
    t_ji = log((L_i - L_j)./ (L_i - L_ji))/ r_B;
    [t, LH] = ode45(@dget_LH_ji,[-1e-8;t_ji],[L_j;H_j],options,f, kap, v * s_M, g, k_M, k_J);
    if n_ji==1; t = t([1 end]); LH = LH([1 end],:); end
    t(1) = []; LH(1,:) = []; a_ji = tau_j/ k_M + t; H_ji = min(H_p,LH(:,2));
  end

  % catenate values
  H = [H_0b; H_bj; H_ji]; a = [a_0b; a_bj; a_ji];

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
  
  r = (g * u_E/ l - l3)/ (u_E + l3); % -,spec growth rate in scaled time
  dl = l * r/ 3;
  du_E =  - u_E * (g/ l - r);
  du_H = (1 - kap) * u_E * (g/ l - r) - k * u_H;

  dluEuH = [dl; du_E; du_H]; % pack output
end

function dLH = dget_LH_bj(t, LH, f, L_b, kap, v, g, k_M, k_J)
  % t: time since birth during acceleration (v is value before acceleration)
  % LH: 2-vector with (L, H) 
  % dLH: 2-vector with (dL/dt, dH/dt)
  
  L = LH(1); % cm, structural length
  H = LH(2); % d.cm^2, scaled maturity
  s_M = L/ L_b; % -, acceleration factor
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