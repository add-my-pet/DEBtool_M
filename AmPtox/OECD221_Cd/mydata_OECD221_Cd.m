function [data, auxData, metaData, txtData, weights] = mydata_OECD221_Cd
%% set metaData (optional fields)

metaData.author = 'Bas Kooijman';
metaData.date = [2022 01 28];
metaData.toxTest = 'OECD211';
metaData.species = 'Daphnia_magna';
metaData.cashno = '10108-64-2';
metaData.compound = 'Cadmium chloride';
metaData.MolWeight = 112.41; % g/mol, of Cd only
metaData.endpoint = 'embryo hazard';
metaData.DEBpars = 'KooyGerg2019';

%% set data

% time - conc - cum # of offspring per female
t = (1:21)'; % d, exposure time
c = [0.0  0.2  0.4  0.8  1.0  2.0]'; % mug/l, concentration of cadmium 
N = [ 0.000   0.000   0.000   0.000   0.000   0.000 % cumulative offspring per female
      0.000   0.000   0.000   0.000   0.000   0.000 
      0.000   0.000   0.000   0.000   0.000   0.000 
      0.000   0.000   0.000   0.000   0.000   0.000
      0.000   0.000   0.000   0.000   0.000   0.000
      0.000   0.000   0.000   0.000   0.000   0.000
      1.400   0.800   1.800   0.000   0.900   0.000
      3.600   1.300   2.300   2.600   2.800   2.600
     10.400  13.600   7.000   5.100   5.400   3.900
     20.400  16.600  13.800  12.000   7.800   4.800
     22.800  18.900  13.800  14.500   7.800   4.800
     31.200  27.000  14.700  14.500   7.800   4.800
     41.500  35.500  20.800  15.600   9.300   4.800
     43.400  37.900  20.800  15.600   9.300   4.800
     53.000  44.700  24.100  15.600   9.300   NaN*4.800 % example that NaN's are allowed
     64.100  48.300  29.700  16.800  10.000   5.244
     66.800  51.000  31.200  16.800  11.300   5.244
     75.900  58.300  39.500  17.000  11.300   5.244
     88.100  66.900  45.300  21.300  11.300   5.244
     90.600  72.000  47.600  21.700  11.300   5.244
     98.700  76.200  53.000  21.700  11.300   5.244];
data.tN = [t, N]; % compose data set
units.tN = {'d', '#'}; label.tN = {'exposure time', 'cum number of offspring'};  
treat.tN = {1, c}; units.treat.tN = 'mug/l'; label.treat.tN = 'conc. of Cd';
temp.tN = 20; units.temp.tN = 'C'; label.temp.tN = 'temperature';
bibkey.tN = {'KooyBeda1996b','KooyBeda1996'};
comment.tN = 'Hazard effects of Cd on Daphnia magna reproduction';
  
%% set weights for all real data
weights = setweights(data, []);

%% pack auxData and txtData for output
auxData.treat = treat; % auxData must have at least one field
auxData.temp = temp; 
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Discussion points
D1 = 'hazard effects on offspring of ectotherm: target is hazard rate';
D2 = 'The type of length in parameter L0 should correspond with that in parameter v, so structural length';
D3 = 'Read (compound) DEB parameters from allStat.Daphnia_magna after load allStat';
metaData.discussion = struct('D1',D1, 'D2',D2, 'D3',D3);

%% References
bibkey = 'OECD221'; type = 'techreport'; bib = [ ...
'doi = {10.1787/9789264185203-en}, ' ... 
'author = {OECD}, ' ...
'year = {2012}, ' ...
'title  = {Test No. 211: Daphnia magna Reproduction Test}, ' ...
'institution = {OECD Publishing, Paris}, ' ...
'series = {OECD Guidelines for the Testing of Chemicals, Section 2}, ' ...
'howpublished = {https://www.oecd.org/chemicalsafety/test-no-211-daphnia-magna-reproduction-test-9789264185203-en.htm}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'KooyBeda1996'; type = 'Book'; bib = [ ...
'author = {Kooijman, S.A.L.M. and Bedaux, J.J.M.}, ' ...
'year = {1996}, ' ...
'title  = {The analysis of aquatic toxicity data}, ' ...
'publisher = {VU University Press}', ...
'howpublished = {https://research.vu.nl/en/publications/the-analysis-of-aquatic-toxicity-data}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'KooyBeda1996b'; type = 'article'; bib = [ ...
'author = {Kooijman, S.A.L.M. and Bedaux, J.J.M.}, ' ...
'year = {1996}, ' ...
'title  = {Analysis of toxicity tests on \emph{Daphnia} survival and reproduction}, ' ...
'journal = {Water Res.}', ...
'volume = {30}, ' ...
'pages = {1711-1723}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'KooyGerg2019'; type = 'misc'; bib = [ ...
'author = {Bas Kooijman, Andre Gergs}, ' ...
'year = {2019}, ' ...
'title  = {AmP Daphnia magna, version 2019/03/16}, ' ...
'howpublished = {https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries_web/Daphnia_magna/Daphnia_magna_res.html}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
