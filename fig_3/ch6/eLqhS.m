function [L S Lf Sf] = eLqhS(p, aL, aS, aLf, aSf)
  %% LT = 0; 
  global kM v g ha sG f0
  
  %% unpack parameters
  Lb = p(1); g = p(2); kM = p(3);
  v = p(4); ha = 1E-6 * p(5); sG = p(6);

  f0 = 1;
  eLqhS0 = [1; Lb; 0; 0; 1];
  [e eLqhSt] = ode23('deLqhS', [-1e-6; aL(:,1)], eLqhS0);
  L = eLqhSt(:,2); L(1) = [];
  [a eLqhSt] = ode23('deLqhS', [-1e-6; aS(:,1)], eLqhS0);
  S = eLqhSt(:,5); S(1) = [];

  f0 = p(7);
  [a eLqhSt] = ode23('deLqhS', [-1e-6; aLf(:,1)], eLqhS0);
  Lf = eLqhSt(:,2); Lf(1) = [];
  [a eLqhSt] = ode23('deLqhS', [-1e-6; aSf(:,1)], eLqhS0);
  Sf = eLqhSt(:,5); Sf(1) = [];
