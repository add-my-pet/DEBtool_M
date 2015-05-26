function f = fnlm (y)
  %% called from flocpirt and flocdeb to calculate
  %%   scaled maximum thickness of living layer in a floc
  %%   integrate between sD and s0=S/K, multiply by 1/sqrt(2)
  global sD
  
  f = 1./sqrt(y - sD + log((1 + sD)./(1 + y)));
