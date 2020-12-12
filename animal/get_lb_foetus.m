%% get_lb_foetus
% Obtains scaled length at birth in case of foetal development

%%
function [lb, tb, info] = get_lb_foetus(p, tb0)
  %  created 2007/07/28 by Bas Kooijman; modified 2011/04/07, 2015/01/18
  
  %% Syntax
  % [lb, tb, info] = <../get_lb_foetus.m *get_lb_foetus*>(p, tb0)
  
  %% Description
  % Obtains scaled length at birth in case of foetal development via scaled age at birth.
  % This scaled age is only computed if input p has length 3
  % Development is not restricted by reserve availability. 
  %
  % Input
  %
  % * p: p: 1-vector with g if tb is specified else 3-vector with g, k, v_H^b, see get_tb_foetus
  % * tb0: optional scalar with scaled age at birth 
  %  
  % Output
  %
  % * lb: scaler with scaled length at birth
  % * tb: scalar with scaled age at birth
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % The theory behind get_lb, get_tb and get_ue0 is discussed in 
  %    <http://www.bio.vu.nl/thb/research/bib/Kooy2009b.html Kooy2009b>.
  
  %% Example of use
  % See <../mydata_ue0.m *mydata_ue0*>
  
  info = 1;
  if ~exist('tb0', 'var')
    if length(p) < 3
      fprintf('Warning from get_lb_foetus: not enough input parameters, see get_tb_foetus \n');
      lb = []; tb = []; info = 0; return;
    end

    [tb, lb] = get_tb_foetus(p); % get scaled age and length at birth
    info = 1;
  else
    tb = tb0; lb = [];
  end

