function dXt = dpirt (t, Xt)
  %% dXt = dpirt (t, Xt)
  %% created at 2002/10/28 by Bas Kooijman, modified 2010/06/27
  %% calculates derivatives of concentrations of substrate and
  %%  microbial biomass as functions of time in a batch culture
  %%  using the Marr-Pirt model
  %% Xt: (2)-vector with substrate, structure
  
  global par;

  %% unpack parameters
  K   = par(1); % saturation constant
  jSm = par(2); % maximum spec consumption rate
  ySV = par(3); % yield of substrate on structure
  kM  = par(4); % maintenance rate constant

  %% unpack state vector
  S = Xt(1); % substrate
  V = Xt(2); % biomass

  %% obtain changes
  f = S/(K+S); % scaled functional response
  dS = - f * jSm * V;      %  substrate use
  dV = - dS/ ySV - kM * V; %  growth rate

  %% pack dXt
  dXt = [dS, dV];
