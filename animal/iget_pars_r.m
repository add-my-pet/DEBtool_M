%% iget_pars_r
% Obtains growth and reprod data from compound parameters for one feeding level.

%%
function [p, U] = iget_pars_r(par, F)
  %  created 2006/09/29 by Bas Kooijman, modified 2009/09/29
  
  %% Syntax
  % [p, U] = <../iget_pars_r.m *iget_pars_r*>(par, F)
  
  %% Description
  % Obtains growth and reprod data from compound parameters for one feeding level.   
  % Maturity and somatic maitenance rate coefficients are equal.
  %
  % Input
  %
  % * par: 8-vector with
  %
  %    1 kap   % fraction allocated to som maint + growth
  %    2 kapR  % fraction of energy allocated to reprod fixed in embryo
  %    3 g     % energy investment ratio
  %    4 kJ    % maturity maintenance rate coefficient
  %    5 kM    % somatic maintenance rate coefficient
  %    6 v     % energy conductance
  %    7 Hb    % scaled maturity at birth M_H^b/{J_EAm}
  %    8 Hp    % scaled maturity at puberty M_H^p/{J_EAm}
  %
  % * F: scalar with scaled functional response (optional)
  %
  % Output
  %
  % * p: 8-vector with f, L_b, L_p, L_i, a_b, \dot{r}_B, \dot{R}_i, kapR
  % * U: 3-vector with
  %    U^0 = M_E^0/\{\dot{J}_{EAm}\},
  %    U^b = M_E^b/\{\dot{J}_{EAm}\},
  %    U^p = M_E^p/\{\dot{J}_{EAm}\}
  
  %% Remarks
  % See <get_pars_r.html *get_pars_r*> for inverse mapping

  %% Example of use
  % See <../mydata_get_pars.m *mydata_get_pars*>

  
  global kap v kJ g Lm f % for tranfer to dget_aul_p

  %  unpack input parameters
  kap = par(1); % fraction allocated to som maint + growth
  kapR= par(2); % fraction of energy allocated to reprod fixed in embryo
  g   = par(3); % energy investment ratio
  kJ  = par(4); % maturity maintenance rate coefficient
  kM  = par(5); % somatic maintenance rate coefficient
  v   = par(6); % energy conductance
  Hb  = par(7); % scaled maturity at birth M_H^b/{J_EAm}
  Hp  = par(8); % scaled maturity at puberty M_H^p/{J_EAm}

  if exist('F','var') == 0
    f = 1; % abundant food
  else
    f = F; % to make scaled functional response global
  end
  
  rB = kM * g/ (3 * (f + g));    % von Bert growth rate
  Lm = v/ (kM * g); Li = f * Lm; % max, ultimate length
  VHb = Hb/ (1 - kap);           % scaled maturity
  [U0 Lb] = initial_scaled_reserve(f, [VHb; g; kJ; kM; v]);
  ab = get_tb([g kJ/kM], f, Lb/ Lm)/ kM; % age at birth
  Ub = f * Lb^3/ v; % scaled reserve at birth
  
  Ri = ((1 - kap) * f * Li^2 - kJ * Hp) * kapR/ U0; % ultimate reprod rate
  % obtain Up Lp given conditions at birth
  [H, aUL] = ode45(@dget_aul_p, [Hb; Hp], [ab; Ub; Lb], [], kap, v, kJ, g, Lm, f);
  Up = aUL(end,2); Lp = aUL(end,3);
  
  % prepare output
  U = [U0; Ub; Up];
  p = [f; Lb; Lp; Li; ab; rB; Ri; kapR];
  