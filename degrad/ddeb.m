function dXt = ddeb (t, Xt)
  %% dXt = ddeb (t, Xt)
  %% created at 2002/10/28 by Bas Kooijman, modified 2010/06/27
  %% calculates derivatives of concentrations of substrate and
  %%  microbial biomass as functions of time in a batch culture
  %%  using the DEB model
  %% Xt: (3)-vector with substrate, structure, scaled reserve density
  
  global par;

  %% unpack parameters
  K   = par(1); % saturation constant
  jSm = par(2); % maximum spec consumption rate
  ySV = par(3); % yield of substrate on structure
  kE  = par(4); % reserve turnover rate
  kM  = par(5); % maintenance rate constant

  %% unpack state vector
  S = Xt(1); % substrate
  V = Xt(2); % structure
  M = Xt(3); % reserve density = m/yEV in DEB book

  %% obtain changes
  f = S/ (K + S); % scaled functional response
  dS = - f * jSm * V;
  dM = f * jSm/ ySV - kE * M;
  r = (kE * M - kM)/ (M + 1); % specific growth rate
  dV = r * V;

  %% pack dXt
  dXt = [dS, dV, dM];
