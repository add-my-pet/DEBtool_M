%% get_tm
% Gets scaled mean age at death

%%
function [tau_m, S_b, S_p, info] = get_tm(p, F, lb, lp)
  % created 2009/02/21 by Bas Kooijman; modified 2013/08/21, 2015/01/18, 2021/06/28
  
  %% Syntax
  % [t_m, S_b, S_p, info] = <../get_tm.m *get_tm*>(p, F, lb, lp)
  
  %% Description
  % Obtains scaled mean age at death by integration of cumulative survival prob over length for the std model. 
  % Divide the result by the somatic maintenance rate coefficient to arrive at the mean age at death. 
  %
  % Input
  %
  % * p: 7-vector with parameters: g k lT vHb vHp ha SG
  % * F: optional scalar with scaled reserve density at birth (default F = 1)
  % * lb: optional scalar with scaled length at birth (default: lb is obtained from get_lb)
  % * lp: optional scalar with scaled length at puberty
  %  
  % Output
  %
  % * t_m: scalar with scaled mean life span
  % * S_b: scalar with survival probability at birth 
  % * S_p: scalar with survival prabability at puberty (if length p = 7)
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % Theory is given in comments on DEB3 Section 6.1.1 
  % The variant <get_tm_foetus.html *get_tm_foetus*> does the same in case of foetal development. 
  % See <get_tm_s.html *get_tm_s*> for a short growth period relative to the life span
  
  %% Example of use
  % get_tm([.5, .1, .1, .01, .2, .1, .01])
  
  %  unpack pars
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % scaled heating length {p_T}/[p_M]Lm
  vHb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_B^b = M_H^b/ {J_EAm}
  %vHp = p(5); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_B^p = M_H^p/ {J_EAm}
  ha  = p(6); % h_a/ k_M^2, scaled Weibull aging acceleration
  sG  = p(7); % Gompertz stress coefficient
  
  if ~exist('F', 'var')
    f = 1;
  elseif isempty(F)
    f = 1;
  else
    f = F;
  end
   
  if ~exist('l_p','var') && ~exist('l_b','var')
    [tp, tb, lp lb info_tp] = get_tp (p, f);
  elseif ~exist('l_p','var') || isempty('l_p')
    [tp, tb, lp lb info_tp] = get_tp(p, f, lb);
  end
  [uE0, lb, info_uE0] = get_ue0([g, k, vHb], f, lb);
  
  x0 = [uE0; 0; 0; 1; 0]; % initiate uE q h S cS
  [l, x]= ode45(@dget_tm_egg, [1e-6; lb], x0, [], g, lT, ha, sG);
  xb = x(end,:)'; xb(1) = lb; % l q h S cS at birth
  options = odeset('Events', @dead_for_sure, 'NonNegative', ones(5,1));  
  [t, x]= ode45(@dget_tm_adult, [tb; tp; 1e8], xb, options, g, lT, ha, sG, f);
  S_b   = x(1,4);
  S_p   = x(2,4);
  tau_m = x(3,5);

  if info_tp == 1 && info_uE0 == 1 && lp < f - lT
    info = 1;
  else
    info = 0;
    if info_uE0 ~= 1
      fprintf('warning: no convergence for uE0 \n');
    elseif info_lp ~=1
      fprintf('warning: no convergence for t_p \n');
    else
      fprintf('warning: l_p > f - l_T \n');
    end
  end
end

% subfunctions

function dx = dget_tm_egg(l, x, g, lT, ha, sG)
  %  created 2000/09/21 by Bas Kooijman; modified 2009/09/29
  %  routine called by get_tm
  %  l: scalar with scaled length l = L/L_m
  %  x: 5-vector with state variables, see below
  %  dx: d/dt x
  
  % unpack state variables
  uE = x(1); % scaled reserve
  q  = x(2); % acelleration 
  h  = x(3); % hazard
  S  = x(4); % survival probability
  % cS = x(5); % cumulative survival probability

  % derivatives with respect to time
  r = (g * uE/ l^4 - 1 - lT/ l)/ (uE/ l^3 + g); % spec growth rate in scaled time
  dl = l * r/ 3;
  duE = - uE * l^2 * (g + (1 + lT/ l) * l)/ (uE + l^3);
  dq = (q * sG + ha/ l^3) * g * uE * (g/ l - r) - r * q;
  dh = q - r * h;
  dS = - S * h;
  dcS = S;

  % pack derivatives with respect to length
  dx = [duE; dq; dh; dS; dcS]/ dl;
end

function dx = dget_tm_adult(t, x, g, lT, ha, sG, f)
  %  created 2000/09/21 by Bas Kooijman; modified 2009/09/29
  %  routine called by get_tm
  %  l: scalar with scaled length l = L/L_m
  %  x: 4-vector with state variables, see below
  %  dx: d/dt x
  
  % unpack state variables
  l  = x(1); % scaled length
  q  = x(2); % acelleration 
  h  = x(3); % hazard
  S  = x(4); % survival probability
  % cS = x(5); % cumulative survival probability
 
  % derivatives with respect to scaled time
  r = (f - lT - l)/ l/ (f/ g + 1); % spec growth rate in scaled time
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

