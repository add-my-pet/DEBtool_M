function dVe = dv0(Ve, t)

global v kM g LT rho

V = Ve(1); ee = Ve(2); L = max(1e-3,V)^(1/ 3);
Lm = v/ g/ kM;

de = (rho - ee) * Lm^2/ V;
r = (ee * Lm^2/ V - kM * g)/ (ee + g);
dV = r * V;

dVe = [dV; de];