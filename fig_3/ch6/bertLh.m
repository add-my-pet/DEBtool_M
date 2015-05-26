function h = bertLh(p, ah)
  global Lb Lm rB kM
  %% unpack parameters
  Lb = p(1)^(1/3); Lm = p(2)^(1/3); rB = p(3); kM = p(4); ha = p(5);


  a  = ah(:,1); V  = (Lm - (Lm - Lb) * exp(- rB * a)).^3;
  [a Vh] = ode23('dbertLh', [-1e-6; a], [0 0 0]'); Vh = Vh(:,1); Vh(1) = [];
  h = (ha ./ V) .* Vh;
