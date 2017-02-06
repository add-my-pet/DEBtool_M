function Lt = magrowth(p, t, c)
  %  created 2002/01/21 by Bas Kooijman, modified 2008/12/29
  %
  %% Description
  %  maintenance effects on growth of ectotherm: target is [J_EM]
  %   first order toxico kinetics with dilution by growth
  %     elimination not via reproduction
  %   spec maint costs linear in internal concentration
  %   abundant food, internal conc and reserve are hidden variables
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

  % Code
  
  global C nc c0 cM ke g kM v

  C = c; nc = size(C,1); % copy concentrations into dummy
  
  %% unpack parameters for easy reference
  c0 = p(1);  % mM, No-Effect-Concentration (external, may be zero)
  cM = p(2);  % mM, tolerance concentration
  ke = p(3);  % 1/d, elimination rate at L = Lm
  g  = p(4);  % -, energy investment ratio
  kM = p(5);  % 1/d, somatic maint rate coeff
  v  = p(6);  % cm/d, energy conductance
  L0 = p(7);  % cm, initial body length
   
  U0 = L0^3/ v; % initial reserve at max value
  %% initialize state vector; catenate to avoid loops
  X0 = [L0 * ones(nc,1); %  L: initial length, 
        U0 * ones(nc,1); %  U: scaled reserve U = M_E/ {J_EAm}
        zeros(nc,1)];    %  c: scaled internal concentration

  nt = size(t,1);
  %% Make sure that initial state vector corresponds to t = 0
  if t(1) == 0
    [t, Xt] = ode23('dmagrowth', t, X0); % integrate changes in state
    Lt = Xt(:,1:nc); % select lengths only
  elseif nt > 1
    t = [0;t]; 
    [t, Xt] = ode23('dmagrowth', t, X0); % integrate changes in state
    Lt = Xt(2:nt+1,1:nc); % select lengths only; remove prepended zero
  else
    t = [0;t]; 
    [t, Xt] = ode23('dmagrowth', t, X0); % integrate changes in state
    Lt = Xt(end,1:nc); % select lengths only; remove prepended zero
  end
