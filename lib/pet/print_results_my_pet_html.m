%% print_results_my_pet_html
% read and write results_my_pet.html

%%
function print_results_my_pet_html(metadata, metapar)
% created 2015/04/11 by Starrlight & Goncalo Marques; modified 2015/04/23 Starrlight 

%% Syntax
% <../print_results_my_pet_html.m *print_results_my_pet_html*> (metadata, metapar) 

%% Description
% Prints an html file which compares model predictions with data
%
% Input:
%
% * metadata: structure
% * metapar:  structure

%% Remarks
% Keep in mind that this function is specifically designed for created the
% webpage of add-my-pet - this function is called when local directory is
% html and when we go one level up it supposes the existance of a
% subdirectory called results ! see 
%<http://www.bio.vu.nl/thb/deb/deblab/add_my_pet/art/websitemaintenance.html *maintanance webpage*>

%% Example of use
% load('results_my_pet.mat');
% print_results_my_pet_html(metadata, metapar)



v2struct(metadata); v2struct(metapar); 

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

speciesprintnm = strrep(species, '_', ' ');

oid = fopen(['results_', species, '.html'], 'w+'); % % open file for writing, delete existing content
fprintf(oid, '%s\n' ,'<!DOCTYPE html>');
fprintf(oid, '%s\n' ,'<HTML>');
fprintf(oid, '%s\n' ,'  <HEAD>');
fprintf(oid,['    <TITLE>add-my-pet: results ', speciesprintnm, '</TITLE>\n']);
fprintf(oid, '%s'   ,'    <META NAME = "keywords" ');
fprintf(oid, '%s\n' ,'     CONTENT="add-my-pet, Dynamic Energy Budget theory, DEBtool">');

% ----- calls the javascript function (found in subfolder sys):
fprintf(oid, '%s\n' ,'<script type="text/javascript" src="../sys/boxmodal.js"></script>');
% ------ calls the cascading style sheet (found in subfolder css):
fprintf(oid, '%s\n' ,'<link rel="stylesheet" type="text/css" href="../css/collectionstyle.css">'); 

fprintf(oid, '%s\n' , ' </HEAD>');
fprintf(oid, '%s\n\n','  <BODY>');
  
   
%% content of results_my_pet
% fprintf(oid, '%s\n' , ' <BR>');
% fprintf(oid, '%s\n' , ...
%     [' <H2>Model: <A target = "_blank" href= "http://www.bio.vu.nl/thb/deb/deblab/debtool/DEBtool_M/manual/DEBtool_animal.html#',model,'">']);
% fprintf(oid, '%s \n' , [model,'</A> </H2>']);
fprintf(oid, ['<H2>Model: <a class="link" href="#" onclick="BoxArt_type();">&nbsp;', model,' &nbsp;</a></H2>']);


%%% get the predictions vs the data: 
% fprintf(oid, '<H3 class="pet">Overview:</H3>\n');

fprintf(oid,'<p> \n');    
fprintf(oid,'COMPLETE = %3.1f <BR>\n',COMPLETE);
fprintf(oid,'MRE = %8.3f \n',MRE);   
fprintf(oid,'</p> \n');     % close the paragraph

cd ../mydata
[data, txt_data] = feval(['mydata_',species]); 
% %%% these next lines of code have been canabalised from printprd_st.m:

cd ../mat
load(['results_',species,'.mat'])

cd ../predict
prd_data = feval(['predict_',species], par, chem, T_ref, data);

% appends new field to prd_data with predictions for the pseudo data:
% (the reason is that the predicted values for the pseudo data are not
% returned by predict_my_pet and this has to do with compatibility with the
% multispcecies parameter estimation):
eval('prd_data = predict_pseudodata(prd_data, par, chem, data);');

% remove fields 'weight' and 'temp' from structure data:
datapl    = rmfield_wtxt(data, 'weight');
datapl    = rmfield_wtxt(datapl, 'temp');

% cell array of string with fieldnames of data.weight
dtsets    = fieldnames(data.weight);
[nm, nst] = fieldnmnst_st(datapl);

fprintf(oid,'<p> \n');   % open paragraph  
fprintf(oid,'Data and predictions (relative error): \n');
fprintf(oid,'<ul> \n');     % open the unordered list
%-----------------------------------------------------------
  for j = 1:nst
  eval(['[aux, k] = size(data.', nm{j}, ');']) % number of data points per set
    if k == 1 % if it is a zero-variate data set
fprintf(oid,'<li> \n');   
    eval(['str = [nm{j}, '', '', txt_data', '.units.', nm{j},', '', '', txt_data.label.', nm{j},'];']);
      str = ['%3.4g %3.4g (%3.4g) ', str, '\n'];
      eval(['fprintf(oid, str, datapl.', nm{j},', prd_data.', nm{j},', RE(j));']);
fprintf(oid,'</li> \n');   
    else
      fprintf(oid,'<li> \n');  % open up line of the list 
      eval(['str = [dtsets{j}, '', '', txt_data.label.', nm{j},'{1}, '' vs. '', txt_data.label.', nm{j},'{2}];']);
      str = ['see figure (%3.4g) ', str, '\n'];
      eval(['fprintf(oid,str, RE(j));']);
      fprintf(oid,'</li> \n');   % close line of the list 
    end
  end
%-------------------------------------------------------------
fprintf(oid,'</ul> \n');    % close the unordered list
fprintf(oid,'</p> \n');     % close paragraph


%%% Print out all of the graphs:
% fprintf(oid, '<H3 class="pet">Plots of Uni-variate data</H3>\n');


cd ../figs % go to the subdirectory figs:
ex = 1;
counter = 0;

while ex
  test = counter + 1;
  if test < 10
    fullnm = ['results_',species, '_0', num2str(test), '.png'];
  else
    fullnm = ['results_',species, '_', num2str(test), '.png'];
  end
  
  if exist(fullnm, 'file')
    counter = counter +1;
    fprintf(oid,'<p>\n');
    fprintf(oid,'<span class="imgleft">\n');
    fprintf(oid,['<IMG class = "workerpic" SRC="../figs/',fullnm,'" WIDTH=500px></IMG>\n']) ;   
    fprintf(oid,'</span></p>\n');    
  else
    ex = 0;
  end
end
cd ../results % back to subdirectory results

fprintf(oid, '<H3 style="clear:both" class="pet">Bibliography</H3>\n');
fprintf(oid, '<p>\n');
fprintf(oid, ['see <A target="_blank" href="../mydata/mydata_',species,'.m">mydata_',metadata.species,'</A>\n']);
fprintf(oid, '</p>\n' );
  
%% author and last data of modification

fprintf(oid, '<HR> \n');
fprintf(oid,['    <H3 ALIGN="CENTER">', txt_author, ', ', txt_date, ...
        ' (last modified by ', txt_author_mod_1, '\n', txt_date_mod_1,')','</H3>\n']);
 
%% close results_my_pet.html  
  
% these two lines are necessary for the boxes called by java scrip in
% subfolder sys to work:
fprintf(oid,'%s\n' , '<div style="position: absolute; z-index: 20000; visibility: hidden; display: none;" id="ext-comp-1001" class="x-tip"><div class="x-tip-tl"><div class="x-tip-tr"><div class="x-tip-tc"><div style="-moz-user-select: none;" id="ext-gen10" class="x-tip-header x-unselectable"><span class="x-tip-header-text"></span></div></div></div></div><div id="ext-gen11" class="x-tip-bwrap"><div class="x-tip-ml"><div class="x-tip-mr"><div class="x-tip-mc"><div style="height: auto;" id="ext-gen12" class="x-tip-body"></div></div></div></div>');
fprintf(oid,'%s\n' , '<div class="x-tip-bl x-panel-nofooter"><div class="x-tip-br"><div class="x-tip-bc"></div></div></div></div></div><div id="xBoxScreen"></div>');

fprintf(oid, '  </BODY>\n');
fprintf(oid, '  </HTML>\n');
fclose(oid);
