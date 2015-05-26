function [L Tb] = gen_logist(p, aL, aT)
  %% unpack parameters
  Lb = p(1); Lm = p(2); rB = p(3); d = p(4); Ti = p(5); TA = p(6);

  lb = Lb/ Lm;
  L = Lm * (1 - (1 - lb^d) * exp( - rB * aL(:,1))).^ (1/d);
  if exist('aT','var') == 1
    l = (1 - (1 - lb^d) * exp( - rB * aT(:,1))).^ (1/d);
    Tb = 1 ./(1/ Ti - log((1 - 1 ./ l .^d) ./ (d - d ./ l))/TA);
    Tb = Tb - 273;
  end
