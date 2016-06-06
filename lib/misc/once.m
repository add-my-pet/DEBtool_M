%% once
% removes double true's in columns of a boolean matrix

%%
function  sel = once(sel)
% created 2016/04/12 by Bas Kooijman

%% Syntax
% sel = <once.m *sel*>(sel)

%% Description
% Removes double true's in columns of a boolean matrix
%
% Input
%
% * sel: (n,m)-matrix with booleans
%
% Output
%
% * sel: (n,m)-matrix with booleans, like input, but with at most 1 true per row

%% Example of use
% once([1 0 0 1; 0 0 0 0; 0 1 0 0])

[n m] = size(sel); zero = false(1, m);
for i = 1:n
  j = find(sel(i,:),1); sel(i,:) = zero; sel(i,j) = true;
end

