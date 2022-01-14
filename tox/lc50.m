%% lc50
% calculates LC50 values from parameter values

%%
function [c, ERR] = lc50 (p, tc)
% created 2002/02/05 by Bas Kooijman

%% Syntax
% [c, ERR] = <../lc50.m *lc50*> (p, tc) 

%% Description
% calculates LC50 values from parameter values
%
% Input:
%
% * p: 3-vector with NEC, killing rate and elimination rate
% * tc: n-vector with exposure times
%
% Ouput:
%
% * c: n-vector with LC50 values for the exposure times 
% * ERR: scalar with indicator for failure (0) or success (1) of numerical procedure 

%% Example of use
% lc50([1, 1, 1], [3 4]), which results in a 2-vector with [LC50.3d LC50.4d]. 
% Another application in regression and plotting routines is given in the script-file <../mydata_lc50.m *mydata_lc50*>, 
% where LC50 data are used to extract the toxicity parameters 
% (so just opposite to the previous application). 
%  Consult the script-file for further explanation. 

  
  global t C0 Bk Ke;

  options = optimset('Display','off'); 
  
  % unpack parameters
  C0 = p(1); Bk = p(2); Ke = p(3);

  % initiate output vector
  tc = tc(:,1); nt = length(tc); c = ones(nt,1); ERR = c;
  
  for i = 1:nt
    t = tc(i,1); % get exposure time
    %LC0 = 1.1*C0./(1 - exp(-Ke * t)); % guess given Bk = infty
    
    [LC, fl, err] = fzero('fnlc50', 2*C0, options); % recalculate LC50
  
    c(i) = LC; ERR(i) = err;
  
  end
  x=1;