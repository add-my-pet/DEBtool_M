%% birth_pie
% Plots pie diagram for the cumulative energy investment at birth

%%
function [Hfig EMJHG info] = birth_pie(p, eb)
  % created at 2011/01/19 by Bas Kooijman; modified 2016/05/03
  
  %% Syntax
  % [Hfig EMJHG info] = <../birth_pie.m *birth_pie*> (p, eb)
  
  %% Description
  % Shell around <get_EMJHG.html *get_EMJHG*> to draw pies.
  % Plots pie diagram for the cumulative energy investment at birth
  % See  <http://www.bio.vu.nl/thb/research/bib/Kooy2010.pdf *section 4.3.3 of the comments on the DEB-book*>. 
  % The pie pieces are also given numerically as fractions in the output, which sum to 1. 
  % Investments that are fully dissipated are drawn exploded. 
  % If the growth efficiency is specified, cumulative allocation to growth is splitted into that to growth overhead and structure.  
  %
  % Input
  %
  % * p: 4 or 5-vector with parameters: g, k, vHb, kap, kap_G
  % * eb: optional n-vector with scaled reserve densities at birth (default: 1)
  %
  % Output
  %
  % * Hfig: scalar with figure handle
  % * EMJHG: (n,5 or 6)-matrix with in the columns fractions of initial reserve at birth
  %    reserve left at birth, cumulatively allocated to som maint, mat maint, maturation, growth 
  %    if p(5) is specified, growth if splitted in dissipated and fixed in structure
  % * info: n-vector with 1's success and 0's otherwise for uE0 and tau_b-computations
  
  %% Remarks
  % See also <birth_pie_foetus.html *birth_pie_foetus*> for foetal development.
  
  %% Example of use
  % See <../mydata_birth_pie.m *mydata_birth_pie*>

  if exist('eb','var') == 0
    eb = 1; % maximum value as juvenile
  end
  n = length(eb);
  [EMJHG info] = get_EMJHG(p, eb);

  %close all
  if length(p) == 4
    pie_txt = {'reserve', 'som maint', 'mat maint', 'maturity', 'growth'};
    pie_color = [1 1 .8; 1 0 0; 1 0 1; 0 0 1; 0 1 0];
    for i = 1:n
      Hfig = figure;
      colormap(pie_color);
      set(gca, 'FontSize', 15, 'Box', 'on')
      pie3s(EMJHG(i,:), 'Explode', [0 1 1 1 0], 'Labels', pie_txt, 'Bevel', 'Elliptical');
      title(['cum. investment at birth, e_b = ', num2str(eb(i))])  
    end
  else
    pie_txt = {'reserve', 'som maint', 'mat maint', 'maturity', 'growth overhead', 'structure'};
    pie_color = [1 1 .8; 1 0 0; 1 0 1; 0 0 1; 0 1 0; .8 1 .8];
    for i = 1:n
      Hfig = figure;
      colormap(pie_color);
      set(gca, 'FontSize', 15, 'Box', 'on')
      pie3s(EMJHG(i,:), 'Explode', [0 1 1 1 1 0], 'Labels', pie_txt, 'Bevel', 'Elliptical');
      title(['cum. investment at birth, e_b = ', num2str(eb(i))])
    end
  end