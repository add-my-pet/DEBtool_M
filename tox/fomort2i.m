function S = fomort2i (p, t, c1 ,c2)
  %  created 2006/03/11 by Bas Kooijman
  %
  %% Decription
  %  standard effects on survival: first-order-mortality
  %   first order toxico kinetics: NEC fixed for each compound
  %   hazard rate linear in the internal conc
  %
  %% Input
  %  p: (8,1) matrix with parameters values
  %  t: (nt,1) matrix with exposure times
  %  c1: (nA,1) matrix with concentrations of toxic compound type 1
  %  c2: (nB,1) matrix with concentrations of toxic compound type 2
  %
  %% Outout
  %  S: (nt,nA*nB) matrix with survival probabilities
  %
  %% Example of use
  %  see mydata_fomort2
  
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
    cB = max(1e-10,c2(j));
    for i = 1:nA
      cA = max(1e-10,c1(i)); 
      if 1 >= cA/ CA0 & 1 >= cB/ CB0
	S(:,i + (j - 1) * nA) = exp(- h0 * t);
      else
	t0A = - ones(nt,1) * (log(max(1e-10,1 - CA0/ cA)))/ kA;
	t0B = - ones(nt,1) * (log(max(1e-10,1 - CB0/ cB)))/ kB;
	t0 = max(t0A,t0B);
	tA = max(0,(exp(-kA * t0) - exp(-kA * t)))/ kA;
	tB = max(0,(exp(-kB * t0) - exp(-kB * t)))/ kB;
	tAB = max(0,(exp(-(kA + kB) * t0) - exp(-(kA + kB) * t)))/ (kA + kB);
	gA = - cA * tA + (cA - CA0) * max(0,t - t0A);
	gB = - cB * tB + (cB - CB0) * max(0,t - t0B);
	gAB = cA * cB * tAB + (cA - CA0) * (cB - CB0) * max(0,t - t0) ...
	    - cA * (cB - CB0) * tA - (cA - CA0) * cB * tB ;
        a = h0 * t + max(0, bA * gA + bB * gB + dAB * gAB);
        S(:,i + (j - 1) * nA) = exp(-a);
      end
    end
  end  
