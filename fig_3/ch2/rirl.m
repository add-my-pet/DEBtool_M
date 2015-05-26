function [respi, ing, crep, L, L1, L2, L3, L4, L5, Lbp, ab v_cal] ...
      = rirl (p, Lrespi, Ling, acrep, aL, aL1, aL2, aL3, aL4, aL5, fL, a_obs, v_obs)
  
  global f v g kM Lb Lp Linf rB C D

  del = p(1); % shape coefficient
  %% v, UHb, UHv in volumetric length
  kap = p(2); kapR = p(3); g = p(4); kJ = p(5); kM = p(6); v = p(7);
  UHb = p(8); UHp = p(9); A = p(10); B = p(11);
  f = p(12); f1 = p(13); f2 = p(14); f3 = p(15); f4 = p(16); f5 = p(17);

  LT = 0; % heating length
  
  %% respiration (L)
  respi = A * (v * (del * Lrespi(:,1)) .^ 2 + ...
	       kM * (del * Lrespi(:,1)) .^ 3);

  %% ingestion (L)
  ing = B * (del * Ling(:,1)) .^ 2;

  %% cumulative reproduction (a)
  p_crep = [kap; kapR; g; kJ; kM; LT; v; UHb; UHp]; % pars for cum_reprod
  [crep, UE0, Lb, Lp, ab, ap] = cum_reprod(acrep(:,1), f, p_crep, del * .8);

  %% max and ultimate volumetric length
  Lm = v/ (g * kM);
  Li  = f  * Lm - LT; Li1 = f1 * Lm - LT;
  Li2 = f2 * Lm - LT; Li3 = f3 * Lm - LT;
  Li4 = f4 * Lm - LT; Li5 = f5 * Lm - LT;
  
  %% inverse van Bert growth rate linear in the ultimate length
  rB  = kM/ (1 + f/ g)/ 3;  rB1 = kM/ (1 + f1/ g)/ 3;
  rB2 = kM/ (1 + f2/ g)/ 3; rB3 = kM/ (1 + f3/ g)/ 3;
  rB4 = kM/ (1 + f4/ g)/ 3; rB5 = kM/ (1 + f5/ g)/ 3;

  %% physical length (a): a = time since birth
  L  = Li  - (Li -  Lb) * exp( - rB * aL(:,1));  L = L/del; 
  L1 = Li1 - (Li1 - Lb) * exp(- rB1 * aL1(:,1)); L1 = L1/del; 
  L2 = Li2 - (Li2 - Lb) * exp(- rB2 * aL2(:,1)); L2 = L2/del; 
  L3 = Li3 - (Li3 - Lb) * exp(- rB3 * aL3(:,1)); L3 = L3/del; 
  L4 = Li4 - (Li4 - Lb) * exp(- rB4 * aL4(:,1)); L4 = L4/del; 
  L5 = Li5 - (Li5 - Lb) * exp(- rB5 * aL5(:,1)); L5 = L5/del;

  %% length at birth and puberty
  VHb = UHb/ (1 - kap); VHp = UHp/ (1 - kap);
  vHb = VHb * g^2 * kM^3/ v^2; vHp = VHp * g^2 * kM^3/ v^2; 
  p_lp = [g; kJ/kM; LT/Lm; vHb; vHp];
  [lp1 lb1] = get_lp(p_lp, 1, Lb/Lm); % Lb and Lm in volumetric length

  [lp5 lb5] = get_lp(p_lp, .5, Lb/Lm);

  Lbp = [lb1; lb5; lp1; lp5] * Lm/ del; % output in physical length

  %% don't deviate too much from the observed mean value for v
  v_cal = v; % in volumetric length