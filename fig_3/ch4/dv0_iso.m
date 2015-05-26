function dVe = dv0_iso(t, Ve)

global v kM g LT rho

V = Ve(1); ee = Ve(2); L = max(1e-3,V)^(1/ 3);
Lm = v/ g/ kM; Li = Lm - LT;

de = ( rho * Li^2/ L^2 - ee) * v/ L;
r = (v * ee/ L - (1 + LT/ L) * kM * g)/ (ee + g);
dV = r * V;

dVe = [dV; de];