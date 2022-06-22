function [data, auxData, metaData, txtData, weights] = mydata_Cyclops_vicinus

%% set metaData
metaData.phylum     = 'Arthropoda'; 
metaData.class      = 'Hexanauplia'; 
metaData.order      = 'Cyclopoida'; 
metaData.family     = 'Cyclopidae';
metaData.species    = 'Cyclops_vicinus'; 
metaData.species_en = 'Copepod'; 
metaData.ecoCode.climate = {'Cfb', 'Dfb', 'Dfc'};
metaData.ecoCode.ecozone = {'TH'};
metaData.ecoCode.habitat = {'0iFp', '0iFl', '0iFm'};
metaData.ecoCode.embryo  = {'Fbf'};
metaData.ecoCode.migrate = {};
metaData.ecoCode.food    = {'biP', 'biCi'};
metaData.ecoCode.gender  = {'D'};
metaData.ecoCode.reprod  = {'O'};
metaData.T_typical  = C2K(20); % K, body temp
metaData.data_0     = {'am'; 'Lb'; 'Lj'; 'Lp'; 'Li'; 'Ri'}; 
metaData.data_1     = {'t-L'; 'L-Wd'; 'T-ab'; 'T-aj'; 'T-ap'; 'T-am'}; 

metaData.COMPLETE = 2.6; % using criteria of LikaKear2011

metaData.author   = {'Bas Kooijman'};    
metaData.date_subm = [2011 12 17];              
metaData.email    = {'bas.kooijman@vu.nl'};            
metaData.address  = {'VU University Amsterdam'};   

metaData.author_mod_1   = {'Bas Kooijman'};    
metaData.date_mod_1 = [2013 08 21];              
metaData.email_mod_1    = {'bas.kooijman@vu.nl'};            
metaData.address_mod_1  = {'VU University Amsterdam'};   

metaData.author_mod_2   = {'Bas Kooijman'};    
metaData.date_mod_2 = [2016 01 30];              
metaData.email_mod_2    = {'bas.kooijman@vu.nl'};            
metaData.address_mod_2  = {'VU University Amsterdam'};   

metaData.curator     = {'Starrlight Augustine'};
metaData.email_cur   = {'starrlight.augustine@akvaplan.niva.no'}; 
metaData.date_acc    = [2016 02 04]; 

%% set data
% zero-variate data

data.am = 44;        units.am = 'd';      label.am = 'life span';                bibkey.am = 'HoppMaie1997';   
  temp.am = C2K(19); units.temp.am = 'K'; label.temp.am = 'temperature'; 

data.Lb  = 0.0207;    units.Lb  = 'cm';    label.Lb  = 'total length at birth';   bibkey.Lb  = 'Vijv1980';
data.Lj  = 0.0626;    units.Lj  = 'cm';    label.Lj  = 'total length at metam';   bibkey.Lj  = 'Vijv1980';
data.Lp  = 0.1627;    units.Lp  = 'cm';    label.Lp  = 'total length at puberty'; bibkey.Lp  = 'Vijv1980';
data.Li  = 0.1627;    units.Li  = 'cm';    label.Li  = 'ultimate total length';   bibkey.Li  = 'Vijv1980';

data.Ri  = 50/ 3;   units.Ri  = '#/d';   label.Ri  = 'maximum reprod rate';     bibkey.Ri  = 'HoppMaie1997';   
  temp.Ri = C2K(19); units.temp.Ri = 'K'; label.temp.Ri = 'temperature';
  comment.Ri = '110 eggs per female, one clutch per 3 d on mixed diet'; 

% uni-variate data

% tL-data, Koos Vijverberg (pers com) for females: T = 273+15
data.tL = [  ... % duration of stage (d), length (mm)
      1.9 0.626  
      1.8 0.752
      1.8 0.966
      2.1 1.191
      4.7 1.493
      40  1.627];
data.tL(:,1) = cumsum([8.6; data.tL(1:5,1)]); 
data.tL(:,2) = data.tL(:,2)/ 10; % convert mm to cm
data.tL = [0 0.02; data.tL]; % prepend Lb
units.tL   = {'d', 'cm'};  label.tL = {'time since birth', 'length'};  
temp.tL    = C2K(15);  units.temp.tL = 'K'; label.temp.tL = 'temperature';
bibkey.tL = 'Vijv2011';

% LW-data
data.LW = [  ... % length (mm) dry weight (mug) 
      0.326 0.33 
      0.380 0.80 
      0.416 0.83 
      0.489 1.07 
      0.543 1.43 
      0.597 1.80
      1.086 8.30];
data.LW(:,1) = data.LW(:,1)/ 10; % convert mm to cm
units.LW   = {'cm', 'mug'};  label.LW = {'length', 'dry weight'};  
bibkey.LW = 'CulvBouc1985';

% T-ab data from Vijv1980
data.Tab = [ ... % temperature (C), age at birth (d)
 2.5 18.1
 5   12.2
10    6.0
15    3.7
20    2.1
25    1.6];
units.Tab   = {'C', 'd'};  label.Tab = {'temperature', 'age at birth'};  
bibkey.Tab = 'Vijv1980';

% time - spawning data from Vijv1980 
%  not used; concern buffer handling rule only
Ta0 = [ ... % temperature (C), time between broods (d)
 5   2.8
10   0.9
15   0.7];

% T-tj data from Vijv1980
% time of combined naupliar instars (aj - ab)
%   where aj is age at first copepodite stage
data.Ttj = [ ... % temperature (C), time since birth at metam (d)
 2.5 83.0 
 5   48.2
10   13.1
15    8.6];
units.Ttj   = {'C', 'd'};  label.Ttj = {'temperature', 'time since birth at metam'};  
bibkey.Ttj = 'Vijv1980';

% T-tp data from Vijv1980
% time of combined copepodite stages C1-C5 (ap - aj)
%   where ap is age at last copepodite stage
data.Ttp = [ ... % temperature (C), time since metam at puberty (d) for male, female
 2.5 46 50 
 5   34 43
10   24 29
15   15 18];
data.Ttp = data.Ttp(:,[1 3]); % select females
units.Ttp   = {'C', 'd'};  label.Ttp = {'temperature', 'time since metam at puberty'};  
bibkey.Ttp = 'Vijv1980';

% data from Vijv1980
% time of last copepodite stage (am - ap)
%   where am is age at death
data.Ttm = [ ... % temperature (C), am-ap (d) for male, female
 5  125 143
10  139 139
15   39  51];
data.Ttm = data.Ttm(:,[1 3]); % select females
units.Ttm   = {'C', 'd'};  label.Ttm = {'temperature', 'time since puberty at death'};  
bibkey.Ttm = 'Vijv1980';
 
%% set weights for all real data
weights = setweights(data, []);
weights.Lp = 10 * weights.Lp;
weights.LW = 10 * weights.LW;

%% set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);
data.psd.p_M = 1400; weights.psd.p_M = 20 * weights.psd.p_M;
data.psd.kap = 0.99; weights.psd.kap = 20 * weights.psd.kap;

%% pack auxData and txtData for output
auxData.temp = temp;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Discussion points
D1 = 'Acceleration starts at birth and continues till puberty, beyond metam; growth ceases at puberty';
D2 = 'Data for females of subspecies C.v.vicinus';
metaData.discussion = struct('D1', D1, 'D2', D2);

%% Facts
F1 = 'sexual reproduction in last copepodite stage; 11 moults: 5 naupliar stages, 6 copepodite stages';
metaData.bibkey.F1 = 'Vijv1980'; 
F2 = 'cyclopoid: adult is carnivore, younger copepodites are omnivore, nauplii are herbivore';
metaData.bibkey.F2 = 'Vijv1980'; 
metaData.facts = struct('F1',F1,'F2',F2);

%% Links
metaData.links.id_CoL = '3665f193e29e67b5f91a61c8f72b79e8'; % Cat of Life
metaData.links.id_EoL = '339864'; % Ency of Life
metaData.links.id_Wiki = 'Cyclops_(genus)'; % Wikipedia
metaData.links.id_ADW = 'Cyclops_vicinus'; % ADW
metaData.links.id_Taxo = '125392'; % Taxonomicon

%% References
bibkey = 'Wiki'; type = 'Misc'; bib = ...
'howpublished = {\url{https://en.wikipedia.org/wiki/Cyclops_(genus)}}';
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
bibkey = 'Vijv1980'; type = 'Article'; bib = [ ... 
'author = {Vijverberg, J.}, ' ... 
'year = {1980}, ' ...
'title = {Effect of temperature in laboratory studies on the development and growth of Cladocera and copepoda from {T}jeukemeer, the {N}etherlands.}, ' ...
'journal = {Freshwater Biol}, ' ...
'volume = {10}, ' ...
'pages = {317--340}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'HoppMaie1997'; type = 'Article'; bib = [ ... 
'author = {Hopp, U. and Maier, G. and Bleher, R.}, ' ... 
'year = {1997}, ' ...
'title = {Reproduction and adult longevity of five planktonic cyclopoid copepods reared on different diets: a comparative study}, ' ...
'journal = {Freshwater Biol}, ' ...
'volume = {38}, ' ...
'pages = {289--300}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Vijv2011'; type = 'Misc'; bib = [ ...
'author = {Vijverberg, J.}, ' ... 
'year = {2011}, ' ...
'note = {Personal communication}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'CulvBouc1985'; type = 'Misc'; bib = [ ...
'author = {Culver, D. A. and Boucherie, M. M. and Bean, D. J. and Fletcher, J. W.}, ' ... 
'year = {1985}, ' ...
'title = {Biomass of freshwater crustacean zooplankton from length-weight regressions}, ' ...
'journal = {Can. J. Fish. Aquat. Sci.}, ' ...
'volume = {42}, ' ...
'pages = {1380--1390}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
