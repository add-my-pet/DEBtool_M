function f = skewNormal(p, logv)
  X = (logv(:,1) - p(1))/ p(2);
  f = (1 - erf(X/ sqrt(2)))/ 2 + 2 * owensT(X,p(3));
end
