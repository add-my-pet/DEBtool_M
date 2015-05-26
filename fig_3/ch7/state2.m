function [A B X1 a C X2] = state2(p, tA, tB, tX1, ta, tC, tX2)
  %% mutual substrate uptake inhibition in two data sets: BranKelp2001
  %%   substrates A,B & A,C together with biomass (6 time trajectories)
  
  global KA KB yEA yEB yEV kE kM jAm jBm w h
  global tkA1 tkA2 tmE1 tmE2

  %% unpack parameters
  x01 = p([1:5]'); x02 = p([6:10]'); % initial conditions
  KA = p(11); KB = p(12); KC = p(13);
  yEA = p(14); yEB = p(15); yEC = p(16); yEV = p(17);
  jAm = p(18); jBm = p(19); jCm = p(20); kE = p(21); kM = p(22); 
  w = p(23); w2 = p(24); h = p(25); h2 = p(26);

  %% data set 1
  [t A] = ode23('dstate', tA(:,1), x01); A = A(:,1); % substrate A
  [t B] = ode23('dstate', tB(:,1), x01); B = B(:,2); % substrate B
  [t X1] = ode23('dstate', tX1(:,1), x01); 
  tkA1 = [tX1(:,1), X1(:,4)]; tmE1 = [tX1(:,1), X1(:,5)]; % kappa & reserve density
  X1 = X1(:,3); % biomass
  %% data set 2
  KB = KC; yEB = yEC; jBm = jCm; w = w2; h = h2; % overwrite pars
  [t a] = ode23('dstate', ta(:,1), x02); a = a(:,1); % substrate A
  [t C] = ode23('dstate', tC(:,1), x02); C = C(:,2); % substrate C
  [t X2] = ode23('dstate', tX2(:,1), x02);
  tkA2 = [tX2(:,1), X2(:,4)]; tmE2 = [tX2(:,1), X2(:,5)]; % kappa & reserve density
  X2 = X2(:,3); % biomass
