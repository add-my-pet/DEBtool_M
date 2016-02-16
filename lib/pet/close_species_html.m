%% close_species_html(fid_Spec)
% closes species.html

%%
function close_species_html(fidSpec)
% originally created by Bas Kooiman; modified 2015/08/28 Starrlight

%% Syntax
% <../close_species_html.m *close_species_html*> (fid_Spec) 

%% Description
% Run this after print_species_html.m
%
% Input:
%
% * fidSpec : scalar

fprintf(fidSpec,   '%s\n' , '    </TABLE>');
fprintf(fidSpec,   '%s\n\n' , '  </BODY>');
fprintf(fidSpec,   '%s\n' , '</HTML>');
fclose(fidSpec);


