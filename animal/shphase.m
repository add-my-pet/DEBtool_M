%% shphase
% Phase diagrams for reserve and structure

%%
function shphase
  
  %% Description
  % Runs <shphase_memv.html *shphase_memv*> and <shphase_el.html *shphase_el*> 
  % to compare phase diagrams expressed in mass and scaled variables.

  subplot(1,2,1)
  shphase_memv(1,3)

  subplot(1,2,2)
  shphase_el(1,1)
