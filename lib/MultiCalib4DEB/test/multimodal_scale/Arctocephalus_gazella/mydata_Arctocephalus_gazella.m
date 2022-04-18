function [data, auxData, metaData, txtData, weights] = mydata_Arctocephalus_gazella
%% set metaData
metaData.phylum     = 'Chordata'; 
metaData.class      = 'Mammalia'; 
metaData.order      = 'Carnivora'; 
metaData.family     = 'Otariidae';
metaData.species    = 'Arctocephalus_gazella'; 
metaData.species_en = 'Antarctic fur seal'; 

metaData.ecoCode.climate = {'MC'};
metaData.ecoCode.ecozone = {'MS'};
metaData.ecoCode.habitat = {'0iMc'};
metaData.ecoCode.embryo  = {'Tv'};
metaData.ecoCode.migrate = {};
metaData.ecoCode.food    = {'bxM', 'xiCvf', 'xiCic', 'xiCik'};
metaData.ecoCode.gender  = {'Dg'};
metaData.ecoCode.reprod  = {'O'};

metaData.T_typical  = C2K(37.5); % K, body temp
metaData.data_0     = {'tg'; 'ax'; 'ap'; 'am'; 'Wwb'; 'Wwi'; 'Ri'}; 
metaData.data_1     = {'t-Ww'}; 

metaData.COMPLETE = 2.5; % using criteria of LikaKear2011

metaData.author   = {'Bas Kooijman','Starrlight Augustine'};    
metaData.date_subm = [2018 11 01];              
metaData.email    = {'bas.kooijman@vu.nl'};            
metaData.address  = {'VU University Amsterdam'};   

metaData.curator     = {'Starrlight Augustine'};
metaData.email_cur   = {'starrlight.augustine@akvaplan.niva.no'}; 
metaData.date_acc    = [2018 11 01]; 

%% set data
% zero-variate data

data.tg = 257;    units.tg = 'd';    label.tg = 'gestation time';             bibkey.tg = 'AnAge';   
  temp.tg = C2K(37.5);  units.temp.tg = 'K'; label.temp.tg = 'temperature';
  comment.tg = 'Temp for Zalophus_californianus';
data.tx = 112;     units.tx = 'd';    label.tx = 'time since birth at weaning'; bibkey.tx = 'AnAge';   
  temp.tx = C2K(37.5);  units.temp.tx = 'K'; label.temp.tx = 'temperature';
data.tp = 1278;   units.tp = 'd';    label.tp = 'time since birth at puberty'; bibkey.tp = 'AnAge';
  temp.tp = C2K(37.5);  units.temp.tp = 'K'; label.temp.tp = 'temperature';
data.tpm = 1278;  units.tpm = 'd';   label.tpm = 'time since birth at puberty'; bibkey.tpm = 'AnAge';
   temp.tpm = C2K(37.5);  units.temp.tpm = 'K'; label.temp.tpm = 'temperature';
data.am = 30.6*365; units.am = 'd';    label.am = 'life span';                bibkey.am = 'AnAge';   
  temp.am = C2K(37.5);  units.temp.am = 'K'; label.temp.am = 'temperature';
  comment.am = 'data for Arctocephalus australis';
  
data.Wwb = 4200; units.Wwb = 'g';  label.Wwb = 'wet weight at birth';     bibkey.Wwb = 'AnAge';
data.Wwi = 35e3; units.Wwi = 'g';   label.Wwi = 'ultimate wet weight for females'; bibkey.Wwi = 'AnAge';
  comment.Wwi = '22 to 50 kg';
data.Wwim = 200e3; units.Wwim = 'g'; label.Wwim = 'ultimate wet weight for males';  bibkey.Wwim = 'Wiki';
  comment.Wwim = 'Wiki: 91 to 215 kg; EoL: 130 to 2000 kg (but this must probably be to 200 kg)';

data.Ri  = 1/365; units.Ri  = '#/d'; label.Ri  = 'maximum reprod rate';     bibkey.Ri  = 'AnAge';   
  temp.Ri = C2K(37.5); units.temp.Ri = 'K'; label.temp.Ri = 'temperature';
  
% uni-variate data
% t-W data 
data.tW = [ ... % time since birth (d), weight (kg)
  0	 4.227
 14	 6.398
 32	 9.259
 55	10.393
 66	11.927
 84	13.083
 97	14.465
111	15.492];
units.tW   = {'d', 'kg'};  label.tW = {'time since birth', 'weight'};  
temp.tW    = C2K(38.1);  units.temp.tW = 'K'; label.temp.tW = 'temperature';
bibkey.tW = 'Kerl1985';
comment.tW = 'Data from Marion Island, means of both male and female pups';

% t-W data 
data.tW_f = [ ... % time since birth (yr), weight (kg)
0.014	4.430
0.357	13.527
1.044	16.501
1.991	20.555
2.994	24.603
3.955	28.932
4.985	30.486
5.988	31.489
7.032	32.211
7.952	34.330
8.941	34.504
9.971	35.782
10.973	34.847
15.300	38.273];
data.tW_f(:,1) = data.tW_f(:,1) * 365;
units.tW_f   = {'d', 'kg'};  label.tW_f = {'time since birth', 'weight', 'female'};  
temp.tW_f    = C2K(38.1);  units.temp.tW_f = 'K'; label.temp.tW_f = 'temperature';
bibkey.tW_f = 'Payn1979';
comment.tW_f = 'data for females';
%
data.tW_m = [ ... % time since birth (yr), weight (kg)
0.014	6.645
0.288	16.856
0.989	22.319
1.991	30.797
2.994	39.828
3.997	52.734
5.013	69.237
5.947	78.552
6.991	115.814
7.966	122.633
8.900	138.592
9.943	131.286];
data.tW_m(:,1) = data.tW_m(:,1) * 365;
units.tW_m   = {'d', 'kg'};  label.tW_m = {'time since birth', 'weight', 'male'};  
temp.tW_m    = C2K(38.1);  units.temp.tW_m = 'K'; label.temp.tW_m = 'temperature';
bibkey.tW_m = 'Payn1979';
comment.tW_m = 'data for males';

%% set weights for all real data
weights = setweights(data, []);
weights.tW = 2 * weights.tW;
weights.tW_f = 2 * weights.tW_f;
weights.tW_m = 2 * weights.tW_m;
weights.Wwi = 2 * weights.Wwi;
weights.Wwim = 2 * weights.Wwim;
weights.Wwb = 5 * weights.Wwb;

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
D1 = 'Males are assumed to differ from females by {p_Am} and E_Hp only';
D2 = 'Male {p_Am} jumps upward at puberty, as discussed in Kooy2014 under type A acceleration';
metaData.discussion = struct('D1', D1, 'D2', D2);

%% Acknowledgment
metaData.acknowledgment = 'The creation of this entry was supported by the Norwegian Science Council (NFR 255295)';

%% Links
metaData.links.id_CoL = '5W3QR'; % Cat of Life
metaData.links.id_ITIS = '180630'; % ITIS
metaData.links.id_EoL = '46559193'; % Ency of Life
metaData.links.id_Wiki = 'Arctocephalus_gazella'; % Wikipedia
metaData.links.id_ADW = 'Arctocephalus_gazella'; % ADW
metaData.links.id_Taxo = '67390'; % Taxonomicon
metaData.links.id_WoRMS = '231404'; % WoRMS
metaData.links.id_MSW3 = '14001001'; % MSW3
metaData.links.id_AnAge = 'Arctocephalus_gazella'; % AnAge


%% References
bibkey = 'Wiki'; type = 'Misc'; bib = ...
'howpublished = {\url{http://en.wikipedia.org/wiki/Arctocephalus_gazella}}';
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
bibkey = 'Kerl1985'; type = 'Article'; bib = [ ... 
'author = {G. I. H. Kerley}, ' ... 
'year = {1985}, ' ...
'title = {Pup growth in the fur seals \emph{Arctocephalus tropicalis} and \emph{A. gazella} on {M}arion {I}sland}, ' ...
'journal = {J. Zool., Lond.}, ' ...
'volume = {205}, ' ...
'pages = {315-324}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Payn1979'; type = 'Article'; bib = [ ... 
'author = {M. R. Payne}, ' ... 
'year = {1979}, ' ...
'title = {Growth in the {A}ntarctic fur seal \emph{Arctocephalus gazella}}, ' ...
'journal = {J. Zool., Lond.}, ' ...
'volume = {187}, ' ...
'pages = {1-20}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'AnAge'; type = 'Misc'; bib = ...
'howpublished = {\url{http://genomics.senescence.info/species/entry.php?species=Arctocephalus_gazella}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'EoL'; type = 'Misc'; bib = ...
'howpublished = {\url{http://eol.org/pages/328620/overview}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];


