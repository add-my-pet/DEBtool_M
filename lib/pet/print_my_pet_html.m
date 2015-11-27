%% print_my_pet_html
% Creates my_pet.html 

%%
function print_my_pet_html(metaData, metaPar, par, txtPar)
% created 2015/04/11 by Starrlight (heavily inspired by a file created by Bas Kooijman)
% modified 2015/07/27 by starrlight
% modified 2015/08/06 by Dina
% modified 2015/08/25 by Starrlight

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
if strcmp(metaPar.model,'abj')
    fldsStd = {'T_A';'z'; 'F_m'; 'kap_X'; 'kap_P'; 'v'; 'kap'; 'kap_R'; 'p_M'; 'p_T'; ...
    'k_J'; 'E_G'; 'E_Hb'; 'E_Hj'; 'E_Hp'; 'h_a'; 's_G'};
else
fldsStd = {'T_A';'z'; 'F_m'; 'kap_X'; 'kap_P'; 'v'; 'kap'; 'kap_R'; 'p_M'; 'p_T'; ...
    'k_J'; 'E_G'; 'E_Hb'; 'E_Hp'; 'h_a'; 's_G'};
end

fldsChem = {'mu_X'; 'mu_V'; 'mu_E'; 'mu_P'; 'd_X'; 'd_V'; 'd_E'; 'd_P'; ...
    'n_CX'; 'n_CV'; 'n_CE'; 'n_CP'; 'n_OX'; 'n_NX'; 'n_HV'; 'n_OV'; 'n_NV'; 'n_HE'; 'n_HX'; 'n_OE'; 'n_NE';'n_HP'; 'n_OP'; 'n_NP';};

fldsOther = {'mu_C'; 'mu_H'; 'mu_O'; 'mu_N'; 'n_CC'; 'n_HC'; 'n_OC'; 'n_NC'; ...
    'n_CH'; 'n_HH'; 'n_OH'; 'n_NH';'n_CO'; 'n_HO'; 'n_OO'; 'n_NO';'n_CN'; 'n_HN'; 'n_ON'; 'n_NN'};


% make structure with label, units and values of parameters specific for
% my_pet:
parAux   = rmfield_wtxt(par, fldsStd{1});
parAux   = rmfield_wtxt(parAux, 'free');
labelAux = rmfield_wtxt(txtPar.label, fldsStd{1});
unitsAux = rmfield_wtxt(txtPar.units, fldsStd{1});
for j = 2:length(fldsStd)
parAux   = rmfield_wtxt(parAux, fldsStd{j});
labelAux = rmfield_wtxt(labelAux, fldsStd{j});
unitsAux = rmfield_wtxt(unitsAux, fldsStd{j});
end
for j = 1:length(fldsChem)
parAux   = rmfield_wtxt(parAux, fldsChem{j});
labelAux = rmfield_wtxt(labelAux, fldsChem{j});
unitsAux = rmfield_wtxt(unitsAux, fldsChem{j});
end
for j = 1:length(fldsOther)
parAux   = rmfield_wtxt(parAux, fldsOther{j});
labelAux = rmfield_wtxt(labelAux, fldsOther{j});
unitsAux = rmfield_wtxt(unitsAux, fldsOther{j});
end


% make structure with label, units and values of standard parameters
[fldsAux, nst] = fieldnmnst_st(parAux); 
parStd   = rmfield_wtxt(par, fldsAux{1});
parStd   = rmfield_wtxt(parStd, 'free');
labelStd = rmfield_wtxt(txtPar.label, fldsAux{1});
unitsStd = rmfield_wtxt(txtPar.units, fldsAux{1});
for j = 2:nst
parStd   = rmfield_wtxt(parStd, fldsAux{j});
labelStd = rmfield_wtxt(labelStd, fldsAux{j});
unitsStd = rmfield_wtxt(unitsStd, fldsAux{j});
end
parStd   = rmfield_wtxt(parStd, 'z');
parStd.p_Am = par.z * par.p_M/ par.kap;
labelStd.p_Am = 'max spec assimilation rate';
unitsStd.p_Am = 'J/d.cm^2';

fldsStd = {'T_A';'F_m'; 'kap_X'; 'kap_P'; 'p_Am'; 'v'; 'kap'; 'kap_R'; 'p_M'; 'p_T'; ...
    'k_J'; 'E_G'; 'E_Hb'; 'E_Hp'; 'h_a'; 's_G'};  % overwrite the original fields_std

colPar.T_A  = '#FFC6A5'; 
colPar.F_m = '#CEEFBD';  colPar.kap_X = '#CEEFBD'; colPar.kap_P = '#CEEFBD';  colPar.p_Am = '#CEEFBD'; 
colPar.v = '#DEF3BD';  colPar.kap = '#DEF3BD';  colPar.kap_R = '#DEF3BD'; 
colPar.p_M = '#FFFF9C';  colPar.p_T = '#FFFF9C';  colPar.k_J = '#FFFF9C'; 
colPar.E_G = '#FFFFC6'; 
colPar.E_Hb = '#94D6E7';  colPar.E_Hp = '#94D6E7'; 
colPar.h_a = '#BDC6DE';  colPar.s_G = '#BDC6DE'; 
% col_par = {... % colours for primary parameters
%     '#FFC6A5'; '#F7BDDE'; '#DEBDDE'; '#CEEFBD'; '#DEF3BD'; '#FFFF9C'; '#FFFFC6'; '#94D6E7'; '#BDC6DE'; 
%     '#C6E7DE'; '#C6EFF7'; '#F7BDDE'; '#FFFFFF'; '#F7BDDE'; '#FFFFFF'};

%%
% make structure with label, units and values of statistics
% statistics we would like to see on the web:

if strcmp(metaPar.model,'abj')
    fldsStat = {'c_T'; ...
    's_M'; 's_H'; 's_s'; ...
    'E_0'; 'W_0';'del_Ub'; ...
    'a_b'; 'a_j'; 'a_p'; 'a_99'; ...
    'W_b'; 'W_j';'W_p'; 'W_i'; 'L_b'; 'L_j'; 'L_p'; 'L_i'; 'R_i'; ...
    'del_Wb'; 'del_Wp'; 'del_V'; 'r_B'; ...
    'E_m'; 't_starve'; 't_E'; 'xi_W_E'; ...
    'eb_ming'; 'eb_minh'; ...'ep_min'; ...
    'VO_b'; 'VO_j'; 'VO_p'; 'VO_i'; ...
    'p_t_b'; 'p_t_j'; 'p_t_p'; 'p_t_i'; ...
    'RQ_b'; 'RQ_j'; 'RQ_p'; 'RQ_i'};
[stat, txtStat] = statistics_abj(par, metaData.T_typical, 1, metaPar.model);
elseif strcmp(metaPar.model,'ssj') % not correct but ok for now
fldsStat = {'c_T'; ...
    's_H'; 's_s'; ...
    'E_0'; 'W_0';'del_Ub'; ...
    'a_b'; 'a_p'; 'a_99'; ...
    'W_b'; 'W_p'; 'W_i'; 'L_b';'L_p'; 'L_i'; 'R_i'; ...
    'del_Wb'; 'del_Wp'; 'del_V'; 'r_B'; ...
    'E_m'; 't_starve'; 't_E'; 'xi_W_E'; ...
    'eb_ming'; 'eb_minh'; ...'ep_min'; ...
    'VO_b'; 'VO_p'; 'VO_i'; ...
    'p_t_b'; 'p_t_p'; 'p_t_i'; ...
    'RQ_b'; 'RQ_p'; 'RQ_i'};    
[stat, txtStat] = statistics_ssj(par, metaData.T_typical, 1, metaPar.model);
else % std, stx, stf ...
fldsStat = {'c_T'; ...
    's_H'; 's_s'; ...
    'E_0'; 'W_0';'del_Ub'; ...
    'a_b'; 'a_p'; 'a_99'; ...
    'W_b'; 'W_p'; 'W_i'; 'L_b';'L_p'; 'L_i'; 'R_i';  ...
    'del_Wb'; 'del_Wp'; 'del_V'; 'r_B'; ...
    'E_m'; 't_starve'; 't_E'; 'xi_W_E'; ...
    'eb_ming'; 'eb_minh'; ... 'ep_min'; ...
    'VO_b'; 'VO_p'; 'VO_i'; ...
    'p_t_b'; 'p_t_p'; 'p_t_i'; ...
    'RQ_b'; 'RQ_p'; 'RQ_i'};
[stat, txtStat] = statistics_std(par, metaData.T_typical, 1, metaPar.model);
end
[fields, nst] = fieldnmnst_st(stat); 
for  i = 1:length(fldsStat)
k = find(strcmp(fldsStat{i},fields));
statStd.(fldsStat{i}) = stat.(fields{k});
unitsStat.(fldsStat{i}) = txtStat.units.(fields{k});
labelStat.(fldsStat{i}) = txtStat.label.(fields{k});
% eval(['statStd.',fldsStat{i},' = stat.',fields{k},';']);
% eval(['unitsStat.',fldsStat{i},' = txtStat.units.',fields{k},';']);
% eval(['labelStat.',fldsStat{i},' = txtStat.label.',fields{k},';']);
end 

colStat.s_H = '#F7BDDE'; colStat.s_s = '#F7BDDE';
colStat.c_T = '#FFC6A5';
colStat.E_0 = '#FFFFFF'; colStat.W_0 = '#FFFFFF'; colStat.del_Ub = '#FFFFFF'; 
colStat.a_b = '#C6E7DE'; colStat.a_p = '#C6E7DE'; colStat.a_99 = '#C6E7DE';
colStat.W_b = '#CEEFBD'; colStat.W_p = '#CEEFBD'; colStat.W_i = '#CEEFBD';
colStat.L_b = '#DEF3BD'; colStat.L_p = '#DEF3BD'; colStat.L_i = '#DEF3BD';
colStat.R_i = '#FFFFC6'; 
colStat.del_Wb = '#FFFF9C';  colStat.del_Wp = '#FFFF9C';  colStat.del_V = '#FFFF9C'; colStat.r_B = '#FFFF9C'; 
colStat.E_m = '#FFC6A5';  colStat.t_starve = '#FFC6A5';  colStat.t_E = '#FFC6A5';  colStat.xi_W_E = '#FFC6A5'; 
colStat.eb_ming = '#94D6E7'; colStat.eb_minh = '#94D6E7'; colStat.ep_min = '#94D6E7';
colStat.VO_b = '#FFFFFF'; colStat.VO_p = '#FFFFFF'; colStat.VO_i = '#FFFFFF';
colStat.p_t_b = '#FFFFC6'; colStat.p_t_p = '#FFFFC6'; colStat.p_t_i = '#FFFFC6'; 
colStat.RQ_b = '#FFFF9C'; colStat.RQ_p = '#FFFF9C'; colStat.RQ_i = '#FFFF9C';


if strcmp(metaPar.model,'abj')
    colStat.s_M = '#F7BDDE'; 
    description.E_Hj  = 'maturity at metamorphosis';
    colPar.E_Hj = colPar.E_Hb;
    colStat.a_j = colStat.a_b;  colStat.L_j = colStat.L_b;  colStat.W_j = colStat.W_b; 
    colStat.VO_j = colStat.VO_b;  colStat.p_t_j = colStat.p_t_b; colStat.RQ_j = colStat.RQ_b;
end

% colours for statistics
%     '#FFC6A5'; '#FFFFFF'; '#C6E7DE'; '#CEEFBD'; '#CEEFBD';
%     '#DEF3BD'; '#FFFFC6'; '#BDC6DE'; '#C6B5DE'; '#DEBDDE';
%     '#F7BDDE'; '#C6E7DE'; '#FFFFC6'; '#FFC6A5'; '#FFFFC6'; 
%     '#F7BDDE'; '#BDC6DE'; '#FFFFC6'; '#FFFFFF'


%%
% - this section might disapear if the description is put in all of the
% pars init files.
description.T_A   = 'Arrhenius temp';
description.F_m   = 'max spec searching rate';
description.kap_X = 'digestion efficiency of food to reserve';
description.kap_P = 'faecation efficiency of food to faeces';
description.p_Am  = 'max spec assimilation rate';
description.v     = 'energy conductance';
description.kap   = 'allocation fraction to soma';
description.kap_R = 'reproduction efficiency';
description.p_M   = 'vol-specific somatic maintenance';
description.p_T   = 'surface-specific som maintenance';
description.k_J   = 'maturity maint rate coefficient';
description.E_G   = 'specific cost for structure';
description.E_Hb  = 'maturity at birth';
description.E_Hp  = 'maturity at puberty';
description.h_a   = 'Weibull aging acceleration';
description.s_G   = 'Gompertz stress coefficient';

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
  for i = 1:  size(fldsStat,1)
    fprintf(oid, '    <TR BGCOLOR = "%s"> <TD>%s</TD> <TD>%g</TD> <TD>%s</TD><TD>%s</TD></TR>\n',...
      colStat.(fldsStat{i}), fldsStat{i}, statStd.(fldsStat{i}), ...
       unitsStat.(fldsStat{i}), labelStat.(fldsStat{i}));
  end
fprintf(oid, '    </TABLE>\n');    
% ----------------------------------------------------------------------

% open up the second column:
fprintf(oid, '    </TD><TD>\n');    

%% primary parameters tables:
   
fprintf(oid, '    <TABLE>\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="4">Primary parameters at reference temperature (%g deg. C)</TH></TR>\n', par.T_ref - 273.15);
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH>symbol</TH><TH> value</TH><TH> units</TH><TH> description</TH></TR>\n');
  for i = 1:  size(fldsStd,1)
    fprintf(oid, '    <TR BGCOLOR = "%s"> <TD>%s</TD> <TD>%g</TD> <TD>%s</TD><TD>%s</TD></TR>\n',...
          colPar.(fldsStd{i}), fldsStd{i}, parStd.(fldsStd{i}), ...
       unitsStd.(fldsStd{i}), description.(fldsStd{i}));
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

fprintf(oid, '    <TD>\n');  
fprintf(oid, '    <TABLE>\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="4">Parameters specific for this entry (%g deg. C) </TH></TR>\n', par.T_ref - 273.15);
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH>symbol</TH><TH> value</TH><TH> units</TH><TH> description</TH></TR>\n');
  for i = 1:  size(fldsAux,1)
    fprintf(oid, '    <TR BGCOLOR = "%s"> <TD>%s</TD> <TD>%g</TD> <TD>%s</TD><TD>%s</TD></TR>\n',...
          '#FFFFFF', fldsAux{i}, parAux.(fldsAux{i}), ...
       unitsAux.(fldsAux{i}), labelAux.(fldsAux{i}));
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
