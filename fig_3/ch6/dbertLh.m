function df = dbertLh(t, x)
  global Lb Lm rB kM
  intV = x(2); a = x(3);
  V = (Lm - (Lm - Lb) * exp(- rB * a))^3; % plain volume V = L^3
  %% proportionality constant cancels 
  Vh = V - Lb^3 + kM * intV; % Eq (4.22) {141} under integration
  df = [Vh V 1]'; 
