%% iget_pars_g
% Obtains growth data from compound parameters at one feeding level

%%
function [p, U0b] = iget_pars_g(par, F)
  %  created 2006/10/01 by Bas Kooijman, modified 2009/09/29
  
  %% Syntax
  % [p, U0b] = <../iget_pars_g.m *iget_pars_g*> (par, F)
  
  %% Description
  % Obtains growth data from 4 compound parameters at one feeding level.
  % Maturity and somatic maitenance rate coefficients are equal.
  %
  % Input
  %
  % * par: 4-vector with
  %
  %    1 VHb   % scaled maturity at birth
  %    2 g     % energy investment ratio
  %    3 kM    % somatic maintenance rate coefficient
  %    4 v     % energy conductance
  %
  % * F: scalar with scaled functional response (optional)
  %
  % Output
  %
  % * p: 5-vector with: f, L_b, L_i, a_b, \dot{r}_B
  % * U0b: (2,n)-matrix with:
  %    U^0 = M_E^0/\{\dot{J}_{EAm}\}, U^b = M_E^b/\{\dot{J}_{EAm}\}
  
  %% Remarks
  % See <get_pars_g.html *get_pars_g*> for inverse mapping
  
  %% Example of use
  % See <../mydata_get_pars.m *mydata_get_pars*>


  if exist('F','var') == 0
    f = 1; % abundant food
  else
    f = F; % to make scaled functional response global
  end
 
  % unpack input parameters
  VHb = par(1); % scaled maturity at birth
  g   = par(2); % energy investment ratio
  kM  = par(3); % somatic maintenance rate coefficient
  v   = par(4); % energy conductance

  Lb = (VHb * v/ g)^(1/3);       % length at birth
  rB = kM * g/ (3 * (f + g));    % von Bert growth rate
  Lm = v/ (kM * g); Li = f * Lm; % max, ultimate length
  lb = Lb/ Lm;
  U0 = get_ue0([g, 1], f, lb) * v^2/ g^2/ kM^3;
  % initial scaled reserve M_E^0/{J_EAm}

  ab = get_tb([g 1], f, lb)/ kM;
  Ub = f * Lb^3/ v;
   
  U0b = [U0; Ub];
  p = [f; Lb; Li; ab; rB];