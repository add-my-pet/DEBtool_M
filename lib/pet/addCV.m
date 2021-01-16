%% addCV
% appends parameter weights and cv's to addCV.html

%%
function addCV
% created 2021/01/14 by  Bas Kooijman

%% Syntax
% addCV

%% Description
% Multi-species parameter estimation, using pars_init_group and run_group makes use of augmented loss functions that also minimize variation coefficients of specied parmeters.
% This function adds a row to a report-table (or initiates such a table, with mean MRE, SMSE and weights and cv for the various parameters.
% The system-browser is automatically opened if the table is initiated.
% First apply run_group to convergence, and give command addCV to append a new report-row and hit refresh in the browser.
% The information is taken from metaPar in results_group.mat.

%% Remark
% The value of the loss function does not include contributions from the augmented term or pseudo-data

load results_group.mat
MRE = metaPar.MRE; SMSE = metaPar.SMSE; lossf = metaPar.lossf;
nms = fieldnames(metaPar.weights); n = length(nms); weights = zeros(n,1); cv = weights;
for i = 1:n
  weights(i) = metaPar.weights.(nms{i}); cv(i) = metaPar.cv.(nms{i}); 
end

init = ~ismember('addCV.html', cellstr(ls('.'))); % true if no addCV.html file exists in local directory
if init
  oid = fopen('addCV.html', 'w+'); % open file for writing, delete existing content
   
  fprintf(oid, '<!DOCTYPE html>\n');
  fprintf(oid, '<HTML>\n');
  fprintf(oid, '<HEAD>\n');
  fprintf(oid, '  <TITLE>addCV</TITLE>\n');
  fprintf(oid, '  <style>\n');
  fprintf(oid, '    #head {\n');
  fprintf(oid, '      background-color: #FFE7C6;\n');                          % pink header background
  fprintf(oid, '    }\n\n');
  fprintf(oid, '    #Table {\n');
  fprintf(oid, '      border-style: solid none solid none;\n');                          % pink header background
  fprintf(oid, '    }\n\n');

  fprintf(oid, '    TR:nth-child(even){background-color: #f2f2f2};\n');      % grey on even rows
  fprintf(oid, '    TD:nth-child(odd){border-left: solid 1px black};\n\n');  % lines between species
  fprintf(oid, '  </style>\n\n');
  fprintf(oid, '</HEAD>\n\n');
  fprintf(oid, '<BODY>\n\n'); % open table
  fprintf(oid, '   <TABLE id="Table">\n');

  % table head:
  fprintf(oid, '     <TR id=head> <TH></TH> <TH></TH> <TH></TH> ');
  for i = 1:n
    fprintf(oid, '<TH colspan="2">%s</TH> ', nms{i});  
  end
  fprintf(oid, '</TR>\n');
  fprintf(oid, '     <TR id=head> <TH>MRE</TH> <TH>SMSE</TH> <TH>lossf</TH>');
  for i = 1:n
    fprintf(oid, '<TH>wght</TH> <TH>cv</TH> ');  
  end
  fprintf(oid, '</TR>\n');
else
  fopen('addCV.html'); addCV = fileread('addCV.html'); fclose all;
  add = strfind(addCV, '   </TABLE>'); addCV = addCV(1:add-1);
  oid = fopen('addCV.html', 'w+'); % open file for writing, delete existing content
  fprintf(oid, addCV);  
end
fprintf(oid, '     <TR> <TD>%9.4g</TD> <TD>%9.4g</TD>  <TD>%9.4g</TD> ', MRE, SMSE, lossf);
for i = 1:n
  fprintf(oid, '<TH>%9.4g</TH> <TH>%9.4g</TH> ', weights(i), cv(i));  
end
fprintf(oid, '</TR>\n');
fprintf(oid, '   </TABLE>\n\n');

fprintf(oid, '   <p> Pets:\n');
fprintf(oid, '   <ol>\n');
nms = fields(metaData); n_pets = length(nms);
for i = 1 : n_pets
   fprintf(oid, '     <li>%s</li>\n', nms{i});
end
fprintf(oid, '   </ol>\n');
fprintf(oid, '</BODY>\n\n'); 

fprintf(oid, '</HTML>\n');
fclose(oid);

if init
  web('addCV.html','-browser') % open addCV.html in systems browser
end
