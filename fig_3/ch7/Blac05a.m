%% fig:Blac05a
%% out:Blac05a

%% concentration gradients of substrates around cells

l = linspace(0.1,1,100)';
X = grad([1;5;5], l); lX5 = [[l, X]; [1.1 5]];
X = grad([1;5;2], l); lX2 = [[l, X]; [1.1 2]];
X = grad([1;5;1], l); lX1 = [[l, X]; [1.1 1]];
X = grad([1;5;.5], l); lXi2 = [[l, X]; [1.1 .5]];

%% gset term postscript color solid "Times-Roman" 35
%% gset output "Black05a.ps"

plot(lXi2(:,1), lXi2(:,2), '-r', ...
     lX1(:,1), lX1(:,2), '-g', ...
     lX2(:,1), lX2(:,2), '-b', ...
     lX5(:,1), lX5(:,2), '-m', ...
     [1; 1],  [5; 0], ':k')
legend('0.5', '1', '2', '5', 4);
xlabel('distance')
ylabel('scaled concentration X/K')
title ('X1/K')
