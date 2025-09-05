%% get_axis
% Gets axis through a set of (x,y)-values

%%
function [XYmean, slope, Yrange] = get_axis(XY, Xrange)
  % created 2025/08/12 by Bas Kooijman
  
  %% Syntax
  % [XYmean, slope, Yrange] = <../get_axis.m *get_axis*> (XY, Xrange)
  
  %% Description
  % Get axis through a set of XY-values
  %
  % Input
  %
  % * XY: (n,2)-matrix of XY values
  % * Xrange: optional (2,1)-matrix with range of X-values
  %  
  % Output
  %
  % * XYmean: (1,2)-matrix of means of X,Y
  % * slope: scalar with slope of axis through XY-values
  % * Yrange: (2,1)-matrix of Y-values; empty if Xrange is not specified  
  %
  %% example of use
  % XY = [1 3; 2 4.5; 3 5]; Xrange = [.5;3.5]; [~, ~, Yrange] = get_axis(XY, Xrange); plot(XY(:,1),XY(:,2),'ob',Xrange,Yrange,'k') 
  
  XYmean = mean(XY,1);
  [e_XY, d_XY] = eig(cov(XY)); slope = e_XY(2,2)./e_XY(1,2); 
 
  if ~exist('Xrange','var') 
    Yrange =  [];
  else
    Yrange = [XYmean(2)-slope*(XYmean(1)-Xrange(1)); 
              XYmean(2)-slope*(XYmean(1)-Xrange(2))];
  end
  

end