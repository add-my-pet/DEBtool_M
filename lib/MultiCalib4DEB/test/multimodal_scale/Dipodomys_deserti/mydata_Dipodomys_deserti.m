function [data, auxData, metaData, txtData, weights] = mydata_Dipodomys_deserti
%% set metaData
metaData.phylum     = 'Chordata'; 
metaData.class      = 'Mammalia'; 
metaData.order      = 'Rodentia'; 
metaData.family     = 'Heteromyidae';
metaData.species    = 'Dipodomys_deserti'; 
metaData.species_en = 'Desert kangaroo rat'; 
metaData.ecoCode.climate = {'BWh', 'BWk', 'BSh', 'BSk'};
metaData.ecoCode.ecozone = {'THn'};
metaData.ecoCode.habitat = {'0iTa', '0iTd'};
metaData.ecoCode.embryo  = {'Tv'};
metaData.ecoCode.migrate = {};
metaData.ecoCode.food    = {'bxM', 'xiHl', 'xiHs'};
metaData.ecoCode.gender  = {'Dg'};
metaData.ecoCode.reprod  = {'O'};
metaData.T_typical  = C2K(36.8); % K, body temp
metaData.data_0     = {'tg'; 'ax'; 'ap'; 'am'; 'Wwb'; 'Wwx'; 'Wwi'; 'Ri'}; 
metaData.data_1     = {}; 

metaData.COMPLETE = 2.1; % using criteria of LikaKear2011

metaData.author    = {'Bas Kooijman'};    
metaData.date_subm = [2018 01 01];              
metaData.email     = {'bas.kooijman@vu.nl'};            
metaData.address   = {'VU University, Amsterdam'};   

metaData.curator   = {'Starrlight Augustine'};    
metaData.email_cur = {'starrlight.augustine@akvaplan.niva.no'};            
metaData.date_acc  = [2018 01 01];              

%% set data
% zero-variate data

data.tg = 30;    units.tg = 'd';     label.tg = 'gestation time';             bibkey.tg = 'AnAge';   
  temp.tg = C2K(36.8);  units.temp.tg = 'K'; label.temp.tg = 'temperature';
data.tx = 20;    units.tx = 'd';     label.tx = 'time since birth at weaning'; bibkey.tx = 'AnAge';   
  temp.tx = C2K(36.8);  units.temp.tx = 'K'; label.temp.tx = 'temperature';
data.tp = 61;   units.tp = 'd';     label.tp = 'time since birth at puberty for female'; bibkey.tp = 'AnAge';
  temp.tp = C2K(36.8); units.temp.tp = 'K'; label.temp.tp = 'temperature';
  comment.tp = 'Data for Dipodomys ordii';
data.am = 8.6*365;    units.am = 'd'; label.am = 'life span';                bibkey.am = 'AnAge';   
  temp.am = C2K(36.8); units.temp.am = 'K'; label.temp.am = 'temperature';

data.Wwb = 3.04;   units.Wwb = 'g';     label.Wwb = 'wet weight at birth';     bibkey.Wwb = 'AnAge';
data.Wwx = 38;   units.Wwx = 'g';     label.Wwx = 'wet weight at weaning';     bibkey.Wwx = 'AnAge';
data.Wwi = 116;   units.Wwi = 'g';  label.Wwi = 'ultimate wet weight';     bibkey.Wwi = 'AnAge';

data.Ri  = 3*3/365;  units.Ri  = '#/d'; label.Ri  = 'maximum reprod rate';  bibkey.Ri  = 'AnAge';   
  temp.Ri = C2K(36.8); units.temp.Ri = 'K'; label.temp.Ri = 'temperature';
  comment.Ri = '3 pups per litter; 3 litters per yr';

%% set weights for all real data
weights = setweights(data, []);
weights.Wwb = 5 * weights.Wwb;

%% set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);
data.psd.t_0 = 0;  units.psd.t_0 = 'd'; label.psd.t_0 = 'time at start development';
weights.psd.t_0 = 0.1;

%% pack auxData and txtData for output
auxData.temp = temp;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Links
metaData.links.id_CoL = '36PMN'; % Cat of Life
metaData.links.id_ITIS = '180236'; % ITIS
metaData.links.id_EoL = '328080'; % Ency of Life
metaData.links.id_Wiki = 'Dipodomys_deserti'; % Wikipedia
metaData.links.id_ADW = 'Dipodomys_deserti'; % ADW
metaData.links.id_Taxo = '62059'; % Taxonomicon
metaData.links.id_WoRMS = ''; % WoRMS
metaData.links.id_MSW3 = '12700014'; % MSW3
metaData.links.id_AnAge = 'Dipodomys_deserti'; % AnAge


%% References
bibkey = 'Wiki'; type = 'Misc'; bib = ...
'howpublished = {\url{http://en.wikipedia.org/wiki/Dipodomys_deserti}}';
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
bibkey = 'AnAge'; type = 'Misc'; bib = ...
'howpublished = {\url{http://genomics.senescence.info/species/entry.php?species=Dipodomys_deserti}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];

