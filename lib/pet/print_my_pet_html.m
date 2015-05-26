%% print_my_pet_html
% Creates my_pet.html 

%%
function print_my_pet_html(metadata, par, chem, stat)
% created 2015/04/11 by Starrlight (heavily inspired by a file created by Bas Kooijman)
% modified 2015/04/19

%% Syntax
% <../print_my_pet_html.m *print_my_pet_html*> (imetadata, par, chem, stat) 

%% Description
% Read and writes my_pet.html. This pages contains a list of implied model
% properties and parameters values of my_pet.
%
% Input:
%
% * metadata: structure
% * par: structure
% * chem: structure
% * stat: structure


%% Remarks
% Keep in mind that the files will be saved in your local directory; use
% the cd command BEFORE running this function to save files in the desired
% place.

%% Example of use
% load('results_my_pet.mat');
% print_my_pet_html(metadata)

v2struct(metadata); 

n_author = length(author);

switch n_author
    
    case 1
    txt_author = author{1};

    case 2
    txt_author = [author{1}, ', ', author{2}];

    otherwise    
    txt_author = [author{1}, ', et al.'];

end

txt_date = [num2str(date_acc(1)), '/', num2str(date_acc(2)), '/', num2str(date_acc(3))]; 

% !!!!!!!!!!!!!!! We need to adapt this part of the code
% because it is possible that exist('author_mod_2', 'var') == 1 etc. ...

if exist('author_mod_1', 'var') == 1 && exist('date_mod_1', 'var') == 1
n_author_mod_1 = length(author_mod_1);

    switch n_author_mod_1
      case 1
      txt_author_mod_1 = author_mod_1{1};
      case 2
      txt_author_mod_1 = [author_mod_1{1}, ', ', author_mod_1{2}];
      otherwise    
      txt_author_mod_1 = [author_mod_1{1}, ', et al.'];
    end

txt_date_mod_1 = [num2str(date_mod_1(1)), '/', num2str(date_mod_1(2)), '/', num2str(date_mod_1(3))]; 

else
    
txt_author_mod_1 = '';
txt_date_mod_1 =  '';

end  

% --- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


  oid = fopen([species, '.html'], 'w+'); % % open file for writing, delete existing content
  fprintf(oid, '%s\n' ,'<!DOCTYPE html>');
  fprintf(oid, '%s\n' ,'<HTML>');
  fprintf(oid, '%s\n' ,'  <HEAD>');
  fprintf(oid,['    <TITLE>add-my-pet:', species, '</TITLE>\n']);
  fprintf(oid, '%s'   ,'    <META NAME = "keywords" ');
  fprintf(oid, '%s\n' ,'     CONTENT="add-my-pet, Dynamic Energy Budget theory, DEBtool">');
  
  % ----- calls the javascript function (found in subfolder sys):
  fprintf(oid, '%s\n' ,'<script type="text/javascript" src="../sys/boxmodal.js"></script>');
  % ------ calls the cascading style sheet (found in subfolder css):
  fprintf(oid, '%s\n' ,'<link rel="stylesheet" type="text/css" href="../css/collectionstyle.css">'); 
  
  fprintf(oid, '%s\n' , ' </HEAD>');
  fprintf(oid, '%s\n\n','  <BODY>');
  
   
 
% make a large table with two columns
% the statistics table is in column 1 
% the primary parameter and chemical parameters are in column 2:
fprintf(oid, '<TABLE CELLSPACING=60><TR VALIGN=TOP><TD>\n');

% statistics table (column 1):
fprintf(oid, '      <TABLE>\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="4">Properties at T_typical and f </TH></TR>\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH>symbol</TH><TH> value</TH><TH> units</TH><TH> description</TH></TR>\n');
  for i = 1:  size(stat,1)
    fprintf(oid, '    <TR BGCOLOR = "%s"> <TD>%s</TD> <TD>%g</TD> <TD>%s</TD><TD>%s</TD></TR>\n',...
        stat{i,1}, stat{i,2}, stat{i,3}, stat{i,4}, stat{i,5});
  end
% ----------------------------------------------------------------------
fprintf(oid, '    </TABLE>\n');    

% open up the second column:
fprintf(oid, '    </TD><TD>\n');    

%% primary parameters tables:
   
fprintf(oid, '    <TABLE>\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="4">Primary parameters at T_ref</TH></TR>\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH>symbol</TH><TH> value</TH><TH> units</TH><TH> description</TH></TR>\n');
  for i = 1:  size(par,1)
    fprintf(oid, '    <TR BGCOLOR = "%s"> <TD>%s</TD> <TD>%g</TD> <TD>%s</TD><TD>%s</TD></TR>\n',...
        par{i,1}, par{i,2}, par{i,3}, par{i,4}, par{i,5});
  end
  
% Empty line in table so that there is a space between primary parameters
% and chemical parameters:
fprintf(oid, '     <TR><TD BGCOLOR = "%s">%s</TD> \n', '#FAFAFA', '&nbsp;');

% chemical parameters:
% this table is in truth a continuation of the same table as for statistics
% the advantage being that the tables won't slide around when the browser
% window is re-sized:
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="4">Biochemical parameters</TH></TR>\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH>symbol</TH><TH> value</TH><TH> units</TH><TH> description</TH></TR>\n');
  for i = 1:  size(chem,1)
    fprintf(oid, '    <TR BGCOLOR = "%s"> <TD>%s</TD> <TD>%g</TD> <TD>%s</TD><TD>%s</TD></TR>\n',...
    chem{i,1}, chem{i,2}, chem{i,3}, chem{i,4}, chem{i,5});
  end
fprintf(oid, '    </TABLE>\n'); 

% close the second column:
fprintf(oid, '    </TD>\n');  
% close the table:
fprintf(oid, '    </TABLE>\n');  

%% author and last data of modification

fprintf(oid, '<HR> \n');
fprintf(oid,['    <H3 ALIGN="CENTER">', txt_author, ', ', txt_date, ...
        ' (last modified by ', txt_author_mod_1, '\n', txt_date_mod_1,')','</H3>\n']); 

%% close my_pet.html  
  
% these two lines are necessary for the boxes called by java scrip in
% subfolder sys to work:
fprintf(oid,'%s\n' , '<div style="position: absolute; z-index: 20000; visibility: hidden; display: none;" id="ext-comp-1001" class="x-tip"><div class="x-tip-tl"><div class="x-tip-tr"><div class="x-tip-tc"><div style="-moz-user-select: none;" id="ext-gen10" class="x-tip-header x-unselectable"><span class="x-tip-header-text"></span></div></div></div></div><div id="ext-gen11" class="x-tip-bwrap"><div class="x-tip-ml"><div class="x-tip-mr"><div class="x-tip-mc"><div style="height: auto;" id="ext-gen12" class="x-tip-body"></div></div></div></div>');
fprintf(oid,'%s\n' , '<div class="x-tip-bl x-panel-nofooter"><div class="x-tip-br"><div class="x-tip-bc"></div></div></div></div></div><div id="xBoxScreen"></div>');

fprintf(oid, '  </BODY>\n');
fprintf(oid, '  </HTML>\n');
fclose(oid);
