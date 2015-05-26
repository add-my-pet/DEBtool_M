a = 1; b = 3; x = (1:10)'; vc = 1e-1; n = 5000;
y = a + b * x;
w = 1 + 0./y.^2;
nrregr_options('default');
nrregr_options('report',0);
nrregr_options('max_step_number',1e3);
nrregr_options('max_set_size',1e2);
pars = zeros(2,n); sd = pars;
for i = 1:n
  ry = y + vc * y .* randn(10,1);
  pars(:,i) = nrvcregr('linear', [a;b], [x, ry, w]);
  [cov cor sd(:,i)] = pvcregr('linear', [a;b], [x, ry, w]);
end
[[a;b], sum(pars,2)/ n]
[sum(sd,2)/ n, sqrt(sum((pars- [a;b] * ones(1,n)).^2,2)/ n)]