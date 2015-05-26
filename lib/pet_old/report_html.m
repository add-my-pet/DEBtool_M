%% report_html
% clear and create file my_pet.html in subdirectory html and write data to it
% append data to Species.html in current directory
% append data to primary_parameters.html and statistics.html in subdirectory html
% this script is called at start of report_xls and assumes that report_html_init has been run previously
% files must be completed by report_html_close

%% Species.html

  n_data_0 = size(data_0,1); n_data_1 = size(data_1,1); 
  
  fprintf(fid_Spec, '      <TR>\n');
  fprintf(fid_Spec,['        <TD>', phylum, '</TD>  <TD>', class, '</TD> <TD>', order, '</TD> <TD>', family, '</TD> ']);
  fprintf(fid_Spec,['<TD><A HREF="./html/', species, '.html">', species, '</A></TD> <TD>', species_en, '</TD> ']);
  fprintf(fid_Spec,['<TD>', txt_author, '</TD> <TD>', txt_date, '</TD> ']);
  fprintf(fid_Spec,['<TD>', txt_author_mod, '</TD> <TD>', txt_date_mod, '</TD> ']);
  fprintf(fid_Spec, '<TD BGCOLOR = "#FFC6A5">%g</TD> ', TYPE);
  fprintf(fid_Spec, '<TD BGCOLOR = "#FFE7C6">%g</TD> ', FIT);
  fprintf(fid_Spec, '<TD BGCOLOR = "#FFCE9C">%g</TD>\n        ', COMPLETE);
  for i = 1:n_data_0
    fprintf(fid_Spec, '<TD BGCOLOR = "#FFFFC6">%s</TD> ', data_0{i});      
  end
  for i = 1:n_data_1
    fprintf(fid_Spec, '<TD BGCOLOR = "#FFFF9C">%s</TD>', data_1{i});  
  end
  fprintf(fid_Spec, '\n      </TR>\n');

%% primary_parameters.html
 
  % sequence of par_prim equals that of header in report_html_init and in report_xls_init
  % present rates at reference temperature
  par_primary = [ ...
      T; T_A; T_L; T_H; T_AL; T_AH;
      f; z; del_M; FT_m; kap_X; kap_X_P;
      p_Am; v; kap; kap_R; p_M; p_T; k_J; E_G;
      E_Hb; E_Hj; E_Hp; h_a; s_G;
      mu_X; mu_V; mu_E; mu_P;
      d_O;
      n_O(2:4,1); n_O(2:4,2);
      n_O(2:4,3); n_O(2:4,4)];

  n_par_primary = size(par_primary,1);
  
  fprintf(fid_par,  '      <TR>\n');
  fprintf(fid_par, ['        <TD><A HREF="./', species, '.html">', species, '</A></TD>\n']);
  for i = 1:n_par_primary
    fprintf(fid_par,'        <TD BGCOLOR = "%s">%g</TD> ', col_par_primary{i}, par_primary(i));
  end  
  fprintf(fid_par,'\n      </TR>\n');

%% statistics.html

  fprintf(fid_stat, '      <TR>\n');
  fprintf(fid_stat, ['        <TD><A HREF="./', species, '.html">', species, '</A></TD>\n        ']);
  for i = 1:n_statistics
    fprintf(fid_stat, '<TD BGCOLOR = "%s">%g</TD> ', col_statistics{i}, val_statistics(i));
  end  
  fprintf(fid_stat, '      </TR>\n');

%% my_pet.html

  oid = fopen(['./html/', species, '.html'], 'w+'); % % open file for writing, delete existing content
  fprintf(oid, '%s\n' ,'<HTML>');
  fprintf(oid, '%s\n' ,'  <HEAD>');
  fprintf(oid,['    <TITLE>add_my_pet:', species, '</TITLE>\n']);
  fprintf(oid, '%s'   ,'    <META NAME = "keywords" ');
  fprintf(oid, '%s\n' ,'     CONTENT="add_my_pet, Dynamic Energy Budget theory, DEBtool">');
  fprintf(oid, '%s\n' ,'  </HEAD>');
  fprintf(oid,'%s\n\n','  <BODY>');
  fprintf(oid,['    <H1 ALIGN="CENTER">', species, ': ', species_en, '</H1>\n\n']);
  fprintf(oid, '    <H3 ALIGN="CENTER">Go to <A HREF="../Species.html">species-list</A>, \n'); 
  fprintf(oid,['                             <A HREF="../pars_', species, '.m">pars</A>, \n']);
  fprintf(oid,['                             <A HREF="../mydata/mydata_',  species, '.m">mydata</A>, \n']);
  fprintf(oid,['                             <A HREF="../mydata/predict_', species, '.m">predict</A>, \n']);
  fprintf(oid,['                             <A HREF="../mydata/html/mydata_', species, '.html">fit</A><H3>\n\n']);
  fprintf(oid, '  <TABLE CELLSPACING=50><TR VALIGN=TOP><TD>\n');
  fprintf(oid, '    <TABLE>\n');
  fprintf(oid, '      <TR BGCOLOR = "#FFE7C6"> <TH>statistic</TH> <TH>value at T</TH> </TR>\n');
  for i = 1: n_statistics
    fprintf(oid, '      <TR><TD BGCOLOR = "%s">%s</TD> <TD BGCOLOR = "%s">%g</TD></TR>\n', col_statistics{i}, txt_statistics{i}, col_statistics{i}, val_statistics(i));
  end
  fprintf(oid, '    </TABLE>\n');
  fprintf(oid, '  </TD><TD>\n');
  fprintf(oid, '    <TABLE>\n');
  fprintf(oid, '      <TR BGCOLOR = "#FFE7C6"> <TH>parameter</TH> <TH>value  at T_ref</TH> </TR>\n');
  for i = 1: n_par_primary
    fprintf(oid, '      <TR><TD BGCOLOR = "%s">%s</TD> <TD BGCOLOR = "%s">%g</TD></TR>\n', col_par_primary{i}, txt_par_primary{i}, col_par_primary{i}, par_primary(i));
  end  
  fprintf(oid, '    </TABLE>\n');  
  fprintf(oid, '  </TD></TABLE>\n');  
  fprintf(oid, '  </BODY>\n');
  fprintf(oid, '</HTML>\n');
  fclose(oid);
