%% rmfield_wtxt
% Removes fields with a given name in a multilevel structure 

%%
function st = rmfield_wtxt(st, txt)
% created 2015/01/18 by Goncalo Marques

%% Syntax
% st = <../rmfield_wtxt.m *rmfield_wtxt*> (st, txt)

%% Description
% removes from a structure all fields with the name txt
%
% Inputs:
%
% * st : structure to be handled
% * txt : string with field name to be removed
%
% Output:
% 
% * st : structure with the fields removed

%% Example of use
% Suppose one has the structure x with the following fields:
%
%    x.value.temp
%    x.value.len
%    x.value.reprod
%    x.unit.temp
%    x.unit.len
%    x.temp
%
% the command  x = rmfield_wtxt(x, 'temp') will make x have only the fields:
%
%    x.value.len
%    x.value.reprod
%    x.unit.len


  if isfield(st, txt)
    rmfield(st, txt);
  end

  nmaux = fieldnames(st);
  fullnmaux = nmaux;
  fullnm = [];

  for i = 1:length(nmaux)
    if strcmp(nmaux(i), txt)
      st = rmfield(st, txt);
      return;
    end
  end
  
  while length(fullnmaux) > 0
    if eval(['isfield(st.', fullnmaux{1},', txt)'])
      eval(['st.', fullnmaux{1},' = rmfield(st.', fullnmaux{1},', txt);']);
    end
    if eval(['isstruct(st.', fullnmaux{1},')'])
      eval(['nmaux = fieldnames(st.', fullnmaux{1},');']);
      for i = 1:length(nmaux)
        fullnmaux = [fullnmaux; cellstr(strcat(fullnmaux{1}, '.', nmaux{i}))];
      end
    end
    fullnmaux(1) = [];
  end

