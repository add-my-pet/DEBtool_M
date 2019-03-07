%% prt_report_my_pet
% Creates report_my_pet.html in specified directory

%%
function prt_report_my_pet(focusSpecies, comparisonSpecies, T, f, destinationFolder)
% created 2016/11/24 Starrlight;  modified 2018/08/22, 2019/02/22 Bas Kooijman

%% Syntax
% <../prt_report_my_pet.m *prt_report_my_pet*> (focusSpecies, T, f, destinationFolder) 

%% Description
% Writes report_my_pet.html with a list of parameters and implied model properties for selected species. 
% focusSpecies can be empty, or a single species;
% comparisonSpecies can be empty (if focusSpecies is specified), or a cell-string of entries.
% The parameters of the focusSpeces are obtained either from allStat.mat, or by metaData, metaPar and par, which are output structures of
% <http://www.debtheory.org/wiki/index.php?title=Mydata_file *mydata_my_pet*>,
% <http://www.debtheory.org/wiki/index.php?title=Pars_init_file *pars_init_my_pet*>
% and <http://www.debtheory.org/wiki/index.php?title=Pars_init_file *pars_init_my_pet*> 
% respectively, as part of the parameter estimation process.
%
% Input:
%
% * focusSpecies: character-string with name of entry of special interest or cellstring with structures: {metaData, metaPar, par}; might also be empty 
% * comparisonSpecies: cell string with entry names, might be empty
% * T: optional scalar with temperature in Kelvin for all species (default: T_typical, which is species-specific)
% * f: optional scalar scaled functional response (default: 1); it applies to all species
% * destinationFolder: optional string with destination folder the output html-file (default: current folder) 
%
% Output:
%
% * no Malab output, but a html-file is written with report-table and opened automatically in the system browser

%% Remarks
% If the focus species is specified by string (rather than by data), its parameters are obtained from allStat.mat. 
% The parameters of the comparison species are obtained from allStat.mat, and the data of creation of that file is indicated on the top of the report.
% AmPtool has allStat.mat, and is available via GitHub.
% AmPtool functions <../../../../../AmPtool/html/select.html *select*> or <../../../../../AmPtool/html/clade.html *clade*> can be used to create a cell string of comparison species.
%
% The difference between focus and comparison species only becomes important in the case of more than one comparison species and
%   color-coding is used to indicate how eccentric the focus-species is from the comparison-species.
% The lava color-scheme is used, from white (high) to black (low), via red and blue, to show the value of the eccentricity.
% This quantity is computed for each statistic and parameter and is the squared distance to the mean of the comparison species as a hyperbolically-transformed fraction 
%   of the variance for the comparison-species.
% Function <../../misc/html/color_lava.html *color_lava*> is used to convert the eccentricity to rgb-colors.
% If the focus species also occurs in the comparison species, it is removed from that list.
% So, if the comparison species all belong to the same genus, for instance, you can change your selection of focus species, and so change colors, without affecting numbers.
% If you just have a set of species and want to avoid colors, treat them all as comparison species, leaving focusSpecies empty.
% If model types differ among species in the tabel, only parameter and statistics fields for the focus species are shown.
% In absence of a focus species, the first comparison specie serves this role.
% 
% The search boxes in the top-line of the report can be used to symbols, units, descriptions, but also (on the top-right) to make selections from
%   the statictics and/or the parameters.
% NA means "not applicable": the parameter or statistic does not depend on temperature or food.
% nan means "not a number": the model for that species does not have that field.

%% Example of use
%
% * If results_My_Pet.mat exists in current directory (where "My_Pet" is replaced by the name of some species, but don't replace "my_pet"):
%   load('results_My_Pet.mat'); prt_report_my_pet({par, metaPar, txtPar, metaData}, [], T, f, destinationFolder)
% * prt_report_my_pet('Daphnia_magna')
% * prt_report_my_pet('Daphnia_pulex', [],  C2K(22), 0.8)
% * prt_report_my_pet('Lutjanus_analis', select('Lutjanus'), C2K(21))
% * prt_report_my_pet('Nasalis_larvatus', clade('Nasalis_larvatus'))

path_entries_web = 'https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries_web/'; % links of species names to AmP collection in table head

% focusSpecies initiation: get parameters (separate from get statistics because of 2 possible routes for getting pars)
if isempty(focusSpecies) % only comparion species, but treat first comparison species as pseudo-focus species, but no color-coding 
  focusSpecies = comparisonSpecies{1}; specList = {focusSpecies}; [parList.(specList{1}), metaPar, txtPar, metaData] = allStat2par(specList{1}); 
  allStatInfo = dir(which('allStat.mat')); datePrintNm = strsplit(allStatInfo.date, ' '); 
  datePrintNm = ['allStat version: ', datestr(datePrintNm(1), 'yyyy/mm/dd')];
  color = 0; n_spec = 1; % number of focus species, initiate total number of species
    
elseif iscell(focusSpecies) %  use metaData, metaPar and par to specify (one or more) focusSpecies
  par = focusSpecies{1}; metaPar = focusSpecies{2}; txtPar = focusSpecies{3}; metaData = focusSpecies{4}; metaDataFldNm = fieldnames(metaData);
  if isempty(strfind(metaDataFldNm{1}, '_')) % single species; name of species is recognized by the presence of "_"
    focusSpecies = metaData.species; specList = {focusSpecies}; color = 1; n_spec = length(specList); % number of focus species, initiate total number of species
    par = rmfield (par, 'free'); fldsPar = get_parfields(metaPar.model, 1);
    for i=1:length(fldsPar)
      parList.(specList{1}).(fldsPar{i}) = par.(fldsPar{i});
    end
    datePrintNm = ['date: ',datestr(date, 'yyyy/mm/dd')];
    if exist('comparisonSpecies', 'var') && ~isempty(comparisonSpecies)
      allStatInfo = dir(which('allStat.mat')); datePrint = strsplit(allStatInfo.date, ' '); 
      datePrintNm = [datePrintNm, '; allStat version: ', datestr(datePrint(1), 'yyyy/mm/dd')];
    end  
  else % multispecies; no color coding, so color = 0
    focusSpecies = metaDataFldNm; specList = focusSpecies; color = 0; n_spec = length(specList); % number of focus species, initiate total number of species
    for k = 1:n_spec
      par.(specList{k}) = rmfield (par.(specList{k}), 'free'); 
    end
    parList = par;
    datePrintNm = ['date: ',datestr(date, 'yyyy/mm/dd')];
    if exist('comparisonSpecies', 'var') && ~isempty(comparisonSpecies)
      allStatInfo = dir(which('allStat.mat')); datePrint = strsplit(allStatInfo.date, ' '); 
      datePrintNm = [datePrintNm, '; allStat version: ', datestr(datePrint(1), 'yyyy/mm/dd')];
    end  
  end

else  % use allStat.mat as parameter source for focusSpecies (always single species)
  specList = {focusSpecies}; [parList.(specList{1}), metaPar, txtPar, metaData] = allStat2par(specList{1}); 
  allStatInfo = dir(which('allStat.mat')); datePrintNm = strsplit(allStatInfo.date, ' '); 
  datePrintNm = ['allStat version: ', datestr(datePrintNm(1), 'yyyy/mm/dd')];
  color = 1; n_spec = 1; % number of focus species, initiate total number of species
end
if n_spec == 1
  modelList = {metaPar.model}; % initiate cell string for model
  tempList.(specList{1}) = metaData.T_typical; % initiate cell string for typical body temperature
  specListPrintNm = {strrep(specList{1}, '_', ' ')}; % initiate cell string for species names as they appear above the table
else
  modelList = metaPar.model; % initiate cell string for model
  specListPrintNm = cell(n_spec,1);
  for k = 1: n_spec
    tempList.(specList{k}) = metaData.(specList{k}).T_typical; % initiate cell string for typical body temperature
    specListPrintNm(k) = {strrep(specList{k}, '_', ' ')}; % initiate cell string for species names as they appear above the table
  end
end

fldsPar = fieldnmnst_st(parList.(specList{1})); % fieldnames of all pars are taken from first species only

if exist('T', 'var') % fix temperature for all species
  T_free = 0; 
else
  T_free = 1; % temperature for each species equals typical body temperature
end

% scaled functional response for all species
if ~exist('f', 'var') || isempty(f)
  f = 1;
end

% path+filename of output file
if exist('destinationFolder','var')
  fileName = [destinationFolder, 'report_', focusSpecies, '.html'];
else
  fileName = ['report_', specList{1}, '.html'];
end
 
% focus species: get statistics
for k = 1:n_spec
  if T_free
    Ti = tempList.(specList{k}); % temperature for statistics
  else
    Ti = T;
  end
  [statList.(specList{k}), txtStat.(specList{k})] = statistics_st(modelList{k}, parList.(specList{k}), Ti, f);
  statList.(specList{k}) = rmfield(statList.(specList{k}), {'T','f'}); % remove fields T and f, because it is already in txtStat
end

fldsStat = fieldnmnst_st(statList.(specList{1})); % fieldnames of all statistics are taken from first species only

% comparison species
if exist('comparisonSpecies', 'var') && ~isempty(comparisonSpecies)
  comparisonSpecies = comparisonSpecies(~ismember(comparisonSpecies,focusSpecies)); % remove focus species from comparison species
  specList = [specList; comparisonSpecies(:)]; n_spec = length(specList); % list of all entries to be shown in the table
  for k = 2:n_spec
    % parameters
    [parList.(specList{k}), metaPark, txtPark, metaDatak] = allStat2par(specList{k});
    modelList{k} = metaPark.model;
    if ~strcmp(modelList{1},modelList{k})
      fldsPark = get_parfields(modelList{k}, 1);
      for j = 1:length(fldsPar)
        if ~ismember(fldsPar{j}, fldsPark)
          parList.(specList{k}).(fldsPar{j}) = NaN;
        end
      end
    end
    tempList.(specList{k}) = metaDatak.T_typical;
    if T_free
      Ti = tempList.(specList{k}); % temperature for statistics
    else
      Ti = T;
    end
    % statistics
    [statList.(specList{k}), txtStat.(specList{k})] = statistics_st(modelList{k}, parList.(specList{k}), Ti, f);
    specListPrintNm{k} = strrep(specList{k}, '_', ' '); % list of all species names to be shown in the table
    if ~strcmp(modelList{1},modelList{k})
      statList.(specList{k}) = rmfield(statList.(specList{k}), {'T','f'}); % remove fields T and f, because it is already in txtStat
      fldsStatk = fieldnmnst_st(statList.(specList{k})); % fieldnames of all statistics
      for j = 1:length(fldsStat)
        if ~ismember(fldsStat{j}, fldsStatk)
          statList.(specList{k}).(fldsStat{j}) = NaN;
          txtStat.(specList{k}).temp.(fldsStat{j}) = NaN;
        end
      end
    end
  end
end

% font color-coding, based on eccentricity of focus species, relative to comparison species
if color == 1 && n_spec > 2
  % parameters
  eccPar = zeros(length(fldsPar),1); % initiate eccentricity quantifyer
  for i = 1:length(fldsPar)
    pari = zeros(n_spec-1,1);
    for k = 2:n_spec % fill parameters
      pari(k-1) = parList.(specList{k}).(fldsPar{i});
    end
    pariMean = mean(pari); pariVar = max(1e-4, var(pari)); 
    eccPar(i) = (parList.(specList{1}).(fldsPar{i}) - pariMean)^2/ pariVar;  
    eccPar(i) = 0.9 * eccPar(i)/(1 + eccPar(i)); % make sure that eccentricity is between 0 and 0.9 (avoiding white for eccentricity 1)
    if isnan(eccPar(i))
      eccPar(i) = 0;
    end
  end
 
  % statistics
  eccStat = zeros(length(fldsStat),1); % initiate eccentricity quantifyer
  for i = 1:length(fldsStat)
    stati = zeros(n_spec-1,1);
    for k = 2:n_spec % fill statistics
      stati(k-1) = statList.(specList{k}).(fldsStat{i});
    end
    statMean = mean(stati); statVar = max(1e-4, var(stati)); 
    eccStat(i) = (statList.(specList{1}).(fldsStat{i}) - statMean)^2/ statVar;  
    eccStat(i) = 0.9 * eccStat(i)/(1 + eccStat(i)); % make sure that eccentricity is between 0 and 0.9 (avoiding white for eccentricity 1)
    if isnan(eccStat(i))
      eccStat(i) = 0;
    end
  end
end

% write table
oid = fopen(fileName, 'w+'); % open file for writing, delete existing content

fprintf(oid, '<!DOCTYPE html>\n');
fprintf(oid, '<HTML>\n');
fprintf(oid, '<HEAD>\n');
fprintf(oid,['  <TITLE>', specList{1}, '</TITLE>\n']);
fprintf(oid, '  <style>\n');

fprintf(oid, '    #InputSymbol {\n');
fprintf(oid, '      width: 10%%; /* Width of search field */\n');
fprintf(oid, '      font-size: 14px; /* Increase font-size */\n');
fprintf(oid, '      border: 1px solid #ddd; /* Add a grey border */\n');
fprintf(oid, '      margin-bottom: 12px; /* Add some space below the input */\n');
fprintf(oid, '    }\n\n');

fprintf(oid, '    #InputUnits {\n');
fprintf(oid, '      width: 10%%; /* Width of search field */\n');
fprintf(oid, '      font-size: 14px; /* Increase font-size */\n');
fprintf(oid, '      border: 1px solid #ddd; /* Add a grey border */\n');
fprintf(oid, '      margin-bottom: 12px; /* Add some space below the input */\n');
fprintf(oid, '    }\n\n');

fprintf(oid, '    #InputLabel {\n');
fprintf(oid, '      width: 10%%; /* Width of search field */\n');
fprintf(oid, '      font-size: 14px; /* Increase font-size */\n');
fprintf(oid, '      border: 1px solid #ddd; /* Add a grey border */\n');
fprintf(oid, '      margin-bottom: 12px; /* Add some space below the input */\n');
fprintf(oid, '    }\n\n');

fprintf(oid, '    #InputShort {\n');
fprintf(oid, '      width: 15%%; /* Width of toggle field */\n');
fprintf(oid, '      font-size: 14px; /* Increase font-size */\n');
fprintf(oid, '      border: 1px solid #ddd; /* Add a grey border */\n');
fprintf(oid, '      margin-bottom: 12px; /* Add some space below the input */\n');
fprintf(oid, '    }\n\n');

fprintf(oid, '    #specPrintNm {\n'); 
fprintf(oid, '      background-color: #f2f2f2\n');                          % grey species background
fprintf(oid, '    }\n\n');

fprintf(oid, '    #species {\n');
fprintf(oid, '      color: rgb(0,0,255)\n');                                % blue font for species names
fprintf(oid, '    }\n\n');

fprintf(oid, '    #head {\n');
fprintf(oid, '      background-color: #FFE7C6\n');                          % pink header background
fprintf(oid, '    }\n\n');

fprintf(oid, '    tr:nth-child(even){background-color: #f2f2f2}\n');        % grey on even rows
fprintf(oid, '    td:nth-child(odd){border-left: solid 1px black}\n\n');  % lines between species

if color == 1 && n_spec > 2 % font colors if focus species and more than one comparison species are present
  % parameters
  for i = 1:length(fldsPar)
    rgb = round(255 * color_lava(eccPar(i))); 
fprintf(oid,['    #', fldsPar{i}, ' {\n']);
fprintf(oid,['      color: rgb(', num2str(rgb(1)), ',', num2str(rgb(2)), ',', num2str(rgb(3)), ')\n']); % font color for parameter i
fprintf(oid, '    }\n\n');
  end 
  % statistics
  for i = 1:length(fldsStat)
    rgb = round(255 * color_lava(eccStat(i))); 
fprintf(oid,['    #', fldsStat{i}, ' {\n']);
fprintf(oid,['      color: rgb(', num2str(rgb(1)), ',', num2str(rgb(2)), ',', num2str(rgb(3)), ')\n']); % font color for parameter i
fprintf(oid, '    }\n\n');
  end
end

fprintf(oid, '  </style>\n\n');

fprintf(oid, '</HEAD>\n\n');
fprintf(oid, '<BODY>\n\n');
			
% search boxes above the table
fprintf(oid, '      <div>\n');
fprintf(oid, '        <input type="text" id="InputSymbol" onkeyup="FunctionSymbol()" placeholder="Search for symbol ..">\n');
fprintf(oid, '        <input type="text" id="InputUnits"  onkeyup="FunctionUnits()"  placeholder="Search for units ..">\n');
fprintf(oid, '        <input type="text" id="InputLabel"  onkeyup="FunctionLabel()"  placeholder="Search for label ..">\n');
fprintf(oid, '        <input type="text" id="InputShort"  onkeyup="FunctionShort()"  placeholder="Short/Medium/Long/Pars" title="Type S or M or L or P">\n');
fprintf(oid, '      </div>\n\n');

% open table
fprintf(oid, '      <TABLE id="Table">\n');

% table head:
% row with species print names and source dates
fprintf(oid, '        <TR id="species"> <TH colspan="2"></TH>\n');
for k = 1:n_spec
    if k == 1 && ~isempty(strfind(datePrintNm, 'date')) % no link if focusSpecies is specified by data, rather than by string
fprintf(oid, '          <TH colspan="2" id="specPrintNm">%s</TH>\n', specListPrintNm{k});
    else % links to AmP entries
fprintf(oid, '          <TH colspan="2" id="specPrintNm"><a href="%s%s/%s_res.html">%s</a></TH>\n', path_entries_web, specList{k}, specList{k}, specListPrintNm{k});
    end
end
fprintf(oid, '          <TH></TH> <TH>%s</TH>\n', datePrintNm);
fprintf(oid, '        </TR>\n\n');
% row with table header
fprintf(oid, '        <TR id="head"> <TH>symbol</TH> <TH>units</TH>\n');
for k = 1:n_spec
fprintf(oid, '          <TH>value</TH> <TH>&deg;C</TH>\n');
end
fprintf(oid, '          <TH>func resp</TH> <TH>description</TH>\n');
fprintf(oid, '        </TR>\n\n');
% row with model
fprintf(oid, '        <TR id="model"> <TD style="font-weight:bold">model</TD> <TD>-</TD>\n');
for k = 1:n_spec
fprintf(oid,['          <TD>', modelList{k}, '</TD> <TD>NA</TD>\n']);
end
fprintf(oid, '          <TD align="center">NA</TD> <TD>typified model</TD>\n');
fprintf(oid, '        </TR>\n\n');
% row with typical body temperature
fprintf(oid, '        <TR id="T_typical"> <TD style="font-weight:bold">T_typical</TD> <TD>&deg;C</TD>\n');
for k = 1:n_spec
fprintf(oid,['          <TD>', num2str(K2C(tempList.(specList{k}))), '</TD> <TD>NA</TD>\n']);
end
fprintf(oid, '          <TD align="center">NA</TD> <TD>typical body temperature</TD>\n');
fprintf(oid, '        </TR>\n\n');

% parameters:    
for i = 1:length(fldsPar)
  txtPar.fresp.(fldsPar{i}) = 'NA'; % no parameter depends on functional response
  if isempty(strfind(txtPar.units.(fldsPar{i}),'d'))
    txtPar.temp.(fldsPar{i}) = 'NA';
  else
    txtPar.temp.(fldsPar{i}) = num2str(20); % time-dependent pars are at T_ref
  end
fprintf(oid, '        <TR id="%s"> <TD style="font-weight:bold">%s</TD> <TD>%s</TD>\n', fldsPar{i}, fldsPar{i}, txtPar.units.(fldsPar{i}));
  for k = 1:n_spec
    if ~isfield(parList.(specList{k}),(fldsPar{i}))
      parList.(specList{k}).(fldsPar{i}) = NaN; txtPar.temp.(fldsPar{i}) = 'NA';
    end
fprintf(oid, '          <TD>%g</TD> <TD>%s</TD>\n', parList.(specList{k}).(fldsPar{i}), txtPar.temp.(fldsPar{i}));
  end
fprintf(oid, '          <TD align="center">%s</TD> <TD>%s</TD>\n', txtPar.fresp.(fldsPar{i}), txtPar.label.(fldsPar{i}));
fprintf(oid, '        </TR>\n\n');
end 

% statistics
for i = 1:length(fldsStat)
  if isnan(txtStat.(specList{1}).fresp.(fldsStat{i}))
    txtStat.(specList{1}).fresp.(fldsStat{i}) = 'NA';
  else
    txtStat.(specList{1}).fresp.(fldsStat{i}) = num2str(txtStat.(specList{1}).fresp.(fldsStat{i}));
  end
fprintf(oid, '        <TR id="%s"> <TD style="font-weight:bold">%s</TD> <TD>%s</TD>\n', fldsStat{i}, fldsStat{i}, txtStat.(specList{1}).units.(fldsStat{i}));
  for k = 1:n_spec
  if isnan(txtStat.(specList{k}).temp.(fldsStat{i}))
    txtStat.(specList{k}).temp.(fldsStat{i}) = 'NA';
  else
    txtStat.(specList{k}).temp.(fldsStat{i}) = num2str(K2C(txtStat.(specList{k}).temp.(fldsStat{i})));
  end
fprintf(oid, '          <TD>%g</TD> <TD>%s</TD>\n',  statList.(specList{k}).(fldsStat{i}), txtStat.(specList{k}).temp.(fldsStat{i}));
  end
  label = txtStat.(specList{1}).label.(fldsStat{i}); label = strrep(label, '<', '&lt;'); label = strrep(label, '>', '&gt;'); % html cannot show < or >
fprintf(oid, '          <TD align="center">%s</TD> <TD>%s</TD>\n', txtStat.(specList{1}).fresp.(fldsStat{i}), label);
fprintf(oid, '        </TR>\n');
end 

% close table
fprintf(oid, '      </TABLE>\n\n');

% search/selection facilities
% symbol
fprintf(oid, '      <script>\n');
fprintf(oid, '        function FunctionSymbol() {\n');
fprintf(oid, '          // Declare variables\n');
fprintf(oid, '          var input, filter, table, tr, td, i;\n');
fprintf(oid, '          input = document.getElementById("InputSymbol");\n');
fprintf(oid, '          filter = input.value.toUpperCase();\n');
fprintf(oid, '          table = document.getElementById("Table");\n');
fprintf(oid, '          tr = table.getElementsByTagName("tr");\n\n');
%
fprintf(oid, '          // Loop through all table rows, and hide those who don''t match the search query\n');
fprintf(oid, '          for (i = 0; i < tr.length; i++) {\n');
fprintf(oid, '          td = tr[i].getElementsByTagName("td")[0];\n');
fprintf(oid, '          if (td) {\n');
fprintf(oid, '            if (td.innerHTML.toUpperCase().indexOf(filter) > -1) {\n');
fprintf(oid, '              tr[i].style.display = "";\n');
fprintf(oid, '            } else {\n');
fprintf(oid, '              tr[i].style.display = "none";\n');
fprintf(oid, '              }\n');
fprintf(oid, '            }\n');
fprintf(oid, '          }\n');
fprintf(oid, '        }\n\n');
% units
fprintf(oid, '        function FunctionUnits() {\n');
fprintf(oid, '          // Declare variables\n');
fprintf(oid, '          var input, filter, table, tr, td, i;\n');
fprintf(oid, '          input = document.getElementById("InputUnits");\n');
fprintf(oid, '          filter = input.value.toUpperCase();\n');
fprintf(oid, '          table = document.getElementById("Table");\n');
fprintf(oid, '          tr = table.getElementsByTagName("tr");\n\n');
%
fprintf(oid, '          // Loop through all table rows, and hide those who don''t match the search query\n');
fprintf(oid, '          for (i = 0; i < tr.length; i++) {\n');
fprintf(oid, '          td = tr[i].getElementsByTagName("td")[2];\n');
fprintf(oid, '          if (td) {\n');
fprintf(oid, '            if (td.innerHTML.toUpperCase().indexOf(filter) > -1) {\n');
fprintf(oid, '              tr[i].style.display = "";\n');
fprintf(oid, '            } else {\n');
fprintf(oid, '              tr[i].style.display = "none";\n');
fprintf(oid, '              }\n');
fprintf(oid, '            }\n');
fprintf(oid, '          }\n');
fprintf(oid, '        }\n\n');
% label (= description)
fprintf(oid, '        function FunctionLabel() {\n');
fprintf(oid, '          // Declare variables\n');
fprintf(oid, '          var input, filter, table, tr, td, i;\n');
fprintf(oid, '          input = document.getElementById("InputLabel");\n');
fprintf(oid, '          filter = input.value.toUpperCase();\n');
fprintf(oid, '          table = document.getElementById("Table");\n');
fprintf(oid, '          tr = table.getElementsByTagName("tr");\n\n');
%
fprintf(oid, '          // Loop through all table rows, and hide those who don''t match the search query\n');
fprintf(oid, '          for (i = 0; i < tr.length; i++) {\n');
fprintf(oid, '          td = tr[i].getElementsByTagName("td")[5];\n');
fprintf(oid, '          if (td) {\n');
fprintf(oid, '            if (td.innerHTML.toUpperCase().indexOf(filter) > -1) {\n');
fprintf(oid, '              tr[i].style.display = "";\n');
fprintf(oid, '            } else {\n');
fprintf(oid, '              tr[i].style.display = "none";\n');
fprintf(oid, '              }\n');
fprintf(oid, '            }\n');
fprintf(oid, '          }\n');
fprintf(oid, '        }\n\n');
% selection for short/medium/long/pars
fprintf(oid, '        function FunctionShort() {\n');
fprintf(oid, '          // Declare variables\n');
fprintf(oid, '          var input, filter, table, tr, td, i;\n');
fprintf(oid, '          input = document.getElementById("InputShort");\n');
fprintf(oid, '          filter = input.value.toUpperCase();\n');
fprintf(oid, '          table = document.getElementById("Table");\n');
fprintf(oid, '          tr = table.getElementsByTagName("tr");\n\n');
%
fprintf(oid, '          // Loop through all table rows, and show some from the long list\n');
% filter S: popular short selection of some statistics
fprintf(oid, '          if (filter == "S") {\n');
fprintf(oid, '            for (i = 0; i < tr.length; i++) {\n');
fprintf(oid, '              td = tr[i].getElementsByTagName("td")[0];\n');
fprintf(oid, '              if (td) {\n');
fprintf(oid, '                if (\n');
fprintf(oid, '                    td.innerHTML == "model" ||\n');
fprintf(oid, '                    td.innerHTML == "T_typical" ||\n');
fprintf(oid, '                    td.innerHTML == "c_T" ||\n');
fprintf(oid, '                    td.innerHTML == "Ww_0" ||\n');
fprintf(oid, '                    td.innerHTML == "Ww_b" ||\n');
fprintf(oid, '                    td.innerHTML == "Ww_p" ||\n');
fprintf(oid, '                    td.innerHTML == "Ww_i" ||\n');
fprintf(oid, '                    td.innerHTML == "a_b" ||\n');
fprintf(oid, '                    td.innerHTML == "a_p" ||\n');
fprintf(oid, '                    td.innerHTML == "a_m" ||\n');
fprintf(oid, '                    td.innerHTML == "t_starve" ||\n');
fprintf(oid, '                    td.innerHTML == "J_Ci" ||\n');
fprintf(oid, '                    td.innerHTML == "J_Hi" ||\n');
fprintf(oid, '                    td.innerHTML == "J_Oi" ||\n');
fprintf(oid, '                    td.innerHTML == "J_Ni" ||\n');
fprintf(oid, '                    td.innerHTML == "J_Xi" ||\n');
fprintf(oid, '                    td.innerHTML == "J_Pi" ||\n');
fprintf(oid, '                    td.innerHTML == "p_Ti" ||\n');
fprintf(oid, '                    td.innerHTML == "r_B" ||\n');
fprintf(oid, '                    td.innerHTML == "R_i" ||\n');
fprintf(oid, '                    td.innerHTML == "del_V"\n');
fprintf(oid, '                  ) {\n');
fprintf(oid, '                  tr[i].style.display = "";\n');
fprintf(oid, '                } else {\n');
fprintf(oid, '                  tr[i].style.display = "none";\n');
fprintf(oid, '                }\n');
fprintf(oid, '              }\n');
fprintf(oid, '            }\n');
% filter M: statistics as printed on AmP website on pages my_pet_stat.html
fprintf(oid, '          } else if (filter == "M") {\n');
fprintf(oid, '            for (i = 0; i < tr.length; i++) {\n');
fprintf(oid, '              td = tr[i].getElementsByTagName("td")[0];\n');
fprintf(oid, '              if (td) {\n');
fprintf(oid, '                if (\n');
fprintf(oid, '                    td.innerHTML == "model" ||\n');
fprintf(oid, '                    td.innerHTML == "T_typical" ||\n');
fprintf(oid, '                    td.innerHTML == "z" ||\n');
fprintf(oid, '                    td.innerHTML == "c_T" ||\n');
fprintf(oid, '                    td.innerHTML == "s_M" ||\n');
fprintf(oid, '                    td.innerHTML == "s_Hbp" ||\n');
fprintf(oid, '                    td.innerHTML == "s_s" ||\n');
fprintf(oid, '                    td.innerHTML == "E_0" ||\n');
fprintf(oid, '                    td.innerHTML == "Ww_0" ||\n');
fprintf(oid, '                    td.innerHTML == "Ww_b" ||\n');
fprintf(oid, '                    td.innerHTML == "Ww_p" ||\n');
fprintf(oid, '                    td.innerHTML == "Ww_i" ||\n');
fprintf(oid, '                    td.innerHTML == "a_b" ||\n');
fprintf(oid, '                    td.innerHTML == "a_p" ||\n');
fprintf(oid, '                    td.innerHTML == "a_99" ||\n');
fprintf(oid, '                    td.innerHTML == "a_m" ||\n');
fprintf(oid, '                    td.innerHTML == "t_starve" ||\n');
fprintf(oid, '                    td.innerHTML == "J_Ci" ||\n');
fprintf(oid, '                    td.innerHTML == "J_Hi" ||\n');
fprintf(oid, '                    td.innerHTML == "J_Oi" ||\n');
fprintf(oid, '                    td.innerHTML == "J_Ni" ||\n');
fprintf(oid, '                    td.innerHTML == "J_Xi" ||\n');
fprintf(oid, '                    td.innerHTML == "J_Pi" ||\n');
fprintf(oid, '                    td.innerHTML == "p_Ti" ||\n');
fprintf(oid, '                    td.innerHTML == "r_B" ||\n');
fprintf(oid, '                    td.innerHTML == "R_i" ||\n');
fprintf(oid, '                    td.innerHTML == "N_i" ||\n');
fprintf(oid, '                    td.innerHTML == "del_V" ||\n');
fprintf(oid, '                    td.innerHTML == "W_dWm" ||\n');
fprintf(oid, '                    td.innerHTML == "dWm" ||\n');
fprintf(oid, '                    td.innerHTML == "del_Wb" ||\n');
fprintf(oid, '                    td.innerHTML == "del_Wp" ||\n');
fprintf(oid, '                    td.innerHTML == "t_E" ||\n');
fprintf(oid, '                    td.innerHTML == "xi_WE"\n');
fprintf(oid, '                  ) {\n');
fprintf(oid, '                  tr[i].style.display = "";\n');
fprintf(oid, '                } else {\n');
fprintf(oid, '                  tr[i].style.display = "none";\n');
fprintf(oid, '                }\n');
fprintf(oid, '              }\n');
fprintf(oid, '            }\n');
% filter L: all statistics
fprintf(oid, '          } else if (filter == "L") {\n');
fprintf(oid, '            for (i = 0; i < tr.length; i++) {\n');
fprintf(oid, '              td = tr[i].getElementsByTagName("td")[0];\n');
fprintf(oid, '              if (td) {\n');
fprintf(oid, '                if (\n');
fprintf(oid, '                    td.innerHTML == "model" ||\n');
fprintf(oid, '                    td.innerHTML == "T_typical" ||\n');
for j = 1:length(fldsStat)-1
fprintf(oid,['                    td.innerHTML == "', fldsStat{j},'" ||\n']);
end
fprintf(oid,['                    td.innerHTML == "', fldsStat{end},'"\n']);
fprintf(oid, '                  ) {\n');
fprintf(oid, '                  tr[i].style.display = "";\n');
fprintf(oid, '                } else {\n'); % show all
fprintf(oid, '                  tr[i].style.display = "none";\n');
fprintf(oid, '                }\n');
fprintf(oid, '              }\n');
fprintf(oid, '            }\n');
% filter P: parameters only
fprintf(oid, '          } else if (filter == "P") {\n');
fprintf(oid, '            for (i = 0; i < tr.length; i++) {\n');
fprintf(oid, '              td = tr[i].getElementsByTagName("td")[0];\n');
fprintf(oid, '              if (td) {\n');
fprintf(oid, '                if (\n');
fprintf(oid, '                    td.innerHTML == "model" ||\n');
for j = 1:length(fldsPar)-1
fprintf(oid,['                    td.innerHTML == "', fldsPar{j},'" ||\n']);
end
fprintf(oid,['                    td.innerHTML == "', fldsPar{end},'"\n']);
fprintf(oid, '                  ) {\n');
fprintf(oid, '                  tr[i].style.display = "";\n');
fprintf(oid, '                } else {\n'); % show all
fprintf(oid, '                  tr[i].style.display = "none";\n');
fprintf(oid, '                }\n');
fprintf(oid, '              }\n');
fprintf(oid, '            }\n');
% no filter: parameters and statistics
fprintf(oid, '          } else {\n'); % complete list
fprintf(oid, '            for (i = 0; i < tr.length; i++) {\n');
fprintf(oid, '              tr[i].style.display = "";\n');
fprintf(oid, '            }\n');
fprintf(oid, '          }\n');
fprintf(oid, '        }\n\n');

fprintf(oid, '      </script>\n');

fprintf(oid, '</BODY>\n');
fprintf(oid, '</HTML>\n');

fclose(oid);

web(fileName,'-browser') % open html in systems browser
%web(fileName)

