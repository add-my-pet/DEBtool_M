%% time points in hours
t = [0 0.2 0.4 0.6 0.8 1 1.2 1.4 1.6 1.8 2 2.2 2.4]';
%% concentration and biomass pairs
cb = [10 0.1; 9.88 0.15; 9.7 0.235; 9.44 0.34; 9.04 0.52;
      8.44 0.8; 7.54 1.2; 6.22 1.8; 4.33 2.65; 1.89 3.74;
      0.14 4.53; 0.02 4.59; 0.01 4.59];
%% (time, conc) and (time, biomass) data points 
tc = [t, cb(:,1)]; tb = [t, cb(:,2)];

%% initial parameter guesses
p = [9.994 1;  % initial conc
     0.09961 1; % initial biomass
     0.984 1; % saturation constant
     2.298/.4494 1;  % max spec uptake rate
     1/.4494 1; % yield of substrate on biomass
     0 0];  % maintenance rate coeffcient

%% Use both substrate and biomass concentrations to estimate parameters
%% p = nmregr("pirt",p,tc,tb); % use the Nelder Mead method (simplex)
%% p = nrregr("pirt",p,tc,tb); % use the Newton Raphson method

%% [cor,cov,sd, ss] = pregr("pirt",p,tc,tb);
%% [p,sd] % show parameters and standard deviations
%% sqrt(ss) % total mean standard deviation
%% shregr("pirt",p,tc,tb); % show plots

%% Biomass data help to fix the parameters,
%%    but are not strictly necessary
p([2 6]',2) = 0; % exclude initial biomass and yield from estimation
p = nmregr('pirt',p,tc);
%% p = nrregr('pirt',p,tc);
[cor, cov, sd, ss] = pregr('pirt',p,tc); % get correlations and variances 
[p,sd] % show parameters and standard deviations
sqrt(ss) % total mean standard deviation
shregr('pirt',p,tc); % show plot
