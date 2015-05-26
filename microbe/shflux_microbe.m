function shflux_microbe (j)
  %% created 2000/10/20 by Bas Kooijman, modified 2009/08/01
  %% calculates normalized fluxes at different growth rates
  %%   this results in yield coefficients (per substrate or structure)
  %%   J_*/J_X = Y_*,X and J_*/J_V = Y_*,V 
  %%   and specific prod/consumption rates J_*/W = q_*  

  global kT_E hT_a g kT_M K;
  
  X_r = K*1e8;
  h_m = (kT_E - hT_a*(1 + g) - g*kT_M*(1 + K/X_r))/(1 + g*(1 + K/X_r));

  n_h = 100; h  = linspace(1e-3, h_m, n_h)';  % 1/d, throughput rates
  [Xh, ph, J_O, J_M] = chemostat (h, K*1e8);       % get fluxes
  W = Xh(:,7) + Xh(:,8); % single out weight
  p_T = ph(:,1); % single out dissipating heat
  
  clf;
  if exist('j')==1 % single-plot mode
    
    switch j
      case 1
        plot(h, J_O(:,2)./J_O(:,1), 'g', h, J_O(:,3)./J_O(:,1), 'r', ...
	        h, J_O(:,4)./J_O(:,1), 'k');
        title ('structure, reserve, & product');
        xlabel('spec growth rate, 1/d'); 
        ylabel('Y_{VX}, Y_{EX}, Y_{PX}, mol/mol');

      case 2
        plot(h, J_M(:,1)./J_O(:,1),'k', h, J_M(:,2)./J_O(:,1), 'b');
        title ('carbon dioxide, water');
        xlabel('spec growth rate, 1/d'); 
        ylabel('Y_{CX}, Y_{HX}, mol/mol');

      case 3
        plot(h, J_M(:,3)./J_O(:,1),'k', h, J_M(:,4)./J_O(:,1), 'b');
        title ('dioxygen, ammonia');
        xlabel('spec growth rate, 1/d'); 
        ylabel('Y_{OX}, Y_{NX}, mol/mol');

      case 4
        plot(h, p_T./J_O(:,1),'r');
        title ('dissipating heat');
        xlabel('spec growth rate, 1/d'); 
        ylabel('Y_{TX}, kJ/mol');

      case 5
        plot(h, J_O(:,1)./J_O(:,2), 'g', h, J_O(:,3)./J_O(:,2), 'r', ...
	        h, J_O(:,4)./J_O(:,2), 'k');
        title ('substrate, reserve, & product');
        xlabel('spec growth rate, 1/d'); 
        ylabel('Y_{XV}, Y_{EV}, Y_{PV}, mol/mol');

      case 6
        plot(h, J_M(:,1)./J_O(:,2),'k', h, J_M(:,2)./J_O(:,2), 'b');
        title ('carbon dioxide, water');
        xlabel('spec growth rate, 1/d'); 
        ylabel('Y_{CV}, Y_{HV}, mol/mol');

      case 7
        plot(h, J_M(:,3)./J_O(:,2),'r', h, J_M(:,4)./J_O(:,2), 'b');
        title ('dioxygen, ammonia');
        xlabel('spec growth rate, 1/d'); 
        ylabel('Y_{OV}, Y_{NV}, mol/mol');

      case 8
        plot(h, p_T./J_O(:,2),'r');
        title ('dissipating heat');
        xlabel('spec growth rate, 1/d'); 
        ylabel('Y_{TV}, kJ/mol');
        
      case 9
        plot(h, J_O(:,1)./W, 'g', h, J_O(:,3)./W, 'r', ...
	        h, J_O(:,4)./W, 'k');
        title ('substrate, reserve, & product');
        xlabel('spec growth rate, 1/d'); 
        ylabel('q_X, q_E, q_P, mol/d.g');

      case 10
        plot(h, J_M(:,1)./W,'k', h, J_M(:,2)./W, 'b');
        title ('carbon dioxide, water');
        xlabel('spec growth rate, 1/d'); 
        ylabel('q_C, q_H, mol/d.g');

      case 11
        plot(h, J_M(:,3)./W,'r', h, J_M(:,4)./W, 'b');
        title ('oxygen, ammonia');
        xlabel('spec growth rate, 1/d'); 
        ylabel('q_O, q_N, mol/d.g');

      case 12
        % plot(h, p_T./W,'r');
        plot (h, W, 'b');
        title ('dissipating heat');
        xlabel('spec growth rate, 1/d'); 
        ylabel('q_T, kJ/d.g');

      otherwise
	      return;
	
    end
    
  else % multi-plot mode
 
    subplot(3,4,1);
        plot(h, J_O(:,2)./J_O(:,1), 'g', h, J_O(:,3)./J_O(:,1), 'r', ...
	        h, J_O(:,4)./J_O(:,1), 'k');
        title ('structure, reserve, & product');
        xlabel('spec growth rate, 1/d'); 
        ylabel('Y_{VX}, Y_{EX}, Y_{PX}, mol/mol');

    subplot(3,4,2);
        plot(h, J_M(:,1)./J_O(:,1),'k', h, J_M(:,2)./J_O(:,1), 'b');
        title ('carbon dioxide, water');
        xlabel('spec growth rate, 1/d'); 
        ylabel('Y_{CX}, Y_{HX}, mol/mol');

    subplot(3,4,3);
        plot(h, J_M(:,3)./J_O(:,1),'k', h, J_M(:,4)./J_O(:,1), 'b');
        title ('oxygen, ammonia');
        xlabel('spec growth rate, 1/d'); 
        ylabel('Y_{OX}, Y_{NX}, mol/mol');

    subplot(3,4,4);
        plot(h, p_T./J_O(:,1),'r');
        title ('dissipating heat');
        xlabel('spec growth rate, 1/d'); 
        ylabel('Y_{TX}, kJ/mol');

    subplot(3,4,5);
        plot(h, J_O(:,1)./J_O(:,2), 'g', h, J_O(:,3)./J_O(:,2), 'r', ...
	        h, J_O(:,4)./J_O(:,2), 'k');
        title ('substrate, reserve, & product');
        xlabel('spec growth rate, 1/d'); 
        ylabel('Y_{XV}, Y_{EV}, Y_{PV}, mol/mol');

    subplot(3,4,6);
        plot(h, J_M(:,1)./J_O(:,2),'k', h, J_M(:,2)./J_O(:,2), 'b');
        title ('carbon dioxide, water');
        xlabel('spec growth rate, 1/d'); 
        ylabel('Y_{CV}, Y_{HV}, mol/mol');

    subplot(3,4,7);
        plot(h, J_M(:,3)./J_O(:,2),'k', h, J_M(:,4)./J_O(:,2), 'b');
        title ('oxygen, ammonia');
        xlabel('spec growth rate, 1/d'); 
        ylabel('Y_{OV}, Y_{NV}, mol/mol');

    subplot(3,4,8);
        plot(h, p_T./J_O(:,2),'r');
        title ('dissipating heat');
        xlabel('spec growth rate, 1/d'); 
        ylabel('Y_{TV}, kJ/mol');
        
    subplot(3,4,9);
        plot(h, J_O(:,1)./W, 'g', h, J_O(:,3)./W, 'r', ...
	        h, J_O(:,4)./W, 'k');
        title ('substrate, reserve, & product');
        xlabel('spec growth rate, 1/d'); 
        ylabel('q_X, q_E, q_P, mol/d.g');

    subplot(3,4,10);
        plot(h, J_M(:,1)./W,'k', h, J_M(:,2)./W, 'b');
        title ('carbon dioxide, water');
        xlabel('spec growth rate, 1/d'); 
        ylabel('q_C, q_H, mol/d.g');

    subplot(3,4,11);
        plot(h, J_M(:,3)./W,'k', h, J_M(:,4)./W, 'b');
        title ('oxygen, ammonia');
        xlabel('spec growth rate, 1/d'); 
        ylabel('q_O, q_N, mol/d.g');

    subplot(3,4,12);
        plot(h, p_T./W,'r');
        title ('dissipating heat');
        xlabel('spec growth rate, 1/d'); 
        ylabel('q_T, kJ/d.g');
      
 end
  
