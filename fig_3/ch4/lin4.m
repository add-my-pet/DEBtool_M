function [E Prot Lip Carb] = lin4 (p, tE, tProt, tLip, tCarb)
  %% unpack pars
  E0 = p(1); JE = p(2);  P0 = p(3); JP = p(4); L0 = p(5); JL = p(6);
  C0 = p(7); JC = p(8);

  E = E0 - JE * tE(:,1);
  Prot = P0 - JP * tProt(:,1);
  Lip = L0 - JL * tLip(:,1);
  Carb = C0 - JC * tCarb(:,1);