%% maturity
% calculates the scaled maturity from structural length at constant food

%%
function [H, a, info] = maturity(L, f, p)
  %  created 2024/07/12 by Bas Kooijman
  
  %% Syntax
  % [H, a, info] = <../maturity.m *maturity*> (L, f, p)
  
  %% Description
  % calculates the scaled maturity U_H = M_H/{J_EAm} = E_H/{p_Am} at constant food density. 
  %
  % Input
  %
  % * L: n-vector with length, ordered from small to large 
  % * f: scalar with (constant) scaled functional response
  % * p: 9-vector with parameters: [kap,kap_R,g,k_J,k_M,L_T,v,U_Hb,U_Hp] 
  %
  % Output
  %
  % * H: n-vector with scaled maturities: H = M_H/{J_EAm} = E_H/{p_Am}
  % * a: n-vector with ages at which lengths (and maturities) are reached
  % * info: boolean for success (1) or failure (0)
  
  %% Remarks
  %  called by DEBtool/tox/*rep and DEBtool/animal/scaled_power
  % See <maturity_j.html *maturity_j*> for type M accleration and
  % <maturity_s.html *maturity_s*> for delayed type M acceleration.
  
  %% Example of use
  %  [H, a] = maturity(.4, 1, [.8,.95, .2, .002, .01, 0, .02, .2, 2])

  % unpack parameters
  kap = p(1);  % -, fraction allocated to growth + som maint
  %kap_R = p(2);% -, fraction of reprod flux that is fixed in embryo reserve 
  g   = p(3);  % -, energy investment ratio
  k_J = p(4);  % 1/d, maturity maint rate coeff
  k_M = p(5);  % 1/d, somatic maint rate coeff
  L_T = p(6);  % cm, heating length
  v   = p(7);  % cm/d, energy conductance
  H_b = p(8);  % d cm^2, scaled maturity at birth
  H_p = p(9);  % d cm^2, scaled maturity at puberty
  % kap_R is not used, but kept for consistency with iget_pars_r, reprod_rate
  
  if isempty(f)
    f = 1; % abundant food
  end

  L_m = v/ k_M/ g; l_T = L_T/ L_m; k = k_J/ k_M; L = L(:); 

  u_Hb = H_b * g^2 * k_M^3/ v^2; v_Hb = u_Hb/ (1 - kap); % -, scaled maturity at birth
  u_Hp = H_p * g^2 * k_M^3/ v^2; v_Hp = u_Hp/ (1 - kap); % -, scaled maturity at puberty
  [tau_p, tau_b, l_p, l_b, info] = get_tp([g, k, l_T, v_Hb, v_Hp], f);
  L_b = L_m * l_b; L_0b = L(L<=L_b); L_bi = L(L>L_b);
  n_0b = length(L_0b); n_bi = length(L_bi); % number of embryo and post-embryo lengths
  a_0b = []; H_0b = []; a_bi = []; H_bi = []; % initiate values for a and H
  options = odeset('RelTol',1e-6, 'AbsTol',1e-6); 
  
  % integrate [l, u_E, u_H] in time and find u_H via spline-interpolation in the trajectory
  if n_0b > 0 % embryo values
    u_E0 = get_ue0([g, k, v_Hb], f); L_0b = L(1:n_0b);
    [tau, luEuH] = ode45(@dget_luEuH, [0;tau_b], [1e-6;u_E0;1e-6], options, kap, g, k);
    a = tau/ k_M; La = L_m * luEuH(:,1); H = luEuH(:,3)*v^2/g^2/k_M^3;
    a_0b = spline1(L_0b,[La,a]); H_0b = spline1(L_0b,[La,H]);
  end

  % first find times since birth for L, then integrate [L, U_H] in time
  % allow to integrate past puberty, but clip in trajectory
  if n_bi > 0 % post-embryo values
    L_i = f * L_m - L_T; r_B = k_M/ 3/ (1 + f/ g);
    t_bi = log((L_i - L_b)./ (L_i - L_bi))/ r_B;
    [t, LH] = ode45(@dget_LH_bi,[-1e-8;t_bi],[L_b;H_b],options,f, kap, v, g, k_M, k_J);
    if n_bi==1; t = t([1 end]); LH = LH([1 end],:); end
    t(1) = []; LH(1,:) = []; a_bi = tau_b/ k_M + t; H_bi = min(H_p,LH(:,2));
  end
  
  % catenate embryo and post-embryo values
  H = [H_0b; H_bi]; a = [a_0b; a_bi];
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

function dLH = dget_LH_bi(t, LH, f, kap, v, g, k_M, k_J)
  % t: time since birth
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