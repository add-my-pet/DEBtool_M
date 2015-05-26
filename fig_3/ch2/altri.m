%% fig:altri
%% bib:Kend40,BartGold84,RomiLokh51,Roma60,VlecHoyt79
%% out:Kend40,Kend40r,BartGold84,BartGold84r,RomiLokh51,RomiLokh51r,
%%     Roma60,Roma60r

%% text that is used in printpar
nmVO = {'time at birth'; 'scaled res at birth'; 'scaled length at birth';...
      'l3 to weight'; 'maint rate coeff, kM';...
      'energy invest ratio, g'; 'l3 to respi'; 'dl3 to respi'};

%% assign data values
altri_troglodytes
altri_pelicanus
altri_gallus
altri_anser

%% nrregr_options('report',0)
p_Ta = [12 0; 1 0; .1 0; 1410 1; .03 0; 1.04 1; 26882 1; 660 0];
%% p_Ta = nmregr('embryoVO',p_Ta, aW_Ta, aCO2_Ta);
%% [cov cor sd ssd] = pregr('embryoVO',p_Ta, aW_Ta, aCO2_Ta);
%% printpar(nmVO, p_Ta, sd); ssd
p_Po = [31 0; 1 0; .1 0; 65319 1; .05 1; 0.324 1; 414 1; 181 1];
%% p_Po = nmregr('embryoVO',p_Po, aW_Po, aO2_Po);
%% [cov cor sd ssd] = pregr('embryoVO',p_Po, aW_Po, aO2_Po);
%% printpar(nmVO, p_Po, sd); ssd
p_Gd = [30 0; .44 1; .1 0; 58000 1; .008 0; 2.23 1; 40 0; 69 1];
%% p_Gd = nmregr('embryoVO',p_Gd, aW_Gd, aO2_Gd);
%% [cov cor sd ssd] = pregr('embryoVO',p_Gd, aW_Gd, aO2_Gd);
%% printpar(nmVO, p_Gd, sd); ssd
p_Aa = [30 0; 1 0; .1 0; 94173 1; .0037 1; 6.29 1; 771 1; 24.25 1];
%% p_Aa = nmregr('embryoVO',p_Aa, aW_Aa, aO2_Aa);
%% [cov cor sd ssd] = pregr('embryoVO',p_Aa, aW_Aa, aO2_Aa);
%% printpar(nmVO, p_Aa, sd); ssd
%% nrregr_options('report',1)

a_Ta = linspace(12,0,100)';
[W_Ta CO2_Ta] = embryoVO(p_Ta(:,1), a_Ta, a_Ta);
a_Po = linspace(31,0,100)';
[W_Po O2_Po] = embryoVO(p_Po(:,1), a_Po, a_Po);
a_Gd = linspace(20,0,100)';
[W_Gd O2_Gd] = embryoVO(p_Gd(:,1), a_Gd, a_Gd);
a_Aa = linspace(30,0,100)';
[W_Aa O2_Aa] = embryoVO(p_Aa(:,1), a_Aa, a_Aa);
[eW_Aa eO2_Aa] = embryoVO(p_Aa(:,1), aW_Aa, aO2_Aa);

%% gset term postscript color solid 'Times-Roman' 35
%% gset nokey

%% multiplot(2,4)
subplot(2,4,1);
%% gset output 'Kend40.ps'
plot(aW_Ta(:,1), aW_Ta(:,2), 'og', a_Ta, W_Ta, 'r');
title('Troglodytes aedon')
xlabel('time, d');
ylabel('wet weight structure, g');

subplot(2,4,2);
%% gset output 'Kend40r.ps'
plot(aCO2_Ta(:,1), aCO2_Ta(:,2), 'ob', a_Ta, CO2_Ta, 'r');
title('Troglodytes aedon')
xlabel('time, d');
ylabel('CO2 production, ml/d');

subplot(2,4,3);
%% gset output 'BartGold84.ps'
plot(aW_Po(:,1), aW_Po(:,2), 'og', a_Po, W_Po, 'r');
title('Pelicanus occidentalis')
xlabel('time, d');
ylabel('wet weight structure, g');

subplot(2,4,4);
%% gset output 'BartGold84r.ps'
plot(aO2_Po(:,1), aO2_Po(:,2), 'ob', a_Po, O2_Po, 'r');
title('Pelicanus occidentalis')
xlabel('time, d');
ylabel('O2 consumption, l/d');

subplot(2,4,5);
%% gset output 'RomiLokh51.ps'
plot(aW_Gd(:,1), aW_Gd(:,2), 'og', a_Gd, W_Gd, 'r');
title('Gallus domesticus')
xlabel('time, d');
ylabel('wet weight structure, g');

subplot(2,4,6);
%% gset output 'RomiLokh51r.ps'
plot(aO2_Gd(:,1), aO2_Gd(:,2), 'ob', a_Gd, O2_Gd, 'r');
title('Gallus domesticus')
xlabel('time, d');
ylabel('O2 consumption, l/d');

subplot(2,4,7);
%% gset output 'Roma60.ps'
plot(aW_Aa(:,1), aW_Aa(:,2), 'og', a_Aa, W_Aa, 'r');
title('Anser anser')
xlabel('time, d');
ylabel('wet weight structure, g');

subplot(2,4,8);
%% gset output 'Roma60r.ps'
plot(aO2_Aa(:,1), aO2_Aa(:,2), 'ob', a_Aa, O2_Aa, 'r');
title('Anser anser')
xlabel('time, d');
ylabel('O2 consumption, l/d');

%% multiplot(0,0)
