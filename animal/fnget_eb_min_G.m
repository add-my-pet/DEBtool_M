function f_G = fnget_eb_min_G(eb,x)
  
  global par_eb_min

  f_G = get_lb(par_eb_min, eb, eb) - eb;
  