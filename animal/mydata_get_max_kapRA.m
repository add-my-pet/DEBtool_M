%% mydata_get_max_kapRA

nm = select('Mus_musculus'); pars = read_stat(nm,{'p_Am','p_M','k_J','E_Hp','s_M','kap'}); 
res = get_max_kapRA(pars); % res: kap_opt, kapRA_opt, kap_min, kap_max, s_s
pRA = read_stat(nm,{'p_Ri','p_Ai','kap'}); kapRA = pRA(:,1)./pRA(:,2); kap = pRA(:,3); 
prt_tab({nm,res(:,1:4),kap,kapRA,kapRA./res(:,2),pRA(:,1),pRA(:,2)},{'species','kap_opt','kapRA_opt','kap_min','kap_max','kap','kapRA','kapRA/kapRA_opt','p_Ri','p_Ai'})

% just for 1 species
shkapRA(pars);