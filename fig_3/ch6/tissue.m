function df = tissue(t, x)
  %% called from kinetics
  global k

  %% unpack x
  l = x(1); % scaled length
  c_V = x(2); % scaled tissue conc at environ conc c_d = 1

  dl = 1 - l; % von Bertalanffy growth at f = 1
  %% dilution by growth d/dt ln l^3 = l^-3 d/dt l^3 = l^-3 3 l^2 d/dt l
  %% first compartment kinetics with elim rate propto 1/l
  dc_V = k * (1 - c_V)/ l - 3 * c_V * dl / l;

  df = [dl; dc_V];
