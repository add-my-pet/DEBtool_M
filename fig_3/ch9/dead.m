%% fig:dead
%% out:dead

%% fraction of dead cells in chemostat

h = linspace (1e-3,1,100)';
hf1 = [h, dfraction(h, .05, 0.01)];
hf2 = [h, dfraction(h, .1, 0.01)];
hf3 = [h, dfraction(h, .05, 0.1)];

%% gset term postscript color solid "Times-Roman" 35
%% gset output "dead.ps"

plot(hf1(:,1), hf1(:,2), '-r', ...
     hf2(:,1), hf2(:,2), '-g', ...
     hf3(:,1), hf3(:,2), '-b')
legend('.05 .01', '.1, .01', '.01, .1')
xlabel('scaled throughput rate')
ylabel('fraction of dead cells')
title('kM/rm, ha/rm')
