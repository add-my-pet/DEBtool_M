function shthrou2graz (j)
  %% created 2000/10/18 by Bas Kooijman
  %% called from 'symbi' to show throughput/grazing profiles
  %%  in symbiosis
  %% State vector:
  %%   X_t = [X; X_N; X_CH; X_VA; m_EC; m_EN; X_VH; m_E]
  %%   X: substrate        X_N: nitrogen      X_CH: carbo-hydrate
  %%   X_VA: struc autotr  m_EC: C-res dens   m_EN: N-res density
  %%   X_VH: struc hetero  m_E: res density

  global X_R X_RN

  X_t = [X_R X_RN 0 1 1 1 1 1];
  [hb_VA, h_v, b_VAv] = ...
     varpar2 ('dx', X_t, 'h', 0.05, 0.025, 10, 'b_VA', 1e-5, .0005, 10);
   
  rotate3d on
  clf
   
  if exist('j')==1 % single plot mode
    switch j
 
      case 1
        mesh (h_v, b_VAv, hb_VA(:,:,4));
        xlabel('throughput'); ylabel('grazing'); zlabel('X_{VA}');
        view(30,5);

      case 2
        mesh (h_v, b_VAv, hb_VA(:,:,7));
        xlabel('throughput'); ylabel('grazing'); zlabel('X_{VH}');
        view(30,5);

      case 3
        mesh (h_v, b_VAv, hb_VA(:,:,4) ./ hb_VA(:,:,7));
        xlabel('throughput'); ylabel('grazing'); zlabel('X_{VA}/X_{VH}');
        view(30,5);

      otherwise
        return	
    end
  else % multiple plot mode
    %% top_title('Equilibria of auto -and heterotrophs and their ratio')

    subplot (1, 3, 1);
    mesh (h_v, b_VAv, hb_VA(:,:,4));
    xlabel('throughput'); ylabel('grazing'); zlabel('X_{VA}');
    view(30,5);

    subplot (1, 3, 2);
    mesh (h_v, b_VAv, hb_VA(:,:,7));
    xlabel('throughput'); ylabel('grazing'); zlabel('X_{VH}');
    view(30,5);

    subplot (1, 3, 3);
    mesh (h_v, b_VAv, hb_VA(:,:,4) ./ hb_VA(:,:,7));
    xlabel('throughput'); ylabel('grazing'); zlabel('X_{VA}/X_{VH}');
    view(30,5);
  end

