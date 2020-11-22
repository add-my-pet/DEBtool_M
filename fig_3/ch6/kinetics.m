%% fig:kinetics
%% out:oecd0,oecd1

t = linspace(1e-3, 2, 100)';

global k;

k = 10; lb = 0.18;
  [t c0_10] = ode23('tissue', t, [lb; 0]); tc0_10 = [t, c0_10(:,2)];
  [t c1_10] = ode23('tissue', t, [lb; 1]); tc1_10 = [t, c1_10(:,2)];
k =  2;
  [t c0_2]  = ode23('tissue', t, [lb; 0]); tc0_2 = [t, c0_2(:,2)];
  [t c1_2]  = ode23('tissue', t, [lb; 1]); tc1_2 = [t, c1_2(:,2)];
k =  1;
  [t c0_1]  = ode23('tissue', t, [lb; 0]); tc0_1 = [t, c0_1(:,2)];
  [t c1_1]  = ode23('tissue', t, [lb; 1]); tc1_1 = [t, c1_1(:,2)];
k =  0.5;
  [t c0_05]  = ode23('tissue', t, [lb; 0]); tc0_05 = [t, c0_05(:,2)];
  [t c1_05]  = ode23('tissue', t, [lb; 1]); tc1_05 = [t, c1_05(:,2)];
k =  0.1;
  [t c0_01]  = ode23('tissue', t, [lb; 0]); tc0_01 = [t, c0_01(:,2)];
  [t c1_01]  = ode23('tissue', t, [lb; 1]); tc1_01 = [t, c1_01(:,2)];
  %% scaled length
  tl = [t, c0_10(:,1)]; l = tl(:,2);
  %% scaled reproduction cf Fig 3.22 {116}
  tR = [t, (l.^2 + .004 * l.^3 - .07)/ (1 + .004 - .07)]; tR = tR(22:100,:);
  
%% gset term postscript color solid 'Times-Roman' 35

 subplot(1,2,1);
  plot(tc0_10(:,1), tc0_10(:,2), '-r', ...
        tc0_2(:,1), tc0_2(:,2), '-g', ...
        tc0_1(:,1), tc0_1(:,2), '-b', ...
        tc0_05(:,1), tc0_05(:,2), '-k', ...
        tc0_01(:,1), tc0_01(:,2), '-y', ...
        tl(:,1), tl(:,2), '-c', ...
        tR(:,1), tR(:,2), '-m')
  legend('10', '2', '1', '0.5', '0.1', 'length', 'reprod');
  title('cV(0) = 0'); % set yrange [0:1] 
  %% gset key 1.4, .6 title 'k_e/r_B'
  xlabel('scaled time'); ylabel('scaled tissue concentration');
     
  subplot(1,2,2);
  plot(tc1_10(:,1), tc1_10(:,2), '-r', ...
       tc1_2(:,1), tc1_2(:,2), '-g', ...
       tc1_1(:,1), tc1_1(:,2), '-b', ...
       tc1_05(:,1), tc1_05(:,2), '-k', ...
       tc1_01(:,1), tc1_01(:,2), '-y', ...
       tl(:,1), tl(:,2), '-c', ...
       tR(:,1), tR(:,2), '-m');
  legend('10', '2', '1', '0.5', '0.1', 'length', 'reprod');
  title('cV(0) = 1'); % set yrange [0:1]
  %% gset key 1.4,.6 title 'k_e/r_B'
  xlabel('scaled time'); ylabel('scaled tissue concentration');
