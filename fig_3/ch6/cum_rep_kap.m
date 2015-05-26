%% effect of kap in cum reprod of D. magna at f=1
%% pars from fig_2_10

  z = 1; % zoom factor
  p = [.799; % 1, kap
       .950; % 2, kapR
       .1509; % 3, g
       3.569; % 4, kJ, d^-1
       4.063; % 5, kM, d^-1
       0; % 6, LT, mm
       z*1.6216; % 7, v, mm d^-1 (vol length)
       z^2*.00100; % 8, UHb, mm^2 d (vol length)
       z^2*.0491]; % 9, UHp, mm^2 d^-1 (vol length) 
  
   kap0 = p(1);
   [crep, Lb0, Lp0] = cum_reprod([0;21], 1, p); crep0 = crep(2); 

   kap = .15; % smallest value for kappa
     p(3) = p(3) * p(1)/ kap;
     p(1) = kap;
   [crep, Lb, Lp] = cum_reprod([0;21], 1, p);
   crep_vector = crep(2); Lb_vector = Lb; Lp_vector = Lp; kap_vector = p(1);


   a = 1.01; % increment factor for kappa
   while p(1)<.95
     p(1) = a * p(1);
     p(3) = p(3)/ a;
     [crep, Lb, Lp] = cum_reprod([0;21], 1, p, Lb);
     crep_vector = [crep_vector; crep(2)];
     Lb_vector = [Lb_vector; Lb];
     Lp_vector = [Lp_vector; Lp];
     kap_vector = [kap_vector;p(1)];
   end

   subplot(1,3,1)
   plot(kap_vector, crep_vector, 'r', kap0, crep0, 'or')
   xlabel('kappa')
   ylabel('cum reproduction')
   

   subplot(1,3,2)
   plot(kap_vector, Lb_vector,'r', kap0, Lb0, 'or')
   xlabel('kappa')
   ylabel('Lb')

   subplot(1,3,3)
   plot(kap_vector, Lp_vector,'r', kap0, Lp0, 'or')
   xlabel('kappa')
   ylabel('Lp')