%% fig:chartox
%% out:chareq,chareqf

%% effects of toxicants on the spec pop growth rate

piso = [1 .1 1 .2 .8 .0001 .9 .8 2]'; % parameters in the blank
lp = piso(9) * piso(2)/ (piso(5) * piso(1)); % scaled length ar puberty
fi = linspace(1, lp + .01 , 100)'; % scaled func response (backward)
ri = r_iso(piso, fi); rmi = r_iso(piso, 1);
q1iso = find_par('r_iso', 1,.9,.9,piso); r1iso = [ri, r_iso(q1iso, fi)]/ rmi;
q2iso = find_par('r_iso', 2,1.7,.9,piso); r2iso = [ri, r_iso(q2iso, fi)]/ rmi;
q3iso = find_par('r_iso', 3,1.15,.9,piso); r3iso = [ri, r_iso(q3iso, fi)]/ rmi;
q4iso = find_par('r_iso', 4,4,.9,piso); r4iso = [ri, r_iso(q4iso, fi)]/ rmi;
q5iso = find_par('r_iso', 5,.975,.9,piso); r5iso = [ri, r_iso(q5iso, fi)]/ rmi;
q6iso = find_par('r_iso', 6,45,.9,piso); r6iso = [ri, r_iso(q6iso, fi)]/ rmi;
q7iso = find_par('r_iso', 7,.7,.9,piso); r7iso = [ri, r_iso(q7iso, fi)]/ rmi;

fv = linspace(0,1,100)'; % scaled func response
pV1 = [1 .1 1 .2 .8 .01]'; rv = r_v1(pV1, fv); rmv = r_v1(pV1, 1);
q1V1 = find_par('r_v1', 1,.9,.9,pV1); r1V1 = [rv, r_v1(q1V1, fv)]/ rmv;
q2V1 = find_par('r_v1', 2,1.7,.9,pV1); r2V1 = [rv, r_v1(q2V1, fv)]/ rmv;
q3V1 = find_par('r_v1', 3,1.15,.9,pV1); r3V1 = [rv, r_v1(q3V1, fv)]/ rmv;
q4V1 = find_par('r_v1', 4,1.6,.9,pV1); r4V1 = [rv, r_v1(q4V1, fv)]/ rmv;
q5V1 = find_par('r_v1', 5,.78,.9,pV1); r5V1 = [rv, r_v1(q5V1, fv)]/ rmv;
q6V1 = find_par('r_v1', 6,10,.9,pV1); r6V1 = [rv, r_v1(q6V1, fv)]/ rmv;

diag = [0 0; 1 1];

subplot(1,2,1)
plot(r1iso(:,1), r1iso(:,2), '-r', ...
     r2iso(:,1), r2iso(:,2), '-g', ...
     r3iso(:,1), r3iso(:,2), '-b', ...
     r4iso(:,1), r4iso(:,2), '-m', ...
     r5iso(:,1), r5iso(:,1), '-y', ...
     r6iso(:,1), r6iso(:,2), '-k', ...
     r7iso(:,1), r7iso(:,2), '-c', ...
     diag(:,1),  diag(:,2),  '-k');
legend('{pAm}', '[pM]', '[Em]', '[EG]', 'kappa', 'ha', 'kapR',2);
axis([0,1,0,1]);
title ('isomorphs');
xlabel ('scaled blank spec growth rate');
ylabel ('scaled stressed spec growth rate');
%% set(YAxisLocation('right'))

subplot(1,2,2)
plot(r1V1(:,1), r1V1(:,2), '-r', ...
     r2V1(:,1), r2V1(:,1), '-g', ...
     r3V1(:,1), r3V1(:,2), '-b', ...
     r4V1(:,1), r4V1(:,2), '-m', ...
     r5V1(:,1), r5V1(:,2), '-y', ...
     r6V1(:,1), r6V1(:,2), '-k', ...
     diag(:,1), diag(:,2), '-k')
legend('[pAm]', '[pM]', '[Em]', '[EG]', 'kappa', 'ha',2);
axis([0,1,0,1]);
title ('V1-morphs');
xlabel ('scaled blank spec growth rate');
ylabel ('scaled stressed spec growth rate');
%% set(YAxisLocation('right'))

