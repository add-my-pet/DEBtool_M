%% stripHTML
% Strip a character string from html links

%%
function str = stripHTML(str)
% created 2023/07/28 by  Bas Kooijman

%% Syntax
% <../stripHTML.m *stripHTML*>(str))

%% Description
% Strip a character string from html links
%
% Input:
%
% * string with html links
%
% Output
%
% * same string without html links
%
%% Remarks
% Applied in function web2local
%
%% Example
% stripHTML('bli <a href="address">bla</a> blo')

  for i=1:length(strfind(str, '<a href'))
    ind_0 = strfind(str, '<a href'); ind_0 = ind_0(1);
    ind_1 = ind_0 + 1 + strfind(str(ind_0:end), '">'); ind_1 = ind_1(1);
    ind_2 = ind_1 - 2 + strfind(str(ind_1:end), '</a>'); ind_2 = ind_2(1);
    str = [str(1:ind_0-1), str(ind_1:ind_2) str(5+ind_2:end)];
  end
end
  