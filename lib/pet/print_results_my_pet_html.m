%% print_results_my_pet_html
% read and write results_my_pet.html

%%
function print_results_my_pet_html(metaData, metaPar, par)
% created 2015/04/11 by Starrlight & Goncalo Marques; modified 2015/08/23 Starrlight 

%% Syntax
% <../print_results_my_pet_html.m *print_results_my_pet_html*> (metaData, metaPar, par)

%% Description
% Prints an html file which compares metapar.model predictions with data
%
% Input:
%
% * metaData: structure
% * metaPar:  structure
% * par

%% Remarks
% Keep in mind that this function is specifically designed for creating the
% webpage of add-my-pet -

%% Example of use
% load('results_my_pet.mat');
% print_results_my_pet_html(metadata, metapar)

% v2struct(metadata); v2struct(metapar); 

n_author = length(metaData.author);

switch n_author
    
    case 1
    txt_author = metaData.author{1};

    case 2
    txt_author = [metaData.author{1}, ', ', metaData.author{2}];

    otherwise    
    txt_author = [metaData.author{1}, ', et al.'];

end

txt_date = [num2str(metaData.date_acc(1)), '/', num2str(metaData.date_acc(2)), '/', num2str(metaData.date_acc(3))]; 

if isfield(metaData,'author_mod_1')
n_author_mod_1 = length(metaData.author_mod_1);

    switch n_author_mod_1
      case 1
      txt_author_mod_1 = metaData.author_mod_1{1};
      case 2
      txt_author_mod_1 = [metaData.author_mod_1{1}, ', ', metaData.author_mod_1{2}];
      otherwise    
      txt_author_mod_1 = [metaData.author_mod_1{1}, ', et al.'];
    end

txt_date_mod_1 = [num2str(metaData.date_mod_1(1)), '/', num2str(metaData.date_mod_1(2)), '/', num2str(metaData.date_mod_1(3))]; 

else
    
txt_author_mod_1 = '';
txt_date_mod_1 =  '';

end  

speciesprintnm = strrep(metaData.species, '_', ' ');

oid = fopen(['results_', metaData.species, '.html'], 'w+'); % open file for reading and writing, delete existing content
fprintf(oid, '%s\n' ,'<!DOCTYPE html>');
fprintf(oid, '%s\n' ,'<HTML>');
fprintf(oid, '%s\n' ,'  <HEAD>');
fprintf(oid,['    <TITLE>add-my-pet: results ', speciesprintnm, '</TITLE>\n']);
fprintf(oid, '%s'   ,'    <META NAME = "keywords" ');
fprintf(oid, '%s\n' ,'     CONTENT="add-my-pet, Dynamic Energy Budget theory, DEBtool">');

% % ----- calls the javascript function (found in subfolder sys):
% fprintf(oid, '%s\n' ,'<script type="text/javascript" src="../sys/boxmodal.js"></script>');
% fprintf(oid, '%s\n' ,'<script type="text/javascript" src="entries.js"></script>'); % java functions specific for the entries of 

% ------ calls the cascading style sheet (found in subfolder css):
fprintf(oid, '%s\n' ,'<link rel="stylesheet" type="text/css" href="../css/collectionstyle.css">'); 

fprintf(oid, '%s\n' , ' </HEAD>');
fprintf(oid, '%s\n\n','  <BODY>');
  
   
%% content of results_my_pet
fprintf(oid, ['<H2>Model: <a class="link" target = "_blank" href="http://www.debtheory.org/wiki/index.php?title=Typified_models" >&nbsp;', metaPar.model,' &nbsp;</a></H2>']);

%%% get the predictions vs the data: 

fprintf(oid,'<p> \n');    
fprintf(oid,['<a class="link" target = "_blank" href="http://www.debtheory.org/wiki/index.php?title=Completeness" >COMPLETE</a>',' = %3.1f <BR>\n'],metaData.COMPLETE);
fprintf(oid,['<a class="link" target = "_blank" href="http://www.debtheory.org/wiki/index.php?title=Add-my-pet_Introduction#Goodness_of_fit_criterion" >MRE</a>',' = %8.3f \n'],metaPar.MRE);   
fprintf(oid,'</p> \n');     % close the paragraph

[data, auxData, metaData, txtData, weights] = feval(['mydata_',metaData.species]); 
prdData = feval(['predict_',metaData.species], par, data, auxData);

% appends new field to prd_data with predictions for the pseudo data:
% (the reason is that the predicted values for the pseudo data are not
% returned by predict_my_pet and this has to do with compatibility with the
% multimetadata.species parameter estimation):
prdData = predict_pseudodata(par, data, prdData);

% make structure for 'real' and predicted pseudodata:
pseudo = data.psd;
prdPseudo = prdData.psd;
psTxtData.units = txtData.units.psd;
psTxtData.label = txtData.label.psd;

% remove pseudodata:
data    = rmfield_wtxt(data, 'psd');
prdData    = rmfield_wtxt(prdData, 'psd');
txtData    = rmfield_wtxt(txtData, 'psd');

%-----------------------------------------------------------
% make table for zero-variate data set:
fprintf(oid, '      <TABLE id="t01">\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="7"><a class="link" target = "_blank" href="http://www.debtheory.org/wiki/index.php?title=Zero-variate_data" >Zero-variate</a> data</TH></TR>\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TD><b>Data</b></TD><TD><b>Observed</b></TD><TD><b>Predicted</b></TD><TD><b>(RE)</b></TD><TD><b>Unit</b></TD><TD><b>Description</b></TD><TD><b>Reference</b></TD></TR>\n');
% cell array of string with fieldnames of data
[nm, nst] = fieldnmnst_st(data);
 for j = 1:nst
 [~, k] = size(data.(nm{j})); % number of data points per set
    if k == 1       
    name = nm{j};
    dta   = data.(nm{j}); 
    prdta = prdData.(nm{j});
    re    = metaPar.RE(j); 
    unit  = txtData.units.(nm{j});
    des   = txtData.label.(nm{j});
    n = iscell(txtData.bibkey.(nm{j})); 
      if n
      n = length(txtData.bibkey.(nm{j}));
      REF = [];
        for i = 1:n
        ref = txtData.bibkey.(nm{j}){i};
          if i == 1
          REF = [REF,' ',ref];
          else
          REF = [REF,', ',ref];
          end
        end
      else
      REF = txtData.bibkey.(nm{j});      
      end
      fprintf(oid, '    <TR > <TD>%s</TD><TD>%3.4g</TD> <TD>%3.4g</TD> <TD>(%3.4g)</TD><TD>%s</TD><TD>%s</TD><TD>%s</TD></TR>\n',...
      name, dta, prdta, re, unit, des, REF);
    end
  end
fprintf(oid, '    <TR><TD></TD><TD></TD><TD></TD><TD></TD><TD></TD><TD></TF></TR>\n');
fprintf(oid, '    </TABLE>\n');  
%%
% make a nice table for uni-variate data set:
if isempty(metaData.data_1) == 0
fprintf(oid, '      <TABLE id="t01">\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="6"><a class="link" target = "_blank" href="http://www.debtheory.org/wiki/index.php?title=Univariate_data" >Uni-variate</a> data </TH></TR>\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TD><b>Dataset</b></TD><TD><b>Figure</b></TD><TD><b>(RE)</b></TD><TD><b>Independent variable</b></TD><TD><b>Dependent variable</b></TD><TD><b>Reference</b></TD></TR>\n');  
unidta = []; 
fignum = 0;

   for j = 1:nst
    eval(['[aux, k] = size(data.', nm{j}, ');']) % number of data points per set 
        if k >1 
        unidta = [unidta;j]; 
        end
   end

FIGNUM = zeros(length(unidta),1);    
   
 switch isfield(metaData,'grp')
    
    case 0      
        
    for j = 1:length(unidta)
        fignum = fignum + 1;
        FIGNUM(j) = fignum;
    end   
        
    otherwise
        
        nbGrpPlots = length(metaData.grp.sets); 
        figID = zeros(length(unidta),nbGrpPlots);
       
            for j = 1:length(unidta)
                Val = zeros(1,nbGrpPlots);
                for t = 1:nbGrpPlots
                 Val(1,t)  = sum(strcmp(nm{unidta(j)},metaData.grp.sets{t}));
                end
                figID(j,:) = Val;
            end

            FIGNUM(1) = 1;
            for i = 1 : length(figID) - 1
                
                if sum(figID(i+1,:)) == 0
                    FIGNUM(i+1) = FIGNUM(i) + 1;
                else
                    if isequal(figID(i+1,:), figID(i,:))
                 FIGNUM(i+1) = FIGNUM(i);
                    else
                 FIGNUM(i+1) = FIGNUM(i) + 1;
                    end  
                end                                 
            end
                 
 end 
             

     for j = 1: length(unidta)
        label  = nm{unidta(j)};
        re     = metaPar.RE(unidta(j)); 
        ivar   = txtData.label.(nm{unidta(j)}){1};
        dvar   = txtData.label.(nm{unidta(j)}){2};

        if FIGNUM(j) < 10
        fig   = ['see <A href = "results_',metaData.species,'_0',num2str(FIGNUM(j)),'.png"> Fig. ',num2str(FIGNUM(j)),'</A>'];
        else
        fig   = ['see <A href = "results_',metaData.species,'_',num2str(FIGNUM(j)),'.png"> Fig. ',num2str(FIGNUM(j)),'</A>'];
        end        
      n = iscell(txtData.bibkey.(nm{unidta(j)}));
      if n
      n = length(txtData.bibkey.(nm{unidta(j)}));
      REF = [];
        for i = 1:n
        ref = txtData.bibkey.(nm{unidta(j)}){i};
          if i == 1
          REF = [REF,' ',ref];
          else
          REF = [REF,', ',ref];
          end
        end
      else
      REF = txtData.bibkey.(nm{unidta(j)});    
      end
      fprintf(oid, '    <TR > <TD>%s</TD> <TD>%s</TD> <TD>(%3.4g)</TD><TD>%s</TD><TD>%s</TD><TD>%s</TD></TR>\n',...
      label, fig, re, ivar, dvar, REF);        
    end
 fprintf(oid, '    <TR><TD></TD><TD></TD><TD></TD><TD></TD><TD></TD><TD></TD></TR>\n');
 fprintf(oid, '    </TABLE>\n'); 
end
 
%%
% make table for pseudo-data:
[nm, nst] = fieldnmnst_st(pseudo);
fprintf(oid, '      <TABLE id="t01">\n');
fprintf(oid, '    <TR BGCOLOR = "#FFE7C6"><TH colspan="5"> Pseudo-data </TH></TR>\n');
fprintf(oid, ['    <TR BGCOLOR = "#FFE7C6"><TD><B>Data</B></TD><TD><B>Generalised animal</B></TD><TD><B>',speciesprintnm,'</B></TD><TD><B>Unit</B></TD><TD><B>Description</B></TD></TR>\n']);
  for j = 1:nst
       name = nm{j};
       dta   = pseudo.(nm{j});
       prdta = prdPseudo.(nm{j});
       unit  = psTxtData.units.(nm{j});
       des   = psTxtData.label.(nm{j});
       fprintf(oid, '<TR ><TD>%s</TD> <TD>%3.4g</TD> <TD>%3.4g</TD><TD>%s</TD><TD>%s</TD></TR>\n',...
       name, dta, prdta, unit, des);       
  end
 fprintf(oid, '    </TABLE>\n'); 
 
% %% 
%  if isempty(metaData.data_1) == 0
%  print_unidata_my_pet_html(metaData, metaPar)
%  end
%  
%% Facts:
if isfield(metaData, 'facts') 
fprintf(oid, '<H3 style="clear:both" class="pet">Facts</H3>\n');
fprintf(oid,'<ul> \n');     % open the unordered list
[nm, nst] = fieldnmnst_st(metaData.facts);
  for i = 1:nst
  fprintf(oid, '<li>\n'); % open bullet point
  str1 = metaData.facts.(nm{i});
    if isfield(txtData.bibkey,nm{i})
    str2 = metaData.bibkey.(nm{i});
    fprintf(oid, [str1,' (',str2,') \n']);
    else
    fprintf(oid, [str1,'\n']);  
    end
  fprintf(oid, '</li>\n' ); % close bullet point
  end
fprintf(oid,'</ul> \n');     % open the unordered list    
end

%% Discussion:
if isfield(metaData, 'discussion') == 1
fprintf(oid, '<H3 style="clear:both" class="pet">Discussion</H3>\n');
fprintf(oid,'<ul> \n');     % open the unordered list
[nm, nst] = fieldnmnst_st(metaData.discussion);
    for i = 1:nst
    fprintf(oid, '<li>\n'); % open bullet point
    str = metaData.discussion.(nm{i});
      if isfield(txtData.bibkey,nm{i})
      str2 = metaData.bibkey.(nm{i});
      fprintf(oid, [str,' (',str2,') \n']);
      else
      fprintf(oid, [str, '\n']);
      end
    fprintf(oid, '</li>\n' ); % close bullet point
    end
fprintf(oid,'</ul> \n');     % open the unordered list      
end

%% Bibliography:
fprintf(oid, '<H3 style="clear:both" class="pet">Bibliography</H3>\n');
[nm, nst] = fieldnmnst_st(metaData.biblist);
    for i = 1:nst
    fprintf(oid, '<li>\n'); % open bullet point
    fprintf(oid, [nm{i}, '\n']);
    fprintf(oid, '</li>\n' ); % close bullet point
    end
fprintf(oid,'</ul> \n');     % open the unordered list   
fprintf(oid, '<p>\n');
fprintf(oid, ['<A class="link" href = "bib_',metaData.species,'.bib" target = "_blank">Bibtex files with references for this entry </A> <BR> \n']);
% fprintf(oid, 'A PDF of all of the references of the add-my-pet collection can be consulted <A target="_blank" href="../../add_my_pet_bibliography.pdf">here</A>\n');
fprintf(oid, '</p>\n' );
  
%% Authors and last data of modification
fprintf(oid, '<HR> \n');
fprintf(oid,['    <H3 ALIGN="CENTER">', txt_author, ', ', txt_date, ...
        ' (last modified by ', txt_author_mod_1, '\n', txt_date_mod_1,')','</H3>\n']);
 
%% close results_my_pet.html  
fprintf(oid, '  </BODY>\n');
fprintf(oid, '  </HTML>\n');
fclose(oid);
