function shbatch (j)
  %% created 2000/10/17 by Bas Kooijman; modified 2009/09/29
  %% calculates substrate/product profiles in a batch reactor
  %% X(:,1)= X_A, X(:,2)= X_B, X(:,3)=X_C
  %% X_C0 = 0;

  X_A0 = 3; X_B0 = 2; % initial conditions for substrates A and B
  
    if exist('j','var') == 1 ; % single plot mode
    clf;
     
    switch j

      case 1
        [X, t] = batch('su11', X_A0, X_B0);
        plot(t, X(:,1), 'r', t, X(:,2), 'b', t, X(:,3), 'k');
        title('profiles in batch reactor for 1,1-SU');
        ylabel('compound, M');
        xlabel('time, h');

      case 2
        [X, t] = batch('enz11', X_A0, X_B0);
        plot(t, X(:,1), 'r', t, X(:,2), 'b', t, X(:,3), 'k');
        title('profiles in batch reactor for 1,1-enzyme');
        ylabel('compound, M');
        xlabel('time, h');

      case 3
        [X, t] = batch('ru11', X_A0, X_B0);
        plot(t, X(:,1), 'r', t, X(:,2), 'b', t, X(:,3), 'k');
        title('profiles in batch reactor for 1,1-RU');
        ylabel('compound, M');
        xlabel('time, h');

      otherwise
        return;
    end
   
  else % multiplot mode
    
    subplot(1,3,1);
    [X, t] = batch('su11', X_A0, X_B0);
    plot(t, X(:,1), 'r', t, X(:,2), 'b', t, X(:,3), 'k');
    title('profiles in batch reactor for 1,1-SU');
    ylabel('compound, M');
    xlabel('time, h');

    subplot(1,3,2);
    [X, t] = batch('enz11', X_A0, X_B0);
    plot(t, X(:,1), 'r', t, X(:,2), 'b', t, X(:,3), 'k');
    title('profiles in batch reactor for 1,1-enzyme');
    ylabel('compound, M');
    xlabel('time, h');

    subplot(1,3,3);
    [X, t] = batch('ru11', X_A0, X_B0);
    plot(t, X(:,1), 'r', t, X(:,2), 'b', t, X(:,3), 'k');
    title('profiles in batch reactor for 1,1-RU');
    ylabel('compound, M');
    xlabel('time, h');

  end
 
  
