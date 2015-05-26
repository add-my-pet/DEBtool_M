%% print_pet_frames_html
% prints four html pages for each pet

%%
function print_pet_frames_html(metadata)
% created 2015/04/11 Starrlight & Goncalo
% Marques; modified 2015/04/23 Starrlight 

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
% Keep in mind that this function is specifically designed for created the
% webpage of add-my-pet - this function is called when local directory is
% html and when we go one level up it supposes the existance of a
% subdirectory called results ! see 
%<http://www.bio.vu.nl/thb/deb/deblab/add_my_pet/art/websitemaintenance.html *maintanance webpage*>

%% Example of use
% load('results_my_pet.mat');
% print_pet_frames_html(metadata)


% Removes underscores and makes first letter of english name be
% in capital:
speciesprintnm = strrep(metadata.species, '_', ' ');

speciesprintnm_en = strrep(metadata.species_en, '_', ' ');
if speciesprintnm_en(1)>='a' && speciesprintnm_en(1)<='z'
  speciesprintnm_en(1)=char(speciesprintnm_en(1)-32);
end
% ------------------------------------------------------------


%%% read and write i_my_pet
oid = fopen(['i_', metadata.species, '.html'], 'w+'); % % open file for writing, delete existing content
  fprintf(oid, '%s\n' ,'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN">');
  fprintf(oid, '%s\n' ,'<HTML>');
  fprintf(oid, '%s\n' ,'  <HEAD>');
  fprintf(oid,['    <TITLE>add-my-pet: ', speciesprintnm, '</TITLE>\n']);
  fprintf(oid, '%s'   ,'    <META NAME = "keywords" ');
  fprintf(oid, '%s\n' ,'     CONTENT="add-my-pet, Dynamic Energy Budget theory, DEBtool">');
  fprintf(oid, '%s\n' , ' </HEAD>'); 
% ---------------------------------------------------------------------
fprintf(oid, '<FRAMESET BORDER=0 FRAMEBORDER=0 FRAMESPACING=0 cols="150,*">\n');
fprintf(oid, ['<FRAME SRC="i_left_',metadata.species,'.html" NAME="left">\n']);
fprintf(oid, '<FRAMESET BORDER=0 FRAMEBORDER=0 FRAMESPACING=0 rows="100,*">\n');
fprintf(oid, ['<FRAME SRC="i_top_',metadata.species,'.html" NAME="top">\n']);
fprintf(oid, ['<FRAME SRC="../html/',metadata.species,'.html" NAME="main">\n']);
fprintf(oid, '</FRAMESET>\n');
fprintf(oid, '  </FRAMESET>\n');
fprintf(oid, '<NOFRAMES>\n');
fprintf(oid, '  <BODY>\n');    
fprintf(oid, ['<A HREF="../html/',metadata.species,'.html"></A>']);    
fprintf(oid, '  </BODY>\n');
% ---------- close i_my_pet.html ------------------------   
fprintf(oid, '  </NOFRAMES>\n');
fprintf(oid, '  </HTML>\n');
fclose(oid);

%%% read and write i_results_my_pet
oid = fopen(['i_results_', metadata.species, '.html'], 'w+'); % % open file for writing, delete existing content
  fprintf(oid, '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN">\n');
  fprintf(oid, '%s\n' ,'<HTML>');
  fprintf(oid, '%s\n' ,'  <HEAD>');
  fprintf(oid,['    <TITLE>add-my-pet: results ', speciesprintnm, '</TITLE>\n']);
  fprintf(oid, '%s'   ,'    <META NAME = "keywords" ');
  fprintf(oid, '%s\n' ,'     CONTENT="add-my-pet, Dynamic Energy Budget theory, DEBtool">');
  fprintf(oid, '%s\n' , ' </HEAD>'); 
% ---------------------------------------------------------------------
fprintf(oid, '<FRAMESET BORDER=0 FRAMEBORDER=0 FRAMESPACING=0 cols="150,*">\n');
fprintf(oid, ['<FRAME SRC="i_left_',metadata.species,'.html" NAME="left">\n']);
fprintf(oid, '<FRAMESET BORDER=0 FRAMEBORDER=0 FRAMESPACING=0 rows="100,*">\n');
fprintf(oid, ['<FRAME SRC="i_top_',metadata.species,'.html" NAME="top">\n']);
fprintf(oid, ['<FRAME SRC="../results/results_',metadata.species,'.html" NAME="main">\n']);
fprintf(oid, '</FRAMESET>\n');
fprintf(oid, '  </FRAMESET>\n');
fprintf(oid, '<NOFRAMES>\n');
fprintf(oid, '  <BODY>\n');    
fprintf(oid, ['<A HREF="../html/',metadata.species,'.html"></A>']);    
fprintf(oid, '  </BODY>\n');
% ---------- close i_results_my_pet.html ------------------------   
fprintf(oid, '  </NOFRAMES>\n');
fprintf(oid, '  </HTML>\n');
fclose(oid);

%%% read and write i_top_my_pet:
oid = fopen(['i_top_', metadata.species, '.html'], 'w+'); % % open file for writing, delete existing content
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
fprintf(oid, ['<p class="specieshead">',speciesprintnm,':  ',speciesprintnm_en,' &nbsp;\n']);
fprintf(oid, '<img src = "../img/bannercycle.png" style="height:50px;">\n');
fprintf(oid, '</p>\n');
fprintf(oid, '  </BODY>\n');
% ---------- close i_top_my_pet.html ------------------------   
fprintf(oid, '  </HTML>\n');
fclose(oid);


%%% rad and write i_left_my_pet
oid = fopen(['i_left_', metadata.species, '.html'], 'w+'); % % open file for writing, delete existing content
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
fprintf(oid, ['Close submenu','; return true;">  <IMG SRC="../img/collection.png" WIDTH="110px"  BORDER="0" ALT="*"> </A>\n']);
fprintf(oid, '</DIV><BR>\n');
fprintf(oid, '<DIV ALIGN=CENTER VALIGN="top">\n');
fprintf(oid, '<TABLE>\n');
fprintf(oid, ['<TR> <TD style="text-align:center" > <A  class="link" TARGET="_top"  HREF="i_',metadata.species,'.html"> Properties <BR> & <BR> Parameters </A></TD></TR>\n']);
fprintf(oid, '<TR> <TD> &nbsp;  </TD> </TR>\n');
fprintf(oid, ['<TR> <TD style="text-align:center"> <A  class="link" TARGET="_top"  HREF="i_results_',metadata.species,'.html" >  Predictions <BR> & <BR> Data</A></TD></TR>\n']);
fprintf(oid, '<TR> <TD> &nbsp;  </TD> </TR>\n');
fprintf(oid, '<TR> <TD> &nbsp;</TD> </TR>\n');
fprintf(oid, ['<TR> <TD style="text-align:center"><A class="link" href = "../mydata/mydata_',metadata.species,'.m" target = "_blank">mydata</A>  </TD></TR>\n']);
fprintf(oid, ['<TR> <TD style="text-align:center"><A class="link" href = "../predict/predict_',metadata.species,'.m" target = "_blank">predict</A> </TD> </TR>\n']);
fprintf(oid, ['<TR> <TD style="text-align:center"><A class="link" href = "../parsinit/pars_init_',metadata.species,'.m" target = "_blank">pars_init</A> </TD> </TR>\n']);
cd ../results % go up one level and then to add-my-pet/results
if exist(['results_',metadata.species,'.m'], 'file') % check and see if there is a cusumised results_my_pet.m file
fprintf(oid, ['<TR> <TD style="text-align:center"><A class="link" href = "../results/results_',metadata.species,'.m" target = "_blank">results</A> </TD> </TR>\n']); % if there is then make a link to it
end
cd ../html % go up one level and back to the html subdirectory
fprintf(oid, '<TR> <TD style="text-align:center"><A class="link" href = "../mat/" target = "_blank"> mat file </A>  </TR> \n');
fprintf(oid, '</TABLE>\n');
fprintf(oid, '</DIV>\n');

fprintf(oid, '  </BODY>\n');
% ---------- close i_left_my_pet.html ------------------------   
fprintf(oid, '  </HTML>\n');
fclose(oid);
