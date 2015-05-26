%% open_species_html
% opens up species.html for reading and writing

%% 
function fid_Spec = open_species_html
% originally created by Bas Kooiman; modified 2015/04/14 Starrlight

%% Syntax
% fid_Spec = <../open_species_html.m *open_species_html*> 

%% Description
%
% Output:
% 
% * fid_Spec: scalar

%% Remarks
% This deletes the existing species.html

%% Example of use
% fid_Spec = open_species_html




% if exist('n_spec','var')==0
%   n_spec = 1;  % initiate species numbers

  fid_Spec = fopen('species.html', 'w+'); % open file for writing, delete existing content
  fprintf(fid_Spec, '<HTML>\n');
  fprintf(fid_Spec, '  <HEAD>\n');
  fprintf(fid_Spec, '    <TITLE>Species</TITLE>\n');
  fprintf(fid_Spec, '    <META NAME = "keywords" CONTENT="add_my_pet, Dynamic Energy Budget theory, DEBtool">\n');

% ------------ style sheets and java script function ---------------------
  fprintf(fid_Spec,'<script type="text/javascript" src="sys/boxmodal.js"></script>'); 
  fprintf(fid_Spec, '<link rel="stylesheet" type="text/css" href="css/collectionstyle.css">'); 
% ------------------------------------------------------------------------

  fprintf(fid_Spec, '  </HEAD>\n');
  fprintf(fid_Spec, '  <BODY>\n');
  fprintf(fid_Spec, '    <BR><TABLE>\n');
  fprintf(fid_Spec, '      <TR HEIGHT=60 BGCOLOR = "#FFE7C6">\n');
  fprintf(fid_Spec,'        <TH><a class="link" href="#" onclick="BoxArt_phylum();">phylum</a></TH>\n');
  
  fprintf(fid_Spec, '        <TH>class</TH> <TH>order</TH> <TH>family</TH>\n');
  fprintf(fid_Spec, '        <TH>species</TH> <TH>common name</TH>\n');
  fprintf(fid_Spec, '    <TH BGCOLOR = "#FFC6A5"><a class="link" href="#" onclick="BoxArt_type();">&nbsp; type &nbsp;</a></TH>\n');
  fprintf(fid_Spec, '    <TH BGCOLOR = "#FFE7C6"><a class="link" href="#" onclick="BoxArt_fit();"> &nbsp; MRE &nbsp;</a></TH>\n') ;
  fprintf(fid_Spec, '    <TH BGCOLOR = "#FFCE9C"><a class="link" href="#" onclick="BoxArt_complete();">&nbsp; complete &nbsp;</a></TH>\n');
  fprintf(fid_Spec, '    <TH BGCOLOR = "#FFFFC6"><a class="link" href="#" onclick="BoxArt_data();">&nbsp; data &nbsp;</a></TH>\n');
  fprintf(fid_Spec, '      </TR>\n');

