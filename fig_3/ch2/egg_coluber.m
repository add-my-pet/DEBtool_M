%% fig:egg_coluber
%% bib:PackPack84
%% out:PackPack84,PackPack84a
%%  run this script from egg
%% Coluber constrictor: dry weight (g) and yolk (g) at age (d)

aW = [41   0.994534;
      35   0.697623;
      30   0.399243;
      20   0.097133];

aY = [41   0.19729;
      35   0.60204;
      30   0.89808;
      20   1.19897;
       0   1.39517];

nrregr_options('report',0)
p = [41 0; 1 0; .39 1; 4.46 1; 16.2 1; .02 0; 3.26 1];
p = nrregr('embryoEV',p, aY, aW);
[cov cor sd ssd] = pregr('embryoEV',p, aY, aW);
printpar(nmEV, p, sd); 
nrregr_options('report',1)

a = linspace(41,0,100)';
[Y W] = embryoEV(p(:,1), a, a);

%% gset term postscript color solid 'Times-Roman' 35
%% clg; gset nokey

%% multiplot(1,2)
subplot(1,2,1);
%% gset output 'PackPack84.ps'
plot(aY(:,1), aY(:,2), 'og', a, Y, 'r');
title('Coluber constrictor')
xlabel('time, d');
ylabel('dry weight, g');

subplot(1,2,2);
%% gset output 'PackPack84a.ps'
plot(aW(:,1), aW(:,2), 'og', a, W, 'r');
title('Coluber constrictor')
xlabel('time, d');
ylabel('weight structure, g');

%% multiplot(0,0)
