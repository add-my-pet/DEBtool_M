double spline_JX(double tt)
{
  int i, n; n = 2;
  double t[n+1], JX[n+1];

  t[1] =     0; JX[1] = 3.729e+04;
  t[2] = 5.475e+04; JX[2] = 3.729e+04;

  for (i = n - 1; i >= 1; i--)
  {
    if (tt - t[i] >= 0)
      break;
  }

  return JX[i] + (tt - t[i]) * (JX[i+1] - JX[i])/ (t[i+1] - t[i]);

}
