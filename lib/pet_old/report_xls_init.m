%% initializes report_xls

% Warning: language setting in Windows control panel under Formats must be on dutch 
% UK-setting causes Error: Object returned error code: 0x800A03EC
%  because of the : in HYPERLINK (see below at http://www....)
%  the dutch-setting still shows : but with a different ascii code that HYPERLINK understands
 
if exist('file_name', 'var') == 0  % file_name set in pars_my_pets
  file_name = 'Species.xls';
end

if exist('txt_statistics', 'var') == 0
  report_init % get texts for labelling data
end

report_html_init % initiate hmtl reporting parallel to xls

txt_pwd = [pwd, '\']; % path to present directory that should contain file_name
warning off MATLAB:xlswrite:AddSheet

n_spec = 1;  % initiate species numbers
  
%% sheet 1: species_list; initiate file_name
  hyp_add_my_pet = 'http://www.bio.vu.nl/thb/deb/deblab/add_my_pet/'; % used in report_xls
  hyper_data = ['=HYPERLINK("', hyp_add_my_pet, 'add_my_pet.pdf"; "data")'];
  
  hyp_Lifecycles = 'http://www.bio.vu.nl/thb/deb/sheets/cycle_pr_files/v3_document.htm';
  hyper_phylum = ['=HYPERLINK("', hyp_Lifecycles,'"; "phylum")'];
  
  xlswrite(file_name, {hyper_phylum, 'class', 'order', 'family', 'species', 'common name', ...
      'author', 'date', 'author mod.', 'date mod.', 'TYPE', 'FIT', 'COMPLETE', hyper_data},  'species_list', 'A1:N1'); % write header

  % colour header
  excelObj = actxserver('Excel.Application'); %opens up an excel object
  excelWorkbook = excelObj.workbooks.Open([txt_pwd, file_name]);
  excelObj.sheets.Item('species_list').Range('A1:N1').Interior.ColorIndex = 36;
  excelWorkbook.Save;
  excelWorkbook.Close(false);
  excelObj.Quit;
  delete(excelObj);
  
%% sheet 2: primary_parameters
  header = {...
      'species';
      'T, K'; 'T_A, K'; 'T_L, K'; 'T_H, K'; 'T_AL, K'; 'T_AH, K';
       'f, -'; 'z, -'; 'del_M, -'; '{F_m}, l/d.cm^2'; 'kap_X, -'; 'kap_X_P, -'; 
      '{p_Am}, J/d.cm^2'; 'v, cm/d'; 'kap, -'; 'kap_R, -'; 
      '[p_M], J/d.cm^3'; '{p_T}, J/d.cm^2'; 'k_J, 1/d'; '[E_G], J/cm^3'; 
      'E_Hb, J'; 'E_Hj, J'; 'E_Hp, J'; 'h_a, 1/d^2'; 's_G, -';
      'mu_X, J/mol'; 'mu_V, J/mol'; 'mu_E, J/mol'; 'mu_P, J/mol';
      'd_X,  g/cm^3'; 'd_V,  g/cm^3'; 'd_E,  g/cm^3'; 'd_P,  g/cm^3';
      'n_HX, -'; 'n_OX, -'; 'n_NX, -'; 'n_HV, -'; 'n_OV, -'; 'n_NV, -';
      'n_HE, -'; 'n_OE, -'; 'n_NE, -'; 'n_HP, -'; 'n_OP, -'; 'n_NP'};
  
  xlswrite(file_name, header', 'primary_parameters', 'A1:AT1'); % write header 
  
%% sheet 3: statistics

  xlswrite(file_name, [{'species'}; txt_statistics]', 'statistics', 'A1:DR1'); % write header

  % colour, column width and header rotation
  excelObj = actxserver('Excel.Application'); %opens up an excel object
  excelWorkbook = excelObj.workbooks.Open([txt_pwd, file_name]);
  excelObj.sheets.Item('statistics').Range('A:A').ColumnWidth = 20; % species-column is broad
  excelObj.sheets.Item('statistics').Range('A1:DR1').Interior.ColorIndex = 36; % colour header
  excelObj.sheets.Item('statistics').Range('B1:DR1').Orientation = 90; % rotate header primary parameters
  excelWorkbook.Save;
  excelWorkbook.Close(false);
  excelObj.Quit;
  delete(excelObj);
  
%% delete empty sheets 1, 2 and 3 (default addition by Excel)
  % file_name starts with species_list, primary_parameters, statistics, species 1,.,n

  excelObj = actxserver('Excel.Application'); %opens up an excel object
  excelWorkbook = excelObj.workbooks.Open([txt_pwd, file_name]);
  excelObj.sheets.Item(1).Delete; 
  excelObj.sheets.Item(1).Delete;
  excelObj.sheets.Item(1).Delete;
  excelWorkbook.Save;
  excelWorkbook.Close(false);
  excelObj.Quit;
  delete(excelObj);
  
%% Excel cell names

   cell_name = {...
       ' A',' B',' C',' D',' E',' F',' G',' H',' I',' J',' K',' L',' M',' N',' O',' P',' Q',' R',' S',' T',' U',' V',' W',' X',' Y',' Z', ...
       'AA','AB','AC','AD','AE','AF','AG','AH','AI','AJ','AK','AL','AM','AN','AO','AP','AQ','AR','AS','AT','AU','AV','AW','AX','AY','AZ', ...
       'BA','BB','BC','BD','BE','BF','BG','BH','BI','BJ','BK','BL','BM','BN','BO','BP','BQ','BR','BS','BT','BU','BV','BW','BX','BY','BZ', ...
       'CA','CB','CC','CD','CE','CF','CG','CH','CI','CJ','CK','CL','CM','CN','CO','CP','CQ','CR','CS','CT','CU','CV','CW','CX','CY','CZ', ...
       'DA','DB','DC','DD','DE','DF','DG','DH','DI','DJ','DK','DL','DM','DN','DO','DP','DQ','DR','DS','DT','DU','DV','DW','DX','DY','DZ'};