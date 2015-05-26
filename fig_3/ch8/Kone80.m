%% fig:Kone80
%% bib:Kone80
%% out:Kone80

%% LC50.14 d as function of P_ow in Poecilia reticulata

PL = [-0.29999   5.04000;
      0.88000   4.46001;
      2.79001   2.64001;
      2.02001   2.93001;
      1.51000   3.54001;
      3.97999   1.46001;
      3.31001   1.67001;
      5.68999  -0.14998;
      4.94001   0.15001;
      4.94001   0.57000;
      4.94001   0.57000;
      4.19999   1.25999;
      4.19999   1.12001;
      4.19999   1.11001;
      3.53001   1.42999;
      3.53001   1.70000;
      3.53001   1.59999;
      2.81000   2.23002;
      3.09001   2.55000;
      2.59001   2.87001;
      2.13001   2.91002];


p = [50, -6.6]';
nrregr_options('report',0);
p = nrregr('Pow2Lc50', p, PL);
nrregr_options('report', 1);
[cov, cor, sd, ssq] = pregr('Pow2Lc50', p, PL);
par_txt = [{'elim rate = ?/sqrt(Pow)'}; 'killing rate = 10^? Pow'];
printpar(par_txt, p, sd);

lPow = linspace(-.5, 6, 100)';
elLC50 = Pow2Lc50 (p(:,1), lPow); 

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'Kone80.ps'

plot(PL(:,1), PL(:,2), 'og', lPow, elLC50, 'r');
xlabel('log Pow')
ylabel('log LC50.14d, muM')
