%% fig:rich75
%% bib:Rich75
%% out:rich75
%% diameter of lichens as function of time

%% Aspicilia cinerea
tL_Ac = [1595.9996    30.9170;
  1777.9997    12.6037;
  1814.0001    11.6606;
  1846.9998     8.7157;
  1901.0012     5.1573;
  1924.0008     3.8994];

%% Rhizocarpon geographicum
tL_Rg = [1595.9996    13.1244;
  1777.9997     7.5616;
  1814.0001     6.2105;
  1846.9998     5.5406;
  1901.0012     4.2669;
  1924.0008     3.8994];

nrregr_options('report',0);
p_Ac = nrregr('linear_r', [1 1]',tL_Ac);
p_Rg = nrregr('linear_r', [1 1]',tL_Rg);
t = [1580 1925]';
e_Ac = linear_r(p_Ac(:,1), t);
e_Rg = linear_r(p_Rg(:,1), t);
nrregr_options('report',1);

%% gset term postscript color solid  'Times-Roman' 30
%% gset output 'rich75.ps'

plot(t, e_Ac, '-r', t, e_Rg, '-b' , ...
    tL_Ac(:,1), tL_Ac(:,2), '.r', tL_Rg(:,1), tL_Rg(:,2), '.b') 
    legend('Aspicilia cinerea', 'Rhizocarpon geographicum');
xlabel('year of moraine deposition')
ylabel('diameter, cm')
