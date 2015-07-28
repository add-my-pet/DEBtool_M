%% addchem
% sets chemical parameters and text for units and labels

%%
function [chem, txt_chem] = addchem(phylum, class, T_ref)
  % created by Starrlight Augustine, Dina Lika, Bas Kooijman, Goncalo Marques and Laure Pecquerie 2015/07/23
  
  %% Syntax
  % [chem, txt_chem] = <../addchem.m *addchem*>(phylum, class)
  
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
chem.d_X = d_V;  units.d_X = 'g/cm^3'; label.d_X = 'specific density of food'; 
chem.d_V = d_V;  units.d_V = 'g/cm^3'; label.d_V = 'specific density of structure'; 
chem.d_E = d_V;  units.d_E = 'g/cm^3'; label.d_E = 'specific density of reserve'; 
chem.d_P = d_V;  units.d_P = 'g/cm^3'; label.d_P = 'specific density of faeces';

% chemical potentials from Kooy2010 Tab 4.2
chem.mu_X = 525000; units.mu_X = 'J/ mol'; label.mu_X = 'chemical potential of food'; 
chem.mu_V = 500000; units.mu_V = 'J/ mol'; label.mu_V = 'chemical potential of structure'; 
chem.mu_E = 550000; units.mu_E = 'J/ mol'; label.mu_E = 'chemical potential of reserve'; 
chem.mu_P = 480000; units.mu_P = 'J/ mol'; label.mu_P = 'chemical potential of faeces'; 

% chemical potential of minerals
chem.mu_C = 0;     units.mu_C = 'J/ mol'; label.mu_C = 'chemical potential of CO2'; 
chem.mu_H = 0;     units.mu_H = 'J/ mol'; label.mu_H = 'chemical potential of H2O'; 
chem.mu_O = 0;     units.mu_O = 'J/ mol'; label.mu_O = 'chemical potential of O2'; 
chem.mu_N = 0;     units.mu_N = 'J/ mol'; label.mu_N = 'chemical potential of NH3'; 

% chemical indices for water-free organics from Kooy2010 Fig 4.15 (excluding contributions of H and O atoms from water)
chem.n_CX = 1;     units.n_CX = '-'; label.n_CX = 'chem. index of carbon in food'; % C/C = 1 by definition
chem.n_HX = 1.8;   units.n_HX = '-'; label.n_HX = 'chem. index of hydrogen in food';
chem.n_OX = 0.5;   units.n_OX = '-'; label.n_OX = 'chem. index of oxygen in food';
chem.n_NX = 0.15;  units.n_NX = '-'; label.n_NX = 'chem. index of nitrogen in food';

chem.n_CV = 1;     units.n_CV = '-'; label.n_CV = 'chem. index of carbon in structure'; % n_CV = 1 by definition
chem.n_HV = 1.8;   units.n_HV = '-'; label.n_HV = 'chem. index of hydrogen in structure';
chem.n_OV = 0.5;   units.n_OV = '-'; label.n_OV = 'chem. index of oxygen in structure';
chem.n_NV = 0.15;  units.n_NV = '-'; label.n_NV = 'chem. index of nitrogen in structure';

chem.n_CE = 1;     units.n_CE = '-'; label.n_CE = 'chem. index of carbon in reserve';   % n_CE = 1 by definition
chem.n_HE = 1.8;   units.n_HE = '-'; label.n_HE = 'chem. index of hydrogen in reserve';
chem.n_OE = 0.5;   units.n_OE = '-'; label.n_OE = 'chem. index of oxygen in reserve';
chem.n_NE = 0.15;  units.n_NE = '-'; label.n_NE = 'chem. index of nitrogen in reserve';

chem.n_CP = 1;     units.n_CP = '-'; label.n_CP = 'chem. index of carbon in faeces';    % n_CP = 1 by definition
chem.n_HP = 1.8;   units.n_HP = '-'; label.n_HP = 'chem. index of hydrogen in faeces';
chem.n_OP = 0.5;   units.n_OP = '-'; label.n_OP = 'chem. index of oxygen in faeces';
chem.n_NP = 0.15;  units.n_NP = '-'; label.n_NP = 'chem. index of nitrogen in faeces';
    
%               X         V          E         P
chem.n_O = [chem.n_CX, chem.n_CV, chem.n_CE, chem.n_CP;  % C/C, equals 1 by definition
            chem.n_HX, chem.n_HV, chem.n_HE, chem.n_HP;  % H/C  these values show that we consider dry-mass
            chem.n_OX, chem.n_OV, chem.n_OE, chem.n_OP;  % O/C
            chem.n_NX, chem.n_NV, chem.n_NE, chem.n_NP]; % N/C
        
%            C     H     O     N
chem.n_M = [ 1     0     0     0;    % C/C, equals 0 or 1
             0     2     0     3;    % H/C
             2     1     2     0;    % O/C
             0     0     0     1];   % N/C

% molar volume of gas at 1 bar and 20 C is 24.4 L/mol
T_C = 273.15; % K, temp at 0 degrees C
T = T_C + 20; % K, temp of measurement equipment
chem.X_gas = T_ref/ T/ 24.4;  units.X_gas = 'M'; label.X_gas = 'mol of gas per litre at T_ref (= 20 C) and 1 bar ';

txt_chem.units = units; txt_chem.label = label; % pack units, label in structure

end