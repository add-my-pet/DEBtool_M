%% prt_results_my_pet
% writes results of estimation to my_pet_res.html

%%
function prt_results_my_pet(parPets, metaPar, txtPar, data, metaData, txtData, prdData)
% created 2019/03/01 by Bas Kooijman, modified 2019/07/01, 2022/01/21

%% Syntax
% <../prt_results_my_pet.m *prt_results_my_pet*> (parPets, metaPar, txtPar, data, metaData, txtData, prdData) 

%% Description
% Writes results of an estimation to my_pet_res.html for each pet, as specified by pets. 
% Input is the same as for results_pets, but inputs auxData and  weights are not required in this function
%
% Input:
%
% * parPets: cell string of parameters for each pet
% * metaPar: structure with information on parameters
% * txtPar: structure with text for parameters
% * data: structure with data for species
% * metaData: structure with information on the data
% * txtData: structure with text for the data
% * prdData: structure with predictions for the data
%
% Output:
%
% * no Matlab output, text is written to html

%% Remarks
% Function prt_results2screen writes to screen; subfunction of results_pets.

  global pets 
  
  n_pets = length(pets);
    
  for i = 1:n_pets
    fileName = [pets{i}, '_res.html']; % char string with file name of output file
    oid = fopen(fileName, 'w+'); % open file for writing, delete existing content

    fprintf(oid, '<!DOCTYPE html>\n');
    fprintf(oid, '<HTML>\n');
    fprintf(oid, '<HEAD>\n');
    fprintf(oid, '  <TITLE>%s</TITLE>\n',  pets{i});
    fprintf(oid, '  <style>\n');
    fprintf(oid, '    div.prd {\n');
    fprintf(oid, '      width: 50%%;\n');
    fprintf(oid, '      float: left;\n'); 
    fprintf(oid, '    }\n\n');
    
    fprintf(oid, '    div.par {\n');
    fprintf(oid, '      width: 50%%;\n');
    fprintf(oid, '      float: right;\n');
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    p.clear {\n');
    fprintf(oid, '      clear: both;\n');
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    .head {\n');
    fprintf(oid, '      background-color: #FFE7C6\n');                  % pink header background
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    .psd {\n');
    fprintf(oid, '      color: blue\n');                                % blue
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    #prd {\n');
    fprintf(oid, '      border-style: solid hidden solid hidden;\n');   % border top & bottom only
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    #par {\n');
    fprintf(oid, '      border-style: solid hidden solid hidden;\n');   % border top & bottom only
    fprintf(oid, '    }\n\n');

    fprintf(oid, '    tr:nth-child(even){background-color: #f2f2f2}\n');% grey on even rows
    fprintf(oid, '  </style>\n');
    fprintf(oid, '</HEAD>\n\n');
    fprintf(oid, '<BODY>\n\n');

    fprintf(oid, '  <div class="prd">\n');
    fprintf(oid, '  <h1>%s</h1>\n', strrep(pets{i}, '_', ' '));
    fprintf(oid, '  </div>\n\n');

    if ~isfield(metaData.(pets{i}), 'COMPLETE')
      metaData.(pets{i}).COMPLETE = nan;
    end
    
    fprintf(oid, '  <div class="par">\n');
    fprintf(oid, '  <h4>COMPLETE = %3.1f; MRE = %8.3f; SMAE = %8.3f; SMSE = %8.3f </h4>\n', metaData.(pets{i}).COMPLETE, metaPar.(pets{i}).MRE, metaPar.(pets{i}).SMAE, metaPar.(pets{i}).SMSE);
    fprintf(oid, '  </div>\n\n');

    fprintf(oid, '  <p class="clear"></p>\n\n');
   
    fprintf(oid, '  <div class="prd">\n');
    % open prdData table
    fprintf(oid, '  <h2>Data & predictions</h2>\n');
    fprintf(oid, '  <TABLE id="prd">\n');
    fprintf(oid, '    <TR  class="head"><TH>data</TH> <TH>prd</TH> <TH>RE</TH>  <TH>symbol</TH> <TH>units</TH> <TH>description</TH> </TR>\n');

    [nm, nst] = fieldnmnst_st(data.(pets{i}));
    for j = 1:nst
      fieldsInCells = textscan(nm{j},'%s','Delimiter','.');
      tempData = getfield(data.(pets{i}), fieldsInCells{1}{:});
      k = size(tempData, 2); % number of data points per set
      if k == 1
        if ~isempty(strfind(nm{j}, '.'))
          tempUnit = getfield(txtData.(pets{i}).units, fieldsInCells{1}{:}); 
          tempLabel = getfield(txtData.(pets{i}).label, fieldsInCells{1}{:});       
          tempPrdData = getfield(prdData.(pets{i}), fieldsInCells{1}{:});
          tempClass = 'psd'; 
          if isempty(strfind(nm{j},'psd.'))
            tempClass = 'data';
          end
          str = '    <TR class="%s"><TD>%3.4g</TD> <TD>%3.4g</TD> <TD>%3.4g</TD> <TD>%s</TD> <TD>%s</TD> <TD>%s</TD></TR>\n';
          fprintf(oid, str, tempClass, tempData, tempPrdData, metaPar.(pets{i}).RE(j,1), nm{j}, tempUnit, tempLabel);
        else
          str = '    <TR><TD>%3.4g</TD> <TD>%3.4g</TD> <TD>%3.4g</TD> <TD>%s</TD> <TD>%s</TD> <TD>%s</TD></TR>\n';
          fprintf(oid, str, data.(pets{i}).(nm{j}), prdData.(pets{i}).(nm{j}), metaPar.(pets{i}).RE(j,1), nm{j}, txtData.(pets{i}).units.(nm{j}),  txtData.(pets{i}).label.(nm{j}));
        end
      else
        if length(fieldsInCells{1}) == 1
          aux = txtData.(pets{i});
        else
          aux = txtData.(pets{i}).(fieldsInCells{1}{1});
        end
        if isfield(aux.label,'treat') && isfield(aux.label.treat, fieldsInCells{1}{1}) && length(txtData.(pets{i}).label.(fieldsInCells{1}{1}))<3 % bivar
          str = ['    <TR><TD colspan="2">see figure</TD> <TD>%3.4g</TD> <TD>%s</TD> <TD colspan="2">%s '...
              '<font color="blue"><i>vs.</i></font> %s <font color="blue"><i>vs.</i></font> %s</TD>\n'];
          fprintf(oid, str, metaPar.(pets{i}).RE(j,1), fieldsInCells{1}{end}, aux.label.(fieldsInCells{1}{end}){1}, aux.label.treat.(fieldsInCells{1}{1}), aux.label.(fieldsInCells{1}{end}){2});
        elseif isfield(aux.label,'treat') && isfield(aux.label.treat, fieldsInCells{1}{1}) && length(txtData.(pets{i}).label.(fieldsInCells{1}{1}))==3 % trivar
          str = ['    <TR><TD colspan="2">see figure</TD> <TD>%3.4g</TD> <TD>%s</TD> <TD colspan="2">%s '...
              '<font color="blue"><i>vs.</i></font> %s <font color="blue"><i>vs.</i></font> %s</TD>\n'];
          fprintf(oid, str, metaPar.(pets{i}).RE(j,1), fieldsInCells{1}{end}, aux.label.(fieldsInCells{1}{end}){1}, aux.label.(fieldsInCells{1}{1}){2}, aux.label.(fieldsInCells{1}{end}){3});
        else % univar
          str = '    <TR><TD colspan="2">see figure</TD> <TD>%3.4g</TD> <TD>%s</TD> <TD colspan="2">%s <font color="blue"><i>vs.</i></font> %s</TD>\n';
          fprintf(oid, str, metaPar.(pets{i}).RE(j,1), fieldsInCells{1}{end}, aux.label.(fieldsInCells{1}{end}){1}, aux.label.(fieldsInCells{1}{end}){2});
        end
      end
    end
  
    fprintf(oid, '  </TABLE>\n'); % close prdData table
    fprintf(oid, '  </div>\n\n');

    fprintf(oid, '  <div class="par">\n');
    % open parameter table 
    if isfield(parPets.(pets{i}), 'T_ref')
      fprintf(oid, '  <h2>%s parameters at %3.1f&deg;C</h2>\n', metaPar.(pets{i}).model, K2C(parPets.(pets{i}).T_ref));
    else
      fprintf(oid, '  <h2>%s parameters</h2>\n', metaPar.(pets{i}).model);
    end
    fprintf(oid, '  <TABLE id="par">\n');
    fprintf(oid, '    <TR class="head"><TH>symbol</TH> <TH>units</TH> <TH>value</TH>  <TH>free</TH> <TH>description</TH> </TR>\n');

    currentPar = parPets.(pets{i});
    free = currentPar.free;  
    corePar = rmfield_wtxt(currentPar,'free'); coreTxtPar.units = txtPar.units; coreTxtPar.label = txtPar.label;
    [parFields, nbParFields] = fieldnmnst_st(corePar);
    % we need to make a small addition so that it recognises if one of the chemical parameters were released and then print them as well
    for j = 1:nbParFields
      if  ~isempty(strfind(parFields{j},'n_')) | ~isempty(strfind(parFields{j},'mu_')) | ~isempty(strfind(parFields{j},'d_')) ...
        & ~free.(parFields{j})==1 %|| (strcmp(parFields{j}, currentPar.d_V) &&  currentPar.d_V == get_d_V(metaData.phylum, metaData.class)) 
        corePar          = rmfield_wtxt(corePar, parFields{j});
        coreTxtPar.units = rmfield_wtxt(coreTxtPar.units, parFields{j});
        coreTxtPar.label = rmfield_wtxt(coreTxtPar.label, parFields{j});
        free  = rmfield_wtxt(free, parFields{j});
      end
    end
    parFreenm = fields(free);
    for j = 1:length(parFreenm)
      if length(free.(parFreenm{j})) ~= 1
        free.(parFreenm{j}) = free.(parFreenm{j})(i);
      end
    end    
    parpl = corePar;  % remove substructure free from par
    [nm, nst] = fieldnmnst_st(parpl);   % get number of parameter fields
    for j = 1:nst % scan parameter fields
      str = '    <TR><TD>%s</TD> <TD>%s</TD> <TD>%3.4g</TD> <TD>%d</TD> <TD>%s</TD></TR>\n';
      fprintf(oid, str, nm{j}, coreTxtPar.units.(nm{j}), parpl.(nm{j}), free.(nm{j}), txtPar.label.(nm{j}));
    end
    
    fprintf(oid, '  </TABLE>\n'); % close parameter table  
    fprintf(oid, '  </div>\n\n');

    fprintf(oid, '</BODY>\n');
    fprintf(oid, '</HTML>\n');

    fclose(oid);

    web(fileName,'-browser') % open html in systems browser

  end
