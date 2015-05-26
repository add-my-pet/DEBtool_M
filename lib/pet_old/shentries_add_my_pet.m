%% plots number of entries in add_my_pet against time
% reads variable date in all pars_files
% warning: do not run this script inside DEBtool_M/animal
  
  info = entries_add_my_pet_init; % creates locally report_xls_init.m and report_xls.m
  if info == 0
     return
  end
  
  dates = [];    % initiate dates
  pars_my_pets;  % append to dates
  
  figure
  surv_dates = surv(dates, 0); 
  surv_dates(1,:) = [];
  surv_dates(:,1) = surv_dates(:,1) - surv_dates(1,1);
  surv_dates([end - 1; end],:) = [];
  n = size(surv_dates, 1)/2;
  plot(surv_dates(:,1), n * (1 - surv_dates(:,2)),'g', 'Linewidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('time, d')
  ylabel('# of add\_my\_pet entries')
 
  delete('report_xls_init.m');
  delete('report_xls.m');
