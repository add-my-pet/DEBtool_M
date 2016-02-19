%% print_my_pet_under_construction
% Creates an html page for 'my_pet' which says that it is under construction  

%%
function print_my_pet_under_construction(metaData, metaPar, par, txtPar)
% created 2015/04/11 by Starrlight (heavily inspired by a file created by Bas Kooijman)
% modified 2015/07/27 by starrlight
% modified 2015/08/06 by Dina

%% Syntax
% <../print_my_pet_html.m *print_my_pet_html*> (metaData, metaPar, par, txtPar) 

%% Description
% Read and writes my_pet.html. This pages contains a list of implied model
% properties and parameters values of my_pet.
%
% Input:
%
% * metaData: structure
% * par: structure
% * stat: structure


%% Remarks
% Keep in mind that the files will be saved in your local directory; use
% the cd command BEFORE running this function to save files in the desired
% place.

%% Example of use
% load('results_my_pet.mat');
% print_my_pet_html(metaData)

v2struct(metaData); 

n_author = length(author);

switch n_author
    
    case 1
    txt_author = author{1};

    case 2
    txt_author = [author{1}, ', ', author{2}];

    otherwise    
    txt_author = [author{1}, ', et al.'];

end

txt_date = [num2str(date_acc(1)), '/', num2str(date_acc(2)), '/', num2str(date_acc(3))]; 

% !!!!!!!!!!!!!!! We need to adapt this part of the code
% because it is possible that exist('author_mod_2', 'var') == 1 etc. ...

if exist('author_mod_1', 'var') == 1 && exist('date_mod_1', 'var') == 1
n_author_mod_1 = length(author_mod_1);

    switch n_author_mod_1
      case 1
      txt_author_mod_1 = author_mod_1{1};
      case 2
      txt_author_mod_1 = [author_mod_1{1}, ', ', author_mod_1{2}];
      otherwise    
      txt_author_mod_1 = [author_mod_1{1}, ', et al.'];
    end

txt_date_mod_1 = [num2str(date_mod_1(1)), '/', num2str(date_mod_1(2)), '/', num2str(date_mod_1(3))]; 

else
    
txt_author_mod_1 = '';
txt_date_mod_1 =  '';

end  

% default parameters for model std after Marques et al 2015 -

switch metaPar.model
    
    case 'abj'
        
    fields_std = {'T_A'; 'F_m'; 'kap_X'; 'kap_P'; 'v'; 'kap'; 'kap_R'; 'p_M'; 'p_T'; ...
    'k_J'; 'E_G'; 'E_Hb'; 'E_Hj'; 'E_Hp'; 'h_a'; 's_G'};

    case 'hex'
        
     fields_std = {'T_A'; 'F_m'; 'kap_X'; 'kap_P'; 'kap_V'; 'v'; 'kap'; 'kap_R'; 'p_M'; 'p_T'; ...
    'k_J'; 'E_G'; 'E_Hb'; 'E_He'; 'h_a'; 's_G'};
        
    case 'abp'
        
     fields_std = {'T_A';'F_m'; 'kap_X'; 'kap_P'; 'v'; 'kap'; 'kap_R'; 'p_M'; 'p_T'; ...
    'k_J'; 'E_G'; 'E_Hb'; 'E_Hp'; 'h_a'; 's_G'};

    otherwise
        
     fields_std = {'T_A'; 'F_m'; 'kap_X'; 'kap_P'; 'v'; 'kap'; 'kap_R'; 'p_M'; 'p_T'; ...
    'k_J'; 'E_G'; 'E_Hb'; 'E_Hp'; 'h_a'; 's_G'};
end


fldsChem = {'mu_X'; 'mu_V'; 'mu_E'; 'mu_P'; 'd_X'; 'd_V'; 'd_E'; 'd_P'; ...
    'n_CX'; 'n_CV'; 'n_CE'; 'n_CP'; 'n_OX'; 'n_NX'; 'n_HV'; 'n_OV'; 'n_NV'; 'n_HE'; 'n_HX'; 'n_OE'; 'n_NE';'n_HP'; 'n_OP'; 'n_NP';};

fldsOther = {'mu_C'; 'mu_H'; 'mu_O'; 'mu_N'; 'n_CC'; 'n_HC'; 'n_OC'; 'n_NC'; ...
    'n_CH'; 'n_HH'; 'n_OH'; 'n_NH';'n_CO'; 'n_HO'; 'n_OO'; 'n_NO';'n_CN'; 'n_HN'; 'n_ON'; 'n_NN'};

% make structure with label, units and values of parameters specific for
% my_pet:
par_aux   = rmfield_wtxt(par, fields_std{1});
par_aux   = rmfield_wtxt(par_aux, 'free');
label_aux = rmfield_wtxt(txtPar.label, fields_std{1});
units_aux = rmfield_wtxt(txtPar.units, fields_std{1});
for j = 2:length(fields_std)
par_aux   = rmfield_wtxt(par_aux, fields_std{j});
label_aux = rmfield_wtxt(label_aux, fields_std{j});
units_aux = rmfield_wtxt(units_aux, fields_std{j});
end
for j = 1:length(fldsChem)
par_aux   = rmfield_wtxt(par_aux, fldsChem{j});
label_aux = rmfield_wtxt(label_aux, fldsChem{j});
units_aux = rmfield_wtxt(units_aux, fldsChem{j});
end
for j = 1:length(fldsOther)
par_aux   = rmfield_wtxt(par_aux, fldsOther{j});
label_aux = rmfield_wtxt(label_aux, fldsOther{j});
units_aux = rmfield_wtxt(units_aux, fldsOther{j});
end

% make structure with label, units and values of standard parameters
[fields_aux, nst] = fieldnmnst_st(par_aux); 
par_std   = rmfield_wtxt(par, fields_aux{1});
par_std   = rmfield_wtxt(par_std, 'free');
label_std = rmfield_wtxt(txtPar.label, fields_aux{1});
units_std = rmfield_wtxt(txtPar.units, fields_aux{1});
for j = 2:nst
par_std   = rmfield_wtxt(par_std, fields_aux{j});
label_std = rmfield_wtxt(label_std, fields_aux{j});
units_std = rmfield_wtxt(units_std, fields_aux{j});
end
par_std   = rmfield_wtxt(par_std, 'z');
par_std.p_Am = par.z * par.p_M/ par.kap;
label_std.p_Am = 'max spec assimilation rate';
units_std.p_Am = 'J/d.cm^2';
par_std   = rmfield_wtxt(par_std, 'z');


% fields_std = {'T_A';'F_m'; 'kap_X'; 'kap_P'; 'p_Am'; 'v'; 'kap'; 'kap_R'; 'p_M'; 'p_T'; ...
%     'k_J'; 'E_G'; 'E_Hb'; 'E_Hp'; 'h_a'; 's_G'};  % overwrite the original fields_std

col_par.T_A  = '#FFC6A5'; 
col_par.F_m = '#CEEFBD';  col_par.kap_X = '#CEEFBD'; col_par.kap_P = '#CEEFBD';  col_par.p_Am = '#CEEFBD'; 
col_par.v = '#DEF3BD';  col_par.kap = '#DEF3BD';  col_par.kap_R = '#DEF3BD'; 
col_par.p_M = '#FFFF9C';  col_par.p_T = '#FFFF9C';  col_par.k_J = '#FFFF9C'; 
col_par.E_G = '#FFFFC6'; 
col_par.E_Hb = '#94D6E7';  col_par.E_Hp = '#94D6E7'; 
col_par.h_a = '#BDC6DE';  col_par.s_G = '#BDC6DE'; 
% 
if strcmp(metaPar.model,'abj')
    col_par.E_Hj = col_par.E_Hb;
end

if strcmp(metaPar.model,'hex')
    col_par.E_He = col_par.E_Hp;
    col_par.kap_V = col_par.kap_R;
end

chem_out = { ...
% temperature  #FFC6A5    
'#FFC6A5', 'mu_X', par.mu_X,  'J/ mol', 'chemical potential of food'  
'#FFC6A5', 'mu_V', par.mu_V,  'J/ mol', 'chemical potential of structure'    
'#FFC6A5', 'mu_E', par.mu_E,  'J/ mol', 'chemical potential of reserve'    
'#FFC6A5', 'mu_P', par.mu_P,  'J/ mol', 'chemical potential of faeces'   
%
'#CEEFBD', 'd_X',   par.d_X,  'g/cm^3', 'specific density of food'   
'#CEEFBD', 'd_V',   par.d_V,  'g/cm^3', 'specific density of structure'   
'#CEEFBD', 'd_E',   par.d_E,  'g/cm^3', 'specific density of reserve'   
'#CEEFBD', 'd_P',   par.d_P,  'g/cm^3', 'specific density of faeces' 
% 
'#DEF3BD', 'n_HX',    par.n_HX,  '-',     'chem. index of hydrogen in food'   
'#DEF3BD', 'n_OX',    par.n_OX,  '-',     'chem. index of oxygen in food'     
'#DEF3BD', 'n_NX',    par.n_NX,  '-',     'chem. index of nitrogen in food'   
% 
'#FFFF9C', 'n_HV',    par.n_HV,  '-',     'chem. index of hydrogen in structure'     
'#FFFF9C', 'n_OV',    par.n_OV,  '-',     'chem. index of oxygen in structure'    
'#FFFF9C', 'n_NV',    par.n_NV,  '-',     'chem. index of nitrogen in structure'    
% 
'#FFFFC6', 'n_HE',    par.n_HE,  '-',     'chem. index of hydrogen in reserve'  
'#FFFFC6', 'n_OE',    par.n_OE,  '-',     'chem. index of oxygen in reserve'
'#FFFFC6', 'n_NE',    par.n_NE,  '-',     'chem. index of nitrogen in reserve'
% 
'#94D6E7', 'n_HP',    par.n_HP,  '-',     'chem. index of hydrogen in faeces' 
'#94D6E7', 'n_OP',    par.n_OP,  '-',     'chem. index of oxygen in faeces' 
'#94D6E7', 'n_NP',    par.n_NP,  '-',     'chem. index of nitrogen in faeces' 
};

% --------------------------------------------------
% ------------- WRITE THE INFORMATION COMPILED ABOVE TO MY_PET.HTML


  oid = fopen([species, '.html'], 'w+'); % % open file for writing, delete existing content
  fprintf(oid, '%s\n' ,'<!DOCTYPE html>');
  fprintf(oid, '%s\n' ,'<HTML>');
  fprintf(oid, '%s\n' ,'  <HEAD>');
  fprintf(oid,['    <TITLE>add-my-pet:', species, '</TITLE>\n']);
  fprintf(oid, '%s'   ,'    <META NAME = "keywords" ');
  fprintf(oid, '%s\n' ,'     CONTENT="add-my-pet, Dynamic Energy Budget theory, DEBtool">');
  
  % ----- calls the javascript function (found in subfolder sys):
  fprintf(oid, '%s\n' ,'<script type="text/javascript" src="../sys/boxmodal.js"></script>');
  % ------ calls the cascading style sheet (found in subfolder css):
  fprintf(oid, '%s\n' ,'<link rel="stylesheet" type="text/css" href="../css/collectionstyle.css">'); 
  
  fprintf(oid, '%s\n' , ' </HEAD>');
  fprintf(oid, '%s\n\n','  <BODY>');
  
   
 
% make a large table with two columns
% the statistics table is in column 1 
% the primary parameter and chemical parameters are in column 2:
fprintf(oid, '<TABLE CELLSPACING=60><TR VALIGN=TOP><TD>\n');

% statistics table (column 1):
fprintf(oid, '      <TABLE>\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="4">Properties temperature corrected to %g deg. C (f = %g) </TH></TR>\n', metaData.T_typical - 273.15, 1);
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH>symbol</TH><TH> value</TH><TH> units</TH><TH> description</TH></TR>\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="4">This table is under construction for model %s </TH></TR>\n', metaPar.model);
fprintf(oid, '    </TABLE>\n');    
% ----------------------------------------------------------------------

% open up the second column:
fprintf(oid, '    </TD><TD>\n');    

%% primary parameters tables:
   
fprintf(oid, '    <TABLE>\n'); 
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="4">Primary parameters at reference temperature (%g deg. C)</TH></TR>\n', K2C(par.T_ref));
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH>symbol</TH><TH> value</TH><TH> units</TH><TH> description</TH></TR>\n');
  for i = 1:  size(fields_std,1)
    fprintf(oid, '    <TR BGCOLOR = "%s"> <TD>%s</TD> <TD>%g</TD> <TD>%s</TD><TD>%s</TD></TR>\n',...
          eval(['col_par.',fields_std{i}]), fields_std{i}, eval(['par_std.',fields_std{i}]), ...
       eval(['units_std.',fields_std{i}]), eval(['label_std.',fields_std{i}]));
  end
  
% Empty line in table so that there is a space between primary parameters
% and chemical parameters:
fprintf(oid, '     <TR><TD BGCOLOR = "%s">%s</TD> \n', '#FAFAFA', '&nbsp;');

% chemical parameters:
% this table is in truth a continuation of the same table as for statistics
% the advantage being that the tables won't slide around when the browser
% window is re-sized:
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="4">Biochemical parameters</TH></TR>\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH>symbol</TH><TH> value</TH><TH> units</TH><TH> description</TH></TR>\n');
  for i = 1:  size(chem_out,1)
    fprintf(oid, '    <TR BGCOLOR = "%s"> <TD>%s</TD> <TD>%g</TD> <TD>%s</TD><TD>%s</TD></TR>\n',...
    chem_out{i,1}, chem_out{i,2}, chem_out{i,3}, chem_out{i,4}, chem_out{i,5});
  end
fprintf(oid, '    </TABLE>\n'); 

% close the second column:
fprintf(oid, '    </TD>\n');  

% final table with extra parameters:
fprintf(oid, '    <TD>\n');  
fprintf(oid, '    <TABLE>\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="4">Parameters specific for this entry (%g deg. C) </TH></TR>\n', par.T_ref - 273.15);
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH>symbol</TH><TH> value</TH><TH> units</TH><TH> description</TH></TR>\n');
  for i = 1:  size(fields_aux,1)
    fprintf(oid, '    <TR BGCOLOR = "%s"> <TD>%s</TD> <TD>%g</TD> <TD>%s</TD><TD>%s</TD></TR>\n',...
          '#FFFFFF', fields_aux{i}, eval(['par_aux.',fields_aux{i}]), ...
       eval(['units_aux.',fields_aux{i}]), eval(['label_aux.',fields_aux{i}]));
  end
 fprintf(oid, '    </TABLE>\n'); 


fprintf(oid, '    </TD>\n'); 
% close the table:
fprintf(oid, '    </TABLE>\n');  

%% author and last data of modification

fprintf(oid, '<HR> \n');
fprintf(oid,['    <H3 style="clear:both" ALIGN="CENTER">', txt_author, ', ', txt_date, ...
        ' (last modified by ', txt_author_mod_1, '\n', txt_date_mod_1,')','</H3>\n']); 

%% close my_pet.html  
  
% these two lines are necessary for the boxes called by java scrip in
% subfolder sys to work:
fprintf(oid,'%s\n' , '<div style="position: absolute; z-index: 20000; visibility: hidden; display: none;" id="ext-comp-1001" class="x-tip"><div class="x-tip-tl"><div class="x-tip-tr"><div class="x-tip-tc"><div style="-moz-user-select: none;" id="ext-gen10" class="x-tip-header x-unselectable"><span class="x-tip-header-text"></span></div></div></div></div><div id="ext-gen11" class="x-tip-bwrap"><div class="x-tip-ml"><div class="x-tip-mr"><div class="x-tip-mc"><div style="height: auto;" id="ext-gen12" class="x-tip-body"></div></div></div></div>');
fprintf(oid,'%s\n' , '<div class="x-tip-bl x-panel-nofooter"><div class="x-tip-br"><div class="x-tip-bc"></div></div></div></div></div><div id="xBoxScreen"></div>');

fprintf(oid, '  </BODY>\n');
fprintf(oid, '  </HTML>\n');
fclose(oid);
