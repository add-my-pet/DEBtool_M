function [par, metaPar, txtPar] = pars_init_no_pet(metaData)

metaPar.model = 'nat'; 


%% parameters 
par.a = 3.0757;       free.a     = 1;   units.a = '-';            label.a = 'intercept'; 
par.b = 0.35;         free.b     = 1;   units.b = 'l/d';          label.b = 'slope'; 

%% Pack output: 
txtPar.units = units; txtPar.label = label; par.free = free; 
