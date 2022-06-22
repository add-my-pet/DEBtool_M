function [data, auxData, metaData, txtData, weights] = mydata_Homo_sapiens

%% set metaData
metaData.phylum     = 'Chordata'; 
metaData.class      = 'Mammalia'; 
metaData.order      = 'Primates'; 
metaData.family     = 'Hominidae';
metaData.species    = 'Homo_sapiens'; 
metaData.species_en = 'Human'; 
metaData.ecoCode.climate = {'A', 'B', 'C', 'D'};
metaData.ecoCode.ecozone = {'TH', 'TN', 'TP', 'TA'};
metaData.ecoCode.habitat = {'0iT'};
metaData.ecoCode.embryo  = {'Tv'};
metaData.ecoCode.migrate = {};
metaData.ecoCode.food    = {'bxM', 'xiO'};
metaData.ecoCode.gender  = {'Dg'};
metaData.ecoCode.reprod  = {'O'};
metaData.T_typical  = C2K(37); % K, body temp
metaData.data_0     = {'tg'; 'ax'; 'ap'; 'am'; 'Lb'; 'Lp'; 'Li'; 'Wwb'; 'Wwx'; 'Wwp'; 'Wwi'; 'Ri'; 'pXi'}; 
metaData.data_1     = {'t-L'}; 

metaData.COMPLETE = 2.7; % using criteria of LikaKear2011

metaData.author   = {'Bas Kooijman'};    
metaData.date_subm = [2009 07 30];              
metaData.email    = {'bas.kooijman@vu.nl'};            
metaData.address  = {'VU University Amsterdam'};   

metaData.author_mod_1   = {'Anne-Thea McGill'};    
metaData.date_mod_1 = [2015 04 20];              
metaData.email_mod_1    = {'at.mcgill@auckland.ac.nz'};            
metaData.address_mod_1  = {'University of Auckland,1142, New Zealand'};   

metaData.author_mod_2   = {'Bas Kooijman'};    
metaData.date_mod_2     = [2017 11 11];              
metaData.email_mod_2    = {'bas.kooijman@vu.nl'};            
metaData.address_mod_2  = {'VU University Amsterdam'};   


metaData.curator     = {'Starrlight Augustine'};
metaData.email_cur   = {'starrlight.augustine@akvaplan.niva.no'}; 
metaData.date_acc    = [2017 11 11]; 


%% set data
% zero-variate data

data.tg = 305;   units.tg = 'd';    label.tg = 'gestation time';                 bibkey.tg = 'Wiki';   
  temp.tg = C2K(37);  units.temp.tg = 'K'; label.temp.tg = 'temperature';
data.tx = 365;     units.tx = 'd';    label.tx = 'time since birth at weaning';  bibkey.tx = 'guessed';   
  temp.tx = C2K(37);  units.temp.tx = 'K'; label.temp.tx = 'temperature';
data.tp = 4685;  units.tp = 'd';    label.tp = 'time since birth at puberty';    bibkey.tp = 'AnAge';
  temp.tp = C2K(37);  units.temp.tp = 'K'; label.temp.tp = 'temperature';
data.am = 85*365;  units.am = 'd';    label.am = 'life span';                    bibkey.am = 'guessed';   
  temp.am = C2K(37);  units.temp.am = 'K'; label.temp.am = 'temperature'; 

  
data.Lb  = 60;     units.Lb  = 'cm';  label.Lb  = 'head-feet length at birth';   bibkey.Lb  = 'guessed';
data.Lp  = 160;    units.Lp  = 'cm';  label.Lp  = 'head-feet length at puberty'; bibkey.Lp  = 'guessed';
data.Li  = 165;    units.Li  = 'cm';  label.Li  = 'ultimate head-feet length';   bibkey.Li  = 'guessed';

data.Wwb = 3313;   units.Wwb = 'g';   label.Wwb = 'wet weight at birth';         bibkey.Wwb = 'AnAge';
data.Wwx = 11750;  units.Wwx = 'g';   label.Wwx = 'wet weight at weaning';       bibkey.Wwx = 'AnAge';
data.Wwp = 48e3;   units.Wwp = 'g';   label.Wwp = 'wet weight at puberty';       bibkey.Wwp = 'guessed';
data.Wwi = 58e3;   units.Wwi = 'g';   label.Wwi = 'ultimate wet weight';         bibkey.Wwi = 'guessed';

data.Ri  = 1/1000; units.Ri  = '#/d'; label.Ri  = 'maximum reprod rate';         bibkey.Ri  = 'guessed';   
  temp.Ri = C2K(37);  units.temp.Ri = 'K'; label.temp.Ri = 'temperature';

data.pXi  = 4.2*2e6; units.pXi  = 'J/d'; label.pXi  = 'adult male maintenance intake'; bibkey.pXi  = 'guessed';   
  temp.pXi = C2K(37); units.temp.pXi = 'K'; label.temp.pXi = 'temperature';

% uni-variate data
% t-L data
data.tL = [ ... % time since birth (yr), head-feet length (m)
0.01822481473 0.5218074351; 
      0.4242089731 0.6488752111;
      1.034256445 0.7218652059;
      1.526001851 0.805800039;
      2.004516996 0.9003477247;
      2.674061662 0.9298597829;
      3.06765134 0.9757793423;
      3.425067522 1.027858381;
      4.0782108 1.055656853;
      4.557175021 1.100900084;
      5.065986075 1.113618996;
      5.666501453 1.151684027;
      5.988062236 1.174998556;
      6.401327343 1.223659203;
      6.965856341 1.24734019;
      7.280859687 1.269626893;
      7.484314876 1.282315561;
      7.97646258 1.32208182;
      8.593513446 1.347137578;
      9.062655545 1.389298305;
      9.660146369 1.39894447;
      10.05387638 1.429456387;
      11.53739462 1.492945909;
      12.12825004 1.510124048;
      12.73202698 1.550586148;
      13.12261394 1.565690098;
      13.55248314 1.593808848;
      14.1002833 1.651727413;
      14.49391663 1.692853484;
      15.12367384 1.764818254;
      15.63571527 1.783358157;
      16.31816899 1.837523743;
      16.63313803 1.863576759;
      17.21425553 1.868427809;
      17.50639985 1.877016553;
      17.71981126 1.878064868];
data.tL(:,1) = data.tL(:,1) * 365; % convert yr to d
data.tL(:,2) = data.tL(:,2) * 100; % convert m to cm
units.tL   = {'d', 'cm'};  label.tL = {'time since birth', 'head-feet length'};  
temp.tL    = C2K(37);  units.temp.tL = 'K'; label.temp.tL = 'temperature';
bibkey.tL = 'Came1984';
comment.tL = 'bad fit is probably due to changes in shape (relative leg-length)';  

%% set weights for all real data
weights = setweights(data, []);

%% set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);
data.psd.t_0 = 0;  units.psd.t_0 = 'd'; label.psd.t_0 = 'time at start development';
weights.psd.t_0 = 0.2;
weights.psd.k_J = 0; weights.psd.k = 0.1;
data.psd.k = 0.3; units.psd.k  = '-'; label.psd.k  = 'maintenance ratio'; 

%% pack auxData and txtData for output
auxData.temp = temp;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Discussion points
D1 = 'In view of low somatic maintenance, pseudodata k_J = 0.002 1/d is replaced by pseudodata k = 0.3';
metaData.discussion = struct('D1', D1);

%% Links
metaData.links.id_CoL = 'e3b90576561f93a8ac8b59e185b01511'; % Cat of Life
metaData.links.id_EoL = '327955'; % Ency of Life
metaData.links.id_Wiki = 'Homo_sapiens'; % Wikipedia
metaData.links.id_ADW = 'Homo_sapiens'; % ADW
metaData.links.id_Taxo = '66295'; % Taxonomicon
metaData.links.id_MSW3 = '12100795'; % Mammal Spec World
metaData.links.id_AnAge = 'Homo_sapiens'; % AnAge

%% References
bibkey = 'Wiki'; type = 'Misc'; bib = ...
'howpublished = {\url{http://en.wikipedia.org/wiki/Homo_sapiens}}';
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
bibkey = 'Came1984'; type = 'Book'; bib = [ ... 
'author = {Cameron, N.}, ' ... 
'year = {1984}, ' ...
'title = {The measurement of human growth}, ' ...
'publisher = {Croom Helm}, ' ...
'address = {London}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'AnAge'; type = 'Misc'; bib = ...
'howpublished = {\url{http://genomics.senescence.info/species/entry.php?species=Homo_sapiens}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];

