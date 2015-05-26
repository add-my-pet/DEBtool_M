%% add_my_pet(species, species_next)
% Adds a species to the collection

%%
function add_my_pet(species, species_next)
% created by Bas Kooijman at 2014/03/19
%
%% Syntax
% add_my_pet(species, species_next)

%% Description
% adds a spieces-content to 
%
%     Species.xls (single row first 3 sheets and appending a sheet)
%     Species.html (single row)
%     /html/primary_parameters.html (single row)
%     /html/statistics.html (single row)
%     /html/my_pet.html (new file)
%
% first insert blank lines in first 3 sheets of Species.xls before running this script
% cf: refresh_my_pet for updating the content of a species
%
% To add a species to the collection:
% 1) write a mydata- and a predict-file in subdir add_my_pet/mydata/new
% 2) write a pars-file in subdir add_my_pet/mydata/new
% 3) move pars-file to top dir add_my_pet and add species name to add_my_pet/pars_my_pets.m
% 4) move mydata- and predict-file to subdir add_my_pet/mydata
% 5) out-comment estimation in mydata and run: 
%       options.showCode = false; publish('mydata_my_pet', options);
% 6a) remove Species.xls from top dir and run pars_my_pets (takes several hours)
% 6b) insert blank lines in first 3 sheets of Species.xls and run this function
% 7) copy whole add_my_pet directory to central and run in that directory: chmod -R ugo+rx *
% 8) goto web/deb/deblab/add_my_pet and run:
%       yes | cp -r pwd/add_my_pet/* .
% 9) edit update date in web/deb/deblab/index_main.html
%  
% Primary utilities
%
%   plot number of entries against time with shentries_add_my_pet
%   list authors with shauthors_add_my_pet
%   plot primary parameters with shprimairy_parameters
%   plot functions of parameters with shparameters
%
% Input
%
% * species: character string with latin name of species
% * species_next: character string with latin name of the following species in the list of species


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

  %% check that species to be added actually exists
  if exist(['pars_', species, '.m'], 'file') == 0
    fprintf([species, ' not found\n']);
    return
  end

  if 0 % xls, insert rows in Species.xls, but does not work, so you have to you this in Excel by hand
  
    excelObj = actxserver('Excel.Application'); %opens up an excel object
    excelWorkbook = excelObj.workbooks.Open([pwd, '\Species.xls']);
  
    excelObj.sheets.Item('species_list').Rows('2').Insert;

    excelWorkbook.Save;         % save font change
    excelWorkbook.Close(false); % closes excel object
    excelObj.Quit;
    delete(excelObj);
    
  end
  
  %% open 3 html files for reading and writing and opisition writing head
  
  % Species.html
  fid_Spec = fopen('Species.html', 'r+'); % open file for reading 
  Spec     = fread(fid_Spec);             % read Species: column vector of binaries
  nid_Spec = length(Spec);                % file size
  %
  in_Spec = strfind(Spec', species_next); 
  if isempty(in_Spec) % check that species after added species actually exists
     fprintf([species_next, ' not found\n']);
     fclose(fid_Spec);
     return
  end
  %
  in_Spec = in_Spec(1); % select first occurence, next one concerns link
  in_Spec = strfind(Spec(1:in_Spec)', '<TR>'); % find last <TR>
  n_spec = length(in_Spec);   % row number in first 3 sheets of Species.xls before the one at which species needs to be added
  % check for empty rows in Species.xls (actually only check for empty first column)
  txt_n = num2str(1 + n_spec);
  [x name_1]  = xlsread(file_name, 1, ['A', txt_n, ':A', txt_n]); % read phylum name
  [x name_2]  = xlsread(file_name, 2, ['A', txt_n, ':A', txt_n]); % read species name
  [x name_3]  = xlsread(file_name, 3, ['A', txt_n, ':A', txt_n]); % read species name
  if ~isempty(name_1) 
     fprintf(['row ', txt_n, ' of species_list of Species.xls is not empty\n'])
     return
  elseif ~isempty(name_2) 
     fprintf(['row ', txt_n, ' of primary_parameters of Species.xls is not empty\n'])
     return
  elseif ~isempty(name_3) 
     fprintf(['row ', txt_n, ' of statistics of Species.xls is not empty\n'])
     return
  end
  %
  in_Spec = in_Spec(end) - 1; % index of end of previous species
  frewind(fid_Spec);          % reset current position
  fread(fid_Spec, in_Spec);   % set position on in_Spec 
  fseek(fid_Spec, 0, 'cof');  % prepare for wrting at position in_Spec
   
  % primary_parameters.html
  fid_par = fopen('./html/primary_parameters.html', 'r+'); % open file for reading
  Par = fread(fid_par); % read primary_parameters (comlumn vector of binaries)
  nid_Par = length(Par);    % file size of Par
  in_Par = strfind(Par', species_next); in_Par = in_Par(1);
  in_Par = strfind(Par(1:in_Par)', '<TR>'); 
  in_Par = in_Par(end) - 1; % index of end of previous species
  frewind(fid_par);         % reset current position
  fread(fid_par, in_Par);   % set position on in_Par
  fseek(fid_par, 0, 'cof'); % prepare for wrting at position in_Par
   
  % statistics.html
  fid_stat = fopen('./html/statistics.html', 'r+'); % open file for reading
  Stat = fread(fid_stat);
  nid_Stat = length(Stat);    % file size of Stat
  in_Stat = strfind(Stat', species_next); in_Stat = in_Stat(1);
  in_Stat = strfind(Stat(1:in_Stat)', '<TR>'); 
  in_Stat = in_Stat(end) - 1; % index of end of previous species
  frewind(fid_stat);          % reset current position
  fread(fid_stat, in_Stat);   % set position on in_Stat
  fseek(fid_stat, 0, 'cof');  % prepare for wrting at position in_Stat

  eval(['pars_', species]);  % write species that is added

  % write trailing species to the 3 html files
  in_span = 1000; % writing problems for large strings
  fseek(fid_Spec, 0, 'cof'); % prepare for wrting at position in_Par
  while in_Spec <= nid_Spec
    fprintf(fid_Spec, char(Spec(in_Spec: min(nid_Spec, in_Spec + in_span - 1))'));
    in_Spec = in_Spec + in_span;
  end
  fclose(fid_Spec);
  %
  fseek(fid_par, 0, 'cof'); % prepare for wrting at position in_Par
  while in_Par <= nid_Par
    fprintf(fid_par, char(Par(in_Par: min(nid_Par, in_Par + in_span - 1))'));
    in_Par = in_Par + in_span;
  end
  fclose(fid_par);
  %
  fseek(fid_stat, 0, 'cof'); % prepare for wrting at position in_Par
  while in_Stat <= nid_Stat
    fprintf(fid_stat, char(Stat(in_Stat: min(nid_Stat, in_Stat + in_span - 1))'));
    in_Stat = in_Stat + in_span;
  end
  fclose(fid_stat);
