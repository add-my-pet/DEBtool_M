%% fig:cartox
%% out:carv,carbr,cardmq,carcr,caraa,carcol
%% feeding rate (1000 cells/ind.d) as function of concentration toxicant

%% metavanadate (mg/l)
V =  [0 0.9650679272;
      0.32 0.914201688;
      0.56 1.097126471;
      1 1.5565559;
      1.8 3.136780035;
      3.2 0]; V(1,1) = V(2,1)/sqrt(3); 

%% sodium bromide (mg/l)
BR = [0 1.400319578;
      0.32 1.243851123;
      1 1.454884993;
      3.2 1.806682188;
      10 1.929220388;
      32 3.458039287]; BR(1,1) = BR(2,1)/sqrt(10); 

%% 2,6-dimethylquinoline (mg/l)
DMQ = [0 1.660494681;
       1 1.809707959;
       1.8 1.580399748;
       3.2 1.547494648;
       5.6 2.002222524;
       10 2.308161614]; DMQ(1,1) = DMQ(2,1)/sqrt(3); 

%% potassium dicromate (mg/l)
CR = [0 1.522761286;
      0.18 1.082066861;
      0.32 1.170782442;
      0.56 1.347392539;
      1 2.79990316;
      1.8 0]; CR(1,1) = CR(2,1)/sqrt(3); 

%% 9-aminoacridine (mg/l)
AA = [0 1.166168588;
      0.056 1.98730844;
      0.1 1.904326394;
      0.18 1.247484556;
      0.32 2.19937259
      0.56 0]; AA(1,1) = AA(2,1)/sqrt(3); 

%% colchicine (mg/l)
COL = [0 1.464812738;
       0.1 1.203463189;
       0.18 1.247625369;
       0.32 1.337372273
       0.56 0]; COL(1,1) = COL(2,1)/sqrt(3); 

subplot(2,3,1);
plot(log10(V(1:5,1)), V(1:5,2),'.g', log10(V(6,1)), V(6,2), '.r')
title('metavanadate');
xlabel('10 log mg V/l');
ylabel('1000 cells (ind.d)^-1')

subplot(2,3,2);
plot(log10(BR(:,1)), BR(:,2),'.g')
title('sodium bromide');
xlabel('10 log mg Br/l');
ylabel('1000 cells (ind.d)^-1')

subplot(2,3,3);
plot(log10(DMQ(:,1)), DMQ(:,2),'.g')
title('2,6-dimethylquinoline');
xlabel('10 log mg DMQ/l');
ylabel('1000 cells (ind.d)^-1')

subplot(2,3,4);
plot(log10(CR(1:4,1)), CR(1:4,2),'.g', log10(CR(5:6,1)), CR(5:6,2), '.r')
title('potassium dichromate');
xlabel('10 log mg K2Cr2O7/l');
ylabel('1000 cells (ind.d)^-1')

subplot(2,3,5);
plot(log10(AA(1:5,1)), AA(1:5,2),'.g',log10(AA(6,1)), AA(6,2),'.r')
title('9-aminoacridine');
xlabel('10 log mg AA/l');
ylabel('1000 cells (ind.d)^-1')

subplot(2,3,6);
plot(log10(COL(1:4,1)), COL(1:4,2),'.g', log10(COL(5,1)), COL(5,2),'.r')
title('colchicine');
xlabel('10 log mg Col/l');
ylabel('1000 cells (ind.d)^-1')

