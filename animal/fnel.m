function del = fnel(el)
  % change in e and l for isomorph cf {222}
  % called from shphase_el

  global kT_M g l_T l_b kap f

  if el(1) < kap * g * el(2)/ (g + (1 - kap) *el(2) + l_T)
    del = [0; 0]; % death because p_C < p_M
    
  elseif el(2) < l_b % embryo
    del = kT_M * [- g * el(1)/ el(2);
       		(el(1) - el(2) - l_T)/ (3 + 3 * el(1)/ g)];

  else % juvenile or adult
    del = kT_M * [g * (f - el(1))/ el(2);
       		(el(1) - el(2) - l_T)/ (3 + 3 * el(1)/ g)];
  end
