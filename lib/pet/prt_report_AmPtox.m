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

  list = cellstr(ls); title = list(contains(list,'.mat')); title = title{1}; load(title) % load the results_*.mat file
  title(1:8) = []; title(end-4:end) = []; % select identifying part of the name 
  
  prt_my_pet_bib(title, metaData.biblist);                % my_pet_bib.bib 
  bib2html([title, '_bib']);                              % my_pet_bib.html 

    fileName = [title, '_report.html']; % char string with file name of output file
    oid = fopen(fileName, 'w+'); % open file for writing, delete existing content

    fprintf(oid, '<!DOCTYPE html>\n');
    fprintf(oid, '<HTML>\n');
    fprintf(oid, '<HEAD>\n');
    fprintf(oid, '  <TITLE>%s</TITLE>\n',  title);
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
    fprintf(oid,['  <h1>', title, '</h1>\n']);
    fprintf(oid, '  </div>\n\n');

    
    fprintf(oid, '  <p class="clear"></p>\n\n');
    
    % Facts:
    if isfield(metaData, 'facts') 
      fprintf(oid, '      <H3 style="clear:both" class="pet">Facts</H3>\n');
      fprintf(oid, '      <ul> \n');     % open the unordered list
      [nm, nst] = fieldnmnst_st(metaData.facts);
      for i = 1:nst
        fprintf(oid, '        <li>\n'); % open bullet point
        str1 = metaData.facts.(nm{i});
        if isfield(metaData.bibkey,(nm{i}))
          bib = metaData.bibkey.(nm{i}); 
          if ~iscell(bib)
            str2 = bib;
          else
            n_bib = length(bib);
            str2 = bib{1};
            for j = 2:n_bib
              str2 = [str2, ', ', bib{j}];
            end            
          end
          fprintf(oid, ['          ', str1,' (ref: ',str2, ')\n']);
        else
          fprintf(oid, ['          ', str1, '\n']);  
        end
        fprintf(oid, '        </li>\n' ); % close bullet point
      end
      fprintf(oid,'      </ul>\n');       % close the unordered list    
    end

    % Discussion
    if isfield(metaData, 'discussion') == 1
      fprintf(oid, '      <H3 style="clear:both" class="pet">Discussion</H3>\n');
      fprintf(oid, '      <ul> \n');     % open the unordered list
      [nm, nst] = fieldnmnst_st(metaData.discussion);
      for i = 1:nst
        fprintf(oid, '        <li>\n'); % open bullet point
        str = metaData.discussion.(nm{i});
        if isfield(txtData.bibkey,nm{i})
          str2 = metaData.bibkey.(nm{i});
          fprintf(oid, ['          ', str,' (',str2,') \n']);
        else
          fprintf(oid, ['          ', str, '\n']);
        end
        fprintf(oid, '        </li>\n' ); % close bullet point
      end
     fprintf(oid,'      </ul>\n\n');      % open the unordered list      
    end

    % Acknowledgment:
    if isfield(metaData, 'acknowledgment') == 1
      fprintf(oid, '      <H3 style="clear:both" class="pet">Acknowledgment</H3>\n');
      fprintf(oid, '        <ul> \n');     % open the unordered list
    
      fprintf(oid, '          <li>\n');    % open bullet point
      str = metaData.acknowledgment;
      fprintf(oid, ['          ', str, '\n']);
      fprintf(oid, '          </li>\n' );  % close bullet point
   
      fprintf(oid,'         </ul>\n\n\n'); % close the unordered list      
    end

    % Bibliography:
    fprintf(oid,['      <H3 style="clear:both" class="pet"><a class="link" href = "',metaData.species,'_bib.bib" target = "_blank">Bibliography</a></H3>\n']);
    fprintf(oid,['      <div w3-include-html="', metaData.species, '_bib.html"></div>\n']);
    fprintf(oid, '      <script>w3IncludeHTML();</script>\n\n');
  

    % ----------------------------------------------------------

    fprintf(oid, '    </div> <!-- end of content -->\n\n');

    fprintf(oid, '    <div w3-include-html="../../sys/footer_amp.html"></div>\n');
    fprintf(oid, '    <script>w3IncludeHTML();</script>\n\n');

    fprintf(oid, '  </div> <!-- main wrapper -->\n');
    fprintf(oid, '</div> <!-- main -->\n');
    fprintf(oid, '</BODY>\n');
    fprintf(oid, '</HTML>\n');

    fclose(oid);

    web(fileName,'-browser') % open html in systems browser
