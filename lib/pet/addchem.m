%% addchem
% sets chemical parameters and text for units and labels

%%
function [par, txtPar] = addchem(par, txtPar, phylum, class)
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
par.d_X = d_V;  txtPar.units.d_X = 'g/cm^3'; txtPar.label.d_X = 'specific density of food'; 
par.d_V = d_V;  txtPar.units.d_V = 'g/cm^3'; txtPar.label.d_V = 'specific density of structure'; 
par.d_E = d_V;  txtPar.units.d_E = 'g/cm^3'; txtPar.label.d_E = 'specific density of reserve'; 
par.d_P = d_V;  txtPar.units.d_P = 'g/cm^3'; txtPar.label.d_P = 'specific density of faeces';

% chemical potentials from Kooy2010 Tab 4.2
par.mu_X = 525000; txtPar.units.mu_X = 'J/ mol'; txtPar.label.mu_X = 'chemical potential of food'; 
par.mu_V = 500000; txtPar.units.mu_V = 'J/ mol'; txtPar.label.mu_V = 'chemical potential of structure'; 
par.mu_E = 550000; txtPar.units.mu_E = 'J/ mol'; txtPar.label.mu_E = 'chemical potential of reserve'; 
par.mu_P = 480000; txtPar.units.mu_P = 'J/ mol'; txtPar.label.mu_P = 'chemical potential of faeces'; 

% chemical potential of minerals
par.mu_C = 0;     txtPar.units.mu_C = 'J/ mol'; txtPar.label.mu_C = 'chemical potential of CO2'; 
par.mu_H = 0;     txtPar.units.mu_H = 'J/ mol'; txtPar.label.mu_H = 'chemical potential of H2O'; 
par.mu_O = 0;     txtPar.units.mu_O = 'J/ mol'; txtPar.label.mu_O = 'chemical potential of O2'; 
par.mu_N = 0;     txtPar.units.mu_N = 'J/ mol'; txtPar.label.mu_N = 'chemical potential of NH3'; 

% chemical indices for water-free organics from Kooy2010 Fig 4.15 (excluding contributions of H and O atoms from water)
par.n_CX = 1;     txtPar.units.n_CX = '-'; txtPar.label.n_CX = 'par. index of carbon in food'; % C/C = 1 by definition
par.n_HX = 1.8;   txtPar.units.n_HX = '-'; txtPar.label.n_HX = 'par. index of hydrogen in food';
par.n_OX = 0.5;   txtPar.units.n_OX = '-'; txtPar.label.n_OX = 'par. index of oxygen in food';
par.n_NX = 0.15;  txtPar.units.n_NX = '-'; txtPar.label.n_NX = 'par. index of nitrogen in food';

par.n_CV = 1;     txtPar.units.n_CV = '-'; txtPar.label.n_CV = 'par. index of carbon in structure'; % n_CV = 1 by definition
par.n_HV = 1.8;   txtPar.units.n_HV = '-'; txtPar.label.n_HV = 'par. index of hydrogen in structure';
par.n_OV = 0.5;   txtPar.units.n_OV = '-'; txtPar.label.n_OV = 'par. index of oxygen in structure';
par.n_NV = 0.15;  txtPar.units.n_NV = '-'; txtPar.label.n_NV = 'par. index of nitrogen in structure';

par.n_CE = 1;     txtPar.units.n_CE = '-'; txtPar.label.n_CE = 'par. index of carbon in reserve';   % n_CE = 1 by definition
par.n_HE = 1.8;   txtPar.units.n_HE = '-'; txtPar.label.n_HE = 'par. index of hydrogen in reserve';
par.n_OE = 0.5;   txtPar.units.n_OE = '-'; txtPar.label.n_OE = 'par. index of oxygen in reserve';
par.n_NE = 0.15;  txtPar.units.n_NE = '-'; txtPar.label.n_NE = 'par. index of nitrogen in reserve';

par.n_CP = 1;     txtPar.units.n_CP = '-'; txtPar.label.n_CP = 'par. index of carbon in faeces';    % n_CP = 1 by definition
par.n_HP = 1.8;   txtPar.units.n_HP = '-'; txtPar.label.n_HP = 'par. index of hydrogen in faeces';
par.n_OP = 0.5;   txtPar.units.n_OP = '-'; txtPar.label.n_OP = 'par. index of oxygen in faeces';
par.n_NP = 0.15;  txtPar.units.n_NP = '-'; txtPar.label.n_NP = 'par. index of nitrogen in faeces';
    
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


% all of these parameters are fixed by default.
% the user must overwrite these values in pars_init-my_pet if they wish to
% estimate them.
[nm, nst] = fieldnmnst_st(chem);
for j = 1:nst
    eval(['par.free.',nm{j},' = 0']);
end         
         

end