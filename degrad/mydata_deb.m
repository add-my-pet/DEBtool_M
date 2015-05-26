%% set parameter guesses
p = [9.99;   % initial conc
     0.10;   % initial biomass
     0.98;   % saturation constant
     25;     % max spec uptake rate
     1.5;    % yield of substrate on structure
     .4;     % reserve turnover rate
     .01];   % maintenance rate coeffcient

%% get time points in hours
nt = 20; t = linspace(0,3,nt)';

%% calculate 'observations' for time points t
[c,b] = deb(p,t,t); % c = concentration; b = structure

%% obtain data with 'observations' plus random error
tc = [t, c + 0.5 * randn(nt,1)]; % (time, conc) data points 
tb = [t, b + 0.01 * randn(nt,1)]; % (time, biomass) data points
tb(:,3) = 10; % give biomass data weight 10 because of their small values

%% set parameter values away from the real values (apart from error)
%% p = p + .1 * randn(7,1);
	      
%% now the use in practical situations
p = nmregr('deb',p,tc,tb); % obtain correct parameter values
%% p = nrregr('deb',p,tc,tb); % obtain correct parameter values

[cor,cov,sd, ss] = pregr('deb',p,tc,tb); % get correlations and variances
[p,sd] % show parameters and standard deviations
sqrt(ss) % mean standard deviation
shregr('deb',p,tc,tb); % show goodness of fit

% now try pirt model
q = p; q(6,:) = []; % remove reserve turnover rate
q = nmregr('pirt',q,tc,tb); 
[cor,cov,sdq, ssq] = pregr('pirt',q,tc,tb); % get correlations and variances
[q, sdq] % show parameters and standard deviations
[sqrt(ssq), sqrt(ss/ssq)] % mean standard deviation, ratio deb/pirt < 1?
shregr('pirt',q,tc,tb); % show goodness of fit
