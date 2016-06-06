% created 2016/01/30 by Goncalo Marques

% set parameters based on Balaenoptera 
d_V = 0.3;           % g/cm^3, specific density of structure
t_b = 36;            % d, time at birth
t_p = 2555;          % d, time at puberty
a_m = 29200;         % d, life span
W_b = 2.75e6;        % g, weight at birth
W_p = W_b + 30e6;    % g, weight at weaning
W_i = 160e6;         % g, weight at death
R_i = 0.0011;        % 1/d, reproduction rate
data = [d_V; t_b; t_b + t_p; a_m; W_b; W_p; W_i; R_i];

t_0 = 10;            % d, time to start embryo development
p_T = 100.0;   % J/d, {p_T} = 0  J/d.cm^2, surf-spec som maint

txt_par = { ...
 '1 p_Am, J/d.cm^2, max specific assimilation rate';
 '2 v, cm/d, energy conductance';
 '3 kap, -, allocation fraction to soma';
 '4 p_M, J/d.cm^3, [p_M], vol-specific somatic maintenance';
 '5 E_G, J/cm^3, [E_G], spec cost for structure';
 '6 E_Hb, J, E_H^b, maturity at birth';
 '7 E_Hp, J, E_H^p, maturity at puberty';
 '8 h_a, 1/d^2, Weibull aging acceleration'};

txt_data = { ...
 '1 d_V, g/cm^3, specific density of structure';
 '2 t_b, d, time at birth';
 '3 t_p, d, time since birth at puberty';
 '4 t_m, d, time since birth at death';
 '5 W_b, g, wet weight at birth';
 '6 W_p, g, wet weight at puberty';
 '7 W_m, g, maximum wet weight';
 '8 R_m, #/d, maximum reproduction rate'};

% to be changed when there is a filter_data_stx
% [fil_d fl_d] = filter_data_9(data); % run data filter
% if fil_d == 0
%   fprintf(['data do not pass filter with flag ', num2str(fl_d),'\n'])
% end

% run iget_pars_8_stx and get_pars_8_stx
par = get_pars_8_stx(data, t_0, p_T);   % map data to par
Edata = iget_pars_8_stx(par, t_0, p_T);   % map par to data
Epar = get_pars_8_stx(Edata, t_0, p_T);   % map data to par

L_T = p_T/ par(4); % p_T/ p_M
L_m = par(3) * par(1)/ par(4); % kap * pAm/ p_M
l_T = L_T/ L_m;

printpar(txt_par, par, Epar, 'name, pars, back-estimated pars')
fprintf('\n'); % insert blank line
printpar(txt_data, data, Edata, 'name, data, back-estimated data')
fprintf('\n'); % insert blank line
fprintf(['l_t, -, scaled heating length ', num2str(l_T), '\n']);

MRE_par = sum(abs(par - Epar) ./ par)/9;
MRE_data = sum(abs(data - Edata) ./ data)/9;
printpar({'mean relative error of par and data'}, MRE_par, MRE_data, '')

t_0 = 1:30;
for i = 1:length(t_0)
  par = get_pars_8_stx(data, t_0(i), 0);
  v(i)   = par(2);
  kap(i) = par(3);
  p_M(i) = par(4);
end

close all
plot(t_0, p_M)
figure
plot(t_0, kap)
figure
plot(t_0, v)

clear p_M v kap
p_T = 0:100:1000;
for i = 1:length(p_T)
  par = get_pars_8_stx(data, 0, p_T(i));
  v(i)   = par(2);
  kap(i) = par(3);
  p_M(i) = par(4);
  p_Am(i) = par(1);
end

close all
plot(p_T, p_M)
figure
plot(p_T, kap)
figure
plot(p_T, v)
figure
plot(p_T, p_Am)

