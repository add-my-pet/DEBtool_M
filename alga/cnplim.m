%% cnplim
% simultaneous C, N, P limitation in a batch-culture

%%
function f = cnplim(p, t, NP)
  %  created 2002/02/11 by Bas Kooijman
  
  %% Syntax
  % f = <../cnplim.m *cnplim*> (p, t, NP)

  %% Description
  % Simultaneous C, N, P limitation in a batch-culture
  %     C is consumed as CO2 only, while CO2 exchanges with HCO3
  %     maintenance costs are assummed to be negligibly small.
  %
  % Input:
  %
  % * p: parameter vector:
  %
  %     p(1)=K_C; mM, saturation constant for CO2 (C)
  %     p(2)=K_N; mM, saturation constant for nitrate (N)
  %     p(3)=K_P; mM, saturation constant for phosphate (P)
  %     p(4)=j_Cm; mM/(mol*h), max spec CO2 uptake rate
  %     p(5)=j_Nm; mM/(mol*h), max spec N 
  %     p(6)=j_Pm; mM/(mol*h), max spec P
  %     p(7)=k_E; 1/h, reserve turnover rate
  %     p(8)= kap_C; -, recovery fraction for rejected C-reserves
  %     p(9)= kap_N; -, recovery fraction for rejected N-reserves
  %     p(10)=kap_P; -, recovery fraction for rejected P-reserves
  %     p(11)=yC_EV; mol/mol, yield for C-reserve on structure
  %     p(12)=yN_EV; mol/mol, yield for N-reserve on structure
  %     p(13)=yP_EV; mol/mol, yield for P-reserve on structure
  %     p(14)=k_BC; 1/h, transformation from B (bicarbonate) to C
  %     p(15)=k_CB; 1/h, transformation from C (CO2) to B
  %     p(16)=B_0; mM, initial bicarbonate concentration
  %     p(17)=C_0; mM, initial CO2 concentration
  %     p(18)=m_C0; mol/mol, initial C-reserve density
  %     p(19)=m_N0; mol/mol, initial N-reserve density
  %     p(20)=m_P0; mol/mol, initial P-reserve density
  %     p(21)=Biomm0; mM, initial structure concentration
  %
  % * t: (nt)-vector with time
  % * NP: (NP,2)-matrix with initial nitrate, phosphate concentrations
  %
  % Output:
  %
  % % f: biomass
  
  %% Remarks
  % Calls for dcnplim; see mydata_cnplim for an application.
  % Apply this function with nmregr2 for parameter estimation,
  %     or pregr2 for parameter statistics, or shregr2 for plotting

  %  State vector:
  %  Xt: C = Xt(1);  N = Xt(2);  P = Xt(3); m_C = Xt(4); m_N = Xt(5);
  %      m_P = Xt(6); X = Xt(7); B = Xt(8);

  global K_C K_N K_P j_Cm j_Nm j_Pm k_E yC_EV yN_EV yP_EV k_BC k_CB
  global kap_C kap_N kap_P
 
  % global B C N P m_C m_N m_P X B r;

  % unpack p
  K_C = p(1); K_N = p(2); K_P = p(3); j_Cm = p(4); j_Nm = p(5); j_Pm = p(6);
  k_E = p(7); kap_C = p(8); kap_N = p(9); kap_P = p(10);
  yC_EV = p(11); yN_EV = p(12); yP_EV = p(13); k_BC = p(14); k_CB = p(15);
  B_0 = p(16); C_0 = p(17); m_C0 = p(18); m_N0 = p(19); m_P0 = p(20); Biomm0 = p(21);
  
  m_C0 = j_Cm/k_E; m_N0 = j_Nm/k_E; m_P0 = j_Pm/k_E;

  [nNP k] = size(NP);
  
  for i = 1:nNP
    Xt0 = [B_0 C_0 NP(i,1) NP(i,2) m_C0 m_N0 m_P0 Biomm0];
    Xt = ode23s ('dcnplim', t, Xt0);
    f(:,i)=Xt(:,8);
  end