%% fig:foet
%% bib:MacdAlle27,Fair69
%% out:MacdAlle27,Fair69
%% foetal weight at age (d)

%% Sub 1: Mus musculus (g)
aW_Mm = [18 1.1899996;
	 17 0.8466994;
	 16 0.5926020;
	 15 0.3650994;
	 14 0.2287995;
	 13 0.1297981;
	 12 0.0761993;
	 11 0.0329006;
	 10 0.0085998];

%% Sub 2: Aepyceros melampus (kg)
aW_Am = [196 5.37;
	 189 4.16;
	 182 3.105;
	 175 2.739;
	 168 2.335;
	 161 1.881;
	 154 2.150;
	 147 1.430;
	 140 1.245;
	 133 0.85201;
	 126 0.85501;
	 119 0.34000;
	 112 0.39501;
	 105 0.32080;
	 98  0.15060;
	 91  0.11100;
	 84  0.10581;
	 77  0.05651;
	 70  0.04541;
	 63  0.02900;
	 56  0.010608;
	 49  0.012208;
	 42  0.002904;
	 35  0.001895;
	 28  0];

nrregr_options('report',0);
p_Mm = nrregr('foetus',[.3 10]', aW_Mm);
nm = {'energy conductance, v'; 'time at start development'};
[cov cor sd ssq] = pregr('foetus', p_Mm, aW_Mm);
printpar(nm, p_Mm, sd);
a_Mm = linspace(10,18,100)'; W_Mm = foetus(p_Mm(:,1), a_Mm);

p_Am = nrregr('foetus',[.03 53]', aW_Am);
[cov cor sd ssq] = pregr('foetus', p_Am, aW_Am);
printpar(nm, p_Am, sd);
a_Am = linspace(0,200,100)'; W_Am = foetus(p_Am(:,1), a_Am);
nrregr_options('report',1);

%% gset term postscript color solid 'Times-Roman' 35
%% gset nokey;

%% multiplot(1,2)

subplot(1,2,1);
%% gset output 'MacdAlle27.ps'
plot(aW_Mm(:,1), aW_Mm(:,2), 'og', a_Mm, W_Mm, 'r')
title('Mus musculus embryo')
xlabel('time, d')
ylabel('weight, g')

subplot(1,2,2);
%% gset output 'Fair69.ps'
plot(aW_Am(:,1), aW_Am(:,2), 'og', a_Am, W_Am, 'r')
title('Aepyceros melampus embryo')
xlabel('time, d')
ylabel('weight, kg')

%% multiplot(0,0)
