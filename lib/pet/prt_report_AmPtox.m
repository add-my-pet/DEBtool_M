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
  global pets
  
  path2sys = [set_path2server, 'add_my_pet/sys/'];
  if ~exist('fileNm', 'var')
    %list = cellstr(ls); title = list(contains(list,'.mat')); title = title{1}; load(title) % load the results_*.mat file
    %title(1:8) = []; title(end-3:end) = []; % select identifying part of the name 
    title = pets{1}; load(['results_',title]);
  else
    title = fileNm; load(['results_',fileNm]);   
  end
  
  [~, ~, ~, txtData] = feval(['mydata_', title]); % get txtData
  
  % compose fileNm_bib.bib and, if the user has BibTex, fileNm_bib.html
  prt_my_pet_bib(title, metaData.biblist);                % my_pet_bib.bib 
  try
    bib2html([title, '_bib']);                              % my_pet_bib.html 
  catch
  end
  list = cellstr(ls);

    fileName = [title, '_report.html']; % char string with file name of output file
    oid = fopen(fileName, 'w+'); % open file for writing, delete existing content

    fprintf(oid, '<!DOCTYPE html>\n');
    fprintf(oid, '<html>\n');
    fprintf(oid, '<head>\n');
    fprintf(oid, '  <title>%s</title>\n\n',  title);
    
    fprintf(oid, '  <style>\n');
    fprintf(oid, '    div.left {\n');
    fprintf(oid, '      width: 30%%;\n');
    fprintf(oid, '      float: left;\n'); 
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    div.middle {\n');
    fprintf(oid, '      width: 15%%;\n');
    fprintf(oid, '      float: left;\n'); 
    fprintf(oid, '      padding-top: 60px;\n');
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    div.right {\n');
    fprintf(oid, '      width: 55%%;\n');
    fprintf(oid, '      float: right;\n');
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    p.clear {\n');
    fprintf(oid, '      clear: both;\n');
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    div.footer{\n');
    fprintf(oid, '      margin: auto;\n');
    fprintf(oid, '      clear: both;\n');
    fprintf(oid, '      text-align: center;\n');
    fprintf(oid, '      font-size: 0.8em;\n');
    fprintf(oid, '    }\n\n');

    fprintf(oid, '  </style>\n');
    fprintf(oid, '</head>\n\n');
    
    fprintf(oid, '<body>\n\n');

    % metaData
    fprintf(oid, '  <div class="left">\n');
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

    % results
    fprintf(oid, '  <div class="middle">\n');
    fprintf(oid, '    <h3><a href="%s_res.html">results</a></h3>\n\n', title);
    
    % elasticities
    if ismember([title,'_elas.html'], list)
      fprintf(oid, '    <h3><a href="%s_elas.html">elasticities</a></h3>\n\n', title); 
    end
    
    % Bibliography
    if ismember([title, '_bib.html'], list)
      fprintf(oid, '    <h3><a href="%s_bib.html">bibliography</a></h3>\n', title);
    elseif ismember([title, '_bib.bib'], list)
      fprintf(oid, '    <h3><a href="%s_bib.bib">bibliography</a></h3>\n', title);
    end
    fprintf(oid, '  </div>\n\n');

    % plots
    fprintf(oid, '  <div class="right">\n');
    png = list(contains(list,'.png')); png = png(contains(png,title)); n_png = length(png);
    for i = 1:n_png
      if ~contains(png{i},'legend')
        fprintf(oid, '    <img src=%s width="500px">\n',png{i});
      else
        fprintf(oid, '    <img src=%s width="150px">\n',png{i});
     end
    end
    fprintf(oid, '  </div>\n\n');
    
    fprintf(oid, '  <p class="clear"></p>\n\n');

    % Facts:
    if isfield(metaData, 'facts') 
      fprintf(oid, '      <h3 style="clear:both" class="pet">Facts</h3>\n');
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
      fprintf(oid,'      </ul>\n\n');       % close the unordered list    
    end

    % Discussion
    if isfield(metaData, 'discussion') == 1
      fprintf(oid, '  <h3 style="clear:both" class="pet">Discussion</h3>\n');
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
        fprintf(oid, '    </li>\n'); % close bullet point
      end
     fprintf(oid,'  </ul>\n\n');      % open the unordered list      
    end

    % Acknowledgment:
    if isfield(metaData, 'acknowledgment') == 1
      fprintf(oid, '  <h3 style="clear:both" class="pet">Acknowledgment</h3>\n');
      fprintf(oid, '    <ul> \n');     % open the unordered list
    
      fprintf(oid, '      <li>\n');    % open bullet point
      str = metaData.acknowledgment;
      fprintf(oid, '      %s\n', str);
      fprintf(oid, '      </li>\n' );  % close bullet point
   
      fprintf(oid,'     </ul>\n\n'); % close the unordered list      
    end
  
    % footer
    fprintf(oid, '  <div class="footer">\n');
    fprintf(oid, '    Report generated by <a href="https://add-my-pet.github.io/AmPtox/docs/">AmPtox</a>\n');
    fprintf(oid, '    at %s; \n', datestr(datenum(date), 'yyyy/mm/dd'));
    fprintf(oid, '    <a href="https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/sys/disclaimer.html">\n');
    fprintf(oid, '      Disclaimer/Terms of use\n');
    fprintf(oid, '    </a> &#169; 2009-%s Add-my-Pet\n', datestr(datenum(date), 'yyyy'));
    fprintf(oid, '  </div>\n\n');

    fprintf(oid, '</body>\n');
    fprintf(oid, '</html>\n');

    fclose(oid);

    web(fileName,'-browser') % open html in systems browser
