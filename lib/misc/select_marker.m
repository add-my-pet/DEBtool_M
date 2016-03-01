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
% Press Esc when done

%% Example of use
% marker = select_marker;

  global T MS LW MEC MFC 
  
  if exist('marker', 'var')
    % unpack marker
    T = marker{1}; MS = marker{2}; LW = marker{3}; MEC = marker{4}; MFC = marker{5};
  else % assign default marker specification
    T = 'o'; MS = 12; LW = 4; MEC = 'b'; MFC = 'r'; 
  end
  
  HFig_marker = figure('Position', [300, 700, 400, 200]);

  % Components
  HType = uicontrol('Style','pushbutton',...
           'String', 'Type',...
           'Position',[315,150,70,25], ...
           'Callback', @Type_Callback);
  HMS   = uicontrol('Style','pushbutton',...
           'String', 'Size', ...
           'Position',[315,120,70,25], ...
           'Callback', @MS_Callback);
  HLW   = uicontrol('Style','pushbutton',...
           'String', 'Line Width', ...
           'Position',[315,90,70,25], ...
           'Callback', @LW_Callback);    
  HMEC  = uicontrol('Style','pushbutton', ...
           'String','Egde Color',...
           'Position',[315,60,70,25], ...
           'Callback', @MEC_Callback);
  HMFC  = uicontrol('Style','pushbutton', ...
           'String','Face Color',...
           'Position',[315,30,70,25], ...
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
      i = 1:length(list); i = i(strcmp(list, T));
      T = list(listdlg('PromptString', 'Select Type', 'ListString', list, 'Selectionmode', 'single', 'InitialValue', i));
      T = T{1}; 
      plot(0, 0, T, 'MarkerSize', MS, 'LineWidth', LW, 'MarkerFaceColor', MFC, 'MarkerEdgeColor', MEC); axis('off');
    end
    function C = MS_Callback(source, eventdata) 
      global T MS LW MEC MFC 
      list = {num2str((1:25)')};
      MS = listdlg('PromptString', 'Select Type', 'ListString', list, 'Selectionmode', 'single', 'InitialValue', MS);
      plot(0, 0, T, 'MarkerSize', MS, 'LineWidth', LW, 'MarkerFaceColor', MFC, 'MarkerEdgeColor', MEC); axis('off');
    end
    function C = LW_Callback(source, eventdata) 
      global T MS LW MEC MFC 
      list = {num2str((1:20)')};
      LW = listdlg('PromptString', 'Select Type', 'ListString', list, 'Selectionmode', 'single', 'InitialValue', LW);
      plot(0, 0, T, 'MarkerSize', MS, 'LineWidth', LW, 'MarkerFaceColor', MFC, 'MarkerEdgeColor', MEC); axis('off');
    end
    function C = MEC_Callback(source, eventdata) 
      global T MS LW MEC MFC 
      MEC = uisetcolor(HMarker, 'Set MarkerEdge Color');
      plot(0, 0, T, 'MarkerSize', MS, 'LineWidth', LW, 'MarkerFaceColor', MFC, 'MarkerEdgeColor', MEC); axis('off');
    end
    function C = MFC_Callback(source, eventdata) 
      global T MS LW MEC MFC
      MFC = uisetcolor(HMarker, 'Set MarkerFace Color');
      plot(0, 0, T, 'MarkerSize', MS, 'LineWidth', LW, 'MarkerFaceColor', MFC, 'MarkerEdgeColor', MEC); axis('off');
    end
