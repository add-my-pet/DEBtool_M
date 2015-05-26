
hG = .1; hW = .00004; q0 = .005;

t = linspace(0,100,100)'; 

hGt = hG * t;
S = exp((1 - exp(hG * t) + hGt + hGt.^2/2) * 6 * hW^3/hG);
G1 = exp(- (exp(hG * t) - 1 - hG * t) * q0/ hG^2);
G2 = exp(- (exp(hG * t) - 1)* q0/ hG^2);

plot(t,S,'g',t,G1,'r',t,G2,'m')