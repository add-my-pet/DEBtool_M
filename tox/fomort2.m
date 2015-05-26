function S = fomort2 (p, t, c1 ,c2)
  %  created 2006/03/08 by Bas Kooijman, modified 2008/12/30
  %
  %% Descriptiob
  %  standard effects on survival: first-order-mortality
  %   first order toxico kinetics
  %   hazard rate linear in the internal conc
  %
  %% Input
  %  p: (8,1) matrix with parameters values
  %  t: (nt,1) matrix with exposure times
  %  c1: (nA,1) matrix with concentrations of toxic compound type 1
  %  c2: (nB,1) matrix with concentrations of toxic compound type 2
  %
  %% Output
  %  S: (nt,nA*nB) matrix with survival probabilities
  %
  %% Example of use
  %n see mydata_fomort2

  global cA cB CA0 CB0 kA kB

  
  %% unpack parameters
  h0 = p(1);  % 1/h, blank mortality prob rate (always >0)
  CA0 = p(2); % mM, No-Effect-Concentration for A (external, may be zero)
  CB0 = p(3); % mM, No-Effect-Concentration for B (external, may be zero)
  bA = p(4);  % 1/(h*mM), killing rate for A
  bB = p(5);  % 1/(h*mM), killing rate for B
  kA = p(6);  % 1/h, elimination rate for A
  kB = p(7);  % 1/h, elimination rate for B
  dAB = p(8); % 1/(h*mM^2), interaction rate for A and B

  nt = length(t); % number of time points
  nA = length(c1); % number of values for conc A
  nB = length(c2); % number of values for conc B

  S = zeros(nt, nA*nB); % initiate output
  for j = 1:nB
    cB = c2(j);
    for i = 1:nA
      cA = c1(i); 
      if 1 >= cA/ CA0 + cB/ CB0
	S(:,i + (j - 1) * nA) = exp(- h0 * t);
      else
        [t0 ft info] = fzero('find_effect_time', 0); % no-effect-time
	if info ~= 1| 1e-8 < abs(ft)
	  [t0 ft info] = fzero('find_effect_time', 1);
	  if info ~= 1 | 1e-8 < abs(ft)
	    fprintf('no convergence for effect time \n');
	  end
	end
	CA0B = (1 - exp(-t0 * kA)) * cA;
	CB0A = (1 - exp(-t0 * kB)) * cB;	
	t0 = ones(nt,1) * t0;
	tA = max(0,(exp(-kA * t0) - exp(-kA * t)))/ kA;
	tB = max(0,(exp(-kB * t0) - exp(-kB * t)))/ kB;
	tAB = max(0,(exp(-(kA + kB) * t0) - exp(-(kA + kB) * t)))/ (kA + kB);
	gA = - cA * tA + (cA - CA0B) * max(0,t - t0);
	gB = - cB * tB + (cB - CB0A) * max(0,t - t0);
	gAB = cA * cB * tAB + (cA - CA0B) * (cB - CB0A) * max(0,t - t0) ...
	    - cA * (cB - CB0A) * tA - (cA - CA0B) * cB * tB ;
        a = h0 * t + max(0,bA * gA + bB * gB + dAB * gAB);
        S(:,i + (j - 1) * nA) = exp(-a);
      end
    end
  end  
