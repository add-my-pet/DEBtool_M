%% isotope_flux
% calculates changes otolith masses

%%
function dMd = isotope_flux(t, Md)
  %  created 2008/02/10 by Bas Kooijman, modified 2008/03/17
  
  %% Syntax 
  % dMd = <../isotope_flux.m *isotope_flux*> (t, Md)
  
  %% Description
  %
  % Input
  %
  % * t: scalar with time
  % * Md: 13-vector with values for
  %      res M_E, struc M_V, mat M_H, otol M_OD, otol M_OG, del_*E, del_*V
  %
  % Output
  %
  % * dMd: 13-vector with changes in Md
  
  %% Remarks
  %  Called from isotope

  global tTXd n_M n_O aA aD aG odds
  global JEAm yEX yVE JEM JET kJ kap kapR MHb MHp MV yPX yVE_D kapD TA
  global yOE_D yOE_G delS % otolith yields (C-moles), shape of otosac
  global K kM MEm mEm g Lm Lh T_ref Y_ME_A Y_ME_D Y_ME_G
  
  % unpack state variables
  M_E = Md(1); M_V = Md(2); M_H = Md(3);
  M_OD = Md(4); M_OG = Md(5); M_O = M_OD + M_OG; % otolith mass
  del_CE = Md(6);  del_HE = Md(7);  del_OE = Md(8);  del_NE = Md(9);
  del_CV = Md(10); del_HV = Md(11); del_OV = Md(12); del_NV = Md(13);

  % determine environmental forcing at t by linear interpolation
  nt = sum(t >= tTXd(:,1));
  w = (t - tTXd(nt,1))/ (tTXd(nt+1,1) - tTXd(nt,1));
  TXd = w * tTXd(nt,2:8) + (1 - w) * tTXd(nt+1,2:8);
  T = TXd(1); X = TXd(2);
  del_CX = TXd(3); del_HX = TXd(4); del_OX = TXd(5); del_NX = TXd(6);
  del_OO = TXd(7);

  % adapt rates to current temperature		  
  cT = tempcorr(T, T_ref, TA);
  JEAmT = cT * JEAm; kJT = cT * kJ; 
  JEMT = cT * JEM; JETT = cT * JET;
 
  % convert variables
  f = X/ (X + K); % scaled functional response
  L = (M_V/ MV) ^ (1/3); % structural length
  ee = (M_E/ M_V)/ mEm; % scaled reserve density, dim-less

  % organic fluxes J_jk
  %   J = flux, j = compound, k = process; J_jk < 0 if j disappears
  J_EA = JEAmT * (M_H > MHb) * f * L^2; % assimilation, pos
  J_XA = - J_EA/ yEX; % food uptake; neg
  J_PA = - yPX * J_XA; % faeces production; pos
  J_EC = - JEAmT * L^2 * (g * ee / (g + ee)) * (1 + (Lh + L) / (g * Lm)); % neg
  J_EJ = - kJT * M_H; % maturity maintenance; neg
  J_ER = (1 - kap) * J_EC + J_EJ; % maturation/reproduction; neg
  J_EM = - JEMT * L ^ 3; % volume-linked somatic maintenance; neg
  J_ET = - JETT * L ^ 2; % surface-linked somatic maintenance; neg
  J_ED = J_EM + J_ET + J_EJ + (1 - (M_H > MHp) * kapR) * J_ER; % neg
  J_EG = min(-1e-9, kap * J_EC - J_EM - J_ET); % growth sink of reserve; neg
  J_VDs = 0; % shrinking; neg
  J_VG = - yVE * J_EG; % growth; pos
  % J_O = [J_XA, J_V, J_E + J_ER * kapR * (M_H > MHp), J_PA];
  J_OA = Y_ME_A(3) * J_EA; % neg
  J_OD = Y_ME_D(3) * J_ED; % neg
  J_OG = Y_ME_G(3) * J_EG; % neg
  J_VD = yVE_D * J_ED; % neg

  % mineral fluxes: J_M * n_M' + J_O * n_O'= 0
  % J_M = - J_O * n_O'/n_M';

  % coefficients n_is_0k; n_O: food X, structure V, reserve E, faeces P
  %   n = chem index, i = element, s = substrate, 0 = isotope, k = process
  % modified by odds ratios that are unequal to one
  %   if odds ratio == 1 anabolic (a) and catabolic (c) substrates have
  %     isotope ratio of the total flux A, D, G
  %  (4,4)-matrix of odds ratios has elements in rows and 
  %  cols of odds: X in assim A_a, E,V in dissi D_a, E in growth G_a
  % anabolic assim substr (X,O)
  n_CX_0A = n_O(1,1) * del_CX; n_CX_0Aa = n_CX_0A; n_CX_0Ac = n_CX_0A;
  if odds(1,1) ~= 1  
    kapAa = yEX; kapAc = 1 - kapAa;
    B = n_CX_0A - kapAc - (n_CX_0A + kapAa) * odds(1,1); 
    C = 4 * (1 - odds(1,1)) * odds(1,1) * n_CX_0A * kapAa;
    n_CX_0Aa = 2 * n_CX_0A * odds(1,1)/ (sqrt(B * B + C) - B);
    n_CX_0Ac = (n_CX_0A - n_CX_0Aa * kapAa)/ kapAc;
    %% n_CX_0A = (kapAa * n_CX_0Aa + kapAc * n_CX_0Ac);
  end
  n_HX_0A = n_O(2,1) * del_HX; n_HX_0Aa = n_HX_0A; n_HX_0Ac = n_HX_0A;
  if odds(2,1) ~= 1
    kapAa = yEX; kapAc = 1 - kapAa;
    B = n_HX_0A - kapAc - (n_HX_0A + kapAa) * odds(2,1); 
    C = 4 * (1 - odds(2,1)) * odds(2,1) * n_HX_0A * kapAa;
    n_HX_0Aa = 2 * n_HX_0A * odds(2,1)/ (sqrt(B * B + C) - B);
    n_HX_0Ac = (n_CX_0A - n_HX_0Aa * kapAa)/ kapAc;
    %% n_HX_0A = (kapAa * n_HX_0Aa + kapAc * n_HX_0Ac);
  end
  n_OO_0A = n_M(3,3) * del_OO;
  n_OX_0A = n_O(3,1) * del_OX; n_OX_0Aa = n_OX_0A; n_OX_0Ac = n_OX_0A;
  if odds(3,1) ~= 1
    kapAa = yEX; kapAc = 1 - kapAa;
    B = n_OX_0A - kapAc - (n_OX_0A + kapAa) * odds(3,1); 
    C = 4 * (1 - odds(3,1)) * odds(3,1) * n_OX_0A * kapAa;
    n_OX_0Aa = 2 * n_OX_0A * odds(1,1)/ (sqrt(B * B + C) - B);
    n_OX_0Ac = (n_OX_0A - n_OX_0Aa * kapAa)/ kapAc;
    %% n_OX_0A = (kapAa * n_OX_0Aa + kapAc * n_OX_0Ac);
  end
  n_NX_0A = n_O(4,1) * del_NX; n_NX_0Aa =n_NX_0A; n_NX_0Ac =n_NX_0A;
  if odds(4,1) ~= 1
    kapAa = yEX; kapAc = 1 - kapAa;
    B = n_NX_0A - kapAc - (n_NX_0A + kapAa) * odds(4,1); 
    C = 4 * (1 - odds(4,1)) * odds(4,1) * n_NX_0A * kapAa;
    n_NX_0Aa = 2 * n_NX_0A * odds(4,1)/ (sqrt(B * B + C) - B);
    n_NX_0Ac = (n_NX_0A - n_NX_0Aa * kapAa)/ kapAc;
    %% n_NX_0A = (kapAa * n_NX_0Aa + kapAc * n_NX_0Ac);
  end
  % anabolic dissip substr (E,V,O)
  n_CE_0D = n_O(1,3) * del_CE; n_CE_0Da = n_CE_0D; n_CE_0Dc = n_CE_0D;
  if odds(1,2) ~= 1
    kapDa = kapD; kapDc = 1 - kapDa;
    B = n_CE_0D - kapDc - (n_CE_0D + kapDa) * odds(1,2); 
    C = 4 * (1 - odds(1,2)) * odds(1,2) * n_CE_0D * kapDa;
    n_CE_0Da = 2 * n_CE_0D * odds(1,2)/ (sqrt(B * B + C) - B);
    n_CE_0Dc = (n_CE_0D - n_CE_0Da * kapDa)/ kapDc;
    %% n_CE_0D = (kapDa * n_CE_0Da + kapDc * n_CE_0Dc);
  end
  n_CV_0D_s = n_O(1,2) * del_CV;
  n_CV_0Da_s = n_CV_0D_s; n_CV_0Dc_s = n_CV_0D_s;
  % n_CV_OD refers to V as product, n_CV_OD_s as substrate
  if odds(1,3) ~= 1
    kapDa = kapD; kapDc = 1 - kapDa;
    B = n_CV_0D_s - kapDc - (n_CV_0D_s + kapDa) * odds(1,3); 
    C = 4 * (1 - odds(1,3)) * odds(1,3) * n_CV_0D_s * kapDa;
    n_CV_0Da_s = 2 * n_CV_0D_s * odds(1,3)/ (sqrt(B * B + C) - B);
    n_CV_0Dc_s = (n_CV_0D_s - n_CV_0Da_s * kapDa)/ kapDc;
    % n_CV_0D_s = (kapDa * n_CV_0Da_s + kapDc * n_CV_0Dc_s);
  end
  n_HE_0D = n_O(2,3) * del_HE; n_HE_0Da = n_HE_0D; n_HE_0Dc = n_HE_0D;
  if odds(2,2) ~= 1
    kapDa = kapD; kapDc = 1 - kapDa;
    B = n_HE_0D - kapDc - (n_HE_0D + kapDa) * odds(2,2); 
    C = 4 * (1 - odds(2,2)) * odds(2,2) * n_HE_0D * kapDa;
    n_HE_0Da = 2 * n_HE_0D * odds(2,2)/ (sqrt(B * B + C) - B);
    n_HE_0Dc = (n_HE_0D - n_HE_0Da * kapDa)/ kapDc;
    %% n_HE_0D = (kapDa * n_HE_0Da + kapDc * n_HE_0Dc);
  end
  n_HV_0D_s = n_O(2,2) * del_HV;
  n_HV_0Da_s = n_HV_0D_s; n_HV_0Dc_s = n_HV_0D_s;
  if odds(2,3) ~= 1
    kapDa = kapD; kapDc = 1 - kapDa;
    B = n_HV_0D - kapDc - (n_HV_0D + kapDa) * odds(2,3); 
    C = 4 * (1 - odds(2,3)) * odds(2,3) * n_HV_0D * kapDa;
    n_HV_0Da_s = 2 * n_CE_0D * odds(2,3)/ (sqrt(B * B + C) - B);
    n_HV_0Dc_s = (n_HV_0D_s - n_HV_0Da_s * kapDa)/ kapDc;
    %% n_HV_0D_s = (kapDa * n_HV_0Da_s + kapDc * n_HV_0Dc_s);
  end
  n_OO_0D = n_OO_0A;
  n_OE_0D = n_O(3,3) * del_OE; n_OE_0Da = n_OE_0D; n_OE_0Dc = n_OE_0D;
  if odds(3,2) ~= 1
    kapDa = kapD; kapDc = 1 - kapDa;
    B = n_OE_0D - kapDc - (n_OE_0D + kapDa) * odds(3,2); 
    C = 4 * (1 - odds(3,2)) * odds(3,2) * n_OE_0D * kapDa;
    n_OE_0Da = 2 * n_CE_0D * odds(3,2)/ (sqrt(B * B + C) - B);
    n_OE_0Dc = (n_OE_0D - n_OE_0Da * kapDa)/ kapDc;
    %% n_OE_0D = (kapDa * n_OE_0Da + kapDc * n_OE_0Dc);
  end
  n_OV_0D_s = n_O(3,2) * del_OV;
  n_OV_0Da_s = n_OV_0D_s; n_OV_0Dc_s = n_OV_0D_s;
  if odds(3,3) ~= 1
    kapDa = kapD; kapDc = 1 - kapDa;
    B = n_OV_0D - kapDc - (n_HV_0D + kapDa) * odds(3,3); 
    C = 4 * (1 - odds(3,3)) * odds(3,3) * n_OV_0D * kapDa;
    n_OV_0Da_s = 2 * n_OE_0D * odds(3,3)/ (sqrt(B * B + C) - B);
    n_OV_0Dc_s = (n_OV_0D_s - n_OV_0Da_s * kapDa)/ kapDc;
    %% n_OV_0D_s = (kapDa * n_HV_0Da_s + kapDc * n_HV_0Dc_s);
  end
  n_NE_0D = n_O(4,3) * del_NE; n_NE_0Da = n_NE_0D; n_NE_0Dc = n_NE_0D;
  if odds(4,2) ~= 1
    kapDa = kapD; kapDc = 1 - kapDa;
    B = n_NE_0D - kapDc - (n_NE_0D + kapDa) * odds(4,2); 
    C = 4 * (1 - odds(4,2)) * odds(4,2) * n_NE_0D * kapDa;
    n_NE_0Da = 2 * n_NE_0D * odds(4,2)/ (sqrt(B * B + C) - B);
    n_NE_0Dc = (n_NE_0D - n_NE_0Da * kapDa)/ kapDc;
    % n_NE_0D = (kapDa * n_NE_0Da + kapDc * n_OE_0Dc);
  end
  n_NV_0D_s = n_O(4,2) * del_NV;
  n_NV_0Da_s = n_NV_0D_s; n_NV_0Dc_s = n_NV_0D_s;
  if odds(4,3) ~= 1
    kapDa = kapD; kapDc = 1 - kapDa;
    B = n_NV_0D - kapDc - (n_NV_0D + kapDa) * odds(4,3); 
    C = 4 * (1 - odds(4,3)) * odds(4,3) * n_NV_0D * kapDa;
    n_NV_0Da_s = 2 * n_NV_0D * odds(4,3)/ (sqrt(B * B + C) - B);
    n_NV_0Dc_s = (n_NV_0D_s - n_NV_0Da_s * kapDa)/ kapDc;
    % n_NV_0D_s = (kapDa * n_NV_0Da_s + kapDc * n_NV_0Dc_s);
  end
  % anabolic growth substr (E,O)
  n_CE_0G = n_CE_0D; n_CE_0Ga = n_CE_0G; n_CE_0Gc = n_CE_0G;
  if odds(1,4) ~= 1
    kapGa = yVE; kapGc = 1 - kapGa;
    B = n_CE_0G - kapGc - (n_CE_0G + kapGa) * odds(1,4); 
    C = 4 * (1 - odds(1,4)) * odds(1,4) * n_CE_0G * kapGa;
    n_CE_0Ga = 2 * n_CE_0G * odds(1,4)/ (sqrt(B * B + C) - B);
    n_CE_0Gc = (n_CE_0G - n_CE_0Ga * kapGa)/ kapGc;
    % n_CE_0G = (kapGa * n_CE_0Ga + kapGc * n_CE_0Gc);
  end
  n_HE_0G = n_HE_0D; n_HE_0Ga = n_HE_0G; n_HE_0Gc = n_HE_0G;
  if odds(2,4) ~= 1
    kapGa = yVE; kapGc = 1 - kapGa;
    B = n_HE_0G - kapGc - (n_HE_0G + kapGa) * odds(2,4); 
    C = 4 * (1 - odds(2,4)) * odds(2,4) * n_HE_0G * kapGa;
    n_HE_0Ga = 2 * n_HE_0G * odds(2,4)/ (sqrt(B * B + C) - B);
    n_HE_0Gc = (n_HE_0G - n_HE_0Ga * kapGa)/ kapGc;
    % n_HE_0G = (kapGa * n_HE_0Ga + kapGc * n_HE_0Gc);
  end
  n_OO_0G =  n_OO_0A;
  n_OE_0G = n_OE_0D; n_OE_0Ga = n_OE_0G; n_OE_0Gc = n_OE_0G;
  if odds(3,4) ~= 1
    kapGa = yVE; kapGc = 1 - kapGa;
    B = n_OE_0G - kapGc - (n_OE_0G + kapGa) * odds(3,4); 
    C = 4 * (1 - odds(3,4)) * odds(3,4) * n_OE_0G * kapGa;
    n_OE_0Ga = 2 * n_OE_0G * odds(3,4)/ (sqrt(B * B + C) - B);
    n_OE_0Gc = (n_OE_0G - n_OE_0Ga * kapGa)/ kapGc;
    % n_OE_0G = (kapGa * n_OE_0Ga + kapGc * n_OE_0Gc);
  end
  n_NE_0G = n_NE_0D; n_NE_0Ga = n_NE_0G; n_NE_0Gc = n_NE_0G;
  if odds(4,4) ~= 1
    kapGa = yVE; kapGc = 1 - kapGa;
    B = n_NE_0G - kapGc - (n_NE_0G + kapGa) * odds(4,4); 
    C = 4 * (1 - odds(4,4)) * odds(4,4) * n_nE_0G * kapGa;
    n_NE_0Ga = 2 * n_NE_0G * odds(4,4)/ (sqrt(B * B + C) - B);
    n_NE_0Gc = (n_NE_0G - n_NE_0Ga * kapGa)/ kapGc;
    % n_NE_0G = (kapGa * n_NE_0Ga + kapGc * n_NE_0Gc);
  end

  % coefficients n_ip_0k %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %   n = chem index, i = element, p = product, 0 = isotope, k = process
  % assim aA: rows prod E P C H N; cols: substr (X,O) for elements *
  % evaluation for prod E only
  if J_EA > 0
    n_CE_0A = - (aA(1,1) * n_CX_0Aa * J_XA)/ J_EA;
    n_HE_0A = - (aA(1,3) * n_HX_0Aa * J_XA)/ J_EA;
    n_OE_0A = - (aA(1,5) * n_OX_0Aa * J_XA + aA(1,6) * n_OO_0A * J_OA)/ J_EA;
    n_NE_0A = - (aA(1,7) * n_NX_0Aa * J_XA)/ J_EA;
  else
    n_CE_0A = 0; n_HE_0A = 0; n_OE_0A = 0; n_NE_0A = 0;
  end
  % dissip aD: rows prod V C H N; cols: substr (E,V,O) for elements *
  % evaluation for prod V only; notice that J_VD < 0
  n_CV_0D = (aD(1,1) * n_CE_0Da * J_ED + aD(1,2) * n_CV_0Da_s * J_VD)/ J_VD;
  n_HV_0D = (aD(1,4) * n_HE_0Da * J_ED + aD(1,5) * n_HV_0Da_s * J_VD)/ J_VD;
  n_OV_0D = (aD(1,7) * n_OE_0Da * J_ED + aD(1,8) * n_OV_0Da_s * J_VD + ...
             aD(1,9) * n_OO_0D * J_OD)/ J_VD;
  n_NV_0D = (aD(1,10) * n_NE_0Da * J_ED + aD(1,11) * n_NV_0Da_s * J_VD)/ J_VD;
  % growth aG: rows prod V C H N; cols: substr (E,O) for elements *
  % evaluation for prod V only
  n_CV_0G = - (aG(1,1) * n_CE_0Ga * J_EG)/ J_VG;
  n_HV_0G = - (aG(1,3) * n_HE_0Ga * J_EG)/ J_VG;
  n_OV_0G = - (aG(1,5) * n_OE_0Ga * J_EG + aG(1,6) * n_OO_0G * J_OG)/ J_VG;
  n_NV_0G = - (aG(1,7) * n_NE_0Ga * J_EG)/ J_VG;

  % changes in state
  dM_E = J_EA + J_EC;
  dM_V = J_VG + J_VDs;
  dM_H = - (M_H < MHp) * J_ER;
  dM_OD = - yOE_D * J_ED * max(0, 1 - delS * M_O/ M_V); % otolith-dissip
  dM_OG = - yOE_G * J_EG * max(0, 1 - delS * M_O/ M_V); % otolith-growth
  
  ddel_CE = (n_CE_0A/ n_O(1,3) - del_CE) * J_EA/ M_E;
  ddel_HE = (n_HE_0A/ n_O(2,3) - del_HE) * J_EA/ M_E;
  ddel_OE = (n_OE_0A/ n_O(3,3) - del_OE) * J_EA/ M_E;
  ddel_NE = (n_NE_0A/ n_O(4,3) - del_NE) * J_EA/ M_E;

  % for J_VD < 0 
  ddel_CV = (n_CV_0G/ n_O(1,2) - del_CV) * J_VG/ M_V - ...
      (n_CV_0D/ n_O(1,2) - del_CV) * J_VD/ M_V;
  ddel_HV = (n_HV_0G/ n_O(2,2) - del_HV) * J_VG/ M_V - ...
        (n_HV_0D/ n_O(2,2) - del_HV) * J_VD/ M_V;
  ddel_OV = (n_OV_0G/ n_O(3,2) - del_OV) * J_VG/ M_V - ...
        (n_OV_0D/ n_O(3,2) - del_OV) * J_VD/ M_V;
  ddel_NV = (n_NV_0G/ n_O(4,2) - del_NV) * J_VG/ M_V - ...
        (n_NV_0D/ n_O(4,2) - del_NV) * J_VD/ M_V;
  
  % pack output
  dMd = [dM_E; dM_V; dM_H; dM_OD; dM_OG
	 ddel_CE; ddel_HE; ddel_OE; ddel_NE;
         ddel_CV; ddel_HV; ddel_OV; ddel_NV];
