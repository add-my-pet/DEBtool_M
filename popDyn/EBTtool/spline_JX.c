double spline_JX(double tt)
{
  int i, n; n = 2;
  double t[n+1], JX[n+1];

  t[1] =     0; JX[1] =   0.1;
  t[2] =   550; JX[2] =   0.1;

  for (i = n - 1; i >= 1; i--)
  {
    if (tt - t[i] >= 0)
      break;
  }

  return JX[i] + (tt - t[i]) * (JX[i+1] - JX[i])/ (t[i+1] - t[i]);

}
