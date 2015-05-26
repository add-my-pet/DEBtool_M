%% fig:Bert_fig
%% out:bert_fig

t = linspace(0,2,50)';
L = 5 - 4*exp(-t);

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'bert.ps'

%% gset nokey
%% gset xrange[-.25:2]
%% gset yrange[0:5]
%% gset noborder
%% gset xtics 100
%% gset ytics 100
plot([-.25;2],[0;0],'k', [0;0],[0;5],'k', ...
     t,L,'g', [0;3], ...
     [5;5],'r', [-.25;1], [0;5],'r', [1;1],[0;5],'r', ...
     [0;.2],[1;1],'b', [0;1], [0;5],'b',[.2;.2],[0;1],'b',[0;.2],[0,0],'b', ...
     [-.2;0],[0,0],'m')

