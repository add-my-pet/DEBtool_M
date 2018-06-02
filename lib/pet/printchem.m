%% printchem
% prints the chemical parameters of a species to screen

%%
function printchem(chem, txt_chem)
% created 2015/07/25 by Bas Kooijman

%% Syntax
% <../printchem.m *printchem*>(chem, txt_chem)

%% Description
% Prints the chemical parameters of a species to screen
%
% Input
%
% * chem: chemical parameters
% * txt_chem: text for chemical parameters

  fprintf('\nChemical parameters \n')
  fprintf('\nOrganic indices (X, V, E, P)\n')
  print_txt_var({'C'; 'H'; 'O'; 'N'}, chem.n_O)
  fprintf('\nMineral indices (C, H, O, N)\n')
  print_txt_var({'C'; 'H'; 'O'; 'N'}, chem.n_M)
  fprintf('\n')
  
  chempl = rmfield_wtxt(chem, 'mu_M');   % remove matrix-valued elements
  chempl = rmfield_wtxt(chempl, 'n_M');  % remove matrix-valued elements
  chempl = rmfield_wtxt(chempl, 'n_O');  % remove matrix-valued elements
  [nm nst] = fieldnmnst_st(chempl);      % get number of parameter fields
  for j = 1:nst % scan chemical parameter fields
    eval(['str = [txt_chem.label.', nm{j},', '', '', txt_chem.units.', nm{j},'];']);
    str = [str,  ' %3.4g %d \n'];
    eval(['fprintf(str, chempl.', nm{j},');']);
    fprintf('\n');
  end
end


