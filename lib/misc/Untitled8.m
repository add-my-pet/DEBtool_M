%% demo for nmfzero, relative to fzero

function test
par = 3;
  char_eq = @(rho, rho_p) 1 + exp(- rho * rho_p) - exp(rho); % see DEB3 eq (9.22): exp(-r*a_p) = exp(r/R) - 1 
  options = optimset('Display','iter');
  [rho_max, fval, info] = fzero(@(rho) char_eq(rho, par), [1e-9 1], options); 
  [rho_max, info] = nmfzero(@charEq, rho, .2, par);
end

function val = charEq (rho, rho_p)
  val = 1 + exp(- rho * rho_p) - exp(rho);
end