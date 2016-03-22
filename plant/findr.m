%% findr
% subfunction to find specific growth rate

%%
function f = findr (r)
  % created: 2000/09/26 by Bas Kooijman
  
  %% Syntax
  % f = <../findr.m *findr*> (r) 

  %% Description
  % Subfunction to find specific growth rate
  %
  % Input:
  %
  % * r: scalar with guess for specific growth rate
  %
  % Output:
  %
  % * f: scalar that has value 0 if r is the correct specific growth rate
  
  %% Remarks:
  % Routine called from 'flux' for 'plant' to obtain specific growth rates.
  % Requires:
  %  par1 = [y_CH_E?_NO, y_V?_E?, y_EN?_E?, kap_S?, k_E?, k_EC?, k_EN?, j_E?_M?];
  %  par2 = [A_?, m_EC?, m_EN?, m_E?]; ? can be S or R, for shoot or root
  
  global par1 par2;
  
  a = par2(2)*(par2(1)*par1(6) - r)/par1(1);
  % spec mobilisation from reserve EC in terms of E
  b = par2(3)*(par2(1)*par1(7) - r)/par1(3);
  % spec mobilisation from reserve EN in terms of E
  d = 1/(1/a + 1/b - 1/(a + b));
  % stoichiometrically merged spec flux from reserves EC and EN in terms of E
  c =         par2(4)*(par2(1)*par1(5) - r); % spec flux from reserve E

  f = par1(2)*(par1(4)*(c + d) - par1(8)) - r;
  % par1(4)*(c+d) is spec E-flux allocated to growth + som maint
