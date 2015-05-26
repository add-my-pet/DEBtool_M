%% fig:Here79
%% bib:Here79
%% out:Here79

%% ln spec population growth rate as function of inverse temperature
%%    in Escherichia coli

iTr = [3.490400  -2.059301;
       3.472222  -1.832584;
       3.448274  -1.469669;
       3.424657  -1.078813;
       3.401361  -0.705610;
       3.378377  -0.458764;
       3.322259   0.090199;
       3.300331   0.311436;
       3.267974   0.387531;
       3.236247   0.453703;
       3.225807   0.706076;
       3.205129   0.769066;
       3.174604   0.687679;
       3.144654   0.132754;
       3.134798  -0.146088;
       3.125000  -0.797390;
       3.115266  -1.775157];

%% untransform data
Tr = iTr; Tr(:,1) = 1000./Tr(:,1); Tr(:,2) = exp(Tr(:,2));

%% initial parameter estimates
p = [1.94 1; 310 0; 4370 1; 293 1; 318 1; 20110 1; 69490 1];
nrregr_options('report',0);
p = nrregr('kTemp', p, Tr); p = p(:,1); % get parameters
nrregr_options('report',1);

iT = linspace(3.1,3.5,100)';       % set plot range for inverse temp
Tq = p([4 5]); iTq = 1000 ./Tq;    % set T_AL - T_AH range for comparison
kq = p(1) * exp(p(3)/ p(2) - p(3)./ Tq); % simple Arrhenius

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'Here79.ps'

plot(iTr(:,1), iTr(:,2),'+g', iT, log(ktemp(p, 1000 ./ iT)), '-r', ...
     iTq, log(kq), '-b')
xlabel('10^3/T, K^-1');
ylabel('ln pop growth rate, 1/h');