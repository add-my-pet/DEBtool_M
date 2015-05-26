%% fig:RussCook59
%% bib:RussCook59
%% out:RussCook59

%% Russell, J.B. and Cook, G.M. 1995
%% Energetics of bacterial growth: balance of anabolic and catabolic reactions
%% Microbiol Rev 59: 48-62

%% Streptococcus bovis on glucose-limited medium
%% 1/dilution rate (1/h), 1/yield (mg cells/ mmol glucose)

hy = [0.5  .024;
      0.8  .022;
      1.4  .02;
      2.2  .018;
      4.25 .0175;
      5.5  .021;
      9.7  .024;
      12.3 .024];

p = [63 6 .007]';
nmregr_options('max_step_number',500)
p = nmregr('iriy',p,hy);
[cov,cor,sd] = pregr('iriy',p,hy);
[p, sd];

x = linspace(0.2,14,100)';

%% gset term postscript color solid  'Times-Roman' 30
%% gset output 'RussCook95.ps'

%% gset nokey
%% gset yrange [0.01:0.04]
%% gset ytics .01
%% gset xrange [0:12]
%% gset xtics 3
plot (x, iriy(p(:,1),x), 'g', hy(:,1), hy(:,2), 'or' );  
xlabel('1/growth rate, 1/h')
ylabel('1/yield, mg cells/ mmol glucose')