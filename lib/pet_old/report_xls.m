% created 2009/07/11 by Dina Lika, modified by Bas Kooijman 2015/06/03
%
%% Description
%  writes report input parameters and output statistics
%   to Excel-file file_name set in pars_my_pets
%   assumes that report (and so parscomp) and report_xls_init have been run previously 
%     and report_xls_close afterwards
%   txt_statistics, val_statistics, txt_par, val_par, txt_mudn are set in report

if exist('n_spec','var')==0
  report_xls_init 
end

report_html %  hmtl reporting parallel to xls

n_spec = n_spec + 1; % increment row number; initiated in report_xls_init
txt_row = num2str(n_spec);

%% sheet 1: list of species
        
  hyper_species = ['=HYPERLINK("[', file_name, '.xls]', species, '!A1";"', species,'")'];
  xlswrite(file_name, {phylum, class, order, family, hyper_species, species_en, ...
      txt_author, txt_date, txt_author_mod, txt_date_mod, TYPE, FIT, COMPLETE, data_0{:}, data_1{:}}, 'species_list', ['A', txt_row])
   
  % colour font for data_0 and data_1
  n_data_0 = size(data_0,1); n_0_start = 1 + 13;       n_0_end = n_0_start + n_data_0 - 1; 
    cell_0_start = cell_name{n_0_start}; cell_0_end = cell_name{n_0_end}; % cell_name is defined in report_xls_init
  n_data_1 = size(data_1,1); n_1_start = 1 + n_0_end; n_1_end = n_1_start + n_data_1 - 1;
    cell_1_start = cell_name{n_1_start}; cell_1_end = cell_name{n_1_end};
 
  excelObj = actxserver('Excel.Application'); %opens up an excel object
  excelWorkbook = excelObj.workbooks.Open([txt_pwd, file_name]);
  % column width
  excelObj.sheets.Item('species_list').Range('E:G').ColumnWidth = 20; % species, common name and auhtor columns are broad
  excelObj.sheets.Item('species_list').Range('K:M').ColumnWidth = 4;  % TYPE,COMPLETE,FIT-column are narrow
  % colour cells fit TYPE FIT and COMPLETE
  excelObj.sheets.Item('species_list').Range(['K2:M', num2str(n_spec)]).Interior.ColorIndex = 36;
  % colour data types
  if n_data_0 > 0
    excelObj.sheets.Item(1).Range([cell_0_start, txt_row, ':', cell_0_end, txt_row]).Font.ColorIndex = 5; % blue for zero-variate data
  end
  if n_data_1 > 0 
    excelObj.sheets.Item(1).Range([cell_1_start, txt_row, ':', cell_1_end, txt_row]).Font.ColorIndex = 10; % green for uni-variate data
  end  
  excelWorkbook.Save;         % save font change
  excelWorkbook.Close(false); % closes excel object
  excelObj.Quit;
  delete(excelObj);
 
%% sheet 2: primary parameters for all species

  xlswrite(file_name, {hyper_species}, 'primary_parameters', ['A', txt_row]);
  
  % sequence of par_prim equals that of header in report_xls_init
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
  
  xlswrite(file_name, par_primary', 'primary_parameters', ['B', txt_row,':AT', txt_row]);
  
  % colour cells
  excelObj = actxserver('Excel.Application'); %opens up an excel object
  excelWorkbook = excelObj.workbooks.Open([txt_pwd, file_name]);
  excelObj.sheets.Item('primary_parameters').Range('A:A').ColumnWidth = 20; % species-column is broad
  excelObj.sheets.Item('primary_parameters').Range(['A1:A', txt_row]).Interior.ColorIndex = 36; % species list
  excelObj.sheets.Item('primary_parameters').Range(['B1:G', txt_row]).Interior.ColorIndex = 22; % temp pars
  excelObj.sheets.Item('primary_parameters').Range(['H1:H', txt_row]).Interior.ColorIndex = 38; % scaled func resp
  excelObj.sheets.Item('primary_parameters').Range(['I1:J', txt_row]).Interior.ColorIndex =  7; % zoom, del_M
  excelObj.sheets.Item('primary_parameters').Range(['K1:N', txt_row]).Interior.ColorIndex = 43; % assimilation
  excelObj.sheets.Item('primary_parameters').Range(['O1:Q', txt_row]).Interior.ColorIndex =  4; % reserve, reprod
  excelObj.sheets.Item('primary_parameters').Range(['R1:T', txt_row]).Interior.ColorIndex =  6; % maintenance
  excelObj.sheets.Item('primary_parameters').Range(['U1:U', txt_row]).Interior.ColorIndex = 19; % growth
  excelObj.sheets.Item('primary_parameters').Range(['V1:X', txt_row]).Interior.ColorIndex = 17; % life stages
  excelObj.sheets.Item('primary_parameters').Range(['Y1:Z', txt_row]).Interior.ColorIndex = 24; % ageing
  excelObj.sheets.Item('primary_parameters').Range(['AA1:AD',txt_row]).Interior.ColorIndex = 42; % chem potentials
  excelObj.sheets.Item('primary_parameters').Range(['AE1:AH',txt_row]).Interior.ColorIndex = 34; % densities
  excelObj.sheets.Item('primary_parameters').Range(['AI1:AK',txt_row]).Interior.ColorIndex = 28; % chem indices X
  excelObj.sheets.Item('primary_parameters').Range(['AL1:AN',txt_row]).Interior.ColorIndex = 33; % chem indices V
  excelObj.sheets.Item('primary_parameters').Range(['AO1:AQ',txt_row]).Interior.ColorIndex = 28; % chem indices E
  excelObj.sheets.Item('primary_parameters').Range(['AR1:AT',txt_row]).Interior.ColorIndex = 33; % chem indices P
  excelWorkbook.Save;
  excelWorkbook.Close(false);
  excelObj.Quit;
  delete(excelObj);

%% sheet 3: statistics for all species

  xlswrite(file_name, {hyper_species}, 'statistics', ['A', txt_row]);
  
  % sequence of statistics equals that in report_animal
  % present rates at temperature that is set for each species
  
  xlswrite(file_name, val_statistics', 'statistics', ['B', txt_row,':DR', txt_row]);

  % colour cells
  excelObj = actxserver('Excel.Application'); %opens up an excel object
  excelWorkbook = excelObj.workbooks.Open([txt_pwd, file_name]);
  excelObj.sheets.Item('statistics').Range([' B2: D',txt_row]).Interior.ColorIndex = 22; % 1
  excelObj.sheets.Item('statistics').Range([' E2: J',txt_row]).Interior.ColorIndex = 38; % 2
  excelObj.sheets.Item('statistics').Range([' K2: P',txt_row]).Interior.ColorIndex =  7; % 3
  excelObj.sheets.Item('statistics').Range([' Q2: U',txt_row]).Interior.ColorIndex =  4; % 4
  excelObj.sheets.Item('statistics').Range([' V2: Z',txt_row]).Interior.ColorIndex =  4; % 5
  excelObj.sheets.Item('statistics').Range(['AA2:AG',txt_row]).Interior.ColorIndex =  6; % 6
  excelObj.sheets.Item('statistics').Range(['AH2:AK',txt_row]).Interior.ColorIndex = 19; % 7
  excelObj.sheets.Item('statistics').Range(['AL2:AO',txt_row]).Interior.ColorIndex = 17; % 8
  excelObj.sheets.Item('statistics').Range(['AP2:AS',txt_row]).Interior.ColorIndex = 24; % 9
  excelObj.sheets.Item('statistics').Range(['AT2:BB',txt_row]).Interior.ColorIndex = 42; % 10
  excelObj.sheets.Item('statistics').Range(['BC2:BF',txt_row]).Interior.ColorIndex = 34; % 11
  excelObj.sheets.Item('statistics').Range(['BG2:BJ',txt_row]).Interior.ColorIndex = 28; % 12
  excelObj.sheets.Item('statistics').Range(['BK2:BT',txt_row]).Interior.ColorIndex = 22; % 13
  excelObj.sheets.Item('statistics').Range(['BU2:CL',txt_row]).Interior.ColorIndex = 38; % 14
  excelObj.sheets.Item('statistics').Range(['CM2:CP',txt_row]).Interior.ColorIndex =  7; % 15
  excelObj.sheets.Item('statistics').Range(['CQ2:CU',txt_row]).Interior.ColorIndex = 43; % 16
  excelObj.sheets.Item('statistics').Range(['CV2:DE',txt_row]).Interior.ColorIndex =  4; % 17
  excelObj.sheets.Item('statistics').Range(['DF2:DH',txt_row]).Interior.ColorIndex =  6; % 18
  excelObj.sheets.Item('statistics').Range(['DI2:DR',txt_row]).Interior.ColorIndex = 19; % 19
  excelWorkbook.Save;
  excelWorkbook.Close(false);
  excelObj.Quit;
  delete(excelObj);
  
%% sheet species; one sheet per species

  % links to pars-, mydata-, predict-, result-files in header
  hyper_pars = ['=HYPERLINK("', hyp_add_my_pet, 'pars_', species,'.m";"pars")'];
  xlswrite(file_name, {hyper_pars}, species, 'F1')

  hyper_mydata = ['=HYPERLINK("', hyp_add_my_pet, 'mydata/mydata_', species,'.m";"mydata")'];
  xlswrite(file_name, {hyper_mydata}, species, 'G1')
  hyper_predict = ['=HYPERLINK("', hyp_add_my_pet, 'mydata/predict_', species,'.m";"predict")'];
  xlswrite(file_name, {hyper_predict}, species, 'H1')
  hyper_result = ['=HYPERLINK("', hyp_add_my_pet, 'mydata/html/mydata_', species,'.html";"fit")'];
  xlswrite(file_name, {hyper_result}, species, 'I1')


  % statistics
  hyper_statistics = ['=HYPERLINK("', hyp_add_my_pet, 'add_my_pet.pdf"; "statistics at T")'];
  xlswrite(file_name, [{hyper_statistics}; txt_statistics], species, 'A1')
  xlswrite(file_name, val_statistics, species, 'B2') 

  % input parameters
  n_par = length(val_par);

  xlswrite(file_name, [{'Input parameters at T_ref'}; txt_par; txt_mudn], species, 'D1')
  xlswrite(file_name, val_par, species, 'E2')
  xlswrite(file_name, [mu_O'; d_O'; n_O], species, ['E', num2str(2 + n_par)]);
  
  excelObj = actxserver('Excel.Application'); %opens up an excel object
  excelWorkbook = excelObj.workbooks.Open([txt_pwd, file_name]);
  excelObj.sheets.Item(species).Range('A:A').ColumnWidth = 40; % description-column is broad
  excelObj.sheets.Item(species).Range('D:D').ColumnWidth = 30; % description-column is broad
  excelObj.sheets.Item(species).Range('A1:I1').Interior.ColorIndex   = 36; % header

  % colour statistics
  excelObj.sheets.Item(species).Range('A2:B4').Interior.ColorIndex   = 22; % 1
  excelObj.sheets.Item(species).Range('A5:B10').Interior.ColorIndex  = 38; % 2
  excelObj.sheets.Item(species).Range('A11:B16').Interior.ColorIndex =  7; % 3
  excelObj.sheets.Item(species).Range('A17:B21').Interior.ColorIndex =  4; % 4
  excelObj.sheets.Item(species).Range('A22:B26').Interior.ColorIndex =  4; % 5
  excelObj.sheets.Item(species).Range('A27:B33').Interior.ColorIndex =  6; % 6
  excelObj.sheets.Item(species).Range('A34:B37').Interior.ColorIndex = 19; % 7
  excelObj.sheets.Item(species).Range('A38:B41').Interior.ColorIndex = 17; % 8
  excelObj.sheets.Item(species).Range('A42:B45').Interior.ColorIndex = 24; % 9
  excelObj.sheets.Item(species).Range('A46:B54').Interior.ColorIndex = 42; % 10
  excelObj.sheets.Item(species).Range('A55:B58').Interior.ColorIndex = 34; % 11
  excelObj.sheets.Item(species).Range('A59:B62').Interior.ColorIndex = 28; % 12
  excelObj.sheets.Item(species).Range('A63:B72').Interior.ColorIndex = 22; % 13
  excelObj.sheets.Item(species).Range('A73:B90').Interior.ColorIndex = 38; % 14
  excelObj.sheets.Item(species).Range('A91:B94').Interior.ColorIndex =  7; % 15
  excelObj.sheets.Item(species).Range('A95:B99').Interior.ColorIndex = 43; % 16
  excelObj.sheets.Item(species).Range('A100:B109').Interior.ColorIndex = 4;% 17
  excelObj.sheets.Item(species).Range('A110:B112').Interior.ColorIndex = 6;% 18
  excelObj.sheets.Item(species).Range('A113:B122').Interior.ColorIndex =19;% 19
 
  % colour primary_parameters
  excelObj.sheets.Item(species).Range('D2:E8').Interior.ColorIndex =   22; % temp pars
  excelObj.sheets.Item(species).Range('D9:E9').Interior.ColorIndex =   38; % scaled func resp
  excelObj.sheets.Item(species).Range('D10:E11').Interior.ColorIndex =  7; % zoom, del_M
  excelObj.sheets.Item(species).Range('D12:E14').Interior.ColorIndex = 43; % assimilation
  excelObj.sheets.Item(species).Range('D15:E17').Interior.ColorIndex =  4; % reserve, reprod
  excelObj.sheets.Item(species).Range('D18:E20').Interior.ColorIndex =  6; % maintenance
  excelObj.sheets.Item(species).Range('D21:E21').Interior.ColorIndex = 19; % growth
  excelObj.sheets.Item(species).Range('D22:E24').Interior.ColorIndex = 17; % life stages
  excelObj.sheets.Item(species).Range('D25:E26').Interior.ColorIndex = 24; % ageing
  excelObj.sheets.Item(species).Range('D27:H27').Interior.ColorIndex = 42; % chem potentials
  excelObj.sheets.Item(species).Range('D28:H28').Interior.ColorIndex = 34; % densities
  excelObj.sheets.Item(species).Range('D29:H32').Interior.ColorIndex = 28; % chem indices X

  excelWorkbook.Save;         % save font change
  excelWorkbook.Close(false); % closes excel object
  excelObj.Quit;
  delete(excelObj);

%% prepare for a next species
  
  clear T* t_* W* w* d* M* m* E* e* p* V* v* U* u* L* l* a* F* s_* SD* S_* K* k*
  clear y* J* j* x* z* G* g* F* R* r* h_* hT* C* X* f f_* n_M n_O
  clear val* info* species family order class phylum author txt_author author_mod txt_author_mod date txt_date date_mod txt_date_mod data_0 data_1
