%% fig:juv
%% out:juv

%% effect of juvenile period and discrete reprod on spec growth rate

apR = linspace(0, 5, 100)'; % juv period axis
cont = cjuv (apR); % continuous reprod
disc = djuv (apR); % discrete repod

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'juv.ps'

plot(apR, cont, '-r', apR, disc, '-g')
title('Effect of juvenile period and discreteness of individuals')
legend('continuous reproduction', 'discrete reproduction', 1)
xlabel('scaled juvenile period')
ylabel('scaled spec pop growth rate')
