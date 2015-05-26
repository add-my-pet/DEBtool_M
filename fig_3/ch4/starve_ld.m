function [w1, w2, w3, w4]  = starve_ld(p, tw1, tw2, tw3, tw4)
  l1 = p(1); l2 = p(2); l3 = p(3); l4 = p(4); % scaled struc length
  dV = p(5); % V_m d_Vd
  dE = p(6); % V_m w_Ed [M_Em] e(0)
  k = p(7);  % g k_M
  w1 = l1^3 * (dV + dE * exp(- tw1(:,1) * k/ l1));
  w2 = l2^3 * (dV + dE * exp(- tw2(:,1) * k/ l2));
  w3 = l3^3 * (dV + dE * exp(- tw3(:,1) * k/ l3));
  w4 = l4^3 * (dV + dE * exp(- tw4(:,1) * k/ l4));