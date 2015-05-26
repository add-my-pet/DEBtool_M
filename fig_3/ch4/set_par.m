function [p lb] = set_par

  kap = 0.8;
  g  = 0.69;
  kJ = 1.70;   % 1/d
  kM = 1.70;   % 1/d
  v  = 3.24;   % mm/d
  Hb = 0.0046; % d.mm^2
  Hp = 0.042;  % d.mm^2
  tR = 4.8;    % d
  v0 = .055;   % mm/d
  
  p = [kap 0; g 0; kJ 0; kM 0; v 0; Hb 0; Hp 0; tR 0; v0 0];
		  
  %% check "easy-to-measure" statistics with
  kapR = 0.95; [ip U] = iget_pars_r([kap; kapR; g; kJ; kM; v; Hb; Hp], 1);
  Lb = ip(2); Lm = v/ (g * kM); lb = Lb/ Lm;

