%% select_marker
% graphical user interface for setting marker

%%
function marker = select_marker(marker)
%% created 2016/02/26 by Bas Kooijman

%% Syntax
% marker = <../select_marker.m *select_marker*> (marker)

%% Description
% Selects type, size, linewidth, edge color and face color of a marker
%
% Input:
%
% * marker: optional 5-vector of cells with type, size, linewidth, edge color and face color of a marker
%
% Output: 
% 
% * marker: 5-vector of cells with type, size, linewidth, edge color and face color of a marker

%% Remarks
% Type Esc when done

%% Example of use
% marker = select_marker;

  global T MS LW MEC MFC 
  
  if exist('marker', 'var')
    % unpack marker
    T = marker{1}; MS = marker{2}; LW = marker{3}; MEC = marker{4}; MFC = marker{5};
  else % assign default marker specification
    T = 'o'; MS = 12; LW = 4; MEC = 'b'; MFC = 'r'; 
  end
  
  HFig_marker = figure('Position', [360, 500, 450, 285]);

  % Components
  HType = uicontrol('Style','pushbutton',...
           'String', 'Type',...
           'Position',[315,220,70,15], ...
           'Callback', @Type_Callback);
  HMS   = uicontrol('Style','pushbutton',...
           'String', 'Size', ...
           'Position',[315,180,70,25], ...
           'Callback', @MS_Callback);
  HLW   = uicontrol('Style','pushbutton',...
           'String', 'Line Width', ...
           'Position',[315,135,70,25], ...
           'Callback', @LW_Callback);    
  HMEC  = uicontrol('Style','pushbutton', ...
           'String','Egde Color',...
           'Position',[325,90,60,15], ...
           'Callback', @MEC_Callback);
  HMFC  = uicontrol('Style','pushbutton', ...
           'String','Face Color',...
           'Position',[325,40,60,15], ...
           'Callback', @MFC_Callback);
   
  align([HType,HMS,HLW,HMEC,HMFC],'Center','None');
      
    
  plot(0, 0, T, 'MarkerSize', MS, 'LineWidth', LW, 'MarkerFaceColor', MFC, 'MarkerEdgeColor', MEC);
  axis('off');
  pause
 
  close (HFig_marker)
  marker = {T; MS; LW; MEC; MFC}; % pack marker
end

%% subfunctions
    function C = Type_Callback(source, eventdata) 
      global T MS LW MEC MFC 
      list = {'+','o','*','.','x','s','d','^','v','>','<','p','h'};
      n = length(list); i = 1:n;
      i = i(strcmp(list, 'o'));
      T = list(listdlg('PromptString', 'Select Type', 'ListString', list, 'Selectionmode', 'single', 'InitialValue', i));
      T = T{1}; 
      plot(0, 0, T, 'MarkerSize', MS, 'LineWidth', LW, 'MarkerFaceColor', MFC, 'MarkerEdgeColor', MEC); axis('off');
    end
    function C = MS_Callback(source, eventdata) 
      global T MS LW MEC MFC 
      list = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'};
      n = length(list); i = 1:n;
      i = i(strcmp(list, '12'));
      MS = list(listdlg('PromptString', 'Select Type', 'ListString', list, 'Selectionmode', 'single', 'InitialValue', i));
      MS = str2num(MS{1}); 
      plot(0, 0, T, 'MarkerSize', MS, 'LineWidth', LW, 'MarkerFaceColor', MFC, 'MarkerEdgeColor', MEC); axis('off');
    end
    function C = LW_Callback(h, str) 
      global T MS LW MEC MFC 
      list = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'};
      n = length(list); i = 1:n;
      i = i(strcmp(list, '4'));
      LW = list(listdlg('PromptString', 'Select Type', 'ListString', list, 'Selectionmode', 'single', 'InitialValue', i));
      LW = str2num(LW{1}); 
      plot(0, 0, T, 'MarkerSize', MS, 'LineWidth', LW, 'MarkerFaceColor', MFC, 'MarkerEdgeColor', MEC); axis('off');
    end
    function C = MEC_Callback(source, HMarker) 
      global T MS LW MEC MFC 
      MEC = uisetcolor(HMarker, 'Set MarkerEdge Color');
      plot(0, 0, T, 'MarkerSize', MS, 'LineWidth', LW, 'MarkerFaceColor', MFC, 'MarkerEdgeColor', MEC); axis('off');
    end
    function C = MFC_Callback(source, HMarker) 
      global T MS LW MEC MFC
      MFC = uisetcolor(HMarker, 'Set MarkerFace Color');
      plot(0, 0, T, 'MarkerSize', MS, 'LineWidth', LW, 'MarkerFaceColor', MFC, 'MarkerEdgeColor', MEC); axis('off');
    end
