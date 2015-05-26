function plotdev
  global data
  pd = zeros(100,2);

  for i=1:100
    pd(i,:) = [i/50, dev('expon',i/50,data)];
  end
  clg;
  plot(pd(:,1), pd(:,2), 'r')