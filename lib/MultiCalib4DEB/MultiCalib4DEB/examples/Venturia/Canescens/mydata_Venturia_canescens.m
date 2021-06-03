function [data, auxData, metaData, txtData, weights] = mydata_Venturia_canescens

%% set metaData
metaData.phylum     = 'Arthropoda'; 
metaData.class      = 'Insecta'; 
metaData.order      = 'Hymenoptera'; 
metaData.family     = 'Ichneumonidae';
metaData.species    = 'Venturia_canescens'; 
metaData.species_en = 'Parasitic wasp'; 
metaData.ecoCode.climate = {'BSk', 'Csa', 'Cfb', 'Dfb'};
metaData.ecoCode.ecozone = {'THp'};
metaData.ecoCode.habitat = {'0iTf', '0iTi', '0iTg'};
metaData.ecoCode.embryo  = {'Th'};
metaData.ecoCode.migrate = {};
metaData.ecoCode.food    = {'bjTii', 'eiHn'};
metaData.ecoCode.gender  = {'D'};
metaData.ecoCode.reprod  = {'O'};
metaData.T_typical  = C2K(25); % K, body temp
metaData.data_0     = {'ab'; 'aj'; 'ae'; 'am'; 'Wd0'; 'Wdb'; 'Wdj'; 'Wde'}; 
metaData.data_1     = {'t-Wd'; 't-N'}; 

metaData.COMPLETE = 2.5; % using criteria of LikaKear2011

metaData.author   = {'Ana Lopez Llandres'; 'Bas Kooijman'};    
metaData.date_subm = [2013 07 18];              
metaData.email    = {'anallandres@gmail.com'};            
metaData.address  = {'University of Tours'};   

metaData.author_mod_1   = {'Bas Kooijman'};    
metaData.date_mod_1 = [2016 02 20];              
metaData.email_mod_1    = {'bas.kooijman@vu.nl'};            
metaData.address_mod_1  = {'VU University Amsterdam'};   

metaData.author_mod_2   = {'Bas Kooijman'};    
metaData.date_mod_2 = [2019 08 24];              
metaData.email_mod_2    = {'bas.kooijman@vu.nl'};            
metaData.address_mod_2  = {'VU University Amsterdam'};   

metaData.curator     = {'Starrlight Augustine'};
metaData.email_cur   = {'starrlight.augustine@akvaplan.niva.no'}; 
metaData.date_acc    = [2019 08 24]; 

%% set data
% zero-variate data

data.ab = 4;         units.ab = 'd';    label.ab = 'age at birth';                  bibkey.ab = 'HarvHarv1994';   
  temp.ab = C2K(25); units.temp.ab = 'K'; label.temp.ab = 'temperature';
data.tj = 5;        units.tj = 'd';    label.tj = 'time since birth at pupation';  bibkey.tj = 'HarvHarv1994';   
  temp.tj = C2K(25); units.temp.tj = 'K'; label.temp.tj = 'temperature';
data.te = 10;        units.te = 'd';    label.te = 'time since pupation at emergence'; bibkey.te = 'HarvHarv1994';
  temp.te = C2K(25); units.temp.te = 'K'; label.temp.te = 'temperature';
data.am = 36.5;      units.am = 'd';    label.am = 'life span as imago';            bibkey.am = 'HarvHarv1994';   
  temp.am = C2K(25); units.temp.am = 'K'; label.temp.am = 'temperature';
  comment.am = 'while fed with honey solution add libitum';

data.Wd0 = 1.87e-7;  units.Wd0 = 'g'; label.Wd0 = 'initial eggs dry weight';        bibkey.Wd0 = 'HarvHarv1994';
  comment.Wd0 = 'calculated from the length (l= 0.027 cm) and width (w = 0.0047 cm radio=r2 0.0047/2= 0.0024) of a egg picture and by assuming that the egg is cylindrical and the density of the eggs is 0.4 g/cm^3, Mass = density*pi*l*r2^2 =0.4 *pi*0.027* 0.0024^2= 1.87e-007g * pi * 0.0047^2/4';
data.Wdb = 6.90e-5;  units.Wdb = 'g'; label.Wdb = 'dry weight at hatch';            bibkey.Wdb = 'HarvHarv1994';
data.Wdj = 4.77e-3;  units.Wdj = 'g'; label.Wdj = 'dry weight at pupation';         bibkey.Wdj = 'HarvHarv1994';
data.Wde = 1.75e-3;  units.Wde = 'g'; label.Wde = 'dry weight at emergence';        bibkey.Wde = 'HarvHarv1994';

% uni-variate data

% larval growth (Harvey et al. 1994, graph 4 larvae growth when feeding in instar 5 of the host)
data.tWd =  [... % time since hatch (d), larval dry weight (mg)
0	0.069444444 
1	0.069444444
2	0.222222222
3	0.722222222
4	3.180555556
5	3.666666667];
data.tWd(:,2) = data.tWd(:,2)/ 1e3; % convert mg to g
units.tWd   = {'d', 'g'};  label.tWd = {'time since hatch', 'larva dry weight'};  
temp.tWd    = C2K(25);  units.temp.tWd = 'K'; label.temp.tWd = 'temperature';
bibkey.tWd = 'HarvHarv1994';
%
% pupal growth (Harvey et al. 1994 graph 4 pupa growth when after feeding in instar 5 of the host)
data.tWdj =  [... % time since pupation (d), pupal dry weight (mg)
0	4.777777778
1	4.069444444
2	3.972222222
3	2.777777778
4	2.361111111
5	2.736111111
6	2.541666667
7	3.083333333
8	2.805555556
9	2.541666667];
data.tWdj(:,2) = data.tWdj(:,2)/ 1e3; % convert mg to g
units.tWdj   = {'d', 'g'};  label.tWdj = {'time since pupation', 'pupa dry weight'};  
temp.tWdj    = C2K(25);  units.temp.tWdj = 'K'; label.temp.tWdj = 'temperature';
bibkey.tWdj = 'HarvHarv1994';

% Harvey et al. 2001 
data.tN =  [... % time since emergence (d), reprod rate (number progeny/d), 
1	40.20408163
2	30.40816327
3	30.20408163
4	33.36734694
5	32.14285714
6	28.46938776
7	23.7755102
8	18.97959184
9	9.183673469
10	2.857142857
11	3.87755102
12	0.918367347
13	0.408163265
14	0
15	0.306122449
16	0.714285714
17	0.816326531
18	0
19	0
20	0.204081633
21	0
22	0
23	0
24	0
25	0.204081633
26	0
27	0
28	0
29	0
30	0
31	0
32	0
33	0
34	0];
data.tN(:,2) = cumsum(data.tN(:,2)); % cumulative reproduction
units.tN   = {'d', '#'};  label.tN = {'time since emergence', 'cum # of eggs'};  
temp.tN    = C2K(25);  units.temp.tN = 'K'; label.temp.tN = 'temperature';
bibkey.tN = 'HarvHarv1994';
comment.tN = 'Data represents averages of 10 individuals each day, which face high food quantity (costant food access to 50% honey solution) and 24 h/d host access until imago death.';
  
%% set weights for all real data
weights = setweights(data, []);
weights.Wdj = 2 * weights.Wdj;
weights.Wdb = 5 * weights.Wdb;
weights.tj = 5 * weights.tj;
weights.tN = 5 * weights.tN;

%% set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);

%% pack auxData and txtData for output
auxData.temp = temp;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Discussion points
D1 = 'Hydrophic egg is modelled as a new maturity level E_Hx, which preceeds birth';
D2 = 'E_Hx is treated as birth, while at E_Hb uptake switches from absorbtion to feeding'; 
D3 = 'All parasitoid data is from host (moth Plodia interpunctella) that was infected at instar 5';
D4 = 'Assimilation by imago is assumed to cover maintenance costs';
D5 = 'mod_2: no allocation to reproduction during imago-stage';
metaData.discussion = struct('D1', D1, 'D2', D2, 'D3', D3, 'D4', D4, 'D5', D5);

%% Facts
F1 = 'V. canescens is a koinobiont parasitoid wasp, i.e. allows its host to continue development after parasitism. ';
metaData.bibkey.F1 = 'HarvHarv1994'; 
F2 = 'It has hydrophic eggs, meaning that they take up nutrients in the embryo-stage. ';
metaData.bibkey.F2 = 'HarvHarv1994'; 
F3 = 'This species does not host-feed, so host access is just for oviposition. ';
metaData.bibkey.F3 = 'HarvHarv1994'; 
F4 = 'This entry is discussed in LlanMarq2015';
metaData.bibkey.F4 = 'LlanMarq2015'; 
metaData.facts = struct('F1',F1,'F2',F2,'F3',F3,'F4',F4);

%% Links
metaData.links.id_CoL = '25a05f2c5c8f5146d4b515c36d06e089'; % Cat of Life
metaData.links.id_EoL = '3780488'; % Ency of Life
metaData.links.id_Wiki = 'Ichneumonoidea'; % Wikipedia
metaData.links.id_ADW = 'Venturia_canescens'; % ADW
metaData.links.id_Taxo = '27808'; % Taxonomicon

%% References
bibkey = 'Wiki'; type = 'Misc'; bib = ...
'howpublished = {\url{https://en.wikipedia.org/wiki/Parasitoid_wasp}}';
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
bibkey = 'HarvHarv1994'; type = 'Article'; bib = [ ... 
'author = {Harvey, J. A. and Harvey, I. F. and Thompson, D. J.}, ' ... 
'year = {1994}, ' ...
'title = {Flexible Larval Growth Allows Use of a Range of Host Sizes by a Parasitoid Wasp}, ' ...
'journal = {Ecology}, ' ...
'volume = {75}, ' ...
'pages = {1420--1428}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'LlanMarq2015'; type = 'Article'; bib = [ ... 
'author = {A. L. Llandres and G. M. Marques and J. Maino and S. A. L. M. Kooijman and M. R. Kearney and J. Casas}, ' ... 
'year = {2015}, ' ...
'title = {A dynamic energy budget for the whole life-cycle of holometabolous insects}, ' ...
'journal = {Ecological Monographs}, ' ...
'volume = {85}, ' ...
'pages = {353--371}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];

