function [par, metaPar, txtPar] = pars_init_OECD221_Cd(metaData)

metaPar.model = 'nat'; 


%% parameters 
% stress
par.c0 = 0.00049955;    free.c0 = 1; units.c0 =  'mM'; label.c0 = ' No-Effect-Concentration (external, may be zero)';
par.cA = 0.0053618;free.cA = 1;  units.cA = 'mM'; label.cA = 'tolerance concentration';
par.ke = 0.0010741;    free.ke = 1; units.ke = '1/d'; label.ke = 'elimination rate at L = Lm';
% DEB
par.kap = 0.58;   free.kap = 0; units.kap =  '-'; label.kap = 'fraction allocated to growth + som maint';
par.kap_R = 0.95; free.kap_R = 0; units.kap_R = '-'; label.kap_R = 'fraction of reprod flux that is fixed into embryo reserve'; 
par.g  = 4.94;    free.g = 0; units.g = '-'; label.g = 'energy investment ratio';
par.k_J = 0.002;  free.k_J = 0; units.k_J = '1/d'; label.k_J = 'maturity maint rate coeff';
par.k_M = 0.27;   free.k_M = 0; units.k_M = '1/d'; label.k_M = 'somatic maint rate coeff';
par.v  = 0.1809;  free.v = 0; units.v = 'cm/d'; label.v = 'energy conductance';
par.U_Hb = 0.00017433; free.U_Hb = 0; units.U_Hb = 'd.cm^2'; label.U_Hb = 'scaled maturity at birth';
par.U_Hp = 0.0034802; free.U_Hp = 0; units.U_Hp = 'd.cm^2'; label.U_Hp = 'scaled maturity at puberty';
% other
par.L0 = 0.026;   free.L0 = 0; units.L0 = 'cm'; label.L0 = 'initial structural length';
par.f = 1;        free.f = 0; units.f = '-'; label.f = 'scaled functional response';

%% Pack output: 
txtPar.units = units; txtPar.label = label; par.free = free; 
