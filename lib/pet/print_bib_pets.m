%% print_bib_pets
% pen, read and write bib_pets.bib - data is appended nothing is deleted
% from file.

function print_bib_pets(biblist)
% created 2015/07/17 by Starrlight 

%% Syntax
% <../print_bib_pets.m *print_bib_pets*> (species,biblist) 

%% Description
% Prints a .bib file with the bibliography of the whole collection
%
% Input:
%
% * biblist:  structure with each field containing a reference in bibtext format. The name of
% the key corresponds to the bibtex key. 

%% Remarks
% if you load results_my_pet.mat then you access the biblist in biblist.metadata

%% Example of use
% print_bib_pets(metadata.biblist)

oid = fopen('bib_pets.bib', 'a'); % open file for reading and writing and appends new information without erasing

[nm, nst] = fieldnmnst_st(biblist);

for j = 1:nst 
    str = eval(['biblist.',nm{j}]);
fprintf(oid, '%s \n\n', str);
end
    
%% close bib_my_pet.bib  
fclose(oid);