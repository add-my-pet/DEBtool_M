%% web2local
% copy a directory on the web to local on the pc
%%
function web2local(varargin)
% created 2023/07/28 by  Bas Kooijman

%% Syntax
% <../web2local.m *web2local*>(varargin))

%% Description
% Copies a file or directory on the web to local. 
% A directory directory might contain files or directories, but these directories might not contain directories.
% The names of the local subdirectories are tha same as on the web
%
% Input:
%
% * dirLocal: optional character string with path to local file or directory (default web name)
% * dirWeb: character string with web address of file or directory

  if nargin > 1
    dirLocal = varargin{1};
    dirWeb = varargin{2};
    if strcmp(dirWeb(end),'/'); dirWeb(end) = []; end
  else
    dirWeb = varargin{1};
    if strcmp(dirWeb(end),'/'); dirWeb(end) = []; end
    dirLocal = strsplit(dirWeb,'/'); dirLocal = dirLocal{end};
  end

  nm_dirLocal = dirLocal; % copy name to survive upcomming deletion
  if ismac || isunix
    system(['wget -O ', dirLocal, ' ', dirWeb]);
  else
    system(['powershell wget -O ', dirLocal, ' ', dirWeb]);
  end

  dir = fileread(dirLocal);
  if ~contains(dir,'Parent Directory') 
    return % target is a file, not a directory
  end
  delete(dirLocal);
  mkdir(nm_dirLocal); WD = pwd; cd(nm_dirLocal); % goto local directory

  % remove table header
  ind = strfind(dir,'Parent'); ind_0 = ind + 4 + strfind(dir(ind:end),'</tr>'); dir(1:ind_0) = [];
  n = -1+length(strfind(dir,'<tr>')); % number of rows of table
  for i = 1:n % scan rows
    ind_0 = strfind(dir,'<tr>'); ind_1 = 5+strfind(dir,'</tr>'); % row i of table
    dir_i = dir(ind_0:ind_1); dir(1:ind_1) = [];
    ind_0 = 11 + strfind(dir_i, '"></td><td>'); 
    ind_1 = ind_0 -2 + strfind(dir_i(ind_0:end), '</td>'); ind_1 = ind_1(1);
    nm = stripHTML(dir_i(ind_0:ind_1));
    if contains(dir_i,'folder.gif') % table row refers to folder
      if ismac || isunix
        system(['wget -O dirSub_w2l ', dirWeb, '/', nm]);
      else
        system(['powershell wget -O dirSub_w2l ', dirWeb, '/', nm]);
      end
      dirSub = fileread('dirSub_w2l'); delete('dirSub_w2l');
      ind = strfind(dirSub,'Parent'); ind_0 = ind + 4 + strfind(dirSub(ind:end),'</tr>'); dirSub(1:ind_0) = [];
      nSub = -1+length(strfind(dirSub,'<tr>')); % number of rows of table
      mkdir(nm); cd(nm); % goto local sub directory
      for j = 1:nSub % scan rows of table of sub folder
        ind_0 = strfind(dirSub,'<tr>'); ind_1 = 5+strfind(dirSub,'</tr>'); % row j of table
        dirSub_j = dirSub(ind_0:ind_1); dirSub(1:ind_1) = [];
        ind_0 = 11 + strfind(dirSub_j, '"></td><td>'); 
        ind_1 = ind_0 -2 + strfind(dirSub_j(ind_0:end), '</td>'); ind_1 = ind_1(1);
        nmSub = stripHTML(dirSub_j(ind_0:ind_1));
        if ismac || isunix
          system(['wget -O ', nmSub, ' ', dirWeb, '/', nm, '/', nmSub]);
        else
          system(['powershell wget -O ', nmSub, ' ', dirWeb, '/', nm, '/', nmSub]);
        end
      end
      cd ../ % go parent directory
    else % table row does not refer to folder but to file
      if ismac || isunix
        system(['wget -O ', nm, ' ', dirWeb, '/', nm]);
      else
        system(['powershell wget -O ', nm, ' ', dirWeb, '/', nm]);
      end
    end
 end
  
 cd(WD)
end

