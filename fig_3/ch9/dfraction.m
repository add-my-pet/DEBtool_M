function f = dfraction(h, kM, ha)
  %% h: vector with scaled throughput rate h/ rm
  %% kM: scalar scaled maintenance rate coefficient kM/ rm
  %% ha: scalar with scaled aging rate ha/ rm
  %% f: vector with fraction dead cells at equilibrium

  %% assume Xr high and/or K low, so hm = rm, cf Eq (9.16) {317}
  f = (kM + h) ./ (kM + (kM + 1 + ha) * h/ ha); 
