%% scaled_power_hex
% Gets scaled powers as function of length in case of model hex

%%
function pACSJGRD = scaled_power_hex(L, f, p, lb, lj, le)
  % created 2016/04/16 by Bas Kooijman
  
  %% Syntax
  % pACSJGRD = <..scaled_power_hex.m *scaled_power_hex*> (L, f, p, lb, lj, le)
  
  %% Description
  % Gets scaled powers assimilation, mobilisation, somatic maintenance, maturity maintenance, growth, reproduction and dissipation as function of length.
  % Length must monitonically increase till pupation (j), and again after pupation.
  % Length at pupation must be present, if lengths of pupa and/or imago are included
  %
  % Input
  %
  % * L: n-vector with lengths
  % * f: scalar with (constant) scaled functional response
  % * p: 10-vector with parameters: kap kapV kapR g kJ kM sj v UHb UHe
  % * lb: scalar with scaled length at birth for f; if not existent: NaN
  % * lj: scalar with scaled length at pupation for f; if not existent: NaN
  % * le: scalar with scaled length at emergence for f; if not existent: NaN  
  %
  % Output
  %
  % * pACSJGRD: (n,7)-matrix with scaled powers p_A, p_C, p_S, p_J, p_G, p_R, p_D / L_m^2 {p_Am}
  
  %% Remarks
  % Similar to <scaled_power.html *scaled_power*> 
  % The maturity value relates to the one for which f has been constant.
  % Powers can become negative for shrinking of structure or maturity.
  % See function <scaled_power.html *scaled_power*> for model std.
  
  %% Example of use
  % See <../statistics_st.m *statistics_st*>

  % unpack parameters
  kap  = p(1);  % -, fraction allocated to growth + som maint
  kapV = p(2);  % -, conversion efficiency from larval reserve to larval structure, back to imago reserve
  kapR = p(3);  % -, reproduction efficiency from reserve to eggs
  g    = p(4);  % -, energy investment ratio
  kJ   = p(5);  % 1/d, maturity maint rate coeff
  kM   = p(6);  % 1/d, somatic maint rate coeff
  sj   = p(7);  % -, [E_R] as fraction of max at pupation
  v    = p(8);  % cm/d, energy conductance
  U_Hb = p(9);  % d cm^2, scaled maturity at birth
  U_He = p(10); % d cm^2, scaled maturity at emergence

  Lm = v/ kM/ g; k = kJ/ kM;
  L = L(:); l = L/ Lm; lp = lb;

  if isnan(lb) && isnan(lp) % adult stage cannot be reached
    assim = 0 * l;
    kapR = 0 * l;
    sM = 1 + 0 * l;
  else % adult stage can be reached
    assim = (l > lb);
    kapR = kapR * (l > lp);
    sM = min(lj, max(lb, l))/ lb;    % -, stress fractor for acceleration
  end

  H = maturity_hex(L, f, p, lb, lj, le);  % scaled maturities E_H/ {p_Am}
  uH = H *  g^2 * kM^3/ v^2;

  % scaled powers: powers per max assimilation {p_Am} L_m^2
  pA = assim * f .* sM .* l.^2;              % assim
  pC = l.^2 .* (g .* sM + l )/ (1 + g/ f);   % mobilisation
  pS = kap * l.^3;                           % somatic  maint
  pJ = k * uH;                               % maturity maint
  pG = kap * pC - pS;                        % growth
  pR = (1 - kap) * pC - pJ;                  % maturation/reproduction
  pD = pS + pJ + (1 - kapR) .* pR ;          % dissipation

  pACSJGRD = [pA, pC, pS, pJ, pG , pR, pD];