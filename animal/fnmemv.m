function dmemv = fnmemv(EV)
  % modified 2009/09/29
  % change in M_E and M_V for isomorph eqn (3.55), (2.56) at {120}
  % called from shphase_memv

  global JT_X_Am y_E_X jT_E_M kap y_E_V m_Em M_Vm M_Vb l_T L_m g f

  % unpack state variables
  M_E = EV(1); M_V = EV(2); m_E = M_E/ M_V;
  l = (M_V/ M_Vm) ^(1/3); E = m_E/ m_Em;

  % J_X_Am = JT_X_Am * L^2; j_X_Am = J_X_Am/ M_V
  j_E_Am = y_E_X * JT_X_Am * (l * L_m)^2/ M_V;
  
  if E < kap * g * l/ (g + (1 - kap) * l + l_T)
    dM_E = 0; dM_V = 0; % death because p_C < p_M
  elseif M_V < M_Vb % embryo  
    dm_E = - j_E_Am * m_E/ m_Em;
    dM_V = M_V * (j_E_Am * (m_E/ m_Em - l_T) - j_E_M/ kap)/ (m_E + y_E_V/ kap);
    dM_E = M_V * dm_E + m_E * dM_V;
  else %juvenile/adult
    dm_E = j_E_Am * (f - m_E/ m_Em);
    dM_V = M_V * (j_E_Am * (m_E/ m_Em - l_T) - jT_E_M/ kap)/ (m_E + y_E_V/ kap);
    dM_E = M_V * dm_E + m_E * dM_V;
  end

  dmemv = [dM_E; dM_V];