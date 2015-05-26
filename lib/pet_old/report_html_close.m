%% complete and close Species.html, primary_parameters.html, statistics.html, 
% 2012/10/26 created by Bas Kooijman

  fprintf(fid_Spec, '%s\n' , '    </TABLE>');
  fprintf(fid_Spec, '%s\n\n' , '  </BODY>');
  fprintf(fid_Spec, '%s\n' , '</HTML>');
  fclose(fid_Spec);

  fprintf(fid_par, '%s\n' , '    </TABLE>');
  fprintf(fid_par, '%s\n\n' , '  </BODY>');
  fprintf(fid_par, '%s\n' , '</HTML>');
  fclose(fid_par);

  fprintf(fid_stat, '%s\n\n' , '    </TABLE>');
  fprintf(fid_stat, '%s\n' , '  </BODY>');
  fprintf(fid_stat, '%s\n' , '</HTML>');
  fclose(fid_stat);
