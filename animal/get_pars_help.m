%% get_pars_* and iget_pars_* and elas_pars_*
%
%% Description
%  Functions get_pars_* obtain compound DEB parameters from easy-to-observe quantities
%  Functions iget_pars_* do the reverse, which can be used for checking. 
%
%  The routines are organized as follows
%
%	               |            get_pars   	          |             iget_pars               | 
%  food level      |	one 	      several 	      | one               several           |
%  constraint      | kJ = kM    kJ != kM   kJ = kM 	  | kJ = kM 	kJ != kM 	kJ = kM     |
%  growth 	       | get_pars_g get_pars_h get_pars_i |	iget_pars_g iget_pars_h iget_pars_i |
%  growth & reprod | get_pars_r get_pars_s get_pars_t |	iget_pars_r iget_pars_s iget_pars_s |
%                  |            get_pars_9            |             iget_pars_9             |
%
% Functions for several food levels do not use age at birth data. 
% If one food level is available, we have to make use of the assumption of stage transitions at fixed amounts of structure (k_M = k_J). 
% If several food levels are available, we no longer need to make this assumption, but it does simplify matters considerably. 
% Functions elas_pars_g and elas_pars_r give elasticity coefficients. 
% Function get_pars_u converts compound parameters into unscaled primary parameters at abundant food. 
% Function get_pars_9 converts data into unscaled primary parameters at abundant food. 
%
%% Remarks
%  The theory is discussed in KooySous2008 and LikaAugu2014. 
%  The heating length LT is assumed to be zero in all get_pars_* functions.
%
%% Example of use
%  See mydata_get_pars and mydata_get_pets_9. 
