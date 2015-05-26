function [WV WE] = structure(W, pW)
  %% W: vector with body wet weights
  %% p: scalar with w_E [M_Em] V_m^{-1/3}
  %% WV: vector with structural body weights
  %% WV: vector with reserve body weights
  global w p;
  N = length(W); WE = W; WV = WE; p = pW; 
  for i=1:N
    w = W(i);
    [WV(i) val err] = fsolve('findWV',1);
    WE(i) = W(i) - WV(i);
  end
