%% asgrowth
% assimilation effects on growth of ectotherm

%%
function Lt = asgrowth(p, t, c)
  %  created 2002/02/15 by Bas Kooijman; modified 2006/09/07, 2007/07/10
  
  %% Syntax
  % Lt = <../asgrowth.m *asgrowth*>(p, t, c)
  
  %% Description
  % assimilation effects on growth of ectotherm: target is {J_EAm}
  % first order toxico kinetics with dilution by growth
  % elimination not via reproduction
  % max assim rate linear in internal concentration
  % abundant food, reserve and internal conc are hidden variables
  %
  % Input
  %
  % * p: 7-vector with parameters values (see below)
  % * t: (nt,1) matrix with exposure times
  % * c: (nc,1) matrix with concentrations of toxic compound
  %
  % Output
  %
  % * Lt: (nt,nc) matrix with body lengths
  
  %% Example of use
  % <../mydata_growth *mydata_growth*>

  global C nc c0 cA ke g kM v

  C = c; nc = size(C,1); % copy concentrations into dummy
  
  % unpack parameters for easy reference
  c0 = p(1);  % mM, No-Effect-Concentration (external, may be zero)
  cA = p(2);  % mM, tolerance concentration
  ke = p(3);  % 1/d, elimination rate at L = Lm
  g  = p(4);  % -, energy investment ratio
  kM = p(5);  % 1/d, somatic maint rate coeff
  v  = p(6);  % cm/d, energy conductance
  L0 = p(7);  % cm, initial body length
   
  U0 = L0^3/ v; % initial reserve at max value
  
  % initialize state vector; catenate to avoid loops
  X0 = [L0 * ones(nc,1); %  L: initial length, 
        U0 * ones(nc,1); %  U: scaled reserve U = M_E/ {J_EAm}
       zeros(nc,1)];    %  c: scaled internal concentration

  nt = length(t);  
  
  % Make sure that initial state vector corresponds to t = 0
    [tt, Lt] = ode23('dasgrowth', [-1e-6; t(:)], X0); % integrate changes in state
    Lt(1,:) = []; Lt = Lt(:,1:nc);
    if nt == 1
      Lt = Lt(end,:);
    end

