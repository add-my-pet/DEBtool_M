%% get_tm_j
% Gets scaled mean age at death

%%
function [tau_m, S_b, S_p, info] = get_tm_j(p, f)
  % created 2021/06/28 by Bas Kooijman
  
  %% Syntax
  % [tau_m, S_b, S_p, info] = <../get_tm.m *get_tm_j*>(p, f)
  
  %% Description
  % Obtains scaled mean age at death by integration of cumulative survival prob over length for the abj model. 
  % Divide the result by the somatic maintenance rate coefficient to arrive at the mean age at death. 
  %
  % Input
  %
  % * p: 8-vector with parameters: g k lT vHb vHj vHp ha SG 
  % * f: scalar with scaled reserve density at birth (default f = 1)
  %  
  % Output
  %
  % * tau_m: scalar with scaled mean life span
  % * S_b: scalar with survival probability at birth 
  % * S_p: scalar with survival prabability at puberty (if length p = 7)
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % Theory is given in comments on DEB3 Section 6.1.1 
  
  %% Example of use
  % get_tm_j([.5, .1, 0, .01, .02, .1, .01, 1])
  
  %  unpack pars
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % scaled heating length {p_T}/[p_M]Lm
  vHb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_B^b = M_H^b/ {J_EAm}
  %vHj = p(5); % v_H^j = U_H^j g^2 kM^3/ (1 - kap) v^2; U_B^j = M_H^j/ {J_EAm}
  %vHp = p(6); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_B^p = M_H^p/ {J_EAm}
  ha  = p(7); % h_a/ k_M^2, scaled Weibull aging acceleration
  sG  = p(8); % Gompertz stress coefficient
  
  if ~exist('f', 'var') || isempty(f)
    f = 1;
  end
   
  [tj, tp, tb, lj, lp, lb, ~, ~, ~, info_tj] = get_tj (p, f);
  [uE0, ~, info_uE0] = get_ue0([g, k, vHb], f, lb);
  
  x0 = [uE0; 1e-4; 0; 0; 1; 0]; % initiate uE l q h S cS
  [t, x]= ode45(@dget_tm_egg, [0; tb], x0, [], g, ha, sG);
  xb = x(end,:)'; xb(1) = []; % l q h S cS at birth
  options = odeset('Events', @dead_for_sure, 'NonNegative', ones(5,1));  
  [t, x]= ode45(@dget_tm_adult, [tb; tj; tp; 1e10], xb, options, g, lT, lb, lj, ha, sG, f);
  if size(x,1)==4
    S_b = x(1,4); S_p = x(3,4); tau_m = x(4,5);
  else
    S_b = x(1,4); S_p = []; tau_m = x(end,5);
  end

  if info_tj == 1 && info_uE0 == 1 && lp < f*lj/lb - lT
    info = 1;
  else
    info = 0;
    if info_uE0 ~= 1
      fprintf('warning: no convergence for u_E0 \n');
    elseif info_lj ~= 1
      fprintf('warning: no convergence for t_j \n');
    else
      fprintf('warning: l_p > f*s_M - l_T \n');
    end
  end
end

% subfunctions

function dx = dget_tm_egg(t, x, g, ha, sG)
  %  t: scalar with scaled time
  %  x: 6-vector with scaled state variables, see below
  %  dx: d/dt x
  
  % unpack state variables
  uE = max(0,x(1)); % reserve
  l  = max(0,x(2)); % length
  q  = max(0,x(3)); % acelleration 
  h  = max(0,x(4)); % hazard
  S  = max(0,x(5)); % survival probability
  % cS = x(6); % cumulative survival probability

  % derivatives with respect to time
  r = (g * uE/ l^4 - 1)/ (uE/ l^3 + g); % spec growth rate in scaled time
  duE = - uE * l^2 * (g + l)/ (uE + l^3);
  dl = l * r/ 3;
  dq = (q * sG + ha/ l^3) * g * uE * (g/ l - r) - r * q;
  dh = q - r * h;
  dS = - S * h;
  dcS = S;

  % pack derivatives
  dx = [duE; dl; dq; dh; dS; dcS];
end

function dx = dget_tm_adult(t, x, g, lT, lb, lj, ha, sG, f) 
  %  t: scalar with scaled time
  %  x: 5-vector with state variables, see below
  %  dx: d/dt x
  
  % unpack state variables
  l  = max(0,x(1)); % scaled length
  q  = max(0,x(2)); % acelleration 
  h  = max(0,x(3)); % hazard
  S  = max(0,x(4)); % survival probability
  % cS = x(5); % cumulative survival probability
 
  sM = lj/ lb; 
  
  % derivatives with respect to scaled time
  if l < lj
    r = (f/lb - lT/lb - 1)/ (f/g + 1);    % scaled exponential growth rate between b and j
  else
    r = (f*sM - lT*sM - l)/ l/ (f/g + 1); % spec growth rate in scaled time between j and i
  end
  dl = l * max(0,r)/ 3;
  dq = max(0, (q * l^3 * sG + ha) * f * (g/ l - r) - r * q);
  dh = max(0, q - r * h);
  dS = - S * h;
  dcS = S;
 
  % pack derivatives
  dx = [dl; dq; dh; dS; dcS];
end

% event dead_for_sure, linked to dget_tm_adult
function [value, isterminal, direction] = dead_for_sure(t, lqhSC, varargin)
  value = lqhSC(4) - 1e-6;  % trigger 
  isterminal = 1;   % terminate after the first event
  direction  = [];  % get all the zeros
end

