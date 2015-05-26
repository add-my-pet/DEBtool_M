function f = findr20 (h)
  %% finds (with fsolve) the max growth rate of species 2 if species 1
  %% grows fastest and produces product 2 that species 1 can use. At
  %% this growth rate, species 2 is hardly present, and the contribution
  %% of product 1 is negligibly small

    global S1_r S2_r ... % reactor controls
      k1_E k2_E k1_M k2_M ... % res turnover, maintenance rate coeff
      k1_S k2_S k1_P k2_P ... % dissociation rates
      b1_S b2_S b1_P b2_P ... % association rates
      y1_EV y2_EV y1_ES y2_ES y1_EP y2_EP ... % res, substr, prod costs
      y1_PS y2_PS y1_PP y2_PP y1_PM y2_PM y1_PG y2_PG; % product yields

    m1 = y1_EV*(k1_M + h)/(k1_E - h);
    j1_E = k1_E*m1;
    j1_S = j1_E/y1_ES;
    j1_P = y1_PS*j1_S + y1_PM*k1_M + y1_PG*h;
    S1 = 1/(b1_S*(1/j1_S - 1/k1_S));
    P1 = (S1_r - S1)*j1_P/j1_S;
    j2_E = (y2_ES*b2_S*S2_r+y2_EP*P1*b2_P)/(1+S2_r*b2_S/k2_S+P1*b2_P/k2_P);
    m2 = j2_E/k2_E;
    f = h - (k2_E*m2 - k2_M*y2_EV)/(m2 + y2_EV);