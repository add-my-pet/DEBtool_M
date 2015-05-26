function f = fnr_iso(r)
  global F R1 R2 v g kM Lm Li Lp Lb rB ap ha

  a = linspace(0,ap,100)'; da = a(2)-a(1); % age axis till ap
  L = Li - (Li - Lb) * exp(- a * rB); % length, Eq (3.20) {95} 
  V = L .^3; Vb = Lb^3; W = kM * da * cumsum(V);
  hp = ha * da * cumsum(V - Vb + W) ./ V; % hazard rate Eq (4.22) {141}
  Sp = exp( - da * sum(hp)); % survival prob at ap

  a = linspace(ap,200,1000)'; da = a(2)-a(1); % age axis
  L = Li - (Li - Lb) * exp(- a * rB); % length, Eq (3.20) {95} 
  V = L .^3; Vp = Lp^3; W = kM * da * cumsum(V);
  R = R1 * (g * F * (v * L.^2 + kM * V)/ (F + g) - R2); % Eq (3.48) {114}
  hp = ha * da * cumsum(V - Vp + W) ./ V; % hazard rate Eq (4.22) {141}
  S = Sp * exp( - da * cumsum(hp)); % survival prob
  %% [a L R S]
  f = 1 - da * sum(exp(- r * a) .* R .* S); % char eq (9.23) {322}

