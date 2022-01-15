%% prt_elas
% writes table with first and second order elasticities to temporary file elas.html, shows it in the bowser and deletes it

%%
function prt_elas(del, save)
% created 2022/01/09 by Bas Kooijman

%% Syntax
% <../prt_elas.m *prt_elas*> (del, save) 

%% Description
% writes table with first and second order elasticities to temporary file my_pet_elas.html, shows it in the bowser and deletes it
% Deletion is suppressed if second input is true.
%
% Input:
%
% * del: optional scalar with pertubation factor (default 1e-6) 
% * save: optional boolean to save the html-file (default: false)
%
% Output:
%
% * no Malab output, elas.html is written, shown in browser and deleted, unless save is true

%% Remarks
% Assumes local existence of mydata_my_pet.m, predict_my_pet.m and results_my_pet.mat.
% Assumes that global lossfunction and pets exist.

%% Example of use
% Meant to be used as last line "prt_elas" in the run-file

  global pets lossfunction
  
  if ~exist('del','var') || isempty(del)
    del = 1e-6;
  end
  
  if ~exist('save','var')
    save = false;
  end
  
  
  n_pets = length(pets);
  for j = 1:n_pets
    my_pet = pets{j};
    [elas2, elas, nm, lf] = elas2_lossfun(my_pet, del);
  
    n = length(nm);
          
    fileName = [my_pet,'_elas.html']; % char string with file name of output file
    oid = fopen(fileName, 'w+'); % open file for writing, delete existing content

    fprintf(oid, '<!DOCTYPE html>\n');
    fprintf(oid, '<HTML>\n');
    fprintf(oid, '<HEAD>\n');
    fprintf(oid, '  <TITLE>%s</TITLE>\n',  fileName);
    fprintf(oid, '  <style>\n');
    fprintf(oid, '    div.elas {\n');
    fprintf(oid, '      width: 25%%;\n');
    fprintf(oid, '      float: left;\n'); 
    fprintf(oid, '    }\n\n');
    
    fprintf(oid, '    div.elas2 {\n');
    fprintf(oid, '      width: 75%%;\n');
    fprintf(oid, '      float: right;\n');
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    p.clear {\n');
    fprintf(oid, '      clear: both;\n');
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    .head {\n');
    fprintf(oid, '      background-color: #FFE7C6\n'); % pink header background
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    .diag {\n');
    fprintf(oid, '      background-color: #f9e79f\n'); % yellow diagonal background 
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    #elas {\n');
    fprintf(oid, '      border-style: solid hidden solid hidden;\n');   % border top & bottom only
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    #elas2 {\n');
    fprintf(oid, '      border-style: solid hidden solid hidden;\n');   % border top & bottom only
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    tr:nth-child(even){background-color: #f2f2f2}\n');% grey on even rows
    fprintf(oid, '  </style>\n');
    fprintf(oid, '</HEAD>\n\n');
    fprintf(oid, '<BODY>\n\n');

    fprintf(oid, '  <div class="elas">\n');
    fprintf(oid, '    <h1>%s</h1>\n', strrep(my_pet, '_', ' '));
    fprintf(oid, '  </div>\n\n');

    fprintf(oid, '  <div class="elas2">\n');
    fprintf(oid, '    <h3>lossfunction %s %3.4g; perturbation factor %3.4g</h3>\n', lossfunction, lf, del); 
    fprintf(oid, '  </div>\n\n');


    fprintf(oid, '  <p class="clear"></p>\n\n');

    fprintf(oid, '  <div class="elas">\n');
    % open elas table
    fprintf(oid, '  <h2>Elasticities</h2>\n');
    fprintf(oid, '  <TABLE id="elas">\n');
    fprintf(oid, '    <TR  class="head"><TH>par</TH> <TH>elasticity</TH></TR>\n');

    for i = 1:n
      fprintf(oid, '    <TR><TH class="head">%s</TH> <TD>%3.4g</TD></TR>\n',nm{i}, elas(i));
    end
    
    fprintf(oid, '  </TABLE>\n'); % close elas table
    fprintf(oid, '  </div>\n\n');

    fprintf(oid, '  <div class="elas2">\n');
    % open elas2 table
    fprintf(oid, '  <h2>Second order elasticities</h2>\n');
    fprintf(oid, '  <TABLE id="elas2">\n');
    fprintf(oid, '    <TR class="head"><TH>par</TH> ');
    for i=1:n
      fprintf(oid, '<TH>%s</TH> ', nm{i});
    end
    fprintf(oid, '</TR>\n');

    for i=1:n
      fprintf(oid, '    <TR><TH class="head">%s</TH> ', nm{i});
      for j=1:n
        if j == i
          fprintf(oid, '<TD class="diag">%3.4g</TD> ', elas2(i,j));
        else
          fprintf(oid, '<TD>%3.4g</TD> ', elas2(i,j));
        end
      end
      fprintf(oid, '</TR>\n');
    end
    
    fprintf(oid, '  </TABLE>\n'); % close elas2 table  
    fprintf(oid, '  </div>\n\n');

    fprintf(oid, '</BODY>\n');
    fprintf(oid, '</HTML>\n');

    fclose(oid);

    web(fileName,'-browser') % open html in systems browser
    pause(2)
    if ~save
      delete(fileName)
    end  
  end
end
