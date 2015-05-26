% created 2014/06/16 by Bas Kooijman
% runs get_pars_9_foetus and its inverse iget_pars_9_foetus
% consider increase of numerical accuracy in the case of large relative errors


% set parameters according to Balaenoptera 
t_0 = 0;             % d, delay till start of development

d_V = 0.3;           % g/cm^3, specific density of structure
t_b = 336;           % d, time at birth
t_x = 6*30.5;        % d, time at weaning
t_p = 2555;          % d, time at puberty
a_m = 29200;         % d, life span
W_b = 2.75e6;        % g, weight at birth
W_x = W_b + 30e6;    % g, weight at weaning
W_i = 160e6;         % g, weight at death
R_i = 0.0011;        % 1/d, reproduction rate
TC = tempcorr(273+20, 273+37, 15e3);
data = [d_V; t_b/TC; t_x/TC; t_p/TC; a_m/TC; W_b; W_x; W_i; R_i*TC];

% z = 181.4;           %   -, zoom factor
% v = 0.0204;          % 2 cm/d, energy conductance
% kap = 0.959;         % 3 -, allocation fraction to soma = growth + somatic maintenance
% p_M = 19.23;         % 4 J/d.cm^3, [p_M], vol-specific somatic maintenance
% p_Am = z * p_M/ kap; % 1 J/d.cm^2, max specific assimilation rate
% E_G = 7816;          % 5 J/cm^3, [E_G], spec cost for structure
% E_Hb = 3.91e7;       % 6 J, E_H^b, maturity at birth
% E_Hx = 2.30e8;       % 7 J, E_H^x, maturity at weaning
% E_Hp = 1.41e9;       % 8 J, E_H^p, maturity at puberty
% h_a = 1.370e-21;     % 9 1/d^2, Weibull aging acceleration
% par = [p_Am; v; kap; p_M; E_G; E_Hb; E_Hx; E_Hp; h_a];

txt_par = { ...
 '1 p_Am, J/d.cm^2, max specific assimilation rate';
 '2 v, cm/d, energy conductance';
 '3 kap, -, allocation fraction to soma';
 '4 p_M, J/d.cm^3, [p_M], vol-specific somatic maintenance';
 '5 E_G, J/cm^3, [E_G], spec cost for structure';
 '6 E_Hb, J, E_H^b, maturity at birth';
 '7 E_Hx, J, E_H^j, maturity at weaning';
 '8 E_Hp, J, E_H^p, maturity at puberty';
 '9 h_a, 1/d^2, Weibull aging acceleration'};

txt_data = { ...
 '1 d_V, g/cm^3, specific density of structure';
 '2 t_b, d, time at birth';
 '3 t_x, d, time since birth at weaning';
 '4 t_p, d, time since birth at puberty';
 '5 t_m, d, time since birth at death';
 '6 W_b, g, wet weight at birth';
 '7 W_x, g, wet weight at weaning';
 '8 W_m, g, maximum wet weight';
 '9 R_m, #/d, maximum reproduction rate'};

% [fil_p fl_p] = filter_pars_9(par); % run parameter filter
% if fil_p == 0
%   fprintf(['pars do not pass filter with flag ', num2str(fl_p),'\n'])
%   return
% end

% run iget_pars_9 and get_pars_9
par = get_pars_9_foetus(data, t_0);   % map data to par
Edata = iget_pars_9_foetus(par, t_0);   % map par to data
Epar = get_pars_9_foetus(Edata, t_0);   % map data to par

% [fil_d fl_d] = filter_data_9(data); % run data filter
% if fil_d == 0
%   fprintf(['data do not pass filter with flag ', num2str(fl_d),'\n'])
% end
   
printpar(txt_par, par, Epar, 'name, pars, back-estimated pars')
fprintf('\n'); % insert blank line
printpar(txt_data, data, Edata, 'name, data, back-estimated data')

MRE_par = sum(abs(par - Epar) ./ par)/9;
MRE_data = sum(abs(data - Edata) ./ data)/9;
printpar({'mean relative error of par and data'}, MRE_par, MRE_data, '')

%return

t_b = data(2); t_x = data(3); W_b = data(6); W_x = data(7); W_m = data(8); 
l_b = (W_b/ W_m)^(1/3);  % -, scaled length at birth
l_x = (W_x/ W_m)^(1/3);  % -, scaled length at metamorphosis
r_B = log((1 - l_b)/ (1 - l_x))/ t_x;    % 1/d, von Bertalanffy growth rate

t0_min = max(0,t_b - l_b/ r_B); t0_max = t_b;
t0 = linspace(t0_min + 0.5, t0_max - 0.5, 100)';
t0par = zeros(100,9);
for i = 1:100
  t0par(i,:) = get_pars_9_foetus(data, t0(i))';
end

close all

figure
subplot(3,3,1) 
plot(t0, t0par(:,1), 'b')
xlabel('t_0, d'); ylabel('\{p_{Am}\}, J/d.cm^2');
 
subplot(3,3,2) 
plot(t0, t0par(:,2), 'b')
xlabel('t_0, d'); ylabel('v, cm/d');

subplot(3,3,3) 
plot(t0, t0par(:,3), 'b')
xlabel('t_0, d'); ylabel('\kappa, -');

subplot(3,3,4) 
plot(t0, t0par(:,4), 'b')
xlabel('t_0, d'); ylabel('[p_M], J/d.cm^3');

subplot(3,3,5) 
plot(t0, t0par(:,5), 'b')
xlabel('t_0, d'); ylabel('[E_G], J/cm^3');

subplot(3,3,6) 
plot(t0, t0par(:,6), 'b')
xlabel('t_0, d'); ylabel('E_H^b, J');

subplot(3,3,7) 
plot(t0, t0par(:,7), 'b')
xlabel('t_0, d'); ylabel('E_H^x, J');

subplot(3,3,8) 
plot(t0, t0par(:,8), 'b')
xlabel('t_0, d'); ylabel('E_H^p, J');

subplot(3,3,9) 
plot(t0, t0par(:,9), 'b')
xlabel('t_0, d'); ylabel('h_a, 1/d^2');
