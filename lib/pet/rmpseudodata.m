%% rmpseudodata
% Removes pseudodata information from inputed data structures 

%%
function data = rmpseudodata(data)
% created 2015/02/09 by Goncalo Marques

%% Syntax
% [data] = <../rmpseudodata.m *rmpseudodata*> (data)

%% Description
% removes the pseudodata information from the structures
%
% Inputs:
%
% * data : structure with data and pseudodata values and weights
%
% Output: 
%
% * data : structure with data values and weights only

%% Example of use
% data = addpseudodata(data);
% will remove pseudodata fields from data, data.weight, units and label

% removes pseudodata
  [nmpsd, nst] = fieldnm_wtxt(data, 'psd');
  if nst > 0
    nmpsd = strrep(nmpsd, '.psd', '');
    for i = 1:length(nmpsd);
      eval(['data.', nmpsd{i}, ' = rmfield(data.', nmpsd{i}, ', ''psd'');']);
    end
  end