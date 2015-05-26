function Lt = grigrowth(p, t, c)
  %  created 2002/02/18 by Bas Kooijman; modified 2006/09/07, 2007/07/12
  %
  %% Description
  %  assimilation effects on growth of ectotherm: target is y_VE
  %   fast first order toxico kinetics
  %     elimination not via reproduction
  %   yield of structure on reserve linear in internal concentration
  %   abundant food, internal conc and reserve are hidden variables
  %
  %% Input
  %  p: 7-vector with parameters values (see below)
  %  t: (nt,1) matrix with exposure times
  %  c: (nc,1) matrix with concentrations of toxic compound
  %
  %% Output
  %  Lt: (nt,nc) matrix with lengths
  %
  %% Example of use
  %  see mydata_growth

  %% Code
  global C nc c0 cG ke g kM v

  C = c; nc = size(C,1); % copy concentrations into dummy
  
  %% unpack parameters for easy reference
  c0 = p(1);  % mM, No-Effect-Concentration (external, may be zero)
  cG = p(2);  % mM, tolerance concentration
  ke = p(3);  % 1/d, elimination rate at L = Lm
  g  = p(4);  % -, energy investment ratio
  kM = p(5);  % 1/d, somatic maint rate coeff
  v  = p(6);  % cm/d, energy conductance
  L0 = p(7);  % cm, initial body length
  %% elimination rate ke at p(3) is not used
  %% it is still present for consistency with grgrowth
   
  U0 = L0^3/ v; % initial reserve at max value
  %% initialize state vector; catenate to avoid loops
  X0 = [L0 * ones(nc,1); %  L: initial length, 
        U0 * ones(nc,1)]; %  U: scaled reserve U = M_E/ {J_EAm}

  %% Make sure that initial state vector corresponds to t = 0
  if t(1) == 0
    [t, Xt] = ode23('dgrigrowth', t, X0); % integrate changes in state
    Lt = Xt(:,1:nc); % select lengths only
  else
    t = [0;t]; nt = size(t,1);
    [t, Xt] = ode23('dgrigrowth', t, X0); % integrate changes in state
    Lt = Xt(2:nt,1:nc); % select lengths only; remove prepended zero
  end
