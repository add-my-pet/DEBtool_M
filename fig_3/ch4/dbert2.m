function dLe = dbert2 (Le)
  global f Lm v g
  dLe = [(Le(2) - Le(1)/ Lm) * v/ (3 * (Le(2) + g)); (f - Le(2)) * v/ Le(1)];
  dLe(1) = max(0, dLe(1));
endfunction
