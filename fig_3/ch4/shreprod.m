function sh_reprod(p, varargin)
  
    subplot(1,2,1)
     %% gset parametric
     %% gset ticslevel 0
     %% gset view 60, 310, 1, 1
     hold on
     title('eggs as function of f and L')
     for i= 2:n:nargin
       if data(i,1) > er(i)
         gsplot ([data(i, [2 3 1]), data(i, [2 3]), er(i)]) with line 1;
         gsplot (data(i, [2 3 1])) with points 2;
       else
        gsplot ([data(i, [2 3 1]), data(i, [2 3]), er(i)]) with line 2;
        gsplot (data(i, [2 3 1])) with points 12;
       endif
       gsplot ([data(i, [2 3]), min(data(i,1),er(i)), data(i, [2 3]), 0])\
       with line 3;
       end

      subplot(1,2,2)
      plot(d3_19(:,6),egg_vol(d3_19(:,[4 5])),"*r")
      xlabel('number of eggs')
      ylabel('volume of eggs')

end
