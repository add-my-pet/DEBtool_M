%% init report_html
% clear and create file Species.html in current directory
% clear and create files primary_parameters.html, statistics.html in subdirectory html
% write headers and open tables in these 3 files
% this script is called at start of report_xls_init
% files must be completed by report_html_close

  report_init % set texts
  
%% Species.html

  hyp_Lifecycles = 'http://www.bio.vu.nl/thb/deb/sheets/cycle_pr_files/v3_document.htm';

  fid_Spec = fopen('Species.html', 'w+'); % open file for writing, delete existing content
  fprintf(fid_Spec, '<HTML>\n');
  fprintf(fid_Spec, '  <HEAD>\n');
  fprintf(fid_Spec, '    <TITLE>Species</TITLE>\n');
  fprintf(fid_Spec, '    <META NAME = "keywords" CONTENT="add_my_pet, Dynamic Energy Budget theory, DEBtool">\n');
  fprintf(fid_Spec, '    <style type="text/css">\n');
  fprintf(fid_Spec, '       #rot{width:10px; height:35px; transform:rotate(-90deg); -moz-transform:rotate(-90deg); text-align:left}\n');
  fprintf(fid_Spec, '    </style>\n');
  fprintf(fid_Spec, '  </HEAD>\n');
  fprintf(fid_Spec, '  <BODY>\n');
  fprintf(fid_Spec, '    <H1 ALIGN="CENTER">Add_my_pet: species list </H1>\n\n');
  fprintf(fid_Spec, '    <H3 ALIGN="CENTER">Go to \n'); 
  fprintf(fid_Spec, '      <A HREF="./add_my_pet.pdf">manual, </A>\n');
  fprintf(fid_Spec, '      <A HREF="./html/primary_parameters.html">primary_parameters, </A>\n');
  fprintf(fid_Spec, '      <A HREF="./html/statistics.html">statistics, </A>\n');
  fprintf(fid_Spec, '      <A HREF="http://www.bio.vu.nl/thb/deb/deblab/">DEBlab</A></H3>\n\n');
  fprintf(fid_Spec, '    <TABLE>\n');
  fprintf(fid_Spec, '      <TR HEIGHT=150 BGCOLOR = "#FFE7C6">\n');
  fprintf(fid_Spec,['        <TH><A HREF = "', hyp_Lifecycles, '" TARGET = "_top">phylum</A></TH>\n']);
  fprintf(fid_Spec, '        <TH>class</TH> <TH>order</TH> <TH>family</TH>\n');
  fprintf(fid_Spec, '        <TH>species</TH> <TH>common name</TH>\n');
  fprintf(fid_Spec, '        <TH>author</TH> <TH>date</TH> <TH>author mod.</TH> <TH>date mod.</TH>\n');
  fprintf(fid_Spec, '        <TH BGCOLOR = "#FFC6A5"><div id="rot">TYPE</div></TH> <TH BGCOLOR = "#FFE7C6"><div id="rot">FIT</div></TH> <TH BGCOLOR = "#FFCE9C"><div id="rot">COMPLETE</div></TH>\n');
  fprintf(fid_Spec, '        <TH BGCOLOR = "#FFFFC6"><A HREF = "add_my_pet.pdf">data</A></TH>\n');
  fprintf(fid_Spec, '      </TR>\n');
    
%% primary_parameters.html

  fid_par = fopen('./html/primary_parameters.html', 'w+'); % open file for writing, delete existing content
  fprintf(fid_par, '<HTML>\n');
  fprintf(fid_par, '  <HEAD>\n');
  fprintf(fid_par, '    <TITLE>primary_parameters</TITLE>\n');
  fprintf(fid_par, '    <META NAME = "keywords" CONTENT="add_my_pet, Dynamic Energy Budget theory, DEBtool">\n');
  fprintf(fid_par, '  </HEAD>\n');
  fprintf(fid_par, '  <BODY>\n\n');
  fprintf(fid_par, '    <H1 ALIGN="CENTER">Add_my_pet: primary parameters </H1>\n\n');
  fprintf(fid_par, '    <H3 ALIGN="CENTER">Go to \n'); 
  fprintf(fid_par, '      <A HREF="../Species.html">species-list, </A>\n');
  fprintf(fid_par, '      <A HREF="statistics.html">statistics</A></H3>\n\n');
  fprintf(fid_par, '    <TABLE>\n');
  fprintf(fid_par, '      <TR>\n');
  fprintf(fid_par, '        <TH BGCOLOR = "#FFE7C6">species</TH>\n        ');
  for i = 1:n_par_primary
    fprintf(fid_par, '<TH BGCOLOR = "%s">%s</TH> ', col_par_primary{i}, txt_sym_primary{i});     
  end
  fprintf(fid_par, '\n      </TR>\n');
  
%% statistics.html

  n_statistics = size(txt_statistics,1);
  
  fid_stat = fopen('./html/statistics.html', 'w+'); % open file for writing, delete existing content
  fprintf(fid_stat, '<HTML>\n');
  fprintf(fid_stat, '  <HEAD>\n');
  fprintf(fid_stat, '    <TITLE>statistics</TITLE>\n');
  fprintf(fid_stat, '    <META NAME = "keywords" CONTENT="add_my_pet, Dynamic Energy Budget theory, DEBtool">\n');
  fprintf(fid_stat, '    <style type="text/css">\n');
  fprintf(fid_stat, '       #rot{width:150px; height:150px; word-wrap: break-word; transform:rotate(-90deg); -moz-transform:rotate(-90deg); text-align:left}\n');
  fprintf(fid_stat, '    </style>\n');
  fprintf(fid_stat, '  </HEAD>\n');
  fprintf(fid_stat, '  <BODY>\n');
  fprintf(fid_stat, '    <H1 ALIGN="CENTER">Add_my_pet: statistics </H1>\n');
  fprintf(fid_stat, '    <H3 ALIGN="CENTER">Go to \n'); 
  fprintf(fid_stat, '      <A HREF="../Species.html">species-list, </A>\n');
  fprintf(fid_stat, '      <A HREF="primary_parameters.html">primary_parameters</A></H3>\n\n');
  fprintf(fid_stat, '    <TABLE>\n');
  fprintf(fid_stat, '      <TR HEIGHT=200 BGCOLOR = "#FFE7C6">\n');
  fprintf(fid_stat, '        <TH BGCOLOR = "#FFE7C6">species</TH>\n');
  for i = 1:n_statistics
    fprintf(fid_stat, '        <TH BGCOLOR = "%s"><div id="rot">%s</div></TH>\n' , col_statistics{i}, txt_statistics{i});
  end
  fprintf(fid_stat, '      </TR>\n');
