%% Demo for [r, jEM, jVM, jER, info] = sgri (m_E, k_E, j_EM, y_EV, j_VM, a)

r0 = 0; r1 = 0; r2 = 0; % initiate specific growth rate

switch 1 % number indicates number of reserves (1 till 4)
  case 1
  k_E = 1; j_EM = 0.3; y_EV = 1.2; j_VM = 0.4;
  D0 = zeros(0,4); D1 = D0; D2 = D0; D3 = D0;
    for m_E = 0:.005:1
    [r0 jEM jVM] = sgr1(m_E, k_E, j_EM, y_EV, j_VM, 0, r0);
    D0 = [D0; [m_E r0 jEM jVM]];
    [r1 jEM jVM] = sgr1(m_E, k_E, j_EM, y_EV, j_VM, 1e-2, r1);
    D1 = [D1; [m_E r1 jEM jVM]];
    [r2 jEM jVM] = sgr1(m_E, k_E, j_EM, y_EV, j_VM, 1, r2);
    D2 = [D2; [m_E r2 jEM jVM]];
  end

  subplot(1,2,1)
  plot(D0(:,1), D0(:,3), 'b', ...
     D0(:,1), D0(:,4), 'b', ...
     D1(:,1), D1(:,3), 'm', ...
     D1(:,1), D1(:,4), 'm', ...
     D2(:,1), D2(:,3), 'r', ...
     D2(:,1), D2(:,4), 'r')
  xlabel('reserve density m_E')
  ylabel('j_E^M, j_V^M')
  legend('pref = 0', '', 'pref = 0.01', '', 'pref = 1', '', 4)

  subplot(1,2,2)
  plot(D0(:,1), D0(:,2), 'b',...
     D1(:,1), D1(:,2), 'm',...
     D2(:,1), D2(:,2), 'r')
  xlabel('reserve density m_E')
  ylabel('specific growth rate, r')
  legend('pref = 0', 'pref = 0.01', 'pref = 1', 4)

  
  case 2
  k_E = [1 1]'; j_EM = [0.3 .1]' ; y_EV = [1.2 1]'; j_VM = [0.4 .2]';

  j = 1;
  
  D0 = zeros(0,4); D1 = D0; D2 = D0; D3 = D0;
  for m = 0:.005:1
    m_E = 2000 * [1; 1]; m_E(j) = m;
    [r0 jEM jVM] = sgr2(m_E, k_E, j_EM, y_EV, j_VM, [0 0], r0);
    D0 = [D0; [m_E(j) r0 jEM(j) jVM(j)]];
    [r1 jEM jVM] = sgr2(m_E, k_E, j_EM, y_EV, j_VM, [1e-2 0], r1);
    D1 = [D1; [m_E(j) r1 jEM(j) jVM(j)]];
    [r2 jEM jVM] = sgr2(m_E, k_E, j_EM, y_EV, j_VM, [1 1], r2);
    D2 = [D2; [m_E(j) r2 jEM(j) jVM(j)]];
  end

  subplot(1,2,1)
  plot(D0(:,1), D0(:,3), 'b', ...
     D0(:,1), D0(:,4), 'b', ...
     D1(:,1), D1(:,3), 'm', ...
     D1(:,1), D1(:,4), 'm', ...
     D2(:,1), D2(:,3), 'r', ...
     D2(:,1), D2(:,4), 'r')
  xlabel('reserve density m_E')
  ylabel('j_E^M, j_V^M')
  legend('pref = 0', '', 'pref = 0.01', '', 'pref = 1', '', 4)

  subplot(1,2,2)
  plot(D0(:,1), D0(:,2), 'b',...
     D1(:,1), D1(:,2), 'm',...
     D2(:,1), D2(:,2), 'r')
  xlabel('reserve density m_E')
  ylabel('specific growth rate, r')
  legend('pref = 0', 'pref = 0.01', 'pref = 1', 4)


  case 3
  k_E = [1 1 1]'; j_EM = [0.3 .1 .2]' ; y_EV = [1.2 1 1.5]';
  j_VM = [0.4 .2 .5]';

  j = 3;
  
  D0 = zeros(0,4); D1 = D0; D2 = D0; D3 = D0;
  for m = 0:.005:1
    m_E = 2000 * [1; 1; 1]; m_E(j) = m;
    [r0 jEM jVM] = sgr3(m_E, k_E, j_EM, y_EV, j_VM, [0 0 0], r0);
    D0 = [D0; [m_E(j) r0 jEM(j) jVM(j)]];
    [r1 jEM jVM] = sgr3(m_E, k_E, j_EM, y_EV, j_VM, [1e-2 0 1e-3], r1);
    D1 = [D1; [m_E(j) r1 jEM(j) jVM(j)]];
    [r2 jEM jVM] = sgr3(m_E, k_E, j_EM, y_EV, j_VM, [1 1 1], r2);
    D2 = [D2; [m_E(j) r2 jEM(j) jVM(j)]];
  end


  subplot(1,2,1)
  plot(D0(:,1), D0(:,3), 'b', ...
     D0(:,1), D0(:,4), 'b', ...
     D1(:,1), D1(:,3), 'm', ...
     D1(:,1), D1(:,4), 'm', ...
     D2(:,1), D2(:,3), 'r', ...
     D2(:,1), D2(:,4), 'r')
  xlabel('reserve density m_E')
  ylabel('j_E^M, j_V^M')
  legend('pref = 0', '', 'pref = 0.01', '', 'pref = 1', '', 4)

  subplot(1,2,2)
  plot(D0(:,1), D0(:,2), 'b',...
     D1(:,1), D1(:,2), 'm',...
     D2(:,1), D2(:,2), 'r')
  xlabel('reserve density m_E')
  ylabel('specific growth rate, r')
  legend('pref = 0', 'pref = 0.01', 'pref = 1', 4)


  case 4
  k_E = [1 1 1 1]'; j_EM = [0.3 .1 .2 .15]' ; y_EV = [1.2 1 1.5 1.3]';
  j_VM = [0.4 .2 .5 .01]';

  j = 4;
  
  D0 = zeros(0,4); D1 = D0; D2 = D0; D3 = D0;
  for m = 0:.005:1
    m_E = 2000 * [1; 1; 1; 1]; m_E(j) = m;
    [r0 jEM jVM] = sgr4(m_E, k_E, j_EM, y_EV, j_VM, 0, r0);
    D0 = [D0; [m_E(j) r0 jEM(j) jVM(j)]];
    [r1 jEM jVM] = sgr4(m_E, k_E, j_EM, y_EV, j_VM, 1e-2, r1);
    D1 = [D1; [m_E(j) r1 jEM(j) jVM(j)]];
    [r2 jEM jVM] = sgr4(m_E, k_E, j_EM, y_EV, j_VM, 1, r2);
    D2 = [D2; [m_E(j) r2 jEM(j) jVM(j)]];
  end

  subplot(1,2,1)
  plot(D0(:,1), D0(:,3), 'b', ...
     D0(:,1), D0(:,4), 'b', ...
     D1(:,1), D1(:,3), 'm', ...
     D1(:,1), D1(:,4), 'm', ...
     D2(:,1), D2(:,3), 'r', ...
     D2(:,1), D2(:,4), 'r')
  xlabel('reserve density m_E')
  ylabel('j_E^M, j_V^M')
  legend('pref = 0', '', 'pref = 0.01', '', 'pref = 1', '', 4)

  subplot(1,2,2)
  plot(D0(:,1), D0(:,2), 'b',...
     D1(:,1), D1(:,2), 'm',...
     D2(:,1), D2(:,2), 'r')
  xlabel('reserve density m_E')
  ylabel('specific growth rate, r')
  legend('pref = 0', 'pref = 0.01', 'pref = 1', 4)

otherwise
end
  
