function f = findr10 (h)
  %% modified 2009/09/29
  %% finds (with fsolve) the max growth rate of species 1 if species 2
  %% grows fastest and produces product 1 that species 2 can use. At
  %% this growth rate, species 1 is hardly present, and the contribution
  %% of product 2 is negligibly small
  
    global S1_r S2_r ... % reactor controls
      k1_E k2_E k1_M k2_M ... % res turnover, maintenance rate coeff
      k1_S k2_S k1_P k2_P ... % dissociation rates
      b1_S b2_S b1_P b2_P ... % association rates
      y1_EV y2_EV y1_ES y2_ES y1_EP y2_EP ... % res, substr, prod costs
      y1_PS y2_PS y1_PP y2_PP y1_PM y2_PM y1_PG y2_PG; % product yields
    
    m2 = y2_EV*(k2_M + h)/(k2_E - h);
    j2_E = k2_E*m2;
    j2_S = j2_E/y2_ES;
    j2_P = y2_PS*j2_S + y2_PM*k2_M + y2_PG*h;
    S2 = 1/(b2_S*(1/j2_S - 1/k2_S));
    P2 = (S2_r - S2)*j2_P/j2_S;
    j1_E = (y1_ES*b1_S*S1_r+y1_EP*P2*b1_P)/(1+S1_r*b1_S/k1_S+P2*b1_P/k1_P);
    m1 = j1_E/ k1_E;
    f = h - (k1_E*m1 - k1_M*y1_EV)/(m1 + y1_EV);