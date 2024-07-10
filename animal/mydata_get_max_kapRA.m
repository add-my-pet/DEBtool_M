%% mydata_get_max_kapRA

nm = 'Glaucomys_volans'; pars = read_stat(nm,{'p_Am','p_M','k_J','E_Hp','s_M','s_s'}); 
pars(:,1) = pars(:,1).*pars(:,5); s_s = pars(:,6); res = get_max_kapRA(pars(:,1:4));
pRA = read_stat(nm,{'p_Ri','p_Ai','kap'}); kapRA = pRA(:,1)./pRA(:,2); kap = pRA(:,3); 
prt_tab({nm,res,kap,kapRA,kapRA./res(:,2),s_s},{'species','kap_opt','kapRA_opt','kap_min','kap_max','info','kap','kapRA','kapRA/kapRA_opt','s_s'})

shkapRA(pars(1:4));