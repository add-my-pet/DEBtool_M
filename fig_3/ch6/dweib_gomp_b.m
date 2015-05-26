function dqhS = dweib_gomp_b(t, qhS)

global v kM g LT rho h0 kW kG L0

%% upack vars
Lm = v/ g/ kM; Li = rho * Lm - LT;
q = qhS(1); h = qhS(2); S = qhS(3);

%% e and L trajectories
rB = kM/ 3/ (1 + rho/ g);
L = Li - (Li - L0) * exp(- rB * t);
r = (v * rho/ L - (1 + LT/ L) * kM * g)/ (rho + g);

%% aging
s = .001;
dq = s^2 * kW * rho * (v/ L - r) - r * q ;
dh = s * kG * q - h * (r - s * kG) ;

%% survival
dS = - S * (h0 + h);

%% pack output
dqhS = [dq; dh; dS];
