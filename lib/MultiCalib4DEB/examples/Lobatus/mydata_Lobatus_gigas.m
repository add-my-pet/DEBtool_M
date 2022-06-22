function [data, auxData, metaData, txtData, weights] = mydata_Lobatus_gigas
%% set metaData
metaData.phylum     = 'Mollusca'; 
metaData.class      = 'Gastropoda'; 
metaData.order      = 'Littorinimorpha'; 
metaData.family     = 'Strombidae';
metaData.species    = 'Lobatus_gigas'; 
metaData.species_en = 'Queen conch'; 

metaData.ecoCode.climate = {'MA'};
metaData.ecoCode.ecozone = {'MAW'};
metaData.ecoCode.habitat = {'0jMp', 'jiMb', 'jiMi'};
metaData.ecoCode.embryo  = {'Mp'};
metaData.ecoCode.migrate = {};
metaData.ecoCode.food    = {'bjPp', 'jiHa'};
metaData.ecoCode.gender  = {'D'};
metaData.ecoCode.reprod  = {'O'};

metaData.T_typical  = C2K(27); % K, body temp
metaData.data_0     = {'ab'; 'aj'; 'ap'; 'am'; 'Wwb'; 'Wwp'; 'Wwi'; 'Ri'}; 
metaData.data_1     = {'t-L'; 'L-Ww'}; 

metaData.COMPLETE = 2.5; % using criteria of LikaKear2011

metaData.author   = {'Bas Kooijman'}; 
metaData.date_subm = [2018 12 14]; 
metaData.email    = {'bas.kooijman@vu.nl'}; 
metaData.address  = {'VU University, Amsterdam'};

metaData.curator     = {'Starrlight Augustine'};
metaData.email_cur   = {'starrlight.augustine@akvaplan.niva.no'}; 
metaData.date_acc    = [2018 12 14]; 

%% set data
% zero-variate data

data.ab = 4; units.ab = 'd';    label.ab = 'age at birth';                bibkey.ab = 'Wiki';   
  temp.ab = C2K(27);  units.temp.ab = 'K'; label.temp.ab = 'temperature'; 
  comment.ab = '3 to 5 d';
data.tj = 20;    units.tj = 'd';    label.tj = 'time since birth at settlement'; bibkey.tj = 'Wiki';
  temp.tj = C2K(27);  units.temp.tj = 'K'; label.temp.tj = 'temperature';
  comment.tj = '16 to 40 d';
data.tp = 3.5*365;    units.tp = 'd';    label.tp = 'time since birth at puberty'; bibkey.tp = 'Wiki';
  temp.tp = C2K(27);  units.temp.tp = 'K'; label.temp.tp = 'temperature';
  comment.tp = '3 to 4 yr';
data.am = 40*365; units.am = 'd';    label.am = 'life span';                bibkey.am = 'Wiki';   
  temp.am = C2K(27);  units.temp.am = 'K'; label.temp.am = 'temperature'; 
  comment.am = 'usually 7 yr, in deeper water much more';

data.Wwb = 1.4e-5;  units.Wwb = 'g'; label.Wwb = 'wet weight at birth'; bibkey.Wwb = 'guess';
  comment.Wwb = 'based on guessed egg diameter of 0.3 mm: pi/6*0.01^3';
data.Wwp = 300;  units.Wwp = 'g'; label.Wwp = 'tissue wet weight at puberty'; bibkey.Wwp = 'Appe1988';
data.Wwi = 500;  units.Wwi = 'g'; label.Wwi = 'ultimate tissue wet weight'; bibkey.Wwi = 'Appe1988';

data.Ri = 8.5*4e5/365; units.Ri = 'J/d.g'; label.Ri = 'max repoduction rate'; bibkey.Ri = 'Wiki';
  temp.Ri = C2K(27);  units.temp.Ri = 'K'; label.temp.Ri = 'temperature';
  comment.Ri = '8 to 9 egg masses per yr, each 1.8e5–4.6e5 eggs, but numbers can be as high as 7.5e5 eggs';

% uni-variate data
% t-Ww data
tL = [ ... % time since ap (yr), shell lip thickness (cm)
    0.25 0.48
    0.50 0.94
    0.75 1.34
    1.00 1.72
    1.25 2.08
    1.50 2.37
    1.75 2.64
    2.00 2.90
    2.25 3.12];
% 
LW_f = [ ... % shell lip thickness (cm), wet tissue weight (g)
0.205	382.909
0.299	322.200
0.303	337.532
0.823	422.301
1.039	411.871
1.094	441.180
1.441	462.693
1.443	470.692
1.505	525.665
1.844	434.180
1.917	450.815
1.942	415.470
1.952	456.466
2.085	468.740
2.086	471.406
2.402	505.932
2.523	390.212
2.604	465.509
3.080	486.631];
data.tW_f = [spline1(LW_f(:,1), tL)*365, LW_f(:,2)];
units.tW_f   = {'d', 'g'};  label.tW_f = {'time since puberty', 'wet tissue weight'};  
temp.tW_f = C2K(27);  units.temp.tW_f = 'K'; label.temp.tW_f = 'temperature';
bibkey.tW_f = 'Appe1988';
comment.tW_f = 'Data for females; time reconstructed from shell lip thickness, which is zero at ap';
%
LW_m = [ ... % shell lip thickness (cm), wet tissue weight (g)
0.205	327.909
0.422	348.479
0.518	351.103
0.858	370.619
1.418	450.370
1.506	447.664
1.521	396.991
1.546	416.979
1.617	400.615
2.065	386.749
2.174	413.367];
data.tW_m = [spline1(LW_m(:,1), tL)*365, LW_m(:,2)];
units.tW_m   = {'d', 'g'};  label.tW_m = {'time since puberty', 'wet tissue weight'};  
temp.tW_m = C2K(27);  units.temp.tW_m = 'K'; label.temp.tW_m = 'temperature';
bibkey.tW_m = 'Appe1988';
comment.LW_m = 'Data for males; time reconstructed from shell lip thickness, which is zero at ap';

%% set weights for all real data
weights = setweights(data, []);
weights.tW_f = 5 * weights.tW_f;
weights.tW_m = 5 * weights.tW_m;
weights.Wwp = 5 * weights.Wwp;

%% set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);
weights.psd.p_M = 5 * weights.psd.p_M;

%% pack auxData and txtData for output
auxData.temp = temp;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Group plots
set1 = {'tW_f','tW_m'}; comment1 = {'Data for females, males'};
metaData.grp.sets = {set1};
metaData.grp.comment = {comment1};

%% Discussion points
D1 = 'Temperatures are guessed, based on preferred temperature, sealifebase';
D2 = 'Males are assumed not to differ from females';     
metaData.discussion = struct('D1', D1, 'D2', D2);

%% Links
metaData.links.id_CoL = 'e9cd75257b06d72b4c56c8d5c7070010'; % Cat of Life
metaData.links.id_EoL = '455238'; % Ency of Life
metaData.links.id_Wiki = 'Lobatus_gigas'; % Wikipedia
metaData.links.id_ADW = 'Strombus_gigas'; % ADW
metaData.links.id_Taxo = '35586'; % Taxonomicon
metaData.links.id_WoRMS = '564730'; % WoRMS
metaData.links.id_molluscabase = '564730'; % MolluscaBase

%% References
bibkey = 'Wiki'; type = 'Misc'; bib = ...
'howpublished = {\url{https://en.wikipedia.org/wiki/Lobatus_gigas}}';
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
bibkey = 'Appe1988'; type = 'Article'; bib = [ ... 
'author = {R. S. Appeldoorn}, ' ... 
'year = {1988}, ' ...
'title = {Age Determination, Growth, Mortality and Age of First Reproduction in Adult Queen Conch, \emph{Strombus gigas} {L}., off {P}uerto {R}ico}, ' ...
'journal = {Fisheries Research}, ' ...
'volume = {6}, ' ...
'pages = {363-378}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'sealifebase'; type = 'Misc'; bib = ...
'howpublished = {\url{https://www.sealifebase.ca/summary/Lobatus-gigas.html}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];

