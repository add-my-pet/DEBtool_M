/***
  NAME
    ebtbifstats.c
  DESCRIPTION
    Collects and outputs summary statistics over bifurcation runs. Apart from
    averages, minimum/maximum and variances over the output qunatities
    defined in the DefineOutput() routine, the following additional statistics
    are written to file:

        column OUTPUT_VAR_NR      : Bifurcation parameter
        column OUTPUT_VAR_NR+1    : Periodicity of oscillations in stored variable 1
        .
        .
        column OUTPUT_VAR_NR+N    : Periodicity of oscillations in stored variable N
        column OUTPUT_VAR_NR+N+1  : Average number of cohorts during bifurcation period
        column OUTPUT_VAR_NR+N+2  : cohort_limit (if adjusted during run)

  Last modification: AMdR - May 28, 2019
***/

// If not explicitly requested, output variances as CV
//    0: No output of variances
//    1: Variances as output
//    2: Variances as CV
#ifndef VARIANCES
#define VARIANCES  2
#endif
#if (VARIANCES == 0)
#if !defined(_MSC_VER)
#warning "Not generating any output on variances"
#endif
#endif
#ifndef PERIODICITY_OUTPUT_NR
#define PERIODICITY_OUTPUT_NR     0
#endif
#ifndef ADJUST_COH_LIMIT
#define ADJUST_COH_LIMIT          0                                                 // Do not adjust cohort limit by default
#endif
#ifndef TARGET_COHORTS
#define TARGET_COHORTS            500
#endif
#ifndef MIN_COH_LIMIT
#define MIN_COH_LIMIT             0.001
#endif
#ifndef MAX_COH_LIMIT
#define MAX_COH_LIMIT             1.0
#endif
#ifndef ZERO_CV
#define ZERO_CV                   0.001                                             // Threshold for positive coeff. of variation
#endif
#ifndef MAXFFT
#define MAXFFT                    65536                                             // Maximum points in FFT: 2^16
#endif
#ifndef TRANSFRAC
#define TRANSFRAC                 0.4
#endif
#ifndef M_PI
#define M_PI                      3.14159265358979323846
#endif
#ifndef HAS_FFTW3
#define HAS_FFTW3                 0
#endif

#ifndef NANO
#define NANO                      1.0E-9
#endif

static double                     stored[MAXFFT], wrapped[MAXFFT];
static int                        indexStored;
static double                     periodFFT;

static char                       fn[1024], currun[1024];

#define Sigma(ss, n)              sqrt((ss)/((double)(n - 1)))

static int                        Observation = 0;

static int                        PreventRecursion = 0;

static double                     delt_out_target;
extern double                     delt_out;

static double                     BifOutputVar[OUTPUT_VAR_NR];
static double                     AllAve[OUTPUT_VAR_NR];
static double                     AllGAve[OUTPUT_VAR_NR];
static double                     AllVar[OUTPUT_VAR_NR];
static double                     AllMax[OUTPUT_VAR_NR];
static double                     AllMin[OUTPUT_VAR_NR];
static double                     AveCohno[POPULATION_NR];

static void                       initMeasureBifstats(char *rn);
static void                       UpdateStats(double value, double *mean, double *gmean, double *sum_sq, int n);
static double                     dofft(double *source, double *tm, int obs);

#if (ADJUST_COH_LIMIT == 1)
#define COHORTLIMITS              13
static double                     CohLimits[COHORTLIMITS] = {0.001, 0.002, 0.0025, 0.005,
                                                             0.01,  0.02,  0.025,  0.05,
                                                             0.1,   0.2,   0.25,   0.5,
                                                             1.0};
static int                        CLindex = 0, minCLindex, maxCLindex;
static void                       setCohortLimit(double targetval);
#endif


/*
 *====================================================================================================================================
 *
 *    Implementation of globally aceesible routines
 *
 *====================================================================================================================================
 */

void  measureBifstats(double *env, population *pop)

{
  int     i, nr;
  static double   lastCallT = -HUGE_VAL;
  static int    first = 1;

  if (first) initMeasureBifstats(runname);
  first = 0;

  // If DefineOutput() is called from another routine in this file
  // return immediately
  if ((PreventRecursion) || (lastCallT > env[0]-0.5*cohort_limit)) return;

  // Measure over the last 60% of the bifurcation period.
  if ((env[0] < (next_bif_output - TRANSFRAC*BifPeriod)) && (!DoBifOutput)) return;

  memset(BifOutputVar, 0, OUTPUT_VAR_NR*sizeof(double));
  PreventRecursion = 1;
  if (outputDefined)
    for (i=0; i<OUTPUT_VAR_NR; i++) BifOutputVar[i] = output[i+1];                  // Output is shifted at end of FileOut()
  else DefineOutput(env, pop, BifOutputVar);
  PreventRecursion = 0;

  // Measure over the last 60% of the bifurcation period. With 2000 time units
  // as BifPeriod this allows for an FFT on 1024 data points.
  // Limit the storage to MAXFFT points. Wrap around the array if more
  nr = Observation % MAXFFT;

  // Store output variables
  stored[nr] = BifOutputVar[indexStored];

  Observation++;

  for (i=0; i<OUTPUT_VAR_NR; i++)
    {
      if (isnan(BifOutputVar[i]) || ismissing(BifOutputVar[i])) continue;

      AllMax[i] = max(BifOutputVar[i], AllMax[i]);
      AllMin[i] = min(BifOutputVar[i], AllMin[i]);

      UpdateStats(BifOutputVar[i], AllAve+i, AllGAve+i, AllVar+i, Observation);
    }

#if (POPULATION_NR > 0)
  for (i=0; i<POPULATION_NR; i++) UpdateStats(cohort_no[i], AveCohno+i, NULL, NULL, Observation);
#endif
  lastCallT = env[0];

  return;
}


/*==================================================================================================================================*/

void  outputMeasureBifstats(double *env, population *pop)

{
  int       i, j, nr;

  // If DefineOutput() is called from another routine in this file
  // or output is not required at this time return immediately
  if ((PreventRecursion) || (!DoBifOutput)) return;

#if (POPULATION_NR > 0)
  measureBifstats(env, pop);
#else
  measureBifstats(env, NULL);
#endif

  if (Observation < 2)                                                              // This should not happen
    ErrorExit(1, "Less than 2 observations stored at the end of BifPeriod, measuring not possible!");

  // If time equal to integer multiple of BifPeriod output all averages
  nr = imin(Observation, MAXFFT);
  if (Observation > MAXFFT)
    {
      // More points have been stored than the array allows
      // and hence the data are wrapped around. Unwrap!
      // First copy stored to wrapped
      memcpy(wrapped, stored, MAXFFT*sizeof(double));
      // What is stored at Observation % MAXFFT (which would be the
      // place of next storage) is in fact the first observation
      // and should end up in stored[0]. Similarly, what is stored at
      // (Observation+i) % MAXFFT should end up in stored[i].
      for (i=0; i<MAXFFT; i++)
        {
          j = (Observation + i) % MAXFFT;
          stored[i] = wrapped[j];
        }
    }
  periodFFT = dofft(stored, wrapped, nr);

  if (averages)
    {
      PrettyPrint(averages, env[0]);

      for (i=0; i<OUTPUT_VAR_NR; i++)
        {
          fprintf(averages, "\t");
          PrettyPrint(averages, AllAve[i]);
        }
      fprintf(averages, "\t");
      PrettyPrint(averages, parameter[BifParIndex]);

      fprintf(averages, "\t");
      PrettyPrint(averages, periodFFT);
      for (i=0; i<POPULATION_NR; i++)
        {
          fprintf(averages, "\t");
          PrettyPrint(averages, AveCohno[i]);
        }
#if (ADJUST_COH_LIMIT == 1)
      fprintf(averages, "\t");
      PrettyPrint(averages, cohort_limit);
#endif
      (void)fprintf(averages, "\n");
      (void)fflush(averages);
    }

  if (gaverages)
    {
      PrettyPrint(gaverages, env[0]);

      for (i=0; i<OUTPUT_VAR_NR; i++)
        {
          fprintf(gaverages, "\t");
          PrettyPrint(gaverages, exp(AllGAve[i]));
        }
      fprintf(gaverages, "\t");
      PrettyPrint(gaverages, parameter[BifParIndex]);

      fprintf(gaverages, "\t");
      PrettyPrint(gaverages, periodFFT);

      for (i=0; i<POPULATION_NR; i++)
        {
          fprintf(gaverages, "\t");
          PrettyPrint(gaverages, AveCohno[i]);
        }
#if (ADJUST_COH_LIMIT == 1)
      fprintf(gaverages, "\t");
      PrettyPrint(gaverages, cohort_limit);
#endif
      (void)fprintf(gaverages, "\n");
      (void)fflush(gaverages);
    }

  if (extrema)
    {
      PrettyPrint(extrema, env[0]);

      for (i=0; i<OUTPUT_VAR_NR; i++)
        {
          fprintf(extrema, "\t");
          PrettyPrint(extrema, AllMin[i]);
        }
      fprintf(extrema, "\t");
      PrettyPrint(extrema, parameter[BifParIndex]);

      fprintf(extrema, "\t");
      PrettyPrint(extrema, periodFFT);

      for (i=0; i<POPULATION_NR; i++)
        {
          fprintf(extrema, "\t");
          PrettyPrint(extrema, AveCohno[i]);
        }
#if (ADJUST_COH_LIMIT == 1)
      fprintf(extrema, "\t");
      PrettyPrint(extrema, cohort_limit);
#endif
      (void)fprintf(extrema, "\n");

      PrettyPrint(extrema, env[0]);

      for (i=0; i<OUTPUT_VAR_NR; i++)
        {
          fprintf(extrema, "\t");
          PrettyPrint(extrema, AllMax[i]);
        }
      fprintf(extrema, "\t");
      PrettyPrint(extrema, parameter[BifParIndex]);

      fprintf(extrema, "\t");
      PrettyPrint(extrema, periodFFT);

      for (i=0; i<POPULATION_NR; i++)
        {
          fprintf(extrema, "\t");
          PrettyPrint(extrema, AveCohno[i]);
        }
#if (ADJUST_COH_LIMIT == 1)
      fprintf(extrema, "\t");
      PrettyPrint(extrema, cohort_limit);
#endif
      (void)fprintf(extrema, "\n");
      (void)fflush(extrema);
    }

  if (variances)
    {
      PrettyPrint(variances, env[0]);

#if (VARIANCES == 2)
      for (i=0; i<OUTPUT_VAR_NR; i++)
        {
          fprintf(variances, "\t");
          if (AllAve[i] > NANO)
            PrettyPrint(variances, Sigma(AllVar[i], Observation)/AllAve[i]);
          else
            PrettyPrint(variances, 0.0);
        }
#else
      for (i=0; i<OUTPUT_VAR_NR; i++)
        {
          fprintf(variances, "\t");
          PrettyPrint(variances, Sigma(AllVar[i], Observation));
        }
#endif
      fprintf(variances, "\t");
      PrettyPrint(variances, parameter[BifParIndex]);

      fprintf(variances, "\t");
      PrettyPrint(variances, periodFFT);

      for (i=0; i<POPULATION_NR; i++)
        {
          fprintf(variances, "\t");
          PrettyPrint(variances, AveCohno[i]);
        }
#if (ADJUST_COH_LIMIT == 1)
      fprintf(variances, "\t");
      PrettyPrint(variances, cohort_limit);
#endif
      (void)fprintf(variances, "\n");
      (void)fflush(variances);
    }

#if ((ADJUST_COH_LIMIT == 1) && (POPULATION_NR > 0))
  double    avecn = 0.0;

  for (i=0; i<POPULATION_NR; i++) avecn +=AveCohno[i];
  avecn /= POPULATION_NR;
  setCohortLimit((avecn/TARGET_COHORTS)*cohort_limit);
#endif

  for (i=0; i<OUTPUT_VAR_NR; i++)
    {
      AllAve[i]    =  0.0;
      AllGAve[i]   =  0.0;
      AllVar[i]    =  0.0;
      AllMin[i]    =  HUGE_VAL;
      AllMax[i]    = -HUGE_VAL;
    }
  memset(stored, 0, MAXFFT*sizeof(double));

  for (i=0; i<POPULATION_NR; i++) AveCohno[i] = 0;

  DoBifOutput = 0;
  Observation = 0;

  return;
}


/*
 *====================================================================================================================================
 *
 *    Implementation of static routines
 *
 *====================================================================================================================================
 */

static void initMeasureBifstats(char *rn)

{
  int     i;

  strcpy(currun, rn);

  ReportNote(" ");
  ReportNote("%-57s:  %-10.6f", "Zero CV threshold", ZERO_CV);
#if (VARIANCES == 2)
  ReportNote("%-57s", "Variances of output variables expressed as coefficients of variation");
#else
  ReportNote("%-57s", "Variances of output variables expressed as standard deviation");
#endif

  Observation = 0;
  for (i=0; i<OUTPUT_VAR_NR; i++)
    {
      AllAve[i]    =  0.0;
      AllGAve[i]   =  0.0;
      AllVar[i]    =  0.0;
      AllMin[i]    =  HUGE_VAL;
      AllMax[i]    = -HUGE_VAL;
    }
  for (i=0; i<POPULATION_NR; i++) AveCohno[i] = 0;

  delt_out_target = delt_out;
#if (ADJUST_COH_LIMIT == 1)
  for (minCLindex = 0; (minCLindex <  COHORTLIMITS) && (CohLimits[minCLindex] < MIN_COH_LIMIT); minCLindex++);
  minCLindex = imin(minCLindex, COHORTLIMITS-1);

  for (maxCLindex = COHORTLIMITS-1; (maxCLindex >= 0) && (CohLimits[maxCLindex] > MAX_COH_LIMIT); maxCLindex--);
  maxCLindex = imax(maxCLindex, 0);

  setCohortLimit(cohort_limit);
#endif

  memset(stored, 0, MAXFFT*sizeof(double));
  indexStored = PERIODICITY_OUTPUT_NR;

  averages  = NULL;
  gaverages = NULL;
  extrema   = NULL;
  variances = NULL;

  strcpy(fn, currun);                                                               // Open additional file for averages output 
  strcat(fn, "avg.out");
  averages = fopen(fn, "a");
  if (!averages)
    fprintf(stderr, "Failed to open file %s\n", fn);

  strcpy(fn, currun);                                                               // Open additional file for geometric averages output
  strcat(fn, "gavg.out");
  gaverages = fopen(fn, "a");
  if (!gaverages)
    fprintf(stderr, "Failed to open file %s\n", fn);

  strcpy(fn, currun);                                                               // Open additional file for minima/maxima output
  strcat(fn, "minmax.out");
  extrema  = fopen(fn, "a");
  if (!extrema)
    fprintf(stderr, "Failed to open file %s\n", fn);

#if (VARIANCES != 0)
  strcpy(fn, currun);                                                               // Open additional file for variances output
  strcat(fn, "var.out");
  variances = fopen(fn, "a");
  if (!variances)
    fprintf(stderr, "Failed to open file %s\n", fn);
#endif

  return;
}


/*==================================================================================================================================*/
#if (ADJUST_COH_LIMIT == 1)

static void setCohortLimit(double targetval)

{
  double    ratio, testfun, maxtest;

  if (minCLindex > maxCLindex) return;

  // Determine the cohort limit index
  if (minCLindex == maxCLindex) CLindex = minCLindex;
  else if (targetval < CohLimits[minCLindex])
    CLindex = minCLindex;
  else if (targetval > CohLimits[maxCLindex])
    CLindex = maxCLindex;
  else
    {
      for (CLindex=maxCLindex, maxtest = 0.0; CLindex>=minCLindex; CLindex--)
        {
          ratio   = targetval/CohLimits[CLindex];
          testfun = ratio*exp(-ratio);
          if (testfun < maxtest) break;

          maxtest = testfun;
        }
    }

  cohort_limit = CohLimits[CLindex + 1];
  delt_out = max(delt_out_target, cohort_limit);

  return;
}

#endif

/*==================================================================================================================================*/

static void    UpdateStats(double value, double *mean, double *gmean, double *sum_sq, int n)

  /*
   * UpdateStats -  Routine that updates the value of the mean and the sum of
   *                the squared deviations from the mean for a series of number
   *                of which "value" is the next element.
   *
   * Arguments -  value : The current element in the series of numbers.
   *              mean  : The mean value of all preceding number in the series.
   *              sum_sq: The sum of the squared deviations of all preceding numbers.
   *              n     : The order number of the current value in the series.
   *                      It hence equals the number of observations on which
   *                      the resulting (!!) statistics are based.
   */

{
  double    deviation;

  // Very clever! Writing out the expressions for mean and variance shows that
  // it is indeed correct.

  // Compute arithmetic mean
  deviation  = value - *mean;
  *mean     += (deviation / n);

  // Compute the variance if requested
  if (sum_sq)
    *sum_sq += (deviation * (value - *mean));

  // Compute geometric mean: Ignore negative values completely, the mean is
  // only computed over all positive observations
  if (gmean && (value > 0))
    {
      deviation  = log(value) - *gmean;
      *gmean    += (deviation / n);
    }

  return;
}




/*==================================================================================================================================*/
#if (HAS_FFTW3 == 1)
#include <fftw3.h>

static void fft(double *jr, double *ji, int n)

{
  int     i, nc;
  double    *in;
  fftw_complex    *out;
  fftw_plan   plan_forward;

  // Set up an array to hold the transformed data, get a "plan", and execute
  // the plan to transform the IN data to the OUT FFT coefficients.
  nc = (n / 2) + 1;

  in  = (double *)fftw_malloc(sizeof(double) * n);
  out = (fftw_complex *)fftw_malloc(sizeof(fftw_complex) * nc);

  plan_forward = fftw_plan_dft_r2c_1d(n, in, out, FFTW_ESTIMATE);

  for (i = 0; i < n; i++) in[i] = jr[i];

  fftw_execute(plan_forward);

  for (i = 0; i < nc; i++)
    {
      jr[i]=out[i][0]; ji[i]=out[i][1];
    }

  // Release the memory associated with the plans.
  fftw_destroy_plan(plan_forward);
  fftw_free(in);
  fftw_free(out);

  return;
}

#else
static int bit_swap(int i, int nu)

/*
 * Bit swapping routine in which the bit pattern of the integer i is reordered.
 * See Brigham's book for details
 */

{
  int   ib, i1, i2;

  ib = 0;

  for (i1 = 0; i1 != nu; i1++)
    {
      i2 = i / 2;
      ib = ib * 2 + i - 2 * i2;
      i  = i2;
    }

  return (ib);
}


/*==================================================================================================================================*/

static void fswap(double *a, double *b)

{
  double  temp;

  temp = (*a);
  (*a) = (*b);
  (*b) = temp;

  return;
}


/*==================================================================================================================================*/

static void fft(double *real_data, double *imag_data, int n_pts)

/*
 * Carry out a FORWARD Fourier transform on data. Real and imaginary part of
 * the data points are stored in real_data and imag_data, respectively. These
 * arrays are of length n_pnts, which MUST be an integer power of 2 (this is
 * not checked for!).
 *
 * Routine is adapted from the routine implemented in the source code of
 * Grace.
 */

{
  int                             n2, i, ib, mm, k, nu;
  int                             tstep;
  double                          tr, ti, arg;                                      // intermediate values in calcs.
  double                          c, s;                                             // cosine & sine components of Fourier trans.
  static double                   *sintab = NULL;
  static int                      last_n = 0;

  // nu ...... logarithm in base 2 of n_pts e.g. nu = 5 if n_pts = 32.
  n2 = n_pts;
  nu = 0;
  while (n2 > 1)
    {
      nu++;
      n2 /= 2;
    }

  // n2 is the size of half the data array
  n2 = n_pts / 2;

  // just deallocate memory if called with zero points
  if (n_pts==0)
    {
      if (sintab) free(sintab);
      sintab = NULL;
      last_n = 0;
      return;
    }
  else if (n_pts != last_n)
    {
      /// allocate new sin table
      arg    = 2*M_PI/n_pts;
      last_n = 0;
      if (sintab) free(sintab);
      sintab = (double *) calloc(n_pts, sizeof(double));

      if (sintab == NULL) return;   // out of memory!

      for (i=0; i<n_pts; i++) sintab[i] = sin(arg*i);
      last_n = n_pts;
    }

  // do bit reversal of data in advance
  for (k = 0; k != n_pts; k++)
    {
      ib = bit_swap(k, nu);
      if (ib > k)
        {
          fswap((real_data + k), (real_data + ib));
          fswap((imag_data + k), (imag_data + ib));
        }
    }

  // Calculate the componets of the Fourier series of the function
  tstep = n2;
  for (mm = 1; mm < n_pts; mm*=2)
    {
      int sinidx=0, cosidx=n_pts/4;
      for (k=0; k<mm; k++)
        {
          c = sintab[cosidx];
          s = sintab[sinidx];

          sinidx += tstep; cosidx += tstep;
          if (sinidx >= n_pts) sinidx -= n_pts;
          if (cosidx >= n_pts) cosidx -= n_pts;

          for (i = k; i < n_pts; i+=mm*2)
            {
              double re1, re2, im1, im2;

              re1=real_data[i]; re2=real_data[i+mm];
              im1=imag_data[i]; im2=imag_data[i+mm];

              tr = re2 * c + im2 * s;
              ti = im2 * c - re2 * s;
              real_data[i+mm] = re1 - tr;
              imag_data[i+mm] = im1 - ti;
              real_data[i] = re1 + tr;
              imag_data[i] = im1 + ti;
            }
        }
      tstep /= 2;
    }

  return;
}

#endif

/*==================================================================================================================================*/

static double dofft(double *source, double *dummy, int obs)

{
  int     i, maxi, obs2;
  double    dt, *data, timespan, mean, variance;
  double    maxpower, x[3], y[3], period, a, b;

  // Data are collected at interval cohort_limit
  dt = cohort_limit;

#if (HAS_FFTW3 == 1)
  // If using FFTW3 we do not need a data length equal to a power of 2
  obs2 = obs;
#else
  // Here we have to find the largest power of 2 that is <= obs
  for (obs2 = MAXFFT; obs2 >= obs; obs2 >>= 1);
#endif

  // obs2 is now the length of the input series
  // Timespan is the number of observations minus 1 times the timestep
  timespan = (obs2-1)*dt;

  // Take the last obs2 data points. Data points are stored in
  // source[0]..source[obs-1]. The one's I need are in source[(obs-obs2)] to
  // source[obs-1].
  data = source + (obs-obs2);

  // Compute mean and variance of the observations
  mean = 0.0;
  for (i=0; i<obs2; i++) mean += data[i];
  mean /= obs2;

  variance = 0.0;
  for (i = 0; i < obs2; i++) variance += (data[i] - mean) * (data[i] - mean);
  variance /= (obs2 - 1);

  // If coefficient of variation is indistinguishable from 0, return

  if (sqrt(variance) < ZERO_CV*mean) return 0.0;

  // Zero-mean the data
  for (i=0; i<obs2; i++) data[i] -= mean;

  // Apply a Hann window to the data for better estimation
  for (i=0; i<obs2; i++)
    data[i] *= (0.5 - 0.5 * cos(2.0 * M_PI * i / (obs2 - 1.0)));

  // for(i=0; i<obs2; i++) printf("%10.4f\t%G\n", i*cohort_limit, data[i]);

  // Now zero the dummy array and use it as the imaginary data array
  memset(dummy, 0, MAXFFT*sizeof(double));

  // Call the FFT
  fft(data, dummy, obs2);

  maxpower = 0.0;
  maxi     = 0;

  // Calculate the power at each frequency
  for (i=0; i<obs2/2; i++)
    {
      if (!i)
        dummy[i] = fabs(data[i]);
      else
        {
          dummy[i]  = sqrt(data[i]*data[i] + dummy[i]*dummy[i]);

          // printf("%6d\t%12G\t", i, dummy[i]);

          dummy[i] += sqrt(data[obs2-i]*data[obs2-i] + dummy[obs2-i]*dummy[obs2-i]);

          // printf("%12G\n", dummy[i]);

          if (dummy[i] > maxpower)
            {
              maxpower = dummy[i];
              maxi     = i;
            }
        }

    }

  // Now we fit a parabola to the maximum peak in the powerspectrum
  for (i=0; i<3; i++)
    {
      x[i] = (maxi+i-1);
      y[i] = dummy[maxi+i-1];
    }

  // I fitted y = a*x*x + b*x + c and used Maple to derive the coefficients
  // a  = -(x[1]*y[0]-x[0]*y[1]-x[2]*y[0]-x[1]*y[2]+x[2]*y[1]+x[0]*y[2]);
  // a /= ((x[2]-x[1])*x[0]*x[0]+(x[0]-x[2])*x[1]*x[1]+(x[1]-x[0])*x[2]*x[2]);
  // b  = ((y[1]-y[0])*x[2]*x[2]+(y[2]-y[1])*x[0]*x[0]+(y[0]-y[2])*x[1]*x[1]);
  // b /= ((x[2]-x[1])*x[0]*x[0]+(x[0]-x[2])*x[1]*x[1]+(x[1]-x[0])*x[2]*x[2]);

  // This equals -b/(2*a), the frequency where the top is located
  // period  = ((y[1]-y[0])*x[2]*x[2]+(y[2]-y[1])*x[0]*x[0]+(y[0]-y[2])*x[1]*x[1]);
  // period /= 2*(x[1]*y[0]-x[0]*y[1]-x[2]*y[0]-x[1]*y[2]+x[2]*y[1]+x[0]*y[2]);
  // period  = timespan/period;

  // Drop the common denominator of both coefficients
  a = -(x[1]*y[0]-x[0]*y[1]-x[2]*y[0]-x[1]*y[2]+x[2]*y[1]+x[0]*y[2]);
  b = ((y[1]-y[0])*x[2]*x[2]+(y[2]-y[1])*x[0]*x[0]+(y[0]-y[2])*x[1]*x[1]);

  if (iszero(b))
    period = 0.0;
  else
    period = -timespan*2*a/b;

  return period;
}


/*==================================================================================================================================*/



