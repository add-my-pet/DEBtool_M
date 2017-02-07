%% dtraject
% ODE of DEB model including rejuvenation and shrinking

%%
function dvars = dtraject(t, vars, ...
    vHb, vHp, g, kapR1, kapG, lT, k, k1, ha, sG, sH, uE0, f)
% called from traject and used in ode-solver
% specifies derivatives of state variables
% f equals 0 or 1

global vH_max

%unpack vars
e = vars(1);  % reserve density
l = vars(2);  % length
vH = vars(3); % maturity
q = vars(4);  % acceleration
h = vars(5);  % hazard
S = vars(6);  % survival
%N = vars(7); % cumulative number of eggs

de = g * (f - e)/ l; % change in reserve density
if e > l + lT % (positive) growth
  r = g * (e/ l - 1 - lT/ l)/ (e + g); % spec growth rate
else % shrinking (negative growth)
  r = g * (e/ l - 1 - lT/ l)/ (e + kapG * g); % spec growth rate
end    
dl = l * r/ 3; % growth in length

dvH = - k * vH + l^2 * e * (1 - l * r/ g); % maturity increase
if dvH < 0 % rejuvenation
    dvH = - k1 * (vH - l^2 * e * (1 - l * r/ g)/ k); % maturity decrease
end
if dvH > 0 & vH >= vHp % adult
  dvH = 0; % no maturity increase in adults
end
  
dq = (q * l^3 * sG + ha) * e * (g/ l - r) - r * q; % change in acceleration

dh = q - r * h; % change in hazard by ageing

vH_max = max(vH_max, vH); % maximum maturity

dS = - S * (h + sH * (vH_max - vH)); % survival by ageing, rejuvenation

% uE0 = get_ue0 ([g; k; vHb], e); % initial reserve
% uE0 (global) should be stochastic but hardly affects results
uER = ((g + lT + l) * e * l^2/ (e + g) - k * vHp) * kapR1; % reprod rate
dN = (vH >= vHp) * uER/ uE0; % change in cum number of eggs

%pack derivatives
dvars = [de; dl; dvH; dq; dh; dS; dN];