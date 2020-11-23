%% fig:Blac05
%% out:Blac05
%% functional response as dependent on mantle saturation coefficient

x = linspace(0,6,100)';
f0 = mantle([1;0], x);
f1 = mantle([1;1], x);
f5 = mantle([1;5], x);
f20 = mantle([1;20], x);
fi = mantle([1;1e5], x);

%% gset term postscript color solid "Times-Roman" 35
%% gset output "Black05.ps"

plot(x, f0, '-r', ...
     x, f1, '-g', ...
     x, f5, '-b', ...
     x, f20, '-m', ...
     x, fi, '-k', ...
     [0; 1; 1], [.5; .5; 0], '-r')
legend('0', '1', '5', '20', 'inf');
xlabel('X/(K + K1)');
ylabel('JX/ JXm');
title ('K1')
