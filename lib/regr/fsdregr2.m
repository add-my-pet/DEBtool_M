function f = fsdregr2 (p)
  % created: 2001/09/07 by Bas Kooijman
  % routine called by fsregr2 to calculate numerical derivatives
  % f: (l)-vector with derivatives with respect to parameters
  %   that are listed in vector 'index', set by 'fsregr2'

  global index  nxy l;
  global fn_name par X Y ZZ WW;

  par (index,1) = p;

  step = 1e-6;
  eval(['f = ',fn_name,'(par, X, Y);']);
  df = zeros(nxy,l);
  for i = 1 : l
    cpar = par; cpar(i) = par(i) + step;
    eval(['g =', fn_name,'(cpar, X, Y);']);
    df(:,i) = reshape((g - f)/step, nxy, 1);
  end

  f = df'*(WW .* (ZZ - reshape(f, nxy, 1))); % weighted derivatives which must be set to zero