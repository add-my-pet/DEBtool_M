%% print_unidata_my_pet_html
% read and write unidata_my_pet.html

%%
function print_unidata_my_pet_html(metaData, metaPar)
% created 2015/04/11 by Starrlight & Goncalo Marques; modified 2015/08/23 Starrlight 

%% Syntax
% <../print_results_my_pet_html.m *print_results_my_pet_html*> (metaData, metaPar) 

%% Description
% Prints an html file which compares metaPar.model predictions with data
%
% Input:
%
% * metaData: structure
% * metaPar:  structure

%% Remarks
% Keep in mind that this function is specifically designed for created the
% webpage of add-my-pet -

%% Example of use
% load('results_my_pet.mat');
% print_results_my_pet_html(metaData, metaPar)

[data, auxData, metaData, txtData, weights] = feval(['mydata_',metaData.species]);
% remove pseudodata:
data    = rmfield_wtxt(data, 'psd');
txtData    = rmfield_wtxt(txtData, 'psd');

% cell array of string with fieldnames of data.weight
[nm, nst] = fieldnmnst_st(data);

speciesprintnm = strrep(metaData.species, '_', ' ');

oid = fopen(['unidata_', metaData.species, '.html'], 'w+'); % open file for reading and writing, delete existing content
fprintf(oid, '%s\n' ,'<!DOCTYPE html>');
fprintf(oid, '%s\n' ,'<HTML>');
fprintf(oid, '%s\n' ,'  <HEAD>');
fprintf(oid,['    <TITLE>add-my-pet: results ', speciesprintnm, '</TITLE>\n']);
fprintf(oid, '%s'   ,'    <META NAME = "keywords" ');
fprintf(oid, '%s\n' ,'     CONTENT="add-my-pet, Dynamic Energy Budget theory, DEBtool">');

% ------ calls the cascading style sheet (found in subfolder css):
fprintf(oid, '%s\n' ,'<link rel="stylesheet" type="text/css" href="../../css/collectionstyle.css">'); 

fprintf(oid, '%s\n' , ' </HEAD>');
fprintf(oid, '%s\n\n','  <BODY>');
  
%% content of results_my_pet
fprintf(oid, ['<H2>Univarariate data and ',metaPar.model,' model predictions for ', speciesprintnm,' &nbsp;</a></H2>']);

%%% Print out all of the graphs with captions:
unidta = [];

for j = 1:nst
[aux, k] = size(data.(nm{j})); % number of data points per set
  if k >1
  unidta = [unidta;j];
  end
end

ex = 1;
counter = 0;

  while ex 
  test = counter + 1;
    if test < 10
    fullnm = ['results_',metaData.species, '_0', num2str(test), '.png'];
    else
    fullnm = ['results_',metaData.species, '_', num2str(test), '.png'];
    end
    if exist(fullnm, 'file')
    counter = counter +1;
    n = iscell(txtData.bibkey.(nm{unidta(counter)}));
      if n
      n = length(txtData.bibkey.(nm{unidta(counter)}));
      REF = [];
        for i = 1:n
        ref = txtData.bibkey.(nm{unidta(counter)});
          if i == 1
          REF = [REF,' ',ref];
          else
          REF = [REF,', ',ref];
          end
        end
      else
      REF = txtData.bibkey.(nm{unidta(counter)});    
      end
      fprintf(oid, '<div class="figure">\n');
      fprintf(oid, ['<p><img src="',fullnm,'" width = "380px" alt="Fig ',num2str(test),' 1"> \n']);
      fprintf(oid,[' <p>Fig. ', num2str(test),': symbols: data from ', REF,'. \n']);
      fprintf(oid,'Lines: %s model predictions. \n', metaPar.model); 
      if isfield(txtData.comment, nm{unidta(counter)})
      str = txtData.comment.(nm{unidta(counter)});
      fprintf(oid,str);     
      end
      fprintf(oid,'</div> \n');   
    else
    ex = 0;
    end
  end


% close the file:

fprintf(oid, '  </BODY>\n');
fprintf(oid, '  </HTML>\n');
fclose(oid);

