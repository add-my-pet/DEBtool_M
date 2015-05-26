%% coded by Bas Kooijman, 2008/09/07
%% rat weight at constant (size independent) feeding at levels rho * ad lib
%% levels rho = 1, .75, .45 are set in fnv0_iso
%% Rattus norvegivus (Sprague-Dawley) that eat at constant rate
%% HubeLaro2000, as in Leeu2003 p121; t since birth = 35 d

tW100 = [...
    ];
tW75 = [...
    ];
tW45 = [...
    ];

dV = 1; % g/cm^3, spec density
w = .94; % -, contribution of reserve to weight
W0 = 142; % g, initial weight
v = 0.3; % cm/d, energy conductance
kM = .006; % 1/d, somatic maintenance rate coefficient
g = 7; % -, energy investment ratio
LT = 0; % cm, heating length

par = [dV 1; w 1; W0 1; v 1; g 1; kM 1; Lt 1];
partxt={'dV'; 'w'; 'W0'; 'v'; 'kM'; 'g'; 'LT'};
p = nmregr('fnv0_iso', par, tW100, tW75, tW45);
[cov, cor, sd] = pregr('fnv0_iso', p, tW100, tW75, tW45);
printpar(partxt,p,sd);

t=linspace(35,770,100)';
[W100, W75, W45] = fnv0_iso(p,t,t,t);

plot(tW100(:,1), tW100(:,2),'or', t, W100, 'r', ...
    tW75(:,1), tW75(:,2), 'og', t, W75, 'g', ...
    tW45(:,1), tW45(:,2), 'ob', t, W45, 'b')