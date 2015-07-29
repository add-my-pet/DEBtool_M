%% addchem
% sets chemical parameters and text for units and labels

%%
function [par, free, units, label] = addchem(par, free, units, label, phylum, class)
  % created by Starrlight Augustine, Dina Lika, Bas Kooijman, Goncalo Marques and Laure Pecquerie 2015/07/23
  % last modified 2015/07/29
  
  %% Syntax
  % [chem, txt_chem] = <../addpar.m *addchem*>(phylum, class)
  
  %% Description
  % sets chemical parameters and text for units and labels
  %
  % Input
  %
  % * phylum to get d_V
  % * class to get d_V
  %  
  % Output
  %
  % * chem : structure with values of chemical parameters
  % * txt_chem: structure with information on chemical parameters
  
  %% Remark
  % Calls get_d_V to set specific density of structure
  % For a specific density of wet mass of 1 g/cm^3,
  %   a specific density of d_E = d_V = 0.1 g/cm^3 means a dry-over-wet weight ratio of 0.1

  
% specific densities
%   set specific densites using the pet's taxonomy
d_V = get_d_V(phylum, class); % see comments on section 3.2.1 of DEB3 
par.d_X = d_V;     free.d_X = 0;  units.d_X = 'g/cm^3'; label.d_X = 'specific density of food'; 
par.d_V = d_V;     free.d_V = 0;  units.d_V = 'g/cm^3'; label.d_V = 'specific density of structure'; 
par.d_E = d_V;     free.d_E = 0;  units.d_E = 'g/cm^3'; label.d_E = 'specific density of reserve'; 
par.d_P = d_V;     free.d_P = 0;  units.d_P = 'g/cm^3'; label.d_P = 'specific density of faeces';

% chemical potentials from Kooy2010 Tab 4.2
par.mu_X = 525000; free.mu_X = 0;  units.mu_X = 'J/ mol'; label.mu_X = 'chemical potential of food'; 
par.mu_V = 500000; free.mu_V = 0;  units.mu_V = 'J/ mol'; label.mu_V = 'chemical potential of structure'; 
par.mu_E = 550000; free.mu_E = 0;  units.mu_E = 'J/ mol'; label.mu_E = 'chemical potential of reserve'; 
par.mu_P = 480000; free.mu_P = 0;  units.mu_P = 'J/ mol'; label.mu_P = 'chemical potential of faeces'; 

% chemical potential of minerals
par.mu_C = 0;      free.mu_C = 0;  units.mu_C = 'J/ mol'; label.mu_C = 'chemical potential of CO2'; 
par.mu_H = 0;      free.mu_H = 0;  units.mu_H = 'J/ mol'; label.mu_H = 'chemical potential of H2O'; 
par.mu_O = 0;      free.mu_O = 0;  units.mu_O = 'J/ mol'; label.mu_O = 'chemical potential of O2'; 
par.mu_N = 0;      free.mu_N = 0;  units.mu_N = 'J/ mol'; label.mu_N = 'chemical potential of NH3'; 

% chemical indices for water-free organics from Kooy2010 Fig 4.15 (excluding contributions of H and O atoms from water)
par.n_CX = 1;      free.n_CX = 0;  units.n_CX = '-'; label.n_CX = 'par. index of carbon in food'; % C/C = 1 by definition
par.n_HX = 1.8;    free.n_HX = 0;  units.n_HX = '-'; label.n_HX = 'par. index of hydrogen in food';
par.n_OX = 0.5;    free.n_OX = 0;  units.n_OX = '-'; label.n_OX = 'par. index of oxygen in food';
par.n_NX = 0.15;   free.n_NX = 0;  units.n_NX = '-'; label.n_NX = 'par. index of nitrogen in food';

par.n_CV = 1;      free.n_CV = 0;  units.n_CV = '-'; label.n_CV = 'par. index of carbon in structure'; % n_CV = 1 by definition
par.n_HV = 1.8;    free.n_HV = 0;  units.n_HV = '-'; label.n_HV = 'par. index of hydrogen in structure';
par.n_OV = 0.5;    free.n_OV = 0;  units.n_OV = '-'; label.n_OV = 'par. index of oxygen in structure';
par.n_NV = 0.15;   free.n_NV = 0;  units.n_NV = '-'; label.n_NV = 'par. index of nitrogen in structure';

par.n_CE = 1;      free.n_CE = 0;  units.n_CE = '-'; label.n_CE = 'par. index of carbon in reserve';   % n_CE = 1 by definition
par.n_HE = 1.8;    free.n_HE = 0;  units.n_HE = '-'; label.n_HE = 'par. index of hydrogen in reserve';
par.n_OE = 0.5;    free.n_OE = 0;  units.n_OE = '-'; label.n_OE = 'par. index of oxygen in reserve';
par.n_NE = 0.15;   free.n_NE = 0;  units.n_NE = '-'; label.n_NE = 'par. index of nitrogen in reserve';

par.n_CP = 1;      free.n_CP = 0;  units.n_CP = '-'; label.n_CP = 'par. index of carbon in faeces';    % n_CP = 1 by definition
par.n_HP = 1.8;    free.n_HP = 0;  units.n_HP = '-'; label.n_HP = 'par. index of hydrogen in faeces';
par.n_OP = 0.5;    free.n_OP = 0;  units.n_OP = '-'; label.n_OP = 'par. index of oxygen in faeces';
par.n_NP = 0.15;   free.n_NP = 0;  units.n_NP = '-'; label.n_NP = 'par. index of nitrogen in faeces';
    
% %               X         V          E         P
% par.n_O = [par.n_CX, par.n_CV, par.n_CE, par.n_CP;  % C/C, equals 1 by definition
%             par.n_HX, par.n_HV, par.n_HE, par.n_HP;  % H/C  these values show that we consider dry-mass
%             par.n_OX, par.n_OV, par.n_OE, par.n_OP;  % O/C
%             par.n_NX, par.n_NV, par.n_NE, par.n_NP]; % N/C
        
%            C     H     O     N
% par.n_M = [ 1     0     0     0;    % C/C, equals 0 or 1
%              0     2     0     3;    % H/C
%              2     1     2     0;    % O/C
%              0     0     0     1];   % N/C
 
         

end