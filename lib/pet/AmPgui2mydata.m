%% AmPgui2mydata
% converts structures data and metaData produced by AmPgui, to those produced by mydata_my_pet

%%
function [Data, metaData] = AmPgui2mydata(data, metaData)
% created 2020/06/15 by  Bas Kooijman, modified 2020/09/12

%% Syntax
% [data, metaData] = <../AmPgui2mydata.m *AmPpostEdit*> (data, metaData)

%% Description
% converts structures data and metaData produced by AmPgui, to those produced by mydata_my_pet
%
% Input: 
%
% * data: structure with data
% * metaData: structure with metaData 

% Output: 
%
% * Data: structure with data
% * metaData: structure with metaData 

%% Remark
% <../mydata2AmPgui.html *mydata2AmPgui*> is inverse to AmPgui2mydata

Data = []; 
if isfield(data, 'data_0') && ~isempty(data.data_0)
  fld = fields(data.data_0); n_fld = length(fld);
  for i = 1:n_fld
    Data.(fld{i}) = data.data_0.(fld{i});
  end
end
if isfield(data, 'data_1') && ~isempty(data.data_1)
  fld = fieldnames(data.data_1); n_fld = length(fld);
  for i = 1:n_fld
    Data.(fld{i}) = data.data_1.(fld{i});
  end
end

if isfield(metaData, 'acknowledgment') && isempty(metaData.acknowledgment)
  metaData = rmfield(metaData, 'acknowledgment');
end
%
if isfield(metaData, 'facts') && isempty(metaData.facts)
  metaData = rmfield(metaData, 'facts');
end 
%
if isfield(metaData, 'discussion') && isempty(metaData.discussion)
  metaData = rmfield(metaData, 'discussion');
end 
%
if isempty(metaData.biblist)
  fprintf('Warning from AmP2mydata: empty biblist, no bibtimes specified\n');
else
  fld = fields(metaData.biblist); n_fld = length(fld);
  for i = 1:n_fld
     bibStruc = metaData.biblist.(fld{i}); 
     % remove empty fields of bibStruc
     bibfld = fields(bibStruc); n_bibfld = length(bibfld);
     for j = 1:n_bibfld
       if isempty(bibStruc.(bibfld{j})); bibStruc = rmfield(bibStruc, bibfld{j}); end;
     end
     % flatten structure bibStruc to string bib
     bibfld = fields(bibStruc); n_bibfld = length(bibfld);
     bib = ['@', bibStruc.type, '{', fld{i}, ', '];
     for j = 2:n_bibfld
       if strcmp(bibfld{j},'url')
         bib = [bib, 'howpublished = {\url{', bibStruc.(bibfld{j}), '}}, '];
       else
         bib = [bib, bibfld{j}, ' = {', bibStruc.(bibfld{j}), '}, '];
       end
     end
     %bib([end,end-1]) = []; 
     bib = [bib, '}'];
  metaData.biblist.(fld{i}) = bib;
  end
end