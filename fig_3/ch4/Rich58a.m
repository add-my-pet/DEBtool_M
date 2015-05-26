%% fig:Rich58a
%% bib:Rich58
%% out:Rich58a

%% Respiration (mul/h) during starvation (d) in Daphnia pulex

tO2 = [5 0.08786;
  4 0.06198;
  3 0.10363;
  2 0.09321;
  1 0.16045;
  0 0.16510];
  
tCO2 = [5 0.06380;
  4 0.04550;
  3 0.08456;
  2 0.08118;
  1 0.14917;
  0 0.18571];

par_txt = {'initial JO2'; 'initial JCO2'; ...
  'energy conductance length ratio'};
p = [.18 1; .17 1; .23 1];
p = nmregr('expo2', p, tO2, tCO2); 
[cov cor sd] = pregr('expo2', p, tO2, tCO2);
printpar(par_txt, p, sd)

t = linspace(0,5.5,100)';
[O2 CO2] = expo2(p(:,1), t, t);

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'Rich58a.ps'

plot(t, O2, '-r' , t, CO2, '-b', ...
    tO2(:,1), tO2(:,2), '.r', tCO2(:,1), tCO2(:,2), '.b')
legend('O2', 'CO2', 1);
xlabel('time, d')
ylabel('O2, CO2 flux, mul/h')
