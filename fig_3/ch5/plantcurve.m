%% fig:plantcurve
%% out:plant

%% plant growth, see domain plant for more details
    
%% gset term postscript color solid "Times-Roman" 35
%% gset output "plant.ps"
%% gset nokey;

clf
hold on;
pars_plant; % set parameters for flux

shregr2_options('default')
shtime_plant(1)

X(1) = .01;  
shtime_plant(1)

title('reduce light from 5 to .01')