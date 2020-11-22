function [p, e_l, p_C] = powers (l, f)
  %  created 2000/09/07 by Bas Kooijman, modified 2009/09/29
  %
  %% Descxription
  %  calculates the basic powers (assimilation, dissipation, growth)
  %    and scaled res-dens and cat, cat + som maint powers 
  %
  %% Input
  %  l: (column or row) vector of scaled lengths
  %  f: scaled functional response (scalar)
  %
  %% Output
  %  p: matrix of powers for each scaled length (3 columns); page 123
  %
  %% Example of use
  %  see shpower
  
  %% Code
  global l_b l_p l_h g kap kap_R p_ref;

  nl=size(l(:),1); % nl = number of scaled lengths
  p =zeros(nl,8);     % initiate matrix of scaled powers
  e_l =f.*ones(nl,1); % initiate vector of scaled reserve densities

  for i= 1:nl
   
    if l(i)<l_b
      [lf, el3] = ode23('fnel3',[1e-6,l(i)], el3_init(f,g,l_b));
      e_l(i) = el3(end)/l(i)^3;
      a=l(i)^2*(e_l(i)-l(i))/(1+e_l(i)/g);
      p(i,:)= [0, e_l(i)*l(i)^2*(g+l(i))/(g+e_l(i)), kap*l(i)^3, ...
	     (1-kap)*l(i)^3, 0, kap*a, (1-kap)*a, 0];
    elseif l(i)<l_p % e_l(i) = f
      p_G = kap*l(i)^2*(f-l(i)-l_h)/(1+f/g);
      p_R = (1-kap)*l(i)^2*(f-l(i)+l_h*f/g)/(1+f/g);
      p(i,:)= [f*l(i)^2, f*l(i)^2*(g+l(i)+l_h)/(g+f), kap*l(i)^3, ...
	  (1-kap)*l(i)^3, kap*l_h*l(i)^2, p_G, p_R, 0];
    else % e_l(i) = f
      p_G = kap*l(i)^2*(f-l(i)-l_h)/(1+f/g);
      p_R = (1-kap)*(l(i)^2*(f-l(i)+l_h*f/g)/(1+f/g)+l(i)^3-l_p^3);
      p(i,:)= [f*l(i)^2, f*l(i)^2*(g+l(i)+l_h)/(g+f), kap*l(i)^3, ...
	     (1-kap)*l_p^3, kap*l_h*l(i)^2, p_G, 0, p_R];
    end
  end

  p=p*p_ref; % reference power p_ref= mu_E * M_Em * kT_M * g  
  % p has 8 powers (in colums) for each length, see DEB-book p123
  p_C = [p(:,2), p(:,3) + p(:,6)]; % catabolic, som maint + growth power
  p =[p(:,1), p(:,3)+p(:,4)+p(:,5)+(1-kap_R)*p(:,8), p(:,6)];
