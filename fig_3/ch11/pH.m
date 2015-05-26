%% fig:pH
%% out:water

V = (.02:.001:1.6)'; % cell volumes in mum^3

i95 = pH_interval(V,.95);
i90 = pH_interval(V,.90);
i80 = pH_interval(V,.80);
i60 = pH_interval(V,.20);
i00 = pH_interval(V,.00001); 

plot(V, i95(:,1),'r', V, i95(:,2),'r', ...
     V, i90(:,1),'m', V, i90(:,2),'m', ...
     V, i80(:,1),'b', V, i80(:,2),'b', ...
     V, i60(:,1),'g', V, i60(:,2),'g', ...
     V, i00(:,1),'k')