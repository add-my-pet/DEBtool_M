%% get_tj 
% Gets scaled age at metamorphosis

%%
function varargout = get_tj(p, f, tel_b, tau)
  % created at 2011/04/25 by Bas Kooijman, 
  % modified 2014/03/03 Starrlight Augustine, 2015/01/18 Bas Kooijman
  % modified 2018/09/10 (t -> tau) Nina Marn, 2023/04/05, 2023/08/28 2025/02/27 Bas Kooijman 
  
  %% Syntax
  % varargout = <../get_tj.m *get_tj*> (p, f, tel_b, tau)
  
  %% Description
  % Obtains scaled ages at metamorphosis, puberty, birth and the scaled lengths at these ages;
  % Multiply the result with the somatic maintenance rate coefficient to arrive at unscaled ages. 
  % Metabolic acceleration occurs between birth and metamorphosis, see also get_ts. 
  % Notice j-p-b sequence in output, due to the name of the routine
  %
  % Input
  %
  % * p: 6-vector with parameters: g, k, l_T, v_H^b, v_H^j, v_H^p 
  % * f: optional scalar with functional response (default f = 1) or (n,2)-array with scaled time since birth and scaled func response
  % * tel_b: optional scalar with scaled length at birth or 3-vector with scaled age at birth, reserve density and length at birth
  % * tau: optional n-vector with scaled times since birth
  %  
  % Output
  %
  % * tvel: optional (n,4)-array with scaled time-since-birth, maturity, reserve density and length
  % * tau_j: scaled age at metamorphosis \tau_j = a_j k_M
  % * tau_p: scaled age at puberty \tau_p = a_p k_M
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
  % If input f is scalar (so food is constant), l_j and l_p are solved via fzero, and numerical integration is avoided.
  % if fzero fails, varying food it tried.
 
  %% Example of use
  %  get_tj([.5, .1, 0, .01, .05, .2])
  
  % unpack pars
  g    = p(1); % energy investment ratio
  k    = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  l_T  = p(3); % scaled heating length {p_T}/[p_M]Lm
  v_Hb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = E_H^b/ {p_Am}
  v_Hj = p(5); % v_H^j = U_H^j g^2 kM^3/ (1 - kap) v^2; U_H^j = E_H^j/ {p_Am}
  v_Hp = p(6); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_H^p = E_H^p/ {p_Am}
    
  if ~exist('f', 'var') || isempty(f) % constant food
    f = 1; f_i = f; info_con = 1;
  elseif length(f) == 1 % constant food
    f_i = f; info_con = 1;
  else % varying food
    f_i = f(end,2); info_con = 0;
  end
  tvel = [];

  
  % embryo
  if exist('tel_b', 'var') && ~isempty(tel_b)
    if length(tel_b) == 1
      tau_b = get_tb(p([1 2 4]), f_i);
      e_b = f_i;
      l_b = tel_b;
    else
      tau_b = tel_b(1);
      e_b   = tel_b(2);
      l_b   = tel_b(3);
    end
  else
    e_b = f_i;
    [tau_b, l_b] = get_tb(p([1 2 4]), e_b);
  end
  vel_b = [v_Hb; e_b; l_b]; % states at birth
  rho_j = (f_i/ l_b - 1 - l_T/ l_b)/ (1 + f_i/ g); % -, scaled exp growth rate
  rho_B = 1/ 3/ (1 + f_i/ g); % -, scaled von Bert growth rate
  
  info = 1;
  if ~exist('tau','var'); tau = [0;1e10]; info_tau = 0; else; info_tau = 1; end   
  if exist('info_tb','var') && exist('info_lj','var'); info = min(info_tb, info_lj); end
  
  % juvenile & adult
  if info_con % constant food
    try 
      options = optimset('TolX',1e-16);
      [l_j, ~, info_lj] = fzero(@get_lj, [l_b 1], options, v_Hj, l_b, v_Hb, l_T, rho_j, rho_B, k, g, f);
      [l_p, ~, info_lp] = fzero(@get_lp, [l_j 1], options, v_Hp, l_j, v_Hj, l_b, v_Hb, tau_b, l_T, rho_j, rho_B, k, g, f);
      s_M = l_j/ l_b; l_i = s_M * (f - l_T); l_d = l_i - l_j;
      tau_j =  tau_b + log(s_M) * 3/ rho_j; tau_p = tau_j + log((l_i - l_j)/ (l_i - l_p))/ rho_B; 
      Tau = tau + tau_b; % tau: scaled time since birth; Tau: scaled age
      if info_lj==1 && info_lp==1; info = 1; else info = 0; tau_j = NaN; tau_p = NaN; return; end
      if info_tau
        l = [l_b*exp(tau(Tau<tau_j)*rho_j/3); l_i-(l_i-l_j)*exp(-rho_B*(Tau(Tau>=tau_j)-tau_j))]; % scaled length
        b3 = f/ (f + g); b2 = f * s_M - b3 * l_i;
        a0 = - (b2 + b3 * l_i) * l_i^2/ k; a1 = - (2 * b2 + 3 * b3 * l_i) * l_i * l_d/ (rho_B - k);
        a2 = (b2 + 3 * b3 * l_i) * l_d^2/ (2 * rho_B - k); a3 = - b3 * l_d^3/ (3 * rho_B - k);
        sum_a = a0 + a1 + a2 + a3; 
        sum_ae = a0 + a1 * exp(- rho_B * Tau(Tau>=tau_j)) + a2 * exp(- 2 * rho_B * Tau(Tau>=tau_j)) + a3 * exp(- 3 * rho_B * Tau(Tau>=tau_j));
        v_H = [f*l_b^3*(1/l_b-rho_j/g)/(k+rho_j)*(exp(rho_j*Tau(Tau<tau_j))-exp(-k*Tau(Tau<tau_j)))+v_Hb*exp(-k*Tau(Tau<tau_j)); ...
          (v_Hj+sum_a)*exp(-k*Tau(Tau>=tau_j)) - sum_ae]; % scaled maturity
        tvel = [tau, min(v_H,v_Hp), f*ones(length(tau),1), l];
      end
      if ~(info_lj==1 && info_lp==1); info_con = 0; end
    catch
      info_con = 0; % if constant food failed, try varying food
    end
  end
    
  if ~info_con % varying food
    options = odeset('Events',@event_jp, 'AbsTol',1e-8, 'RelTol',1e-8); 
    %options = odeset('Events',@event_jp); 
    [t, vel, tau_jp, vel_jp] = ode45(@dget_lj, [-1e-10; tau], vel_b, options, info_tau, f, l_b, g, k, l_T, v_Hj, v_Hp);
    tvel = [t, vel]; tvel(1,:) = []; if (length(tau)==1); tvel = tvel(end,:); end
    if isempty(vel_jp)
      tau_j = NaN; tau_p = NaN; l_j = NaN; l_p = NaN; l_i = NaN; info = 0;
    elseif length(tau_jp) == 1
      tau_j = tau_b + tau_jp(1);  l_j = vel_jp(1,3); tau_p = NaN; l_p = NaN; l_i = f_i * l_j/ l_b; info = 0;
    else
      tau_j = tau_b + tau_jp(end-1); tau_p = tau_b + tau_jp(end); 
      l_j = vel_jp(end-1,3); l_p = vel_jp(end,3); l_i = f_i * l_j/ l_b; 
    end

  end 

  if isempty(tau_p) || ~isreal(tau_p) || ~isreal(tau_j) % tj and tp must be real and positive
    info = 0;
  elseif tau_p < 0 || tau_j < 0 || rho_j <= 0 || rho_B <=0
    info = 0;
  end

  if info_tau
    varargout = {tvel, tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B, info};
  else
    varargout = {tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B, info};
  end
end

function [value,isterminal,direction] = event_jp(tau, vel, info_tau, tf, l_b, g, k, l_T, v_Hj, v_Hp)
  % vel: 3-vector with [v_H; e; l]
  value = [v_Hj; v_Hp] - vel(1);
  isterminal = [0; ~info_tau];
  direction  = [0; 0]; 
end

function dvel = dget_lj (tau, vel, info_tau, tf, l_b, g, k, l_T, v_Hj, v_Hp)
  % tau: scaled time since birth 
  % v_H continues changing after v_Hp for simplicity's sake, but is not used
  persistent s_M % set while v_H<v_Hj, used after v_H>v_Hj
  
  v_H = vel(1); e = vel(2); l = vel(3);
  
  if size(tf,2)==1 % f constant
    f = tf(1); 
  else % f is varying
    f = spline1(tau,tf);
  end
  
  if v_H < v_Hj; s_M = l/ l_b; end  % s_M = acceleration factor, requires v_H(0) < v_Hj
  de = (f - e) * g/ l; % d/d tau e
  rho = g * (e * s_M/ l - 1 - s_M * l_T/ l)/ (e + g); % -, spec growth rate
  dl = l * rho/ 3; % -, d/d tau l  
  dv_H = (v_H <v_Hp) * (e * l^3 * (s_M/ l - rho/ g) - k * v_H); % -, d/d tau v_H
  dvel = [dv_H; de; dl]; % pack to output
end

function fn = get_lj(l_j, v_Hj, l_b, v_Hb, l_T, rho_j, rho_B, k, g, f) 
  s_M = l_j/ l_b; s_j = s_M^(-3 * k/ rho_j); 
  fn = v_Hj - f * l_b^3 * (1/ l_b - rho_j/ g)/ (k + rho_j) * (s_M^3 - s_j) - v_Hb * s_j;
end

function fn = get_lp(l_p, v_Hp, l_j, v_Hj, l_b, v_Hb, tau_b, l_T, rho_j, rho_B, k, g, f)
   s_M = l_j/ l_b; l_i = s_M * (f - l_T); l_d = l_i - l_j;
   tau_j = tau_b + log(s_M) * 3/ rho_j; tau_p = tau_j + log((l_i - l_j)/ (l_i - l_p))/ rho_B;
   b3 = f/ (f + g); b2 = f * s_M - b3 * l_i;
   a0 = - (b2 + b3 * l_i) * l_i^2/ k; a1 = - (2 * b2 + 3 * b3 * l_i) * l_i * l_d/ (rho_B - k);
   a2 = (b2 + 3 * b3 * l_i) * l_d^2/ (2 * rho_B - k); a3 = - b3 * l_d^3/ (3 * rho_B - k);
   sum_a = a0 + a1 + a2 + a3; 
   sum_ae = a0 + a1 * exp(- rho_B * tau_p) + a2 * exp(- 2 * rho_B * tau_p) + a3 * exp(- 3 * rho_B * tau_p);
   fn = v_Hp - (v_Hj + sum_a) * exp(- k * tau_p) + sum_ae;
end
