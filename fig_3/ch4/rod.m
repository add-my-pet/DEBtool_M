%% fig:rod
%% bib:TrinRobs90,CollRich62,Kubi90a,Mitc61
%% out:TrinRobs90,CollRich62,Kubi90a,Mitc61

%% size at age for V1-morphs and rods

%% Fusarium graminearum: length (mm) at age (h)
%% \cite{TrinRobs90} trin90.eps
aL_Fg = [11.44990785 0.422956316;
	 11.98106338 0.4487500057;
	 12.41629649 0.5102646945;
	 12.99623938 0.572040041;
	 13.5138739  0.6057223878;
	 13.91621643 0.6602073527;
	 14.44847237 0.769448539;
	 14.90069928 0.9011919852;
	 15.41504947 1.058521754;
	 15.87440032 1.185451928;
	 16.32278764 1.309001065;
	 16.99847461 1.513255475;
	 17.3233456  1.637537114;
	 17.86894083 1.95656536;
	 18.44979903 2.282320088;
	 18.86420212 2.565786082;
	 19.43957856 2.971930054;
	 19.84959691 3.373863256;
	 20.29104201 3.807981946;
	 20.80740117 4.381839533;
	 21.2302103  5.057021738;
	 21.84907404 6.006598899;
	 23.08772022 9.524205456];

%% Bacillus cereus: volume (mum^3) at age (min)
%% \cite{CollRich62} coll62.eps
aV_Bc = [45.0054   4.9965;
	 40.8437   4.5787;
	 36.7810   4.0501;
	 32.7871   3.8994;
	 28.9517   3.5085;
	 24.7692   3.2412;
	 20.8444   2.8344;
	 16.9979   2.5729;
	 12.9023   2.4326;
	  8.9158   2.1603;
	  5.1515   2.0363;
	  1.1127   1.7719];

%% Escherichia coli: volume (mum^3) at age (min)
%% \cite{Kubi90a} kubi90a.eps
aV_Ec = [104.50603    0.80777;
          89.78821    0.74593;
          75.40956    0.69650;
          60.68303    0.63713;
          45.27177    0.59070;
          30.40454    0.53504;
          15.41356    0.47813];

%% Streptococcus faecalis: volume (mum^3) at age (min)
%% \cite{Mitc61} mitc61b.eps
aV_Sf = [93.23375   1.49906;
	 87.94458   1.47951;
	 78.21500   1.47001;
	 67.89875   1.42302;
	 63.81292   1.36030;
	 57.97500   1.38017;
	 53.12292   1.34762;
	 48.50250   1.26501;
	 43.12042   1.18200;
	 32.94667   1.21515;
	 28.04583   1.07002;
	 22.38208   1.05235;
	 17.06125   0.99018];


%% although the Fg data concern lengths, not volumes
%%   we still can use "rod" because we force for exponential growth
%%   by setting p(2) = 0; the spec growth rate then differs by a factor 3
%% Notice that (3.42) for volumes resembles (3.20) for lengths,
%%   but the parameters Vi and/or rr in (3.42) might be negative!
%% This would be non-sense in (3.20)
p_Fg = nrregr('fnrod',[0.017 1; 0 0; -.3 1], aL_Fg)
a_Fg = linspace(11,23.5,100)'; L_Fg = fnrod(p_Fg(:,1), a_Fg);
p_Bc = nrregr('fnrod',[3.5 -.5 -.02]', aV_Bc)
a_Bc = linspace(0,50,100)'; V_Bc = fnrod(p_Bc(:,1), a_Bc);
%% we fix p(3) to a very small number to avoid numerical problems
%% Ec data show almost perfectly linear growth,
%%   wich is a limiting situation for Vi -> infty and rr -> 0
p_Ec = nrregr('fnrod',[.85 1; 16 1; .000228 0], aV_Ec)
a_Ec = linspace(0,110,100)'; V_Ec = fnrod(p_Ec(:,1), a_Ec);
p_Sf = nrregr('fnrod',[1.5 1.7 .017]', aV_Sf)
a_Sf = linspace(0,100,100)'; V_Sf = fnrod(p_Sf(:,1), a_Sf);


%% gset term postscript color solid  "Times-Roman" 30
%% gset nokey;

%% multiplot(2,2)

subplot(2,2,1);
%% gset output 'TrinRobs90.ps'
plot(aL_Fg(:,1), aL_Fg(:,2), 'og', a_Fg, L_Fg, 'r')
title('Fusarium graminearum, delta = 0')
xlabel('time, h')
ylabel('hyphal length, mm')

subplot(2,2,2);
%% gset output 'CollRich62.ps'
plot(aV_Bc(:,1), aV_Bc(:,2), 'og', a_Bc, V_Bc, 'r')
title('Bacillus cereus, delta = 0.2')
xlabel('time, min')
ylabel('cell volume, mum^3')

subplot(2,2,3);
%% gset output 'Kubi90a.ps'
plot(aV_Ec(:,1), aV_Ec(:,2), 'og', a_Ec, V_Ec, 'r')
title('Escherichia coli, delta = 0.28')
xlabel('time, min')
ylabel('cell volume, mum^3')

subplot(2,2,4);
%% gset output 'Mitc61.ps'
plot(aV_Sf(:,1), aV_Sf(:,2), 'og', a_Sf, V_Sf, 'r')
title('Streptococcus faecalis, delta = 0.6')
xlabel('time, min')
ylabel('cell volume, mum^3')

%% multiplot(0,0)
