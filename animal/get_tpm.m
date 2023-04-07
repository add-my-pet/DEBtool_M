%% get_tpm
% Gets scaled age, length at puberty, birth for std model

%%
function varargout = get_tpm(p, f, tel_b, tau)
  % created at 2023/03/26 by Bas Kooijman, 
 
  %% Syntax
  % varargout = <../get_tpm.m *get_tpm*> (p, f, tel_b, tau)
  
  %% Description
  % Obtains scaled ages, lengths at puberty, birth for the std model at constant food, temperature;
  % Notice p-b sequence in output, due to the name of the routine.
  % State at birth (scaled age, reserve density, length) can optionally be specified
  % E.g. for female: [tau_b, f, l_b] with zoom factor z, but for male: [tau_b, f*z/z_m, l_b*z/z_m] with zoom factor z_m
  %
  % Input
  %
  % * p: 5-vector with parameters: g, k, l_T, v_H^b, v_H^p 
  % * f: optional scalar with functional response (default f = 1)
  % * tel_b: optional 3-vector with scaled age, reserve density and length at birth
  % * tau: optional n-vector with scaled times since birth
  %  
  % Output
  %
  % * tvel: optional (n,4)-array with time since birth, scaled maturity, reserve density and length
  % * tau_p: scaled age at puberty \tau_p = a_p * k_M
  % * tau_b: scaled age at birth \tau_b = a_b * k_M
  % * l_p: scaled length at puberty l_b = L_b/ L_m
  % * l_b: scaled length at birth l_p = L_/p L_m
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % If tel_b is specified and different from the DEB value for p and f, see get_tb, initial growth deviates from vBert
  % The m in get_tpm stands for male, see get_tp for female
  
  %% Example of use
  %  get_tpm([.5, .1, 0, .01, .05]) or: 
  %  tel_b = [t_b, f*z/z_m, l_b*z/z_m]; % for males assumes same absolute reserve density at birth
  %  pars_tpm = [g_m k l_T v_Hb v_Hx v_Hpm]; 
  %  tau = t * k_M * TC; % -, scaled time since birth corrected for temperature
  %  [tvel, tau_p, tau_b, l_p, l_b, info] = get_tpm(pars_tpm, f, tel_b, tau);
   
  % unpack pars
  g    = p(1); % energy investment ratio
  k    = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  l_T  = p(3); % scaled heating length {p_T}/[p_M]Lm
  v_Hb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = E_H^b/ {p_Am}
  v_Hp = p(5); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_H^p = E_H^p/ {p_Am}
    
  if ~exist('f', 'var') || isempty(f)
    f = 1;
  end
  
  % get states at birth
  if ~exist('tel_b','var') || isempty(tel_b)
    [tau_b, l_b, info_tb] = get_tb([g, k, v_Hb], f); e_b = f; 
  else
    tau_b = tel_b(1); e_b = tel_b(2); l_b = tel_b(3); info_tb = 1; 
  end
  
  % specify times since birth in trajectory
  if ~exist('tau', 'var') || isempty(tau)
    tau_int = [0; 1e6]; tau_end = tau_int(end); n_tau = 2;
  else
    if tau(1)>0
      tau_int = [0; tau]; 
    else
      tau_int = tau; 
    end
    tau_end = tau(end); n_tau = length(tau);
  end
  
  % get trajectory and traits
  if exist('tau','var')
    options = odeset('AbsTol',1e-8, 'RelTol',1e-8); 
    [t, vel] = ode45(@dget_vel, tau_int, [v_Hb; e_b; l_b], options, f, g, k, l_T, v_Hp);
    if vel(end,1)<v_Hp
      tau_p = NaN; e_p = NaN; l_p = NaN; info_tvel = 0;
    else
      tau_p = tau_b + spline1(v_Hp, [vel(:,1),t]);
      e_p = spline1(v_Hp, vel(:,[1 2])); % equals f if e is in equilibrium at p
      l_p = spline1(v_Hp, vel(:,[1 3]));
      info_tvel = 1;
    end
    tvel = [t, vel]; 
    if length(tau_int)==2; tvel = tvel([1;end],:); end
    if tau(1)>0; tvel(1,:)=[]; end
  else 
    options = odeset('Events',@pub, 'AbsTol',1e-8, 'RelTol',1e-8); 
    [t, vel, tau_p, vel_p, ie] = ode45(@dget_vel, tau_int, [v_Hb; e_b; l_b], options, f, g, k, l_T, v_Hp); 
    if isempty(tau_p)
      e_p = NaN; l_p = NaN; info_tvel = 0;
    else
      e_p = vel_p(1,2); l_p = vel_p(1,3); info_tvel = 1;
    end
    tvel = [t, vel]; % t(end)=1e6 if tau_p>1e6 or t(end)=tau_p if tau_p<e6 
    if exist('tau', 'var') && tau(1)>0 
      tvel(1,:)=[]; 
    end
  end
  
  info = min(info_tb, info_tvel);
  
  if exist('tau','var')
    varargout = {tvel, tau_p, tau_b, l_p, l_b, info};
  else
    varargout = {tau_p, tau_b, l_p, l_b, info};
  end

end

function dvel = dget_vel(tau, vel, f, g, k, l_T, v_Hp)
  % unpack vel
  v_H = vel(1); % -, scaled maturity 
  e = vel(2);   % -, scaled reserve density
  l = vel(3);   % -, scaled structural length
  
  de = (f - e) * g/ l;  % d/dtau e
  rho = g * (e/ l - (1 + l_T/ l))/ (e + g); % scaled specific growth rate
  dl = rho * l/ 3; % d/dtau l
  if v_H < v_Hp % juvenile
    dv_H = e * l^3 * (1/ l - rho/ g) - k * v_H; % d/dtau v_H
  else % adult
    dv_H = 0;
  end
  dvel = [dv_H; de; dl]; % d/dtau vel 
end

function [value,isterminal,direction] = pub(tau, vel, f, g, k, l_T, v_Hp)
  value = vel(1) - v_Hp;  % trigger 
  isterminal = [0 1]; % terminate after event
  direction  = []; % get all the zeros
end
