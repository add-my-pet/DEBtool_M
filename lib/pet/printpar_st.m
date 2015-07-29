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
% * two inputs
%
%     txt_par: text for parameters
%     par: parameters structure

%% Remarks
% Parameter values are followed by 0 for fixed and 1 for free (set in pars_init_my_pet)


if nargin == 1
  species = varargin{1};
  filenm = ['results_', species, '.mat'];
  load(filenm,'txt_par', 'par','chem');
else 
  par     = varargin{1};
  txt_par = varargin{2};
  
end

fprintf('\nParameters \n');
free = par.free;                    % copy substructure
parpl = rmfield_wtxt(par, 'free');  % remove substructure free from par
[nm nst] = fieldnmnst_st(parpl);    % get number of parameter fields
for j = 1:nst % scan parameter fields
  eval(['str = [txt_par.label.', nm{j},', '', '', txt_par.units.', nm{j},'];']);
  str = [str,  ' %3.4g %d \n'];
eval(['fprintf(str, parpl.', nm{j},', free.', nm{j},');']);
end

