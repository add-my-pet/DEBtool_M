%% shtraject_M
%
% created by Bas kooijman 2011/03/07
%
% mineral trajectories in the standard DEB model, stochastic version
%   in scaled mineral fluxes j_M = J_M/ k_M.M_Vm with M_Vm = [M_V] L_m^3
%   in scaled time with 1/k_M as time unit
%
% shtraject gives tau, f(tau), e(tau), l(tau), N(tau), uE0, g
%   the time intervals are short relative to d/dt e,l,N
% this means that d/dt e,l,cN can be obtained from the output table [t e l cN]
% 
% organic & mineral fluxes
% obtain organic fluxes
% j_O = (j_X, j_V, j_E+j_ER, j_P)  j_* = J_*/ M_Vm.k_M
% selected copy-paste from <dtraject.m *dtraject*> to get de dl j_ER

l2 = l .* l; l3 = l .* l2;

j_X = - f .* l2/ (kap * y_VX); % negative because food disappears

if e > l + lT % (positive) growth
  r = g * (e ./ l - 1 - lT ./ l) ./ (e + g); % spec growth rate
else % shrinking (negative growth)
  r = g * (e ./ l - 1 - lT ./ l) ./ (e + kapG * g); % spec growth rate
end
dl = l .* r/ 3; % growth in length
j_V = 3 * l2 .* dl;

de = g * (f - e) ./ l; % change in reserve density
j_E = (l3 .* de +  e  .* j_V)/ (g * kap * y_VE);
j_ER = (vH >= vHp) .* ((g + lT + l) .* e .* l .^2 ./ (e + g) - k * vHp) * kapR1; 
j_E = j_E + j_ER/ (kap * y_VE);

j_P = - y_PX * j_X; % sign opposite for that for food

j_O = [j_X, j_V, j_E, j_P]';

% obtain mineral fluxes
% J_M = (J_C, J_H, J_O, J_N)
% J_M = - n_M^-1 n_O J_O
% notice: J_M is given in scaled time
j_M = - n_M\n_O * j_O;

figure
subplot(2,2,1)
plot(t(alive), j_M(1,alive), 'g', t(~alive), j_M(1,~alive), 'r')
ylabel('scaled CO_2 production')
xlabel('time since birth')

%figure
subplot(2,2,2)
plot(t(alive), j_M(2,alive), 'g', t(~alive), j_M(2,~alive), 'r')
ylabel('scaled H_2O production')
xlabel('time since birth')

%figure
subplot(2,2,3)
plot(t(alive), -j_M(3,alive), 'g', t(~alive), -j_M(3,~alive), 'r')
ylabel('scaled O_2 use')
xlabel('time since birth')

%figure
subplot(2,2,4)
plot(t(alive), j_M(4,alive), 'g', t(~alive), j_M(4,~alive), 'r')
ylabel('scaled NH_3 production')
xlabel('time since birth')