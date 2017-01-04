%% birth_pie
% Plots pie diagram for the cumulative energy investment at birth for foetus

%%
function [Hfig EMJHG uE0 info] = birth_pie_foetus(p, eb)
  % created at 2011/01/19 by Bas Kooijman; modified 2016/05/03, 2017/01/04
  
  %% Syntax
  % [Hfig EMJHG info] = <../birth_pie_foetus.m *birth_pie_foetus*> (p, eb)

  %% Description
  % Shell around <../get_EMJHG_foetus.m *get_EMJHG_foetus*> to draw pies.
  %  Plots pie diagrams for the cumulative energy investment at birth for
  %  Foetal development. See section 4.3.3 of the comments on the DEB-book. 
  %  The pie pieces are also given numerically as fractions in the output, which sum to 1. 
  %  Investments that are fully dissipated are drawn exploded. If the growth efficiency is specified, cumulative allocation to growth is splitted into that to growth overhead and structure.  
  %  If p(5) is specified, growth if splitted in dissipated and fixed in structure
  %
  % Input
  %
  % *  p: 4 or 5-vector with parameters: g, k, vHb, kap, kap_G
  %
  % *  eb: optional n-vector with scaled reserve densities at birth (default: 1)
  %
  % Output
  %
  % * Hfig: scalar with figure handle
  % * EMJHG: (n,5 or 6)-matrix with in the columns fractions of initial reserve at birth
  %
  %     - reserve left at birth, cumulatively allocated to som maint, mat maint, maturation, growth 
  %
  % * uE0: scalar with scaled energy investment in foetus
  % * info: n-vector with 1's success and 0's otherwise for uE0 and tau_b-computations
  
  %% Remarks
  % See also <birth_pie.html *birth_pie*> for egg development.

  %% Example of use
  % See <../mydata_birth_pie.m *mydata_birth_pie*>

  if exist('eb', 'var') == 0
    eb = 1; % maximum value as juvenile
  end
  n = length(eb);
  [EMJHG uE0 info] = get_EMJHG_foetus(p, eb);

  %close all
  if length(p) == 4
    pie_color = [1 1 .8; 1 0 0; 1 0 1; 0 0 1; 0 1 0];
    for i = 1:n
      pie_txt = { ...
        ['reserve ',   num2str(EMJHG(i,1), '% 3.2f')], ['som maint ', num2str(EMJHG(i,2), '% 3.2f')], ...
        ['mat maint ', num2str(EMJHG(i,3), '% 3.2f')], ['maturity ',  num2str(EMJHG(i,4), '% 3.2f')], ['growth ', num2str(EMJHG(i,5), '% 3.2f')]};
      Hfig = figure;
      colormap(pie_color);
      set(gca, 'FontSize', 15, 'Box', 'on')
      pie3s(EMJHG(i,:), 'Explode', [0 1 1 1 0], 'Labels', pie_txt, 'Bevel', 'Elliptical');
      title({['cum. investment at birth, e_b = ', num2str(eb(i))], ['E_{tot} = ', num2str(E0,'% 1.3e'), ' J']})
    end
  else
    pie_color = [1 1 .8; 1 0 0; 1 0 1; 0 0 1; 0 1 0; .8 1 .8];
    for i = 1:n
      pie_txt = { ...
        ['reserve ', num2str(EMJHG(i,1), '% 3.2f')], ['som maint ', num2str(EMJHG(i,2), '% 3.2f')], ['mat maint ', num2str(EMJHG(i,3), '% 3.2f')], ...
        ['maturity ',  num2str(EMJHG(i,4), '% 3.2f')], ['growth overhead ', num2str(EMJHG(i,5), '% 3.2f')], ['structure ', num2str(EMJHG(i,6), '% 3.2f')]};
      Hfig = figure;
      colormap(pie_color);
      set(gca, 'FontSize', 15, 'Box', 'on')
      pie3s(EMJHG(i,:), 'Explode', [0 1 1 1 1 0], 'Labels', pie_txt, 'Bevel', 'Elliptical');
      title({['cum. investment in foetus, e_b = ', num2str(eb(i))], ['E_{tot} = ', num2str(E0,'% 1.3e'), ' J']})
    end
  end
