%% fig:VoogHatt91
%% bib:VoogHatt91
%% out:VoogHatt91

%% mixtures of chemicals, a.o. PAC; Temperatuur: 23 oC	
%% reference:		
%% Voogt, P. de, Hattum, B. van, Leonards, P., Klamer, J.C., Govers, H., 1991.
%% Bioconcentration of polycyclic hydrocarbons in the Guppy
%%   (Poecilia reticulata). Aquatic Toxicol. 20: 169-194.

%% log kow		log ke (d-1)
lklk = [ ...
5.99288256		-2.969768988;
5.63701068		-2.479891568;
4.91103203		-1.966763848;
5.85053381		-1.791595798;
6.02135231		-1.503181408;
6.20640569		-1.770362108;
6.40569395		-1.970915688;
6.40569395		-1.793137908;
5.5088968		-1.012869028;
4.9252669		-1.011247828;
5.02491103		-0.989302398;
4.41281139		-0.676491008;
4.72597865		-0.588472028;
3.72953737		-0.674593028;
3.25978648		-0.362177058;
3.10320285		-0.117297658;
2.96085409		-0.005791128;
2.80427046		0.083532712;
0.83985765		0.955656082;
0.91103203		0.955458372;
3.31672598		-0.006779668;
4.01423488		-0.542050518;
4.113879		-0.520105088;
4.22775801		-0.431532528;
1.89323843		0.797174472;
2.10676157		0.796581352];

p = nrregr('propto', 1, lklk);
x = [.7 ;6.5]; y = propto(p(1,1), x);

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'VoogHatt91.ps'

plot(lklk(:,1), lklk(:,2), 'or', x, y, 'g')
xlabel('log P_{ow}')
ylabel('elimination rate, d^{-1}')
title('polycyclic hydrocarbons in guppies; slope = -0.5')