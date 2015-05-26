%% initial_scaled_reserve_foetus
% Gets initial scaled reserve in case of foetal develpment.

%%
function [U0, Lb, info] = initial_scaled_reserve_foetus(f, p)
  % created 2010/09/09 by Bas Kooijman
  
  %% Syntax
  % [U0, Lb, info] = initial_scaled_reserve_foetus(f, p)
  
  %% Description
  % Gets initial scaled reserve in case of foetal develpment.
  %
  % Input
  %
  % * f: n-vector with scaled functional response
  % * p: 5-vector with parameters: VHb, g, kJ, kM, v
  %
  % Output
  %
  % * U0: n-vector with initial scaled reserve: M_E^0/ {J_EAm}
  % * Lb: n-vector with length at birth
  % * info: scalar with 1 if successful, 0 otherwise
  
  %% Remarks
  % Like <get_ue0_foetus.html *get_ue0_foetus*>, but allows for vector arguments and
  % input and output is not downscaled to dimensionless quantities,

  
  % unpack parameters
  VHb = p(1); % d mm^2, scaled maturity at birth: M_H^b/((1-kap){J_EAm})
  g   = p(2); % -, energy investment ratio
  kJ  = p(3); % 1/d, maturity maintenance rate coefficient
  kM  = p(4); % 1/d, somatic maintenance rate coefficient
  v   = p(5); % mm/d, energy conductance
  % if kJ = kM: VHb = g * Lb^3/ v;

  nf = length(f); U0 = zeros(nf,1);
  pars = [g; kJ/ kM; VHb * g^2 * kM^3/ v^2];
  [lb tb info] = get_lb_foetus(pars);
  Lb = lb * v/ kM/ g * ones(nf,1);
  for i = 1:nf
    uE0 = get_ue0_foetus(pars, f(i), lb);
    U0(i) = uE0 * v^2/ g^2/ kM^3;
  end
  