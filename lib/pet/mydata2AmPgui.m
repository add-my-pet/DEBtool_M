%% mydata2AmPgui
% converts structures data and metaData produced by mydata_my_pet to those produced by AmPgui

%%
function [data, metaData] = mydata2AmPgui(data, metaData)
% created 2020/06/15 by  Bas Kooijman

%% Syntax
% [data, metaData] = <../mydata2AmPgui.m *mydata2AmPgui*> (data, metaData)

%% Description
% converts structures data and metaData produced by mydata_my_pet, to those produced by AmPgui
%
% Input: 
%
% * data: structure with data
% * metaData: structure with metaData 

% Output: 
%
% * data: structure with data
% * metaData: structure with metaData 

%% Remark
% <../AmPgui2mydata.html *AmPgui2mydata*> is inverse to mydata2AmPgui

fld = fieldnames(data); n_fld = length(fld); data_0 = []; data_1 = [];
for i = 1:n_fld
   if size(data.(fld{i}), 2) > 1
     data_1.(fld{i}) = data.(fld{i});
   else
     data_0.(fld{i}) = data.(fld{i});
   end
end
data_0 = rmfield(data_0, 'psd');
data = []; data.data_0 = data_0; data.data_1 = data_1;
    
bibkey = fieldnames(metaData.biblist); bibkey = bibkey(~ismember(bibkey, 'Kooy2010')); n_bibkey = length(bibkey); biblist = [];
for i = 1:n_bibkey
  bib = metaData.biblist.(bibkey{i}); biblist.(bibkey{i}) = [];
  bib(end) = []; i_head = strfind(bib, ','); head = bib(1:i_head(1)); 
  i_type = strfind(head, '{'); type = head(3:i_type-1); biblist.(bibkey{i}).type = lower(type);
  i_fld = strfind(bib, '= {'); n_fld = length(i_fld); i_sep = strfind(bib, ',');
  if n_fld > 1
    for j = 1:n_fld
      i_fld(j) = max(i_sep(i_sep < i_fld(j)));
    end
    for j = 1:n_fld-1
      bibi = bib(2+i_fld(j):1+i_fld(j+1)); 
      bibi = strsplit(bibi, ' = '); fldi = lower(strtrim(bibi{1})); str = strtrim(bibi{2}); str([1, end, end-1]) = [];
      biblist.(bibkey{i}).(fldi) = str;
    end
    bibi = bib(2+i_fld(end):end-2); 
    bibi = strsplit(bibi, ' = '); fldi = lower(strtrim(bibi{1})); str = strtrim(bibi{2}); str([1, end, end-1]) = [];
    biblist.(bibkey{i}).(fldi) = str;
  else
    bibi = bib(2+i_sep(1):end-2); 
    bibi = strsplit(bibi, ' = '); fldi = lower(strtrim(bibi{1})); str = strtrim(bibi{2}); str([1, end, end-1]) = [];
    biblist.(bibkey{i}).(fldi) = str;
  end
  fld = fieldnames(biblist.(bibkey{i}));
  if ismember('howpublished', fld) & strfind(biblist.(bibkey{i}).howpublished, '\url')
    str = biblist.(bibkey{i}).howpublished; str(1:5) = [];
    biblist.(bibkey{i}) = rmfield(biblist.(bibkey{i}), 'howpublished');
    biblist.(bibkey{i}).url = str;
  end
end
metaData.biblist = biblist;
    

