function r = r_v1(p, f)
  %% r = r_v1(p, f)
  %% spec pop growth rate for dividing V1-morphs, cf r_iso
  %% f: n-vector with scaled func reponses
  %% p: parameter vector (see below)
  %% r: n-vector with spec growth rates

  %% unpack parameters
  pAm = p(1); pM = p(2); Em = p(3); EG = p(4); kap = p(5); ha = p(6);

  %% compound parameters
  g = EG/ (kap * Em); kE = pAm/ Em; kM = pM/ EG;

  %% spec growth rate
  r = (f * kE - kM * g) ./ (f + g) - ha * f .* (1 + g) ./ (f + g);
