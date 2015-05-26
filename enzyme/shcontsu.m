function shcontsu (j)
  %% created 2000/10/17 by Bas Kooijman; modified 2009/09/29
  %% shows contour plot for bi-substrate RU, SU, and enzyme

  X_A = linspace(.0001,10,50)';
  X_B = X_A;
  
  if exist('j','var') == 1 % single plot mode
    switch j
      case 1
      fSU = su11(X_A,X_B);
      contourf(fSU, 10);
      title('1,1-SU');

      case 2
      fenz = enz11(X_A,X_B);
      contourf(fenz, 10);
      title('1,1-enzyme');
    
      case 3
      fRU = ru11(X_A,X_B);
      contourf(fRU, 10);
      title ('1,1-RU');
      
      otherwise
      return
    end
    
  else % multiplot mode
     
    subplot(1,3,1)
    fSU = su11(X_A,X_B);
    contourf(fSU, 10);
    title('1,1-SU');

    subplot(1,3,2)
    fenz = enz11(X_A,X_B);
    contourf(fenz, 10);
    title('1,1-enzyme');
    
    subplot(1,3,3)
    fRU = ru11(X_A,X_B);
    contourf(fRU, 10);
    title ('1,1-RU');
    
   end