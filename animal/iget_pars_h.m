%% iget_pars_h
% Obtains growth data from 5 compound parameters for multiple feeding levels 

%%
function [p U] = iget_pars_h(par,f)
  %  created  2007/08/12 by Bas Kooijman
  
  %% Syntax
  % [p U] = <../iget_pars_h.m *iget_pars_h*> (par,f)
  
  %% Description
  % Obtains growth data from compound parameters for multiple feeding levels 
  % Maturity and somatic maitenance rate coefficients might differ.
  %
  % Input
  %
  % * par: 6-vector with
  %
  %     1 VHb   % d mm^2 % scaled maturity at birth M_H^b/((1 - kap) {J_EAm})
  %     2 g     % -    % energy investment ratio
  %     3 kJ    % d^-1 % maturity maintenance rate coefficient
  %     4 kM    % d^-1 % somatic maintenance rate coefficient
  %     5 v     % mm/d % energy conductance
  %
  % * f: n-vector with scaled functional responses
  %
  % Output
  %
  % * p: (n,4)-matrix with quantities (n > 1). The columns are:
  %
  %     1 f     % -  % scaled functional response
  %     2 L_b   % mm % length at birth
  %     3 L_i   % mm % ultimate length
  %     4 \dot{r}_B % d^-1   % von Bertalanffy growth rate
  %
  % * U: (n,2)-matrix with U^0 = M_E^0/\{\dot{J}_{EAm}\},
  %     U^b = M_E^b/\{\dot{J}_{EAm}\}

  %% Remarks
  % See <get_pars_h.html *get_pars_h*> for inverse mapping
  
  %% Example of use
  % See <../mydata_get_pars.m *mydata_get_pars*>


  f = f(:); ns = length(f); par = par(:,1);

  % unpack input parameters
  VHb = par(1); % scaled maturity at birth
  g   = par(2); % energy investment ratio
  kJ  = par(3); % maturity maintenance rate coefficient
  kM  = par(4); % somatic maintenance rate coefficient
  v   = par(5); % energy conductance

  [U0 Lb] = initial_scaled_reserve(f, par) ; % length at birth
  Lm = v/ (kM * g); Li = f * Lm; % max, ultimate length
  rB = kM * g ./ (3 * (f + g));    % von Bert growth rate

  % prepare output
  p = [f, Lb, Li, rB];
  U = [U0, f .* Lb.^3/ v];
