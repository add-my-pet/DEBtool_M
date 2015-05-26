%% get_tul_i
% Gets scaled age, reserve and length at birth

%%
function p = get_tul_i(par, hul_0)
  % created 2007/07/29 by Bas Kooijman; modified 2007/09/02
  
  %% Syntax
  % p = <../get_tul_i.m *get_tul_i*> (par, hul_0)
  
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
  % * hul_0: 3-vector with initial scaled maturity, reserve, length
  %  
  % Output
  %
  % * p: 3-vector with tau_b, u_E^b, l_b
  
  %% Remarks
  %  Function <get_tul.html *get_tul*> is similar, but the second input represents the scaled reserve density at birth

  %% Example of use
  % See <../mydata_ue0.m *mydata_ue0*>
  
  global k g % for dget_tul

  % unpack input parameters
  g   = par(1); % energy investment ratio
  k   = par(2); % ratio of maturity and somatic maintenance rate coefficients
  vHb = par(3); % scaled maturity at birth
  %               (g^2 k_M^3/ v^2) M_H^b/ ((1 - kap) {J_EAm})

  vH0 = hul_0(1); tul_0 = hul_0; tul_0(1) = 0;
  [vH, tul] = ode45s('dget_tul', [vH0; vHb], tul_0);

  % prepare output
  p = tul(end,:)';
