function [data, auxData, metaData, txtData, weights] = mydata_Heterobranchus_longifilis

%% set metaData

metaData.phylum     = 'Chordata'; 
metaData.class      = 'Actinopterygii'; 
metaData.order      = 'Siluriformes'; 
metaData.family     = 'Clariidae';
metaData.species    = 'Heterobranchus_longifilis'; 
metaData.species_en = 'Vundu'; 
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
  comment.ab25 = 'values from Clarius gariepinus';
data.ab33 = 0.58;      units.ab33 = 'd';    label.ab33 = 'age at birth';  bibkey.ab33 = 'fishbase';
  temp.ab33 = C2K(33);  units.temp.ab33 = 'K'; label.temp.ab33 = 'temperature';  
  comment.ab33 = 'values from Clarius gariepinus';
data.am = 12*365;     units.am = 'd';    label.am = 'life span';     bibkey.am = 'fishbase';
  temp.am = C2K(29.5);  units.temp.am = 'K'; label.temp.am = 'temperature'; 

data.Li  = 150;   units.Li  = 'cm';	label.Li  = 'ultimate total length';    bibkey.Li  = 'fishbase'; 
  comment.Li = 'the record is 180 cm and 45.5 kg (ref: worldrecords)';  

data.Wwb = 1.4e-3; units.Wwb = 'g';	label.Wwb = 'wet weight at birth';      bibkey.Wwb = 'LegeTeug1992'; 
  comment.Wwb = 'based on egg diameter of 1.4 mm: pi/6*0.14^3';
data.Wwp = 700;   units.Wwp = 'g';	label.Wwp = 'wet weight at puberty';    bibkey.Wwp = 'LegeTeug1992'; 
  comment.Wwp = 'at f_tW < 1';
data.Wwi = 55e3; units.Wwi = 'g';	label.Wwi = 'ultimate wet weight';      bibkey.Wwi = 'fishbase';

data.GSI = 0.077; units.GSI = 'g/g';  label.GSI = 'gonado somatic index';          bibkey.GSI = 'LegeTeug1992';
  temp.GSI = C2K(29.5); units.temp.GSI = 'K'; label.temp.GSI = 'temperature';
 
% uni-variate data
% time-weight
data.tW = [ ...
0.000	4.688
14.051	15.636
30.264	29.701
45.396	56.172
55.123	81.059
71.336	126.158
84.306	189.858
98.357	262.875
113.489	320.381
124.298	415.103
142.672	461.767
154.562	500.632
170.774	511.593
182.664	547.356
210.766	578.562
225.898	618.999
237.787	643.899
254.000	690.550];
units.tW   = {'d', 'g'};  label.tW = {'time', 'wet weight'};  bibkey.tW = 'LegeTeug1992';
temp.tW    = C2K(29.5);  units.temp.tW = 'K'; label.temp.tW = 'temperature';

%% set weights for all real data
weights = setweights(data, []);
weights.tW = 5 * weights.tW;
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
'howpublished = {\url{https://en.wikipedia.org/wiki/Heterobranchus_longifilis}}';
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
'howpublished = {\url{https://www.fishbase.de/summary/Heterobranchus-longifilis.html}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'worldrecords'; type = 'Misc'; bib = ...
'howpublished = {\url{http://www.fishing-worldrecords.com/scientificname/Heterobranchus%20longifilis/show}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];