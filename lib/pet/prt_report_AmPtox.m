%% prt_report_AmPtox
% writes report of local results file

%%
function prt_report_AmPtox(title)
% created 2022/02/01 by Bas Kooijman

%% Syntax
% <../prt_report_AmPtox.m *prt_report_AmPtox*> (title) 

%% Description
% Writes report in html from the local results file
%
% Input:
%
% * title: optional name of the results_title.mat file
%
% Output:
%
% * no Matlab output, text is written to html

%% Remarks
% If no input is specified, a single .mat file with results is assumed to be locally present
  global pets
  
  path2sys = [set_path2server, 'add_my_pet/sys/'];
  if ~exist('title', 'var')
    title = pets{1}; load(['results_',title]);
  else
    load(['results_',title]);   
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
    fprintf(oid, '      padding-top: 60px;\n');
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

    fprintf(oid, '    /*-------- Figs -----------*/\n\n');

    fprintf(oid, '    /* not-enlarged on page */\n');
    fprintf(oid, '    .myImg {\n');
    fprintf(oid, '      max-width:300px;\n');
    fprintf(oid, '      max-height:200px;\n');
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    /* enlarge figs: to Trigger the Modal */\n');
    fprintf(oid, '    .myImg {\n');
    fprintf(oid, '      border-radius: 5px;\n');
    fprintf(oid, '      cursor: pointer;\n');
    fprintf(oid, '      transition: 0.3s;\n');
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    .myImg:hover {opacity: 0.7;}\n\n');

    fprintf(oid, '    /* The Modal (background) */\n');
    fprintf(oid, '    .modal {\n');
    fprintf(oid, '      display: none; /* Hidden by default */\n');
    fprintf(oid, '      position: fixed; /* Stay in place */\n');
    fprintf(oid, '      z-index: 1; /* Sit on top */\n');
    fprintf(oid, '      padding-top: 100px; /* Location of the box */\n');
    fprintf(oid, '      left: 0;\n');
    fprintf(oid, '      top: 0;\n');
    fprintf(oid, '      width: 100%%; /* Full width */\n');
    fprintf(oid, '      height: 100%%; /* Full height */\n');
    fprintf(oid, '      overflow: auto; /* Enable scroll if needed */\n');
    fprintf(oid, '      background-color: rgb(0,0,0); /* Fallback color */\n');
    fprintf(oid, '      background-color: rgba(0,0,0,0.9); /* Black w/ opacity */\n');
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    /* Modal Content (Image) */\n');
    fprintf(oid, '    .modal-content {\n');
    fprintf(oid, '      margin: auto;\n');
    fprintf(oid, '      display: block;\n');
    fprintf(oid, '      height: 80%%;\n');
    fprintf(oid, '      max-height: 700px;\n');
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    /* Caption of Modal Image (Image Text) - Same Width as the Image */\n');
    fprintf(oid, '    #caption {\n');
    fprintf(oid, '      margin: auto;\n');
    fprintf(oid, '      display: block;\n');
    fprintf(oid, '      width: 80%%;\n');
    fprintf(oid, '      max-width: 700px;\n');
    fprintf(oid, '      text-align: center;\n');
    fprintf(oid, '      color: #ccc;\n');
    fprintf(oid, '      padding: 10px 0;\n');
    fprintf(oid, '      height: 150px;\n');
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    /* Add Animation - Zoom in the Modal */\n');
    fprintf(oid, '    .modal-content, #caption {\n');
    fprintf(oid, '      -webkit-animation-name: zoom;\n');
    fprintf(oid, '      -webkit-animation-duration: 0.6s;\n');
    fprintf(oid, '      animation-name: zoom;\n');
    fprintf(oid, '      animation-duration: 0.6s;\n');
    fprintf(oid, '    }\n\n');
   
    fprintf(oid, '    @-webkit-keyframes zoom {\n');
    fprintf(oid, '      from {-webkit-transform:scale(0)}\n');
    fprintf(oid, '      to {-webkit-transform:scale(1)}\n');
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    @keyframes zoom {\n');
    fprintf(oid, '      from {transform:scale(0)}\n');
    fprintf(oid, '      to {transform:scale(1)}\n');
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    .close:hover,\n');
    fprintf(oid, '    .close:focus {\n');
    fprintf(oid, '      color: #bbb;\n');
    fprintf(oid, '      text-decoration: none;\n');
    fprintf(oid, '      cursor: pointer;\n');
    fprintf(oid, '    }\n\n');

    fprintf(oid, '  </style>\n');
    fprintf(oid, '</head>\n\n');
    
    fprintf(oid, '<body>\n\n');

    % metaData
    fprintf(oid, '  <div class="left">\n');
    fprintf(oid, '  <h1>%s</h1>\n', title);
    flds = fields(metaData); 
    flds = flds(~ismember(flds,{'biblist','discussion','facts','acknowledgment','data_0','data_1','data_2','bibkey','COMPLETE'}));
    n_flds = length(flds);
    for i=1:n_flds
       txt = metaData.(flds{i}); if isnumeric(txt); txt = num2str(txt); end
       if iscell(txt)
          n_txt = length(txt); ltxt=txt{1}; for j=2:n_txt; ltxt=[ltxt,', ', txt{j}];end
          fprintf(oid, '    <b>%s: </b>%s<br>\n', flds{i}, ltxt);
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
      fprintf(oid, '    <img class="myImg" src=%s alt="">\n',png{i});
    end
    fprintf(oid, '    \n');
   
    fprintf(oid, '    <div id="myModal" class="modal">\n');        
    fprintf(oid, '      <img class="modal-content" id="img01">\n');
    fprintf(oid, '      <div id="caption"></div>\n');
    fprintf(oid, '    </div>\n');
    fprintf(oid, '  </div>\n\n');

    fprintf(oid, '  <script>\n');
    fprintf(oid, '    var modal = document.getElementById("myModal");\n');
    fprintf(oid, '    var i;\n\n');

    fprintf(oid, '    var img = document.getElementsByClassName("myImg");\n');
    fprintf(oid, '    var modalImg = document.getElementById("img01");\n');
    fprintf(oid, '    var captionText = document.getElementById("caption");\n\n');

    fprintf(oid, '    for(i=0;i< img.length;i++) {\n');    
    fprintf(oid, '      img[i].onclick = function(){\n');
    fprintf(oid, '        modal.style.display = "block";\n');
    fprintf(oid, '        modalImg.src = this.src;\n');
    fprintf(oid, '        captionText.innerHTML = this.alt;\n');  
    fprintf(oid, '      }\n');
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    // When the user clicks on modelImg, close the modal\n');
    fprintf(oid, '    modalImg.onclick = function() {\n'); 
    fprintf(oid, '      modal.style.display = "none";\n');
    fprintf(oid, '    }\n');
    fprintf(oid, '  </script>\n\n');
    
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
  
    fprintf(oid, '  <hr>\n\n');
    
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
