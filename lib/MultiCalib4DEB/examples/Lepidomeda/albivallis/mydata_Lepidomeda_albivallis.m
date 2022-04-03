function [data, auxData, metaData, txtData, weights] = mydata_Lepidomeda_albivallis
%% set metadata
metaData.phylum     = 'Chordata'; 
metaData.class      = 'Actinopterygii'; 
metaData.order      = 'Cypriniformes'; 
metaData.family     = 'Leuciscidae';
metaData.species    = 'Lepidomeda_albivallis'; 
metaData.species_en = 'White River spinedace'; 

metaData.ecoCode.climate = {'BSk'};
metaData.ecoCode.ecozone = {'THn'};
metaData.ecoCode.habitat = {'0iFr','jiFc'};
metaData.ecoCode.embryo  = {'Fh'};
metaData.ecoCode.migrate = {'Mp'};
metaData.ecoCode.food    = {'bpO'};
metaData.ecoCode.gender  = {'D'};
metaData.ecoCode.reprod  = {'O'};

metaData.T_typical  = C2K(13); % K, body temp
metaData.data_0     = {'am'; 'Lp'; 'Li'; 'Wwb'; 'Wwp'; 'Wwi'; 'Ri'};  
metaData.data_1     = {'t-L'}; 

metaData.COMPLETE = 2.3; % using criteria of LikaKear2011

metaData.author   = {'Bas Kooijman', 'Starrlight Augustine'};        
metaData.date_subm = [2020 09 15];                           
metaData.email    = {'bas.kooijman@vu.nl'};                 
metaData.address  = {'VU University Amsterdam'}; 

metaData.curator     = {'Starrlight Augustine'};
metaData.email_cur   = {'starrlight.augustine@akvaplan.niva.no'}; 
metaData.date_acc    = [2020 09 15]; 

%% set data
% zero-variate data

data.am = 13*365;   units.am = 'd';  label.am = 'life span';                      bibkey.am = 'ScopHarv2004';   
  temp.am = C2K(13); units.temp.am = 'K'; label.temp.am = 'temperature'; 
  
data.Lp = 7;    units.Lp = 'cm'; label.Lp = 'total length at puberty';           bibkey.Lp = 'ScopHarv2004';
  comment.Lp = 'based on FL 6.5 cm';
data.Li = 15;    units.Li = 'cm'; label.Li = 'ultimate total length';             bibkey.Li = 'fishbase'; 
  
data.Wwb = 4.8e-3;   units.Wwb = 'g';  label.Wwb = 'wet weight at birth';          bibkey.Wwb = 'BillTjar2011';
  comment.Wwb = 'based on egg diameter of 2.1 mm for Lepidomeda aliciae: pi/6*0.21^3';
data.Wwp = 3.65;   units.Wwp = 'g';  label.Wwp = 'wet weight at puberty';         bibkey.Wwp = {'fishbase','BillTjar2011'};
  comment.Wwp = 'based on 0.00891*Lp^3.06, F1';
data.Wwi = 35.4;   units.Wwi = 'g';  label.Wwi = 'wet weight at birth';         bibkey.Wwi = {'fishbase','BillTjar2011'};
  comment.Wwi = 'based on 0.00891*Li^3.06, F1';

data.Ri = 2500/365; units.Ri = '#/d';  label.Ri = 'reprod rate at SL 92 mm, TL 108 mm';  bibkey.Ri = 'BillTjar2011';
  temp.Ri = C2K(13); units.temp.Ri = 'K'; label.temp.Ri = 'temperature';
  comment.Ri = 'value for Lepidomeda aliciae';

% univariate data
% time-length
data.tL = [ ... % time (yr), fork length (cm)
0.312	3.728
0.331	3.243
1.279	4.343
1.291	6.079
1.292	5.849
1.293	5.441
1.296	4.215
1.310	5.211
1.311	5.032
1.311	4.930
2.291	6.821
2.327	6.362
2.357	7.638
3.274	7.844
3.292	7.334
3.293	7.206
4.262	7.080
4.275	8.459
5.279	7.618
5.290	9.788
5.298	7.133
5.326	9.176
10.251	9.925
12.271	10.720];
data.tL(:,1) = 365 * (0.3 + data.tL(:,1));
data.tL(:,2) = data.tL(:,2)/ 0.93; % convert FL to TL
units.tL = {'d', 'cm'}; label.tL = {'time since hatch', 'total length'};  
temp.tL = C2K(13);  units.temp.tL = 'K'; label.temp.tL = 'temperature';
bibkey.tL = 'ScopHarv2004'; 

%% set weights for all real data
weights = setweights(data, []);
weights.tL = 5 * weights.tL;

%% set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);

%% pack auxData and txtData for output
auxData.temp = temp;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Discussion points
D1 = 'Temperatures are guessed';
metaData.discussion = struct('D1', D1);

%% Facts
F1 = 'length-weight: Ww in g = 0.00891*(TL in cm)^3.06';
metaData.bibkey.F1 = 'fishbase';
F2 = 'length-length from photo: FL = 0.93 * TL';
metaData.bibkey.F2 = 'fishbase';
metaData.facts = struct('F1',F1, 'F2',F2); 

%% Links
metaData.links.id_CoL = '3TC4N'; % Cat of Life
metaData.links.id_ITIS = '163571'; % ITIS
metaData.links.id_EoL = '207643'; % Ency of Life
metaData.links.id_Wiki = 'Lepidomeda_albivallis'; % Wikipedia
metaData.links.id_ADW = 'Lepidomeda_albivallis'; % ADW
metaData.links.id_Taxo = '178374'; % Taxonomicon
metaData.links.id_WoRMS = '1013782'; % WoRMS
metaData.links.id_fishbase = 'Lepidomeda-albivallis'; % fishbase


%% References
bibkey = 'Wiki'; type = 'Misc'; bib = ...
'howpublished = {\url{https://en.wikipedia.org/wiki/Lepidomeda_albivallis}}';  
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
% 
bibkey = 'fishbase'; type = 'Misc'; bib = ...
'howpublished = {\url{https://www.fishbase.in/summary/Lepidomeda-albivallis.html}}';  
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
bibkey = 'ScopHarv2004'; type = 'article'; bib = [ ...  
'author = {G. Gary Scoppettone and James E. Harvey and James Heinrich}, ' ...
'year = {2004}, ' ...
'title  = {CONSERVATION, STATUS, AND LIFE HISTORY OF THE ENDANGERED WHITE RIVERSPINEDACE, \emph{Lepidomeda albivallis} ({C}YPRINIDAE)}, ' ...
'journal = {Western North American Naturalist}, ' ...
'pages = {38-44}, ' ...
'volume = {64(1)}' ];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%  
bibkey = 'BillTjar2011'; type = 'article'; bib = [ ...  
'author = {Billman, E. J. and Tjarks, B. J. and Belk, M. C.}, ' ...
'year = {2011}, ' ...
'title  = {Effect of predation and habitat quality on growth and reproduction of a stream fish}, ' ...
'journal = {Ecology of Freshwater Fish}, ' ...
'pages = {102-113}, ' ...
'volume = {20}' ];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
