function llc = Pow2Lc50 (p, lPow)
  %% we assume NEC = 0; this allows simple LC50 calculations
  %% unpack parameters
  K = p(1); B = p(2);
  t = 14; % exposure time (given)

  np = length(lPow); llc = zeros(np,1);

  for i = 1:np
    Pow = 10^lPow(i,1); Bk = Pow * 10^B; Ke = K/ sqrt(Pow);
    %% Eq (6.27) at {206} for c_0 = 0 and so t_0 = 0:
    %% - ln 2 = c (1 - exp(-t ke)) b/ ke - b c t
    tKe = t * Ke ; LC = log(2) * (Ke/ Bk)/ (tKe - 1 + exp(- tKe));
    llc(i) = log10(LC);
  end
