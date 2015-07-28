%% get_doi
% extracts doi from mydata

%%
function doi = get_doi(my_pet, bibkey)
  % created by Bas Kooijman at 2015/07/23
  
  %% Syntax
  % doi = <../get_doi.m *get_doi*>(my_pet, bibkey)

  %% Description
  % Extracts doi from a bibkey in metadata.biblist in a mydata-file
  %
  % Input
  %
  % * character string with name of my pet
  % * optional character string with bibkey
  %  
  % Output
  %
  % * character string with doi

  %% Remarks
  % bibkey should be a field of metadata.biblist and contain bib-entry doi, else the result is empty.
  % Sometimes doi is given in bib-entry url or URL. Extract that url with <get_url.m *get_url*>.
  
  %% Example of use
  % get_doi('Aparaima_gigas') 
  
  file_name = ['mydata_', my_pet, '.m']; % name of mydata-file that serves as input
  

  %% check that mydata actually exists
  if exist(file_name, 'file') == 0
    fprintf([file_name, ' not found\n']);
    return
  end

  % run mydata_my_pet and fill metadata
  eval(['[data, txt_data, metadata] = mydata_', my_pet, ';']);

  doi = {};
  
  if isfield(metadata.biblist, bibkey)
    bib = eval(['metadata.biblist.', bibkey]);
  else
    return
  end
  
  n = strfind(bib, 'doi');
  if isempty(n);
    n = strfind(bib, 'DOI');
    if isempty(n)
      return;
    end
  end
  doi = bib;
  doi(1:n) = []; % remove all before doi or DOI

  % remove all before first '{' and after first '}'
  doi(1: strfind(doi, '{')) = [];
  doi = doi(1: strfind(doi, '}') - 1);
end
  
