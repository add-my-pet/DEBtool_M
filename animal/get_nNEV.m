%% get_nNEV
% Gets chemical indices for nitrogen of reserve and structure, from data for biomass

%%
function n_NEV = get_nNEV (f, n_NW, m_Em)
  % created 2023/05/06 by Bas Kooijman
  
  %% Syntax
  % m_Em, n_NEV] =  = <../get_nNEV.m *get_nNEV*> (f, n_NW, m_Em)
  
  %% Description
  % Gets chemical indices for nitrogen of reserve (E) and structure (V), 
  %   from data for biomass (W) at 2 values for scaled functional response (f).
  %   A graph is produced for varying max reserve capacity m_Em.
  %
  % Input
  %
  % * m_Em: 100-vector with max reserve capacity
  % * n_NW: 2-vector with c_NW
  % * m_Em: optinal scalar or vector with m_Em
  %  
  % Output
  %
  %  n_NEV: (n,2)-array with n_NE and n_EV
  
  %% Remarks
  % Notice that chemical indices should be non-negative, and realistic
  % values for n_NE and n_NV should be less than 0.5
  %
  %% Example of use:
  % get_nNEV ([.2;.8], [.1;.2]); or get_nNEV ([.2;.8], [.1;.2], 2)
  
  if ~exist('m_Em','var')
    n=100; m_Em = linspace(.1,10,n);  
  else
    n = length(m_Em);
  end
  n_NEV = zeros(n,2);
  for i=1:n; n_NEV(i,:)= [f*m_Em(i),[1;1]]\(n_NW.*(1+f*m_Em(i))); end
  
  if ~(n==1)
    close all
    figure
    plot(m_Em,n_NEV(:,1),'b', m_Em,n_NEV(:,2),'r', 'linewidth',2)
    xlabel('max reserve capacity m_{Em}, mol/mol')
    ylabel('\color{blue}{n_{NE}}, \color{red}{n_{NV}}')
    title(['f_0=',num2str(f(1)), ', n_{NW}=',num2str(n_NW(1)), '; f_1=',num2str(f(2)), ', n_{NW}=',num2str(n_NW(2))])  
    ylim([0,inf])
    set(gca, 'FontSize', 15, 'Box', 'on')
  end
end
  