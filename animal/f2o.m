%% f2o
% From scaled functional response trajectories to otolith opacity profiles

%%
function [LOO, teLLOO] = f2o (tcf, eb, LOb, par)
  %  created by Bas Kooijman, 2007/08/29
  
  %% Syntax
  % [LOO, teLLOO] = <../f2o.m *f2o*> (tcf, eb, LOb, par)
  
  %% Description
  % From scaled functional response f to otolith opacity O profiles.
  % The routine <o2f.html *o2f*> reconstructs 
  %    time-trajectories of scaled function response, scaled reserve density, body length, otolith length, opacity 
  %    from otolith length-opacity data, 
  %    given DEB parameters and temperature correction factors over time. 
  %  The reconstructed body length at otolith collection can be compared to the observed body length 
  %    as an independent check on the reliability of the reconstruction. 
  %  The assumption kJ = kM is made to ensure stage transitions at fixed length. 
  %  Opacity is zero for contribution of dissipation and one of growth. Opacity, therefore, is always on the interval (0,1). 
  %  Measured opacity might need some rescaling to fit these requirements. 
  %  Otolith and body length are treated as volumetric length; measured lengths might need rescaling. 
  %  The theory behind o2f and f2o is discussed in PecqKooy2008
  %
  % Input
  %
  % * tcf: (n,3)-matrix with time t, tmep cor factor c_T, func resp f
  % * eb: scalar with e at t=0
  % * LOb: scalar with otolith length LO at t=0 (birth)
  % * par: 10-vector with parameters
  %    Lb, Lp, v, vOD, vOG, kM, g, kap, kapR, delS
  %
  % Output
  %
  % * LOO: (n,2)-matrix with L_O, O
  % * teLLOO: (n,5)-matrix with time, e, L, LO, O
  
  %% Remarks
  % Routine *f2o* is reverse to <o2f.html *o2f*> and can be used for checking. 

  %% Example of use
  % See <.../mydata_of.m *mydata_of*>

  global tc tf

  tc = tcf(:,[1 2]); tf = tcf(:,[1 3]);

  %% code
  % unpack par
  Lb = par(1);    % cm, length at birth
  Lp = par(2);    % cm, length at puberty
  v = par(3);     % cm/d, energy conductance
  vOD = par(4);   % mum/d, otolith growth linked to dissipation
  vOG = par(5);   % mum/d, otolith growth linked to body growth
  kM = par(6);    % 1/d, maintenance rate coefficient 
  g = par(7);     % -, energy investment ratio
  kap = par(8);   % -, fraction to som maint + growth
  kapR = par(9) ; % -, reproduction efficiency
  delS = par(10); % -, shape coefficient for otosac

  Lm = v/ kM/ g;

  [t, eLLO] = ode23s(@df2o_ello,tcf(:,1), [eb, Lb, LOb], [], ...
     v,g,Lb,Lp,Lm,kap,kapR,vOD,vOG,delS);

  teLLOO = [t, eLLO(:,[1 2 3])];
  E = eLLO(:,1); L = eLLO(:,2); LO = eLLO(:,3); cor_T = tcf(:,2); f = tcf(:,3);
  E_0 = E(end); L_0 = L(end); LO_0 = LO(end); f_0 = f(end); 
  c_0 = tc(end,2); vT_0 = c_0 * v;
  dE_0 = vT_0 * ((L_0 > Lb) * f_0 - E_0) / L_0; % 1/d, change in scaled res density e = m_E/ m_Em
 
  SC = cor_T .* L .^ 2 .* (g + L/ Lm) .* E ./ (g + E); % p_C/ {p_Am}
  SM = cor_T * kap .* L .^ 3/ Lm; % p_M/ {p_Am}
  SG = max(0,kap * SC - SM); % p_G/ {p_Am}
  SD = (SM + (1 - (L > Lp) * kapR) * (1 - kap) .* SG)/ kap; % p_D/ {p_Am}
  
  svS = vOD * SD + vOG * SG;
  vSG = vOG * SG;
  O = vSG ./ svS; % opacity
  teLLOO = [t, eLLO, O];

  LOO = [LO, O];
  