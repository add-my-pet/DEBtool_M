function d = dist_taxon(species, genus, family, order, class, phylum, superphylum)
% all inputs are cells with strings of the same size (n,1)
% d: (n,n)-matrix with taxonomic distance

n = size(species,1); d = zeros(n,n);
for i = 1:n
    for j = (i+1):n
        if ~strcmp(superphylum{i},superphylum {j})
            d(i,j) = 7; d(j,i) = d(i,j);
        elseif ~strcmp(phylum{i}, phylum {j})
            d(i,j) = 6; d(j,i) = d(i,j);
        elseif ~strcmp(class{i}, class{j})
            d(i,j) = 5; d(j,i) = d(i,j);
        elseif ~strcmp(order{i}, order{j})
            d(i,j) = 4; d(j,i) = d(i,j);
        elseif ~strcmp(family{i}, family{j})
            d(i,j) = 3; d(j,i) = d(i,j);
        elseif ~strcmp(genus{i}, genus{j})
            d(i,j) = 2; d(j,i) = d(i,j);
        elseif ~strcmp(species{i}, species{j})
            d(i,j) = 1; d(j,i) = d(i,j);
        end
    end
end