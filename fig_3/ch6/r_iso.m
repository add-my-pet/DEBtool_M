function r = r_iso(p, f)
  %% r = r_iso(p, f)
  %% spec pop growth rate for reproducing isomorphs, cf r_v1
  %% f: n-vector with scaled func reponses
  %% p: parameter vector (see below)
  %% r: n-vector with spec growth rates
  
  global F R1 R2 v g kM Lm Li Lp Lb rB ap ha
  
  %% unpack parameters
  pAm = p(1); pM = p(2); Em = p(3); EG = p(4); kap = p(5); ha = p(6);
  kapR = p(7); Lb = p(8); Lp = p(9); % extra relative to r_v1

  %% compound parameters
  g = EG/ (kap * Em); % investment ratio
  v = pAm/ Em; % energy conductance
  kM = pM/ EG; % maint rate coefficient
  Lm = kap * pAm/ pM; % max, birth, puber length
  R2 = g * kM * Lp^3; % reprod coefficients

  nf = length(f); r = zeros(nf,1); r0 = .1;
  for i = 1:nf % scan func responses
    F = f(i); Li = F * Lm; % func resp, ultimate length
    lb = Lb/ Lm; lp = Lp/ Lm;
    if F <  lp % not enough food to reach adult state
      r(i) = 0;
      break
    end
    e0 = 1/ (1/ (lb * (g + F)^(1/3)) - ...
    	     beta_43_0(g/ (F + g))/ (3 * g^(4/ 3)))^3; % Eq (3.31) {107}
    R1 = kapR * (1 - kap)/ (e0 * Lm^3); 
    rB = 1/ (3/ kM + 3 * Li/ v); % von Bert growth, Eq (3.22) {95}
    ap = log((Li - Lb)/(Li - Lp))/ rB; % age at puberty
    [r(i), vql, err] = fzero('fnr_iso', r0); % spec growth rate
    r0 = r(i); % continuation
    if r(i) < 1e-6 | err ~= 1
      r(i) = 0;
      break
    end
  end