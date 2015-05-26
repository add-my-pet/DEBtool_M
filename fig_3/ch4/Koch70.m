%% fig:Koch70,BremDenn87
%% bib:Koch70,BremDenn87
%% out:Koch70,BremDenn87

%% RNA content as function of specific growth rate

%% total RNA content
rRNA = [0.02640423234 0.07097107574;
	0.0298742765  0.07905637443;
	0.03058176427 0.08353938607;
	0.02946383908 0.08565883216;
	0.0306453518  0.08746694089;
	0.02964842804 0.09270286927;
	0.03016896042 0.09580542115;
	0.05621440624 0.1083047539;
	0.05732142495 0.1127738352;
	0.07032989703 0.1043451445;
	0.06820033442 0.1078868416;
	0.09783394432 0.09945639123;
	0.1001310158  0.1048086312;
	0.1656958644  0.1196286531;
	0.1664522261  0.1242255422;
	0.3887898053  0.1490673071;
	0.3849363846  0.1608753983;
	0.3849107645  0.1636502482;
	0.3846640287  0.1687444383;
	0.5147436061  0.155309187;
	0.6806875425  0.1885897898;
	0.6898867349  0.2034102224;
	0.7529466694  0.2029452399;
	0.7468383624  0.1669811997;
	1.181721258   0.255263641;
	1.373104192   0.2693953831;
	1.420646008   0.2734012415;
	1.374975187   0.2992657629];

%% scaled elongation rate (for scaled growth rate)
re = [1.00000  1.00000;
      0.80347  0.95238;
      0.59537  0.85714;
      0.39885  0.76190;
      0.23700  0.57143];

rmax = [1.73 1.73 10]; % max spec growth rate

nmregr_options('report',0);
nmregr_options('max_step_number',500);
%% p = [.044 1; .087 1; 20.7 1; 0.05 1; .06 1; .24 1];
p = [0. 0; .087 1; 2.7 1; 0.88 1; 10 0; .27 1];
p = nmregr('RNAdensity', p, rRNA, re, rmax);
nrregr_options('report',1);

[cov cor sd] = pregr('RNAdensity', p, rRNA, re, rmax);
par_txt = {'theta_v '; 'theta_e '; 'rel contrib of reserve w'; ...
	   'maint rate coef kM'; 'investment ratio g'; ...
	   'scaled length at division ld'};
printpar(par_txt,p,sd)

rR = linspace(0,1.5,100)';
rE = linspace(0,1,100)';
[RNA elong rMAX]= RNAdensity(p(:,1), rR, rE, rmax);
rMAX

%% gset term postscript color solid  'Times-Roman' 35
subplot(1,2,1); 
plot(rRNA(:,1), rRNA(:,2), '.g', rR, RNA, '-r');
xlabel('spec growth rate, 1/h');
ylabel('RNA/dry weigth, mug/ mug');

subplot(1,2,2);
plot(re(:,1), re(:,2), '.g', rE, elong, '-r');
xlabel('scaled spec growth rate');
ylabel('scaled elongation rate');
