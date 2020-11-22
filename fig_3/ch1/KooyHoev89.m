%% fig:KooyHoev89
%% bib:KooyHoev89
%% out:KooyHoev89

%% Arrhenius plots for 4 different rates in Daphnia magna

%% clear; closeplot;
%% setpath % to DEBtool/lib

itrep1 = [33.39621336 2.296808408;
	  33.68166885 2.761300707;
	  33.67258836 2.730143481;
	  34.12998167 2.812030379;
	  34.13462446 2.628455148];

itrep2 = [33.66706711 2.064831021;
	  34.13745396 2.00559277;
	  34.73040187 1.607081262;
	  35.35051023 0.4122001524];

iting = [33.21798778 -0.7345242339 1;
	 34.12876465 -0.3560955943 1;
	 34.71067171 -0.8521672678 1;
	 36.0978478 -2.241980443   0; % exclude this data point from regression
	 33.3918952 -1.980115613   0];% exclude this data point from regression

itgrow = [33.66538868 -1.826471182;
	  33.66679537 -2.134371332;
	  34.12887661 -2.255833485;
	  34.12834672 -2.332110399;
	  34.12896565 -2.603294209;
	  34.71126197 -2.653029593;
	  35.3488846  -3.193787616];

itage2 = [33.20943909 -3.466271973;
	  34.3515362 -3.887986952;
	  35.32451531 -4.54572166;
	  35.57014596 -4.830191266];

itage1 = [35.57419239 -4.752469597;
	  35.32875193 -4.551332516;
	  34.34896981 -3.688855745;
	  33.20246201 -3.185259464];

it = [33 36.5]'; % set range inverse temperature (for graphs only)
nrregr_options('report',0);
p = nrregr('linear4',[1 1 1 1 1]',[itrep1;itrep2], iting, itgrow, [itage1;itage2]);
[rep ing grow age] = linear4(p ,it, it, it, it); % get expected values
nrregr_options('report',1);

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'KooyHoev89.ps'

hold on; 
plot(it, rep, '-r', ...
     it, ing, '-m', ...
     it, grow, '-g', ...
     it, age, '-b');
legend('reproduction', 'ingestion', 'growth', 'aging');
plot(itrep1(:,1), itrep1(:,2), '.r', itrep2(:,1), itrep2(:,2), '+r', ...
     iting(:,1),  iting(:,2),  '.m', ...
     itgrow(:,1), itgrow(:,2), '.g', ...
     itage1(:,1), itage1(:,2), '.b', itage2(:,1), itage2(:,2), '+b');
title('reproduction, ingestion, growth, aging in Daphnia magna');
xlabel('10^4 T^-1, K^-1');
ylabel('ln rate, 1/d');