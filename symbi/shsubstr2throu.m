function shsubstr2throu (j)
  %% created 2000/10/18 by Bas Kooijman
  %% called from 'symbi' to show substrate/throughput profiles
  %%  in symbiosis
  %% State vector:
  %%   X_t = [X; X_N; X_CH; X_VA; m_EC; m_EN; X_VH; m_E]
  %%   X: substrate        X_N: nitrogen      X_CH: carbo-hydrate
  %%   X_VA: struc autotr  m_EC: C-res dens   m_EN: N-res density
  %%   X_VH: struc hetero  m_E: res density

  global X_R X_RN
  
  X_t = [X_R X_RN 0 1 1 1 1 1];
  [Xh, X_Rv, h_v, info] = ...
     varpar2 ('dx', X_t, 'X_R', 100, 75, 15, 'h', 0.05, 0.075, 15);
 
  if info == 0
    fprintf ('no plots because of lack of convergence \n');
    return
  end
   
  rotate3d on
  clf;

  if exist('j')==1 % single plot mode
    switch j

      case 1
        mesh (X_Rv, h_v, Xh(:,:,4));
        xlabel('substrate'); ylabel('throughput'); zlabel('X_{VA}');
        view(30,5);

      case 2
        mesh (X_Rv, h_v, Xh(:,:,7));
        xlabel('substrate'); ylabel('throughput'); zlabel('X_{VH}');
        view(30,5);

      case 3
        mesh (X_Rv, h_v, Xh(:,:,4) ./ Xh(:,:,7));
        xlabel('substrate'); ylabel('throughput'); zlabel('X_{VA}/X_{VH}');
        view(30,5);

      otherwise
      	return;
    end
    
  else % mulptiple plot mode
    
    %% top_title('Equilibria of auto -and heterotrophs and their ratio')

    subplot (1, 3, 1);
    mesh (X_Rv, h_v, Xh(:,:,4));
    xlabel('substrate'); ylabel('throughput'); zlabel('X_{VA}');
    view(30,5);

    subplot (1, 3, 2);
    mesh (X_Rv, h_v, Xh(:,:,7));
    xlabel('substrate'); ylabel('throughput'); zlabel('X_{VH}');
    view(30,5);

    subplot (1, 3, 3);
    mesh (X_Rv, h_v, Xh(:,:,4) ./ Xh(:,:,7));
    xlabel('substrate'); ylabel('throughput'); zlabel('X_{VA}/X_{VH}');
    view(30,5);

  end
 