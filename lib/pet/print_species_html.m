%% print_species_html
% places a line in species.html which has previously been opened for
% reading and writing

%%
function print_species_html(metadata, metapar, fid_Spec)
% originally created by Bas Kooijman; modified 2015/04/14 Starrlight &
% Goncalo Marques; modified 2015/07/21 Starrlight

%% Syntax
% <../print_species_html.m *print_species_html*> (metadata, metapar, fid_Spec) 

%% Description
% Print the line in species.html for a pet
%
% Input:
%
% * metadata: structure 
% * metapar: structure
% * fid_Spec: scalar

v2struct(metadata); v2struct(metapar);

CLASS = metadata.class; % this is because class is a built in matlab function

% Removes underscores and makes first letter of english name be
% in capital:
speciesprintnm = strrep(metadata.species, '_', ' ');

speciesprintnm_en = strrep(metadata.species_en, '_', ' ');
if speciesprintnm_en(1)>='a' && speciesprintnm_en(1)<='z'
  speciesprintnm_en(1)=char(speciesprintnm_en(1)-32);
end
% ------------------------------------------------------------


  n_data_0 = size(data_0,1); n_data_1 = size(data_1,1); 
  
  fprintf(fid_Spec, '      <TR>\n');
  fprintf(fid_Spec,['        <TD>', phylum, '</TD>  <TD>', CLASS, '</TD> <TD>', order, '</TD> <TD>', family, '</TD> ']);
  fprintf(fid_Spec,['<TD><A TARGET="_top" HREF="entries/',species,'/i_results_', species, '.html">', speciesprintnm, '</A></TD> <TD>', speciesprintnm_en, '</TD> ']);
  fprintf(fid_Spec, '<TD style="text-align:center"  BGCOLOR = "#FFC6A5">%s</TD> ', model);
  fprintf(fid_Spec, '<TD style="text-align:center"  BGCOLOR = "#FFE7C6">%8.3f</TD> ', MRE);
  fprintf(fid_Spec, '<TD style="text-align:center"  BGCOLOR = "#FFCE9C">%g</TD>\n', COMPLETE);
  for i = 1:n_data_0
    fprintf(fid_Spec, '<TD BGCOLOR = "#FFFFC6">%s</TD> ', data_0{i});      
  end
  for i = 1:n_data_1
    fprintf(fid_Spec, '<TD BGCOLOR = "#FFFF9C">%s</TD>', data_1{i});  
  end
  fprintf(fid_Spec, '\n      </TR>\n');