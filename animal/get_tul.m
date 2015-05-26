%% get_tul
% Gets scaled age, reserve and length at birth

%%
function [p, uE0, info] = get_tul(par, eb, lb0)
  % created 2007/07/24 by Bas Kooijman, modified 2009/09/29
  
  %% Syntax
  % [p, uE0, info] = <../get_tul.m *get_tul*> (par, eb, lb0)
  
  %% Description
  % Obtains the scaled age, reserve and length at birth. 
  %
  % Input
  %
  % * par: 3-vector with
  %
  %    1 g     % energy investment ratio
  %    2 k     % ratio of maturity and somatic maintenance rate coefficients
  %    3 vHb   % scaled maturity at birth
  %              (g^2 k_M^3/ v^2) M_H^b/ (1 - kap) {J_EAm})
  %
  % * eb: optional scalar with scaled reserve density at birth (default: eb = 1)
  % * lb0: optional scalar with initial estimate for scaled length at birth (default: exact value for maintenance ratio 1)
  %  
  % Output
  %
  % * p: 3-vector with tau_b, u_E^b, l_b
  % * uE0: scalar with u_E^0 = (g^2 k_M^3/ v^2) M_E^0/ {J_EAm}
  % * info: scalar with value 1 if successful, 0 otherwise
  
  %% Remarks
  % Function <get_tul_i.html *get_tul_i*> is similar, but the second input represents the initial values for scaled maturity, reserve, length.  

  %% Example of use
  % See <../mydata_ue0.m *mydata_ue0*>
  
  global k g vHb f % for dget_tul

  % unpack input parameters
  g   = par(1); % energy investment ratio
  k   = par(2); % ratio of maturity and somatic maintenance rate coefficients
  vHb = par(3); % scaled maturity at birth
  %               (g^2 k_M^3/ v^2) M_H^b/ ((1 - kap) {J_EAm})

  if exist('eb','var') == 0
    f = 1; % abundant food
  else
    f = eb; % to make scaled functional response global
  end

  if exist('lb0','var') == 0 || k == 1
    lb = vHb ^ (1/3); % exact solution for k = 1
  else
    lb = lb0;
  end

  options = optimset('Display','off');
  [lb, flag, info] = fsolve('fnget_tul', lb, options);
  uE0 = get_ue0(par,f,lb);

  l0 = 1e-6;
  vH0 = uE0 * l0^2 * (g + l0)/ (uE0 + l0^3)/ k;
  [uH, tul] = ode23s('dget_tul', [vH0; vHb], [0; uE0; l0]);

  % prepare output
  p = tul(end,:)';
