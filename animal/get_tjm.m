%% get_tjm 
% Gets scaled age, length at puberty, birth for abj model

%%
function varargout = get_tjm(p, f, tel_b, tau)
  % created at 2012/03/24 by Bas Kooijman, 
 
  %% Syntax
  % varargout = <../get_tjm.m *get_tjm*> (p, f, tel_b, tau)
  
  %% Description
  % Obtains scaled ages, lengths at metamorphosis, puberty, birth for the abj model at constant food, temperature;
  % Metabolic acceleration occurs between birth and metamorphosis, see also get_ts. 
  % Notice j-p-b sequence in output, due to the name of the routine.
  % State at birth (scaled age, reserve density, length) can optionally be specified.
  % E.g. for female: [tau_b, f, l_b] with zoom factor z, but for male: [tau_b, f*z/z_m, l_b*z/z_m] with zoom factor z_m
  %
  % Input
  %
  % * p: 6-vector with parameters: g, k, l_T, v_H^b, v_H^j, v_H^p 
  % * f: optional scalar with functional response (default f = 1)
  % * tel_b: optional 3-vector with scaled age, reserve density and length at birth
  %     If absent or empty, it is computed from p and f using get_tb                  
  % * tau: optional n-vector with scaled times since birth
  %  
  % Output
  %
  % * tvel: optional (n,4)-array with time since birth, scaled maturity, reserve density and length
  % * tau_j: scaled age at metamorphosis \tau_j = a_j * k_M
  % * tau_p: scaled age at puberty \tau_p = a_p * k_M
  % * tau_b: scaled age at birth \tau_b = a_b * k_M
  % * l_j: scaled length at metamorphosis
  % * l_p: scaled length at puberty
  % * l_b: scaled length at birth
  % * l_i: ultimate scaled length
  % * rho_j: scaled exponential growth rate between b and j
  % * rho_B: scaled von Bertalanffy growth rate between j and i
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % If tel_b is specified and different from the DEB value for p and f, see get_tb, initial growth deviates from exponential.
  % The m in get_tjm stands for male, see get_tj for female
  % The first output tvel is suppessed if last input tau is not specified
  
  %% Example of use
  %  get_tjm([.5, .1, 0, .01, .05, .2])
  
  % unpack pars
  g    = p(1); % energy investment ratio
  k    = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  l_T  = p(3); % scaled heating length {p_T}/[p_M]Lm
  v_Hb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = E_H^b/ {p_Am}
  v_Hj = p(5); % v_H^j = U_H^j g^2 kM^3/ (1 - kap) v^2; U_H^j = E_H^j/ {p_Am}
  v_Hp = p(6); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_H^p = E_H^p/ {p_Am}
    
  if ~exist('f', 'var') || isempty(f)
    f = 1;
  end
  
  % get states at birth
  if ~exist('tel_b','var') || isempty(tel_b)
    [tau_b, l_b, info_tb] = get_tb([g, k, v_Hb], f); e_b = f; 
  else
    tau_b = tel_b(1); e_b = tel_b(2); l_b = tel_b(3); info_tb = 1; 
  end
  
  % specify times since birth in trajectory; assume that (tau_p-tau_b)>1e6
  if ~exist('tau', 'var') || isempty(tau)
    tau_int = [0; 1e6]; tau_end = tau_int(end); n_tau = 2;
  else % if tau(end)<tau_p, uncertain  v_Hp, l_p  
    if tau(1)>0
      tau_int = [0; tau]; 
    else
      tau_int = tau; 
    end
    tau_end = tau(end); n_tau = length(tau);
  end
  
  % get trajectory and traits
  if exist('tau','var')
    options = odeset('AbsTol',1e-9, 'RelTol',1e-9); 
    [t, vel] = ode45(@dget_vel, tau_int, [v_Hb; e_b; l_b], options, f, g, k, l_T, l_b, v_Hj, v_Hp); 
    tau_j = tau_b + spline1(v_Hj, [vel(:,1),t]); e_j = spline1(v_Hj, vel(:,[1 2])); l_j = spline1(v_Hj, [vel(:,3),t]);
    if vel(end,1)<v_Hp
      tau_p = NaN; e_p = NaN; l_p = NaN; info_tvel = 0;
    else
      tau_p = tau_b + spline1(v_Hp, [vel(:,1),t]);
      e_p = spline1(v_Hp, vel(:,[1 2])); % equals f if e is in equilibrium 
      l_p = spline1(v_Hp, vel(:,[1 3]));
      info_tvel = 1;
    end
  else
    options = odeset('Events',@jp, 'AbsTol',1e-8, 'RelTol',1e-8); 
    [t, vel, tau_jp, vel_jp, ie] = ode45(@dget_vel, tau_int, [v_Hb; e_b; l_b], options, f, g, k, l_T, l_b, v_Hj, v_Hp); 
    tau_j = tau_b + tau_jp(1); tau_p = tau_b + tau_jp(2); 
    e_j = vel_jp(1,2); e_p = vel_jp(2,2); % equals f if e is in equilibrium at j, p
    l_j = vel_jp(1,3); l_p = vel_jp(2,3);
    info_tvel = (length(ie)==2);
  end
  tvel = [t,vel]; % t(end)=1e6 if tau_p>1e6 or t(end)=tau_p if tau_p<e6 
  if exist('tau', 'var') && tau(1)>0 
    tvel(1,:) = []; 
  end
  tvel = tvel(1:n_tau,:); 
  
  % get scaled growth rates for e = f
  rho_j = g * (f/ l_b - (1 + l_T/ l_b))/ (f + g); % exponential growth rate
  rho_B = 1/ 3/ (1 + f/ g); % v Bert growth rate
  l_i = (l_j/ l_b) * (f - l_T); % ultimate scaled length
  
  info = min(info_tb, info_tvel);
  
  if exist('tau','var')
    varargout = {tvel, tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B, info};
  else
    varargout = {tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B, info};
  end
end

function dvel = dget_vel(tau, vel, f, g, k, l_T, l_b, v_Hj, v_Hp)
  persistent s_M
  
  % unpack vel
  v_H = vel(1); % -, scaled maturity v_H
  e = vel(2);   % -, scaled reserve density
  l = vel(3);   % -, scaled structural length
  
  de = (f - e) * g/ l;  % d/dtau e
  if v_H < v_Hj % acceleration
    s_M = l/ l_b;
    rho = g * (e/ l_b - (1 + l_T/ l_b))/ (e + g); % scaled specific growth rate
  else % no acceleration
    rho = g * (e * s_M/ l - (1 + l_T/ l))/ (e + g); % scaled specific growth rate
  end
  dl = rho * l/ 3; % d/dtau l
  if v_H < v_Hp % juvenile
    dv_H = e * l^3 * (s_M/ l - rho/ g) - k * v_H; % d/dtau v_H
  else % adult
    dv_H = 0;
  end
  dvel = [dv_H; de; dl]; % d/dtau vel 
end
%
function [value,isterminal,direction] = jp(tau, vel, f, g, k, l_T, l_b, v_Hj, v_Hp)
  value = vel(1) - [v_Hj v_Hp]; % trigger 
  isterminal = [0 1];  % terminate after event
  direction  = []; % get all the zeros
end