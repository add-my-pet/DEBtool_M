%% fig:salmo
%% out:salty

%% Batch culture of Salmonella typhimurium

tOD = [ ...
  0.00000  0.08577; % optical densities at 660 nm
  0.02217  0.08459;
  0.03683  0.09914;
  0.05540  0.15015;
  0.07387  0.20787;
  0.09123  0.27802;
  0.10901  0.36734;
  0.12755  0.47009;
  0.14412  0.58862;
  0.16242  0.71000;
  0.18139  0.84872;
  0.19960  0.95818;
  0.21684  1.04461;
  0.23583  1.11910;
  0.25233  1.17584;
  0.27103  1.20625;
  0.28633  1.23662];

tN = [0 0 0]; % no nutrient data

nrregr_options('report',0);
par_txt = {'initial nutrient conc'; 'initial biomass density'; ...
	   'max spec uptake rate'; 'energy investment ratio'; ...
	   'reserve turnover rate'};
p_el = [1 0; .0657 1; 50 1; .355 1; 18.6 1];
p_el = nrregr('expologist', p_el, tOD, tN);
[cor cov sd ssq] = pregr('expologist', p_el, tOD, tN);
printpar(par_txt, p_el, sd);

t = linspace(0, .3, 100)';
[eOD eK] = expologist(p_el(:,1), t, t); teK = [t, eK];

par_txt = {'initial nutrient conc'; 'initial biomass density'; ...
	   'max spec uptake rate'; 'yield'; 'saturation constant'};
p_mon = [1 0; .054 1; 50 1; 1.2 1; 2.8 1];
p_mon = nmregr('monod', p_mon, tOD, tN);
[cor cov sd ssq] = pregr('monod', p_mon, tOD, tN);
printpar(par_txt, p_mon, sd);

[eODm eKm] = monod(p_mon(:,1), t, t); teKm = [t, eKm];
nrregr_options('report',1);

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'salty.ps'

hold on
plot(tOD(:,1), tOD(:,2), '.g', t, eODm, 'b', t, eOD, '-r')
legend('S. typhimurium', 'Monod', 'expologist', 1)
[AX, H1, H2] = plotyy(0,0,teK(:,1), teK(:,2));
set(H2, 'Color', 'r');
[AX, H3, H4] = plotyy(0,0,teKm(:,1), teKm(:,2));
set(H4, 'Color', 'b')
xlabel('time, h')
set(get(AX(1), 'YLabel'), 'String', 'extinction at 660 nm')
set(get(AX(2), 'YLabel'), 'String', 'scaled nutrient concentration')
