%% printpar_st
% prints the parameters of a species to screen

%%
function printpar_st(varargin)
% created 2015/03/20 by Goncalo Marques; modified 2015/03/21 by Bas Kooijman; modified 2015/08/01 by Goncalo Marques

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
  load(filenm,'txtPar', 'par');
else 
  par    = varargin{1};
  txtPar = varargin{2};
end

fprintf('\nParameters \n');
free = par.free;                    % copy substructure
parpl = rmfield_wtxt(par, 'free');  % remove substructure free from par
[nm, nst] = fieldnmnst_st(parpl);    % get number of parameter fields
for j = 1:nst % scan parameter fields
  str = [nm{j}, ', ', txtPar.units.(nm{j}), ' %3.4g %d \n']; 
  fprintf(str, parpl.(nm{j}), free.(nm{j}));
end

