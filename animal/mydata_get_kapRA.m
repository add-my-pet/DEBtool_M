%% mydata_get_kapRA

nm = select('Animalia'); pars = read_stat(nm,{'p_Am','p_M','k_J','E_Hp','s_M','kap'}); 
res = get_kapRA(pars); kapRA = res(:,1);
pRA = read_stat(nm,{'p_Ri','p_Ai'}); kapRA_al = pRA(:,1)./pRA(:,2); 
MRE = (kapRA - kapRA_al).^2./kapRA.^2;
sel = MRE>0.05; nm = nm(sel); kapRA = kapRA(sel); kapRA_al = kapRA_al(sel); MRE = MRE(sel); model = read_stat(nm,'model');
prt_tab({nm,kapRA,kapRA_al,MRE,model},{'species','kapRA','kapRA allStat','MRE','model'})
