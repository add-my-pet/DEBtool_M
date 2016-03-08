%% print_my_pet_html
% Creates my_pet.html 

%%
function print_my_pet_html(metaData, metaPar, par, txtPar)
% created 2015/04/11 by Starrlight
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

% field names for all parameters:
par = rmfield_wtxt(par, 'free');
parFields = fields(par);

% default parameters for model:
[coreParFields] = get_parfields(metaPar.model);

% temperature parameters
tempParFields = {'T_A', 'T_ref'};

% get chemical parameters fields (standard ones)
par_auto = addchem([], [], [], [], metaData.phylum, metaData.class);
chemParFields = fields(par_auto);

% separate out the 'other parameters'
parFields = setdiff(parFields, coreParFields);
otherParFields = setdiff(parFields, chemParFields);
otherParFields = setdiff(otherParFields, tempParFields);

% start printing the html file
oid = fopen([species, '.html'], 'w+'); % % open file for writing, delete existing content
fprintf(oid, '%s\n' ,'<!DOCTYPE html>');
fprintf(oid, '%s\n' ,'<HTML>');
fprintf(oid, '%s\n' ,'  <HEAD>');
fprintf(oid,['    <TITLE>add-my-pet:', species, '</TITLE>\n']);
fprintf(oid, '%s'   ,'    <META NAME = "keywords" ');
fprintf(oid, '%s\n' ,'     CONTENT="add-my-pet, Dynamic Energy Budget theory, DEBtool">');
  
% ------ calls the cascading style sheet (found in subfolder css):
fprintf(oid, '%s\n' ,'<link rel="stylesheet" type="text/css" href="../css/collectionstyle.css">'); 
  
fprintf(oid, '%s\n' , ' </HEAD>');
fprintf(oid, '%s\n\n','  <BODY>');

%% print out text before the tables
fprintf(oid, ['<H2>Paramters values for this entry</H2>']);
fprintf(oid, ['<H2>Model: <a class="link" target = "_blank" href="http://www.debtheory.org/wiki/index.php?title=Typified_models" >&nbsp;', metaPar.model,' &nbsp;</a></H2>']);
  
%% print table with primary parameters :
fprintf(oid, '    <TABLE id = "t01">\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="4">Primary parameters at reference temperature (%g deg. C)</TH></TR>\n', par.T_ref - 273.15);
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH>symbol</TH><TH> value</TH><TH> units</TH><TH> description</TH></TR>\n');
  for i = 1:length(coreParFields)
    fprintf(oid, '    <TR BGCOLOR = "%s"> <TD>%s</TD> <TD>%g</TD> <TD>%s</TD><TD>%s</TD></TR>\n',...
          '#FFFFFF', coreParFields{i}, par.(coreParFields{i}), ...
       txtPar.units.(coreParFields{i}), txtPar.label.(coreParFields{i}));
  end
fprintf(oid, '    </TABLE>\n'); 

%% print table with parameters which are specific for the entry:
fprintf(oid, '    <TABLE id = "t01">\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="4">Parameters specific for this entry at reference temperature (%g deg. C)</TH></TR>\n', par.T_ref - 273.15);
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH>symbol</TH><TH> value</TH><TH> units</TH><TH> description</TH></TR>\n');
  for i = 1:length(otherParFields)
    fprintf(oid, '    <TR BGCOLOR = "%s"> <TD>%s</TD> <TD>%g</TD> <TD>%s</TD><TD>%s</TD></TR>\n',...
          '#FFFFFF', otherParFields{i}, par.(otherParFields{i}), ...
       txtPar.units.(otherParFields{i}), txtPar.label.(otherParFields{i}));
  end
fprintf(oid, '    </TABLE>\n'); 

%% print table with parameters which relate to temperature correction:
% please keep in mind that these are only T_A and T_ref, other parameters
% related to temperature correction will appear in the 'other parameters'
% table unless code further up is changed.
fprintf(oid, '    <TABLE id = "t01">\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="4">Temperature parameters</TH></TR>\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH>symbol</TH><TH> value</TH><TH> units</TH><TH> description</TH></TR>\n');
  for i = 1:length(tempParFields)
    fprintf(oid, '    <TR BGCOLOR = "%s"> <TD>%s</TD> <TD>%g</TD> <TD>%s</TD><TD>%s</TD></TR>\n',...
          '#FFFFFF', tempParFields{i}, par.(tempParFields{i}), ...
       txtPar.units.(tempParFields{i}), txtPar.label.(tempParFields{i}));
  end
fprintf(oid, '    </TABLE>\n');

%% print table with chemical potentials and specific densities:
fprintf(oid, '    <TABLE id = "t01">\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="5">Chemical parameters</TH></TR>\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH></TH><TH>Food</TH><TH> Structure</TH><TH> Reserve</TH><TH> Faeces</TH></TR>\n');
fprintf(oid, '    <TR BGCOLOR = "%s"> <TD>%s</TD> <TD>%g</TD> <TD>%g</TD> <TD>%g</TD><TD>%g</TD></TR>\n',...
'#FFFFFF',  'Chemical potentials (J/C-mol)', par.mu_X, par.mu_V, par.mu_E, par.mu_P);
fprintf(oid, '    <TR BGCOLOR = "%s"> <TD>%s</TD> <TD>%g</TD> <TD>%g</TD> <TD>%g</TD><TD>%g</TD></TR>\n',...
'#FFFFFF',  'Specific density for dry weight (g/cm^3)', par.d_X, par.d_V, par.d_E, par.d_P);
fprintf(oid, '    </TABLE>\n');

%% Print table with chemical indices
fprintf(oid, '    <TABLE id = "t01">\n');
% --------------- organic chemical indices --------------------------------
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH></TH><TH></TH><TH>Food</TH><TH> Structure</TH><TH> Reserve</TH><TH> Faeces</TH></TR>\n');
fprintf(oid, '    <TR BGCOLOR = "%s"> <TD rowspan="4">%s</TD><TD BGCOLOR = "#FFE7C6">%s</TD> <TD>%g</TD> <TD>%g</TD><TD>%g</TD><TD>%g</TD></TR>\n',...
'#FFFFFF','Chemical indices for organics', 'Carbon', par.n_CX, par.n_CV, par.n_CE, par.n_CP);
fprintf(oid, '    <TR BGCOLOR = "%s"><TD BGCOLOR = "#FFE7C6">%s</TD> <TD>%g</TD> <TD>%g</TD><TD>%g</TD><TD>%g</TD></TR>\n',...
'#FFFFFF','Hydrogen', par.n_HX, par.n_HV, par.n_HE, par.n_HP);
fprintf(oid, '    <TR BGCOLOR = "%s"><TD BGCOLOR = "#FFE7C6">%s</TD> <TD>%g</TD> <TD>%g</TD><TD>%g</TD><TD>%g</TD></TR>\n',...
'#FFFFFF','Oxygen', par.n_OX, par.n_OV, par.n_OE, par.n_OP);
fprintf(oid, '    <TR BGCOLOR = "%s"><TD BGCOLOR = "#FFE7C6">%s</TD> <TD>%g</TD> <TD>%g</TD><TD>%g</TD><TD>%g</TD></TR>\n',...
'#FFFFFF','Nitrogen', par.n_NX, par.n_NV, par.n_NE, par.n_NP);
% --------------- mineral chemical indices --------------------------------
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH></TH><TH></TH><TH>CO<sub>2</sub></TH><TH> H<sub>2</sub>O</TH><TH>O<sub>2</sub></TH><TH> NH<sub>3</sub></TH></TR>\n');
fprintf(oid, '    <TR BGCOLOR = "%s"> <TD rowspan="4">%s</TD><TD BGCOLOR = "#FFE7C6">%s</TD> <TD>%g</TD> <TD>%g</TD><TD>%g</TD><TD>%g</TD></TR>\n',...
'#FFFFFF','Chemical indices for minerals', 'Carbon', par.n_CC, par.n_CH, par.n_CO, par.n_CN);
fprintf(oid, '    <TR BGCOLOR = "%s"><TD BGCOLOR = "#FFE7C6">%s</TD> <TD>%g</TD> <TD>%g</TD><TD>%g</TD><TD>%g</TD></TR>\n',...
'#FFFFFF','Hydrogen', par.n_HC, par.n_HH, par.n_HO, par.n_HN);
fprintf(oid, '    <TR BGCOLOR = "%s"><TD BGCOLOR = "#FFE7C6">%s</TD> <TD>%g</TD> <TD>%g</TD><TD>%g</TD><TD>%g</TD></TR>\n',...
'#FFFFFF','Oxygen', par.n_OC, par.n_OH, par.n_OO, par.n_ON);
fprintf(oid, '    <TR BGCOLOR = "%s"><TD BGCOLOR = "#FFE7C6">%s</TD> <TD>%g</TD> <TD>%g</TD><TD>%g</TD><TD>%g</TD></TR>\n',...
'#FFFFFF','Nitrogen', par.n_NC, par.n_NH, par.n_NO, par.n_NN);
fprintf(oid, '    </TABLE>\n');

%% close the file
fprintf(oid, '  </BODY>\n');
fprintf(oid, '  </HTML>\n');
fclose(oid);





