function Lt = ma0growth(p, t, c)
  %  created 2002/02/18 by Bas Kooijman, modified 2008/12/29
  %
  %% Descriprion
  %  maintenance effects on growth of ectotherm: target is [J_EM]
  %   slow first order toxico kinetics with dilution by growth
  %   spec maint costs linear in internal concentration
  %
  %% Input
  %  p: 7-vector with parameters values (see below)
  %  t: (nt,1) matrix with exposure times
  %  c: (nc,1) matrix with concentrations of toxic compound
  %
  %% Output
  %  Lt: (nt,nc) matrix with body lengths
  %
  %% Example of use
  %  see mydata_growth

  global C nc c0t cMt g kM v

  C = c; nc= size(C,1); % copy concentrations into dummy
  
  %% unpack parameters for easy reference
  c0t = p(1); % mM.d, No-Effect-Concentration-time (external, may be zero)
  cAt = p(2); % mM.d, tolerance concentration-time
  ke = p(3);  % 1/d, elimination rate at L = Lm
  g  = p(4);  % -, energy investment ratio
  kM = p(5);  % 1/d, somatic maint rate coeff
  v  = p(6);  % cm/d, energy conductance
  L0 = p(7);  % cm, initial body length
  %% parameter ke at position 3 is not used, but still present in input
  %%   for compatibility reasons with asgrowth
    
  U0 = L0^3/ v; % initial reserve at max value
  %% initialize state vector; catenate to avoid loops
  X0 = [L0 * ones(nc,1); %  L: initial length, 
        U0 * ones(nc,1); %  U: scaled reserve U = M_E/ {J_EAm}
        zeros(nc,1)];    %  ct: scaled internal concentration-time

  nt = size(t,1);
  %% Make sure that initial state vector corresponds to t = 0
  if t(1) == 0
    [t, Xt] = ode23('dma0growth', t, X0); % integrate changes in state
    Lt = Xt(:,1:nc); % select lengths only
  elseif nt > 1
    t = [0;t];
    [t, Xt] = ode23('dma0growth', t, X0); % integrate changes in state
    Lt = Xt(2:nt+1,1:nc); % select lengths only; remove prepended zero
  else
    t = [0;t];
    [t, Xt] = ode23('dma0growth', t, X0); % integrate changes in state
    Lt = Xt(end,1:nc); % select lengths only; remove prepended zero
  end
