%% get_leh
% Gets 7 variables at constant food as function of time

%%
function leh = get_leh(t, p, F)
  % created 2009/01/28 by Bas Kooijman; modified 2009/09/29, 2015/01/18
  
  %% Syntax
  % leh = <../get_leh.m *get_leh*> (t, p, F)
  
  %% Description
  %  Calculates trajectories of 7 variables at constant food
  %
  % Input
  %
  % * t: n-vector with scaled times
  % * p: 7-vector with parameters: g k lT vHb vHp ha SG
  % * F: scalar with functional response (optional, default 1)
  %  
  % Output
  %
  % * leh: (n,7)-matrix with columns
  %
  %    scaled length l, scaled reserve uE, scaled maturity uH,
  %    acelleration q, hazard h, survival prob S, cum surv prob cS
  %
  
  % unpack pars (all dimensionless)
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % scaled heating length {p_T}/[p_M]Lm
  vHb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_B^b = M_H^b/ {J_EAm}
  vHp = p(5); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_B^p = M_H^p/ {J_EAm}
  ha  = p(6); % h_a/ k_M^2, scaled Weibull aging acceleration
  sG  = p(7); % Gompertz stress coefficient
  
  if ~exist('F','var')
    f = 1;
  elseif isempty(F)
    f = 1;
  else
    f = F;
  end

  [uE0 lb info] = get_ue0([g, k, vHb], f); % scaled initial reserve
  if info ~= 1
      fprintf('warning: no convergence for uE0 \n');
  end
  
  x0 = [lb/1000; uE0; 1e-12; 0; 0; 1; 0];
  if t(1) == 0
    [t leh] = ode23(@dget_tm, t, x0, [], g, k, lT, vHb, vHp, ha, sG, f);           
  else
    t = [0; t];
    [t leh] = ode23(@dget_tm, t, x0, [], g, k, lT, vHb, vHp, ha, sG, f); 
    leh(1,:) = [];
  end

end

% subfunctions

function dx = dget_tm(t, x, g, k, lT, vHb, vHp, ha, sG, f)
  %  created 2000/09/06 by Bas Kooijman, modified 2009/01/24
  %  routine called by get_tm
  %  t: scalar with scaled age: a k_M
  %  x: 7-vector with state variables, see below
  %  dx: d/dt x
  
  % unpack state variables
  l  = x(1); % scaled length
  uE = x(2); % scaled reserve
  vH = x(3); % scaled maturity
  q  = x(4); % acelleration 
  h  = x(5); % hazard
  S  = x(6); % survival probability
  cS = x(7); % cumulative survival probability
  
  if vH < vHb
    F = 0; % no feeding for embryo
    Sb = S;
  else
    F = f;
  end
  
  r = (g * uE/ l^4 - 1 - lT/ l)/ (uE/ l^3 + g); % spec growth rate in scaled time
  dl = l * r/ 3;
  duE = F * l^2 - uE * l^2 * (g + (1 + lT/ l) * l)/ (uE + l^3);
  if vH < vHp 
    dvH = uE * l^2 * (g + l)/ (uE + l^3) - k * vH;
    Sp = S;
  else       % adult
    dvH = 0;
  end
  dq = (q * sG + ha/ l^3) * g * uE * (g/ l - r) - r * q;
  dh = q - r * h;
  dS = - S * h;
  dcS = S;
  
  % pack output
  dx = [dl; duE; dvH; dq; dh; dS; dcS];
  
end
