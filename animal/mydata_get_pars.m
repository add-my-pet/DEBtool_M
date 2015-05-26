%% Demonstrates the use of get_pars_*, iget_pars_* and  elas_pars_*
%  modified 2008/06/04

switch 8 % change this to other numbers to run the different cases
  case 1
    %% only info on growth is available, not on reproduction
    %% check that get_pars_g and iget_pars_g are inverses
    %% first obtain easy-to-measure quantities from parameters
    p = [.2 2.5 .02 1.8]';     % p = [VHb g kM v]
    f = .6; % scaled functional response
    [q, U] = iget_pars_g(p, f); % p = [g kM v Lb]; q = [f Lb Li ab rB]
    %% now obtain parameters from quantities
    [pn, Un] = get_pars_g(q);   % q = [f Lb Li  ab rB]; pn = [g kM v Lb];
    %% compare the parameter values
    [p, pn] % must be the same
    %% obtain quantities from parameters again for extra security
    [qn, U] = iget_pars_g(pn, f);
    %% compare the quantity values
    [q, qn] % must be the same
    %% compare scaled reserve: initial and at birth
    [U, Un] % must be the same

  case 2 % single food level, growth data only
    %% although the relationship between quantities and parameters are exact, 
    %%  a small error in the quantities might produce
    %%  large errors in the parameters
    %% sensitivity analysis based on elasticity coefficients
    q = [1 .8 5 1.5 .09]';  % [Lb Li ab rB]
    [p, elas] = elas_pars_g(q); % p = [VHb g kM v]
    [p, elas] % pars & elasticity coefficients

  case 3 % several food levels kJ = kM
    %% only info on growth is available, not on reproduction
    %% check that get_pars_i and iget_pars_i are inverses
    %% first obtain easy-to-measure quantities from parameters
    p = [2.5 .02 1.8 .8]';     % p = [VHb g kM v]
    f = [1 .8 .6]'; % scaled functional response
    [q, U] = iget_pars_i(p, f); % p = [VHb g kM v]; q = [f Lb Li rB]
    %% now obtain parameters from quantities
    [pn Un] = get_pars_i(q,[],[2; .1; 1.5; .4]);
    %%  q = [f Lb Li rB]; pn = [g kM v Lb];
    %% compare the parameter values
    [p pn] % must be the same
    %% obtain quantities from parameters again for extra security
    qn = iget_pars_i(pn, f);
    %% compare the quantity values
    [q qn] % must be the same
    %% compare reserve (initial, at birth)
    [U Un]

  case 4 % several food levels
    %% only info on growth is available, not on reproduction
    %% check that get_pars_h and iget_pars_h are inverses
    %% first obtain easy-to-measure quantities from parameters
    p = [.2 1.5 .001 .02 1.8]'; % p = [VHb g kJ kM v]
    f = [1 .8 .6]'; % scaled functional response
    [q, U] = iget_pars_h(p, f); % p = [VHb g kJ kM v]; q = [f Lb Li rB]
    %% now obtain parameters from quantities
    [pn Un] = get_pars_h(q);
    %% q = [f Lb Li rB]; pn = [VHb g kJ kM v];
    %% compare the parameter values
    [p pn] % must be the same
    %% obtain quantities from parameters again for extra security
    qn = iget_pars_h(pn, f);
    %% compare the quantity values
    [q qn] % must be the same
    %% compare reserve (initial, at birth)
    [U Un]

  case 5 
    %% info on growth and reproduction is available at one food density
    %% makes use of the assumption of stage transition at fixed structure
    %% check that get_pars_r and iget_pars_r are inverses
    %% first obtain easy-to-measure quantities from parameters
    p = [.6; .95; 2; .1; .1; 2.5; 1; 2.5]; % p: [kap kapR g kJ kM v Hb Hp]
    f = 1; % scaled functional response
    [q, U] = iget_pars_r(p, f);  % q: [f, Lb, Lp, Li, ab, rB, Ri, kapR]
    %% now obtain parameters from quantities
    [pn, Un] = get_pars_r(q);
    %% compare the parameter values
    [p, pn] % must be the same
    %% obtain quantities from parameters again for extra security
    qn = iget_pars_r(pn, f);
    %% compare the quantity values
    [q, qn] % must be the same
    %% compare scaled reserve: initial, at birth and at puberty
    [U, Un] % must be the same

  case 6 % growth and reprod data; this takes some time to compute!
    %% although the relationship between quantities and parameters are exact, 
    %%  a small error in the quantities might produce
    %%  large errors in the parameters
    %% sensitivity analysis based on elasticity coefficients
    q = [.8 .8 2.5 4.1 2 .07 10]';  % q: [f, Lb, Lp, Li, ab, rB, Ri, kapR]
    [p, elas] = elas_pars_r(q); % p: [kap kapR g kJ kM v Hb Hp]
    [p, elas] % pars & elasticity coefficients

  case 7 % two food levels, no age at birth 'data'
    %%   no stage transitions at fixed structure
    %% first obtain easy-to-measure quantities from parameters
    %%   at 3 food levels
    p = [.7; .95; 2; .01; .1; 2.5; .1; 1.5]; % p: [kap kapR g kJ kM v Hb Hp]
    %% q(:,)= [f, Lb, Lp, Li, rB, Ri, kapR]
    [q, U] = iget_pars_s(p, [1; .8; .6; .4]); 
    %% now obtain parameters from quantities
    [pn, Un, qn] = get_pars_s(q);
    %% compare parameter values
    [p, pn] % must be the same
    %% check quantities
    [q', qn']

    case 8 % the final step from compound to primary parameters
    %% compose vector of compound parameters
    %% this could be the output of get_pars_s
    p = [.7; .95; 2; .1; .1; 2.5; .1; 0.95]; % p: [kap kapR g kJ kM v Hb Hp]
    %% compose vector of supplementary data (from measurements)
    q = [2; 10; 2.5; 1.8]; % q: [JXAm K ME0 MWb]

    [par, aLM] = get_pars_u(q,p); % get results
    %% prepare explanatory text for parameters
    txt = [{'{J_EAm}'}; {'b'}; {'y_EX'}; {'y_VE'}; {'v'}; {'[J_EM]'}; {'k_J'}; ...
	   {'kappa'}; {'kappa_R'}; {'M_H^b'}; {'M_H^p'}; {'[M_V]'}];
    printpar(txt,par) % show results
    fprintf('                age,    length, reserve mass, structural mass\n');
    age = ['start   '; 'birth   '; 'puberty '; 'ultimate'];
    [age, num2str(aLM)]

  otherwise
    return;
end

