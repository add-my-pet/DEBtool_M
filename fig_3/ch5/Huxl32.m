%% fig:Huxl32
%% bib:Huxl32
%% out:Huxl32b,Huxl32u.ps

%% growth of body parts

%% head length (m) versus body-head length (m) for Balaenoptera musculus
LL_Bm = log10 ([1.5 0.21675;
	 2.5 0.369;
	 3.5 0.5376;
	 4.5 0.6822;
	 17.5 2.76675;
	 18.5 2.9674;
	 19.5 3.2331;
	 20.5 3.5178;
	 21.5 3.76035;
	 22.5 3.987;
	 23.5 4.3334;
	 24.5 4.6697;
	 25.5 4.7736;
	 26.5 5.03765]);

%% chela weight (mg) versus body-chela weight (mg) for Uca pugnax
WW_Up = log10 ([57.6 5.3;
	 80.3 9;
	 109.2 13.7;
	 156.1 25.1;
	 199.7 38.3;
	 238.3 52.5;
	 270 59;
	 300.2 78.1;
	 355.2 104.5;
	 420.1 135;
	 470.1 164.9;
	 535.7 195.6;
	 617.9 243;
	 680.6 271.6;
	 743.3 319.2;
	 872.4 417.6;
	 983.1 460.8;
	 1079.9 537;
	 1165.5 593.8;
	 1211.7 616.8;
	 1291.3 670;
	 1363.2 699.3;
	 1449.1 777.8;
	 1807.9 1009.1;
	 2235 1380]);

nrregr_options('report',1)
p_Bm = nrregr('bilinear', [-1 1; 1 0; 1.2 1; 1.65 1], LL_Bm);
L_B = [.1; p_Bm(3,1);1.5]; L_Bm = bilinear(p_Bm(:,1), L_B);

nrregr_options('max_step_number',1000)
p_Up = nrregr('bilinear', [0 1; 1.63 1; 2.9 1; 1.23 1], WW_Up);
W_U = [1.7; p_Up(3,1);3.4]; W_Up = bilinear(p_Up(:,1), W_U);

%% gset term postscript color solid 'Times-Roman' 35

subplot(1,2,1);
%% gset output 'Huxl32b.ps'
plot(LL_Bm(:,1), LL_Bm(:,2), 'og', L_B, L_Bm, 'r')
title('male blue whale Balaenoptera musculus')
xlabel('10-log body - head length, m')
ylabel('10-log head length, m')

subplot(1,2,2);
%% gset output 'Huxl32u.ps'
plot(WW_Up(:,1), WW_Up(:,2), 'og', W_U, W_Up, 'r')
title('male fiddler crab Uca pugnax')
xlabel('10-log body - chela weight, mg')
ylabel('10-log chela weight, mg')

