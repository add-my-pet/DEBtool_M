%% mydata_my_pet
% Sets referenced data

%%
function [data, auxData, metaData, txtData, weights] = mydata_my_pet
  % created by Starrlight Augustine, Bas Kooijman, Dina Lika, Goncalo Marques and Laure Pecquerie 2015/03/31
  % last modified: 2015/07/28 
  
  %% Syntax
  % [data, auxData, metaData, txtData, weights] = <../mydata_my_pet.m *mydata_my_pet*>
  
  %% Description
  % Sets data, pseudodata, metadata, auxdata, explanatory text, weights coefficients.
  % Meant to be a template in add-my-pet
  %
  % Output
  %
  % * data: structure with data
  % * auxData: structure with auxilliairy data that is required to compute predictions of data (e.g. temperature, food.). 
  %   auxData is unpacked in predict and the user needs to construct predictions accordingly.
  % * txtData: text vector for the presentation of results
  % * metaData: structure with info about this entry
  % * weights: structure with weights for each data set
  
  %% Remarks
  % Plots with the same labels and units can be combined into one plot by assigning a cell string with dataset names to metaData.grp.sets, and a caption to metaData.grp.comment. 
  
  %% To do (remove these remarks after editing this file)
  % * copy this template; replace 'my_pet' by the name of your species (Genus_species)
  % * fill in metaData fields with the proper information
  % * insert references for each data (an example is given), for multiple references, please use commas to separate references
  % * edit real data; remove all data that to not belong to your pet
  % * list facts - this is where you can add relevant/interesting information on its biology
  % * edit discussion concerning e.g. choice of model, assumptions needed to model certain data sets etc. 
  % * fill in all of the references

%% set metaData

metaData.phylum     = 'my_pet_phylum'; 
metaData.class      = 'my_pet_class'; 
metaData.order      = 'my_pet_order'; 
metaData.family     = 'my_pet_family';
metaData.species    = 'my_pet1'; % 
metaData.species_en = 'my_pet_english_name'; 
metaData.T_typical  = C2K(20); % K, body temp
metaData.data_0     = {'ab'; 'ap'; 'am'; 'Lb'; 'Lp'; 'Li'; 'Wdb'; 'Wdp'; 'Wdi'; 'Ri'};  % tags for different types of zero-variate data
metaData.data_1     = {'t-L'; 'L-W'}; % tags for different types of uni-variate data

metaData.COMPLETE = 2.5; % using criteria of LikaKear2011

metaData.author   = {'FirstName1 LastName1'};            % put names as authors as separate strings:  {'FirstName1 LastName2','FirstName2 LastName2'} , with corresponding author in first place 
metaData.date_subm = [2015 04 20];                       % [year month day], date at which the entry is submitted
metaData.email    = {'myname@myuniv.univ'};              % e-mail of corresponding author
metaData.address  = {'affiliation, zipcode, country'};   % affiliation, postcode, country of the corresponding author

% uncomment and fill in the following fields when the entry is updated:
% metaData.author_mod_1  = {'FirstName3 LastName3'};          % put names as authors as separate strings:  {'author1','author2'} , with corresponding author in first place 
% metaData.date_mod_1    = [2017 09 18];                      % [year month day], date modified entry is accepted into the collection
% metaData.email_mod_1   = {'myname@myuniv.univ'};            % e-mail of corresponding author
% metaData.address_mod_1 = {'affiliation, zipcode, country'}; % affiliation, postcode, country of the corresponding author

% for curators only ------------------------------
% metaData.curator     = {'FirstName LastName'};
% metaData.email_cur   = {'myname@myuniv.univ'}; 
% metaData.date_acc    = [2015 04 22]; 
%-------------------------------------------------

%% set data
% zero-variate data;
% typically depend on scaled functional response f.
% here assumed to be equal for all real data; the value of f is specified in pars_init_my_pet.
% add an optional comment structure to give any additional explanations on
% how the value was chosen, see the last column of the ab data set for an
% example

% age 0 is at onset of embryo development
data.ab = 15;      units.ab = 'd';    label.ab = 'age at birth';  bibkey.ab = 'MollCano2010';   comment.ab  = 'mean value taken from several measurements'; 
  temp.ab = C2K(20);  units.temp.ab = 'K'; label.temp.ab = 'temperature';
  % observed age at birth is frequently larger than ab, because of diapauzes during incubation
data.ap = 261;     units.ap = 'd';    label.ap = 'age at puberty'; bibkey.ap = 'Anon2015';
  temp.ap = C2K(20);  units.temp.ap = 'K'; label.temp.ap = 'temperature';
  % observed age at puberty is frequently larger than ap, 
  %   because allocation to reproduction starts before first eggs appear
data.am = 591;     units.am = 'd';    label.am = 'life span';     bibkey.am = 'Wiki';   
  temp.am = C2K(20);  units.temp.am = 'K'; label.temp.am = 'temperature'; 
% (accounting for aging only) 

% Please specify what type of length measurement is used for your species.
% We put here snout-to-vent length, but you should change this depending on your species:
data.Lb  = 0.45;   units.Lb  = 'cm';   label.Lb  = 'snout to vent length at birth';    bibkey.Lb  = 'Anon2015';  
data.Lp  = 2.36;   units.Lp  = 'cm';   label.Lp  = 'snout to vent length at puberty';  bibkey.Lp  = {'Anon2015','Wiki'}; % for multiple references, please use commas to separate references
data.Li  = 6.25;   units.Li  = 'cm';   label.Li  = 'ultimate snout to vent length';    bibkey.Li  = 'Wiki';

data.Wdb = 5.8e-5; units.Wdb = 'g';    label.Wdb = 'dry weight at birth';             bibkey.Wdb = 'Anon2015';
data.Wdp = 8e-3;   units.Wdp = 'g';    label.Wdp = 'dry weight at puberty';           bibkey.Wdp = 'Anon2015';
data.Wdi = 0.15;   units.Wdi = 'g';    label.Wdi = 'ultimate dry weight';             bibkey.Wdi = 'Wiki';

data.Ri  = 2.3;    units.Ri  = '#/d';  label.Ri  = 'maximum reprod rate';              bibkey.Ri  = 'Wiki';   
% for an individual of ultimate length Li 
temp.Ri = C2K(20);  units.temp.Ri = 'K'; label.temp.Ri = 'temperature';
 
% uni-variate data

% uni-variate data at f = 0.8 (this value should be added in pars_init_my_pet as a parameter f_tL) 
% snout-to-vent length and wet weights were measured at the same time
data.tL = [0     50  100 200 300 400 500 600;    % d, time since birth
           0.45  1.1 1.7 2.7 3.4 4.0 4.5 4.9]';  % cm, snout-to-vent length at f and T
units.tL   = {'d', 'cm'};  label.tL = {'time since birth', 'snout to vent length'};  bibkey.tL = 'Anon2015';
temp.tL    = C2K(20);  units.temp.tL = 'K'; label.temp.tL = 'temperature';
comment.tL = 'Put here any relevant remarks about this data'; % optional field
  
data.LW = [0.9 1.8 3.2 4.3 5.0;      % cm, snout-to-vent length at f
           0.004 0.03 0.20 0.55 1.1]';   % g, wet weights at f and T
units.LW = {'cm', 'g'};     label.LW = {'snout to vent length', 'wet weights'};  bibkey.LW = 'Anon2015';
comment.LW = 'Put here any relevant remarks about this data'; % optional field

%% set weights for all real data
weights = setweights(data, []);

%% overwriting weights (remove these remarks after editing the file)
% the weights were set automatically with the function setweigths,
% if one wants to ovewrite one of the weights it should always present an explanation example:
%
% zero-variate data:
% weights.Wdi = 100 * weights.Wdi; % Much more confidence in the ultimate dry
%                                % weights than the other data points
% uni-variate data: 
% weights.tL = 2 * weights.tL;

%% set pseudodata and respective weights
% (pseudo data are in data.psd and weights are in weights.psd)
[data, units, label, weights] = addpseudodata(data, units, label, weights);

%% overwriting pseudodata and respective weights (remove these remarks after editing the file)
% the pseudodata and respective weights were set automatically with the function setpseudodata
% if one wants to overwrite one of the values then please provide an explanation
% example:
% data.psd.p_M = 1000;                    % my_pet belongs to a group with high somatic maint 
% weights.psd.kap = 10 * weights.psd.kap;   % I need to give this pseudo data a higher weights

%% pack auxData and txtData for output
auxData.temp = temp;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
if exist('comment','var')
  txtData.comment = comment;
end

%% Discussion points
D1 = 'Author_mod_1: I found information on the number of eggs per female as a function of length in Anon2013 that was much higher than in Anon2015 but chose to not include it as the temperature was not provided';
% optional bibkey: metaData.bibkey.D1 = 'Anon2013';
D2 = 'Author_mod_1: I was surprised to observe that the weights coefficient for ab changed so much the parameter values';     
% optional bibkey: metaData.bibkey.D2 = 'Kooy2010';
metaData.discussion = struct('D1', D1, 'D2', D2);

%% Facts
% list facts: F1, F2, etc.
% make sure each fact has a corresponding bib key
% do not put any DEB modelling assumptions here, only relevant information on
% biology and life-cycles etc.
F1 = 'The larval stage lasts 202 days and no feeding occurs';
metaData.bibkey.F1 = 'Wiki'; % optional bibkey
metaData.facts = struct('F1',F1);

%% References
% the following two references should be kept-----------------------------------------------------------
bibkey = 'Kooy2010'; type = 'Book'; bib = [ ...  % used in setting of chemical parameters and pseudodata
'author = {Kooijman, S.A.L.M.}, ' ...
'year = {2010}, ' ...
'title  = {Dynamic Energy Budget theory for metabolic organisation}, ' ...
'publisher = {Cambridge Univ. Press, Cambridge}, ' ...
'pages = {Table 4.2 (page 150), 8.1 (page 300)}, ' ...
'howpublished = {\url{http://www.bio.vu.nl/thb/research/bib/Kooy2010.html}}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'LikaKear2011'; type = 'Article'; bib = [ ...  % used for the estimation method
'author = {Lika, K. and Kearney, M.R. and Freitas, V. and van der Veer, H.W. and van der Meer, J. and Wijsman, J.W.M. and Pecquerie, L. and Kooijman, S.A.L.M.},'...
'year = {2011},'...
'title = {The ''''covariation method'''' for estimating the parameters of the standard Dynamic Energy Budget model \textrm{I}: Philosophy and approach},'...
'journal = {Journal of Sea Research},'...
'volume = {66},'...
'number = {4},'...
'pages = {270-277},'...
'DOI = {10.1016/j.seares.2011.07.010},'...
'howpublished = {\url{http://www.sciencedirect.com/science/article/pii/S1385110111001055}}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%------------------------------------------------------------------------------------------------------

 % References for the data, following BibTex rules
 % author names : author = {Last Name, F. and Last Name2, F2. and Last Name 3, F3. and Last Name 4, F4.}
 % latin names in title e.g. \emph{Pleurobrachia pileus}

bibkey = 'Wiki'; type = 'Misc'; bib = [...
'howpublished = {\url{http://en.wikipedia.org/wiki/my_pet}},'...% replace my_pet by latin species name
'note = {Accessed : 2015-04-30}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'MollCano2010'; type = 'Article'; bib = [ ... % meant as example; replace this and further bib entries
'author = {M{\o}ller, L. F. and Canon, J. M. and Tiselius, P.}, ' ... 
'year = {2010}, ' ...
'title = {Bioenergetics and growth in the ctenophore \emph{Pleurobrachia pileus}}, ' ...
'journal = {Hydrobiologia}, ' ...
'volume = {645}, ' ...
'number = {4}, '...
'pages = {167-178}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Anon2015'; type = 'Misc'; bib = [ ...
'author = {Anonymous}, ' ...
'year = {2015}, ' ...
'howpublished = {\url{http://www.fishbase.org/summary/Rhincodon-typus.html}}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
