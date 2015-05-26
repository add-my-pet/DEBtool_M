function shcnplim(p, time, NP, OD, s)
  %  created 2002/02/11 by Bas Kooijman
  % 
  %% Description
  %  plots algal biomass development in a batch reactor under C,N,P-limitation
  %  calls cnplim, dcnplim
  %
  %% Inputs
  %  P: 21-vector of parameter values (see cnplim)
  %  time: (nt)-vector of time-points
  %  NP:(nNP,2)-matrix with initial N and P concentrations
  %  OD:(nt,nNP)-matrix with Optical Densities
  %  s: vector with data-sets that are shown
  %
  %% Outputs
  %  Plots
  %
  %% Remarks
  %  calls cnplim, dcnplim
  
  global K_C K_N K_P j_Cm j_Nm j_Pm k_E yC_EV yN_EV yP_EV k_BC k_CB;
  global kap_C kap_N kap_P;
  %  state vector X = (1)B (2)C (3)N (4)P (5)m_C (6)m_N (7)m_P (8)X

  p = p(:,1);
  
  %% unpack p
  K_C=p(1); K_N=p(2);   K_P=p(3);   j_Cm=p(4);   j_Nm=p(5); j_Pm=p(6);
  k_E=p(7); kap_C=p(8); kap_N=p(9); kap_P=p(10);
  yC_EV=p(11); yN_EV=p(12); yP_EV=p(13); k_BC=p(14); k_CB=p(15);
  B_0=p(16); C_0=p(17); m_C0=p(18); m_N0=p(19); m_P0=p(20); biomm0=p(21);
 
  m_C0=j_Cm/k_E; m_N0=j_Nm/k_E; m_P0=j_Pm/k_E; 

  clf; hold on;

  [nt,nNP] = size OD;
  
  if prod(size(s)) == 0
    s = 1:nNP;
  end
  
  [r k] = size(s);
  for i = 1:k
    t = linspace(0,1.1*t(nt),100);
    Xt0 = [B_0 C_0 NP(s(i),1) NP(s(i),2)) m_C0 m_N0 m_P0 biomm0];
    Xt = ode23s ('dcnplim', t, Xt0); % integrate ode's
    plot(t, Xt(:,8), 'g'); % model predictions
    plot(time, OD(:,(s(i)), 'b+'); % data points
    Xt = ode23s ('dcnplim', time, Xt0);
    for j=1:nt % vertical lines
      plot(time(j)*ones(2,1),[OD(j,(s(i)) Xt(j,8)],'m');
    end
  end
  xlabel('time, h'); ylabel('absorbance at 690 nm');