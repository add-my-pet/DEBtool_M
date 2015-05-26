%% fig:GillSalo94
%% bib:GillSalo94
%% out:gillsalo94_cross_h,gillsalo94_cross_w
%%     gillsalo94_line_20_h,gillsalo94_line_20_w
%%     gillsalo94_mallard_h,gillsalo94_mallard_w
%%     gillsalo94_muscovy_h,gillsalo94_muscovy_w
%%     gillsalo94_nf_20_h,gillsalo94_nf_20_w

%% static generalisation of \kappa-rule
%% growth of body parts: heart

Line_20 = [ ...
  0   77.266;
  7  134.555;
 14  443.385;
 21  732.860;
 28 1061.123;
 35 1408.665;
 42 1678.784;
 56 2257.734;
 70 2449.655;
 84 2370.524;
112 2541.302;
154 2033.010];

Line_20_heart = [ ...
  0  0.515;
  7  1.542;
 14  3.343;
 21  5.402;
 28  6.687;
 35  8.230;
 42  9.385;
 56 12.987;
 70 16.847;
 84 15.158;
112 17.974;
154 16.908];


NF_20 = [ ...
  0   58.294;
  7  136.251;
 14  466.123;
 21  738.009;
 28 1532.385;
 35 1726.854;
 42 2056.572;
 56 2155.040;
 70 2737.367;
 84 2584.228;
112 2761.810;
154 2457.153];

NF_20_heart =[ ...
  0  0.513;
  7  1.409;
 14  3.462;
 21  4.998;
 28  9.890;
 35 10.653;
 42 13.482;
 56 15.008;
 70 14.727;
 84 16.510;
112 17.239;
154 15.364];

Mallard = [ ...
  0   34.043;
  7  102.128;
 14  229.787;
 21  536.170;
 28  655.319;
 35  782.979;
 40  757.447;
 56  995.745;
 70  808.511;
 84 1055.319;
112 1131.915;
154 1200.000];

Mallard_heart = [ ...
  0  0.367;
  7  1.102;
 14  2.021;
 21  3.488;
 28  4.134;
 35  5.602;
 42  6.063;
 56  7.718;
 70  6.994;
 84  8.832;
112 11.593;
154 11.434];

Muscovy = [ ...
  0   49.88;
  7  100.44;
 14  275.41;
 21  425.73;
 28  724.83;
 35 1173.09;
 42 1422.70;
 56 2393.76;
 70 2843.08;
 84 2621.70;
112 2949.01;
154 3725.65];

Muscovy_heart = [ ...
 0   0.357;
 7   1.071;
 14  1.964;
 21  2.857;
 28  4.286;
 35  6.429;
 42  8.929;
 56 13.929;
 70 16.964;
 84 16.607;
112 22.143;
154 25.357];

Cross = [ ...
  0   40.27;
  7  140.94;
 14  362.42;
 21  765.10;
 28 1228.19;
 35 1389.26;
 42 1791.95;
 56 2436.24;
 70 2416.11;
 84 2536.91;
112 2657.72;
154 2758.39];

Cross_heart = [ ...
  0  0.298;
  7  1.488;
 14  3.125;
 21  6.250;
 28  6.101;
 35  8.482;
 42 12.500;
 56 16.369;
 70 16.667;
 84 20.536;
112 23.363;
154 22.321];	 

switch 1
  case 1 % Line_20
    L0 = .8*Line_20(1,2)^(1/3);
    p_Line_20 = [L0 0; .212 1; 0.00017 1; 2.17 1; 0.75 1; 7.015 1; .823 1;
		 .05 1; -.71 1; -0.003 1];
    %% ssq 27.6
    p = p_Line_20; tW = Line_20; tWH = Line_20_heart;
    t_txt = 'Line 20';
  case 2 % NF_20
    L0 = .6*NF_20(1,2)^(1/3);
    NF_20 = [NF_20,ones(12,1)]; NF_20(12,3) = 100;
    p_NF_20 = [L0 0; .297 1; 0.00026 1; 3.39 1; 0.524 1; .1044 1;
	       .676 1; .00093 1; -.6 1; -.12 1];
    %% ssq 39.4
    p = p_NF_20; tW = NF_20; tWH = NF_20_heart;
    t_txt = 'NF 20';
  case 3 % Mallard
    L0 = Mallard(1,2)^(1/3);
    p_Mallard = [L0 0; .228 1; 0.00028 1; 2.070 1; 0.588 1; 3.410 1;
		 .745 1; .037 1; -.6 1; -.1 1];
    %% ssq 3415
    p = p_Mallard; tW = Mallard; tWH = Mallard_heart;
    t_txt = 'Mallard';
  case 4 % Muscovy
    L0 = .8*Muscovy(1,2)^(1/3);
    p_Muscovy = [L0 0; .22 1; 0.00232 1; 1.585 1; 0.308 1; 2.877 1;
		 .75 1; .043 1; -.62 1; -.11 1];
    %% ssq 1.817e4
    p = p_Muscovy; tW = Muscovy; tWH = Muscovy_heart;
    t_txt = 'Muscovy';
  case 5 % Cross
    L0 = Cross(1,2)^(1/3);
    p_Cross = [L0 0; .24 1; 0.00008 1; 2.99 1; 0.416 1; 4.053 1;
	       .66 1; .05 8; -.6 1; -.1 1];
    %% ssq 3372
    p = p_Cross; tW = Cross; tWH = Cross_heart;
    t_txt=  'Cross';
  otherwise
end

al = log10([tW(:,2), tWH(:,2) ./ tW(:,2)] .^ (1/3));
al = [al,10000*(ones(12,1))];
%% p = nmregr("body_heart", p, tW, tWH, al)

tm = 1.1 * max([tW(:,1); tWH(:,1)]);
t = linspace(0,tm,100)';
Wmin = .8*min(tW(:,2)); Wmax = 1.1*max(tW(:,2));
lnL = log10(linspace(Wmin^(1/3),Wmax^(1/3),100)');
[W WH al] = body_heart(p(:,1),t,t,lnL);

%% gset term postscript color solid "Times-Roman" 35

subplot(1,3,1); 
%% gset output "gillsalo94_cross_w.ps"
plot(tW(:,1), tW(:,2), 'ob', t, W, 'r')
xlabel('time, d')
ylabel('body weight, g')
title(t_txt);

subplot(1,3,2);
%% gset output 'gillsalo94_cross_h.ps'
plot(tWH(:,1), tWH(:,2), 'ob', t, WH, 'r')
xlabel('time, d')
ylabel('heart weight, g')
title(t_txt);

subplot(1,3,3);
plot(log10(W .^ (1/3)), log10((WH ./ W) .^ (1/3)),'r', ...
     log10(tW(:,2).^(1/3)), log10((tWH(:,2)./tW(:,2)).^(1/3)), 'ob', ...
     lnL, al, 'm')
xlabel('log body weight, d')
ylabel('log heart weight, g')
title(t_txt);
