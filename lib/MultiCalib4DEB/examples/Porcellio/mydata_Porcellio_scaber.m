function [data, auxData, metaData, txtData, weights] = mydata_Porcellio_scaber 

%% set metaData
metaData.phylum     = 'Arthropoda'; 
metaData.class      = 'Malacostraca'; 
metaData.order      = 'Isopoda'; 
metaData.family     = 'Porcellionidae';
metaData.species    = 'Porcellio_scaber'; 
metaData.species_en = 'Rough woodlouse'; 
metaData.ecoCode.climate = {'Cfb', 'Dfb', 'Dfc'};
metaData.ecoCode.ecozone = {'TH', 'TA'};
metaData.ecoCode.habitat = {'0iTf', '0iTg', '0iTi'};
metaData.ecoCode.embryo  = {'Tbf'};
metaData.ecoCode.migrate = {};
metaData.ecoCode.food    = {'biD'};
metaData.ecoCode.gender  = {'D'};
metaData.ecoCode.reprod  = {'O'};
metaData.T_typical  = C2K(20); % K, body temp
metaData.data_0     = {'ab'; 'ap'; 'am'; 'Lb'; 'Lp'; 'Li'; 'Wwb'; 'Wwp'; 'Wwi'; 'Ri'}; 
metaData.data_1     = {'t-Ww'}; 

metaData.COMPLETE = 2.5; % using criteria of LikaKear2011

metaData.author   = {'Jan Baas'};    
metaData.date_subm = [2013 07 18];              
metaData.email    = {'janbaa@ceh.ac.uk'};            
metaData.address  = {'CEH, UK'};   

metaData.author_mod_1   = {'Bas Kooijman'};    
metaData.date_mod_1 = [2016 02 02];              
metaData.email_mod_1    = {'bas.kooijman@vu.nl'};            
metaData.address_mod_1  = {'VU University Amsterdam'};   

metaData.curator     = {'Starrlight Augustine'};
metaData.email_cur   = {'starrlight.augustine@akvaplan.niva.no'}; 
metaData.date_acc    = [2016 02 09]; 

%% set data
% zero-variate data

data.ab = 35;    units.ab = 'd';    label.ab = 'age at birth';                bibkey.ab = 'ADW';   
  temp.ab = C2K(20);  units.temp.ab = 'K'; label.temp.ab = 'temperature';
data.tp = 400;   units.tp = 'd';    label.tp = 'time since birth at puberty'; bibkey.tp = 'ADW';
  temp.tp = C2K(20);  units.temp.tp = 'K'; label.temp.tp = 'temperature';
  comment.tp = 'estimate, based on max 3 broods/year and first reproduction after ca 500 days';
data.am = 1500;  units.am = 'd';    label.am = 'life span';                   bibkey.am = 'ADW';   
  temp.am = C2K(20);  units.temp.am = 'K'; label.temp.am = 'temperature'; 

data.Lb  = 0.32; units.Lb  = 'cm';  label.Lb  = 'total length at birth for female';   bibkey.Lb  = 'Donk1992';
  comment.Lb = 'All lengths exclude antenna';
data.Lbm  = 0.31;  units.Lbm  = 'cm'; label.Lbm  = 'total length at birth for male';  bibkey.Lbm  = 'Donk1992';
data.Lp  = 1.4;  units.Lp  = 'cm';  label.Lp  = 'total length at puberty for female'; bibkey.Lp  = 'Donk1992';
data.Lpm  = 1.2; units.Lpm  = 'cm'; label.Lpm  = 'total length at puberty for male';  bibkey.Lpm  = 'Donk1992';
data.Li  = 1.9;  units.Li  = 'cm';  label.Li  = 'ultimate total length for female';   bibkey.Li  = 'Donk1992';
data.Lim  = 1.7; units.Lim  = 'cm'; label.Lim  = 'ultimate total length for male';    bibkey.Lim  = 'Donk1992';

data.Wwb = 0.4; units.Wwb = 'mg';   label.Wwb = 'dry weight at birth for female';     bibkey.Wwb = 'Donk1992';
  comment.Wwb = 'value reduced by 0.5 for account for adhering water';
data.Wwbm = 0.4; units.Wwbm = 'mg'; label.Wwbm = 'dry weight at birth for male';      bibkey.Wwbm = 'Donk1992';
data.Wwp = 50;   units.Wwp = 'mg';  label.Wwp = 'dry weight at puberty for female';   bibkey.Wwp = 'Donk1992';
  comment.Wwp = 'Read from growth curve for t_p';
data.Wwpm = 45; units.Wwpm = 'mg';  label.Wwpm = 'wet weight at puberty for male';    bibkey.Wwpm = 'Donk1992';
  comment.Wwpm = 'Read from growth curve for t_p';
data.Wwi = 83.4;  units.Wwi = 'mg';   label.Wwi = 'ultimate wet weight for female';   bibkey.Wwi = 'Donk1992';
data.Wwim = 63.4; units.Wwim = 'mg';  label.Wwim = 'ultimate wet weight for male';    bibkey.Wwim = 'Donk1992';

data.Ri  = 0.26;   units.Ri  = '#/d'; label.Ri  = 'maximum reprod rate';              bibkey.Ri  = 'ADW';   
  temp.Ri = C2K(20);  units.temp.Ri = 'K'; label.temp.Ri = 'temperature';

% uni-variate data
% t-W data
data.tW_f = [ ... % time (d), wet weight (g)
    0   0.0032
    7   0.0037
    14  0.0042
    21  0.0051
    28  0.0062
    35  0.0074
    42  0.0088
    47  0.0102
    56  0.0113
    63  0.0128
    70  0.0146
    77  0.0157
    84  0.0172
    91  0.0188
    98  0.0208
    105 0.0226
    112 0.0241
    119 0.0251
    126 0.0269];
units.tW_f   = {'d', 'g'};  label.tW_f = {'time', 'wet weight'};  
temp.tW_f    = C2K(20);  units.temp.tW_f = 'K'; label.temp.tW_f = 'temperature';
bibkey.tW_f = 'Donk1992'; comment.tW_f = 'females';
%
data.tW_m = [ ... % time since birth (d), wet weight (g)
    0   0.0031
    7   0.0036
    14  0.0041
    21  0.0049
    28  0.0058
    35  0.0069
    42  0.0079
    47  0.0089
    56  0.0103
    63  0.0115
    70  0.0125
    77  0.0137
    84  0.0152
    91  0.0166
    98  0.0179
    105 0.0191
    112 0.0200
    119 0.0211
    126 0.0226];
units.tW_m   = {'d', 'g'};  label.tW_m = {'time', 'wet weight'};  
temp.tW_m    = C2K(20);  units.temp.tW_m = 'K'; label.temp.tW_m = 'temperature';
bibkey.tW_m = 'Donk1992'; comment.tW_m = 'males';

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
set1 = {'tW_f','tW_m'}; comment1 = {'Data for females, males'};
metaData.grp.sets = {set1};
metaData.grp.comment = {comment1};

%% Discussion points
D1 = 'dryweight problaby has a large ash content, due to CaCO3 in carapax';
metaData.discussion = struct('D1', D1);

%% Links
metaData.links.id_CoL = 'f7f2e3aa63418de280d2441a2f50a353'; % Cat of Life
metaData.links.id_EoL = '128536'; % Ency of Life
metaData.links.id_Wiki = 'Porcellio_scaber'; % Wikipedia
metaData.links.id_ADW = 'Porcellio_scaber'; % ADW
metaData.links.id_Taxo = '34215'; % Taxonomicon

%% References
bibkey = 'Wiki'; type = 'Misc'; bib = ...
'howpublished = {\url{http://en.wikipedia.org/wiki/Porcellio_scaber}}';
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
bibkey = 'BrumStui1993'; type = 'Article'; bib = [ ... 
'author = {Brummelen, T. C. van Stuijfzand, S.C.}, ' ... 
'year = {1993}, ' ...
'title = {Effects of benzo[a]pyrene on survival, growth and energy reserves in the terrestrial isopods \emph{Oniscus asellus} and \emph{Porcellio scaber}}, ' ...
'journal = {Science of the Total Environment, supplement}, ' ...
'volume = {S1993}, ' ...
'pages = {921--930}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'LavyRijn2001'; type = 'Article'; bib = [ ... 
'author = {D. Lavy and M. J. van Rijn and H. R. Zoomer and H. A. Verhoef}, ' ... 
'year = {2001}, ' ...
'title = {Dietary effects on growth, reproduction, body composition and stress resistance in the terrestrial isopods \emph{Oniscus asellus} and \emph{Porcellio scaber}}, ' ...
'journal = {Physiological entomology}, ' ...
'volume = {26}, ' ...
'pages = {18--25}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Donk1992'; type = 'Phdthesis'; bib = [ ... 
'author = {Donker, M.}, ' ... 
'year = {1992}, ' ...
'title = {Physiology of metal adaptation in the isopod Porcellio scaber}, ' ...
'school = {VU University Amsterdam}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'ADW'; type = 'Misc'; bib = ...
'howpublished = {\url{http://animaldiversity.ummz.umich.edu/accounts/Porcellio_scaber}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];

