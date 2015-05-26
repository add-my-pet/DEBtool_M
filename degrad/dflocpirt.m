function dXt = dflocpirt (t, Xt)
  %% dXt = dflocpirt (t, Xt)
  %% created at 2002/10/30 by Bas Kooijman, modified 2010/06/27
  %% calculates derivatives of concentrations of substrate and
  %%  living, dead microbial biomass as functions of time in a batch culture
  %%  using the Marr-Pirt model for flocs
  %% Xt: (3)-vector with substrate, living, dead structure
  
  global par sD;

  %% unpack parameters
  K   = par(1); % saturation constant
  jSm = par(2); % maximum spec consumption rate
  ySV = par(3); % yield of substrate on structure
  kM  = par(4); % maintenance rate constant
  Ld  = par(5); % radius at division
  LD  = par(6); % diffusion length

  %% unpack state vector
  S = Xt(1); % substrate
  V = Xt(2); % living structure
  D = Xt(3); % dead structure

  f = S/(K+S);  % scaled functional response
  jS = jSm * f; % spec substrate uptake rate
  fD = kM * ySV/ jSm; % scaled functional response for which r=0
  sD = fD/(1-fD); % scaled substrate concentration for which r=0
  lM = quad('fnlm', sD, S/K)/ sqrt(2); % scaled max thickness of living layer
  

  ld = Ld/ (LD * lM); % scaled radius at division
  N = 1 - 3 * ld + 3 * ld^2;

  %% n is number of daughters per mother floc
  if lM > ld
    n = 8;
  else
    n = 8 * N;
  end

  %% r times division interval td
  if ld < 1
    rtd = 3 * log(2);
  else
    rtd = 3 * log(2) - 1 + ld - pi/ (3 * sqrt(3)) + ...
	atan(sqrt(3) * (2 * ld - 1))/ sqrt(3) + ...
	0.5 * log(N);
  end

  r = (jS/ ySV - kM) * log(n)/ rtd; % specific growth rate

  %% obtain changes
  dV = r * V;
  dD = dV/ ((ld^3 - 0.5^3)/ (ld - 1)^3 - 1);
  dS = - ySV * (dV + dD) - kM * ySV * V;

  %% pack dXt
  dXt = [dS, dV, dD];