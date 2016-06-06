%% print_species_html
% places a line in species.html which has previously been opened for
% reading and writing

%%
function print_species_html(metaData, metaPar, fidSpec)
% originally created by Bas Kooijman; modified 2015/04/14 Starrlight &
% Goncalo Marques; modified 2015/07/21 Starrlight; modified 2015/08/28 Starrlight

%% Syntax
% <../print_species_html.m *print_species_html*> (metadata, metapar, fid_Spec) 

%% Description
% Print the line in species.html for a pet
%
% Input:
%
% * metaData: structure 
% * metaPar: structure
% * fidSpec: scalar

v2struct(metaData); v2struct(metaPar);

% Remove underscores 
% Puts first letter of english name in capital:
speciesprintnm = strrep(metaData.species, '_', ' ');
speciesprintnm_en = strrep(metaData.species_en, '_', ' ');
if speciesprintnm_en(1)>='a' && speciesprintnm_en(1)<='z'
  speciesprintnm_en(1)=char(speciesprintnm_en(1)-32);
end

n_data_0 = length(data_0); n_data_1 = length(data_1); 
  
  fprintf(fidSpec, '      <TR>\n');
  fprintf(fidSpec,['        <TD>', phylum, '</TD>  <TD>', metaData.class, '</TD> <TD>', order, '</TD> <TD>', family, '</TD> ']);
  fprintf(fidSpec,['<TD><A TARGET="_top" HREF="entries_web/i_results_', species, '.html">', speciesprintnm, '</A></TD> <TD>', speciesprintnm_en, '</TD> ']);
  fprintf(fidSpec, '<TD style="text-align:center"  BGCOLOR = "#FFC6A5">%s</TD> ', model);
  fprintf(fidSpec, '<TD style="text-align:center"  BGCOLOR = "#FFE7C6">%8.3f</TD> ', MRE);
  fprintf(fidSpec, '<TD style="text-align:center"  BGCOLOR = "#FFCE9C">%g</TD>\n', COMPLETE);
  for i = 1:n_data_0
    fprintf(fidSpec, '<TD BGCOLOR = "#FFFFC6">%s</TD> ', data_0{i});      
  end
  for i = 1:n_data_1
    fprintf(fidSpec, '<TD BGCOLOR = "#FFFF9C">%s</TD>', data_1{i});  
  end
  fprintf(fidSpec, '\n      </TR>\n');