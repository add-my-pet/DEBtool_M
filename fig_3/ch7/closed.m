%% fig:closed
%% out:csu

%% production in SU's with open and closed handshaking protocols

p = [0 .4 .7 1 .8 1 1 1 1]; % set parameters
jXF = - linspace(1e-4,5,100)';   % set substrate flux

[jXRc jYRc jYPc jZPc] = fnclosed (p, jXF);
[jXRo jYRo jYPo jZPo] = fnopen (p, jXF);

o = [-jXF, jZPo]; c = [-jXF, jZPc];

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'closed.ps'

plot(o(:,1), o(:,2), 'g', ...
     c(:,1), c(:,2), 'r', ...
     -jXF, (jZPo + jYRo), 'g', ...
     -jXF, (jZPc + jYRc), 'r')
legend('open', 'closed')
title('open and closed handshaking');
xlabel('substrate flux -j_{XF}');
ylabel('production of Z and Y+Z');
