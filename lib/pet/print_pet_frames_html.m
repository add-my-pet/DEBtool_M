%% print_pet_frames_html
% prints four html pages for each pet

%%
function print_pet_frames_html(metaData)
% created 2015/04/11 Starrlight & Goncalo Marques; 
% modified 2015/09/11 Starrlight 

%% Syntax
% <../print_pet_frames_html.m *print_pet_frames_html*> (metadata)

%% Description
% Prints four html pages for each entry :
%
% * i_my_pet.html 
% * i_results_my_pet.html
% * i_left_my_pet.html 
% * i_top_my_pet.html 
%
% Input:
%
% * metadata: structure

%% Remarks

%% Example of use
% load('results_my_pet.mat');
% print_pet_frames_html(metadata)


% Removes underscores and makes first letter of english name be
% in capital:
speciesprintnm = strrep(metaData.species, '_', ' ');

speciesprintnm_en = strrep(metaData.species_en, '_', ' ');
if speciesprintnm_en(1)>='a' && speciesprintnm_en(1)<='z'
  speciesprintnm_en(1)=char(speciesprintnm_en(1)-32);
end
% ------------------------------------------------------------

% %%% read and write i_my_pet
% oid = fopen(['i_', metaData.species, '.html'], 'w+'); % % open file for writing, delete existing content
%   fprintf(oid, '%s\n' ,'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN">');
%   fprintf(oid, '%s\n' ,'<HTML>');
%   fprintf(oid, '%s\n' ,'  <HEAD>');
%   fprintf(oid,['    <TITLE>add-my-pet: ', speciesprintnm, '</TITLE>\n']);
%   fprintf(oid, '%s'   ,'    <META NAME = "keywords" ');
%   fprintf(oid, '%s\n' ,'     CONTENT="add-my-pet, Dynamic Energy Budget theory, DEBtool">');
%   fprintf(oid, '%s\n' , ' </HEAD>'); 
% % ---------------------------------------------------------------------
% fprintf(oid, '<FRAMESET BORDER=0 FRAMEBORDER=0 FRAMESPACING=0 cols="150,*">\n');
% fprintf(oid, ['<FRAME SRC="i_left_',metaData.species,'.html" NAME="left">\n']);
% fprintf(oid, '<FRAMESET BORDER=0 FRAMEBORDER=0 FRAMESPACING=0 rows="100,*">\n');
% fprintf(oid, ['<FRAME SRC="i_top_',metaData.species,'.html" NAME="top">\n']);
% fprintf(oid, ['<FRAME SRC="',metaData.species,'.html" NAME="main">\n']);
% fprintf(oid, '</FRAMESET>\n');
% fprintf(oid, '  </FRAMESET>\n');
% fprintf(oid, '<NOFRAMES>\n');
% fprintf(oid, '  <BODY>\n');    
% fprintf(oid, ['<A HREF=',metaData.species,'.html"></A>']);    
% fprintf(oid, '  </BODY>\n');
% % ---------- close i_my_pet.html ------------------------   
% fprintf(oid, '  </NOFRAMES>\n');
% fprintf(oid, '  </HTML>\n');
% fclose(oid);

%%% read and write i_results_my_pet
oid = fopen(['i_results_', metaData.species, '.html'], 'w+'); % % open file for writing, delete existing content
  fprintf(oid, '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN">\n');
  fprintf(oid, '%s\n' ,'<HTML>');
  fprintf(oid, '%s\n' ,'  <HEAD>');
  fprintf(oid,['    <TITLE>add-my-pet: results ', speciesprintnm, '</TITLE>\n']);
  fprintf(oid, '%s'   ,'    <META NAME = "keywords" ');
  fprintf(oid, '%s\n' ,'     CONTENT="add-my-pet, Dynamic Energy Budget theory, DEBtool">');
  fprintf(oid, '%s\n' , ' </HEAD>'); 
% ---------------------------------------------------------------------
fprintf(oid, '<FRAMESET BORDER=0 FRAMEBORDER=0 FRAMESPACING=0 cols="150,*">\n');
fprintf(oid, ['<FRAME SRC="i_left_',metaData.species,'.html" NAME="left">\n']);
fprintf(oid, '<FRAMESET BORDER=0 FRAMEBORDER=0 FRAMESPACING=0 rows="100,*">\n');
fprintf(oid, ['<FRAME SRC="i_top_',metaData.species,'.html" NAME="top">\n']);
fprintf(oid, ['<FRAME SRC="results_',metaData.species,'.html" NAME="main">\n']);
fprintf(oid, '</FRAMESET>\n');
fprintf(oid, '  </FRAMESET>\n');
fprintf(oid, '<NOFRAMES>\n');
fprintf(oid, '  <BODY>\n');    
fprintf(oid, ['<A HREF="',metaData.species,'.html"></A>']);    
fprintf(oid, '  </BODY>\n');
% ---------- close i_results_my_pet.html ------------------------   
fprintf(oid, '  </NOFRAMES>\n');
fprintf(oid, '  </HTML>\n');
fclose(oid);

%%% read and write i_top_my_pet:
oid = fopen(['i_top_', metaData.species, '.html'], 'w+'); % % open file for writing, delete existing content
  fprintf(oid, '%s\n' ,'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN">');
  fprintf(oid, '%s\n' ,'<HTML>');
  fprintf(oid, '%s\n' ,'  <HEAD>');
  fprintf(oid,['    <TITLE>add-my-pet: ', speciesprintnm, '</TITLE>\n']);
  fprintf(oid, '%s'   ,'    <META NAME = "keywords" ');
  fprintf(oid, '%s\n' ,'     CONTENT="add-my-pet, Dynamic Energy Budget theory, DEBtool">');
  fprintf(oid, '<LINK REL="stylesheet" TYPE="text/css" HREF="../css/mypet_frame_style.css"> \n'); 
  fprintf(oid, '%s\n' , ' </HEAD>'); 
% ---------------------------------------------------------------------
fprintf(oid, '  <BODY>\n');  
if isfield(metaData.biblist,'Wiki') || isfield(metaData.biblist,'wiki')
url = get_url(metaData.species);
fprintf(oid, ['<p class="specieshead"><A HREF = "',url,'" target = "_blank">',speciesprintnm,'</A>:  ',speciesprintnm_en,' &nbsp;\n']);
else
fprintf(oid, ['<p class="specieshead">',speciesprintnm,': ',speciesprintnm_en,' &nbsp;\n']);
end    
fprintf(oid, '<img src = "../img/bannercycle.png" style="height:50px;">\n');
fprintf(oid, '</p>\n');
fprintf(oid, '  </BODY>\n');
% ---------- close i_top_my_pet.html ------------------------   
fprintf(oid, '  </HTML>\n');
fclose(oid);

%%% read and write i_left_my_pet
oid = fopen(['i_left_', metaData.species, '.html'], 'w+'); % % open file for writing, delete existing content
  fprintf(oid, '%s\n' ,'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN">');
  fprintf(oid, '%s\n' ,'<HTML>');
  fprintf(oid, '%s\n' ,'  <HEAD>');
  fprintf(oid,['    <TITLE>add-my-pet: ', speciesprintnm, '</TITLE>\n']);
  fprintf(oid, '%s'   ,'    <META NAME = "keywords" ');
  fprintf(oid, '%s\n' ,'     CONTENT="add-my-pet, Dynamic Energy Budget theory, DEBtool">');
  fprintf(oid, '<LINK REL="stylesheet" TYPE="text/css" HREF="../css/mypet_frame_style.css"> \n'); 
  fprintf(oid, '%s\n' , ' </HEAD>'); 
% ---------------------------------------------------------------------
fprintf(oid, '  <BODY>\n');    
fprintf(oid, '<BR><BR>');
fprintf(oid, '<BR><BR>');

fprintf(oid, '<P><DIV ALIGN=CENTER VALIGN="top">\n');
fprintf(oid, '<A HREF="../index_species.html" TARGET="_top" onMouseOver="window.status=');
fprintf(oid, ['Close submenu','; return true;">  <IMG SRC="../img/collection.png" WIDTH="110px"  BORDER="0" ALT="Species list"> </A>\n']);
fprintf(oid, '</DIV><BR>\n');
fprintf(oid, '<DIV ALIGN=CENTER VALIGN="top">\n');
fprintf(oid, '<TABLE>\n');
fprintf(oid, ['<TR> <TD style="text-align:center"> <A  class="link" TARGET="_top"  HREF="i_results_',metaData.species,'.html" >  Predictions <BR> & <BR> Data</A></TD></TR>\n']);
fprintf(oid, '<TR> <TD> &nbsp;  </TD> </TR>\n');
fprintf(oid, ['<TR> <TD style="text-align:center" > <A  class="link" TARGET="main"  HREF="',metaData.species,'.html"> Parameters </A></TD></TR>\n']);
fprintf(oid, '<TR> <TD> &nbsp;  </TD> </TR>\n');
fprintf(oid, ['<TR> <TD style="text-align:center" > <A  class="link" TARGET="main"  HREF="',metaData.species,'_stat.html"> Properties </A></TD></TR>\n']);
fprintf(oid, '<TR> <TD> &nbsp;  </TD> </TR>\n');
fprintf(oid, '<TR> <TD> &nbsp;</TD> </TR>\n');
fprintf(oid, ['<TR> <TD style="text-align:center"><A class="link" href = "../entries/',metaData.species,'/mydata_',metaData.species,'.m" target = "main">mydata</A>  </TD></TR>\n']);
fprintf(oid, ['<TR> <TD style="text-align:center"><A class="link" href = "../entries/',metaData.species,'/predict_',metaData.species,'.m" target = "main">predict</A> </TD> </TR>\n']);
fprintf(oid, ['<TR> <TD style="text-align:center"><A class="link" href = "../entries/',metaData.species,'/pars_init_',metaData.species,'.m" target = "main">pars_init</A> </TD> </TR>\n']);
fprintf(oid, ['<TR> <TD style="text-align:center"> &nbsp; </TD> </TR>\n']);
fprintf(oid, ['<TR> <TD style="text-align:center"><A HREF="../entries_zip/',metaData.species,'_zip.zip" TARGET="_top" onMouseOver="window.status=']);
fprintf(oid, ['Close submenu','; return true;">  <IMG SRC="../img/folder.png" WIDTH="110px"  BORDER="0" ALT="DOWNLOAD ZIPPED FOLDER with files"> </A></TD> </TR>\n']);
fprintf(oid, '</TABLE>\n');
fprintf(oid, '</DIV>\n');

fprintf(oid, '  </BODY>\n');
% ---------- close i_left_my_pet.html ------------------------   
fprintf(oid, '  </HTML>\n');
fclose(oid);
