function Nt = grrep(p, t, c)
  %  created 2002/01/20 by Bas Kooijman, modified 2009/01/15
  %
  %% Description
  %  growth effects on reproduction of ectotherm: target is y_VE
  %   yield of structure on reserve linear in internal concentration
  %   capacity of repoduction buffer equal to zero
  %   first order toxico kinetics with dilution by growth
  %     elimination not via reproduction
  %   abundant food, internal conc, maturity, reserve are hidden variables
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

  global C nc c0 cG ke kap kapR g kJ kM v Hb Hp Lb0

  C = c; nc = size(C,1); % copy concentrations into dummy
  
  %% unpack parameters for easy reference
  c0 = p(1);  % mM, No-Effect-Concentration (external, may be zero)
  cG = p(2);  % mM, tolerance concentration
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

  H0 = maturity(L0, 1, [p(4:8), 0, p(9:11)]); % initial scaled maturity
  U0 = L0^3/ v; % initial reserve at max value
  %% initialize state vector; catenate to avoid loops
  X0 = [zeros(nc,1); ...    % N: cumulative number of offspring
        H0 * ones(nc,1); ...% H: scaled maturity H = M_H/ {J_EAm}
        L0 * ones(nc,1); ...% L: length
        U0 * ones(nc,1); ...% U: scaled reserve U = M_E/ {J_EAm}
        zeros(nc,1)];       % c: scaled internal concentration

  Lb = (Hb * v/ (g * (1 - kap))) ^ (1/ 3);
  Lb0 = Lb * ones(nc,1);

  nt = size(t,1);
  %% Make sure that initial state vector corresponds to t = 0
  if t(1) == 0
    [t, Xt] = ode23('dgrrep', t, X0); % integrate changes in state
    Nt = Xt(:,1:nc);
  elseif nt > 1
    t = [0;t]; 
    [t, Xt] = ode23('dgrrep', t, X0); % integrate changes in state
    Nt = Xt(2:nt+1,1:nc);
  else
    t = [0;t]; 
    [t, Xt] = ode23('dgrrep', t, X0); % integrate changes in state
    Nt = Xt(end,1:nc);
  end
