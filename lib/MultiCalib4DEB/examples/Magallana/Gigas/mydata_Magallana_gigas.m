function [data, auxData, metaData, txtData, weights] = mydata_Magallana_gigas

global tN2 tN3 tN4 tN5 tN6 tN7 % d,cells/dm^3
% these tX data for tL, tWw and tJX are global, because, if passed as auxiliary, no in-between times are plotted and errors result 

%% set metaData
metaData.phylum     = 'Mollusca'; 
metaData.class      = 'Bivalvia'; 
metaData.order      = 'Ostreoida'; 
metaData.family     = 'Ostreidae';
metaData.species    = 'Magallana_gigas'; 
metaData.species_en = 'Pacific oyster'; 

metaData.ecoCode.climate = {'MC'};
metaData.ecoCode.ecozone = {'MPE', 'MPSE', 'MAN'};
metaData.ecoCode.habitat = {'0jMp', 'jiMb'};
metaData.ecoCode.embryo  = {'Mp'};
metaData.ecoCode.migrate = {};
metaData.ecoCode.food    = {'biPp'};
metaData.ecoCode.gender  = {'D'};
metaData.ecoCode.reprod  = {'O'};

metaData.T_typical  = C2K(10); % K, body temp
metaData.data_0     = {'ab'; 'aj'; 'ap'; 'am'; 'Lb'; 'Lj'; 'Lp'; 'Li'; 'Wdb'; 'Wdj'; 'Wwp'; 'Wwi'; 'Ri'; 'GSI'; 'K'}; 
metaData.data_1     = {'t-L_fT'; 't-Ww_f'; 't-Wd_f'; 't-F_f'; 't-JX'; 't-WwR'; 'L-JO'; 'L-Wd'}; 

metaData.COMPLETE = 3.3; % using criteria of LikaKear2011

metaData.author   = {'Antoine Emmery'; 'Bas Kooijman'};    
metaData.date_subm = [2011 07 20];              
metaData.email    = {'bas.kooijman@vu.nl'};            
metaData.address  = {'VU University Amsterdam'};   

metaData.curator     = {'Starrlight Augustine'};
metaData.email_cur   = {'starrlight.augustine@akvaplan.niva.no'}; 
metaData.date_acc    = [2015 12 22]; 


%% set data
% zero-variate data

data.ab = 5.5;    units.ab = 'd';    label.ab = 'age at birth';             bibkey.ab = 'RicoPouv2009';   
  temp.ab = C2K(25);  units.temp.ab = 'K'; label.temp.ab = 'temperature';
data.tj = 14.5;   units.tj = 'd';    label.tj = 'time since birth at metam'; bibkey.tj = 'RicoBern2010';   
  temp.tj = C2K(25);  units.temp.tj = 'K'; label.temp.tj = 'temperature';
data.tp = 26.6;   units.tp = 'd';    label.tp = 'time since birth at puberty'; bibkey.tp = 'Mark2011';
  temp.tp = C2K(25);  units.temp.tp = 'K'; label.temp.tp = 'temperature';
data.am = 30*365; units.am = 'd';    label.am = 'life span';                bibkey.am = 'Wiki';   
  temp.am = C2K(7.8); units.temp.am = 'K'; label.temp.am = 'temperature'; 

data.Lb  = 0.01;  units.Lb  = 'cm';  label.Lb  = 'shell length at birth';   bibkey.Lb  = 'RicoPouv2009';
data.Lj  = 0.034; units.Lj  = 'cm';  label.Lj  = 'shell length at metam';   bibkey.Lj  = 'RicoBern2010';
data.Lp  = 0.588; units.Lp  = 'cm';  label.Lp  = 'shell length at puberty'; bibkey.Lp  = 'Mark2011';
data.Li  = 45;    units.Li  = 'cm';  label.Li  = 'ultimate shell length';   bibkey.Li  = 'VeerCard2006';

data.Wdb = 5e-8;  units.Wdb = 'g';   label.Wdb = 'dry weight at birth';     bibkey.Wdb = 'RicoBern2010';
data.Wdj = 2e-6;  units.Wdj = 'g';   label.Wdj = 'dry weight at metam';     bibkey.Wdj = 'RicoBern2010';
data.Wwp = 2.9e-3;units.Wwp = 'g';   label.Wwp = 'wet weight at puberty';   bibkey.Wwp = 'Mark2011';
data.Wwi = 1430.6;units.Wwi = 'g';   label.Wwi = 'ultimate wet weight';     bibkey.Wwi = 'PouvBour2006';

data.Ri  = 2.7e6; units.Ri  = '#/d'; label.Ri  = 'maximum reprod rate';     bibkey.Ri  = 'PouvBour2006';   
  temp.Ri = C2K(7.8); units.temp.Ri = 'K'; label.temp.Ri = 'temperature';

data.GSI  = 0.64; units.GSI  = '-'; label.GSI  = 'gonado somatic index';    bibkey.GSI  = 'DuteBeni2009';   
  temp.GSI = C2K(7.8);units.temp.GSI = 'K'; label.temp.GSI = 'temperature';

data.KV  = 6e8;   units.KV  = 'µm^3/dm^3'; label.KV  = 'half saturation coefficient';  bibkey.KV  = 'RicoBern2010';   

% uni-variate data

 % univariate data by Antoine Emmery at T = 273 + 14.3 K
 % experiments starts with a = 260 d at T = 273 + 7.8 K
 % this is after puberty, so allocation to reproduction occurs
 % food Skeletonema costata 
 %   85 µm3; 5e-11 g/cell GonzQuea2011 
 %   15.2 J/mg dry weight Bourles 2004, Ifremer Argeton, pers com
 
% time-length/weight data at low food level
BAC2 = [... %	time(d), shell-length (mm), total wet mass (including shell, g), shell mass (g), wet weight(g), dry weight (g)   
0	18.56066667	0.896766667	0.618533333	0.083633333	0.013035714
2	16.3405	0.6996	0.48545	0.0725	0.01415
4	17.3215	0.7087	0.54405	0.05525	0.01015
8	16.2225	0.68975	0.56465	0.051666667	0.011894737
16	16.0175	0.7075	0.5567	0.05575	0.0109
30	17.3285	0.79845	0.5794	0.0606	0.0125
50	18.559	0.9572	0.7251	0.068877778	0.013035
59	18.85307692	0.979461538	0.7322	0.1115	0.020785
65	21.0135	1.1091	0.8413	0.1391	0.02865
85	26.2585	1.83675	1.26855	0.2367	0.042345
108	29.691	2.7202	1.933769231	0.27545	0.049268421
129	28.76	2.890533333	2.0568	0.228333333	0.039596667
187	28.65066667	2.897	2.109633333	0.207533333	0.036265517
211	28.49366667	2.9527	2.279833333	0.185966667	0.025603333];
data.tL2  = BAC2(:,[1 2]); data.tL2(:,2) = data.tL2(:,2)/ 10; % convert mm to cm
units.tL2   = {'d', 'cm'};  label.tL2 = {'time', 'shell length'};  
temp.tL2    = C2K(14.3);  units.temp.tL2 = 'K'; label.temp.tL2 = 'temperature';
bibkey.tL2 = 'Emme2012';
%
data.tWw2 = BAC2(:,[1 5]);
units.tWw2   = {'d', 'g'};  label.tWw2 = {'time', 'wet weight'};  
temp.tWw2    = C2K(14.3);  units.temp.tWw2 = 'K'; label.temp.tWw2 = 'temperature';
bibkey.tWw2 = 'Emme2012';
comment.tWw2 = 'wet mass excludes body fluids; DW/WW is around 0.2, with body fluids possibly around 0.1';
%
data.tWd2 = BAC2(:,[1 6]);
units.tWd2   = {'d', 'g'};  label.tWd2 = {'time', 'dry weight'};  
temp.tWd2    = C2K(14.3);  units.temp.tWd2 = 'K'; label.temp.tWd2 = 'temperature';
bibkey.tWd2 = 'Emme2012';

% time-length/weight data at high food level
BAC3 = [... %	time(d), shell-length (mm), total wet mass (including shell, g), shell mass (g), wet weight(g), dry weight (g)					
0	18.56066667	0.896766667	0.618533333	0.083633333	0.013035714
2	16.818	0.69675	0.5114	0.0667	0.01195
4	17.354	0.6852	0.4865	0.06455	0.011214286
8	16.363	0.66245	0.51875	0.05745	0.014
16	16.6245	0.72655	0.52675	0.0743	0.0152
30	18.0795	0.86285	0.6064	0.0827	0.01935
50	20.449	1.12225	0.78655	0.143968421	0.028852941
59	21.7115	1.2078	0.84355	0.17555	0.037165
65	22.5505	NaN	1.072210526	0.19685	0.04535
85	27.4545	2.186	1.498315789	0.31385	0.073885
108	30.605	3.2355	2.2496	0.4896	0.107375
129	31.615	3.754033333	2.616	0.423033333	0.078944828
187	31.56566667	3.933766667	2.757666667	0.376566667	0.070944828
211	31.23233333	3.9942	2.8012	0.298137931	0.057289655];
data.tL3  = BAC3(:,[1 2]); data.tL3(:,2) = data.tL3(:,2)/ 10; % convert mm to cm
units.tL3   = {'d', 'cm'};  label.tL3 = {'time', 'shell length'};  
temp.tL3    = C2K(14.3);  units.temp.tL3 = 'K'; label.temp.tL3 = 'temperature';
bibkey.tL3 = 'Emme2012';
%
data.tWw3 = BAC3(:,[1 5]);
units.tWw3   = {'d', 'g'};  label.tWw3 = {'time', 'wet weight'};  
temp.tWw3    = C2K(14.3);  units.temp.tWw3 = 'K'; label.temp.tWw3 = 'temperature';
bibkey.tWw3 = 'Emme2012';
comment.tWw3 = 'wet mass excludes body fluids; DW/WW is around 0.2, with body fluids possibly around 0.1';
%
data.tWd3 = BAC2(:,[1 6]);
units.tWd3   = {'d', 'g'};  label.tWd3 = {'time', 'dry weight'};  
temp.tWd3    = C2K(14.3);  units.temp.tWd3 = 'K'; label.temp.tWd3 = 'temperature';
bibkey.tWd3 = 'Emme2012';

% time-length/weight data at high food level
BAC4 = [... %	time(d), shell-length (mm), total wet mass (including shell, g), shell mass (g), wet weight(g), dry weight (g)					
0	18.56066667	0.896766667	0.618533333	0.083633333	0.013035714
2	16.8545	0.71215	0.5186	0.0546	0.011368421
4	16.865	0.7056	0.5348	0.05675	0.0129
8	17.164	0.7268	0.52995	0.0698	0.01665
16	16.0895	0.75305	0.57855	0.07185	0.016368421
30	18.9765	0.91905	0.66165	0.09635	0.02075
50	21.3475	1.17835	0.847	0.18845	0.027125
59	21.919	1.27795	0.9039	0.1876	0.040945
65	22.6845	1.43755	1.08955	0.2143	0.05145
85	26.7035	2.2373	1.520684211	0.3551	0.07647
108	30.9675	3.2526	2.19915	0.46145	0.105045
129	31.615	3.754033333	2.616	0.423033333	0.078944828
187	31.56566667	3.933766667	2.757666667	0.376566667	0.06958
211	31.23233333	3.9942	2.8012	0.298137931	0.056846667];
data.tL4  = BAC4(:,[1 2]); data.tL4(:,2) = data.tL4(:,2)/ 10; % convert mm to cm
units.tL4   = {'d', 'cm'};  label.tL4 = {'time', 'shell length'};  
temp.tL4    = C2K(14.3);  units.temp.tL4 = 'K'; label.temp.tL4 = 'temperature';
bibkey.tL4 = 'Emme2012';
%
data.tWw4 = BAC4(:,[1 5]);
units.tWw4   = {'d', 'g'};  label.tWw4 = {'time', 'wet weight'};  
temp.tWw4    = C2K(14.3);  units.temp.tWw4 = 'K'; label.temp.tWw4 = 'temperature';
bibkey.tWw4 = 'Emme2012';
comment.tWw4 = 'wet mass excludes body fluids; DW/WW is around 0.2, with body fluids possibly around 0.1';
%
data.tWd4 = BAC4(:,[1 6]);
units.tWd4   = {'d', 'g'};  label.tWd4 = {'time', 'dry weight'};  
temp.tWd4    = C2K(14.3);  units.temp.tWd4 = 'K'; label.temp.tWd4 = 'temperature';
bibkey.tWd4 = 'Emme2012';

% time-length/weight data at low food level
BAC5= [... %	time(d), shell-length (mm), total wet mass (including shell, g), shell mass (g), wet weight(g), dry weight (g)					
0	18.56066667	0.896766667	0.618533333	0.083633333	0.013035714
2	17.121	0.7219	0.5075	0.056631579	0.011368421
4	17.438	0.68555	0.4957	0.06085	0.0109
8	16.648	0.6801	0.4941	0.05345	0.01125
16	16.6055	0.687	0.50285	0.05055	0.0123
30	17.744	0.8082	0.5832	0.068526316	0.013944444
50	18.604	0.9672	0.7076	0.0816	0.015125
59	20.0215	0.956	0.769315789	0.103578947	0.019984211
65	21.296	1.1304	0.87275	0.13085	0.02605
85	25.1715	1.8827	1.2939	0.2042	0.03714
108	30.609	2.65265	1.85785	0.2598	0.044926316
129	28.76	2.890533333	2.0568	0.228333333	0.039596667
187	28.65066667	2.897	2.109633333	0.207533333	0.036265517
211	28.49366667	2.9527	2.279833333	0.185966667	0.025603333];
data.tL5  = BAC5(:,[1 2]); data.tL5(:,2) = data.tL5(:,2)/ 10; % convert mm to cm
units.tL5   = {'d', 'cm'};  label.tL5 = {'time', 'shell length'};  
temp.tL5    = C2K(14.3);  units.temp.tL5 = 'K'; label.temp.tL5 = 'temperature';
bibkey.tL5 = 'Emme2012';
%
data.tWw5 = BAC5(:,[1 5]);
units.tWw5   = {'d', 'g'};  label.tWw5 = {'time', 'wet weight'};  
temp.tWw5    = C2K(14.3);  units.temp.tWw5 = 'K'; label.temp.tWw5 = 'temperature';
bibkey.tWw5 = 'Emme2012';
comment.tWw5 = 'wet mass excludes body fluids; DW/WW is around 0.2, with body fluids possibly around 0.1';
%
data.tWd5 = BAC5(:,[1 6]);
units.tWd5   = {'d', 'g'};  label.tWd5 = {'time', 'dry weight'};  
temp.tWd5    = C2K(14.3);  units.temp.tWd5 = 'K'; label.temp.tWd5 = 'temperature';
bibkey.tWd5 = 'Emme2012';

% time-length/weight data at  low food level
BAC6= [... %	time(d), shell-length (mm), total wet mass (including shell, g), shell mass (g), wet weight(g), dry weight (g)					
0	18.56066667	0.896766667	0.618533333	0.083633333	0.013035714
2	16.49	0.70285	0.50395	0.04855	0.00945
4	17.062	0.69095	0.5158	0.06435	0.010736842
8	16.82	0.79165	0.57645	0.0726	0.01585
16	17.068	0.79555	0.60855	0.06035	0.012736842
30	18.134	0.9147	0.65075	0.079368421	0.01545
50	19.054	1.06835	0.76435	0.093842105	0.018215789
59	20.379	1.0972	0.81655	0.118611111	0.033205
65	22.359	1.24175	0.97215	0.1323	0.02605
85	25.604	2.0644	1.45975	0.23235	0.049905263
108	30.937	2.9476	2.0226	0.29455	0.05176
129	28.76	2.890533333	2.0568	0.228333333	0.039596667
187	28.65066667	2.897	2.109633333	0.207533333	0.036265517
211	28.49366667	2.9527	2.279833333	0.185966667	0.025603333];
data.tL6  = BAC6(:,[1 2]); data.tL6(:,2) = data.tL6(:,2)/ 10; % convert mm to cm
units.tL6   = {'d', 'cm'};  label.tL6 = {'time', 'shell length'};  
temp.tL6    = C2K(14.3);  units.temp.tL6 = 'K'; label.temp.tL6 = 'temperature';
bibkey.tL6 = 'Emme2012';
%
data.tWw6 = BAC6(:,[1 5]);
units.tWw6   = {'d', 'g'};  label.tWw6 = {'time', 'wet weight'};  
temp.tWw6    = C2K(14.3);  units.temp.tWw6 = 'K'; label.temp.tWw6 = 'temperature';
bibkey.tWw6 = 'Emme2012';
comment.tWw6 = 'wet mass excludes body fluids; DW/WW is around 0.2, with body fluids possibly around 0.1';
%
data.tWd6 = BAC5(:,[1 6]);
units.tWd6   = {'d', 'g'};  label.tWd6 = {'time', 'dry weight'};  
temp.tWd6    = C2K(14.3);  units.temp.tWd6 = 'K'; label.temp.tWd6 = 'temperature';
bibkey.tWd6 = 'Emme2012';

% time-length/weight data at high food level
BAC7= [... %	time(d), shell-length (mm), total wet mass (including shell, g), shell mass (g), wet weight(g), dry weight (g)					
0	18.56066667	0.896766667	0.618533333	0.083633333	0.013035714
2	17.3935	0.7244	0.50835	0.066526316	0.012
4	17.105	0.71665	0.535947368	0.0649	0.012052632
8	16.4925	0.7257	0.53215	0.070631579	0.016333333
16	17.002	0.74765	0.58775	0.07615	0.01925
30	18.787	0.94545	0.67705	0.102842105	0.022157895
50	21.8725	1.224	0.857	0.16065	0.03368
59	22.5115	1.3177	1.014	0.17	0.038115
65	22.435	1.48935	1.1127	0.21005	0.04965
85	27.9285	2.378142857	1.56865	0.36395	0.082055
108	31.55	3.61515	2.3382	0.5041	0.1088985
129	31.615	3.754033333	2.616	0.423033333	0.078944828
187	31.56566667	3.933766667	2.757666667	0.376566667	0.06958
211	31.23233333	3.9942	2.8012	0.298137931	0.056846667];
data.tL7  = BAC7(:,[1 2]); data.tL7(:,2) = data.tL7(:,2)/ 10; % convert mm to cm
units.tL7   = {'d', 'cm'};  label.tL7 = {'time', 'shell length'};  
temp.tL7    = C2K(14.3);  units.temp.tL7 = 'K'; label.temp.tL7 = 'temperature';
bibkey.tL7 = 'Emme2012';
%
data.tWw7 = BAC7(:,[1 5]);
units.tWw7   = {'d', 'g'};  label.tWw7 = {'time', 'wet weight'};  
temp.tWw7    = C2K(14.3);  units.temp.tWw7 = 'K'; label.temp.tWw7 = 'temperature';
bibkey.tWw7 = 'Emme2012';
comment.tWw7 = 'wet mass excludes body fluids; DW/WW is around 0.2, with body fluids possibly around 0.1';
%
data.tWd7 = BAC5(:,[1 6]);
units.tWd7   = {'d', 'g'};  label.tWd7 = {'time', 'dry weight'};  
temp.tWd7    = C2K(14.3);  units.temp.tWd7 = 'K'; label.temp.tWd7 = 'temperature';
bibkey.tWd7 = 'Emme2012';

% time (d), food concentration (cells/dm^3) for BAC2 - BAC7
% algal density decreases in time for high food level, because food influx
%   in the tanks remains the constant, while oysters grow (but numbers decrease)
% at t = 0, each tank had 545 oysters
% 11 sampling dates with food, in total 220 oysters are removed
% 545 - 220 = 325 at day 209 of the experiment in each tank
% tanks were 300 dm^3, influx was 90 dm^3/h
%  300 dm^3/d algal cells with 3e6 cell/cm^3 = 3e9 cell/dm^3: 9e11 cells/d
%  suppose 90 dm^3/h for each tank, 8 tanks = 17280 dm^3/d
%  mean algal density: 5.2e7 cells/dm3, actually 2.7e7 cells/dm^3: half of the cells are used
% X_r = 2.6604763e7  and  7.3834197e7 cells/dm^3 (low and high food levels)
%DATE	BAC2	  BAC3        BAC4        BAC5        BAC6        BAC7
tX2_7 = [ ...
0	10663144	52383275	54226725	10107694	9515013     53459963
1	12439175	56331800	57507100	11328275	11211550	56822850
2	8579200	    47863200	48893600	9545200	    8353800	    46687900
3	10897600	50857800	53691400	8740200     8643600     55542900
4	10736600	54480300	56814800	10817100	9851100     54786200
7	19543300	72125900	70628600	16210600	17997700	70274400
8	19173000	64494500	63303100	16194500	17772300	64397900
9	17450300	61049100	62868400	16613100	17047800	57297800
10	15792000	54206600	60920300	15534400	14858200	75941600
11	15598800	62111700	64414000	15840300	15550500	63431900
14	14375200	73091900	68922000	16065700	16242800	71192100
15	17257100	54689600	55204800	12829600	15985200	55671700
16	12394900	63866600	63560700	15389500	15920800	58022300
17	12652500	67167100	68664400	15486100	15856400	60372900
18	11686500	40650400	39008200	10962000	11155200	42421400
21	19527200	50825600	50036700	17385900	18464600	49714700
25	15936900	49135100	49618100	34258700	34967100	52677100
28	16854600	46913300	45287200	18867100	17418100	42228200
29	14487900	33743500	31489500	12813500	12040700	25258800
30	18593400	58167200	59036600	19237400	19173000	54721800
31	18947600	64977500	60501700	21105000	22167600	59745000
35	12829600	35820400	42035000	18770500	19253500	55204800
36	18786600	53659200	53900700	18013800	19334000	45866800
37	15067500	50149400	48974100	13699000	16162300	48877500
38	16838500	50761200	54174400	19752600	21056700	53401600
43	18512900	51775500	48974100	18432400	19575500	54593000
44	19462800	52355100	47573400	18207000	19366200	44337300
45	20831300	50213800	50890000	18190900	18851000	49360500
46	16774100	41181700	44144100	16242800	16226700	42453600
50	12716900	36770300	27641600	12330500	7870800     32809700
51	16114000	41986700	44820300	14632800	16162300	42324800
52	13940500	38283700	40103000	15421700	16339400	42501900
53	12523700	31199700	32117400	11686500	13055000	28688100
57	16355500	44321200	46575200	14906500	16291100	44933000
59	19382300	57716400	57265600	17885000	19913600	51067100
63	19156900	55478500	49666400	29187200	17836700	40843600
64	15131900	44305100	42002800	15309000	16436000	38863300
67	20766900	43532300	33083400	14809900	15840300	32278400
70	17579100	41938400	43017100	13199900	16870700	33775700
72	16854600	23326800	32069100	11525500	16017400	30716700
73	12765200	29686300	28720300	11815300	12394900	26369700
77	13425300	48249600	44546600	16081800	13747300	37752400
78	13344800	41584200	41101200	12089000	12974500	37333800
79	16049600	41342700	39797100	15824200	12797400	37188900
80	12845700	40666500	39925900	13022800	13457500	40827500
81	11847500	35482300	35739900	11477200	12459300	28881300
84	9625700     49247800	44820300	10301900	11944100	28446600
85	9480800     28366100	26096000	12089000	6550600     23020900
87	38171000	26723900	38605700	13876100	21459200	26305300
88	14149800	33968900	37752400	12733000	13441400	30169300
91	9561300     19173000	21233800	7935200     9191000     18786600
92	10108700	31038700	31521700	10962000	11300100	32310600
93	10736600	26691700	29219400	11219600	10784900	24228400
94	9368100     24711400	25596900	10237500	11251800	22827700
95	12362700	36883000	41246100	13248200	12201700	36512700
98	13360900	33421500	33872300	9867200     11251800	28285600
99	13199900	34226500	34194300	12733000	14632800	31682700
100	11106900	30491300	30008300	11445000	11187400	27094200
101	9690100     18641700	19575500	11799200	10205300	18673900
102	11541600	29493100	27754300	11284000	13216000	22441300
105	11428900	32697000	32664800	12378800	11477200	41020700
106	10607800	37800700	25291000	12958400	10189200	34693400
107	8852900     19285700	19881400	7838600     7919100     17933300
108	10296533	29927800	25945733	11058600	9861833     31215800
109	0           0           0           0           0           0
129	0           0           0           0           0           0
187	0           0           0           0           0           0
211	0           0           0           0           0           0];
tN2 = tX2_7(:,[1 2]); % units.tX.tL2 = {'d','cells/dm^3'}; label.tX.tL2 = {'time','food concentration'};
tN3 = tX2_7(:,[1 3]); % units.tX.tL3 = {'d','cells/dm^3'}; label.tX.tL3 = {'time','food concentration'};
tN4 = tX2_7(:,[1 4]); % units.tX.tL4 = {'d','cells/dm^3'}; label.tX.tL4 = {'time','food concentration'};
tN5 = tX2_7(:,[1 5]); % units.tX.tL5 = {'d','cells/dm^3'}; label.tX.tL5 = {'time','food concentration'};
tN6 = tX2_7(:,[1 6]); % units.tX.tL6 = {'d','cells/dm^3'}; label.tX.tL6 = {'time','food concentration'};
tN7 = tX2_7(:,[1 7]); % units.tX.tL7 = {'d','cells/dm^3'}; label.tX.tL7 = {'time','food concentration'};

% Time (d), algae consumption (cells/h/ind),
% consumption = (X without oyster - X with oyster, cells/dm^3) * influx of water (dm^3/h)/ number of oysters
% at each sampling dat 20 ind were removed
tJX2_7 = [... 
% time (d), BAC2, BAC3,     BAC4,       BAC5,       BAC6,       BAC7 
%2	NAN         NAN         NAN         NAN         NAN         NAN
%4	NAN         NAN         NAN         NAN         NAN         NAN
%8	NAN         NAN         NAN         NAN         NAN         NAN
16	1030873.712	4501388.175	4498418.334	1032085.495	1070279.705	3787374.765
30	1264412.022	2548283.956	2656767.309	1027709.743	973162.0027	2597639.209
50	1474244.786	3968259.664	4064023.093	1489747.915	1357003.687	3882599.114
59	2196886.365	5646863.058	5540318.417	2440079.951	2213193.136	5906032.475
65	3117893.756	4833953.896	5960172.642	2333645.52	3147616.61	7176869.732
85	4155711.977	8509440.159	8192828.293	4546548.039	4385909.818	9322297.415
108	3603942.12	9280264.176	9105580.671	3612592.324	3680515.125	9398361.432];
data.tJX2 = tJX2_7(:,[1 2]); 
units.tJX2  = {'d', 'cells/h'};  label.tJX2 = {'time', 'food consumption per oyster'};  
temp.tJX2   = C2K(14.3);  units.temp.tJX2 = 'K'; label.temp.tJX2 = 'temperature';
bibkey.tJX2 = 'Emme2012';
%
data.tJX3 = tJX2_7(:,[1 3]); 
units.tJX3  = {'d', 'cells/h'};  label.tJX3 = {'time', 'food consumption per oyster'};  
temp.tJX3   = C2K(14.3);  units.temp.tJX3 = 'K'; label.temp.tJX3 = 'temperature';
bibkey.tJX3 = 'Emme2012';
%
data.tJX4 = tJX2_7(:,[1 4]); 
units.tJX4  = {'d', 'cells/h'};  label.tJX4 = {'time', 'food consumption per oyster'};  
temp.tJX4   = C2K(14.3);  units.temp.tJX4 = 'K'; label.temp.tJX4 = 'temperature';
bibkey.tJX4 = 'Emme2012';
%
data.tJX5 = tJX2_7(:,[1 5]); 
units.tJX5  = {'d', 'cells/h'};  label.tJX5 = {'time', 'food consumption per oyster'};  
temp.tJX5   = C2K(14.3);  units.temp.tJX5 = 'K'; label.temp.tJX5 = 'temperature';
bibkey.tJX5 = 'Emme2012';
%
data.tJX6 = tJX2_7(:,[1 6]); 
units.tJX6  = {'d', 'cells/h'};  label.tJX6 = {'time', 'food consumption per oyster'};  
temp.tJX6   = C2K(14.3);  units.temp.tJX6 = 'K'; label.temp.tJX6 = 'temperature';
bibkey.tJX6 = 'Emme2012';
%
data.tJX7 = tJX2_7(:,[1 7]); 
units.tJX7  = {'d', 'cells/h'};  label.tJX7 = {'time', 'food consumption per oyster'};  
temp.tJX7   = C2K(14.3);  units.temp.tJX7 = 'K'; label.temp.tJX7 = 'temperature';
bibkey.tJX7 = 'Emme2012';

% Time (d), clearance rate (dm^3/h/ind) 
% clearance rate = algal consumption (cells/h/ind)/ X (cell/dm^3)
tF2_7 = [... % time (d), BAC2,  BAC3,  BAC4,  BAC5,  BAC6,  BAC7 
%2	NAN     NAN     NAN     NAN     NAN     NAN;
%4	NAN     NAN     NAN     NAN     NAN     NAN;
%8	NAN     NAN     NAN     NAN     NAN     NAN;
16	0.0679	0.0757	0.0719	0.0683	0.0672	0.0599
30	0.0791	0.0488	0.0516	0.0649	0.0617	0.0548
50	0.0855	0.0848	0.0921	0.0872	0.0813	0.0842
59	0.1406	0.1340	0.1272	0.1653	0.1369	0.1438
65	0.1855	0.0987	0.1309	0.1345	0.1838	0.1797
85	0.3053	0.2376	0.2271	0.3517	0.3486	0.2925
108	0.3233	0.3222	0.3141	0.3222	0.3203	0.3426];
data.tF2 = tF2_7(:,[1 2]); 
units.tF2  = {'d', 'dm^3/h'};  label.tF2 = {'time', 'clearance rate'};  
temp.tF2  = C2K(14.3);  units.temp.tF2 = 'K'; label.temp.tF2 = 'temperature';
bibkey.tF2 = 'Emme2012';
%
data.tF3 = tF2_7(:,[1 3]); 
units.tF3  = {'d', 'dm^3/h'};  label.tF3 = {'time', 'clearance rate'};  
temp.tF3  = C2K(14.3);  units.temp.tF3 = 'K'; label.temp.tF3 = 'temperature';
bibkey.tF3 = 'Emme2012';
%
data.tF4 = tF2_7(:,[1 4]); 
units.tF4  = {'d', 'dm^3/h'};  label.tF4 = {'time', 'clearance rate'};  
temp.tF4  = C2K(14.3);  units.temp.tF4 = 'K'; label.temp.tF4 = 'temperature';
bibkey.tF4 = 'Emme2012';
%
data.tF5 = tF2_7(:,[1 5]); 
units.tF5  = {'d', 'dm^3/h'};  label.tF5 = {'time', 'clearance rate'};  
temp.tF5  = C2K(14.3);  units.temp.tF5 = 'K'; label.temp.tF5 = 'temperature';
bibkey.tF5 = 'Emme2012';
%
data.tF6 = tF2_7(:,[1 6]); 
units.tF6  = {'d', 'dm^3/h'};  label.tF6 = {'time', 'clearance rate'};  
temp.tF6  = C2K(14.3);  units.temp.tF6 = 'K'; label.temp.tF6 = 'temperature';
bibkey.tF6 = 'Emme2012';
%
data.tF7 = tF2_7(:,[1 7]);
units.tF7  = {'d', 'dm^3/h'};  label.tF7 = {'time', 'clearance rate'};  
temp.tF7  = C2K(14.3);  units.temp.tF7 = 'K'; label.temp.tF7 = 'temperature';
bibkey.tF7 = 'Emme2012';

% Data from RicoPouv2009 for larvae before metamorphosis
% food consists of 2 algal species in equal numbers: 
%   Isochrysis affinis galbana (45 µm3; 20e-12 g/cell)
%   L < 110 µm: Chaetoceros calcitrans forma pumilus (30-45 µm3; 17.3e-12 g dry/cell RobeChret2004)
%    or 
%   L > 110 µm: Chaetoceros gracilis (80 µm3; 70e-12 g dry/cell)
% temp from 0 till 2 d of age: 25 °C
% RicoBern2010 found K = 600 µm3/µl = 13e6 cells/dm3 for larvae
%   K = {p_Am} / kap_X/ E_X/ {F_m} = 14.38e6/dm3, which is in perfect correspondance

%%%% different temperature and constant X = 1400 µm3/µl, f = 0.84 using K = 266 µm3/µl, 
% time is since fertilisation
% age (d) length (µm) at 17 °C
data.tL_T17 = [ ...
2	79.06;
5	86.01;
7	91.95;
10	109.93;
13	123.93;
15	136.16;
18	157.49;
21	171.40;
24	184.12;
28	216.32;
31	218.95;
36	231.46];
units.tL_T17  = {'d', 'µm'};  label.tL_T17 = {'age', 'length'};  
temp.tL_T17  = C2K(17);  units.temp.tL_T17 = 'K'; label.temp.tL_T17 = 'temperature';
bibkey.tL_T17 = 'RicoPouv2009';

% age (d) length (µm) at 22°C
data.tL_T22 = [...
2	79.06;
5	100.05;
7	123.09;
10	154.25;
13	201.88;
15	215.96;
18	244.27;
21	255.56;
24	270.00];
units.tL_T22  = {'d', 'µm'};  label.tL_T22 = {'age', 'length'};  
temp.tL_T22  = C2K(22);  units.temp.tL_T22 = 'K'; label.temp.tL_T22 = 'temperature';
bibkey.tL_T22 = 'RicoPouv2009';

% age (d) length (µm) at 25°C
data.tL_T25 = [...
2	79.77;
5	102.53;
7	123.48;
10	179.09;
13	234.69;
15	253.23;
18	286.61;
21	287.65];
units.tL_T25  = {'d', 'µm'};  label.tL_T25 = {'age', 'length'};  
temp.tL_T25  = C2K(25);  units.temp.tL_T25 = 'K'; label.temp.tL_T25 = 'temperature';
bibkey.tL_T25 = 'RicoPouv2009';

% a (d)	length (µm) at 27°C
data.tL_T27 = [...
2	79.06;
5	117.80;
7	154.91;
10	225.48;
13	268.42;
15	285.00];
units.tL_T27  = {'d', 'µm'};  label.tL_T27 = {'age', 'length'};  
temp.tL_T27  = C2K(27);  units.temp.tL_T27 = 'K'; label.temp.tL_T27 = 'temperature';
bibkey.tL_T27 = 'RicoPouv2009';

% a	(d) length (µm) at 32°C
data.tL_T32 = [...
2	79.06;
5	118.17;
7	163.02;
10	247.38;
13	271.11;
15	287.00];
units.tL_T32  = {'d', 'µm'};  label.tL_T32 = {'age', 'length'};  
temp.tL_T32  = C2K(32);  units.temp.tL_T32 = 'K'; label.temp.tL_T32 = 'temperature';
bibkey.tL_T32 = 'RicoPouv2009';

% RicoBern2010-data
%%%% different food densities and constant temperature T = 25°C
% age (d) length (µm) at f = 0.01, X = 70 µm3/µl = 70e6 µm3/dm^3 
data.tL_f010 = [...
1.98	76.95;
5.02	86.69;
6.93	85.71;
8.97	86.69;
11.91	90.58;
14.05	92.53;
17.99	97.40;
21.12	96.43];
units.tL_f010  = {'d', 'µm'};  label.tL_f010 = {'age', 'length'};  
temp.tL_f010  = C2K(25);  units.temp.tL_f010 = 'K'; label.temp.tL_f010 = 'temperature';
bibkey.tL_f010 = 'RicoBern2010';

% age (d) length (µm) at f = 0.017, X = 280 µm3/µl
data.tL_f017 = [...
1.95	79.25;
5.05	93.08;
5.91	103.87;
7.00	115.65;
7.91	136.22;
9.00	147.02;
10.05	153.91;
11.09	155.92;
12.05	154.99;
13.05	158.94;
14.00	158.99;
15.09	159.04];
units.tL_f017  = {'d', 'µm'};  label.tL_f017 = {'age', 'length'};  
temp.tL_f017  = C2K(25);  units.temp.tL_f017 = 'K'; label.temp.tL_f017 = 'temperature';
bibkey.tL_f017 = 'RicoBern2010';

% age (d) length (µm) at f = 0.36, X = 450 µm3/µl
data.tL_f360 = [...
2.09	77.67;
5.03	102.91;
7.94	133.98;
10.98	180.58;
11.93	188.35;
14.06	207.77;
18.05	250.49;
21.04	272.82];
units.tL_f360  = {'d', 'µm'};  label.tL_f360 = {'age', 'length'};  
temp.tL_f360  = C2K(25);  units.temp.tL_f360 = 'K'; label.temp.tL_f360 = 'temperature';
bibkey.tL_f360 = 'RicoBern2010';

% age (d) length (µm) at f = 0.71, X = 960 µm3/µl
data.tL_f710 = [...
2.02	76.60;
3.12	93.05;
7.01	127.82;
9.06	154.90;
11.90	207.19;
15.11	263.34;
21.14	281.50];
units.tL_f710  = {'d', 'µm'};  label.tL_f710 = {'age', 'length'};  
temp.tL_f710  = C2K(25);  units.temp.tL_f710 = 'K'; label.temp.tL_f710 = 'temperature';
bibkey.tL_f710 = 'RicoBern2010';

% age (d)	length (µm) at f = 0.73, X = 1000 µm3/µl
data.tL_f730 = [...
2.04	78.49;
5.03	99.92;
6.89	121.30;
7.94	142.64;
8.98	161.08;
10.07	177.58;
10.88	201.82;
11.79	214.44;
12.97	230.95;
13.97	252.29;
14.88	271.69;
18.00	286.36;
21.09	287.47];
units.tL_f730  = {'d', 'µm'};  label.tL_f730 = {'age', 'length'};  
temp.tL_f730  = C2K(25);  units.temp.tL_f730 = 'K'; label.temp.tL_f730 = 'temperature';
bibkey.tL_f730 = 'RicoBern2010';

% age (d) length (µm) at f = 0.9, X = 1900 µm3/µl
data.tL_f900 = [...
2.05	79.20;
5.14	99.60;
7.95	147.01;
11.14	211.79;
11.95	234.02;
14.00	270.77;
18.00	279.65;
21.00	281.72];
units.tL_f900  = {'d', 'µm'};  label.tL_f900 = {'age', 'length'};  
temp.tL_f900  = C2K(25);  units.temp.tL_f900 = 'K'; label.temp.tL_f900 = 'temperature';
bibkey.tL_f900 = 'RicoBern2010';

% age (d) length (µm) at f = 0.92, X = 2100 µm3/µl
data.tL_f920 = [...
2.05	75.34;
3.14	92.99;
6.86	126.39;
9.05	148.00;
11.91	201.89;
15.00	270.44;
21.14	284.42];
units.tL_f920  = {'d', 'µm'};  label.tL_f920 = {'age', 'length'};  
temp.tL_f920  = C2K(25);  units.temp.tL_f920 = 'K'; label.temp.tL_f920 = 'temperature';
bibkey.tL_f920 = 'RicoBern2010';

% age (d) length (µm) at f = 0.96, X = 3300 µm3/µl
data.tL_f960 = [...
2.00	72.18;
5.06	90.83;
5.97	99.64;
6.97	113.33;
7.88	137.72;
9.02	150.44;
10.07	165.10;
11.21	175.87;
11.89	197.33;
12.98	220.76;
14.03	243.22;
15.22	263.73;
21.05	283.49];
units.tL_f960  = {'d', 'µm'};  label.tL_f960 = {'age', 'length'};  
temp.tL_f960  = C2K(25);  units.temp.tL_f960 = 'K'; label.temp.tL_f960 = 'temperature';
bibkey.tL_f960 = 'RicoBern2010';

% Nicola Mark 2011 (pers com)
% food ad lib, age 25 d at start of experient (probably at 25 C)
% Date	L (mm) 18°C	L (mm) 22°C	L (mm) 25°C	L (mm) 28°C	L (mm)
% 
tL_T = [...
0	1.14556865	1.14556865	1.14556865	1.14556865
3	1.229901331	1.368580866	1.498123077	1.70686106
6	1.48738146	1.824064444	1.965083591	2.358388727
10	1.791172094	2.772919082	3.234352798	3.98302325
13	2.227595113	3.518152174	4.154010721	5.143219923
17	2.762207782	4.639163969	5.897196409	7.58858929
22	3.6932819	6.232447497	8.141216426	9.255268519];
data.tL_T18_Mark2011 = tL_T(:,[1 2]);
units.tL_T18_Mark2011  = {'d', 'mm'};  label.tL_T18_Mark2011 = {'age', 'length'};  
temp.tL_T18_Mark2011  = C2K(18);  units.temp.tL_T18_Mark2011 = 'K'; label.temp.tL_T18_Mark2011 = 'temperature';
bibkey.tL_T18_Mark2011 = 'Mark2011';
%
data.tL_T22_Mark2011 = tL_T(:,[1 3]);
units.tL_T22_Mark2011  = {'d', 'mm'};  label.tL_T22_Mark2011 = {'age', 'length'};  
temp.tL_T22_Mark2011  = C2K(22);  units.temp.tL_T22_Mark2011 = 'K'; label.temp.tL_T22_Mark2011 = 'temperature';
bibkey.tL_T22_Mark2011 = 'Mark2011';
%
data.tL_T25_Mark2011 = tL_T(:,[1 4]);
units.tL_T25_Mark2011  = {'d', 'mm'};  label.tL_T25_Mark2011 = {'age', 'length'};  
temp.tL_T25_Mark2011  = C2K(18);  units.temp.tL_T25_Mark2011 = 'K'; label.temp.tL_T25_Mark2011 = 'temperature';
bibkey.tL_T25_Mark2011 = 'Mark2011';
%
data.tL_T28_Mark2011 = tL_T(:,[1 5]);
units.tL_T28_Mark2011  = {'d', 'mm'};  label.tL_T28_Mark2011 = {'age', 'length'};  
temp.tL_T28_Mark2011  = C2K(28);  units.temp.tL_T28_Mark2011 = 'K'; label.temp.tL_T28_Mark2011 = 'temperature';
bibkey.tL_T28_Mark2011 = 'Mark2011';


% Nicola Mark 2011 (pers com)
% food ad lib, age 25 d at start of experient (probably at 25 C)
% Date	W (mg) 18°C	W (mg) 22°C	W (mg) 25°C	W (mg) 28°C	W (mg)
% Weights including body fluids, possibly also some environmental water
% at 25°C gonad where seen at day 8, so aT_p = 32 d 
tWw_T = [...
0	0.378378378	0.378378378	0.378378	0.378378378	
3	0.581009009	0.776       0.839945946	1.149495495	
6	0.791477477	1.257891892	1.406504505	2.200738739	
10	1.533657658	3.374702703	4.149459459	8.107207207	
13	2.27827027	6.455027027	8.761459459	18.99108108	
17	3.911279279	13.85302703	21.20562162	41.96378378	
20	6.072072072	23.86151351	36.59091892	61.34108108	
22	7.73981982	31.30021622	48.84843243	77.20972973];
data.tWw_T18_Mark2011 = tWw_T(:,[1 2]);
units.tWw_T18_Mark2011  = {'d', 'mg'};  label.tWw_T18_Mark2011 = {'age', 'wet weight'};  
temp.tWw_T18_Mark2011  = C2K(18);  units.temp.tWw_T18_Mark2011 = 'K'; label.temp.tWw_T18_Mark2011 = 'temperature';
bibkey.tWw_T18_Mark2011 = 'Mark2011';
%
data.tWw_T22_Mark2011 = tWw_T(:,[1 3]);
units.tWw_T22_Mark2011  = {'d', 'mg'};  label.tWw_T22_Mark2011 = {'age', 'wet weight'};  
temp.tWw_T22_Mark2011  = C2K(22);  units.temp.tWw_T22_Mark2011 = 'K'; label.temp.tWw_T22_Mark2011 = 'temperature';
bibkey.tWw_T22_Mark2011 = 'Mark2011';
%
data.tWw_T25_Mark2011 = tWw_T(:,[1 4]);
units.tWw_T25_Mark2011  = {'d', 'mg'};  label.tWw_T25_Mark2011 = {'age', 'wet weight'};  
temp.tWw_T25_Mark2011  = C2K(25);  units.temp.tWw_T25_Mark2011 = 'K'; label.temp.tWw_T25_Mark2011 = 'temperature';
bibkey.tWw_T25_Mark2011 = 'Mark2011';
%
data.tWw_T28_Mark2011 = tWw_T(:,[1 5]);
units.tWw_T28_Mark2011  = {'d', 'mg'};  label.tWw_T28_Mark2011 = {'age', 'wet weight'};  
temp.tWw_T28_Mark2011  = C2K(28);  units.temp.tWw_T28_Mark2011 = 'K'; label.temp.tWw_T28_Mark2011 = 'temperature';
bibkey.tWw_T28_Mark2011 = 'Mark2011';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% from: FabiHuve2005
% Data: extracted with Matlab 
% Experiment information:
%   - origin of oysters: hatchery produce (Ifremer La Tremblade, France) from 30 wild broodstock (Maren-Oléron Bay, France); spat reared at Ifremer station (in Bouin, France)
%   - 1-year old oysters conditioned at Ifremer Argenton (France) from February 2002 to February 2003
%   - rearing system: 600l raceways, 20µm filtered running seawater
%   - food: mixed diet: - Chaetoceros calcitrans-Skeletonema costatum (33%)+ Isochrysis affinis galbana (33%) + Tetraselmis chui (33%)
%                       - 8% dry weight of algae/dry weight of oyster
%   - 3 experimental conditions of T and Light: 
%       NC (natural condition, varying), temp between 9 and 20 C
%       AC (accelerated conditions => *2NC, varying), temp between 9 and 20 C
%       WC (winter condition, T=8°C) 
%   - measurements: Ww = total wet weight; L = length; Wwv = visceral wet weight (digestive gland, gonade, labial palp); Ga = gonad area (% relative to the area of Wwv)
%   - Temperature need to be extracted...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% total wet weight including shell
% [time (d) | Ww WC(g) | Ww AC(g) | Ww NC(g)]
data.tWw_FabiHuve2005 = [ ...
 14.7840   17.5949   17.4485   17.5277;
 45.6661   17.7532   18.1616   19.1918;
 76.2196   22.2627   21.9651   20.8558;
106.1161   22.7373   26.2441   26.1648;
136.6697   20.4430   28.1458   19.5880;
166.8947   24.1614   28.3043   25.2139;
197.4482   25.9019   31.2361   27.1157;
227.0162   30.8070   34.2472   27.9081;
258.8839   25.2690   38.1300   32.1078;
289.4374   31.4399   40.1109   35.7528;
319.3339   34.5253   50.4120   39.9525;
350.2160   37.1361   59.2868   47.6387];
% select winter conditions only; temp unknown for other conditions
data.tWw_FabiHuve2005 = data.tWw_FabiHuve2005(:,[1 2]);
units.tWw_FabiHuve2005  = {'d', 'g'};  label.tWw_FabiHuve2005 = {'time', 'wet weight'};  
temp.tWw_FabiHuve2005  = C2K(8);  units.temp.tWw_FabiHuve2005 = 'K'; label.temp.tWw_FabiHuve2005 = 'temperature';
bibkey.tWw_FabiHuve2005 = 'FabiHuve2005';
comment.tWw_FabiHuve2005 = 'total wet weight including shell';


% [time (d) | L WC(cm) | L AC(cm) | L NC(cm)]
data.tL_FabiHuve2005 = [ ...
 15.1279    5.6039    5.5948    5.6123;
 46.0273    6.1346    5.3935    5.5666;
 76.2831    5.6771    6.1255    5.6854;
106.8607    6.1072    7.0405    6.7728;
136.7945    5.9425    6.7660    5.8864;
168.0159    6.5281    7.1961    6.3616;
198.5935    6.4458    7.1961    6.8460;
228.8492    6.9490    7.3882    6.6084;
258.7831    6.5373    8.1477    7.2023;
290.0044    7.3699    8.2392    7.1658;
319.9383    7.5621    8.8523    7.6227;
350.5159    7.2418    9.4471    7.7050];
% select winter conditions only; temp unknown for other conditions
data.tL_FabiHuve2005 = data.tL_FabiHuve2005(:,[1 2]);
units.tL_FabiHuve2005  = {'d', 'cm'};  label.tL_FabiHuve2005 = {'time', 'shell length'};  
temp.tL_FabiHuve2005  = C2K(8);  units.temp.tL_FabiHuve2005 = 'K'; label.temp.tL_FabiHuve2005 = 'temperature';
bibkey.tL_FabiHuve2005 = 'FabiHuve2005';

% vicera: digestive glad, gonad, labial palp
% [time (d) | Ww WC(g) | Ww AC(g) | Ww NC(g)]
tWwV_FabiHuve2005 = [ ...
 15   0.8105    0.8091    0.7909;
 46   1.1158    1.0928    1.0123;
 77   1.2316    1.1979    1.1599;
107   1.6632    1.6077    1.8243;
138   1.5263    1.0718    1.5395;
168   2.1579    1.1033    0.9912;
199   2.2947    1.5236    1.1705;
230   3.0316    2.1121    1.0123;
260   2.8211    2.4799    1.7821;
290   4.0632    2.9212    2.3726;
320   4.5579    3.8249    3.4482;
350   4.8421    4.0140    4.2496];

% vicera: Gonad mass as fraction of viceral mass 
% [time (d) | Ww WC(%) | Ww AC(%) | Ww NC(%)]
tWwG_FabiHuve2005 = [ ...
 15    5.6388    6.2882    6.1538
 46    4.2291   12.9258    7.1795
 77    9.1630   22.0087   15.0427
107   24.3172   62.5328   49.5726
138   34.8899   34.2358   55.0427
168   30.6608   11.1790   27.3504
199   29.6035   18.1659   20.5128
230   39.1189   21.6594   14.3590
260   57.0925   38.7773   21.1966
290   61.3216   52.4017    9.9145
320   54.9780   44.3668   14.0171
350   56.3877   28.2969   12.6496];
data.tWwR_FabiHuve2005 = [tWwV_FabiHuve2005(:,1), tWwV_FabiHuve2005(:,2) .* tWwG_FabiHuve2005(:,2) * .01];
units.tWwR_FabiHuve2005  = {'d', 'g'};  label.tWwR_FabiHuve2005 = {'time', 'gonad wet weight'};  
temp.tWwR_FabiHuve2005  = C2K(8);  units.temp.tWwR_FabiHuve2005 = 'K'; label.temp.tWwR_FabiHuve2005 = 'temperature';
bibkey.tWwR_FabiHuve2005 = 'FabiHuve2005';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% from: CollBoud1999
% Data: extracted with Matlab 
% Experiment information: larvea
%   - origin of genitors: from the French Atlantic coast; n = 20 males and n = 20 females; see the ms for details on crosses and fertilisation
%   - 3h after fertilisation, 87.6% of embryos developed
%   - larvae were reared in 4 tanks (300L, 1µm filtered seawater, 23°C, 28 PSU)
%   - food: Isochrysis galbana + Extubocellulus criberiger; concentration: 60 cells/µL (excess to avoid competition)
%   - larvea concentration: day 1 = 13 larvae/mL and progrssively reduced to 1 larvae/mL at day 17 (any selective sieving)
%   - sieving groups: every 48h sieving of the whole population; when length pediveliger larvae > 200µm => tranfered for settlement procedure => 4 sieving groups (SG1 to SG4)
%   - settlement procedure: PVC collector system in raceway => 10µm filtered seawater at 26°C
%   - after settlement: collectors were maintained in 800L tanks; food: Skeletonema costatum "enriched sea water"
%   -  groups SG1 to SG4 were transfered, after the experiment to nursery and reared over 11 months (IFREMER hatchery, Tremblade) => Skeletonema costatum and 26°C (supposed)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% larvae (time = time after fertilisation)
% [time (d) | L (µm)]
data.tL_CollBoud1999 = [...
 1.2642   73.2283;
 3.3063   85.0394;
 6.5154   95.2756;
 8.4603  108.6614;
10.4052  130.7087;
13.4198  181.8898;
15.2674  229.1339;
17.3096  273.2283];
units.tL_CollBoud1999  = {'d', 'µm'};  label.tL_CollBoud1999 = {'age', 'length'};  
temp.tL_CollBoud1999  = C2K(23);  units.temp.tL_CollBoud1999 = 'K'; label.temp.tL_CollBoud1999 = 'temperature';
bibkey.tL_CollBoud1999 = 'CollBoud1999';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% from: GoulWolo2004
% Data: extracted with Matlab 
% Experiment information: veliger larvea => respiratory measurments of larvae
%   - origin of larvea: see (Helm and Millican 1977); age of larvea => ~48h after fertilisation (supposed)
%   - intial conditions: L = 95+/-1µm to 331+/-13 µm (D-shaped veligers)
%   - experimental temperature: 20+/-0.5°C; salinity 34.6+/-0.5PSU
%   - rearing system:  300 dm^3 aerated vessels, sea water changed every day
%   - respiratory measurments: volumetric micro-respirometer; every 10min
%   - food: Isochrysis galbana + Chaetoceros pumilum at a concentration of 30e-4 cell/cm^3
%   - Units: respiratory rate (JO) => nL of O_2/h/larvea; L => µm; Wd => µg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [Length, µm, JO, nL of O_2/h/larvea, Wd, mg]
% comment Bas: mg must be µg
LJOW_GoulWolo2004 = [...
120.9599    0.6445  0.1917
151.1556    1.0995  0.3038
155.8527    1.1754  0.3275
169.7204    1.9336  0.4072 
169.9441    2.1232  0.4072
186.2721    2.2180  0.5041
187.8378    2.8057  0.5192
205.2842    2.4645  0.6528
205.5079    1.0616  0.6528
205.5080    1.8768  0.6528
205.5081    3.3365  0.6506
259.4129    3.8104  1.2129
259.4130    4.2844  1.2151
259.6365    4.5118  1.2151
259.8602    3.5261  1.2172
304.8183    7.7725  1.8873
304.8184    6.4076  1.8851
305.0419    6.9194  1.8851
330.5405   10.4455  2.3504
330.5406   11.3744  2.3483];
data.LWd_GoulWolo2004 = LJOW_GoulWolo2004(:,[1 3]);
units.LWd_GoulWolo2004  = {'µm', 'µg'};  label.LWd_GoulWolo2004 = {'length', 'dry weight'};  
bibkey.LWd_GoulWolo2004 = 'GoulWolo2004';
%
data.LJO_GoulWolo2004 = LJOW_GoulWolo2004(:,[1 2]);
units.LJO_GoulWolo2004  = {'µm', 'nL O_2/h'};  label.LJO_GoulWolo2004 = {'length', 'O_2 consumption'};  
temp.LJO_GoulWolo2004  = C2K(20);  units.temp.LJO_GoulWolo2004 = 'K'; label.temp.LJO_GoulWolo2004 = 'temperature';
bibkey.LJO_GoulWolo2004 = 'GoulWolo2004';

%% set weights for all real data
weights = setweights(data, []);

%% set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);

%% pack auxData and txtData for output
auxData.temp = temp;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Group plots
set1 = {'tL2','tL3','tL4','tL5','tL6','tL7'};       comment1 = {'Emme2012 data from bassin 2,3,4,5,6,7'};
set2 = {'tWw2','tWw3','tWw4','tWw5','tWw6','tWw7'}; comment2 = {'Emme2012 data from bassin 2,3,4,5,6,7'};
set3 = {'tWd2','tWd3','tWd4','tWd5','tWd6','tWd7'}; comment3 = {'Emme2012 data from bassin 2,3,4,5,6,7'};
set4 = {'tJX2','tJX3','tJX4','tJX5','tJX6','tJX7'}; comment4 = {'Emme2012 data from bassin 2,3,4,5,6,7'};
set5 = {'tF2','tF3','tF4','tF5','tF6','tF7'}; comment5 = {'Emme2012 data from bassin 2,3,4,5,6,7'};
set6 = {'tL_T32','tL_T27','tL_T25','tL_CollBoud1999','tL_T22','tL_T17'}; comment6 = {'RicoPouv2009 data at 32, 27, 25, 23, 22, 17 C'};
set7 = {'tL_f960','tL_f920','tL_f900','tL_f730','tL_f710','tL_f360','tL_f017','tL_f010'}; comment7 = {'Data at scaled func. resp. 0.96, 0.92, 0.90, 0.73, 0.71, 0.36, 0.017, 0.01'};
set8 = {'tL_T28_Mark2011','tL_T25_Mark2011','tL_T22_Mark2011','tL_T18_Mark2011'}; comment8 = {'Mark2011 data at 28, 25, 22, 18 C'};
set9 = {'tWw_T28_Mark2011','tWw_T25_Mark2011','tWw_T22_Mark2011','tWw_T18_Mark2011'}; comment9 = {'Mark2011 data at 28, 25, 22, 18 C'};
metaData.grp.sets = {set1,set2,set3,set4,set5,set6,set7,set8,set9};
metaData.grp.comment = {comment1,comment2,comment3,comment4,comment5,comment6,comment7,comment8,comment9};

%% Discussion points
D1 = 'Lj is given zero weight because it is out of range';
metaData.discussion = struct('D1', D1);

%% Facts
F1 = 'This entry is discussed in Emme2012';
metaData.bibkey.F1 = 'Emme2012'; 
metaData.facts = struct('F1',F1);

%% Links
metaData.links.id_CoL = '93190b1650de88982e0161577b8b6a7e'; % Cat of Life
metaData.links.id_EoL = '451579'; % Ency of Life
metaData.links.id_Wiki = 'Magallana_gigas'; % Wikipedia
metaData.links.id_Taxo = '39283'; % Taxonomicon
metaData.links.id_WoRMS = '836033'; % WoRMS
metaData.links.id_molluscabase = '140656'; % MolluscaBase

%% References
bibkey = 'Wiki'; type = 'Misc'; bib = ...
'howpublished = {\url{http://en.wikipedia.org/wiki/Magallana_gigas}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Kooy2010'; type = 'Book'; bib = [ ...  % used in setting of chemical parameters and pseudodata
'author = {Kooijman, S.A.L.M.}, ' ...
'year = {2010}, ' ...
'title  = {Dynamic Energy Budget theory for metabolic organisation}, ' ...
'publisher = {Cambridge Univ. Press, Cambridge}, ' ...
'pages = {Table 4.2 (page 150), 8.1 (page 300)}, ' ...
'howpublished = {\url{../../../bib/Kooy2010.html}}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Emme2012'; type = 'Phdthesis'; bib = [ ... 
'author = {Emmery, A.}, ' ... 
'year = {2012}, ' ...
'title = {Influence of the trophic environment and metabolism on the dynamics of stable isotopes in the {P}acific oyster (\emph{Crassostrea gigas}): modeling and experimental approaches}, ' ...
'school = {VU University Amsterdam, Rennes University}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'CollBoud1999'; type = 'Article'; bib = [ ... 
'author = {Collet, B. and Boudry, P. and Thebault, A. and Heurtebise, S. and Morand, B. and G\''{e}rard, A.}, ' ... 
'year = {1999}, ' ...
'title = {Relationship between pre-and post-metamorphic growth in the {P}acific oyster \emph{Crassostrea gigas} ({T}hunberg)}, ' ...
'journal = {Aquaculture}, ' ...
'volume = {175}, ' ...
'pages = {215--226}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'DuteBeni2009'; type = 'Article'; bib = [ ... 
'author = {Dutertre, M. and Beninger, P., and Barille, L. and Papin, M. and Rosa, P. and Barille, A. and Haure, J.}, ' ... 
'year = {2009}, ' ...
'title = {Temperature and seston quantity and quality effects on field reproduction of farmed oysters, \emph{Crassostrea gigas}, in {B}ourgneuf {B}ay, {F}rance}, ' ...
'journal = {Aquatic Living Resources}, ' ...
'volume = {22}, ' ...
'pages = {319--329}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'FabiHuve2005'; type = 'Article'; bib = [ ... 
'author = {Fabiou, C. and Huvet, A. and Le Souchu, P. and Le Pennec, M. and Puvreua, S.}, ' ... 
'year = {2005}, ' ...
'title = {Temperature and photoperiod drive \emph{Crassostrea gigas} reproductive internal clock}, ' ...
'journal = {Aquaculture}, ' ...
'volume = {250}, ' ...
'pages = {458--470}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'GoulWolo2004'; type = 'Article'; bib = [ ... 
'author = {Goulletquer, P. and Wolowicz, M. and Latala, A. and Brown, C. and Cragg, S.}, ' ... 
'year = {2004}, ' ...
'title = {Application of a micro-respirometric volumetric method to respiratory measurements of larvae of the {P}acific oyster \emph{Crassostrea gigas}}, ' ...
'journal = {Aquatic Living Resources}, ' ...
'volume = {17}, ' ...
'number = {2}, '...
'pages = {195--200}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'PouvBour2006'; type = 'Article'; bib = [ ... 
'author = {Pouvreau, S. and Bourl\`{e}s, Y. and Lefebvre, S. and Gangnery, A. and Alunno-Bruscia, M.}, ' ... 
'year = {2006}, ' ...
'title = {Application of a {D}ynamic {E}nergy {B}udget model to the {P}acific oyster, \emph{Crassostrea gigas}, reared under various environmental conditions}, ' ...
'journal = {J. Sea Res.}, ' ...
'volume = {56}, ' ...
'pages = {156--167}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'RicoPouv2009'; type = 'Article'; bib = [ ... 
'author = {Rico-Villa, B. and Pouvreau, S. and Robert, R.}, ' ... 
'year = {2009}, ' ...
'title = {Influence of food density and temperature on ingestion, growth and settlement of {P}acific oyster larvae, \emph{Crassostrea gigas}}, ' ...
'journal = {Aquaculture}, ' ...
'volume = {287}, ' ...
'pages = {395--401}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'RicoBern2010'; type = 'Article'; bib = [ ... 
'author = {Rico-Villa, B. and Bernard, I. and Robert, R. and Pouvreau, S.}, ' ... 
'year = {2010}, ' ...
'title = {A {D}ynamic {E}nergy {B}udget ({D}{E}{B}) growth model for pacific oyster larvae, \emph{Crassostrea gigas}}, ' ...
'journal = {Aquaculture}, ' ...
'volume = {305}, ' ...
'pages = {84--94}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'VeerCard2006'; type = 'Article'; bib = [ ... 
'author = {Van der Veer, H. and Cardoso, J. and Van der Meer, J.}, ' ... 
'year = {2006}, ' ...
'title = {The estimation of {D}{E}{B} parameters for various northeast atlantic bivalve species}, ' ...
'journal = {J. Sea Res.}, ' ...
'volume = {56}, ' ...
'pages = {107--124}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Mark2011'; type = 'Misc'; bib = [ ...
'author = {Nicola Mark}, ' ... 
'year = {2011}, ' ...
'note = {pers. comm.}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];

