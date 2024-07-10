%% mydata_get_max_kapRA

nm = select('Rodentia'); vars = read_stat(nm,{'p_Am','p_M','k_J','E_Hp','s_M','s_s'}); 
vars(:,1) = vars(:,1).*vars(:,5); s_s = vars(:,6); res = get_max_kapRA(vars);
pRA = read_stat(nm,{'p_Ri','p_Ai','kap'}); kapRA = pRA(:,1)./pRA(:,2); kap = pRA(:,3); 
prt_tab({nm,res,kap,kapRA,kapRA./res(:,3),s_s},{'species','kap_opt','kapRA_opt','kap_min','kap_max','info','kap','kapRA','kapRA/kapRA_opt','s_s'})

% Pedetes_capensis
% p_Am = vars(1,1);p_M = vars(1,2);k_J = vars(1,3);E_Hp = vars(1,4); 
% [kap_opt, kapRA_opt, kap_min, kap_max] = kap_kapRA(p_Am,p_M,k_J,E_Hp)