%% fig:flux_tox
%% out:flux_tox

%% steady flux

%% gset term postscript color solid "Times-Roman" 35
%% gset output "flux_tox.ps"

  hold on;
 
  lpow = linspace(-4,6,1000)';
  pow = 10 .^ lpow;
  x = .1;
  v = [.001 .01 .1 1 3.6];
  vi = 1; ki = 10;
  
  for j=1:5
    vj = v(j);
    ke = ki ./ (1 + pow * vi/ vj - vi * sqrt(pow));
    t = max(.001,(- log(1 - x)) ./ ke);
    plot(lpow, log10(t), 'r');
  end

  xlabel('log P_{ow}')
  ylabel('log time to saturation')
  title('time to saturation in film models')