function dXt = dflocdeb (t, Xt)
  %% dXt = dflocdeb (t, Xt)
  %% created at 2002/10/31 by Bas Kooijman, modified 2010/06/29
  %% calculates derivatives of concentrations of substrate and
  %%  living, dead microbial biomass as functions of time in a batch culture
  %%  using the DEB model for flocs
  %% Xt: (5)-vector with substrate, living structure, living reserve,
  %%  dead structure, dead reserve
  
  global par sD;

  %% unpack parameters
  K   = par(1); % saturation constant
  jSm = par(2); % maximum spec consumption rate
  ySE = par(3); % yield of substrate on reserve
  yEV = par(4); % yield of reserve on structure
  kE  = par(5); % reserve turnover rate
  kM  = par(6); % maintenance rate constant
  Ld  = par(7); % radius at division
  LD  = par(8); % diffusion length

  %% unpack state vector
  S = Xt(1); % substrate
  V = Xt(2); % living structure
  E = Xt(3); % living reserve; notice: not reserve density!
  DV = Xt(4); % dead structure
  DE = Xt(5); % dead reserve

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

  %% specific growth rate
  r = (kE*m - kM*yEV)/ (m + yEV); % standard DEB model
  r = r * log(n)/ rtd;            % correction for flocs

  %% obtain changes
  dV = r * V;
  dE = dV * ()/ ();
  dDV = dV * ()/ ();
  dDE = dV * ()/ ();
  dS = - ySE * (yEV* (dV + dD) + dE + dDE) - kM * ySE * yEV * V;

  %% pack dXt
  dXt = [dS, dV, dE, dDV, dDE];
