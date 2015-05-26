% first get parameters of standard DEB model
p = [.7; .95; 2; .1; .1; 2.5; .1; 0.95]; % p: [kap kapR g kJ kM v Hb Hp]
% this vector can be obtained from get_pars_s or get_pars_t
% compose vector of supplementary data (from measurements)
q = [2; 10; 2.5; 1.8]; % q: [JXAm K ME0 MWb]
par = get_pars_u(q,p); % get primary DEB parameters
%  par = [JEAm; b; yEX; yVE; v; JEM; kJ; kap; kapR; MHb; MHp; MV];

% now get nMO = matrix of chemical indices (relative elemental frequencies)
% minerals
%   rows: elements carbon C, hydrogen H, oxygen O, nitrogen N
%   columns: carbon dioxide C, water H, dioxygen O, ammonia N
%      C  H  O  N
n_M = [1, 0, 0, 0;  % C
       0, 2, 0, 3;  % H
       2, 1, 2, 0;  % O
       0, 0, 0, 1]; % N
% organic compounds
%   rows: elements carbon C, hydrogen H, oxygen O, nitrogen N
%   columns: food X, structure V, reserve E, faeces P
%      X     V     E     P
n_O = [1.00, 1.00, 1.00, 1.00;  % C/C, equals 1 by definition
       1.80, 1.80, 2.00, 1.80;  % H/C
       0.50, 0.50, 0.75, 0.50;  % O/C
       0.20, 0.15, 0.20, 0.15]; % N/C
nMO = [n_M, n_O]; % compose combined matrix of chemical indices

% finally specify food density and mass of reserve, structure
X = 10; % food density (mol/m^3)
a = (1:4)'; na = length(a); % ages
EVH = get_evh(a, par, X); XEVH = [X * ones(na,1), EVH];

% present fluxes
JMO = flux(XEVH, nMO, par)

% test conservation of chemical elements	    
% JMO * nMO' % must be all zero
