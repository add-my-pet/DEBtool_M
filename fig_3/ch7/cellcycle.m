%% fig:cellcycle 
%% out:genome

%% growth of a rod at constant substrate
Vd = .2; f = 1; del = .01; kE = .2; g = 5; v = .2; kM = 1;
Vm = (v/ g/ kM)^3;
Vi = Vd * del/ 3/ ((Vd/Vm)^(1/3)/f - 1 + del/ 3);
r_rod = - Vd * f * kE * del/ 3/ Vi/ (f + g);
t0 = -1;
t = linspace(t0,4,100)';       
V = Vi - (Vi - Vd/2) * exp(- t * r_rod);

td = -log((Vi-Vd)/(Vi-Vd/2))/r_rod;
s = linspace(0,td,20)';
W = Vi - (Vi - Vd/2) * exp(- s * r_rod);

%% gset term postscript color solid "Times-Roman" 35
%% gset output "genome.ps"

plot(t, V, '-r', s, W, '-b', ...
     [0;0], [0; Vd/2], '-b', [t0;0], [Vd/2; Vd/2], '-b', ...
     [td;td], [0; Vd], '-b', [td;t0], [Vd; Vd], '-b')
xlabel('time');
ylabel('volume');
