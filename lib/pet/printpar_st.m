%% printpar_st
% prints the parameters of a species to screen

%%
function printpar_st(varargin)
% created 2015/03/20 by Goncalo Marques; modified 2015/03/21 by Bas Kooijman

%% Syntax
% <../printpar_st.m *printpar_st*> (varargin)

%% Description
% Prints the parameters of a species to screen
%
% Input
%
% * one input
%
%     name of my_pet to load results_my_pet.mat
%
% * more inputs
%
%     txt_par: text for parameters
%     par: parameters structure
%     chem: optional chemical parameters

%% Remarks
% Parameter values are followed by 0 for fixed and 1 for free (set in pars_init_my_pet)


if nargin == 1
  species = varargin{1};
  filenm = ['results_', species, '.mat'];
  load(filenm,'txt_par', 'par','chem');
elseif nargin == 2
  txt_par = varargin{1};
  par     = varargin{2};
else
  txt_par = varargin{1};
  par     = varargin{2};
  chem    = varargin{3};
end

fprintf('\nParameters \n')
free = par.free;                    % copy substructure
parpl = rmfield_wtxt(par, 'free');  % remove substructure free from par
[nm nst] = fieldnmnst_st(parpl);    % get number of parameter fields

for j = 1:nst % scan parameter fields
  eval(['str = [txt_par.label.', nm{j},', '', '', txt_par.units.', nm{j},'];']);
  str = [str,  ' %3.4g %d \n'];
  eval(['fprintf(str, parpl.', nm{j},', free.', nm{j},');']);
end

if exist('chem', 'var') % chemical parameters
  units.T_ref = 'K';     label.T_ref = 'T_ref'; 
  units.mu_M = 'J/mol';  label.mu_M = 'mu_M'; % (4,1)-matrix with zeros
  units.mu_X = 'J/mol';  label.mu_X = 'mu_X';
  units.mu_V = 'J/mol';  label.mu_V = 'mu_V';
  units.mu_E = 'J/mol';  label.mu_E = 'mu_E';
  units.mu_P = 'J/mol';  label.mu_P = 'mu_P';
  units.d_X = 'g/cm^3';  label.d_X = 'd_X';
  units.d_V = 'g/cm^3';  label.d_V = 'd_V';
  units.d_E = 'g/cm^3';  label.d_E = 'd_E';
  units.d_P = 'g/cm^3';  label.d_P = 'd_P';
  units.X_gas = 'M';     label.X_gas = 'X_gas';
  units.n_O = '-';       label.n_O = 'n_O';  % (4,4)-matrix
  units.n_M = '-';       label.n_M = 'n_M';  % (4,4)-matrix
  txt_chem.units = units; txt_chem.label = label;
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
    fprintf('\n')
  end
end


