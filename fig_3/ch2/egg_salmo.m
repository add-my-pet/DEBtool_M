%% fig:egg_salmo
%% bib:Gray26
%% out:Gray26
%%  run this script from egg
%% Salmo trutta: dry weight (g) and yolk (g) at age (d)

aW = [80.01 0.0192;
      80 0.0224;
      70.01 0.0173;
      70 0.0155;
      66 0.0128;
      60.01 0.0107;
      60 0.0080;
      50.01 0.0053;
      50 0.0042];


aY = [80.01 0.0048;
      80 0.0057;
      70.01 0.0102;
      70 0.0152;
      66 0.0188;
      60.01 0.0205;
      60 0.0256;
      50.01 0.0283;
      50 0.0307];

nrregr_options('report',0)
p = [80. 0; 1 0; .1 0; 6.5 1; 20.4 1; .002 0; 4.4 1];
p = nrregr('embryoEV',p, aY, aW);
[cov cor sd ssd] = pregr('embryoEV',p, aY, aW);
printpar(nmEV, p, sd); 
nrregr_options('report',1)

a = linspace(80,0,100)';
[Y W] = embryoEV(p(:,1), a, a);

%% gset nokey
%% gset term postscript color solid 'Times-Roman' 35

%% multiplot(1,2)
subplot(1,2,1);
%% gset output 'Gray26.ps'
plot(aY(:,1), aY(:,2), 'og', a, Y, 'r');
title('Salmo trutta')
xlabel('time, d');
ylabel('dry weight, g');

subplot(1,2,2);
%% gset output 'Gray26a.ps'
plot(aW(:,1), aW(:,2), 'og', a, W, 'r');
title('Salmo trutta')
xlabel('time, d');
ylabel('weight structure, g');

%% multiplot(0,0)
