function f = accum(p, tc)
  %% tc(:,1) must be stricty increasing starting from 0     
  global ke BCF t0

  %% unpack parameters
  ke = p(1); BCF = p(2); t0 = p(3);
  [t f] = ode23('daccum', [0; 1e-6+tc(:,1)], [0 0]');
  nf = length(f); f = f(2:nf,1);
