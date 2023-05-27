double spline_TC(double tt)
{
  int i, n; n = 2;
  double t[n+1], TC[n+1];

  t[1] =     0; TC[1] =     1;
  t[2] =   550; TC[2] =     1;

  for (i = n - 1; i >= 1; i--)
  {
    if (tt - t[i] >= 0)
      break;
  }

  return TC[i] + (tt - t[i]) * (TC[i+1] - TC[i])/ (t[i+1] - t[i]);

}
