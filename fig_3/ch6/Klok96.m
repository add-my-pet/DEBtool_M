%% fig:Klok96;
%% bib:KlokRoos96
%% out:assitime,assiconc
%% Effect of CuCl_2 on body growth of Lumbricus rubellus

t = [29.4483 57.2128 84.9764 112.7409 154.3871 196.0334]';
c = [13 60 145 362]';
L = [4.8559  4.6815  4.0897  2.5763;
     7.4308  7.3061  6.2675  5.1526;
     8.9545  8.6907  7.6512  6.2675;
    10.3040  9.9716  8.9399  7.3471;
    10.9876 10.7167  9.5839  7.8128;
    10.9117 10.5657  9.3879  8.2460];

par_txt = {'NEC'; 'tolerance conc'; 'max blank length'; ...
	   'von Bert growth rate'; 'initial length'};
nmregr_options('max_step_number',500)
p_asi = [4.45 1; 1193 1; 11.66 1; 0.018 1; 0 0];
p_asi = nmregr2('asigrowth', p_asi, t, c, L);
[cov, cor, sd, ssq] = pregr2('asigrowth', p_asi, t, c, L);
fprintf('assimilation model \n');
printpar(par_txt, p_asi, sd);

shregr2('asigrowth',p_asi, t, c, L);
title('L. rubellus in CuCl2; assimilation model')
