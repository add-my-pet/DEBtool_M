function y = respi (p,rw)
  %% called from fig_8_2
  %% log body weight as function of log respiration rate
  %%    notice the different standard: respiration as function of body weight
  %% p(1) = d_v/[p_M]; p(2) = w_E [M_Em] [p_M]^{-4/3} V_m^{-1/3}
  r = 10.^rw(:,1);
  y = log10(p(1) * r + p(2) * r.^(4/3));
  