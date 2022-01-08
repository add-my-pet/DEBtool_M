function [data, auxData, metaData, txtData, weights] = mydata_my_pet 

%% set metaData % see http://www.debtheory.org/wiki/index.php?title=Mydata_file for metaData field descriptions

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
metaData.email    = {'myname@myuniv.country'}; 
metaData.address  = {'affiliation, zipcode, country'}; 

% metaData.curator     = {'FirstName LastName'};
% metaData.email_cur   = {'myname@myuniv.univ'}; 
% metaData.date_acc    = [yyyy mm dd]; 

%% set data
% zero-variate data;

data.ab = ?;    units.ab = 'd';    label.ab = 'age at birth';             bibkey.ab = 'bibkey?';   
  temp.ab = C2K();  units.temp.ab = 'K'; label.temp.ab = 'temperature';
  comment.ab = 'range is ..';
data.tj = ?;    units.tj = 'd';    label.tj = 'time since birth at metam'; bibkey.tj = 'bibkey?';   
  temp.tj = C2K();  units.temp.tj = 'K'; label.temp.tj = 'temperature';
  comment.tj = 'range is ..';
data.tp = ?;    units.tp = 'd';    label.tp = 'time since birth at puberty'; bibkey.tp = 'bibkey?';
  temp.tp = C2K();  units.temp.tp = 'K'; label.temp.tp = 'temperature';
  comment.tp = 'range is ..';
data.tpm = ?;    units.tpm = 'd';    label.tpm = 'time since birth at puberty for male'; bibkey.tpm = 'bibkey?';
  temp.tpm = C2K();  units.temp.tpm = 'K'; label.temp.tpm = 'temperature';
  comment.tpm = 'range is ..';
data.am = ?;    units.am = 'd';    label.am = 'life span';                bibkey.am = 'bibkey?';   
  temp.am = C2K();  units.temp.am = 'K'; label.temp.am = 'temperature'; 
  comment.am = 'range is ..';

data.Lb  = ?;   units.Lb  = 'cm';  label.Lb  = 'total length at birth';   bibkey.Lb  = 'bibkey?';
  comment.a Lb 'range is ..';
data.Lj  = ?;   units.Lj  = 'cm';  label.Lj  = 'total length at metam';   bibkey.Lj  = 'bibkey?';
  comment.Lj = 'range is ..';
data.Lp  = ?;   units.Lp  = 'cm';  label.Lp  = 'total length at puberty'; bibkey.Lp  = 'bibkey?';
  comment.Lp = 'range is ..';
data.Li  = ?;   units.Li  = 'cm';  label.Li  = 'ultimate total length';   bibkey.Li  = 'bibkey?';
  comment.Li = 'range is ..';
data.Lim  = ?;  units.Lim  = 'cm'; label.Lim  = 'ultimate total length for male';  bibkey.Lim  = 'bibkey?';
  comment.Lim = 'range is ..';

data.Wwb = ?;   units.Wwb = 'g';   label.Wwb = 'wet weight at birth';     bibkey.Wwb = 'bibkey?';
  comment.Wwb = 'range is ..';
data.Wwj = ?;   units.Wwj = 'g';   label.Wwj = 'wet weight at metam';   bibkey.Wwj = 'bibkey?';
  comment.Wwj = 'range is ..';
data.Wwp = ?;   units.Wwp = 'g';   label.Wwp = 'wet weight at puberty';   bibkey.Wwp = 'bibkey?';
  comment.Wwp = 'range is ..';
data.Wwi = ?;   units.Wwi = 'g';   label.Wwi = 'ultimate wet weight';     bibkey.Wwi = 'bibkey?';
  comment.Wwi = 'range is ..';
data.Wwim = ?;  units.Wwim = 'g';  label.Wwim = 'ultimate wet weight for male'; bibkey.Wwim = 'bibkey?';
  comment.Wwim = 'range is ..';

data.Ri  = ?;   units.Ri  = '#/d'; label.Ri  = 'maximum reprod rate';     bibkey.Ri  = 'bibkey?';   
  temp.Ri = C2K();  units.temp.Ri = 'K'; label.temp.Ri = 'temperature';
  comment.Ri = '? litters per yr; ? pups per litter';
 
% uni-variate data

data.tL_m = [ ... % time since birth (yr), standard length (cm)
    ];
data.tL_m(:,1) = 365 * data.tL_m(:,1); % convert yr to d
units.tL_m = {'d', 'cm'}; label.tL_m = {'time since birth', 'total length'};  
temp.tL_m = C2K(18);  units.temp.tL_m = 'K'; label.temp.tL_m = 'temperature';
bibkey.tL_m = 'bibkey?';
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
D1 = 'males are assumed to differ from females by .. only';
D2 = '';     
metaData.bibkey.D2 = 'bibkey?'; 
metaData.discussion = struct('D1',D1, 'D2',D2);

%% Facts
F1 = '';
metaData.bibkey.F1 = 'bibkey?'; 
metaData.facts = struct('F1',F1);

%% Links
metaData.links.id_CoL = ''; % Cat of Life
metaData.links.id_ITIS = ''; % ITIS
metaData.links.id_EoL = ''; % Ency of Life
metaData.links.id_Wiki = ''; % Wikipedia
metaData.links.id_ADW = ''; % ADW
metaData.links.id_Taxo = ''; % Taxonomicon
metaData.links.id_WoRMS = ''; % WoRMS
metaData.links.id_molluscabase = ''; % molluscabase
metaData.links.id_scorpion = ''; % scorpion
metaData.links.id_spider = ''; % spider
metaData.links.id_collembola = ''; % collembola
metaData.links.id_orthoptera = ''; % orthoptera
metaData.links.id_phasmida = ''; % phasmida
metaData.links.id_aphid = ''; % aphid
metaData.links.id_diptera = ''; % diptera
metaData.links.id_lepidoptera = ''; % lepidoptera
metaData.links.id_fishbase = ''; % fishbase
metaData.links.id_amphweb = ''; % amphweb
metaData.links.id_ReptileDB = ''; % ReptileDB
metaData.links.id_avibase = ''; % avibase
metaData.links.id_birdlife = ''; % birdlife
metaData.links.id_MSW3 = ''; % MSW3
metaData.links.id_AnAge = ''; % AnAge

%% Acknowledgment
metaData.acknowledgment = '';

%% References
bibkey = 'Kooy2010'; type = 'Book'; bib = [ ...  % used in setting of chemical parameters and pseudodata
'author = {Kooijman, S.A.L.M.}, ' ...
'year = {2010}, ' ...
'title  = {Dynamic Energy Budget theory for metabolic organisation}, ' ...
'publisher = {Cambridge Univ. Press, Cambridge}, ' ...
'pages = {Table 4.2 (page 150), 8.1 (page 300)}, ' ...
'howpublished = {\url{../../../bib/Kooy2010.html}}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = ''; type = 'Article'; bib = [ ... 
'author = {}, ' ... 
'year = {}, ' ...
'title = {}, ' ...
'journal = {}, ' ...
'volume = {}, ' ...
'number = {}, '...
'pages = {}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];

