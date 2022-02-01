%% prt_report_AmPtox
% writes report of local results file

%%
function prt_report_AmPtox(varargin)
% created 2022/02/01 by Bas Kooijman

%% Syntax
% <../prt_report_AmPtox.m *prt_report_AmPtox*> (varargin) 

%% Description
% Writes report in html from the local results file
%
% Input:
%
% * varargin: optional name of the results_*.mat file
%
% Output:
%
% * no Malab output, text is written to html

%% Remarks
% If no input is specified, a single .mat file with results is assumed to be locally present

  list = cellstr(ls); nm = list(contains(list,'.mat')); nm = nm{1}; load(nm) % load the results_*.mat file
  nm(1:8) = []; nm(end-4:end) = []; % select identifying part of the name 
  
  prt_my_pet_bib(nm, metaData.biblist);                % my_pet_bib.bib 
  bib2html([nm, '_bib']);                              % my_pet_bib.html 

    fileName = [nm, '_report.html']; % char string with file name of output file
    oid = fopen(fileName, 'w+'); % open file for writing, delete existing content

    fprintf(oid, '<!DOCTYPE html>\n');
    fprintf(oid, '<HTML>\n');
    fprintf(oid, '<HEAD>\n');
    fprintf(oid, '  <TITLE>%s</TITLE>\n',  nm);
    fprintf(oid, '  <style>\n');
    fprintf(oid, '    div.prd {\n');
    fprintf(oid, '      width: 50%%;\n');
    fprintf(oid, '      float: left;\n'); 
    fprintf(oid, '    }\n\n');
    
    fprintf(oid, '    div.par {\n');
    fprintf(oid, '      width: 50%%;\n');
    fprintf(oid, '      float: right;\n');
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    p.clear {\n');
    fprintf(oid, '      clear: both;\n');
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    .head {\n');
    fprintf(oid, '      background-color: #FFE7C6\n');                  % pink header background
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    .psd {\n');
    fprintf(oid, '      color: blue\n');                                % blue
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    #prd {\n');
    fprintf(oid, '      border-style: solid hidden solid hidden;\n');   % border top & bottom only
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    #par {\n');
    fprintf(oid, '      border-style: solid hidden solid hidden;\n');   % border top & bottom only
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    tr:nth-child(even){background-color: #f2f2f2}\n');% grey on even rows
    fprintf(oid, '  </style>\n');
    fprintf(oid, '</HEAD>\n\n');
    fprintf(oid, '<BODY>\n\n');

    fprintf(oid, '  <div class="prd">\n');
    fprintf(oid,['  <h1>', nm, '</h1>\n']);
    fprintf(oid, '  </div>\n\n');

    
    fprintf(oid, '  <div class="par">\n');
    fprintf(oid, '  <h4>COMPLETE = %3.1f; MRE = %8.3f; SMAE = %8.3f; SMSE = %8.3f </h4>\n', metaData.(pets{i}).COMPLETE, metaPar.(pets{i}).MRE, metaPar.(pets{i}).SMAE, metaPar.(pets{i}).SMSE);
    fprintf(oid, '  </div>\n\n');

    fprintf(oid, '  <p class="clear"></p>\n\n');
   

    fprintf(oid, '</BODY>\n');
    fprintf(oid, '</HTML>\n');

    fclose(oid);

    web(fileName,'-browser') % open html in systems browser

  
