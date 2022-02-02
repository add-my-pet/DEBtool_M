%% prt_report_AmPtox
% writes report of local results file

%%
function prt_report_AmPtox(fileNm)
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
% * no Matlab output, text is written to html

%% Remarks
% If no input is specified, a single .mat file with results is assumed to be locally present

  path2sys = [set_path2server, 'add_my_pet/sys/'];
  if ~exist('fileNm', 'var')
    list = cellstr(ls); title = list(contains(list,'.mat')); title = title{1}; load(title) % load the results_*.mat file
  else
    title = fileNm; load(fileNm);
  end
  title(1:8) = []; title(end-3:end) = []; % select identifying part of the name 
  [data, auxData, metaData, txtData, weights] = feval(['mydata_', title]);
  
  prt_my_pet_bib(title, metaData.biblist);                % my_pet_bib.bib 
  try
    bib2html([title, '_bib']);                              % my_pet_bib.html 
  catch
  end

    fileName = [title, '_report.html']; % char string with file name of output file
    oid = fopen(fileName, 'w+'); % open file for writing, delete existing content

    fprintf(oid, '<!DOCTYPE html>\n');
    fprintf(oid, '<HTML>\n');
    fprintf(oid, '<HEAD>\n');
    fprintf(oid, '  <TITLE>%s</TITLE>\n',  title);
    fprintf(oid, '  <script src="w3data.js"></script>\n');

%     fprintf(oid, '  <script>\n');
%     fprintf(oid, '    function w3IncludeHTML() {\n');
%     fprintf(oid, '      var z, i, a, file, xhttp;\n');
%     fprintf(oid, '      z = document.getElementsByTagName("*");\n');
%     fprintf(oid, '      for (i = 0; i < z.length; i++) {\n');
%     fprintf(oid, '        if (z[i].getAttribute("w3-include-html")) {\n');
%     fprintf(oid, '          a = z[i].cloneNode(false);\n');
%     fprintf(oid, '          file = z[i].getAttribute("w3-include-html");\n');
%     fprintf(oid, '          var xhttp = new XMLHttpRequest();\n');
%     fprintf(oid, '          xhttp.onreadystatechange = function() {\n');
%     fprintf(oid, '            if (xhttp.readyState == 4 && xhttp.status == 200) {\n');
%     fprintf(oid, '              a.removeAttribute("w3-include-html");\n');
%     fprintf(oid, '              a.innerHTML = xhttp.responseText;\n');
%     fprintf(oid, '              z[i].parentNode.replaceChild(a, z[i]);\n');
%     fprintf(oid, '              w3IncludeHTML();\n');
%     fprintf(oid, '            }\n');
%     fprintf(oid, '          }\n');      
%     fprintf(oid, '          xhttp.open("GET", file, true);\n');
%     fprintf(oid, '          xhttp.send();\n');
%     fprintf(oid, '          return;\n');
%     fprintf(oid, '        }\n');
%     fprintf(oid, '      }\n');
%     fprintf(oid, '    }\n');
%     fprintf(oid, '  </script>\n\n');
   
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

    fprintf(oid, '  </style>\n');
    fprintf(oid, '</HEAD>\n\n');
    fprintf(oid, '<BODY>\n\n');

    fprintf(oid, '  <div class="prd">\n');
    fprintf(oid, '  <h1>%s</h1>\n', title);
    flds = fields(metaData); 
    flds = flds(~ismember(flds,{'biblist','discussion','facts','acknowledgment','data_0','data_1','data_2','bibkey'}));
    n_flds = length(flds);
    for i=1:n_flds
       txt = metaData.(flds{i}); if isnumeric(txt); txt = num2str(txt); end
       if iscell(txt)
          fprintf(oid, '    <b>%s: </b>%s<br>\n', flds{i}, txt{1});
       else
          fprintf(oid, '    <b>%s: </b>%s<br>\n', flds{i}, txt);
       end           
    end
    fprintf(oid, '  </div>\n\n');
    fprintf(oid, '  <div class="par">\n');
    fprintf(oid, '    <h3>\n');
    fprintf(oid, '      <a href="%s_res.html">go to results</a>\n', title);
    if ismember([title,'_elas.html'], list)
      fprintf(oid, '      <a href="%s_elas.html">, elasticities</a>\n', title); 
    end
    fprintf(oid, '    </h3>\n');
    png = list(contains(list,'.png')); n_png = length(png);
    for i = 1:n_png
      fprintf(oid, '    <img src=%s width="500px">\n',png{i});
    end
    fprintf(oid, '  </div>\n\n');
    
    fprintf(oid, '  <p class="clear"></p>\n\n');

    fprintf(oid, '  <div w3-include-html="%s_res.html"></div>\n', title);
    fprintf(oid, '  <script>w3IncludeHTML();</script>\n\n');

    fprintf(oid, '  <p class="clear"></p>\n\n');
    
    fprintf(oid, '  <div w3-include-html="%s_elas.html"></div>\n', title);
    fprintf(oid, '  <script>w3IncludeHTML();</script>\n\n');

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
          fprintf(oid, '          %s (ref: %s)\n', str1, str2);
        else
          fprintf(oid, '          %s\n', str1);  
        end
        fprintf(oid, '        </li>\n' ); % close bullet point
      end
      fprintf(oid,'      </ul>\n');       % close the unordered list    
    end

    % Discussion
    if isfield(metaData, 'discussion') == 1
      fprintf(oid, '  <H3 style="clear:both" class="pet">Discussion</H3>\n');
      fprintf(oid, '  <ul> \n');     % open the unordered list
      [nm, nst] = fieldnmnst_st(metaData.discussion);
      for i = 1:nst
        fprintf(oid, '    <li>\n'); % open bullet point
        str = metaData.discussion.(nm{i});
        if isfield(txtData.bibkey,nm{i})
          str2 = metaData.bibkey.(nm{i});
          fprintf(oid, '      %s(ref: %s) \n', str, str2);
        else
          fprintf(oid, '      %s\n', str);
        end
        fprintf(oid, '    </li>\n' ); % close bullet point
      end
     fprintf(oid,'  </ul>\n\n');      % open the unordered list      
    end

    % Acknowledgment:
    if isfield(metaData, 'acknowledgment') == 1
      fprintf(oid, '  <H3 style="clear:both" class="pet">Acknowledgment</H3>\n');
      fprintf(oid, '    <ul> \n');     % open the unordered list
    
      fprintf(oid, '      <li>\n');    % open bullet point
      str = metaData.acknowledgment;
      fprintf(oid, '      %s\n', str);
      fprintf(oid, '      </li>\n' );  % close bullet point
   
      fprintf(oid,'     </ul>\n\n\n'); % close the unordered list      
    end

    % Bibliography:
    fprintf(oid, '  <H3 style="clear:both" class="pet"><a class="link" href = "%s_bib.bib" target = "_blank">Bibliography</a></H3>\n', title);
    fprintf(oid, '  <div w3-include-html="%s_bib.html"></div>\n', title);
    fprintf(oid, '  <script>w3IncludeHTML();</script>\n\n');
  
    % ----------------------------------------------------------

    fprintf(oid, '  <div w3-include-html="%sfooter_amp.html"></div>\n', path2sys);
    fprintf(oid, '  <script>w3IncludeHTML();</script>\n\n');


    fprintf(oid, '</BODY>\n');
    fprintf(oid, '</HTML>\n');

    fclose(oid);

    web(fileName,'-browser') % open html in systems browser
