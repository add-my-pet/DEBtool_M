%% mydata_get_max_kapRA

nm = select('Rodentia'); res = get_max_kapRA(read_stat(nm,{'p_Am','p_M','k_J','E_Hp'}));
pRA = read_stat(nm,{'p_Ri','p_Ai','kap'}); kapRA = pRA(:,1)./pRA(:,2); kap = pRA(:,3); 
prt_tab({nm,res,kap,kapRA,kapRA./res(:,3)},{'species','kap_min','kap_opt','kapRA_opt','info','kap', 'kapRA','kapRA/kapRA_opt'})
