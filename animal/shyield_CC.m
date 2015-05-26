%% shyield_CC
%

%%
function shyield_CC(p)
  %  created 2009/01/15 by Bas Kooijman
  
  %% Syntax 
  % <../shyield_CC.m *shyield_CC*> (p)
  
  %% Description
  %  plots yield on carbon-carbon basis as functions of length and scaled func response
  %
  % Input
  %
  %  p: 10-vector with parameters: 
  %   kap, kap_R, g, k_J, k_M, L_T, v, U_Hb, U_Hp, y_VE
  
  %% Example of use
  %  shyield_CC([0.8; 0.95; 0.0207; 0.002; 0.0064; 0; 0.02; 0.275; 50; 0.8])

  % unpack parameters
  kap  = p(1);  % -, fraction allocated to growth + som maint
  kapR = p(2);  % -, fraction of reprod flux that is fixed in embryo reserve 
  g    = p(3);  % -, energy investment ratio
  kJ   = p(4);  % 1/d, maturity maint rate coeff
  kM   = p(5);  % 1/d, somatic maint rate coeff
  LT   = p(6);  % cm, heating length
  v    = p(7);  % cm/d, energy conductance
  Hb   = p(8);  % d cm^2, scaled maturity at birth
  Hp   = p(9);  % d cm^2, scaled maturity at puberty
  yVE =  p(10); % mol/mol, yield of structure on reserve
  
  vHb = Hb * g^2 * kM^3/ ((1 - kap) * v^2);
  vHp = Hp * g^2 * kM^3/ ((1 - kap) * v^2);
  k = kJ/ kM; Lm = v/ g/ kM; lT = LT/ Lm;
  f_min_b = get_eb_min([g; k; vHb]); f_min_b = f_min_b(2);
  f_min_p = get_ep_min([g; k; lT; vHb; vHp]); 
  nf = 10; f = linspace(.001 + max(f_min_p), 1, nf)'; f_min_p = f_min_p(2);
  
  clf
  hold on
  
  for i = 1:nf
    nl = round(2 + 100 * f(i)); 
    l = linspace(1e-3, f(i) - lT - 1e-8, nl)';
    if f(i) > f_min_p
     [lp lb] = get_lp([g;k;lT;vHb;vHp], f(i));
    elseif f(i) > f_min_b
      lp = NaN;
      lb = get_lb([g;k;vHb], f(i));
    else
      lp = NaN;
      lb = NaN;
    end

    pACSJGRD = scaled_power(l, f(i), p, lb, lp);
    F = f(i) * ones(nl,1);
    sel = (sum(pACSJGRD(:,[5 6]) > 0, 2) == 2);
    pC = pACSJGRD(:,2); pD = pACSJGRD(:,7); pG = pACSJGRD(:,5); 
    y = (pD + (1 - yVE) * pG) ./ pC;
    plot3(l(sel), F(sel), y(sel), 'r')
  end
  title('yield of CO2 dissipation on mobilisation')
  xlabel('length')
  ylabel('func resp')
  zlabel('yield_{CC}')
  