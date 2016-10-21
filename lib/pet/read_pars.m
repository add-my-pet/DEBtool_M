%% read_pars
% returns structure with values of core primary parameters for a given DEB model from allStat

%%
function [par model] = read_pars(nm)
% created 2016/10/21 by Bas Kooijman
 
  %% Syntax 
  % par = <../read_pars.m *read_pars*> (nm)

  %% Description
  % Read in global allStat the core primary parameters as specified in  get_parfields for a specified entry
  %
  % Input
  %
  % * string with name of entry 
  %
  % Output
  %
  % * par: structure with core parameter values
  % * model: string with model
  
  %% Remarks
  % Assumes that allStat is available as global

  %% Example of use
  % [par model] = read_pars('Daphnia_magna')
  
  global allStat
  
      model     = allStat.(nm).model;
      
      par.z     = allStat.(nm).z;      
      par.F_m   = allStat.(nm).F_m;
      par.kap_X = allStat.(nm).kap_X;
      par.kap_P = allStat.(nm).kap_P;
      par.v     = allStat.(nm).v;
      par.kap   = allStat.(nm).kap;
      par.kap_R = allStat.(nm).kap_R;
      par.p_M   = allStat.(nm).p_M;
      par.p_T   = allStat.(nm).p_T;
      par.k_J   = allStat.(nm).k_J;
      par.E_G   = allStat.(nm).E_G;
      par.E_Hb  = allStat.(nm).E_Hb;
      par.E_Hp  = allStat.(nm).E_Hp;
      par.h_a   = allStat.(nm).h_a;
      par.s_G   = allStat.(nm).s_G;
      
      par.n_CX  = allStat.(nm).n_CX;
      par.n_CV  = allStat.(nm).n_CV;
      par.n_CE  = allStat.(nm).n_CE;
      par.n_CP  = allStat.(nm).n_CP;
      par.n_HX  = allStat.(nm).n_HX;
      par.n_HV  = allStat.(nm).n_HV;
      par.n_HE  = allStat.(nm).n_HE;
      par.n_HP  = allStat.(nm).n_HP;
      par.n_OX  = allStat.(nm).n_OX;
      par.n_OV  = allStat.(nm).n_OV;
      par.n_OE  = allStat.(nm).n_OE;
      par.n_OP  = allStat.(nm).n_OP;
      par.n_NX  = allStat.(nm).n_NX;
      par.n_NV  = allStat.(nm).n_NV;
      par.n_NE  = allStat.(nm).n_NE;
      par.n_NP  = allStat.(nm).n_NP;
      
      par.n_CC  = allStat.(nm).n_CC;
      par.n_CH  = allStat.(nm).n_CH;
      par.n_CO  = allStat.(nm).n_CO;
      par.n_CN  = allStat.(nm).n_CN;
      par.n_HC  = allStat.(nm).n_HC;
      par.n_HH  = allStat.(nm).n_HH;
      par.n_HO  = allStat.(nm).n_HO;
      par.n_HN  = allStat.(nm).n_HN;
      par.n_OC  = allStat.(nm).n_OC;
      par.n_OH  = allStat.(nm).n_OH;
      par.n_OO  = allStat.(nm).n_OO;
      par.n_ON  = allStat.(nm).n_ON;
      par.n_NC  = allStat.(nm).n_NC;
      par.n_NH  = allStat.(nm).n_NH;
      par.n_NO  = allStat.(nm).n_NO;
      par.n_NN  = allStat.(nm).n_NN;
      
      par.d_E   = allStat.(nm).d_E;
      par.d_V   = allStat.(nm).d_V;
      par.mu_X  = allStat.(nm).mu_X;
      par.mu_E  = allStat.(nm).mu_E;
      par.mu_V  = allStat.(nm).mu_V;
      par.mu_P  = allStat.(nm).mu_P;
      
      par.T_ref = allStat.(nm).T_ref;
      par.T_A   = allStat.(nm).T_A;
      if exist(allStat.(nm).T_L, 'var')
        par.T_L = allStat.(nm).T_L;
      end
      if exist(allStat.(nm).T_AL, 'var')
        par.T_AL = allStat.(nm).T_AL;
      end
      if exist(allStat.(nm).T_H, 'var')
        par.T_H = allStat.(nm).T_H;
      end
      if exist(allStat.(nm).T_AH, 'var')
        par.T_AH = allStat.(nm).T_AH;
      end
      
      switch model
        case 'stx'
          par.E_Hx = allStat.(nm).E_Hx;
          par.t_0  = allStat.(nm).t_0;
        case 'ssj'
          par.E_Hs = allStat.(nm).E_Hs;
          par.t_sj = allStat.(nm).t_sj;
          par.k_E  = allStat.(nm).k_E;
        case 'abj' 
          par.E_Hj = allStat.(nm).E_Hj;
        case 'asj'
          par.E_Hs = allStat.(nm).E_Hs;
          par.E_Hj = allStat.(nm).E_Hj;
        case 'hep'
          par.E_Rj = allStat.(nm).E_Rj;
        case 'hex'
          par.s_j  = allStat.(nm).s_j;
          par.E_He = allStat.(nm).E_He;
      end
  
 
end
  
