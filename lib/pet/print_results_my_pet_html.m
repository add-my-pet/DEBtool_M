%% print_results_my_pet_html
% read and write results_my_pet.html

%%
function print_results_my_pet_html(metadata, metapar, par, chem)
% created 2015/04/11 by Starrlight & Goncalo Marques; modified 2015/07/27 Starrlight 

%% Syntax
% <../print_results_my_pet_html.m *print_results_my_pet_html*> (metadata, metapar) 

%% Description
% Prints an html file which compares metapar.model predictions with data
%
% Input:
%
% * metadata: structure
% * metapar:  structure

%% Remarks
% Keep in mind that this function is specifically designed for created the
% webpage of add-my-pet -

%% Example of use
% load('results_my_pet.mat');
% print_results_my_pet_html(metadata, metapar)

% v2struct(metadata); v2struct(metapar); 

n_author = length(metadata.author);

switch n_author
    
    case 1
    txt_author = metadata.author{1};

    case 2
    txt_author = [metadata.author{1}, ', ', metadata.author{2}];

    otherwise    
    txt_author = [metadata.author{1}, ', et al.'];

end

txt_date = [num2str(metadata.date_acc(1)), '/', num2str(metadata.date_acc(2)), '/', num2str(metadata.date_acc(3))]; 

if exist('metadata.author_mod_1', 'var') == 1 && exist('metadata.date_mod_1', 'var') == 1
n_author_mod_1 = length(metadata.author_mod_1);

    switch n_author_mod_1
      case 1
      txt_author_mod_1 = metadata.author_mod_1{1};
      case 2
      txt_author_mod_1 = [metadata.author_mod_1{1}, ', ', metadata.author_mod_1{2}];
      otherwise    
      txt_author_mod_1 = [metadata.author_mod_1{1}, ', et al.'];
    end

txt_date_mod_1 = [num2str(metadata.date_mod_1(1)), '/', num2str(metadata.date_mod_1(2)), '/', num2str(metadata.date_mod_1(3))]; 

else
    
txt_author_mod_1 = '';
txt_date_mod_1 =  '';

end  

speciesprintnm = strrep(metadata.species, '_', ' ');

oid = fopen(['results_', metadata.species, '.html'], 'w+'); % open file for reading and writing, delete existing content
fprintf(oid, '%s\n' ,'<!DOCTYPE html>');
fprintf(oid, '%s\n' ,'<HTML>');
fprintf(oid, '%s\n' ,'  <HEAD>');
fprintf(oid,['    <TITLE>add-my-pet: results ', speciesprintnm, '</TITLE>\n']);
fprintf(oid, '%s'   ,'    <META NAME = "keywords" ');
fprintf(oid, '%s\n' ,'     CONTENT="add-my-pet, Dynamic Energy Budget theory, DEBtool">');

% ----- calls the javascript function (found in subfolder sys):
fprintf(oid, '%s\n' ,'<script type="text/javascript" src="../../sys/boxmodal.js"></script>');
fprintf(oid, '%s\n' ,'<script type="text/javascript" src="../sys2/entries.js"></script>'); % java functions specific for the entries of 

% ------ calls the cascading style sheet (found in subfolder css):
fprintf(oid, '%s\n' ,'<link rel="stylesheet" type="text/css" href="../../css/collectionstyle.css">'); 

fprintf(oid, '%s\n' , ' </HEAD>');
fprintf(oid, '%s\n\n','  <BODY>');
  
   
%% content of results_my_pet
fprintf(oid, ['<H2>Model: <a class="link" href="#" onclick="BoxArt_type();">&nbsp;', metapar.model,' &nbsp;</a></H2>']);

%%% get the predictions vs the data: 

fprintf(oid,'<p> \n');    
fprintf(oid,['<a class="link" href="#" onclick="BoxArt_complete2();">COMPLETE</a>',' = %3.1f <BR>\n'],metadata.COMPLETE);
fprintf(oid,['<a class="link" href="#" onclick="BoxArt_fit2();">MRE</a>',' = %8.3f \n'],metapar.MRE);   
fprintf(oid,'</p> \n');     % close the paragraph

[data, txt_data] = feval(['mydata_',metadata.species]); 
% %%% these next lines of code have been canabalised from printprd_st.m:

% load(['results_',metadata.species,'.mat'])

prd_data = feval(['predict_',metadata.species], par, chem, metapar.T_ref, data);

% appends new field to prd_data with predictions for the pseudo data:
% (the reason is that the predicted values for the pseudo data are not
% returned by predict_my_pet and this has to do with compatibility with the
% multimetadata.species parameter estimation):
prd_data = predict_pseudodata(prd_data, par, chem, data);

% remove fields 'weight' and 'temp' from structure data:
datapl    = rmfield_wtxt(data, 'weight');
datapl    = rmfield_wtxt(datapl, 'temp');

% cell array of string with fieldnames of data.weight
dtsets    = fieldnames(data.weight);
[nm, nst] = fieldnmnst_st(datapl);

%-----------------------------------------------------------
% make table for zero-variate data set:
fprintf(oid, '      <TABLE id="t01">\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="7"><a class="link" href="#" onclick="BoxArt_data2();">Zero-variate</a> data</TH></TR>\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TD><b>Data</b></TD><TD><b>Observed</b></TD><TD><b>Predicted</b></TD><TD><b>(RE)</b></TD><TD><b>Unit</b></TD><TD><b>Description</b></TD><TD><b>Reference</b></TD></TR>\n');
  for j = 1:nst
  eval(['[aux, k] = size(data.', nm{j}, ');']) % number of data points per set
    if k == 1 && isempty(strfind(nm{j},'psd.')) % if it is a zero-variate data set
      name = nm{j};
      dta   = eval(['data.',nm{j}]);
      prdta = eval(['prd_data.',nm{j}]);
      re    = metapar.RE(j); 
      unit  = eval(['txt_data.units.',nm{j}]);
      des   = eval(['txt_data.label.',nm{j}]);
      eval(['n = iscell(txt_data.bibkey.',nm{j},');']) 
      if n
      n = eval(['length(txt_data.bibkey.',nm{j},');']);
      REF = [];
        for i = 1:n
        ref = eval(['txt_data.bibkey.',nm{j},'{i}']);
          if i == 1
          REF = [REF,' ',ref];
          else
          REF = [REF,', ',ref];
          end
        end
      else
      REF = eval(['txt_data.bibkey.',nm{j}]);    
      end
      fprintf(oid, '    <TR > <TD>%s</TD><TD>%3.4g</TD> <TD>%3.4g</TD> <TD>(%3.4g)</TD><TD>%s</TD><TD>%s</TD><TD>%s</TD></TR>\n',...
      name, dta, prdta, re, unit, des, REF);
    end
  end
fprintf(oid, '    <TR><TD></TD><TD></TD><TD></TD><TD></TD><TD></TD><TD></TF></TR>\n');
fprintf(oid, '    </TABLE>\n');  

% make a nice table for uni-variate data set:
if isempty(metadata.data_1) == 0
fignum = 0; unidta = [];
fprintf(oid, '      <TABLE id="t01">\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="6"><a class="link" href="#" onclick="BoxArt_data3();">Uni-variate</a> data </TH></TR>\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TD><b>Dataset</b></TD><TD><b>Figure</b></TD><TD><b>(RE)</b></TD><TD><b>Independent variable</b></TD><TD><b>Dependent variable</b></TD><TD><b>Reference</b></TD></TR>\n');
  for j = 1:nst
  eval(['[aux, k] = size(data.', nm{j}, ');']) % number of data points per set
  
    if k >1
      unidta = [unidta;j];
      fignum = fignum + 1;
      label = nm{j};
      if fignum < 10
      fig   = ['see <A href = "results_',metadata.species,'_0',num2str(fignum),'.png"> Fig. ',num2str(fignum),'</A>'];
      else
      fig   = ['see <A href = "results_',metadata.species,'_',num2str(fignum),'.png"> Fig. ',num2str(fignum),'</A>'];
      end
      re    = metapar.RE(j); 
      ivar   = eval(['txt_data.label.',nm{j},'{1}']);
      dvar   = eval(['txt_data.label.',nm{j},'{2}']);
      eval(['n = iscell(txt_data.bibkey.',nm{j},');'])
      if n
      n = eval(['length(txt_data.bibkey.',nm{j},');']);
      REF = [];
        for i = 1:n
        ref = eval(['txt_data.bibkey.',nm{j},'{i}']);
          if i == 1
          REF = [REF,' ',ref];
          else
          REF = [REF,', ',ref];
          end
        end
      else
      REF = eval(['txt_data.bibkey.',nm{j}]);    
      end
      fprintf(oid, '    <TR > <TD>%s</TD> <TD>%s</TD> <TD>(%3.4g)</TD><TD>%s</TD><TD>%s</TD><TD>%s</TD></TR>\n',...
      label, fig, re, ivar, dvar, REF);        
    end
  end
 fprintf(oid, '    <TR><TD></TD><TD></TD><TD></TD><TD></TD><TD></TD><TD></TD></TR>\n');
  fprintf(oid, ['    <TR><TH colspan = "6"><A href = "unidata_',metadata.species,'.html" target = "_blank"> View all of the figures here</A></TH></TR>\n']);
 fprintf(oid, '    </TABLE>\n'); 
end
 
% make table for pseudo-data:
fprintf(oid, '      <TABLE id="t01">\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="5"> Pseudo-data </TH></TR>\n');
fprintf(oid, ['    <TR BGCOLOR = "#FFE7C6"><TD><B>Data</B></TD><TD><B>Generalised animal</B></TD><TD><B>',speciesprintnm,'</B></TD><TD><B>Unit</B></TD><TD><B>Description</B></TD></TR>\n']);
  for j = 1:nst
  eval(['[aux, k] = size(data.', nm{j}, ');']) % number of data points per set
    if k == 1 && isempty(strfind(nm{j},'psd.'))==0 % if it is pseudo-data
       printnm = strrep(nm{j}, 'psd.', ' ');
       name    = printnm;
       dta     = eval(['data.',nm{j}]);
       prdta = eval(['prd_data.',nm{j}]);
       unit  = eval(['txt_data.units.',nm{j}]);
       des   = eval(['txt_data.label.',nm{j}]);
       fprintf(oid, '<TR ><TD>%s</TD> <TD>%3.4g</TD> <TD>%3.4g</TD><TD>%s</TD><TD>%s</TD></TR>\n',...
       name, dta, prdta, unit, des);       
    end
  end
 fprintf(oid, '    </TABLE>\n'); 
 
 if isempty(metadata.data_1) == 0
 print_unidata_my_pet_html(metadata, metapar)
 end
 
% %%% Print out all of the graphs with captions:
% 
% ex = 1;
% counter = 0;
% 
% while ex 
%   test = counter + 1;
%   if test < 10
%     fullnm = ['results_',metadata.species, '_0', num2str(test), '.png'];
%   else
%     fullnm = ['results_',metadata.species, '_', num2str(test), '.png'];
%   end
%   
%   if exist(fullnm, 'file')
%      counter = counter +1;
% 
%  eval(['n = iscell(txt_data.bibkey.',nm{unidta(counter)},');'])
%       if n
%       n = eval(['length(txt_data.bibkey.',nm{unidta(counter)},');']);
%       REF = [];
%         for i = 1:n
%         ref = eval(['txt_data.bibkey.',nm{unidta(counter)},'{i}']);
%           if i == 1
%           REF = [REF,' ',ref];
%           else
%           REF = [REF,', ',ref];
%           end
%         end
%       else
%       REF = eval(['txt_data.bibkey.',nm{unidta(counter)}]);    
%       end
%   
%  fprintf(oid, '<div class="figure">\n');
%  fprintf(oid, ['<p><img src="',fullnm,'" width = "380px" alt="Fig ',num2str(test),' 1"> \n']);
%  fprintf(oid,[' <p>Fig. ', num2str(test),': symbols: data from ', REF,'. \n']);
%  fprintf(oid,'Lines: %s metapar.model predictions. \n', metapar.model); 
% 
%  if isfield(txt_data, 'caption')
%       if isfield(txt_data.caption, nm{unidta(counter)})
%       str = eval(['txt_data.caption.',nm{unidta(counter)}]);
%       fprintf(oid,str);     
%       end
%       display('warning: change caption to comment in future version')
%  end
%  if isfield(txt_data, 'comment')
%       if isfield(txt_data.comment, nm{unidta(counter)})
%       str = eval(['txt_data.comment.',nm{unidta(counter)}]);
%       fprintf(oid,str);     
%       end
%  end
%  fprintf(oid,'</div> \n');   
% else
%     ex = 0;
%   end
% end

%% Facts:
if isfield(metadata, 'facts') 
fprintf(oid, '<H3 style="clear:both" class="pet">Facts</H3>\n');
fprintf(oid,'<ul> \n');     % open the unordered list
[nm, nst] = fieldnmnst_st(metadata.facts);
    for i = 1:nst
    fprintf(oid, '<li>\n'); % open bullet point
    str1 = eval(['metadata.facts.',nm{i}]);
    if isfield(txt_data.bibkey,nm{i})
    str2 = eval(['txt_data.bibkey.',nm{i}]);
    fprintf(oid, [str1,' (',str2,') \n']);
    else
    fprintf(oid, [str1,'\n']);  
    end
    fprintf(oid, '</li>\n' ); % close bullet point
    end
fprintf(oid,'</ul> \n');     % open the unordered list    
end

%% Discussion:
if isfield(metadata, 'discussion') == 1
fprintf(oid, '<H3 style="clear:both" class="pet">Discussion</H3>\n');
fprintf(oid,'<ul> \n');     % open the unordered list
[nm, nst] = fieldnmnst_st(metadata.discussion);
    for i = 1:nst
    fprintf(oid, '<li>\n'); % open bullet point
    str = eval(['metadata.discussion.',nm{i}]);
      if isfield(txt_data.bibkey,nm{i})
      str2 = eval(['txt_data.bibkey.',nm{i}]);
      fprintf(oid, [str,' (',str2,') \n']);
      else
      fprintf(oid, [str, '\n']);
      end
    fprintf(oid, '</li>\n' ); % close bullet point
    end
fprintf(oid,'</ul> \n');     % open the unordered list      
end

%% Bibliography:
fprintf(oid, '<H3 style="clear:both" class="pet">Bibliography</H3>\n');
[nm, nst] = fieldnmnst_st(metadata.biblist);
    for i = 1:nst
    fprintf(oid, '<li>\n'); % open bullet point
%     str = eval(['metadata.biblist.',nm{i}]);
    fprintf(oid, [nm{i}, '\n']);
    fprintf(oid, '</li>\n' ); % close bullet point
    end
fprintf(oid,'</ul> \n');     % open the unordered list   
fprintf(oid, '<p>\n');
fprintf(oid, ['<A class="link" href = "bib_',metadata.species,'.bib" target = "_blank">Bibtex files with references for this entry </A> <BR> \n']);
% fprintf(oid, 'A PDF of all of the references of the add-my-pet collection can be consulted <A target="_blank" href="../../add_my_pet_bibliography.pdf">here</A>\n');
fprintf(oid, '</p>\n' );
  
%% Authors and last data of modification
fprintf(oid, '<HR> \n');
fprintf(oid,['    <H3 ALIGN="CENTER">', txt_author, ', ', txt_date, ...
        ' (last modified by ', txt_author_mod_1, '\n', txt_date_mod_1,')','</H3>\n']);
 
%% close results_my_pet.html  
  
% these two lines are necessary for the boxes called by java scrip in
% subfolder sys to work:
fprintf(oid,'%s\n' , '<div style="position: absolute; z-index: 20000; visibility: hidden; display: none;" id="ext-comp-1001" class="x-tip"><div class="x-tip-tl"><div class="x-tip-tr"><div class="x-tip-tc"><div style="-moz-user-select: none;" id="ext-gen10" class="x-tip-header x-unselectable"><span class="x-tip-header-text"></span></div></div></div></div><div id="ext-gen11" class="x-tip-bwrap"><div class="x-tip-ml"><div class="x-tip-mr"><div class="x-tip-mc"><div style="height: auto;" id="ext-gen12" class="x-tip-body"></div></div></div></div>');
fprintf(oid,'%s\n' , '<div class="x-tip-bl x-panel-nofooter"><div class="x-tip-br"><div class="x-tip-bc"></div></div></div></div></div><div id="xBoxScreen"></div>');

fprintf(oid, '  </BODY>\n');
fprintf(oid, '  </HTML>\n');
fclose(oid);
