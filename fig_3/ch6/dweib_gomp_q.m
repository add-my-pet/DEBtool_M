function dVeqhS = dweib_gomp_q(t, VeqhS)

global v kM g LT rho h0 ha sG

%% upack vars
V = VeqhS(1); ee = VeqhS(2); L = max(1e-3, V)^(1/ 3);
Lm = v/ g/ kM; Li = Lm - LT;
q = VeqhS(3); h = VeqhS(4); S = VeqhS(5);

%% e and V trajectories
de = (rho * Li^2/ L^2 - ee) * v/ L;
r = (v * ee/ L - (1 + LT/ L) * kM * g)/ (ee + g);
dV = r * V;

%% aging
dq = (q * sG * L^3/ Lm^3 + 1e-6 * ha) * ee * (v/ L - r) - r * q;
dh = q - h * r;

%% survival
dS = - S * (h0 + h);

%% pack output
dVeqhS = [dV; de; dq; dh; dS];
