% script that runs birth_pie and birth_pie_foetus for e_b = 1 and 0.6
 

% pie_par = [g k v_Hb kap kap_G];
pie_par = [3 .3 .0005 .8 .8];

birth_pie(pie_par, [1 0.6]);

%uE0_1 = get_ue0(pie_par, 1); [tb_1 lb_1] = get_tb(pie_par, 1);
%uE0_06 = get_ue0(pie_par, 0.6); [tb_06 lb_06] = get_tb(pie_par, 0.6); 

birth_pie_foetus(pie_par, [1 0.6]);

%[uE0_f1 lb_f1 tb_f1] = get_ue0_foetus(pie_par, 1);
%[uE0_f06 lb_f06 tb_f06] = get_ue0_foetus(pie_par, 0.6);
%[uE0_1 uE0_06 uE0_f1 uE0_f06]
%[tb_1 tb_06 tb_f1 tb_f06]
%[lb_1 lb_06 lb_f1 lb_f06]

clear pie_par