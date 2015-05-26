function [c, ERR] = lc50 (p, tc)
  %  created 2002/02/05 by Bas Kooijman
  %
  %% Description
  %  calculates LC50 values from parameter values
  %
  %% Input
  %  p: 3-vector with NEC, killing rate and elimination rate
  %  tc: n-vector with exposure times
  %
  %% Output
  %  c: n-vector with LC50 values for the exposure times 
  %  ERR:
  %
  %% Example of use
  %  lc50([1, 1, 1], [3 4]), which results in a 2-vector with [LC50.3d LC50.4d]. 
  %  Another application in regression and plotting routines is given in the script-file mydata_lc50, 
  %    where LC50 data are used to extract the toxicity parameters 
  %   (so just opposite to the previous application). 
  %  Consult the script-file for further explanation. 

  %% Code
  global t C0 Bk Ke;

  opt = optimset('display','off');
  %% unpack parameters
  C0 = p(1); Bk = p(2); Ke = p(3);

  %% initiate output vector
  [nt i] = size(tc); c = ones(nt,1); ERR = c;
  
  for i = 1:nt
    t = tc(i,1); % get exposure time
    LC = 1.1*C0./(1 - exp(-Ke * t)); % guess given Bk = infty
    
    [LC, fl, err] = fsolve('fnlc50', LC, opt); % recalculate LC50
  
    c(i) = LC; ERR(i) = err;
  
  end