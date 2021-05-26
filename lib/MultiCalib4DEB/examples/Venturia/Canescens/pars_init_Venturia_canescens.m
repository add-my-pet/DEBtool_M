function [par, metaPar, txtPar] = pars_init_Venturia_canescens(metaData)

metaPar.model = 'hex'; 

%% reference parameter (not to be changed) 
par.T_ref = 293.15;   free.T_ref = 0;   units.T_ref = 'K';        label.T_ref = 'Reference temperature'; 

%% core primary parameters 
par.T_A = 8000;       free.T_A   = 0;   units.T_A = 'K';          label.T_A = 'Arrhenius temperature'; 
par.z = 0.15439;      free.z     = 1;   units.z = '-';            label.z = 'zoom factor'; 
par.F_m = 6.5;        free.F_m   = 0;   units.F_m = 'l/d.cm^2';   label.F_m = '{F_m}, max spec searching rate'; 
par.kap_X = 0.8;      free.kap_X = 0;   units.kap_X = '-';        label.kap_X = 'digestion efficiency of food to reserve'; 
par.kap_P = 0.1;      free.kap_P = 0;   units.kap_P = '-';        label.kap_P = 'faecation efficiency of food to faeces'; 
par.v = 0.027812;     free.v     = 1;   units.v = 'cm/d';         label.v = 'energy conductance'; 
par.kap = 0.97634;    free.kap   = 1;   units.kap = '-';          label.kap = 'allocation fraction to soma'; 
par.kap_R = 0.98039;  free.kap_R = 1;   units.kap_R = '-';        label.kap_R = 'reproduction efficiency'; 
par.kap_V = 0.8;      free.kap_V = 0;   units.kap_V = '-';        label.kap_V = 'conversion efficient E -> V -> E'; 
par.p_M = 5531.7867;  free.p_M   = 1;   units.p_M = 'J/d.cm^3';   label.p_M = '[p_M], vol-spec somatic maint'; 
par.p_T = 0;          free.p_T   = 0;   units.p_T = 'J/d.cm^2';   label.p_T = '{p_T}, surf-spec somatic maint'; 
par.k_J = 0.002;      free.k_J   = 0;   units.k_J = '1/d';        label.k_J = 'maturity maint rate coefficient'; 
par.E_G = 4600;       free.E_G   = 0;   units.E_G = 'J/cm^3';     label.E_G = '[E_G], spec cost for structure'; 
par.E_Hb = 1.362e-02; free.E_Hb  = 1;   units.E_Hb = 'J';         label.E_Hb = 'maturity at birth'; 
par.s_j = 0.98239;    free.s_j   = 1;   units.s_j = '-';          label.s_j = 'scaled reproduction buffer density'; 
par.E_He = 1.573e+00; free.E_He  = 1;   units.E_He = 'J';         label.E_He = 'maturity at emergence'; 
par.h_a = 1.179e-04;  free.h_a   = 1;   units.h_a = '1/d^2';      label.h_a = 'Weibull aging acceleration'; 
par.s_G = 0.0001;     free.s_G   = 0;   units.s_G = '-';          label.s_G = 'Gompertz stress coefficient'; 

%% other parameters 
par.E_Hx = 1.412e-05; free.E_Hx  = 1;   units.E_Hx = 'J';         label.E_Hx = 'maturity at pre-birth (when embryo starts absorbation)'; 
par.f = 1;            free.f     = 0;   units.f = '-';            label.f = 'scaled functional response for 0-var data'; 
par.k_E = 0.22664;    free.k_E   = 1;   units.k_E = '1/d';        label.k_E = 'reproduction buffer turnover of imago'; 
par.k_EV = 1.8882;    free.k_EV  = 1;   units.k_EV = '1/d';       label.k_EV = 'spec decay rate of larval structure in pupa'; 

%% set chemical parameters from Kooy2010 
[par, units, label, free] = addchem(par, units, label, free, metaData.phylum, metaData.class); 

%% Pack output: 
txtPar.units = units; txtPar.label = label; par.free = free; 
