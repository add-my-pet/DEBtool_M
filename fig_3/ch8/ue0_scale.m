%% fig:ue0_scale
%% bib:Kooy2008
%% out:z_lb,z_tb,z_ue0

%% body size scaling relationships for u_E^0, l_b, t_b
%% M_H \propto L_m^3
%% U_H \propto L_m^2
%% u_H \propto L_m^0
%% v_H \propto L_m^0
%% k   \propto L_m^0
%% g   \propto L_m^-1
%% z: zoom factor

g = 80; z = 1; 
p = [g; .1; .005]; % g k v_H^b
[uE0 lb info] = get_ue0(p); tb = get_tb(p);
d = [z uE0 lb tb];
[uE0 lb tb info] = get_ue0_foetus(p);
f = [z uE0 lb tb];

p1 = [g; .5; .005]; % g k v_H^b
[uE0 lb info] = get_ue0(p1); tb = get_tb(p1);
d1 = [z uE0 lb tb];
[uE0 lb tb info] = get_ue0_foetus(p1);
f1 = [z uE0 lb tb];

p2 = [g; 1; .005]; % g k v_H^b
[uE0 lb info] = get_ue0(p2); tb = get_tb(p2);
d2 = [z uE0 lb tb];
[uE0 lb info] = get_ue0_foetus(p2);
f2 = [z uE0 lb tb];

c = 10000^.01;

for i = 1:100
  z = z * c;
  p(1) = g/ z;
  [uE0 lb] = get_ue0(p); tb = get_tb(p);
  d = [d; [z uE0 lb tb]];
  [uE0 lb tb] = get_ue0_foetus(p);
  f = [f; [z uE0 lb tb]];
  p1(1) = g/ z;
  [uE0 lb] = get_ue0(p1); tb = get_tb(p1);
  d1 = [d1; [z uE0 lb tb]];
  [uE0 lb tb] = get_ue0_foetus(p1);
  f1 = [f1; [z uE0 lb tb]];
  p2(1) = g/ z;
  [uE0 lb] = get_ue0(p2); tb = get_tb(p2);
  d2 = [d2; [z uE0 lb tb]];
  [uE0 lb] = get_ue0_foetus(p2);
  f2 = [f2; [z uE0 lb tb]];
end

%% gset term postscript color solid 'Times-Roman' 35

subplot(1,3,1)
%% gset output 'z_ue0.ps'
plot(log10(d(:,1)),  log10(d(:,2)),  'b', ...
     log10(d1(:,1)), log10(d1(:,2)), 'm', ...
     log10(d2(:,1)), log10(d2(:,2)), 'r')
%     log10(f(:,1)),  log10(f(:,2)),  'g', ...
%     log10(f1(:,1)), log10(f1(:,2)), 'g', ...
%     log10(f2(:,1)), log10(f2(:,2)), 'g')
%     [0; 4], log10(d(100,2)) - [2.2;0], 'g', ...
%     [0; 4], log10(d1(100,2)) - [3.3;0], 'g', ...
%     [0; 4], log10(d2(100,2)) - [4;0], 'g')

subplot(1,3,2)
%% gset output 'z_lb.ps'
plot(log10(d(:,1)),  log10(d(:,3)),  'b', ...
     log10(d1(:,1)), log10(d1(:,3)), 'm', ...
     log10(d2(:,1)), log10(d2(:,3)), 'r')
%     log10(f(:,1)),  log10(f(:,3)),  'g', ...
%     log10(f1(:,1)), log10(f1(:,3)), 'g', ...
%     log10(f2(:,1)), log10(f2(:,3)), 'g')
%     [0; 4], log10(d(100,3)) + [.55;0], 'g', ...
%     [0; 4], log10(d1(100,3)) + [.175;0], 'g', ...
%     [0; 4], log10(d2(100,3)) + [0;0], 'g')

subplot(1,3,3)
%% gset output 'z_tb.ps'
plot(log10(d(:,1)),  log10(d(:,4)),  'b', ...
     log10(d1(:,1)), log10(d1(:,4)), 'm', ...
     log10(d2(:,1)), log10(d2(:,4)), 'r')
%    log10(f(:,1)),  log10(f(:,4)),  'g', ...
%    log10(f1(:,1)), log10(f1(:,4)), 'g', ...
%    log10(f2(:,1)), log10(f2(:,4)), 'g')
%    [0; 4], log10(d(100,4)) - [3.4;0], 'g', ...
%    [0; 4], log10(d1(100,4)) - [3.55;0], 'g', ...
%    [0; 4], log10(d2(100,4)) - [3.7;0], 'g')

