%% prt_tab
% writes table to temporary file tab.html, shows it in the bowser and optionally deletes it

%%
function prt_tab(values, header, fileName, save)
% created 2021/05/11 by Bas Kooijman, modified 2024/09/11

%% Syntax
% <../prt_tab.m *prt_tab*> (values, header, fileName, save) 

%% Description
% writes table to temporary file title.html (= 3rd input) and shows it in the bowser
%
% Input:
%
% * values: cell array with strings and/or matrices with numbers
% * header: cell vector with strings for header; length should match number of columns, but might be empty
% * fileName: optional string with title of browser tab and file-name (default "table")
% * save: optional boolean to save the html-file (default: false)
%
% Output:
%
% * text-file with the name title.html is written and shown in browser, where title is 3rd input

%% Remarks
%
% * The input might be any sequence of cell arrays and matrices, but all must have the same number of rows.
% * If the first element of values is a character string, it is assumed to be a taxon and replaced by its members.
% * If the fileName has no extension, .html is assumed. 
% * Otherwise the exensions of Matlab function writecell are recognized, while input save is ignored:
%    .txt, .text, .dat, .csv, .log, .dlm, .xls, .xlsx, .xlsb, .xlsm, .xltx, .xltm.
%   Extension .tex is also recognized; the resulting Latex text is meant to be copy/pasted into a .tex document

%% Example of use
% prt_tab({{'aa';'b';'cc'}, [1.1 2 3; 4 5 6; 7 8 9.3]},{'nm','v1','v2','v3'});
  
  if ~exist('header','var')
    header = {};
  end
  if ~exist('fileName','var')
    title = 'table'; ext = 'html'; fileName = 'table.html';
  elseif ~ismember('.',fileName)
    title = fileName; ext = 'html'; fileName = [fileName,'.html'];
  else
    str = strsplit(fileName,'.'); title = str(1); ext = str{end};
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
  
  switch ext
    case 'html'
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
  
    case 'tex'
      oid = fopen(fileName, 'w+'); % open file for writing, delete existing content
      l = 'l'; l = ['{', l(ones(1,n_cols)), '}']; % l can be replace by 'c' or 'r' for alignment
      fprintf(oid, '    \\begin{tabular}%s\n      \\hline\n', l);

      % header
      if ~isempty(header)
        fprintf(oid, '      ');
        for j = 1:n_cols-1
          fprintf(oid, '%s & ', header{j});
        end
        fprintf(oid, ' %s \\\\\n', header{end});
        fprintf(oid, '      \\hline\\\\\n');
      end

      % body
      for i = 1:n_rows
        fprintf(oid, '      ');
        for j = 1:n_cols-1
          val_ij = val{i,j};
          if iscell(val_ij)
            fprintf(oid, '%s & ', val_ij{:});
          else
            fprintf(oid, '%s & ', val_ij);
          end
        end
        val_ij = val{i,end};
        if iscell(val_ij)
          fprintf(oid, '%s \\\\\n', val_ij{:});
        else
          fprintf(oid, '%s \\\\\n', val_ij);
        end
      end

      % file tail
      fprintf(oid, '      \\hline\n');
      fprintf(oid, '    \\end{tabular}\n'); % close table
      fclose(oid);

    otherwise % write csv or xls-file to local directory
      writecell([header; val],fileName)
  end
end
