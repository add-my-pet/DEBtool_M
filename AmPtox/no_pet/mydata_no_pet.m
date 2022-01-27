function [data, auxData, metaData, txtData, weights] = mydata_no_pet 
%% set data

% time - rate
data.tX = [ ... % time  (d), rate (1/d)
    0 3
    1 3.5
    3 4.2
    4 4.4
    ];  
units.tX   = {'d', '1/d'};  label.tX = {'time', 'rate'};  
bibkey.tX = 'bla2022';
  
%% set weights for all real data
weights = setweights(data, []);

%% set pseudodata and respective weights: no need for pseudodata
%[data, units, label, weights] = addpseudodata(data, units, label, weights)

%% pack auxData and txtData for output
%metaData = []; % metaData does not need to exist
auxData.temp = []; % auxData must have at least one field
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
%txtData.comment = comment;

%% Discussion points: no need for discussion
%D1 = '';
%metaData.discussion = struct('D1', D1);

%% References
bibkey = 'bla2022'; type = 'Misc'; bib = ...
'howpublished = {\url{http://en.wikipedia.org/wiki/my_pet}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
