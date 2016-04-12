%% select_01
% finds booleans for occurences of members of taxon among members of taxon_src

%
function [sel taxa_src] = select_01(taxon_src, taxon)
% created 2016/04/12 by Bas Kooijman

%% Syntax
% [sel taxa_src] = <select_01.m *select_01*>(taxon_src, taxon)

%% Description
% Finds booleans for occurences of members of taxon among members of taxon_src
%
% Input
%
% * taxon_src: character string with name of source taxon
% * taxon: character string with name of taxon that belongs to source taxon
%
% Output
%
% * sel: n-vector with booleans
% * taxa_scr: n-vector with names of members of taxon_src

%% Remarks
% The names of members of taxon can be found by
% [sel nm] = select_01(taxon_src, taxon); nm(sel)

%% Example of use
% sel = select_01('Animalia', 'Aves')

taxa_src = select(taxon_src); taxa = select(taxon);
m = size(taxa_src,1); n = size(taxa,1); sel = false(m,1);

for i = 1:n
  sel(strcmp(taxa_src, taxa{i})) = true;
end

