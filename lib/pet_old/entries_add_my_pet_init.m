function info = entries_add_my_pet_init
  %  creates scripts report_xls_init, and report_xls
  %  in preparation for use by shentries_ad_my_pet

  info = 1;
  
  % check that creation of files gives no problems
  if exist('report_animal') == 1 || ...
     exist('report_xls_init') == 1 || ...
     exist('report_xls') == 1 || ...
     exist('report_xls_close') == 1
    fprintf('report already exists \n');
    info = 0;
    return
  elseif exist('pars_my_pets') == 0
    fprintf('pars_my_pets does not exist \n');
    info = 0;
    return
  end   
    
  % create report_xls_init
  fid = fopen('report_xls_init.m', 'w+'); % open file for writing
  fprintf(fid, 'parscomp = []; statistics = []; report_animal = []; report_xls_close = [];');
  fclose(fid);

  % create report_xls
  fid = fopen('report_xls.m', 'w+'); % open file for writing
  fprintf(fid, 'dates = [dates; datenum(date)];');
  fclose(fid);