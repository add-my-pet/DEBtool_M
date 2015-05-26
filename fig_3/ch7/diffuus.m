%% fig:diffuus
%% out:diffuus

%% concentration gradients of substrates around cells with barrier

l0 = .1; l2 = .15; l1 = .6; % positions of membrane, barrier, mantle edge
lb = linspace(l0,l2,20)'; % lengths between mambrane and barrier
l = linspace(l2,l1,80)'; % lengths between barrier and mantle edge
%% 4 choices of K1
K = 1; K1 = 5; LD = .05;
[Xb X] = gradb([K;K1;5;LD], lb, l);  lX5 =  [[lb, Xb]; [l, X]; [1.1*l1, 5]];
[Xb X] = gradb([K;K1;2;LD], lb, l);  lX2 =  [[lb, Xb]; [l, X]; [1.1*l1, 2]];
[Xb X] = gradb([K;K1;1;LD], lb, l);  lX1 =  [[lb, Xb]; [l, X]; [1.1*l1, 1]];
[Xb X] = gradb([K;K1;.5;LD], lb, l); lXi2 = [[lb, Xb]; [l, X]; [1.1*l1,.5]];

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'diffuus.ps'

plot(lXi2(:,1), lXi2(:,2), '-r', ...
     lX1(:,1), lX1(:,2), '-g', ...
     lX2(:,1), lX2(:,2), '-b', ...
     lX5(:,1), lX5(:,2), '-m', ...
    [l1; l1], [5; 0], ':k', ...
    [l2; l2], [5; 0], ':k')
legend('0.5', '1', '2', '5', 4);
xlabel('distance')
ylabel('scaled concentration X/K')
title('X1/K')
xlabel('distance')
ylabel('scaled concentration X/K')
title('X1/K')

