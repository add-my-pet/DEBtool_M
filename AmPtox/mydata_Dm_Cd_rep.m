function [data, auxData, metaData, txtData, weights] = mydata_Dm_Cd_rep
%% set data

% time - conc - cum # of offspring
t = [1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21]'; % days
c = [0.00  0.20  0.40  0.80  1.00  2.00]';         % cadmium mM
N = [0.000   0.000   0.000   0.000   0.000   0.000 % Daphnia magna 
     0.000   0.000   0.000   0.000   0.000   0.000 % offspring per female
     0.000   0.000   0.000   0.000   0.000   0.000 
     0.000   0.000   0.000   0.000   0.000   0.000
     0.000   0.000   0.000   0.000   0.000   0.000
     0.000   0.000   0.000   0.000   0.000   0.000
     1.400   0.800   1.800   0.000   0.900   0.000
     3.600   1.300   2.300   2.600   2.800   2.600
     10.400  13.600   7.000  5.100   5.400   3.900
     20.400  16.600  13.800  12.000   7.800   4.800
     22.800  18.900  13.800  14.500   7.800   4.800
     31.200  27.000  14.700  14.500   7.800   4.800
     41.500  35.500  20.800  15.600   9.300   4.800
     43.400  37.900  20.800  15.600   9.300   4.800
     53.000  44.700  24.100  15.600   9.300   NaN*4.800
     64.100  48.300  29.700  16.800  10.000   5.244
     66.800  51.000  31.200  16.800  11.300   5.244
     75.900  58.300  39.500  17.000  11.300   5.244
     88.100  66.900  45.300  21.300  11.300   5.244
     90.600  72.000  47.600  21.700  11.300   5.244
     98.700  76.200  53.000  21.700  11.300   5.244];
data.tN = [t, N]; 
units.tN = {'d', '#'}; label.tN = {'exposure time', 'cum number of offspring'};  
treat.tN = {1, c}; units.treat.tN = 'mM'; label.treat.tN = 'conc. of Cd';
bibkey.tN = 'bla2022';
comment.tN = 'Effects of Cd on Daphnia magna reproduction';
  
%% set weights for all real data
weights = setweights(data, []);

%% set pseudodata and respective weights: no need for pseudodata
%[data, units, label, weights] = addpseudodata(data, units, label, weights)

%% pack auxData and txtData for output
%metaData = []; % metaData does not need to exist
auxData.treat = treat; % auxData must have at least one field
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Discussion points: no need for discussion
%D1 = '';
%metaData.discussion = struct('D1', D1);

%% References
bibkey = 'bla2022'; type = 'Misc'; bib = ...
'howpublished = {\url{http://en.wikipedia.org/wiki/my_pet}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
