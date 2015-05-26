%% fig:salhis
%% out:salhis

%% Batch culture of histidine-limited Salmonella typhimurium

tOD1 =  [7.50123  0.44566;
	 7.00026  0.44515;
	 6.52539  0.44863;
	 6.02731  0.44185;
	 5.50892  0.42968;
	 5.04533  0.32986;
	 4.52097  0.25404;
	 4.01114  0.18483;
	 3.55061  0.15318;
	 3.02637  0.10953;
	 2.50506  0.08345];

tOD2 = [5.02446  0.11769;
	4.49166  0.12204;
	4.01383  0.11457;
	3.53603  0.11283;
	3.02056  0.10136;
	2.50503  0.07684;
	2.03012  0.06641;
	1.50884  0.04938];

tOD3 = [4.01370  0.07144;
	3.54460  0.06762;
	3.02624  0.06832;
	2.51950  0.06919;
	2.03297  0.05807;
	1.51169  0.04398;
	1.01361  0.03564];

tOD4 = [3.54158  0.02866;
	3.02033  0.02710;
	2.49042  0.02937;
	2.03579  0.02902;
	1.51747  0.02851;
	1.01069  0.02886;
	0.53001  0.02921;
	0.00000  0.02487];


nmregr_options('report',0);
par_txt = {'1 initial his conc'; '2 initial his conc'; ...
	   '3 initial his conc'; '4 initial his conc'; ...
	   'background his conc'; ...
	   'initial biomass density'; 'max spec uptake rate'; ...
	   'energy investment ratio'; 'reserve turnover rate'};
p = [5 0; 1 0; .5 0; 0 0; .09 1; .02  1; 7.2 1; 12 1; 7.2 1];
p = nrregr('expologist4', p, tOD1, tOD2, tOD3, tOD4);
[cor cov sd ssq] = pregr('expologist4', p, tOD1, tOD2, tOD3, tOD4);
printpar(par_txt, p, sd);

t = linspace(0, 8, 100)';
[eOD1 eOD2 eOD3 eOD4] = expologist4(p(:,1), t, t, t, t);
nrregr_options('report',1);

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'salhis.ps'
hold on
plot(t, eOD1, '-r', t, eOD2, '-g', t, eOD3, '-b', t, eOD4, '-m')
legend('5 mug/ml', '1 mug/ml', '0.5 mug/ml', '0 mug/ml', 2);
plot(tOD1(:,1), tOD1(:,2), '.r', ... 
     tOD2(:,1), tOD2(:,2), '.g', ... 
     tOD3(:,1), tOD3(:,2), '.b', ... 
     tOD4(:,1), tOD4(:,2), '.m')
xlabel('time, h')
ylabel('extinction at 660 nm')
title('histidine')
