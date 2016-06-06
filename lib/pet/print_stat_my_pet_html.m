%% print_stat_my_pet_html
% Creates my_pet_stat.html 

%%
function print_stat_my_pet_html(metaData, metaPar, par)
% created 2016/03/30 by Starrlight

%% Syntax
% <../print_stat_my_pet_html.m *print_stat_my_pet_html*> (metaData, metaPar, par) 

%% Description
% Read and writes my_pet_stat.html. This pages contains a list of implied model
% properties of my_pet.
%
% Input:
%
% * metaData: structure
% * metaPar: structure
% * par: structure

%% Example of use
% load('results_my_pet.mat');
% print_stat_my_pet_html(metaData, metaPar, par)

% colours for statistics
%     '#FFC6A5'; '#FFFFFF'; '#C6E7DE'; '#CEEFBD'; '#CEEFBD';
%     '#DEF3BD'; '#FFFFC6'; '#BDC6DE'; '#C6B5DE'; '#DEBDDE';
%     '#F7BDDE'; '#C6E7DE'; '#FFFFC6'; '#FFC6A5'; '#FFFFC6'; 
%     '#F7BDDE'; '#BDC6DE'; '#FFFFC6'; '#FFFFFF'

oid = fopen([metaData.species,'_stat', '.html'], 'w+'); % % open file for writing, delete existing content
fprintf(oid, '%s\n' ,'<!DOCTYPE html>');
fprintf(oid, '%s\n' ,'<HTML>');
fprintf(oid, '%s\n' ,'  <HEAD>');
fprintf(oid,['    <TITLE>add-my-pet:', metaData.species, 'properties</TITLE>\n']);
fprintf(oid, '%s'   ,'    <META NAME = "keywords" ');
fprintf(oid, '%s\n' ,'     CONTENT="add-my-pet, Dynamic Energy Budget theory, DEBtool">');
  
% ------ calls the cascading style sheet (found in subfolder css):
fprintf(oid, '%s\n' ,'<link rel="stylesheet" type="text/css" href="../css/collectionstyle.css">'); 
 
fprintf(oid, '%s\n' , ' </HEAD>');
fprintf(oid, '%s\n\n','  <BODY>');
  
% print out text before the tables
fprintf(oid, '<H2>Implied properties for this entry</H2>');
fprintf(oid, ['<H2>Model: <a class="link" target = "_blank" href="http://www.debtheory.org/wiki/index.php?title=Typified_models" >&nbsp;', metaPar.model,' &nbsp;</a></H2>']);
  
   
% Print table with properties of the species :  
if strcmp(metaPar.model,'ssj') || strcmp(metaPar.model,'asj') || strcmp(metaPar.model,'abp') || strcmp(metaPar.model,'sbp') || strcmp(metaPar.model,'hep') || strcmp(metaPar.model,'hex')
fprintf(oid, '<H3>This page is still under construction - thank you for your patience</H3>');
% ------------------------------------------------------------------------
else
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
else 
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

[flds, nst] = fieldnmnst_st(stat); 
for  i = 1:length(fldsStat)
k = find(strcmp(fldsStat{i},flds));
statStd.(fldsStat{i}) = stat.(flds{k});
unitsStat.(fldsStat{i}) = txtStat.units.(flds{k});
labelStat.(fldsStat{i}) = txtStat.label.(flds{k});
% eval(['statStd.',fldsStat{i},' = stat.',fields{k},';']);
% eval(['unitsStat.',fldsStat{i},' = txtStat.units.',fields{k},';']);
% eval(['labelStat.',fldsStat{i},' = txtStat.label.',fields{k},';']);
end 
% 
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
    colStat.a_j = colStat.a_b;  colStat.L_j = colStat.L_b;  colStat.W_j = colStat.W_b; 
    colStat.VO_j = colStat.VO_b;  colStat.p_t_j = colStat.p_t_b; colStat.RQ_j = colStat.RQ_b;
end
    
% print the table with the properties :    
fprintf(oid, '    <TABLE id = "t01">\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="4">Implied properties at typical temperature temperature (%g deg. C)</TH></TR>\n', K2C(metaData.T_typical));
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH>symbol</TH><TH> value</TH><TH> units</TH><TH> description</TH></TR>\n');
  for i = 1:length(fldsStat)
    fprintf(oid, '    <TR BGCOLOR = "%s"> <TD>%s</TD> <TD>%g</TD> <TD>%s</TD><TD>%s</TD></TR>\n',...
          colStat.(fldsStat{i}), fldsStat{i}, stat.(fldsStat{i}), ...
       txtStat.units.(fldsStat{i}), txtStat.label.(fldsStat{i}));
  end
fprintf(oid, '    </TABLE>\n'); 
end
  
fprintf(oid, '  </BODY>\n');
fprintf(oid, '  </HTML>\n');
fclose(oid);





