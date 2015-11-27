Perl routines for taxa

1) To create a tree with each taxon on a new line after level-tabs, run

perl pedigree.pl Animalia > tree.txt 

2) To create a list of species that belong to a taxon, each on a new line, run

perl select.pl Animalia > species.txt

3) to create a list of taxa, each on a new line, to which a particular taxon belongs (last line being Animalia), run 

perl classify.pl my_pet > classification.txt

==================

run perl under Matlab like

  species = perl('select.pl', 'Animalia');
