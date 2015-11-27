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
% these two lines are necessary for the javascript function to work (add_my_pet/sys/boxmodal.js) 
fprintf(fidSpec,'%s\n' , '<div style="position: absolute; z-index: 20000; visibility: hidden; display: none;" id="ext-comp-1001" class="x-tip"><div class="x-tip-tl"><div class="x-tip-tr"><div class="x-tip-tc"><div style="-moz-user-select: none;" id="ext-gen10" class="x-tip-header x-unselectable"><span class="x-tip-header-text"></span></div></div></div></div><div id="ext-gen11" class="x-tip-bwrap"><div class="x-tip-ml"><div class="x-tip-mr"><div class="x-tip-mc"><div style="height: auto;" id="ext-gen12" class="x-tip-body"></div></div></div></div>');
fprintf(fidSpec,'%s\n' , '<div class="x-tip-bl x-panel-nofooter"><div class="x-tip-br"><div class="x-tip-bc"></div></div></div></div></div><div id="xBoxScreen"></div>');
fprintf(fidSpec,   '%s\n\n' , '  </BODY>');
fprintf(fidSpec,   '%s\n' , '</HTML>');
fclose(fidSpec);


