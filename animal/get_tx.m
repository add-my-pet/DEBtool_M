%% get_tx
% gets scaled age and length at puberty, weaning, birth for foetal development.

%%
function varargout = get_tx(p, f, tel_b, tau)
  % created 2019/02/04 by Bas Kooijman, modified 2023/08/26
  
  %% Syntax
  % varargout = <../get_tx.m *get_tx*> (p, f, tel_b, tau)
  
  %% Description
  % Obtains scaled age and length at puberty, weaning, birth for foetal development. 
  % An extra optional parameter, the stress coefficient for foetal development can modify the rate of development from fast 
  %    (default, and a large stress coefficient, s_F, of 1e8) to slow (value 1 gives von Bertalanffy growth of the same rate as post-natal development). 
  % Divide all times that are output with the (temperature-corrected) somatic maintenance rate coefficient to arrive at age at puberty, weaning and birth. 
  % Make sure the times (first column of f when it is an (n,2)-array, first
  % column of tau) as scales with the temperature corrected somatic
  % maintenance rate coefficient. 
  %
  % Input
  %
  % * p: 6 or 7 -vector with parameters: g, k, l_T, v_Hb, v_Hx, v_Hp, s_F
  % * f: optional (default f = 1)
  %
  %      - scalar with scaled functional response for period bi
  %      - 2-vector with scaled functional responses for periods bx and xi (
  %      - (n,2)-array with scaled times and functional responses in the columns
  %
  % * tel_b: optional scalar with scaled length at birth
  %
  %      or 3-vector with scaled age at birth, reserve density and length at 0
  %
  % * tau: optional n-vector with scaled times since birth
  %
  % Output
  %
  % * tvel: optional (n,4)-array with scaled time-since-birth, maturity, reserve density and length
  % * tau_p: scaled age at puberty \tau_p = a_p k_M
  % * tau_x: scaled age at puberty \tau_x = a_x k_M
  % * tau_b: scaled age at birth \tau_b = a_b k_M
  % * lp: scaled length at puberty
  % * lx: scaled length at weaning
  % * lb: scaled length at birth
  % * info: indicator equals 1 if successful, 0 otherwise

  %% Remarks
  % uses integration over scaled age with event detection; this function replaces get_tx_old 
  
  %% Examples
  % See predict_Moschus_berezovskii for a gradual change from f_bx to f_xi (tf = [50 f_bx; 100 f_xi]; tf(:,1) = tf(:,1) * kT_M;
  % tvel = get_tx(pars_tx, tf, [], tW(:,1) * kT_M));). 
  % See predict_Moschiola_meminna for an instantaneous change: (pars_tx = [g k l_T v_Hb v_Hx v_Hp 1];  
  % [tau_p, tau_x, tau_b, l_p, l_x, l_b, info] = get_tx(pars_tx, [f_bx
  % f]);)
  % Notice how the input times (first column of the tW matrix, and first column of the input time varying food tf in the first
  % case) must be multiplied by the temperature corrected somatic
  % maintenance rate in order to scale them appropriately given that this
  % function only works in scaled times. 

  % unpack pars
  g    = p(1); % -, energy investment ratio
  k    = p(2); % -, k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  l_T  = p(3); % -, scaled heating length
  v_Hb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_B^b = M_H^b/ {J_EAm}
  v_Hx = p(5); % v_H^x = U_H^x g^2 kM^3/ (1 - kap) v^2; U_B^x = M_H^x/ {J_EAm}
  v_Hp = p(6); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_B^p = M_H^p/ {J_EAm}
  if length(p) >= 7
    s_F = p(7); % slow development: s_F = 1, for s_F > 1 intermediate between slow and fast
  else
    s_F = 1e10;  % fast development
  end

  % optional input f
  if ~exist('f','var')
    f = 1; 
  end 
  % optional input tau
  if exist('tau','var') 
    info_tau = 1; % time points are specified
  else
    info_tau = 0; tau = 1e20; 
  end
  
  % embryo
  if size(f,1)==1 && size(f,2)==1
    f_0b = f;
  elseif size(f,1)==1 && size(f,2)==2
    f_0b = f(2);
  else
    f_0b = spline1(1e10, f); % ultimate f of mother
  end
  options = odeset('Events',@event_b, 'AbsTol',1e-9, 'RelTol',1e-9); 
  [~, ~, tau_b, vl_b] = ode45(@dget_lb, [0; 1e10], [1e-20; 1e-20], options, f_0b, s_F, g, k, v_Hb);
  l_b = vl_b(1,2);
  
  % optional input tel_b
  if ~exist('tel_b','var') || isempty(tel_b)
    vel_b = [v_Hb;f_0b;l_b]; 
  elseif length(tel_b) == 1
    vel_b = [v_Hb;f_0b;tel_b]; 
  else
    vel_b = [v_Hb;f_0b;tel_b(2);tel_b(3)]; tau_b = tel_b(1); 
  end

  % juvenile & adult
  options = odeset('Events',@event_xp, 'AbsTol',1e-9, 'RelTol',1e-9); 
  [tau, vel, tau_xp, vel_xp] = ode45(@dget_lx, [-1e-10; tau], vel_b, options, info_tau, f, g, k, l_T, v_Hx, v_Hp);
  if isempty(tau_xp) 
    tau_x = []; tau_p = []; l_x = []; l_p = [];
  elseif length(tau_xp) == 1
    tau_x = tau_b + tau_xp(1); tau_p = []; l_x = vel_xp(1,3); l_p = [];
  else
    tau_x = tau_b + tau_xp(1); tau_p = tau_b + tau_xp(2); l_x = vel_xp(1,3); l_p = vel_xp(2,3);
  end
  tvel = [tau, vel]; tvel(1,:) = []; info = 1;

  if ~isreal(tau_b) || ~isreal(tau_x) || ~isreal(tau_p) || tau_b < 0 || tau_x < 0 || tau_p < 0 % tb, tx and tp must be real and positive
    info = 0;
  end

  if info_tau % time points are specified
    varargout = {tvel, tau_p, tau_x, tau_b, l_p, l_x, l_b, info};
  else
    varargout = {tau_p, tau_x, tau_b, l_p, l_x, l_b, info};
  end

end

% subfunctions

function dvl = dget_lb (tau, vl, f, s_F, g, k, v_Hb)
  % tau: scaled time since start development 
  v_H = vl(1); l = vl(2); % f constant; embryo
  
  l_i = s_F * f; % -, scaled ultimate length
  f  = s_F * f;  % -, scaled functional response
  dl = (g/ 3) * (l_i - l)/ (f + g);    % d/d tau l  
  dv_H = 3 * l^2 * dl + l^3 - k * v_H; % d/d tau v_H
  dvl = [dv_H; dl]; % pack to output
end

function dvel = dget_lx (tau, vel, info_tau, tf, g, k, l_T, v_Hx, v_Hp)
  % tau: scaled time since birth 
  v_H = vel(1); e = vel(2); l = vel(3);
  
  if size(tf,1)==1 && size(tf,2)==1 % f constant in period bi
    f = tf(1); e = f; 
  elseif size(tf,1)==1 && size(tf,2)==2 % f constant in periods bx and xi
    if v_H < v_Hx; f = tf(1); else f = tf(2); end; e = f;  
  else % f is varying
    f = spline1(tau,tf);
  end
  
  de = (f - e) * g/ l; % d/d tau e
  rho = g * (e/ l - 1 - l_T/ l)/ (e + g); % -, spec growth rate
  dl = l * rho/ 3; % -, d/d tau l  
  dv_H = e * l^2 * (l + g)/ (e + g) - k * v_H; % -, d/d tau v_H
  dvel = [dv_H; de; dl]; % pack to output
end

function [value,isterminal,direction] = event_xp(tau, vel, info_tau, tf, g, k, l_T, v_Hx, v_Hp)
  % vel: 3-vector with [v_H; e; l]
  value = [v_Hx; v_Hp] - vel(1);
  isterminal = [0; ~info_tau];
  direction  = [0; ]; 
end

function [value,isterminal,direction] = event_b(tau, vl, f, s_F, g, k, v_Hb)
  % vel: 2-vector with [v_H; l]
  value = v_Hb - vl(1);
  isterminal = 1;
  direction  = 0; 
end
