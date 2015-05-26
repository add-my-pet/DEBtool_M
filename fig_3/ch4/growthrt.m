function del = growthrt (t, el)
  global g f
  del = [(f - el(1)) * g/ el(2); (g/ 3) * (el(1) - el(2))/ (el(1) + g)];
