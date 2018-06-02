%% get_url
% extracts url from mydata

%%
function url = get_url(my_pet, bibkey)
  % created by Bas Kooijman at 2015/07/23, modified 2017/04/01
  
  %% Syntax
  % url = <../get_url.m *get_url*>(my_pet, bibkey)

  %% Description
  % Extracts url from a bibkey in metaData.biblist in a mydata-file
  %
  % Input
  %
  % * character string with name of my pet
  % * optional character string with bibkey (default 'Wiki' or 'wiki')
  %  
  % Output
  %
  % * character string with url 

  %% Remarks
  % bibkey should be a field of metaData.biblist and contain http, else the result is empty.
  % If several http's exist in a bib-entry, only the first one is extracted
  
  
  %% Example of use
  % get_url('Ciona_intestinalis') or
  % get_url('Salvelinus_alpinus', 'fishbase') or 
  % get_url('Raja_clavata', 'Kooy2010')
  
  file_name = ['mydata_', my_pet, '.m']; % name of mydata-file that serves as input
  

  % check that mydata actually exists
  if exist(file_name, 'file') == 0
    fprintf([file_name, ' not found\n']);
    return
  end

  % run mydata_my_pet and fill metadata
  eval(['[data, txt_data, metaData] = mydata_', my_pet, ';']);

  if ~exist('bibkey', 'var')
    if isfield(metaData.biblist, 'Wiki') 
      url = metaData.biblist.Wiki;
    elseif isfield(metaData.biblist, 'wiki') 
      url = metaData.biblist.wiki;
    else
      url = {};
      return
    end
  else
    if isfield(metaData.biblist, bibkey)
      url = eval(['metaData.biblist.', bibkey]);
    else
      url = {};
      return
    end
  end
  
  % remove all before 'http' and after first '}'
  url(1: strfind(url, 'http') - 1) = [];
  url = url(1: strfind(url, '}') - 1);
end
  
