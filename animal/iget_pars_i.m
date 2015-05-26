%% iget_pars_i
% Obtains growth data from compound parameters a multiple feeding levels

%%
function [p, U] = iget_pars_i(par,f)
  %  created 2007/08/12 by Bas Kooijman
  
  %% Syntax
  % [p, U] = <../iget_pars_i.m *iget_pars_i*> (par,f)
  
  %% Description
  % Obtains growth data from 4 compound parameters a multiple feeding levels
  % Maturity and somatic maitenance rate coefficients are equal.
  %
  % Input
  %
  % * par: 4-vector with
  %
  %     1 VHb   % d mm^2 % scaled maturity at birth
  %     2 g     % -    % energy investment ratio
  %     3 kM    % d^-1 % somatic maintenance rate coefficient
  %     4 v     % mm/d % energy conductance
  % 
  % * f: n-vector with scaled functional responses
  %
  % Output
  %
  % * p: (n,4)-matrix with quantities (n > 1). The columns are:
  %
  %     1 f     % -  % scaled functioal response
  %     2 L_b   % mm % length at birth
  %     3 L_i   % mm % ultimate length
  %     4 \dot{r}_B % d^-1   % von Bertalanffy growth rate
  %
  % * U: (n,2)-matrix with U^0 = M_E^0/{J_EAm},
  %    U^b = M_E^b/{J_EAm}
  
  %% Remarks
  % See <get_pars_i.html *get_pars_i*> for inverse mapping
  
  %% Example of use
  % See <../mydata_get_pars.m *mydata_get_pars*>


  f = f(:); ns = length(f);

  % unpack input parameters
  VHb = par(1); % scaled maturity at birth
  g   = par(2); % energy investment ratio
  kM  = par(3); % somatic maintenance rate coefficient
  v   = par(4); % energy conductance

  Lb = (VHb * v/ g)^(1/ 3);
  rB = kM * g ./ (3 * (f + g));    % von Bert growth rate
  Lm = v/ (kM * g); Li = f * Lm; % max, ultimate length

  p = [f, Lb * ones(ns,1), Li, rB];
  
  % prepare second output
  U = zeros(ns,2); % initiate second output
  Lm = v/ (kM * g); u2U = v^2 / g^2/ kM^3;
  for i = 1:ns
    U0 = u2U * get_ue0([g, 1], f(i), Lb/ Lm); % initial scaled reserve
    Ub = f(i) * Lb^3/ v; % scaled reserve at birth
    U(i,:) = [U0, Ub];
  end
