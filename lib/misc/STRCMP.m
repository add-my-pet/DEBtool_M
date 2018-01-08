%% STRCMP
% compares cell strinfd on equality

%%
function c = STRCMP(a,b)
% created 2018/01/07 by Bas Kooijman

%% Syntax
% c = <../STRCMP.m *STRCMP*>(a,b)

%% Description
% compares strings on eqality, like Matlab function strcmp, but string
% might not be qually long and sequence of cells in strings is ignored
%
% Input:
%
% * a: cell string
% * b: cell string
%
% Output:
%
% * c: boolean with true if a and b are the same, false if not
 

%% Example of use
% STRCMP({'ab', 'ap'}, {'ap', 'aa'})

%% subfunction

  if length(a) == length(b)
    c = strcmp(sort(a), sort(b));
  else
    c = false;
  end
end