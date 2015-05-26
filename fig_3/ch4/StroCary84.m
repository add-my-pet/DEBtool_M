%% fig:StroCary84
%% bib:StroCary84
%% out:StroCary84

%% Growth rate (mm/d) during starvation (d) in Mytilus edulis

tG = [5.46665  0.00871;
  4.97499  0.01047;
  4.47917  0.01378;
  3.95834  0.02028;
  3.42917  0.02398;
  2.94166  0.03309;
  2.44168  0.04976;
  1.90835  0.07328;
  1.39584  0.09349;
  0.90002  0.11485;
  0.45418  0.14666;
  0.00000  0.16782];

%% notice that the total change in L is so small
%% that is can be neglected
%% else work the the full ode-ystem

par_txt = {'initial Length'; 'investment ratio'; ...
	   'maint rate coeff'; 'energy conductance'};
p = [15 1; 12.59 1; 0.0024 0; 6.84 1];
p = nmregr('starve', p, tG); 
[cov cor sd] = pregr('starve', p, tG);
printpar(par_txt, p, sd)

t = linspace(0,6,100)';
dL = starve(p(:,1), t);

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'StroCary84.ps'

plot(tG(:,1), tG(:,2), '.g', t, dL, '-r')
xlabel('time, d')
ylabel('growth rate, mm/d')

