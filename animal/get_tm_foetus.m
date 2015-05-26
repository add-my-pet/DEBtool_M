%% get_tm_foetus
% Gets scaled mean age at death for foetal development

%%
function [t_m S_b S_p info] = get_tm_foetus(p, F, l_b, l_p)
  % created 2009/02/21 by Bas Kooijman; modified 2013/08/21, 2015/01/18
  
  %% Syntax
  % [t_m S_b S_p info] = <../get_tm_foetus.m *get_tm_foetus*>(p, F, l_b, l_p)
  
  %% Description
  % Obtains scaled mean age at death by integration of cumulative survival prob over length in the case of foetal development. 
  % The variant get_tm does the same in case of egg development. 
  % Divide the result by the somatic maintenance rate coefficient to arrive at the mean age at death. 
  %
  % Input
  %
  % * p: 7-vector with parameters: g k lT vHb vHp ha SG
  % * F: optional scalar with scaled reserve density at birth (default F = 1)
  % * lb: optional scalar with scaled length at birth (default: lb is obtained from get_lb_foetus)
  % * lp: optional scalar with scaled length at puberty (default: lp is obtained from get_lp_foetus)
  %  
  % Output
  %
  % * t_m: scalar with scaled mean life span
  % * S_b: scalar with survival probability at birth 
  % * S_p: scalar with survival prabability at puberty (if length p = 7)
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % Theory is given in comments on DEB3 Section 6.1.1. 
  % The variant <get_tm.html *get_tm*> does the same in case of egg development. 
  
  %% Example of use
  % get_tm_foetus([.1, .1, .1, .001, .2, .1, .01])
  
  %  unpack pars
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % scaled heating length {p_T}/[p_M]Lm
  vHb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_B^b = M_H^b/ {J_EAm}
  %vHp = p(5); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_B^p = M_H^p/ {J_EAm}
  ha  = p(6); % h_a/ k_M^2, scaled Weibull aging acceleration
  sG  = p(7); % Gompertz stress coefficient
  
  if ~exist('F','var')
    f = 1;
  elseif isempty(F)
    f = 1;
  else
    f = F;
  end
   
  info_lp = 1;
  if exist('l_p','var') == 0 && exist('l_b','var') == 0 
      [l_p l_b info_lp] = get_lp (p, f);
  elseif exist('l_p','var') == 0 || isempty('l_p')
      [l_p l_b info_lp] = get_lp(p, f, l_b);
  end
  
  [uE0, l_b, t_b, info_ue0] = get_ue0_foetus([g, k, vHb], f, l_b);
    
  x0 = [uE0; 0; 0; 1; 0]; % initiate uE q h S cS
  [l x]= ode23(@dget_tm_foetus, [1e-6; l_b], x0, [], g, lT, ha, sG, f);
  xb = x(end,:)'; xb(1) = []; % q h S cS at birth
  l = [l_b; l_p; max(l_p + 1e-6, f - lT - 1e-6)];
  [l x]= ode23s(@dget_tm_adult, l, xb, [], g, lT, ha, sG, f);
  S_b = x(1,3);
  S_p = x(2,3);
  t_m = x(3,4);

  if info_lp == 1 && info_ue0 == 1 && l_p < f - lT
    info = 1;
  else
    info = 0;
    if info_ue0 ~= 1
      fprintf('warning: no convergence for get_uE0_foetus \n');
    elseif info_lp ~=1
      fprintf('warning: no convergence for get_lp \n');
    else
      fprintf('warning: l_p < f - l_T \n');
    end
  end
end

% subfunctions

function dx = dget_tm_foetus(l, x, g, lT, ha, sG, f)
  %  created 2000/09/21 by Bas Kooijman; modofied 2009/09/29
  %  routine called by get_tm
  %  l: scalar with scaled length l = L/L_m
  %  x: 5-vector with state variables, see below
  %  dx: d/dt x
  
  % unpack state variables
  uE = x(1); % scaled reserve
  q  = x(2); % acelleration 
  h  = x(3); % hazard
  S  = x(4); % survival probability
  %cS = x(5); % cumulative survival probability

  % derivatives with respect to time
  r = (g * uE/ l^4 - 1 - lT/ l)/ (uE/ l^3 + g); % spec growth rate in scaled time
  dl = l * r/ 3;
  duE = f * l^2 - uE * l^2 * (g + (1 + lT/ l) * l)/ (uE + l^3);
  dq = (q * sG + ha/ l^3) * g * uE * (g/ l - r) - r * q;
  dh = q - r * h;
  dS = - S * h;
  dcS = S;
  
  % pack derivatives with respect to length
  dx = [duE; dq; dh; dS; dcS]/ dl;
end

function dx = dget_tm_adult(l, x, g, lT, ha, sG, f)
  %  created 2000/09/21 by Bas Kooijman; modified 2009/09/29
  %  routine called by get_tm
  %  l: scalar with scaled length l = L/L_m
  %  x: 4-vector with state variables, see below
  %  dx: d/dt x
  
  % unpack state variables
  q  = x(1); % acelleration 
  h  = x(2); % hazard
  S  = x(3); % survival probability
  % cS = x(4); % cumulative survival probability
  % uE = f * l^3/ g; % scaled reserve
 
  % derivatives with respect to time
  r = (f - lT - l)/ l/ (f/ g + g); % spec growth rate in scaled time
  dl = l * r/ 3;
  dq = (q * l^3 * sG + ha) * f * (g/ l - r) - r * q;
  dh = q - r * h;
  dS = - S * h;
  dcS = S;
 
  % pack derivatives with respect to length
  dx = [dq; dh; dS; dcS]/ dl;
end
