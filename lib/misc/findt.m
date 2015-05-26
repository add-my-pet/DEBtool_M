function f = findt (T)
  % function to find temp for which tempcorr is 0.01
      global t_1 tpars;
  f = log(tempcorr(T,t_1, tpars)) - log(0.01);
