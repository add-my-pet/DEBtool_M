function refresh_my_pet(species)
%
%% Description
%  changes a spieces-content to 
%     Species.xls (single row first 3 sheets and overwriting a species-sheet)
%     Species.html (single row)
%     /html/primary_parameters.html (single row)
%     /html/statistics.html (single row)
%     /html/my_pet.html (replace existing file)
% cf add_my_pet for adding a species, rather than updating it
  
  % selected copy-paste from report_xls_init
  file_name = 'Species'; % name of xls-file that serves as output
  txt_pwd = [pwd, '\'];
  hyp_add_my_pet = 'http://www.bio.vu.nl/thb/deb/deblab/add_my_pet/'; % used in report_xls
  hyper_data = ['=HYPERLINK("', hyp_add_my_pet, 'add_my_pet.pdf"; "data")'];
  hyp_Lifecycles = 'http://www.bio.vu.nl/thb/deb/sheets/cycle_pr_files/v3_document.htm';
  hyper_phylum = ['=HYPERLINK("', hyp_Lifecycles,'"; "phylum")'];
  cell_name = {...
    ' A',' B',' C',' D',' E',' F',' G',' H',' I',' J',' K',' L',' M',' N',' O',' P',' Q',' R',' S',' T',' U',' V',' W',' X',' Y',' Z', ...
    'AA','AB','AC','AD','AE','AF','AG','AH','AI','AJ','AK','AL','AM','AN','AO','AP','AQ','AR','AS','AT','AU','AV','AW','AX','AY','AZ', ...
    'BA','BB','BC','BD','BE','BF','BG','BH','BI','BJ','BK','BL','BM','BN','BO','BP','BQ','BR','BS','BT','BU','BV','BW','BX','BY','BZ', ...
    'CA','CB','CC','CD','CE','CF','CG','CH','CI','CJ','CK','CL','CM','CN','CO','CP','CQ','CR','CS','CT','CU','CV','CW','CX','CY','CZ', ...
    'DA','DB','DC','DD','DE','DF','DG','DH','DI','DJ','DK','DL','DM','DN','DO','DP','DQ','DR','DS','DT','DU','DV','DW','DX','DY','DZ'};

  report_init
  n_statistics = size(txt_statistics,1); 

  %% check that species to be refreshed actually exists
  if exist(['pars_', species, '.m'], 'file') == 0
    fprintf([species, ' not found\n']);
    return
  end

  %% open 3 html files for reading and writing and opisition writing head
  
  % Species.html
  fid_Spec = fopen('Species.html', 'r+'); % open file for reading 
  Spec     = fread(fid_Spec);             % read Species.html
  nid_Spec = length(Spec);                % file size
  %
  in_Spec = strfind(Spec', species); 
  if isempty(in_Spec) % check that species entry actually exists
     fprintf([species, ' not found\n']);
     fclose(fid_Spec);
     return
  end
  %
  in_Spec = in_Spec(1); % select first occurence, next one concerns link
  in_Spec = strfind(Spec(1:in_Spec)', '<TR>'); % find last <TR>
  n_spec = length(in_Spec);   % row number in first 3 sheets of Species.xls before the one at which species needs to be added
  in_Spec = in_Spec(end) - 1; % index of end of previous species
  in_Spec_end = strfind(Spec(in_Spec:end)', '</TR>'); in_Spec_end = in_Spec + in_Spec_end(1) + 5;  % index of start next species
  frewind(fid_Spec);          % reset current position
  fread(fid_Spec, in_Spec);   % set position on in_Spec 
  fseek(fid_Spec, 0, 'cof');  % prepare for wrting at position in_Spec
   
  % primary_parameters.html
  fid_par = fopen('./html/primary_parameters.html', 'r+'); % open file for reading
  Par = fread(fid_par);
  nid_Par = length(Par);    % file size of Par
  in_Par = strfind(Par', species); in_Par = in_Par(1);
  in_Par = strfind(Par(1:in_Par)', '<TR>'); 
  in_Par = in_Par(end) - 1; % index of end of previous species
  in_Par_end = strfind(Par(in_Par:end)', '</TR>'); in_Par_end = in_Par + in_Par_end(1) + 5;  % index of start next species
  frewind(fid_par);         % reset current position
  fread(fid_par, in_Par);   % set position on in_Par
  fseek(fid_par, 0, 'cof'); % prepare for wrting at position in_Par
   
  % statistics.html
  fid_stat = fopen('./html/statistics.html', 'r+'); % open file for reading
  Stat = fread(fid_stat);
  nid_Stat = length(Stat);    % file size of Stat
  in_Stat = strfind(Stat', species); in_Stat = in_Stat(1);
  in_Stat = strfind(Stat(1:in_Stat)', '<TR>'); 
  in_Stat = in_Stat(end) - 1; % index of end of previous species
  in_Stat_end = strfind(Stat(in_Stat:end)', '</TR>'); in_Stat_end = in_Stat + in_Stat_end(1) + 5;  % index of start next species
  frewind(fid_stat);          % reset current position
  fread(fid_stat, in_Stat);   % set position on in_Stat
  fseek(fid_stat, 0, 'cof');  % prepare for wrting at position in_Stat

 
  eval(['pars_', species]);  % write species that is added
  
  % write trailing species to the 3 html files
  in_span = 1000; % writing problems for large strings
  in_Spec = in_Spec_end;
  while in_Spec <= nid_Spec
    fprintf(fid_Spec, char(Spec(in_Spec: min(nid_Spec, in_Spec + in_span - 1))'));
    in_Spec = in_Spec + in_span;
  end
  fclose(fid_Spec);
  %
  in_Par = in_Par_end;
  while in_Par <= nid_Par
    fprintf(fid_par, char(Par(in_Par: min(nid_Par, in_Par + in_span - 1))'));
    in_Par = in_Par + in_span;
  end
  fclose(fid_par);
  %
  in_Stat = in_Stat_end;
  while in_Stat <= nid_Stat
    fprintf(fid_stat, char(Stat(in_Stat: min(nid_Stat, in_Stat + in_span - 1))'));
    in_Stat = in_Stat + in_span;
  end
  fclose(fid_stat);
