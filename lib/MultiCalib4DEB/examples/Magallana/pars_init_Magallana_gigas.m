function [par, metaPar, txtPar] = pars_init_Magallana_gigas(metaData)

metaPar.model = 'asj'; 

%% core primary parameters 
par.z = 1.1829;       free.z     = 1;   units.z = '-';            label.z = 'zoom factor'; 
par.F_m = 30.4368;    free.F_m   = 1;   units.F_m = 'l/d.cm^2';   label.F_m = '{F_m}, max spec searching rate'; 
par.kap_X = 0.3259;   free.kap_X = 0;   units.kap_X = '-';        label.kap_X = 'digestion efficiency of food to reserve'; 
par.kap_P = 0.2279;   free.kap_P = 0;   units.kap_P = '-';        label.kap_P = 'faecation efficiency of food to faeces'; 
par.v = 0.005363;     free.v     = 1;   units.v = 'cm/d';         label.v = 'energy conductance'; 
par.kap = 0.2644;     free.kap   = 1;   units.kap = '-';          label.kap = 'allocation fraction to soma'; 
par.kap_R = 0.95;     free.kap_R = 0;   units.kap_R = '-';        label.kap_R = 'reproduction efficiency'; 
par.p_M = 17.3445;    free.p_M   = 1;   units.p_M = 'J/d.cm^3';   label.p_M = '[p_M], vol-spec somatic maint'; 
par.p_T = 0;          free.p_T   = 0;   units.p_T = 'J/d.cm^2';   label.p_T = '{p_T}, surf-spec somatic maint'; 
par.k_J = 0.002;      free.k_J   = 0;   units.k_J = '1/d';        label.k_J = 'maturity maint rate coefficient'; 
par.E_G = 2374;       free.E_G   = 0;   units.E_G = 'J/cm^3';     label.E_G = '[E_G], spec cost for structure'; 
par.E_Hb = 0.00017859;  free.E_Hb  = 1;   units.E_Hb = 'J';         label.E_Hb = 'maturity at birth'; 
par.E_Hs = 0.00018583;  free.E_Hs  = 1;   units.E_Hs = 'J';         label.E_Hs = 'maturity at settlement'; 
par.E_Hj = 0.020766;  free.E_Hj  = 1;   units.E_Hj = 'J';         label.E_Hj = 'maturity at metam'; 
par.E_Hp = 1.7788;    free.E_Hp  = 1;   units.E_Hp = 'J';         label.E_Hp = 'maturity at puberty'; 
par.h_a = 1.0292e-08;  free.h_a   = 1;   units.h_a = '1/d^2';      label.h_a = 'Weibull aging acceleration'; 
par.s_G = 0.0001;     free.s_G   = 0;   units.s_G = '-';          label.s_G = 'Gompertz stress coefficient'; 

%% other parameters 
par.E_X = 7.6e-07;    free.E_X   = 0;   units.E_X = 'J/cell';     label.E_X = 'energy content of a Skeletonema cell'; 
par.L_0 = 0.1461;     free.L_0   = 0;   units.L_0 = 'cm';         label.L_0 = 'length at start of experiment'; 
par.L_25d = 0.01095;  free.L_25d = 0;   units.L_25d = 'cm';       label.L_25d = 'length at start of experiment for tWw data'; 
par.L_2d = 0.008392;  free.L_2d  = 0;   units.L_2d = 'cm';        label.L_2d = 'length at start of experiment for tWw data'; 
par.L_Fabi = 6.3982;  free.L_Fabi = 1;   units.L_Fabi = 'cm';      label.L_Fabi = 'length at 15 d for FabiHuve2005 data'; 
par.M_X = 2.414e-14;  free.M_X   = 0;   units.M_X = 'mol/cell';   label.M_X = 'mol per cell of micro-algae in Rico-data'; 
par.T_A = 8000;       free.T_A   = 0;   units.T_A = 'K';          label.T_A = 'Arrhenius temperature'; 
par.T_ref = 293.15;   free.T_ref = 0;   units.T_ref = 'K';        label.T_ref = 'Reference temperature'; 
par.V_X = 85;         free.V_X   = 0;   units.V_X = 'µm3/cell';   label.V_X = 'volume per cell of Sketetonema'; 
par.del_Mb = 0.86913;  free.del_Mb = 1;   units.del_Mb = '-';       label.del_Mb = 'shape coefficient before metam'; 
par.del_Mj = 0.19664;  free.del_Mj = 1;   units.del_Mj = '-';       label.del_Mj = 'shape coefficient after metam'; 
par.del_sh = 3.9998;  free.del_sh = 1;   units.del_sh = '-';       label.del_sh = 'shape coefficient shell in wet weight'; 
par.e_0 = 0.772;      free.e_0   = 0;   units.e_0 = '-';          label.e_0 = 'scaled res density at start of experiment'; 
par.f = 0.8;          free.f     = 0;   units.f = '-';            label.f = 'scaled functional response for 0-var data'; 
par.f_Fabi = 1.1659;  free.f_Fabi = 1;   units.f_Fabi = '-';       label.f_Fabi = 'scaled functional response for FabiHuve2005 data'; 
par.f_Goul = 0.084182;  free.f_Goul = 1;   units.f_Goul = '-';       label.f_Goul = 'scaled functional response for GoulWolo2004 data'; 
par.f_Mark = 0.56041;  free.f_Mark = 1;   units.f_Mark = '-';       label.f_Mark = 'scaled functional response for Mark2011 data'; 
par.f_Rico = 0.039129;  free.f_Rico = 1;   units.f_Rico = '-';       label.f_Rico = 'scaled functional response for Rico-data'; 
par.s_H = 0.5137;     free.s_H   = 0;   units.s_H = '-';          label.s_H = 'fraction of wet weight that is measured as a result of removing all body fluids'; 

%% set chemical parameters from Kooy2010 
[par, units, label, free] = addchem(par, units, label, free, metaData.phylum, metaData.class);

%% Pack output: 
txtPar.units = units; txtPar.label = label; par.free = free; 
