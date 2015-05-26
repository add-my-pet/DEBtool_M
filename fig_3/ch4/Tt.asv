%% fig:Tt
%% bib:Furn87,Broo90,MahoThre81
%% out:furn87,kort86,thom87,MahoThre81
%% weight^1/3 in g^1/3 against age in d

%% Catharacta skua: Furness
%% bib:Furn87
%% out:furn87
aL_Cs = [0.1726983729 4.131729561;
	1.000542267 4.305226659;
	1.806074327 4.383972866;
	3.14008051 4.702603757;
	3.937065319 4.942841413;
	4.896029257 5.233474555;
	6.039189298 5.604104046;
	6.912984906 5.870981223;
	8.002784308 6.185442436;
	8.974848804 6.483980582;
	9.776956084 6.827408599;
	10.97679688 7.166118297;
	11.98000505 7.356082457;
	12.81638639 7.693935249;
	13.91843261 7.92799029;
	14.81472977 8.095386885;
	15.72630928 8.379800523;
	16.91466215 8.590353917;
	17.77839274 8.724264367;
	18.84939015 8.934938063;
	19.95779202 9.252068436;
	20.78563592 9.288002117;
	21.9763603 9.510052744;
	22.95716177 9.600263234;
	23.8549767 9.745589782;
	25.03203137 9.891756966;
	25.9173149 9.995039893;
	26.8489394 9.95963228;
	27.94443043 10.17788737;
	28.94575119 10.04389226;
	30.01608457 10.19214202;
	30.98587241 10.26576264;
	31.94085221 10.26612317;
	33.16728337 10.32330853;
	34.06063985 10.37204077;
	34.89570295 10.33930537;
	35.94001514 10.58390152;
	36.82986178 10.57157766;
	38.07026685 10.3131927;
	39.12484358 10.36677911;
	39.96853899 10.48375884;
	41.12737062 10.48383203;
	41.88088969 10.1477033;
	43.00305615 10.44876148;
	44.10985519 10.47659551;
	44.97967645 10.30195949];

%% Stercorarius longicaudus
%% bib:de Korte in Furn87
%% out:kort86
aL_Sl = [0 3.081281722;
       1 3.311848597;
       2 3.509181425;
       3 3.879858368;
       4 4.167981058;
       5 4.444598701;
       6 4.728536521;
       7 5.012660538;
       8 5.184741786;
       9 5.373463327;
       10 5.581783383;
       11 5.780587937;
       12 5.914288539;
       13 5.903912781;
       14 5.898428369;
       15 6.195324132;
       16 6.056694572;
       17 6.093795611;
       18 6.286891938;
       19 6.171639388;
       21 6.407371402;
       22 6.276260807;
       23 6.1402491;
       24 6.480897777;
       25 6.261591021];

%% Puffinus puffinus
%% bib:Thompson in Broo90
%% out:thom87
aL_Pp = [3 4.471765429;
	 8 5.36579079;
	 13 6.104801301;
	 18 6.747073291;
	 23 7.445423498;
	 28 7.739824005;
	 33 7.981439102;
	 38 8.175886285;
	 43 8.259555323;
	 49 8.345081686;
	 53 8.334731897;
	 58 8.327317198;
	 63 8.398638046;
	 69 8.161025797;
	 74 7.982571161];
aL_Pp = [aL_Pp, [ones(13,1);0;0]]; % ignore last 2 data points

%% Uria aalge:
%% bib:MahoThre81
%% out:MahoThre81
aL_Ua =  [23 6.3866;
	  21 6.2743;
	  19 6.1797;
	  17 6.0641;
	  15 5.9972;
	  13 5.7790;
	  11 5.7989;
	   9 5.3485;
	   7 5.3015;
	   5 4.8203;
	   3 4.5160;
	   1 4.2078];

%% Uria aalge: mean body temperature
aT_Ua = [ ...
  23  39.0500;
  22  39.0500;
  21  38.8500;
  20  38.5500;
  19  38.5500;
  18  38.5500;
  17  38.6500;
  16  38.3500;
  15  38.7500;
  14  38.0500;
  13  37.9500;
  12  37.9500;
  11  37.8500;
  10  37.9500;
   9  37.6500;
   8  36.8500;
   7  36.6500;
   6  37.1500;
   5  36.2500;
   4  32.0500;
   3  33.2500;
   2  29.8500;
   1  22.8500];
aT_Ua = [aT_Ua, .01*ones(23,1)];

%% Uria aalge: standard deviation of body temperature
aT_Ua_sd = [ ...
   1  22.8500;% 1
   1  39.8500;% 2
   2  29.8500;% 3
   2  38.9500;% 4
   2  29.8500;% 5
   2  20.7500;% 6
   3  33.2500;% 7
   3  38.6500;% 8
   3  33.2500;% 9
   3  27.8500;%10
   4  32.0500;%11
   4  39.7500;%12
   4  32.0500;%13
   4  24.3500;%14
   5  36.2500;%15
   5  40.7500;%16
   5  36.2500;%17
   5  31.7500;%18
   6  37.1500;%19
   6  40.3500;%20
   6  37.1500;%21
   6  33.9500;%22
   7  36.6500;%23
   7  39.3500;%24
   7  36.6500;%25
   7  33.9500;%26
   8  36.8500;%27
   8  39.0500;%28
   8  36.8500;%29
   8  34.6500;%30
   9  37.6500;%31
   9  39.5500;%32
   9  37.6500;%33
   9  35.7500;%34
  10  37.9500;%35
  10  39.3500;%36
  10  37.9500;%37
  10  36.5500;%38
  11  37.8500;%39
  11  39.3500;%40
  11  37.8500;%41
  11  36.3500;%42
  12  37.9500;%43
  12  38.5500;%44
  12  37.9500;%45
  12  37.3500;%46
  13  37.9500;%47
  13  38.5500;%48
  13  37.9500;%49
  13  37.3500;%50
  14  38.0500;%51
  14  39.5500;%52
  14  38.0500;%53
  14  36.5500;%54
  15  38.7500;%55
  15  40.2500;%56
  15  38.7500;%57
  15  37.2500;%58
  16  38.3500;%59
  16  38.9500;%60
  16  38.3500;%61
  16  37.7500;%62
  17  38.6500;%63
  17  40.1500;%64
  17  38.6500;%65
  17  37.1500;%66
  18  38.5500;%67
  18  40.1500;%68
  18  38.5500;%69
  18  36.9500;%70
  19  38.5500;%71
  19  39.4500;%72
  19  38.5500;%73
  19  37.6500;%74
  20  38.5500;%75
  20  39.5500;%76
  20  38.5500;%77
  20  37.5500;%78
  21  38.8500;%79
  21  40.4500;%80
  21  38.8500;%81
  21  37.2500];%82

par_txt = {'length at birth'; 'ultimate length'; ...
	   'von Ber growth r'; 'shape par'; 'ult body Temp'; ...
	   'Arrhenius Temp'};
p_Cs = [4 1; 10 1; .16 1; -2.51 1; 312 0; 10000 0];
p_Cs = [4 1; 10 1; .16 1; -1.159 0; 312 0; 10000 0];
p_Cs = nmregr('gen_logist', p_Cs, aL_Cs);
[cov cor sd] = pregr('gen_logist', p_Cs, aL_Cs);
fprintf('Catharacta skua \n');
printpar(par_txt, p_Cs, sd);

a_Cs = linspace(0,45,100)';
[L_Cs T_Cs] = gen_logist(p_Cs(:,1), a_Cs, a_Cs);

p_Sl = [3 1; 6 1; .26 1; -2.54 1; 312 0; 10000 0];
p_Sl = nmregr('gen_logist', p_Sl, aL_Sl);
[cov cor sd] = pregr('gen_logist', p_Sl, aL_Sl);
fprintf('Stercorarius longicaudus \n');
printpar(par_txt, p_Sl, sd);

a_Sl = linspace(0,25,100)';
[L_Sl T_Sl] = gen_logist(p_Sl(:,1), a_Sl, a_Sl);

p_Pp = [4 1; 8 1; .14 1; -2.483 1; 312 0; 10000 0];
p_Pp = nmregr('gen_logist', p_Pp, aL_Pp);
[cov cor sd] = pregr('gen_logist', p_Pp, aL_Pp);
fprintf('Puffinus puffinus \n');
printpar(par_txt, p_Pp, sd);

a_Pp = linspace(0,75,100)';
[L_Pp T_Pp] = gen_logist(p_Pp(:,1), a_Pp, a_Pp);

p_Ua = [4 1; 6 1; .125 1; -.883 1; 312 0; 8225 0];
p_Ua = nmregr('gen_logist', p_Ua, aL_Ua, aT_Ua);
[cov cor sd] = pregr('gen_logist', p_Ua, aL_Ua, aT_Ua);
fprintf('Uria aalge \n');
printpar(par_txt, p_Ua, sd);

a_Ua = linspace(0,24,100)';
[L_Ua T_Ua] = gen_logist(p_Ua(:,1), a_Ua, a_Ua);

%% gset term postscript color solid  'Times-Roman' 35
%% multiplot(2,2)
%% gset nokey

figure
subplot(2,2,1); 
hold on;
[AX, H1, H2] = plotyy(a_Cs, L_Cs, a_Cs, T_Cs);
plot(aL_Cs(:,1), aL_Cs(:,2), '.g');
title('Great skua, Catharacta skua');
xlabel('age,d');
set(H1, 'LineStyle', '-'); set(H1, 'Color', 'g'); 
set(H2, 'LineStyle', '-'); set(H2, 'Color', 'r');
set(get(AX(1), 'Ylabel'), 'String', 'weight^1/3, g^1/3', 'color', 'g')
set(get(AX(2), 'Ylabel'), 'String', 'body temperature, C', 'color' ,'r')
set(AX(1),'YLim',[3,12],'YTick',[3:3:12])
set(AX(2),'YLim',[25,40],'YTick',[25:5:40])
%% set y2range [20:40]

subplot(2,2,2); hold on;
[AX, H1, H2] = plotyy(a_Sl, L_Sl, a_Sl, T_Sl);
plot(aL_Sl(:,1), aL_Sl(:,2), '.g');
set(H1, 'LineStyle', '-'); set(H1, 'Color', 'g'); 
set(H2, 'LineStyle', '-'); set(H2, 'Color', 'r');
title('Long-tailed skua, Stercorarius longecaudus')
xlabel('age,d')
set(get(AX(1), 'Ylabel'), 'String', 'weight^1/3, g^1/3', 'color' ,'g')
set(get(AX(2), 'Ylabel'), 'String', 'body temperature, C', 'color', 'r')
%% set y2range [20:40]


subplot(2,2,3); hold all;
[AX, H1, H2] = plotyy(a_Pp, L_Pp, a_Pp, T_Pp); 
plot(aL_Pp(:,1), aL_Pp(:,2), '.g');
set(H1, 'LineStyle', '-'); set(H1, 'Color', 'g');
set(H2, 'LineStyle', '-'); set(H2, 'Color', 'r');
title('Manx shearwater, Puffinus puffinus')
xlabel('age,d')
set(get(AX(1), 'Ylabel'), 'String', 'weight^1/3, g^1/3', 'color' , 'g')
set(get(AX(2), 'Ylabel'), 'String', 'body temperature, C', 'color', 'r')
ylabel('weight^1/3, g^1/3')
%% set y2range [20:40]

subplot(2,2,4); 
hold on;
H = plot(aL_Ua(:,1), aL_Ua(:,2),'.g',a_Ua, L_Ua,'g');
[A, HL, H2] = plotyy(0,0,aT_Ua(:,1), aT_Ua(:,2));
[A0 HL0, H4] = plotyy(0,0,a_Ua, T_Ua);
[A1, HL1, HT1] = plotyy(0,0, aT_Ua_sd( 1:2 ,1), aT_Ua_sd( 1:2 ,2));
[A2, HL2, HT2] = plotyy(0,0, aT_Ua_sd( 3:6 ,1), aT_Ua_sd( 3:6 ,2));
[A3, HL3, HT3] = plotyy(0,0, aT_Ua_sd( 7:10,1), aT_Ua_sd( 7:10,2));
[A4, HL4, HT4] = plotyy(0,0, aT_Ua_sd(11:14,1), aT_Ua_sd(11:14,2));
[A5, HL5, HT5] = plotyy(0,0, aT_Ua_sd(15:18,1), aT_Ua_sd(15:18,2)); 
[A6, HL6, HT6] = plotyy(0,0, aT_Ua_sd(19:22,1), aT_Ua_sd(19:22,2)); 
[A7, HL7, HT7] = plotyy(0,0, aT_Ua_sd(23:26,1), aT_Ua_sd(23:26,2)); 
[A8, HL8, HT8] = plotyy(0,0, aT_Ua_sd(27:30,1), aT_Ua_sd(27:30,2)); 
[A9, HL9, HT9] = plotyy(0,0, aT_Ua_sd(31:34,1), aT_Ua_sd(31:34,2)); 
[A10, HL10, HT10] = plotyy(0,0, aT_Ua_sd(35:38,1), aT_Ua_sd(35:38,2)); 
[A11, HL11, HT11] = plotyy(0,0, aT_Ua_sd(39:42,1), aT_Ua_sd(39:42,2));
[A12, HL12, HT12] = plotyy(0,0, aT_Ua_sd(43:46,1), aT_Ua_sd(43:46,2)); 
[A13, HL13, HT13] = plotyy(0,0, aT_Ua_sd(47:50,1), aT_Ua_sd(47:50,2)); 
[A14, HL14, HT14] = plotyy(0,0, aT_Ua_sd(51:54,1), aT_Ua_sd(51:54,2));
[A15, HL15, HT15] = plotyy(0,0, aT_Ua_sd(55:58,1), aT_Ua_sd(55:58,2)); 
[A16, HL16, HT16] = plotyy(0,0, aT_Ua_sd(59:62,1), aT_Ua_sd(59:62,2)); 
[A17, HL17, HT17] = plotyy(0,0, aT_Ua_sd(63:66,1), aT_Ua_sd(63:66,2)); 
[A18, HL18, HT18] = plotyy(0,0, aT_Ua_sd(67:70,1), aT_Ua_sd(67:70,2)); 
[A19, HL19, HT19] = plotyy(0,0, aT_Ua_sd(71:74,1), aT_Ua_sd(71:74,2)); 
[A20, HL20, HT20] = plotyy(0,0, aT_Ua_sd(75:78,1), aT_Ua_sd(75:78,2)); 
[A21, HL21, HT21] = plotyy(0,0, aT_Ua_sd(79:82,1), aT_Ua_sd(79:82,2));
set(get(A(1), 'Ylabel'), 'String', 'weight^1/3, g^1/3', 'color' ,'g')
set(get(A(2), 'Ylabel'), 'String', 'body temperature, C', 'color' , 'r')
set(H2, 'LineStyle', 'none', 'Marker', '.', 'Color', 'r');
set(H4, 'LineStyle', '-', 'Color', 'r');
ylimits = get(A(2),'YLim'); yinc= (ylimits(2)-ylimits(1))/4;
yticks = [ylimits(1):yinc:ylimits(2)];
set(HT1, 'LineStyle', '-', 'Color', 'r');
set(HT2, 'LineStyle', '-', 'Color', 'r');
set(HT3, 'LineStyle', '-', 'Color', 'r');
set(HT4, 'LineStyle', '-', 'Color', 'r');
set(HT5, 'LineStyle', '-', 'Color', 'r');
set(HT6, 'LineStyle', '-', 'Color', 'r');
set(HT7, 'LineStyle', '-', 'Color', 'r');
set(HT8, 'LineStyle', '-', 'Color', 'r');
set(HT9, 'LineStyle', '-', 'Color', 'r');
set(HT10, 'LineStyle', '-', 'Color', 'r');
set(HT11, 'LineStyle', '-', 'Color', 'r');
set(HT12, 'LineStyle', '-', 'Color', 'r');
set(HT13, 'LineStyle', '-', 'Color', 'r');
set(HT14, 'LineStyle', '-', 'Color', 'r');
set(HT15, 'LineStyle', '-', 'Color', 'r');
set(HT16, 'LineStyle', '-', 'Color', 'r');
set(HT17, 'LineStyle', '-', 'Color', 'r');
set(HT18, 'LineStyle', '-', 'Color', 'r');
set(HT19, 'LineStyle', '-', 'Color', 'r');
set(HT20, 'LineStyle', '-', 'Color', 'r');
set(HT21, 'LineStyle', '-', 'Color', 'r');
set(A0(2),'YTick', yticks,'YLim',ylimits);
set(A1(2),'YTick', yticks,'YLim',ylimits);
set(A2(2),'YTick', yticks,'YLim',ylimits);
set(A3(2),'YTick', yticks,'YLim',ylimits);
set(A4(2),'YTick', yticks,'YLim',ylimits);
set(A5(2),'YTick', yticks,'YLim',ylimits);
set(A6(2),'YTick', yticks,'YLim',ylimits);
set(A7(2),'YTick', yticks,'YLim',ylimits);
set(A8(2),'YTick', yticks,'YLim',ylimits);
set(A9(2),'YTick', yticks,'YLim',ylimits);
set(A10(2),'YTick', yticks,'YLim',ylimits);
set(A11(2),'YTick', yticks,'YLim',ylimits);
set(A12(2),'YTick', yticks,'YLim',ylimits);
set(A13(2),'YTick', yticks,'YLim',ylimits);
set(A14(2),'YTick', yticks,'YLim',ylimits);
set(A15(2),'YTick', yticks,'YLim',ylimits);
set(A16(2),'YTick', yticks,'YLim',ylimits);
set(A17(2),'YTick', yticks,'YLim',ylimits);
set(A18(2),'YTick', yticks,'YLim',ylimits);
set(A19(2),'YTick', yticks,'YLim',ylimits);
set(A20(2),'YTick', yticks,'YLim',ylimits);
set(A21(2),'YTick', yticks,'YLim',ylimits);
set(A(1),'YTick',[3:7],'YLim',[3,7])
title('Guillemot, Uria aalge')
xlabel('age,d')


%% set y2range [20:40]
