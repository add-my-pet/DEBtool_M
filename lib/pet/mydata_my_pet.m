function [data, auxData, metaData, txtData, weights] = mydata_my_pet 

%% set metaData

metaData.phylum     = 'my_pet_phylum'; 
metaData.class      = 'my_pet_class'; 
metaData.order      = 'my_pet_order'; 
metaData.family     = 'my_pet_family';
metaData.species    = 'my_pet'; 
metaData.species_en = 'my_pet_english_name'; 
metaData.ecoCode.climate = {?};
metaData.ecoCode.ecozone = {?};
metaData.ecoCode.habitat = {?};
metaData.ecoCode.embryo  = {?};
metaData.ecoCode.migrate = {?};
metaData.ecoCode.food    = {?};
metaData.ecoCode.gender  = {?};
metaData.ecoCode.reprod  = {?};
metaData.T_typical  = C2K(?); % K, typical body temp
metaData.data_0     = {?}; 
metaData.data_1     = {?};

metaData.COMPLETE = ?; % using criteria of LikaKear2011

metaData.author   = {'FirstName1 LastName1', 'FirstName2 LastName2'};  
metaData.date_subm = [yyyy mm dd];  
metaData.email    = {'myname@myuniv.univ'}; 
metaData.address  = {'affiliation, zipcode, country'}; 

% metaData.curator     = {'FirstName LastName'};
% metaData.email_cur   = {'myname@myuniv.univ'}; 
% metaData.date_acc    = [yyyy mm dd]; 

%% set data
% zero-variate data;

% age 0 is at onset of embryo development
data.ab = ?;      units.ab = 'd';    label.ab = 'age at birth';  bibkey.ab = 'bibkey';   
  temp.ab = C2K(20);  units.temp.ab = 'K'; label.temp.ab = 'temperature';
  comment.ab  = ''; 
 
% uni-variate data

data.tL_m = [ ... % time since birth (yr), standard length (cm)
    ];
data.tL_m(:,1) = 365 * data.tL_m(:,1); % convert yr to d
units.tL_m = {'d', 'cm'}; label.tL_m = {'time since birth', 'total length'};  
temp.tL_m = C2K(18);  units.temp.tL_m = 'K'; label.temp.tL_m = 'temperature';
bibkey.tL_m = 'bibkey';
comment.tL_m = 'Data for males';

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

%% Discussion points
D1 = '';
D2 = '';     
metaData.bibkey.D2 = 'Kooy2010';
metaData.discussion = struct('D1', D1, 'D2', D2);

%% Facts
F1 = '';
metaData.bibkey.F1 = 'bibkey'; 
metaData.facts = struct('F1',F1);

%% Links
metaData.links.id_CoL = ''; % Cat of Life
metaData.links.id_EoL = ''; % Ency of Life
metaData.links.id_Wiki = ''; % Wikipedia
metaData.links.id_ADW = ''; % ADW
metaData.links.id_Taxo = ''; % Taxonomicon
metaData.links.id_WoRMS = ''; % WoRMS
metaData.links.id_fishbase = ''; % fishbase

%% Acknowledgment
metaData.acknowledgment = '';

%% References
bibkey = 'Kooy2010'; type = 'Book'; bib = [ ...  % used in setting of chemical parameters and pseudodata
'author = {Kooijman, S.A.L.M.}, ' ...
'year = {2010}, ' ...
'title  = {Dynamic Energy Budget theory for metabolic organisation}, ' ...
'publisher = {Cambridge Univ. Press, Cambridge}, ' ...
'pages = {Table 4.2 (page 150), 8.1 (page 300)}, ' ...
'howpublished = {\url{http://www.bio.vu.nl/thb/research/bib/Kooy2010.html}}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%

