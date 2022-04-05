function [data, auxData, metaData, txtData, weights] = mydata_Sus_scrofa

%% set metaData
metaData.phylum     = 'Chordata'; 
metaData.class      = 'Mammalia'; 
metaData.order      = 'Cetartiodactyla'; 
metaData.family     = 'Suidae';
metaData.species    = 'Sus_scrofa'; 
metaData.species_en = 'Wild boar'; 

metaData.ecoCode.climate = {'Aw', 'Cfa', 'Cfb', 'Dfa', 'Dfb', 'Dwa', 'Dwb'};
metaData.ecoCode.ecozone = {'THp', 'TPi'};
metaData.ecoCode.habitat = {'0iTf', '0iTh'};
metaData.ecoCode.embryo  = {'Tv'};
metaData.ecoCode.migrate = {};
metaData.ecoCode.food    = {'bxM', 'xiO'};
metaData.ecoCode.gender  = {'Dg'};
metaData.ecoCode.reprod  = {'O'};

metaData.T_typical  = C2K(39); % K, body temp
metaData.data_0     = {'tg'; 'ax'; 'ap'; 'am';'Wwb'; 'Wwx';  'Wwi'; 'Ri'}; 
metaData.data_1     = {'t-Ww'}; 

metaData.COMPLETE = 2.5; % using criteria of LikaKear2011

metaData.author      = {'Bas Kooijman'};    
metaData.date_subm   = [2017 02 19];              
metaData.email       = {'bas.kooijman@vu.nl'};            
metaData.address     = {'VU University Amsterdam'};   

metaData.curator     = {'Starrlight Augustine'};
metaData.email_cur   = {'starrlight.augustine@akvaplan.niva.no'}; 
metaData.date_acc    = [2017 02 19]; 

%% set data
% zero-variate data

data.tg = 115;    units.tg = 'd';    label.tg = 'gestation time';             bibkey.tg =  'AnAge';   
  temp.tg = C2K(39);  units.temp.tg = 'K'; label.temp.tg = 'temperature';
data.tx =   56;  units.tx = 'd';    label.tx = 'time since birth at weaning'; bibkey.tx = 'AnAge';   
  temp.tx = C2K(39);  units.temp.tx = 'K'; label.temp.tx = 'temperature';
data.tp = 334;    units.tp = 'd';    label.tp = 'time since birth at puberty for female'; bibkey.tp = 'AnAge';
  temp.tp = C2K(39);  units.temp.tp = 'K'; label.temp.tp = 'temperature';
data.am = 27*365;    units.am = 'd';    label.am = 'life span';              bibkey.am = 'AnAge';   
  temp.am = C2K(39);  units.temp.am = 'K'; label.temp.am = 'temperature'; 
  comment.am =  'life span between 15 and 25 yr ';
  
data.Wwb = 960;   units.Wwb = 'g';   label.Wwb = 'wet weight at birth';     bibkey.Wwb = 'AnAge';
data.Wwx = 5700;   units.Wwx = 'g';   label.Wwx = 'wet weight at weaning';   bibkey.Wwx = 'AnAge';
data.Wwim = 130000;  units.Wwim = 'g';   label.Wwim = 'ultimate wet weight males'; bibkey.Wwim = 'AnAge';
  
data.Ri  = 7/230;   units.Ri  = '#/d'; label.Ri  = 'maximum reprod rate';     bibkey.Ri  = {'AnAge'};   
  temp.Ri = C2K(39);  units.temp.Ri = 'K'; label.temp.Ri = 'temperature';

% uni-variate data
% time-weight data
data.tW_f = [ % time since birth (d), weight (kg)
89.791	    11.296
267.462	    23.891
449.884	    29.550
632.223	    33.920
817.015	    36.031
1002.059	42.014
1184.051	41.061
1371.245	40.108
1550.983	44.477
1732.713	39.492
1917.463	40.958
2104.888	43.554]; 
units.tW_f  = {'d', 'kg'};  label.tW_f = {'time since birth', 'total weight', 'female'};  
temp.tW_f  = C2K(39);  units.temp.tW_f = 'K'; label.temp.tW_f = 'temperature';
bibkey.tW_f = 'DzieClar1990';
comment.tW_f = 'Data for females';
% 
data.tW_m = [ ... % time since birth (d), weight (kg)
82.093	    12.908
264.977	    25.665
455.652	    38.261
635.642	    46.501
815.599	    54.257
1005.646	57.176
1188.016	62.029
1375.356	63.334
1554.611	60.284
1734.380	65.137
1918.690	59.829
2106.230	64.199]; 
units.tW_m  = {'d', 'kg'};  label.tW_m = {'time since birth', 'total weight', 'male'};  
temp.tW_m  = C2K(39);  units.temp.tW_m = 'K'; label.temp.tW_m = 'temperature';
bibkey.tW_m = 'DzieClar1990';

%% set weights for all real data
weights = setweights(data, []);
weights.tW_f = 10 * weights.tW_f;
weights.tW_m = 10 * weights.tW_m;

%% set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);

%% pack auxData and txtData for output
auxData.temp = temp;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Group plots
set1 = {'tW_f','tW_m'}; subtitle1 = {'Data for females, males'};
metaData.grp.sets = {set1};
metaData.grp.subtitle = {subtitle1};

%% Discussion points
D1 = 'The max weight in New Zealand is small for a wild boar, modelled with low f';
D2 = 'Males are assumend to differ from females by {p_Am} only';
metaData.discussion = struct('D1', D1, 'D2', D2);

%% Links
metaData.links.id_CoL = '53HGR'; % Cat of Life
metaData.links.id_ITIS = '180722'; % ITIS
metaData.links.id_EoL = '328663'; % Ency of Life
metaData.links.id_Wiki = 'Sus_scrofa'; % Wikipedia
metaData.links.id_ADW = 'Sus_scrofa'; % ADW
metaData.links.id_Taxo = '67678'; % Taxonomicon
metaData.links.id_WoRMS = '1469456'; % WoRMS
metaData.links.id_MSW3 = '14200054'; % MSW3
metaData.links.id_AnAge = 'Sus_scrofa'; % AnAge


%% References
bibkey = 'Wiki'; type = 'Misc'; bib = ...
'howpublished = {\url{http://en.wikipedia.org/wiki/Sus_scrofa}}';
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
bibkey = 'DzieClar1990'; type = 'Article'; bib = [ ... 
'author = {Dzieciolowski, R. M.  and Clarke, C. M. H. and Fredric, B. J.}, ' ... 
'year = {1990}, ' ...
'title = {Growth of feral pigs in {N}ew {Z}ealand}, ' ...
'journal = {Acta Theriologica}, ' ...
'volume = {35}, ' ...
'pages = {77--88}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'AnAge'; type = 'Misc'; bib = ...
'howpublished = {\url{http://genomics.senescence.info/species/entry.php?species=Sus_scrofa}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'ADW'; type = 'Misc'; bib = ...
'howpublished = {\url{http://animaldiversity.org/accounts/Sus_scrofa/}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];

