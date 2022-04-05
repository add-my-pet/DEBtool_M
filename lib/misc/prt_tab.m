%% prt_tab
% writes table to temporary file tab.html, shows it in the bowser and deletes it

%%
function prt_tab(values, header, title, save)
% created 2021/05/11 by Bas Kooijman

%% Syntax
% <../prt_tab.m *prt_tab*> (values, header, title, save) 

%% Description
% writes table to temporary file tab.html, shows it in the bowser and deletes it

%
% Input:
%
% * varargin: cell arrays with strings and/or matrices with numbers
% * header: cell vector with strings for header; length should match number of columns, but might by empty
% * title: optional string with title of browser tab
% * save: optional boolean to save the html-file (default: false)
%
% Output:
%
% * no Malab output, tab.html is written, shown in browser and deleted

%% Remarks
% The input might be any sequence of cell arrays and matrices, but all must have the same number of rows.
% The header is not optional, but if empty, no header is printed.

%% Example of use
% prt_tab({{'aa';'bb';'cc'}, [1.1 2 3; 4 5 6; 7 8 9.3]},{'nm','v1','v2','v3'})
  
  if ~exist('header','var')
    header = {};
  end
  if ~exist('title','var')
    title = 'table';
  end
  if ~exist('save','var')
    save = false;
  end

  if size(values,2)>1 && ischar(values{1}) && iscell(values(2))
    values{1} = select(values{1}); % the assumption is that values{1} is the name of a taxon, which is replaced by names of entries
  end
  
  n_rows = size(values{1},1);
  N = size(values,2); val = cell(n_rows,0);
  try
    for j=1:N
      if iscell(values{j})
        val = [val,values{j}];
      else
        val = [val, arrayfun(@num2str, values{j}, 'UniformOutput', 0)];
      end
    end
    n_cols = size(val, 2);
  catch
    fprintf('Warning from prt_tab: table components do not all have the same number of rows\n');
    return
  end
 
  if ~isempty(header) && ~n_cols == length(header)
    fprintf('Warning from prt_tab: length of header does not match number of collums\n');
    return
  end
        
  fileName = [title, '.html']; % char string with file name of output file
  oid = fopen(fileName, 'w+'); % open file for writing, delete existing content

  % file head
  fprintf(oid, '<!DOCTYPE html>\n');
  fprintf(oid, '<html>\n');
  fprintf(oid, '<head>\n');
  fprintf(oid, '  <title>%s</title>\n',  title);
  fprintf(oid, '  <style>\n');
  fprintf(oid, '    div.tab {\n');
  fprintf(oid, '      width: 90%%;\n');
  fprintf(oid, '      margin: auto;\n'); 
  fprintf(oid, '      padding-top: 30px;\n'); 
  fprintf(oid, '    }\n\n');
    
  fprintf(oid, '    .head {\n');
  fprintf(oid, '      background-color: #FFE7C6\n');                  % pink header background
  fprintf(oid, '    }\n\n');

  fprintf(oid, '    #tab {\n');
  fprintf(oid, '      border-style: solid hidden solid hidden;\n');   % border top & bottom only
  fprintf(oid, '    }\n\n');

  fprintf(oid, '    tr:nth-child(even){background-color: #f2f2f2}\n');% grey on even rows
  fprintf(oid, '  </style>\n');
  fprintf(oid, '</head>\n\n');
  fprintf(oid, '<body>\n\n');
  
  fprintf(oid, '  <div class="tab">\n');
  fprintf(oid, '  <table id="tab">\n');

  % header
  if ~isempty(header)
    fprintf(oid, '    <tr class="head">');
    for j = 1:n_cols
      fprintf(oid, ' <th>%s</th>', header{j});
    end
    fprintf(oid, ' </tr>\n\n');
  end

  % body
  for i = 1:n_rows
    fprintf(oid, '    <tr>\n      ');
    for j = 1:n_cols
      val_ij = val{i,j};
      if iscell(val_ij)
        fprintf(oid, '<td>%s</td> ', val_ij{:});
      else
        fprintf(oid, '<td>%s</td> ', val_ij);
      end
    end
    fprintf(oid, '  \n    </tr>\n\n');
  end
 
  % file tail
  fprintf(oid, '  </table>\n'); % close table
  fprintf(oid, '  </div>\n\n');

  fprintf(oid, '</body>\n');
  fprintf(oid, '</html>\n');

  fclose(oid);

  web(fileName,'-browser') % open html in systems browser
  pause(2)
  if ~save
    delete(fileName)
  end  
end
