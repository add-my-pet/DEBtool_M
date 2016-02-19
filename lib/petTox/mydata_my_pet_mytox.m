%% mydata_my_pet_mytox
% Sets referenced data with toxicant

%%
function [data, auxData, metaData, txtData, weights] = mydata_my_pet_mytox
  % created by Starrlight Augustine, Bas Kooijman, Dina Lika, Goncalo Marques and Laure Pecquerie 2016/02/18
  
  %% Syntax
  % [data, auxData, metaData, txtData, weights] = <../mydata_my_pet_mytox.m *mydata_my_pet_mytox*>
  
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
metaData.phylum     = 'Arthropoda'; 
metaData.class      = 'Branchiopoda'; 
metaData.order      = 'Cladocera'; 
metaData.family     = 'Daphniidae';
metaData.species    = 'Daphnia_magna'; 
metaData.species_en = 'waterflea'; 

metaData.toxicant   = 'mytox';
metaData.CASnb      = 3;
metaData.w_Q        = 45;  % g/mol, molecular weight
metaData.SMILES     = 345; % code
metaData.logKOW     = 98;  % solubilty
metaData.MoA        = 'MoA';
metaData.excRoute   = 'excretion route'; % e.g. urine, bile, 

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
% add an optional comment structure to give any additional explanations on
% how the value was chosen, see the last column of the ab data set for an
% example

% data.am = 475;     units.am = 'd';    label.am = 'life span';     bibkey.am = 'Wiki';   
%   temp.am = C2K(20);  units.temp.am = 'K';     label.temp.am = 'temperature'; 
%   tox.am = 5;         units.tox.am = 'mg/kg';  label.tox.am = 'toxicant concentration'; 
 
% uni-variate data 
c = [0.00  0.20  0.40  0.80  1.00  2.00]';          % cadmium mM
t = [1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21]'; % days
N = [0.000   0.000   0.000   0.000   0.000   0.000; % Daphnia magna 
     0.000   0.000   0.000   0.000   0.000   0.000; % offspring per female
     0.000   0.000   0.000   0.000   0.000   0.000; 
     0.000   0.000   0.000   0.000   0.000   0.000;
     0.000   0.000   0.000   0.000   0.000   0.000;
     0.000   0.000   0.000   0.000   0.000   0.000;
     1.400   0.800   1.800   0.000   0.900   0.000;
     3.600   1.300   2.300   2.600   2.800   2.600;
     10.400  13.600   7.000   5.100   5.400   3.900;
     20.400  16.600  13.800  12.000   7.800   4.800;
     22.800  18.900  13.800  14.500   7.800   4.800;
     31.200  27.000  14.700  14.500   7.800   4.800;
     41.500  35.500  20.800  15.600   9.300   4.800;
     43.400  37.900  20.800  15.600   9.300   4.800;
     53.000  44.700  24.100  15.600   9.300   4.800;
     64.100  48.300  29.700  16.800  10.000   5.244;
     66.800  51.000  31.200  16.800  11.300   5.244;
     75.900  58.300  39.500  17.000  11.300   5.244;
     88.100  66.900  45.300  21.300  11.300   5.244;
     90.600  72.000  47.600  21.700  11.300   5.244;
     98.700  76.200  53.000  21.700  11.300   5.244];

 
data.tN0 = [t, N(:,1)]; units.tN0   = {'d', '#'}; label.tN0 = {'time since birth','cum. nb. eggs'}; bibkey.tN0 = 'unknown';
data.tN1 = [t, N(:,2)]; units.tN1   = {'d', '#'}; label.tN1 = {'time since birth','cum. nb. eggs'}; bibkey.tN1 = 'unknown';
data.tN2 = [t, N(:,3)]; units.tN2   = {'d', '#'}; label.tN2 = {'time since birth','cum. nb. eggs'}; bibkey.tN2 = 'unknown';
data.tN3 = [t, N(:,4)]; units.tN3   = {'d', '#'}; label.tN3 = {'time since birth','cum. nb. eggs'}; bibkey.tN3 = 'unknown';
data.tN4 = [t, N(:,5)]; units.tN4   = {'d', '#'}; label.tN4 = {'time since birth','cum. nb. eggs'}; bibkey.tN4 = 'unknown';
data.tN5 = [t, N(:,6)]; units.tN5   = {'d', '#'}; label.tN5 = {'time since birth','cum. nb. eggs'}; bibkey.tN5 = 'unknown';

% auxiliary data :
temp.tN0    = C2K(20);  units.temp.tN0 = 'K'; label.temp.tN0 = 'temperature';
temp.tN1    = C2K(20);  units.temp.tN1 = 'K'; label.temp.tN1 = 'temperature';
temp.tN2    = C2K(20);  units.temp.tN2 = 'K'; label.temp.tN2 = 'temperature';
temp.tN3    = C2K(20);  units.temp.tN3 = 'K'; label.temp.tN3 = 'temperature';
temp.tN4    = C2K(20);  units.temp.tN4 = 'K'; label.temp.tN4 = 'temperature';
temp.tN5    = C2K(20);  units.temp.tN5 = 'K'; label.temp.tN5 = 'temperature';

tox.tN0    = c(1);  units.tox.tN0 = 'mM'; label.tox.tN0 = 'cadmium';
tox.tN1    = c(2);  units.tox.tN1 = 'mM'; label.tox.tN1 = 'cadmium';
tox.tN2    = c(3);  units.tox.tN2 = 'mM'; label.tox.tN2 = 'cadmium';
tox.tN3    = c(4);  units.tox.tN3 = 'mM'; label.tox.tN3 = 'cadmium';
tox.tN4    = c(5);  units.tox.tN4 = 'mM'; label.tox.tN4 = 'cadmium';
tox.tN5    = c(6);  units.tox.tN5 = 'mM'; label.tox.tN5 = 'cadmium';

L0.tN0 = 0.08; units.L0.tN0 = 'cm'; label.L0.tN0 = 'inital total length';
L0.tN1 = 0.08; units.L0.tN1 = 'cm'; label.L0.tN1 = 'inital total length';
L0.tN2 = 0.08; units.L0.tN2 = 'cm'; label.L0.tN2 = 'inital total length';
L0.tN3 = 0.08; units.L0.tN3 = 'cm'; label.L0.tN3 = 'inital total length';
L0.tN4 = 0.08; units.L0.tN4 = 'cm'; label.L0.tN4 = 'inital total length';
L0.tN5 = 0.08; units.L0.tN5 = 'cm'; label.L0.tN5 = 'inital total length';

% comment.tN0 = 'Put here any relevant remarks about this data'; % optional field

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

%% pack auxData and txtData for output
auxData.temp = temp;
auxData.tox = tox;
auxData.L0 = L0;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
if exist('comment','var')
  txtData.comment = comment;
end

%% Discussion points
D1 = 'Author_mod_1: I found some data on data that cannot be used';
% optional bibkey: metaData.bibkey.D1 = 'Kooy2010';
metaData.discussion = struct('D1', D1);

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
