function [data, auxData, metaData, txtData, weights] = mydata_Pleurobrachia_bachei

%% set metaData
metaData.phylum     = 'Ctenophora'; 
metaData.class      = 'Tentaculata'; 
metaData.order      = 'Cydippida'; 
metaData.family     = 'Pleurobrachiidae';
metaData.species    = 'Pleurobrachia_bachei'; 
metaData.species_en = 'sea gooseberry'; 

metaData.ecoCode.climate = {'MC'};
metaData.ecoCode.ecozone = {'MPNE'};
metaData.ecoCode.habitat = {'0iMp'};
metaData.ecoCode.embryo  = {'Mp'};
metaData.ecoCode.migrate = {};
metaData.ecoCode.food    = {'biPz'};
metaData.ecoCode.gender  = {'Hh'};
metaData.ecoCode.reprod  = {'O'};

metaData.T_typical  = C2K(15); % K, body temp
metaData.data_0     = {'ab'; 'ap'; 'am'; 'Lb'; 'Lp'; 'Li'; 'WC0'; 'Wdi'; 'Ri'}; 
metaData.data_1     = {'t-L_f'; 't-JX_f'; 't-N_f'; 'L-Wd_f'; 'L-JO_T'; 'L-Wd'}; 

metaData.COMPLETE = 5.0; % using criteria of LikaKear2011

metaData.author   = {'Starrlight Augustine'};    
metaData.date_subm = [2012 11 06];              
metaData.email    = {'starrlight.augustine@akvaplan.niva.no'};            
metaData.address  = {'Akvaplan-niva AS, Fram Centre, P.O. Box 6606 Langnes, 9296 Tromso, Norway'};   

metaData.author_mod_1   = {'Bas Kooijman'};    
metaData.date_mod_1     = [2015 11 04];              
metaData.email_mod_1    = {'bas.kooijman@vu.nl'};            
metaData.address_mod_1  = {'VU University Amsterdam'};   

metaData.curator     = {'Starrlight Augustine'};
metaData.email_cur   = {'starrlight.augustine@akvaplan.niva.no'}; 
metaData.date_acc    = [2015 11 06]; 

%% set data
% zero-variate data

data.ab = 27/24;  units.ab = 'd';    label.ab = 'age at birth';             bibkey.ab = 'Hiro1972';   
  temp.ab = C2K(15);  units.temp.ab = 'K'; label.temp.ab = 'temperature';
  comment.ab = 'observed range of hatching times was 14-40 h from a single experiment';
data.tp = 55;     units.tp = 'd';    label.tp = 'time since birth at puberty';   bibkey.tp = 'Hiro1972';
  temp.tp = C2K(15);  units.temp.tp = 'K'; label.temp.tp = 'temperature';
  comment.tp = 'observed range is 55-70 d';
data.am = 5*30.5; units.am = 'd';    label.am = 'life span';                bibkey.am = 'Wiki';   
  temp.am = C2K(15);  units.temp.am = 'K'; label.temp.am = 'temperature'; 

data.Lb  = 0.01;  units.Lb  = 'cm';  label.Lb  = 'total length at birth';   bibkey.Lb  = 'Hiro1972';
data.Lp  = 1;     units.Lp  = 'cm';  label.Lp  = 'equatorial diameter at puberty'; bibkey.Lp  = 'Hiro1972';
  comment.Lp = 'observed range is 6-10 mm';
data.Li  = 3;     units.Li  = 'cm';  label.Li  = 'ultimate equatorial diameter'; bibkey.Li  = 'guess';

data.WC0 = 0.1;   units.WC0 = 'mugC'; label.WC0 = 'initial egg carbon mass'; bibkey.WC0 = 'Hiro1972';
data.Wdi = 90;    units.Wdi = 'mg';  label.Wdi = 'ultimate ash free dry weight'; bibkey.Wdi = 'guess';

data.Ri  = 1000;  units.Ri  = '#/d'; label.Ri  = 'maximum reprod rate';     bibkey.Ri  = 'Hiro1972';   
  temp.Ri = C2K(15);  units.temp.Ri = 'K'; label.temp.Ri = 'temperature';
 
% uni-variate data

% Hiro1972
%  glass recipients, 15+/- 0.5 C, S = 32 - 34, 
%  * *food type*: early nauplii of Labidocera trispinosa and Acartia tonsa
%  * *length measurments*: ocular micrometer: equatorial diameter in the tentacular plane
%  * *ingestion rate*: difference between initial and final numbers of food
%     particles corrected for average losses in control vessels without ctenophors
%  * *food particle mass*: Labidocera: 0.05 mugC/ind; Acartia adults 3.6 mugC/ind; 
%     calanus nauplii: 0.1 mugC/ind; artemia nauplii 0.5 mugC/ind
%  * *Respiration measurements*: organisms were taken from the field,
%     organisms acclimated to lab conditions for 5 days fed Calanus spp.,
%     Epilabidocera spp and Tortanus spp, organisms were acclimated at two
%  temperatures 13.5+/-1.5 C and 29.5+/-1 salinity

% *individual A* (open white triangles, fig.1,3,4)
data.tJX_A = [ ... time since hatch, d  ingestion rate, mugC/d
25.80	4.08
27.91	5.77
30.02	1.04
32.12	2.73
34.02	0.18
36.13	4.01
38.13	5.72
39.93	5.34
42.03	7.03
44.26	32.22
46.07	66.06
47.96	59.23
50.08	80.17
52.11	133.21
54.20	96.40
56.21	100.25
58.24	151.15
60.06	206.38
62.19	257.26
64.28	226.87
66.11	297.06
68.21	281.64
70.09	242.74
72.15	357.80
74.38	380.86
76.36	337.65
78.44	290.15
80.30	608.47
82.15	721.44
84.04	310.34
86.14	491.71
88.22	446.34
90.00	418.16
92.26	116.07
94.38	530.59
96.11	423.27];
units.tJX_A   = {'d', 'mugC/d'};  label.tJX_A = {'time since birth', 'ingestion rate', 'individual A'};  
bibkey.tJX_A = 'Hiro1972';
tJX.tJX_A = data.tJX_A; units.tJX.tJX_A   = {'d', 'mugC/d'};  label.tJX.tJX_A = {'time since birth', 'ingestion rate'};
treat.tJX_A = {0}; units.treat.tJX_A = ''; label.treat.tJX_A = '';
%
data.tL_A = [ ... time since hatch, d diameter, mm
0.28	0.03
13.18	0.18
17.39	0.26
19.21	0.26
22.86	0.76
25.11	0.90
27.35	0.90
31.28	0.98
35.34	1.12
37.17	1.90
39.13	1.98
41.09	2.62
43.20	3.37
45.44	3.59
47.27	4.01
49.23	4.93
51.05	5.69
53.30	7.00
55.26	7.47
57.36	7.78
59.19	7.64
61.57	8.16
63.25	8.39
65.50	8.75
67.32	8.66
69.14	8.86
71.39	9.19
73.21	9.94
75.60	10.02
77.56	10.19
79.52	10.02
80.93	10.75
83.17	11.86
85.27	12.39
87.24	12.11
89.34	12.47
91.02	12.81
95.23	11.94
97.34	11.93
99.02	12.77];
units.tL_A   = {'d', 'mm'};  label.tL_A = {'time since birth', 'diameter', 'individual A'};  
temp.tL_A    = C2K(15);  units.temp.tL_A = 'K'; label.temp.tL_A = 'temperature';
bibkey.tL_A = 'Hiro1972';
% 
data.tN_A = [ ... time since hatch, d reprod rate eggs/d
 0       0
53.94	49.92
56.18	41.29
58.00	10.24
59.81	15.69
61.73	228.84
63.82	242.68
65.92	205.99
68.02	146.85
69.81	267.38
72.06	174.54
73.96	514.01
75.90	561.55
77.70	639.98
79.90	8.19
81.96	226.95
83.44	521.55
85.84	389.39
87.98	119.72
89.76	307.62
92.40	374.74
94.82	91.01
96.65	801.01];
data.tN_A(:,2) = cumsum(data.tN_A(:,2)); % cum. number of eggs
units.tN_A   = {'d', '#'};  label.tN_A = {'time since birth', 'cumulative # of eggs', 'individual A'};  
temp.tN_A    = C2K(15);  units.temp.tN_A = 'K'; label.temp.tN_A = 'temperature';
bibkey.tN_A = 'Hiro1972';
%
% *individual B* (open white circles fig.1)
data.tJX_B = [ ... time since hatch, d Ingestion rate, mugC/d
25.70	4.10
28.02	5.75
30.12	7.43
32.13	4.87
34.23	2.28
36.13	6.15
38.34	5.68
40.35	7.39
42.14	9.14
44.25	8.69
46.04	1.89
48.04	3.60
49.94	3.20
52.15	4.86
54.05	4.46
56.16	1.87
57.96	29.29
60.07	26.70
62.10	79.74
64.11	92.14
65.94	160.20
68.30	50.61
70.36	146.42
72.31	257.23
74.32	265.36
76.07	391.19
78.14	318.02
80.34	696.16
82.15	533.20
84.02	276.12
86.12	461.77
88.35	482.68
90.10	407.44
92.41	186.63
94.46	680.30
96.34	448.89];
units.tJX_B   = {'d', 'mugC/d'};  label.tJX_B = {'time since birth', 'ingestion rate', 'individual B'};  
bibkey.tJX_B = 'Hiro1972';
tJX.tJX_B = data.tJX_B; units.tJX.tJX_B   = {'d', 'mugC/d'};  label.tJX.tJX_B = {'time since birth', 'ingestion rate'};  
treat.tJX_B = {0}; units.treat.tJX_B = ''; label.treat.tJX_B = '';
%
data.tL_B = [ ... time since hatch, d diameter, mm
0.14	0.00
13.04	0.80
17.11	0.85
19.21	1.02
23.00	1.10
24.96	1.24
27.07	1.10
29.31	1.15
31.28	1.32
33.24	1.31
35.20	1.45
37.45	1.62
39.27	1.67
41.23	1.95
43.34	2.06
45.30	2.17
47.27	2.25
49.51	2.42
51.19	2.58
53.30	3.03
55.26	2.38
57.50	2.72
59.19	3.22
61.29	4.25
63.39	6.04
65.22	7.29
67.46	8.49
69.42	9.11
71.25	9.55
73.21	9.97
75.46	10.47
77.14	10.47
79.38	10.80
81.49	12.39
83.17	12.17
85.13	13.40
87.10	13.12
88.92	13.48
91.02	13.42
95.23	12.80
97.05	13.56
98.74	13.86];
units.tL_B   = {'d', 'mm'};  label.tL_B = {'time since birth', 'diameter', 'individual B'};  
temp.tL_B    = C2K(15);  units.temp.tL_B = 'K'; label.temp.tL_B = 'temperature';
bibkey.tL_B = 'Hiro1972';
%
data.tN_B = [ ... time since hatch, d reprod rate, eggs/d
0        0 
67.90	17.74
69.99	76.49
71.92	168.94
73.98	396.12
75.81	261.21
77.71	575.42
79.77	8.21
81.66	330.84
83.78	190.29
85.62	855.38
87.83	153.42
89.82	751.12
92.11	402.84
94.78	343.64
96.53	688.74];
data.tN_B(:,2) = cumsum(data.tN_B(:,2));
units.tN_B   = {'d', '#'};  label.tN_B = {'time since birth', 'cumulative # of eggs', 'individual B'};  
temp.tN_B    = C2K(15);  units.temp.tN_B = 'K'; label.temp.tN_B = 'temperature';
bibkey.tN_B = 'Hiro1972';
%
% *Individual C* (open white squares, fig.1,3,4 of the original paper)
data.tJX_C = [ ... time since hatch, d ingestion rate mugC/d
25.91	1.92
27.91	2
29.81	3.23
32.02	0.61
34.02	0.18
36.13	8.29
38.45	9.93
41.72	11.37
43.53	43.07
45.76	76.82
48.29	74.14
50.09	90.86
51.90	135.40
54.24	164.84
55.69	121.75
57.92	153.36
59.88	259.89
62.00	291.53
64.21	291.05
66.01	309.92
67.78	266.76
70.00	276.98
72.16	368.50
74.16	361.65
76.49	391.10
78.01	270.99
80.17	976.41
82.24	892.54
84.17	357.37
86.27	540.88
88.10	414.29
89.89	413.90
92.16	118.23
94.10	603.38
96.02	446.82];
units.tJX_C   = {'d', 'mugC/d'};  label.tJX_C = {'time since birth', 'ingestion rate', 'individual C'};  
bibkey.tJX_C = 'Hiro1972'; 
tJX.tJX_C = data.tJX_C; units.tJX.tJX_C   = {'d', 'mugC/d'};  label.tJX.tJX_C = {'time since birth', 'ingestion rate'};  
treat.tJX_C = {0}; units.treat.tJX_C = ''; label.treat.tJX_C = '';
%
data.tL_C =  [ ... time since hatch, d diameter, cm
0.28	0.06
14.73	0.52
19.07	1.02
23.00	1.27
24.96	1.52
27.07	1.60
29.03	1.60
31.00	1.73
32.96	1.73
35.34	1.76
37.17	1.84
38.85	2.09
41.23	2.28
43.34	2.37
45.02	2.51
47.41	2.89
49.23	4.60
51.19	6.38
53.30	8.09
55.12	8.73
56.94	9.03
59.19	9.23
61.57	9.84
63.39	10.48
65.22	10.31
67.32	10.28
69.42	10.87
71.39	10.70
73.49	11.48
75.18	11.42
77.42	11.59
78.82	11.56
81.21	12.90
82.89	13.68
84.85	13.90
86.82	13.79
88.92	13.87
90.88	14.12
94.95	13.05
96.77	13.58
98.60	13.67];
units.tL_C   = {'d', 'mm'};  label.tL_C = {'time since birth', 'diameter', 'individual C'};  
temp.tL_C    = C2K(15);  units.temp.tL_C = 'K'; label.temp.tL_C = 'temperature';
bibkey.tL_C = 'Hiro1972';
%
data.tN_C = [ ... time since hatch, d reprod rate eggs/d
0 0 
47.94	72.94
55.89	75.00
59.94	69.01
61.85	324.27
63.95	304.42
65.90	295.82
68.02	166.50
69.92	469.48
71.65	118.44
73.94	626.30
75.85	847.87
77.67	847.70
79.90	55.91
81.54	243.83
83.54	757.33
85.60	964.85
90.02	411.46
94.74	534.52
96.64	845.92];
data.tN_C(:,2) = cumsum(data.tN_C(:,2)); % cumulative number of eggs
units.tN_C   = {'d', '#'};  label.tN_C = {'time since birth', 'cumulative # of eggs', 'individual C'};  
temp.tN_C    = C2K(15);  units.temp.tN_C = 'K'; label.temp.tN_C = 'temperature';
bibkey.tN_C = 'Hiro1972';

% length dry mass relationship (fig.5 of the original paper)
data.LWd = [ ... diameter, mm dry mass, mg
2.32	0.58
2.37	0.29
2.46	0.25
2.72	0.48
2.82	0.37
3.16	0.91
3.47	0.91
3.48	1.36
3.51	3.56
3.94	2.54
4.43	1.77
4.56	2.37
4.63	3.02
4.76	3.45
4.93	2.10
5.45	4.63
5.65	3.14
5.66	4.10
5.81	3.89
5.99	5.36
5.99	6.30
6.17	8.01
6.29	3.44
6.65	4.56
6.85	7.00
6.86	8.56
7.36	12.62
7.67	15.42
7.68	18.36
7.74	10.32
7.92	6.81
8.08	13.13
8.65	17.62
8.85	11.32
9.01	19.87
9.41	28.14
9.52	23.96
9.81	38.29
9.88	17.59
10.07	33.48
10.31	23.62
10.43	21.22
11.04	31.28
11.17	26.27
11.67	41.99
11.81	36.22
12.50	54.13
13.40	83.07
13.74	65.24
14.51	77.62];
units.LWd   = {'mm', 'mg'};  label.LWd = {'length', 'dry weight', 'diameter'};  
bibkey.LWd = 'Hiro1972';
comment.LWd = 'equatorial length (measured in Hiro1972) is equal to 0.8 polar';

% dioxygen consumption per length at two temperature (mul O2/d)
data.LJO_13 = [ ... diameter, mm dioxygen consumption, mul O2/h
1.99	0.80
2.38	0.70
2.50	0.86
2.77	0.58
3.26	0.94
3.96	3.42
4.33	1.39
5.03	2.61
5.65	4.20
5.95	5.55
6.65	6.46
6.68	7.97
7.12	8.95
7.16	5.60
7.65	3.23
7.66	3.55
8.44	9.91
8.47	5.33
8.60	11.40
8.66	7.48
8.70	9.45
8.78	14.74
9.75	12.94
9.76	13.88
9.78	15.78
9.80	16.93
9.98	19.70
10.00	22.14
10.34	11.64
11.27	18.33
11.66	22.35];
units.LJO_13  = {'mm', 'mul O2/h'};  label.LJO_13 = {'diameter', 'O_2 consumption', '13 C'};  
temp.LJO_13   = C2K(13);  units.temp.LJO_13 = 'K'; label.temp.LJO_13 = 'temperature';
bibkey.LJO_13 = 'Hiro1972';
% --------------
data.LJO_11 = [ ... diameter, mm dioxygen consumption, mul O2/h
4.89	1.40
5.83	4.35
5.84	2.18
5.89	3.32
5.90	3.65
6.16	3.02
6.42	5.23
6.70	4.24
6.71	4.76
6.77	7.51
7.08	3.24
7.10	3.72
7.12	8.95
7.18	6.37
7.68	8.73
7.96	5.28
8.06	4.59
8.65	6.98
8.87	5.46
9.78	7.21
9.81	8.40
10.16	10.48
11.37	13.37
11.58	15.74
11.97	17.28
12.00	20.11];
units.LJO_11   = {'mm', 'mul O2/h'};  label.LJO_11 = {'diameter', 'O_2 consumption', '11.5 C'};  
temp.LJO_11    = C2K(11.5);  units.temp.LJO_11 = 'K'; label.temp.LJO_11 = 'temperature';
bibkey.LJO_11 = 'Hiro1972';

% length dry mass relationships
data.LWd_ThibBowe2004 = [ ... polar length (mm), dry mass (mg)
5.07	2.50
6.61	8.07
6.93	6.29
7.59	6.71
7.89	8.00
8.10	4.21
8.23	9.79
8.55	11.64
9.01	9.64
9.17	9.64
9.54	12.14
10.12	15.14
10.26	14.14
10.73	13.14
10.92	14.14
11.05	26.93
11.23	22.29
11.36	24.07
11.39	15.07
11.53	14.50
11.61	21.64
11.69	18.79
12.01	20.50
12.64	20.93
12.67	25.29
12.75	22.64
12.81	20.50
12.86	20.86
12.96	13.71
12.99	26.21
13.42	29.71
13.42	27.21
13.42	20.14
13.44	22.64
13.44	23.79
13.63	25.07
13.78	24.64
13.79	31.86
13.86	22.50
14.21	26.93
14.55	22.50
14.69	40.14
15.03	34.29
15.64	30.71
15.65	32.71
15.81	36.86
16.12	26.86
16.12	43.50
16.28	43.86
16.60	42.50
16.79	39.50
17.40	43.93];
units.LWd_ThibBowe2004   = {'mm', 'mg'};  label.LWd_ThibBowe2004 = {'length', 'dry weight', 'polar length'};  
bibkey.LWd_ThibBowe2004 = 'ThibBowe2004';
comment.LWd_ThibBowe2004 = 'equatorial length (measured in Hiro1972) is equal to 0.8 polar';
  
%% set weights for all real data
weights = setweights(data, []);

%% set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);

%% pack auxData and txtData for output
auxData.temp = temp;
auxData.tJX = tJX;
auxData.treat = treat;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Group plots
set1 = {'LJO_13','LJO_11'}; subtitle1 = {'Data at 13, 11.5 C'};
set2 = {'LWd','LWd_ThibBowe2004'}; subtitle2 = {'Data for diameter, polar length'};
set3 = {'tL_A','tL_B','tL_C'}; subtitle3 = {'Individual A, B, C'};
set4 = {'tN_A','tN_B','tN_C'}; subtitle4 = {'Individual A, B, C'};
set5 = {'tJX_A','tJX_B','tJX_C'}; subtitle5 = {'Individual A, B, C'};
metaData.grp.sets = {set1,set2,set3,set4,set5};
metaData.grp.subtitle = {subtitle1,subtitle2,subtitle3,subtitle4,subtitle5};

%% Discussion points
D1 = 'Chemical pars are assumped to relate to ash-free dry mass; MaleFaga1993 report ash free dry mass over dry mass ratio of 0.263 - 0.297 with mean 0.279, which makes del_W = 3.5842';
D2 = 'Length measurements from Hiro1972 are equatorial length but more recent studies use polar length';
D3 = 'growth and reprod expectations of indivduals A,B,C use measured ingestion as forcing functions';
metaData.discussion = struct('D1', D1, 'D2', D2, 'D3', D3);

%% Facts
F1 = 'Common ctenophore in the West Coast of united states';
metaData.bibkey.F1 = 'Wiki'; 
F2 = 'Hermaphrodites and breeding can occur at all sizes';
metaData.bibkey.F2 = 'jellieszone'; 
F3 = 'Nice video of feeding';
metaData.bibkey.F3 = 'youtube'; 
metaData.facts = struct('F1',F1,'F2',F2,'F3',F3);

%% Links
metaData.links.id_CoL = '6VRRV'; % Cat of Life
metaData.links.id_ITIS = '53863'; % ITIS
metaData.links.id_EoL = '45502531'; % Ency of Life
metaData.links.id_Wiki = 'Pleurobrachia_bachei'; % Wikipedia
metaData.links.id_ADW = 'Pleurobrachia_bachei'; % ADW
metaData.links.id_Taxo = '12310'; % Taxonomicon
metaData.links.id_WoRMS = '265191'; % WoRMS


%% References
bibkey = 'Wiki'; type = 'Misc'; bib = ...
'howpublished = {\url{http://en.wikipedia.org/wiki/Pleurobrachia_bachei}}';
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
bibkey = 'Hiro1972'; type = 'Incollection'; bib = [ ... 
'author = {Hirota, J.}, ' ... 
'year = {1972}, ' ...
'title = {Laboratory culture and metabolism of the planktonic ctenophore \emph{Pleurobrachia bachei} {A}. {A}gassiz}, ' ...
'booktitle = {Biological Oceanography of the northern North Pacific Ocean}, ' ...
'editor = {A. Y. Takenouti et al}, ' ...
'publisher = {Idemitsu Shoten}, '...
'address = {Tokyo}, ' ...
'pages = {465--484}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'ThibBowe2004'; type = 'Article'; bib = [ ... 
'author = {Thibault-Botha, D. and Bowen, T.}, ' ... 
'year = {2004}, ' ...
'title = {Impact of formalin preservation on \emph{Pleurobrachia bachei} ({C}tenophora)}, ' ...
'journal = {Journal of Experimental Marine Biology and Ecology}, ' ...
'volume = {303}, ' ...
'pages = {11--17}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'jellieszone'; type = 'Misc'; bib = ...
'howpublished = {\url{http://jellieszone.com/pleurobrachia.htm}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'youtube'; type = 'Misc'; bib = ...
'howpublished = {\url{http://www.youtube.com/watch?v=zsMUeo4qJjk}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'MaleFaga1993'; type = 'Article'; bib = [ ... 
'author = {Malej, A. and Faganeli, J. and Pezdic, J.}, ' ... 
'year = {1993}, ' ...
'title = {Stable isotope and biochemical fractionation in the marine pelagic food chain: the jellyfish \emph{Pelagia noctiluca} and net zooplantkton.}, ' ...
'journal = {Marine  Biology}, ' ...
'volume = {116}, ' ...
'pages = {565--570}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
