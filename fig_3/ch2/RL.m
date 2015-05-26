%% fig:RL
%% bib:Gunt90,Mill61
%% out:gunt90,mill61
%% reproduction rate (eggs) at length (cm)

%% Rana esculenta: Gunt90
LR_Re = [75 2944;
	 76 5000;
	 78 4889;
	 78 4389;
	 80 2889;
	 80 5722;
	 81 4833;
	 85 6055;
	 86 5638;
	 88 3982;
	 88 7333;
	 89 7388;
	 92 10021;
	 92 8166;
	 95 7444];
LR_Re(:,2) = .001 * LR_Re(:,2);

%% Gobius paganellus: Mill61
LR_Gp = [48.54688736 1.078019339;
	 51.46795995 1.417784495;
	 62.94847741 2.663949111;
	 66.3794302 2.610544531;
	 68.09027984 3.037017084;
	 72.88840059 4.303071245;
	 72.81942051 4.600020811;
	 74.85869376 4.7502009;
	 76.59226776 4.445142041;
	 75.94824579 3.654429505;
	 75.91854027 5.257360002;
	 82.40617094 5.55905839;
	 82.94453342 6.064846829;
	 83.87778514 5.463050438;
	 86.03196956 5.75585575;
	 87.87899122 6.761966572;
	 77.49158843 7.803336837;
	 81.81083025 8.985734682;
	 83.44190936 8.538083235];

nrregr_options('report',0);
p_Re = nrregr('repro',[2e-4 0; 1e-5 1; .2 1],LR_Re);
L_Re = linspace(75,95,100)';
R_Re = repro(p_Re(:,1),L_Re);
p_Gp = nrregr('repro',[2e-4 0; 1e-5 1; .03 1],LR_Gp);
L_Gp = linspace(48,90,100)';
R_Gp = repro(p_Gp(:,1),L_Gp);
nrregr_options('report',1);

%% gset term postscript color solid 'Times-Roman' 35
%% gset nokey;

%% multiplot(1,2)

subplot(1,2,1);
%% gset output 'mill61.ps'
plot(LR_Gp(:,1), LR_Gp(:,2), 'og', ...
     L_Gp, R_Gp, 'r')
title('Gobius paganellus')
xlabel('length, mm');
ylabel('10^3 oocytes');

subplot(1,2,2);
%% gset output 'Gunt90.ps'
plot(LR_Re(:,1), LR_Re(:,2), 'og',...
     L_Re, R_Re, 'r')
 title('Rana esculenta')
xlabel('length, mm');
ylabel('10^3 eggs');

%% multiplot(0,0)

