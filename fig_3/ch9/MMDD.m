%% fig:MMDD
%% out:mumpdd

%% DEB (for V1-morphs) versus Monod, Marr-Pirt, Droop

x = linspace(0, 5, 100)';
xrMonod = [x, x ./ (1 + x)];
g = 1; G = g/(1 + g); xrDroop = [x, max(0,x ./ (x + G))];
ld = .1; xrMarr = [x, max(0,(x - ld /(1 - ld)) ./ (x + 1))]; 
xrDEB = [x, max(0,(x - ld/(1 - ld)) ./ (x + g/(1 + g)))];

%% gset term postscript color solid "Times-Roman" 35
%% gset output "mumpdd.ps"

plot(xrDEB(:,1), xrDEB(:,2), '-g', ...
     xrDroop(:,1), xrDroop(:,2), '-b', ...
     xrMonod(:,1), xrMonod(:,2), '-r', ...
     xrMarr(:,1), xrMarr(:,2), '-m', ...
    [0 .5 .5], [.5 .5 0], '-b', ...
    [.5 1 1], [.5 .5 0], '-r', ...
    [1 1.222 1.222], [.5 .5 0], '-m')
legend('DEB', 'Droop', 'Monod', 'Marr', 4)
title('DEB versus Monod, Marr-Pirt, Droop')
xlabel('scaled substrate concentration')
ylabel('scaled spec pop growth rate')