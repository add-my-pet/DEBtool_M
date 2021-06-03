function [data, auxData, metaData, txtData, weights] = mydata_Clarias_gariepinus

%% set metaData

metaData.phylum     = 'Chordata'; 
metaData.class      = 'Actinopterygii'; 
metaData.order      = 'Siluriformes'; 
metaData.family     = 'Clariidae';
metaData.species    = 'Clarias_gariepinus'; 
metaData.species_en = 'African sharptooth catfish'; 
metaData.T_typical  = C2K(29.5); % K, body temp
metaData.data_0     = {'ab_T'; 'ap'; 'am'; 'Lb'; 'Li'; 'Wwb'; 'Wwp'; 'Wwi'; 'GSI'}; 
metaData.data_1     = {'t-Ww'}; 

metaData.COMPLETE = 2.5; % using criteria of LikaKear2011

metaData.author     = {'Bas Kooijman','Starrlight Augustine'};    
metaData.date_subm  = [2019 03 07];              
metaData.email      = {'bas.kooijman@vu.nl'};            
metaData.address    = {'VU University Amsterdam'};   

metaData.curator    = {'Starrlight Augustine'};
metaData.email_cur  = {'starrlight@akvaplan.niva.no'}; 
metaData.date_acc   = [2019 03 07]; 

%% set data
% zero-variate data;

data.ab25 = 1.25;      units.ab25 = 'd';    label.ab25 = 'age at birth';  bibkey.ab25 = 'fishbase';
  temp.ab25 = C2K(25);  units.temp.ab25 = 'K'; label.temp.ab25 = 'temperature';  
data.ab33 = 0.58;      units.ab33 = 'd';    label.ab33 = 'age at birth';  bibkey.ab33 = 'fishbase';
  temp.ab33 = C2K(33);  units.temp.ab33 = 'K'; label.temp.ab33 = 'temperature';  
data.am = 15*365;     units.am = 'd';    label.am = 'life span';     bibkey.am = 'fishbase';
  temp.am = C2K(29.5);  units.temp.am = 'K'; label.temp.am = 'temperature'; 

data.Li  = 170;   units.Li  = 'cm';	label.Li  = 'ultimate total length';    bibkey.Li  = 'fishbase'; 
  
data.Wwb = 1.2e-3; units.Wwb = 'g';	label.Wwb = 'wet weight at birth';      bibkey.Wwb = 'LegeTeug1992'; 
  comment.Wwb = 'based on egg diameter of 1.3 mm: pi/6*0.13^3';
data.Wwp = 150;   units.Wwp = 'g';	label.Wwp = 'wet weight at puberty';    bibkey.Wwp = 'LegeTeug1992'; 
  comment.Wwp = 'f_tW < 1';
data.Wwi = 60e3; units.Wwi = 'g';	label.Wwi = 'ultimate wet weight';      bibkey.Wwi = 'fishbase';

data.GSI = 0.216; units.GSI = 'g/g';  label.GSI = 'gonado somatic index';          bibkey.GSI = 'LegeTeug1992';
  temp.GSI = C2K(29.5); units.temp.GSI = 'K'; label.temp.GSI = 'temperature';
 
% uni-variate data
% time-weight
data.tW = [ ...
2.162	0.046
12.970	10.974
28.102	21.929
42.153	43.739
56.204	51.583
72.417	64.096
84.306	84.341
100.519	112.371
113.489	137.278
128.621	173.060
137.268	182.423
152.400	207.343
167.532	218.298
182.664	254.080
208.604	305.445
223.736	331.917
236.706	358.376
251.838	367.778];
units.tW   = {'d', 'g'};  label.tW = {'time', 'wet weight'};  bibkey.tW = 'LegeTeug1992';
temp.tW    = C2K(29.5);  units.temp.tW = 'K'; label.temp.tW = 'temperature';

%% set weights for all real data
weights = setweights(data, []);
weights.tW = 10 * weights.tW;
weights.Wwi = 5 * weights.Wwi;
weights.GSI = 5 * weights.GSI;

%% set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);

%% pack auxData and txtData for output
auxData.temp = temp;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Discussion points
D1 = 'Part of twin entries Heterobranchus_longifilis, Heterobranchus_longifilis_x_Clarias_gariepinus. Clarias_gariepinus_x_Heterobranchus_longifilis';
metaData.discussion = struct('D1', D1);

% %% Facts
% F1 = '';
% metaData.bibkey.F1 = ''; 
% metaData.facts = struct('F1',F1);

%% References
bibkey = 'Wiki'; type = 'Misc'; bib = ...
'howpublished = {\url{https://en.wikipedia.org/wiki/Clarias_gariepinus}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Kooy2010'; type = 'Book'; bib = [ ...  % used in setting of chemical parameters and pseudodata
'author = {Kooijman, S.A.L.M.}, ' ...
'year = {2010}, ' ...
'title  = {Dynamic Energy Budget theory for metabolic organisation}, ' ...
'publisher = {Cambridge Univ. Press, Cambridge}, ' ...
'pages = {Table 4.2 (page 150), 8.1 (page 300)}, ' ...
'howpublished = {\url{http://www.bio.vu.nl/thb/research/bib/Kooy2010.html}}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'LegeTeug1992'; type = 'Article'; bib = [ ... 
'title = {A comparative study on morphology, growth rate and reproduction of \emph{Clarias gariepinus} ({B}urchell, 1822), \emph{Heterobranchus longifilis} {V}alenciennes, 1840, and their reciprocal hybrids ({P}isces, {C}lariidae)},'...
'volume = {40},'...
'journal = {Journal of Fish Biology},'...
'author = {M. Legendre and G. G. Teugels and C. Cauty and  B. Jalabert},'...
'year = {1992},'...
'pages = {59-79}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'fishbase'; type = 'Misc'; bib = ...
'howpublished = {\url{https://www.fishbase.de/summary/Clarias-gariepinus.html}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
