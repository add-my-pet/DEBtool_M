%% prt_tab
% writes table to temporary file tab.html, shows it in the bowser and deletes it

%%
function prt_tab(values, header)
% created 2021/05/11 by Bas Kooijman

%% Syntax
% <../prt_tab.m *prt_tab*> (values, header) 

%% Description
% writes table to temporary file tab.html, shows it in the bowser and deletes it

%
% Input:
%
% * varargin: cell arrays with strings and/or matrices with numbers
% * header: cell vector with strings for header; length should match number of columns, but might by empty
%
% Output:
%
% * no Malab output, tab.html is written, shown in browser and deleted

%% Remarks
% The input might be any sequence of cell arrays and matrices, but all must have the same number of rows.
% The header is not optional, but if empty, no header is printed.
  
   if ~exist('header','var')
     header = {};
   end

    n_rows = size(values{1},1);
    N = size(values,2); val = cell(n_rows,0);
    for j=1:N
      if iscell(values{j})
         val = [val,values{j}];
      else
         val = [val, arrayfun(@num2str, values{j}, 'UniformOutput', 0)];
      end
    end
    n_cols = size(val, 2);

    
    if ~isempty(header) && ~n_cols == length(header)
      fprintf('Warning from prt_tab: length of header does not match numer of collums\n');
      return
    end
        
    fileName = 'tab.html'; % char string with file name of output file
    oid = fopen(fileName, 'w+'); % open file for writing, delete existing content

    % file head
    fprintf(oid, '<!DOCTYPE html>\n');
    fprintf(oid, '<html>\n');
    fprintf(oid, '<head>\n');
    fprintf(oid, '  <title>%s</title>\n',  'Table');
    fprintf(oid, '  <style>\n');
    fprintf(oid, '    div.tab {\n');
    fprintf(oid, '      width: 50%%;\n');
    fprintf(oid, '      float: left;\n'); 
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
        fprintf(oid, '<td>%s</td> ', val{i,j});
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
    delete(fileName)
    

  end
