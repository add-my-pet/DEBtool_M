%% get_pars_r
% Obtains parameters from growth and reprod data at one food level

%%
function [par, U] = get_pars_r(p)
  %  created 2006/09/29 by Bas Kooijman, modified 2009/09/29
  
  %% Syntax
  % [par, U] = <../get_pars_r.m *get_pars_r*>(p)
  
  %% Description
  % Obtains parameters from growth and reprod data at one food level
  % Maturity and somatic maitenance rate coefficients are equal.
  %
  % Input
  %
  % * p: 7 or 8-vector with quantities at constant scaled functional response
  %
  %    1 f     % -  % scaled functional response
  %    2 L_b   % mm % length at birth
  %    3 L_p   % mm % length at puberty
  %    4 L_i   % mm % ultimate length
  %    5 a_b   % d  % age at birth
  %    6 \dot{r}_B % d^-1   % von Bertalanffy growth rate
  %    7 \dot{R}_i % % d^-1 % ultimate reproduction rate
  %    8 kapR  % -  % fraction allocated to reprod that is fixed in embryo's
  %            this parameter is optional; if not specified kapR = 0.95
  %
  % Output
  %
  % * par: 8-vector with
  %
  %    1 kap   % -    % fraction allocated to som maint + growth
  %    2 kapR  % -    % fraction of energy allocated to reprod fixed in embryo
  %    3 g     % -    % energy investment ratio
  %    4 kJ    % d^-1 % maturity maintenance rate coefficient
  %    5 kM    % d^-1 % somatic maintenance rate coefficient
  %    6 v     % mm/d % energy conductance
  %    7 Hb    % d mm^2 % scaled maturity at birth M_H^b/{J_EAm}
  %    8 Hp    % d mm^2 % scaled maturity at puberty M_H^p/{J_EAm}
  %
  % * U: 3-vector with
  %    U^0 = M_E^0/\{\dot{J}_{EAm}\},
  %    U^b = M_E^b/\{\dot{J}_{EAm}\},
  %    U^p = M_E^p/\{\dot{J}_{EAm}\}.
  
  %% Remarks
  % Function <iget_pars_r.html *iget_pars_r*> is inverse.

  %% Example of use
  % See <../mydata_get_pars.m *mydata_get_pars*>

  np = size(p,1);
  
  % unpack input parameters
  f  = p(1); % scaled functional response
  Lb = p(2); % length at birth
  Lp = p(3); % length at puberty
  Li = p(4); % ultimate length
  ab = p(5); % age at birth at abundant food
  rB = p(6); % von Bertalannfy growth rate
  Ri = p(7); % ultimate reproduction rate
  if np == 8
    kapR = p(8); % frac of energy allocated to reprod fixed in embryo
  else
    kapR = 0.95;
  end
  % tp = - log((Li - Lp)/ (Li - Lb))/ rB; % time since birth to puberty
  % Lm = Li/ f; % maximum length

  % get growth parameters and U0, Ub
  p_g = [f; Lb; Li; ab; rB]; [par, U] = get_pars_g(p_g);
  % unpack growth parameters
  g = par(2); kM = par(3); v = par(4); U0 = U(1); Ub = U(2);

  % now obtain parameters related to development and reproduction
  kJ = kM; % maturity maintenance rate coefficient
  % allocation fraction to somatic maintenance plus growth
  kap = 1 - Ri * U0/ (kapR * (f * Li^2 - kJ * Lp^3 * g/ v));
  Hb = Lb^3 * (1 - kap) * g/ v; % scaled maturity at birth
  Hp = Lp^3 * (1 - kap) * g/ v; % scaled maturity at puberty
  Up = Ub * (Lp/ Lb)^3;         % scaled reserve at puberty
  
  % prepare output
  par = [kap; kapR; g; kJ; kM; v; Hb; Hp];
  U = [U0; Ub; Up];