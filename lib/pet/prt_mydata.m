%% prt_mydata
% writes file mydata_my_pet.m from 4 structures

%%
function prt_mydata(data, auxData, metaData, txtData)
% created 2020/05/29 by  Bas Kooijman

%% Syntax
% <../prt_mydata.m *prt_mydata*> (data, auxData, metaData, txtData) 

%% Description
% Writes file mydata_my_pet.m from 4 data-structures; it is inverse to mydata_my_pet.m.
%
% Input:
%
% * data: structure with data
% * auxData: structure with auxilirary data 
% * metaData: structure with metaData 
% * txtData: structure with text for data 

%% Remarks
% The file will be saved in your local directory; 
% use the cd command to the dir of your choice BEFORE running this function to save files in the desired place.
% All weights are set at default values in the resulting file; 
% you might want to change them in the file during the estimation process.
% This version ignores auxData other than temperature.

%% Example of use
% 

fid = fopen(['mydata_', metaData.species, '.m'], 'w+'); % open file for reading and writing, delete existing content
fprintf(fid, 'function [data, auxData, metaData, txtData, weights] = mydata_%s\n', metaData.species);
fprintf(fid, '%% file generated by prt_mydata\n\n');

%% set metaData
fprintf(fid, '%%%% set metaData\n');

fprintf(fid, 'metaData.phylum     = ''%s'';\n', metaData.phylum); 
fprintf(fid, 'metaData.class      = ''%s'';\n', metaData.class); 
fprintf(fid, 'metaData.order      = ''%s'';\n', metaData.order); 
fprintf(fid, 'metaData.family     = ''%s'';\n', metaData.family); 
fprintf(fid, 'metaData.species    = ''%s'';\n', metaData.species); 
fprintf(fid, 'metaData.species_en = ''%s'';\n\n', metaData.species_en); 

fprintf(fid, 'metaData.ecoCode.climate = %s;\n', cell2str(metaData.ecoCode.climate));
fprintf(fid, 'metaData.ecoCode.ecozone = %s;\n', cell2str(metaData.ecoCode.ecozone));
fprintf(fid, 'metaData.ecoCode.habitat = %s;\n', cell2str(metaData.ecoCode.habitat));
fprintf(fid, 'metaData.ecoCode.embryo  = %s;\n', cell2str(metaData.ecoCode.embryo));
if isempty(metaData.ecoCode.migrate) || strcmp(metaData.ecoCode.migrate{1}, ' ')
  fprintf(fid, 'metaData.ecoCode.migrate = {};\n');
else
  fprintf(fid, 'metaData.ecoCode.migrate = %s;\n', cell2str(metaData.ecoCode.migrate));
end
fprintf(fid, 'metaData.ecoCode.food    = %s;\n',   cell2str(metaData.ecoCode.food));
fprintf(fid, 'metaData.ecoCode.gender  = %s;\n',   cell2str(metaData.ecoCode.gender));
fprintf(fid, 'metaData.ecoCode.reprod  = %s;\n\n', cell2str(metaData.ecoCode.reprod));

fprintf(fid, 'metaData.T_typical  = C2K(%g); %% K, body temp\n\n', K2C(metaData.T_typical));

fprintf(fid, 'metaData.data_0     = %s;\n',   cell2str(metaData.data_0));
fprintf(fid, 'metaData.data_1     = %s;\n\n', cell2str(metaData.data_1)); 

fprintf(fid, 'metaData.COMPLETE   = %g; %% using criteria of LikaKear2011\n\n', metaData.COMPLETE);

fprintf(fid, 'metaData.author     = %s;\n',   cell2str(metaData.author)); 
fprintf(fid, 'metaData.date_subm  = %s;\n',   vec2str(metaData.date_subm)); 
fprintf(fid, 'metaData.email      = %s;\n',   cell2str(metaData.email));
fprintf(fid, 'metaData.address    = %s;\n\n', cell2str(metaData.address));

if isfield(metaData, 'author_mod')
  fprintf(fid, 'metaData.author_mod   = %s;\n',   cell2str(metaData.author_mod)); 
  fprintf(fid, 'metaData.date_mod     = %s;\n',   vec2str(metaData.date_mod)); 
  fprintf(fid, 'metaData.email_mod    = %s;\n',   cell2str(metaData.email_mod));
  fprintf(fid, 'metaData.address_mod  = %s;\n\n', cell2str(metaData.address_mod));
end

for i=1:10 % max 10 modifications assumed
  fldnm = ['author_mod_', num2str(i)];
  if isfield(metaData, fldnm)
    fprintf(fid, 'metaData.%s  = %s;\n', fldnm, cell2str(metaData.(fldnm))); 
    fldnm = ['date_mod_', num2str(i)];    fprintf(fid, 'metaData.%s = %s;\n',   fldnm, vec2str(metaData.(fldnm)));
    fldnm = ['email_mod_', num2str(i)];   fprintf(fid, 'metaData.%s = %s;\n',   fldnm, cell2str(metaData.(fldnm)));
    fldnm = ['date_mod_', num2str(i)];    fprintf(fid, 'metaData.%s = %s;\n',   fldnm, vec2str(metaData.(fldnm)));
    fldnm = ['address_mod_', num2str(i)]; fprintf(fid, 'metaData.%s = %s;\n\n', fldnm, cell2str(metaData.(fldnm)));
  end
end

fprintf(fid, 'metaData.curator    = %s;\n',   cell2str(metaData.curator)); 
fprintf(fid, 'metaData.email_cur  = %s;\n',   cell2str(metaData.email_cur)); 
fprintf(fid, 'metaData.date_acc   = %s;\n\n', vec2str(metaData.date_acc));

%% set zero-variate data

% sort data fields to sequence in prdCode, based on units
fld = fields(data); fld = fld(~strcmp(fld, 'psd')); n_fld = length(fld); sel = false(n_fld, 1);
model = get_model(metaData.phylum, metaData.class, metaData.order); if isempty(model); model = 'abj'; end;
load prdCode; FLD = fields(prdCode.(model));
[mem,ind] = ismember(fld, FLD); if ~any(~mem); [~, ind] = sort(ind); fld = fld(ind); end;

% split zero- from uni-variate data
for i = 1:n_fld
  sel(i) = size(data.(fld{i}),1) > 1;
end
fld0 = fld(~sel); fld1 = fld(sel); n_fld0 = length(fld0); n_fld1 = length(fld1);

% write zero-variate data
if n_fld0 > 0
  fprintf(fid, '%%%% set zero-variate data\n');
end

for i = 1:n_fld0
  fprintf(fid, 'data.%s = %g; ', fld0{i}, data.(fld0{i}));
  fprintf(fid, 'units.%s = ''%s''; ', fld0{i}, txtData.units.(fld0{i}));
  fprintf(fid, 'label.%s = ''%s''; ', fld0{i}, txtData.label.(fld0{i}));
  if iscell(txtData.bibkey.(fld0{i}))
    fprintf(fid, 'bibkey.%s = %s;\n', fld0{i}, cell2str(txtData.bibkey.(fld0{i})));
  else
    fprintf(fid, 'bibkey.%s = ''%s'';\n', fld0{i}, txtData.bibkey.(fld0{i}));
  end
  if isfield(auxData.temp, fld0{i})
    fprintf(fid, '  temp.%s = C2K(%g); ', fld0{i}, K2C(auxData.temp.(fld0{i})));
    fprintf(fid, 'units.temp.%s = ''%s''; ', fld0{i}, txtData.units.temp.(fld0{i}));
    fprintf(fid, 'label.temp.%s = ''%s'';\n', fld0{i}, txtData.label.temp.(fld0{i}));
  end
  if isfield(txtData.comment, fld0{i}) && ~isempty(txtData.comment.(fld0{i}))
    txt = txtData.comment.(fld0{i});
    if iscell(txt)
      txt = txt{1};
    end
    fprintf(fid, '  comment.%s = ''%s'';\n', fld0{i}, txt);
  end 
  if i < n_fld0 && ~strcmp(txtData.units.(fld0{i}), txtData.units.(fld0{i+1}))
    fprintf(fid, '\n'); % write empty line if units change
  end
end
fprintf(fid, '\n'); 

%% set uni-variate data
if n_fld1 > 0
  fprintf(fid, '%%%% set uni-variate data\n');
end

for i = 1:n_fld1
  label = txtData.label.(fld1{i}); units = txtData.units.(fld1{i}); data1 = data.(fld1{i}); n_dat = size(data1,1);
  fprintf(fid, '%% %s - %s\n', label{1}, label{2});
  fprintf(fid, 'data.%s = [ ... \n', fld1{i});
  for j = 1:n_dat-1
    fprintf(fid, '  %g %g\n', data1(j,1), data1(j,2));
  end
  fprintf(fid, '  %g %g];\n', data1(end,1), data1(end,2));
  fprintf(fid, 'units.%s = {''%s'', ''%s''}; ', fld1{i}, units{1}, units{2});
  fprintf(fid, 'label.%s = {''%s'', ''%s''};\n', fld1{i}, label{1}, label{2});
  if isfield(auxData.temp, fld1{i})
     fprintf(fid, 'temp.%s = C2K(%g); ', fld1{i}, K2C(auxData.temp.(fld1{i})));
     fprintf(fid, 'units.temp.%s = ''K''; label.temp.%s = ''temperature'';\n', fld1{i}, fld1{i});
  end
  if iscell(txtData.bibkey.(fld1{i}))
    fprintf(fid, 'bibkey.%s = %s;\n', fld1{i}, cell2str(txtData.bibkey.(fld1{i})));
  else
    fprintf(fid, 'bibkey.%s = ''%s'';\n', fld1{i}, txtData.bibkey.(fld1{i}));
  end
  if isfield(txtData.comment, fld1{i}) & ~isempty(txtData.comment.(fld1{i}))
    txt = txtData.comment.(fld1{i});
    if iscell(txt)
      txt = txt{1};
    end
    fprintf(fid, 'comment.%s = ''%s'';\n', fld1{i}, txt);
  end
  fprintf(fid, '\n');  
end

%% set weights
fprintf(fid, '%%%% set weights for all real data\n');
fprintf(fid, 'weights = setweights(data, []);\n\n');

%% set pseudodata and respective weights
fprintf(fid, '%%%% set pseudodata and respective weights\n');
fprintf(fid, '[data, units, label, weights] = addpseudodata(data, units, label, weights);\n\n');

%% pack auxData and txtData for output
fprintf(fid, '%%%% pack auxData and txtData for output\n');

fprintf(fid, 'auxData.temp = temp;\n');
fprintf(fid, 'txtData.units = units;\n');
fprintf(fid, 'txtData.label = label;\n');
fprintf(fid, 'txtData.bibkey = bibkey;\n');
if isfield(txtData, 'comment') & ~isempty(txtData.comment)
  flds_comment = fieldnames(txtData.comment); n_fld = length(flds_comment); n=0;
  for i=1:n_fld; if isempty(txtData.comment.(flds_comment{i})); n=n+1; end; end
  if n<n_fld; fprintf(fid, 'txtData.comment = comment;\n'); end
end
fprintf(fid, '\n');

%% Group plots
if isfield(metaData, 'grp')
  fprintf(fid, '%%%% Group plots\n');
  sets = metaData.grp.sets; n = length(sets); str_set = []; str_com = [];
  for i = 1:n
    nm_set = ['set', num2str(i)];     str_set = [str_set, nm_set, ', '];
    nm_com = ['comment', num2str(i)]; str_com = [str_com, nm_com, ', '];
    fprintf(fid, '%s = %s; ', nm_set, cell2str(sets{i})); 
    fprintf(fid, '%s = %s;\n', nm_com, cell2str(metaData.grp.comment{i})); 
  end
  fprintf(fid, 'metaData.grp.sets = {%s};\n', str_set(1:end-2));
  fprintf(fid, 'metaData.grp.comment = {%s};\n\n', str_com(1:end-2));
end

%% Discussion points
if isfield(metaData, 'discussion')
  fprintf(fid, '%%%% Discussion points\n');
  fld = fieldnames(metaData.discussion); n = length(fld); str = [];
  for i = 1:n
    str = [str, '''', fld{i}, ''',', fld{i}, ', '];
    fprintf(fid, '%s  = ''%s'';\n', fld{i}, metaData.discussion.(fld{i}));
    if isfield(metaData, 'bibkey') && isfield(metaData.bibkey, fld{i})
       fprintf(fid, 'metaData.bibkey.%s = %s;\n', fld{i}, cell2str(metaData.bibkey.(fld{i})));
    end
  end
  str([end,end-1])=[];
  fprintf(fid, 'metaData.discussion = struct(%s);\n\n', str);
end

%% Facts
if isfield(metaData, 'facts') && ~isempty(metaData.facts.F1)
  fprintf(fid, '%%%% Facts\n');
  fld = fieldnames(metaData.facts); n = length(fld); str = [];
  for i = 1:n
    str = [str, '''', fld{i}, ''',', fld{i}, ', '];
    fprintf(fid, '%s  = ''%s'';\n', fld{i}, metaData.facts.(fld{i}));
    if isfield(metaData, 'bibkey') && isfield(metaData.bibkey, fld{i})
       fprintf(fid, 'metaData.bibkey.%s = %s;\n', fld{i}, cell2str(metaData.bibkey.(fld{i})));
    end
  end
  str([end,end-1])=[];
  fprintf(fid, 'metaData.facts = struct(%s);\n\n', str);
end

%% Acknowledgment
if isfield(metaData, 'acknowledgment')
  fprintf(fid, '%%%% Acknowledgment\n');
  fprintf(fid, 'metaData.acknowledgment = ''%s'';\n\n', metaData.acknowledgment);
end

%% Links
fprintf(fid, '%%%% Links\n');
if isfield(metaData.links, 'id_CoL')
  fprintf(fid, 'metaData.links.id_CoL = ''%s''; %% Cat of Life\n', metaData.links.id_CoL);
end
if isfield(metaData.links, 'id_EoL') && ~isempty(metaData.links.id_EoL)
  fprintf(fid, 'metaData.links.id_EoL = ''%s''; %% Ency of Life\n', metaData.links.id_EoL);
end
if isfield(metaData.links, 'id_Wiki') && ~isempty(metaData.links.id_Wiki)
  fprintf(fid, 'metaData.links.id_Wiki = ''%s''; %% Wikipedia\n', metaData.links.id_Wiki);
end
if isfield(metaData.links, 'id_ADW') && ~isempty(metaData.links.id_ADW)
  fprintf(fid, 'metaData.links.id_ADW = ''%s''; %% Anim Div. Web\n', metaData.links.id_ADW);
end
if isfield(metaData.links, 'id_Taxo') && ~isempty(metaData.links.id_Taxo)
  fprintf(fid, 'metaData.links.id_Taxo = ''%s''; %% Taxonomicon\n', metaData.links.id_Taxo);
end
if isfield(metaData.links, 'id_WoRMS') &&  ~isempty(metaData.links.id_WoRMS)
  fprintf(fid, 'metaData.links.id_WoRMS = ''%s'';\n', metaData.links.id_WoRMS);
end
if isfield(metaData.links, 'id_molluscabase') && ~isempty(metaData.links.id_molluscabase)
  fprintf(fid, 'metaData.links.id_molluscabase = ''%s'';\n', metaData.links.id_molluscabase);
end
if isfield(metaData.links, 'id_fishbase') && ~isempty(metaData.links.id_fishbase)
  fprintf(fid, 'metaData.links.id_fishbase = ''%s'';\n', metaData.links.id_fishbase);
end
if isfield(metaData.links, 'id_amphweb') && ~isempty(metaData.links.id_amphweb)
  fprintf(fid, 'metaData.links.id_amphweb = ''%s'';\n', metaData.links.id_amphweb);
end
if isfield(metaData.links, 'id_ReptileDB') && ~isempty(metaData.links.id_ReptileDB)
  fprintf(fid, 'metaData.links.id_ReptileDB = ''%s'';\n', metaData.links.id_ReptileDB);
end
if isfield(metaData.links, 'id_avibase') && ~isempty(metaData.links.id_avibase)
  fprintf(fid, 'metaData.links.id_avibase = ''%s'';\n', metaData.links.id_avibase);
end
if isfield(metaData.links, 'id_birdlife') && ~isempty(metaData.links.id_birdlife)
  fprintf(fid, 'metaData.links.id_birdlife = ''%s'';\n', metaData.links.id_birdlife);
end
if isfield(metaData.links, 'id_MSW3') && ~isempty(metaData.links.id_MSW3)
  fprintf(fid, 'metaData.links.id_MSW3 = ''%s''; %% Mammal Spec of the World\n', metaData.links.id_MSW3);
end
if isfield(metaData.links, 'id_AnAge') && ~isempty(metaData.links.id_AnAge)
  fprintf(fid, 'metaData.links.id_AnAge = ''%s''; %% Anim. Aging\n', metaData.links.id_AnAge);
end
fprintf(fid, '\n');

%% References
fprintf(fid, '%%%% References\n');
fld = fields(metaData.biblist); fld = unique([fld; {'Kooy2010'}]); n = length(fld); 
for i = 1:n
  if strcmp(fld{i}, 'Kooy2010')
    fprintf(fid, '%s\n', 'bibkey = ''Kooy2010''; type = ''Book''; bib = [ ...  % used in setting of chemical parameters and pseudodata');
    fprintf(fid, '%s\n', '''author = {Kooijman, S.A.L.M.}, '' ...');
    fprintf(fid, '%s\n', '''year = {2010}, '' ...');
    fprintf(fid, '%s\n', '''title  = {Dynamic Energy Budget theory for metabolic organisation}, '' ...');
    fprintf(fid, '%s\n', '''publisher = {Cambridge Univ. Press, Cambridge}, '' ...');
    fprintf(fid, '%s\n', '''pages = {Table 4.2 (page 150), 8.1 (page 300)}, '' ...');
    fprintf(fid, '%s\n', '''howpublished = {\url{http://www.bio.vu.nl/thb/research/bib/Kooy2010.html}}''];');
    fprintf(fid, '%s\n', 'metaData.biblist.(bibkey) = [''''''@'', type, ''{'', bibkey, '', '' bib, ''}'''';''];');
    fprintf(fid, '%s\n', '%');
  else
    bib = metaData.biblist.(fld{i}); bib(end) = []; i_head = strfind(bib, ','); head = bib(1:i_head(1)); 
    i_type = strfind(head, '{'); type = head(2:i_type-1);
    fprintf(fid, 'bibkey = ''%s''; type = ''%s''; bib = [ ...\n', fld{i}, type);
    i_fld = strfind(bib, '= {'); n_fld = length(i_fld); i_sep = strfind(bib, ',');
    if n_fld > 1
      for j = 1:n_fld
        i_fld(j) = max(i_sep(i_sep < i_fld(j)));
      end
      for j = 1:n_fld-1
        bibi = bib(2+i_fld(j):1+i_fld(j+1)); bibi = strrep(bibi, '''', '''''');
        fprintf(fid, '''%s'' ... \n', bibi);
      end
      bibi = bib(2+i_fld(end):end-2); bibi = strrep(bibi, '''', '''''');
      fprintf(fid, '''%s''];\n', bibi);
    else
      bibi = bib(2+i_sep(1):end-2); bibi = strrep(bibi, '''', '''''');
      fprintf(fid, '''%s''];\n', bibi);
    end
    fprintf(fid, '%s\n', 'metaData.biblist.(bibkey) = [''''''@'', type, ''{'', bibkey, '', '', bib, ''}'''';''];');
    fprintf(fid, '%s\n', '%');
  end
end

fclose(fid);

end

function str = cell2str(cell)
% Malab has the build-in function cellstr, but this function delivers a cell-vector, not a string
  if isempty(cell)
    str = '{}'; return
  elseif ischar(cell)
    str = ['{''', cell, '''}']; return
  end
  n = length(cell);
  if n == 1
    str = ['{''', cell{1}, '''}']; return
  else
    str = '{';
    for i=1:n
      str = [str,'''',cell{i}, ''','];
    end
    str(end) = '}';
  end
end

function str = vec2str(vec)
n = length(vec); str = '[';
for i=1:n
  str = [str, num2str(vec(i)), ' '];
end
str(end) = ']';
end
