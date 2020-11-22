%% fig:Berg2007
%% out:tf1,fv1,tf,fv

%% Daphnia hyalina Data from Stella Berger 
%% cols: Length (mum), Width (mum), dry weight (mug),
%%   Length-egg(mum), Wight-egg(mum), number of eggs

%% set data and parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  Berg2007a
  xtw = [0 1.5 2000]; % pseudo observation for tR = 1.5 d;
  %% 0 = dummy; 2000 = weight for this observation

  [par lb] = set_par;
  
  switch 1  % Select scenario %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
    case 1 % functions for f different for each individual; scenario 1 %%%
  
    %% nmregr_options("default");
    q = par; % [q, info] = nmregr("reprod1", q, data, xtw)

    [V, tR, F] = reprod1(q(:,1), data, xtw);
    FF = linspace(f_min(q(:,1), data(:,4)), 1, 50)';
    p_isr = q(1:6,1); p_isr(1) = q(6,1)/(1 - q(1,1));
    VV = q(9,1) * initial_scaled_reserve(FF, p_isr);
    FLb = linspace(f_min(q(:,1), data(:,4)), lb, 10)';
    VLb = q(9,1) * initial_scaled_reserve(FLb, p_isr);
    Vc = correct_v(data(:,2), F); F = min(1,F);

%% gset term postscript color solid "Times-Roman" 35

%%    multiplot(1,2)
    subplot(1,2,1)
%% gset output "fv1.ps" 
%%    gset nokey
%%    gset xtics .2
%%    gset xrange [0:1]
%%    gset ytics .002
%%    gset yrange [0:.01]
    plot(F, data(:,1), '+b', F, Vc, '*g', FF, VV, 'r', FLb, VLb, 'm', ...
	 lb, VLb(10), '*m')

    subplot(1,2,2)
%% gset output 'tf1.ps'
%%    gset xtics 2
%%    gset xrange [16:26]
%%    gset ytics .2
%%    gset yrange [0:1]
    fm = f_mean(n,F);
    plot(t1, fm(1:6), 'g', t2, fm(7:13), 'r', t3, fm(14:20), 'b', t4, fm(21:29), 'm');
%%    multiplot(0,0)
    
  case 2 % functiond for f equal within one haul; scenario 2 %%%%%%%%%%%%

   par = [par; % append f for different hauls
	  0.208 1; % 1_17
	  0.701 1; % 1_18
	  0.281 1; % 1_19
          0.069 1; % 1_21
          0.124 1; % 1_22
          0.037 1; % 1_23
	  0.080 1; % 2_16
	  0.399 1; % 2_17
	  0.215 1; % 2_18
	  0.191 1; % 2_19
          0.020 1; % 2_20
          0.016 1; % 2_21
	  0.087 1; % 2_22
	  0.054 1; % 3_17
	  0.126 1; % 3_18
	  0.125 1; % 3_19
	  0.206 1; % 3_20
	  0.036 1; % 3_21
	  0.041 1; % 3_23
	  0.029 1; % 3_25
	  0.034 1; % 4_16
	  0.131 1; % 4_17
	  0.076 1; % 4_18
	  0.192 1; % 4_19
	  0.222 1; % 4_20
	  0.061 1; % 4_21
	  0.030 1; % 4_22
	  0.048 1; % 4_24
	  0.100 1];% 4_25

    q = par;
    if 1       
    nrregr_options('default');
    nrregr_options('max_step_number',50);
    nrregr_options('max_step_size',.01);
    [q, info] = nrregr('reprod', par, ...
    LN1_17, V1_17, LN1_18, V1_18, LN1_19, V1_19, ...
    LN1_21, V1_21, LN1_22, V1_22, LN1_23, V1_23, LN2_16, V2_16, ...
    LN2_17, V2_17, LN2_18, V2_18, LN2_19, V2_19, LN2_20, V2_20, ...
    LN2_21, V2_21, LN2_22, V2_22, LN3_17, V3_17, LN3_18, V3_18, ...
    LN3_19, V3_19, LN3_20, V3_20, LN3_21, V3_21, LN3_23, V3_23, ...
    LN3_25, V3_25, LN4_16, V4_16, LN4_17, V4_17, LN4_18, V4_18, ...
    LN4_19, V4_19, LN4_20, V4_20, LN4_21, V4_21, LN4_22, V4_22, ...
    LN4_24, V4_24, LN4_25, V4_25);
    end

    L = linspace(min(data(:,4)), max(data(:,4)),100)'; V = 0 * L;
    [N1_17, v1_17, N1_18, v1_18, N1_19, v1_19, ...
     N1_21, v1_21, N1_22, v1_22, N1_23, v1_23, N2_16, v2_16, ...
     N2_17, v2_17, N2_18, v2_18, N2_19, v2_19, N2_20, v2_20, ...
     N2_21, v2_21, N2_22, v2_22, N3_17, v3_17, N3_18, v3_18, ...
     N3_19, v3_19, N3_20, v3_20, N3_21, v3_21, N3_23, v3_23, ...
     N3_25, v3_25, N4_16, v4_16, N4_17, v4_17, N4_18, v4_18, ...
     N4_19, v4_19, N4_20, v4_20, N4_21, v4_21, N4_22, v4_22, ...
     N4_24, v4_24, N4_25, v4_25] = reprod(q(:,1), L, V, L, V, L, V, ...
    L, V, L, V, L, V, L, V, L, V, L, V, L, V, L, V, L, V, L, V, L, V, L, V, ...
    L, V, L, V, L, V, L, V, L, V, L, V, L, V, L, V, L, V, L, V, L, V, L, V, ...
    L, V, L, V);

%%     multiplot(5,7)
    subplot(5,7,1)
%%    gset term postscript color solid 'Times-Roman' 30
%%    gset nokey
%%    gset xtics .5
%%    gset xrange [1:2.5]
%%    gset ytics 10
%%    gset yrange [0:40]
    
    subplot(5,7,2)
%%    gset output 'ln1_17.ps'
    plot(LN1_17(:,1), LN1_17(:,2), 'og', L, N1_17, 'r');

    subplot(5,7,3)
%%    gset output 'ln1_18.ps'
%%    plot(LN1_18(:,1), LN1_18(:,2), 'og', L, N1_18, 'r');

    subplot(5,7,4)
%%    gset output 'ln1_19.ps'
    plot(LN1_19(:,1), LN1_19(:,2), 'og', L, N1_19, 'r');

    subplot(5,7,5)
%%    gset output 'ln1_21.ps'
%%    plot(LN1_21(:,1), LN1_21(:,2), 'og', L, N1_21, 'r');

    subplot(5,7,6)
%%    gset output 'ln1_22.ps'
    plot(LN1_22(:,1), LN1_22(:,2), 'og', L, N1_22, 'r');

    subplot(5,7,7)
%%    gset output 'ln1_23.ps'
    plot(LN1_23(:,1), LN1_23(:,2), 'og', L, N1_23, 'r');

    subplot(5,7,8)
%%    gset output 'ln2_16.ps'
    plot(LN2_16(:,1), LN2_16(:,2), 'og', L, N2_16, 'r');

    subplot(5,7,9)
%%    gset output 'ln2_17.ps'
    plot(LN2_17(:,1), LN2_17(:,2), 'og', L, N2_17, 'r');

    subplot(5,7,10)
%%    gset output 'ln2_18.ps'
    plot(LN2_18(:,1), LN2_18(:,2), 'og', L, N2_18, 'r');

    subplot(5,7,11)
%%    gset output 'ln2_19.ps'
    plot(LN2_19(:,1), LN2_19(:,2), 'og', L, N2_19, 'r');

    subplot(5,7,12)
%%    gset output 'ln2_20.ps'
    plot(LN2_20(:,1), LN2_20(:,2), 'og', L, N2_20, 'r');

    subplot(5,7,13)
%%    gset output 'ln2_21.ps'
    plot(LN2_21(:,1), LN2_21(:,2), 'og', L, N2_21, 'r');

    subplot(5,7,14)
%%    gset output 'ln2_22.ps'
    plot(LN2_22(:,1), LN2_22(:,2), 'og', L, N2_22, 'r');

    subplot(5,7,15)
%%    gset output 'ln3_17.ps'
    plot(LN3_17(:,1), LN3_17(:,2), 'og', L, N3_17, 'r');

    subplot(5,7,16)
%%    gset output 'ln3_18.ps'
    plot(LN3_18(:,1), LN3_18(:,2), 'og', L, N3_18, 'r');

    subplot(5,7,17)
%%    gset output 'ln3_19.ps'
    plot(LN3_19(:,1), LN3_19(:,2), 'og', L, N3_19, 'r');

    subplot(5,7,18)
%%    gset output 'ln3_20.ps'
    plot(LN3_20(:,1), LN3_20(:,2), 'og', L, N3_20, 'r');

    subplot(5,7,19)
%%    gset output 'ln3_21.ps'
    plot(LN3_21(:,1), LN3_21(:,2), 'og', L, N3_21, 'r');

    subplot(5,7,20)
%%    gset output 'ln3_23.ps'
    plot(LN3_23(:,1), LN3_23(:,2), 'og', L, N3_23, 'r');

    subplot(5,7,21)
%%    gset output 'ln3_25.ps'
    plot(LN3_25(:,1), LN3_25(:,2), 'og', L, N3_25, 'r');

    subplot(5,7,22)
%%    gset output 'ln4_16.ps'
    plot(LN4_16(:,1), LN4_16(:,2), 'og', L, N4_16, 'r');

    subplot(5,7,23)
%%    gset output 'ln4_17.ps'
    plot(LN4_17(:,1), LN4_17(:,2), 'og', L, N4_17, 'r');

    subplot(5,7,24)
%%    gset output 'ln4_18.ps'
    plot(LN4_18(:,1), LN4_18(:,2), 'og', L, N4_18, 'r');

    subplot(5,7,25)
%%    gset output 'ln4_19.ps'
    plot(LN4_19(:,1), LN4_19(:,2), 'og', L, N4_19, 'r');

    subplot(5,7,26)
%%    gset output 'ln4_20.ps'
    plot(LN4_20(:,1), LN4_20(:,2), 'og', L, N4_20, 'r');

    subplot(5,7,27)
%%    gset output 'ln4_21.ps'
    plot(LN4_21(:,1), LN4_21(:,2), 'og', L, N4_21, 'r');

    subplot(5,7,28)
%%    gset output 'ln4_22.ps'
    plot(LN4_22(:,1), LN4_22(:,2), 'og', L, N4_22, 'r');

    subplot(5,7,29)
%%    gset output 'ln4_24.ps'
    plot(LN4_24(:,1), LN4_24(:,2), 'og', L, N4_24, 'r');

    subplot(5,7,30)
%%    gset output 'ln4_25.ps'
    plot(LN4_25(:,1), LN4_25(:,2), 'og', L, N4_25, 'r');

    subplot(5,7,31)
%%    gset xtics 2
%%    gset xrange [16:26]
%%    gset ytics .2
%%    gset yrange [0:1]
%%    gset output 'tf.ps'
    f1 = q(10:15,1); f2 = q(16:22,1); f3 = q(23:29,1); f4 = q(30:38,1);
    plot(t1, f1, 'g', t2, f2, 'r', t3, f3, 'b', t4, f4, 'm');
    f = [f1; f2; f3; f4];

    subplot(5,7,32)
%%    gset xtics .2
%%    gset xrange [0:1]
%%    gset ytics .002
%%    gset yrange [0:.01]
%5    gset output 'fv.ps'
    FF = linspace(f_min(q(:,1), data(:,4)), 1, 50)';
    VV = q(9,1) * initial_scaled_reserve1(FF, q(1:6,1));
    F = cat_vert(n,f);
    plot(F, data(:,2), '+b', f, V_min, '*g', FF, VV,'r')    
		 
  otherwise
    return;

end
