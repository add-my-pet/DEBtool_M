%% fig:debflux
%% out:debflux

%% fluxes of food, structure, reserves, feaces,
%%     carbon dioxide, water, dioxygen, ammonia
%% in an individual isomorph at abundant food (f=1)

global l_b l_p l_h g kap kap_R p_ref;


%% Parameter values
%% chemical indices (relative elemental frequencies)
%% organic compounds
%%   columns: food, structure, reserve, faeces
%%     X     V     E     P
n_O = [1.0, 1.0, 1.0, 1.0;  % C/C, equals 1 by definition
       1.8, 1.8, 1.8, 1.8;  % H/C
       0.5, 0.5, 0.5, 0.5;  % O/C
       0.2, 0.2, 0.2, 0.2]; % N/C
%% minerals
%%   rows: elements carbon, hydrogen, oxygen, nitrogen
%%   columns: carbon dioxide, water, dioxygen, ammonia
%%     C  H  O  N
n_M = [1, 0, 0, 0;  % C
       0, 2, 0, 3;  % H
       2, 1, 2, 0;  % O
       0, 0, 0, 1]; % N

eta_O = [-1.5  0  0  ;       % mol/kJ, mass-energy coupler
	  0    0  0.5;       %         used in: J_O = eta_O * p
	  1   -1 -1  ;
	  0.5  0  0  ];

f = 1;         % -, scaled functional response

l_b = 0.16;    % -, scaled length at birth
l_p = 0.5;     % -, scaled length at puberty
l_h = 0;       % -, scaled heating length
g = 1;         % -, energy investment ratio
%% partitioning parameters: dimensionless fractions
kap = 0.9;     % -, fraction of catabolic flux allocated to soma
 % the remaining fraction is allocated to development and/or reproduction
kap_R = 0.8;   % -, fraction of flux allocated to reproduction that is
               %% fixed in embryonic reserves; the remaining fraction is lost
p_ref = .1;    % kJ/d, reference power

%% scaled lengths for embryo, juvenile and adult
n_e = floor(2 + 100 * l_b); l_e = linspace(1e-3, l_b - 1e-5, n_e);
if l_p < f
   n_j = floor(2+100*l_p - n_e); l_j = linspace(l_b, l_p - 1e-5, n_j);
   n_a = floor(2+100*f - n_e - n_j); l_a = linspace(l_p, f, n_a);
   l = [l_e l_j l_a];
else
   n_j = floor(2+100*f - n_e); l_j = linspace(l_b, f, n_j);
   n_a = 0;
   l = [l_e l_j];
end
in_e = 1:n_e; in_j = n_e + (1:n_j); in_a = n_e + n_j + (1:n_a);
%% indices of lengths that refer to embryo, juvenile and adult stage

n = [n_e; n_j; n_a];
p = powers(l, f);      % get powers

JO = p * eta_O';            % organic fluxes
JM =  - JO * (n_M\n_O)';    % mineral fluxes


%% gset term postscript color solid  "Times-Roman" 30
%% gset output "debflux.ps"
%%  clg; gset nokey;
%% multiplot(2,4);

  hold on;

  subplot (2, 4, 1); 
      if n(3) > 0
        plot(l_e, JO(in_e,1), '-r', l_j, JO(in_j,1), '-b', ...
	     l_a, JO(in_a, 1), '-g');
      else
        plot(l_e, JO(in_e,1), '-r', l_j, JO(in_j,1), '-b');
      end    
    ylabel('food, mol/d'); xlabel('scaled length');

    subplot (2, 4, 2);
      if n(3) > 0
        plot(l_e, JO(in_e,2), '-r', l_j, JO(in_j,2), '-b', ...
	     l_a, JO(in_a, 2), '-g');
      else
        plot(l_e, JO(in_e,2), '-r', l_j, JO(in_j,2), '-b');
      end    
    ylabel('struc mass, mol/d'); xlabel('scaled length');

    subplot (2, 4, 3);
      if n(3) > 0
        plot(l_e, JO(in_e,3), '-r', l_j, JO(in_j,3), '-b', ...
	     l_a, JO(in_a, 3), '-g');
      else
        plot(l_e, JO(in_e,3), '-r', l_j, JO(in_j,3), '-b');
      end    
    ylabel('reserves, mol/d'); xlabel('scaled length');

    subplot (2, 4, 4);
      if n(3) > 0
        plot(l_e, JO(in_e,4), '-r', l_j, JO(in_j,4), '-b', ...
	     l_a, JO(in_a, 4), '-g');
      else
        plot(l_e, JO(in_e,4), '-r', l_j, JO(in_j,4), '-b');
      end    
    ylabel('faeces, mol/d'); xlabel('scaled length');

    subplot (2, 4, 5);
      if n(3) > 0
        plot(l_e, JM(in_e,1), '-r', l_j, JM(in_j,1), '-b',  ...
	     l_a, JM(in_a, 1), '-g');
      else
        plot(l_e, JM(in_e,1), '-r', l_j, JM(in_j,1), '-b');
      end    
    ylabel('carbon dioxide, mol/d'); xlabel('scaled length');

    subplot (2, 4, 6);
      if n(3) > 0
        plot(l_a, JM(in_a,2), '-r', l_j, JM(in_j,2), '-b',  ...
	     l_a, JM(in_a, 2), '-g');
      else
        plot(l_e, JM(in_e,2), '-r', l_j, JM(in_j,2), '-b');
      end    
    ylabel('water, mol/d'); xlabel('scaled length');

    subplot (2, 4, 7);
      if n(3) > 0
        plot(l_e, JM(in_e,3), '-r', l_j, JM(in_j,3), '-b',  ...
	     l_a, JM(in_a, 3), '-g');
      elseif n(2) > 0
        plot(l_e, JM(in_e,3), '-r', l_j, JM(in_j,3), '-b');
      else
        plot(l_e, JM(in_e,3), '-r', l(in2));
      end    
    ylabel('dioxygen, mol/d'); xlabel('scaled length');

    subplot (2, 4, 8);
      if n(3) > 0
        plot(l_e, JM(in_e,4), '-r', l_j, JM(in_j,4), '-b', ...
	     l_a, JM(in_a, 4), '-g');
      else
        plot(l_e, JM(in_e,4), '-r', l_j, JM(in_j,4), '-b');
      end    
    ylabel('ammonia, mol/d'); xlabel('scaled length');

%% see shflux in toolbox 'animal' for more details
