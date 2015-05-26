% Usage:   last = priority [ [s] [l,bn,n,an] ] (single char argument)
% 
%          old priority is returned in 'last', new priority
%          can be low, below-normal, normal, or above-normal.
%          pre-pending 's' to the priority string will cause
%          silent behaviour. priorities higher than above-normal
%          are returned as 'h', but cannot be set due to the risk
%          of freezing the machine. sending 'h' as the new priority
%          will set to above-normal.
% 
% Example: last = priority('sl');
%          <do some idle processing>
%          priority(['s' last]);
%
%	Requires Win95 or WinNT 3.1 (or greater)

%	VERSION:  15/06/2002
%	AUTHOR:   ben mitch
%	CONTACT:  footballpitch@theconnexion.zzn.com
%	LOCATION:	utils\matlab\

%	--- IMPLEMENTED AS A MEX FILE ---
