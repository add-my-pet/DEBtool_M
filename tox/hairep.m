function Nt = hairep(p, t, c)
  %  created 2002/02/18 by Bas Kooijman, modified 2009/01/15
  %
  %% Description
  %  hazard effects on reproduction of ectotherm: target is hazard of offspring
  %   hazard of offspring linear in internal concentration
  %   capacity of repoduction buffer equal to zero
  %   fast first order toxico kinetics
  %
  %% Input
  %  p: 12-vector with parameters values (see below)
  %  t: (nt,1) matrix with exposure times
  %  c: (nc,1) matrix with concentrations of toxic compound
  %
  %% Output
  %  Nt: (nt,nc) matrix with cumulative number of offspring
  %
  %% Example of use
  %  see mydata_rep

  global C nc c0 cH kap kapR g kJ kM v Hb Hp U0

  C = c; nc = size(C,1); % copy concentrations into dummy
  
  %% unpack parameters for easy reference
  c0 = p(1);  % mM, No-Effect-Concentration (external, may be zero)
  cH = p(2);  % mM, tolerance concentration
  ke = p(3);  % 1/d, elimination rate at L = Lm
  kap = p(4); % -, fraction allocated to growth + som maint
  kapR = p(5);% -, fraction of reprod flux that is fixed into embryo reserve 
  g  = p(6);  % -, energy investment ratio
  kJ = p(7);  % 1/d, maturity maint rate coeff
  kM = p(8);  % 1/d, somatic maint rate coeff
  v  = p(9);  % cm/d, energy conductance
  Hb = p(10); % d cm^2, scaled maturity at birth
  Hp = p(11); % d cm^2, scaled maturity at puberty
  L0 = p(12); % cm, initial body length
  %% elimination rate ke at p(3) is not used
  %% it is still present for consistency with grrep

  H0 = maturity(L0, 1,[p(4:8), 0, p(9:11)]); % initial scaled maturity
  U0 = L0^3/ v; % initial reserve at max value
  %% initialize state vector; catenate to avoid loops
  X0 = [zeros(nc,1);     % N: cumulative number of offspring
        H0 * ones(nc,1); % H: scaled maturity H = M_H/ {J_EAm}
        L0 * ones(nc,1); % L: length
        U0 * ones(nc,1)]; % U: scaled reserve U = M_E/ {J_EAm}

  p_U0 = [Hb/ (1 - kap); g; kJ; kM; v];
  U0 = initial_scaled_reserve(1,p_U0);

  %% Make sure that initial state vector corresponds to t = 0
  if t(1) == 0
    [t, Xt] = ode23('dhairep', t, X0); % integrate changes in state
    Nt = Xt(:,1:nc); % select lengths only
  else
    t = [0;t]; nt = size(t,1);
    [t, Xt] = ode23('dhairep', t, X0); % integrate changes in state
    Nt = Xt(2:nt,1:nc); % select lengths only; remove prepended zero
  end
