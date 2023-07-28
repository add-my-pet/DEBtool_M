%% web2local
% copy a directory on the web to local on the pc
%%
function list = web2local(dirLocal,dirWeb)
% created 2023/07/28 by  Bas Kooijman

%% Syntax
% <../web2local.m *web2local*>(dirLocal,dirWeb))

%% Description
% Copies a directory on the web to local
%
% Input:
%
% * dirLocal: charcter string with path to local directory
% * dirWeb: charcter string with web adress of directory

  nm_dirLocal = dirLocal; 
  if strcmp(dirWeb(end),'/'); dirWeb(end) = []; end
  if ismac || isunix
    system(['wget -O ', dirLocal, ' ', dirWeb]);
  else
    system(['powershell wget -O ', dirLocal, ' ', dirWeb]);
  end

  dir = fileread(dirLocal); delete(dirLocal);
  ind_0 = 11 + strfind(dir, '"></td><td>'); n = length(ind_0); ind_1 = zeros(n,1);
  for i=1:n; ind = ind_0(i) -2 + strfind(dir(ind_0(i):end), '</td>'); ind_1(i) = ind(1); end
  list = cell(n,1); for i=1:n; list{i} = dir(ind_0(i):ind_1(i)); end
  list(1) = [];
  mkdir(nm_dirLocal); WD = pwd; cd(nm_dirLocal)
  for i=1:n-1 
    if ismac || isunix
      txt =['wget -O ', list{i}, ' ', dirWeb, '/', list{i}];
      system(stripHTML(txt));
    else
      txt = ['powershell wget -O ', list{i}, ' ', dirWeb, '/', list{i}];
      system(stripHTML(txt));
    end
  end
  cd(WD)
end

