%% lists authors of entries in add_my_pet
% reads variable author in all pars_files
% warning: do not run this script inside DEBtool_M/animal
  
  info = authors_add_my_pet_init; % creates locally report_xls_init.m and report_xls.m
  if info == 0
     return
  end
  
  authors = [];    % initiate authors
  pars_my_pets;  % append to dates
  
  authors = unique(authors)
  n = size(authors,1);
  fprintf([num2str(n), ' add_my_pet authors\n'])
  
  delete('report_xls_init.m');
  delete('report_xls.m');
