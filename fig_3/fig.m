function page = fig(n)

  %% figures of DEB3 for which m-files are available 

  %% 01 02 03 04 05 06 07 08 09 10 11 tot chapters
  %% 22 54 34 68 30 40 28 48 46 44  8 421 pages (xvi + 489)
  %%  3 59 43 29 32 55 85  9 50  0  0 365 numbered equations
  %%  3  5  4  3  2  0  0  3  6  0  2  28 numbered tables
  %%  8 19 11 30 12 16 25 15 17 11  2 163 numbered figures
  %%  4 13  3 26  6 16 16 12 16  2  1 114 m-file figures
  %%  4 11  2 23  5 12  8 10  7  0  0  82 fit (data + model predictions)
  %%  0  1  0  3  1  2  9  2  8  2  1  29 sim (simulations)
  %%  0  1  0  0  0  2  0  0  1  0  0   4 dat (data)

  %% clear; closeplot

  %% setpath % to DEBtool
  switch n
    case '1.2' % fit
      page = 11;
      BergHelb82
    case '1.6' % fit
      page = 17;
      Meye84
    case '1.7' % fit
      page = 18;
      KooyHoev89
    case '1.8' % fit
      page = 22;
      Here79
    case '2.3' % fit
      page = 28;
      Wint73
    case '2.4' % fit
      page = 28;
      ZonnKooy89
    case '2.5' % fit
      page = 29;
      Kluy61
    case '2.6' % fit
      page = 32;
      Pila77 
    case '2.9' % dat
      page = 45;
      Balt90
    case '2.10' % fit
      page = 46;
      daph
    case '2.11' % fit
      page = 50;
      Bert_examples
    case '2.12' % fit
      page = 54;
      egg_fig
    case '2.13' % fit
      page = 57;
      altri
    case '2.14' % sim
      page = 59;
      Bert_fig
    case '2.15' % fit
      page = 62;
      foet
    case '2.17' % fit
      page = 68;
      RL
    case '2.19' % fit
      page = 70;
      FenaGors83
    case '3.1' % fit
      page = 80;
      Reev70
    case '3.2' % fit
      page = 80;
      Lyne64
    case '4.1' % sim
      page = 112;
      wscat
    case '4.2' % fit
      page = 114;
      step_up_down
    case '4.3' % fit
      page = 115;
      StroCary84
    case '4.4' % fit
      page = 115;
      Rich58a
    case '4.5' % fit
      page = 116;
      LDMD
    case '4.6' % fit
      page = 116;
      tLDMD
    case '4.7' % fit
      page = 122;
      HubeLaro2000
    case '4.9' % fit
      page = 125;
      Beun2001
    case '4.10' % fit
      page = 126;
      RussCook95
    case '4.11' % fit
      page = 129;
      rod
    case '4.13' % fit
      page = 131;
      rich75
    case '4.15' % sim
      page = 137;
      debflux
    case '4.16' % fit
      page = 139;
      esen82
    case '4.17' % fit
      page = 140;
      Koch70
    case '4.18' % fit
      page = 140;
      BremDenn87
    case '4.19' % fit
      page = 143;
      WhytEngl90
    case '4.21' % fit
      page = 144;
      Rich58
    case '4.22' % fit
      page = 158;
      %% setpath % to DEBtool/lib
      mYW
    case '4.23' % fit
      page = 158;
      %% setpath % to DEBtool/lib
      Rutg90
    case '4.24' % fit
      page = 162;
      %% setpath % to DEBtool/lib
      scha75
    case '4.25' % fit
      page = 165;
      Kaut82
    case '4.26' % fit
      page = 166;
      penguin
    case '4.27' % fit
      page = 168;
      Buch83
    case '4.28' % fit
      page = 170;
      Tt
    case '4.29' % fit
      page = 173;
      Berg2007
    case '4.30' % sim
      page = 176;
      otolith
    case '5.1' % fit
      page = 183;
      PostSche89
    case '5.5' % fit
      page = 190;
      Droo74a
    case '5.6' % fit
      page = 192;
      Droo74
    case '5.8' % fit
      page = 197;
      GillSalo94
    case '5.9' % fit
      page = 198;
      Huxl32
    case '5.12' % sim
      page = 205;
      plantcurve
    case '6.1' % fit
      page = 211;
      MacABail29
    case '6.2' % fit
      page = 212;
      WeinWalf86
    case '6.3' % fit
      page = 213;
      Comf63
    case '6.4' % fit
      page = 214;
      SlobJans88
    case '6.5' % sim
      page = 224;
      kinetics
    case '6.6' % fit
      page = 228;
      hcb
    case '6.7' % fit
      page = 228;
      mcn
    case '6.8' % fit
      page = 234;
      tox
    case '6.9' % fit
      page = 236;
      dir_effects
    case '6.10' % fit
      page = 237;
      KlokRoos96
    case '6.11' % fit
      page = 238;
      indir_effects
    case '6.12' % fit
      page = 242;
      RobeSalt81
    case '6.13' % fit
      page = 243;
      cd_cu
    case '6.14' % sim
      page = 245;
      chartox
    case '6.15' % dat
      page = 246
      %% brach, data went lost
    case '6.16' % dat
      page = 247;
      cartox
    case '7.2' % sim
      page = 254;
      closed
    case '7.6' % sim
      page = 261;
      chemo
    case '7.7' % sim
      page = 263;
      Blac05
    case '7.8' % sim
      page = 263;
      Blac05a
    case '7.10' % sim
      page = 264;
      sher
    case '7.11' % sim
      page = 265;
      diffuus
    case '7.12' % sim
      page = 266;
      prof
    case '7.15' % fit
      page = 271;
      gut
    case '7.17' % fit
      page = 274;
      ass
    case '7.18' % sim
      page = 275;
      cellcycle
    case '7.20' % fit
      page = 280;
      ForsWikl88
    case '7.21' % fit
      page = 280;
      Rose84
    case '7.22' % fit
      page = 281;
      ErnsIsaa91
    case '7.23' % fit
      page = 284;
      Came84
    case '7.24' % fit
      page = 286;
      popg
    case '7.25' % fit
      page = 287;
      NaraKono97
    case '8.2' % fit
      page = 296;
      Hemm69
    case '8.3' % sim
      page = 297;
      ue0_scale
    case '8.4' % fit
      page = 299;
      Mill81
    case '8.5' % fit
      page = 299;
      Harr75
    case '8.6' % fit
      page = 310;
      Bert_comp
    case '8.7' % fit
      page = 310;
      BlaxHunt82
    case '8.9' % fit
      page = 316;
      VoogHatt91
    case '8.10' % fit
      page = 317;
      Hend95
    case '8.11' % sim
      page = 317;
      flux_tox
    case '8.12' % fit
      page = 319;
      KooyHare90
    case '8.13' % fit
      page = 320;
      KooyBaas2007
    case '8.14' % fit
      page = 321;
      KooyBaas2007a
    case '8.15' % fit
      page = 321;
      Kone80
    case '9.1' % sim
      page = 331;
      symbiosis
    case '9.2' % sim
      page = 338;
      dirf
    case '9.3' % sim
      page = 339;
      MMDD
    case '9.4' % sim
      page = 339;
      dead
    case '9.5' % fit
      page = 341;
      Muld88
    case '9.6' % fit
      page = 343;
      salmo
    case '9.7' % fit
      page = 343;
      salhis
    case '9.8' % sim
      page = 344;
      juv
    case '9.9' % fit
      page = 345;
      popg2
    case '9.10' % fit
      page = 347;
      Fits90
    case '9.11' % sim
      page = 348;
    case '9.12' % sim
      page = 350;
    case '9.13' % dat
      page = 352;
      daphpop
    case '9.14' % fit	
      page = 357;
      HeijRoel81
    case '9.15' % fit
      page = 358;
      DentBazi76
    case '9.17' % sim
      page = 366;
      showm
    case '10.8' % sim
      page = 395;
      structure_endo
    case '10.11' % sim
      page = 402;
      cycle
    case '11.1' % sim
      page = 415;
      pH 
    otherwise
      page = 0;
  end
  
      