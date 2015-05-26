function err = testpars
  %% Created at 2002/04/04 by Bas Kooijman
  %% tests some consistencies of parameter values for 'endosym'
  %% err: scalar with error information: err = 0 if no error is detected

  pars_endosym; % get parameter values

  %% chemical potentials (not part of dynamic system)
  %% combustion frame of reference
  mu1_S = 750; mu2_S = 750; % substrates
  mu1_P = 700; mu2_P = 700; % products
  mu1_E = 650; mu2_E = 650; % reserves
  mu1_V = 500; mu2_V = 500; % structures

  %% substrates and products are substitutable
  if mu2_P < mu1_E*y1_EP + mu1_P*y1_PP
    err = 1;  % 
  elseif mu1_P < mu2_E*y2_EP + mu2_P*y2_PP
    err = 2;
  elseif mu1_S < mu1_E*y1_ES + mu1_P*y1_PS
    err = 3;
  elseif mu2_S < mu2_E*y2_ES + mu2_P*y2_PS
    err = 4; % S2 + y2_PS P2 ->
  elseif mu1_E < mu1_V/y1_EV + mu1_P*y1_PG
    err = 5;
  elseif mu2_E < mu2_V/y2_EV + mu2_P*y2_PG
    err = 6;
  elseif mu1_E < mu1_P*y1_PM/max(1e-10,y1_EP)
    err = 7;
  elseif mu2_E < mu2_P*y2_PM/max(1e-10,y2_EP)
    err = 8;
    %% substrates and products are complementary
  elseif mu1_E > (mu2_P - mu1_P*y1_PP)*y1_Pt/y1_Et + mu1_S*y1_St/y1_Et
    err = 9;
  elseif mu2_E > (mu1_P - mu2_P*y2_PP)*y2_Pt/y2_Et + mu2_S*y2_St/y2_Et
    err = 10;
  else
    err = 0;
  end
  if err ~= 0
    printf(['Parameter values are inconsistent, error ', num2str(err),' \n']);
  end

  err=0;
