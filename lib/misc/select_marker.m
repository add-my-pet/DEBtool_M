%% select_marker
% graphical user interface for setting marker

%%
function marker = select_marker(marker)
% created 2016/02/26 by Bas Kooijman; modified 2016/03/08 by Dina Lika,
% 2018/01/22, 2018/06/02 by Bas Kooijman,

%% Syntax
% marker = <../select_marker.m *select_marker*> (marker, k)

%% Description
% Selects marker specification: type, size, linewidth and edge color and face color if k is absent or false
%
% Input:
%
% * marker: optional 3 or 5-vector of cells with marker specs: type, size, linewidth, and edge color and face color 
%
% Output: 
% 
% * marker: 3 or 5-vector of cells with marker specs: type, size, linewidth, and edge color and face color 
%
%% Remarks
% Press OK when done
 
%% Example of use
% marker = select_marker;

  global T MS LW MEC MFC HMarker
  
  if exist('marker', 'var')
    % unpack marker
    if length (marker) == 5
      T = marker{1}; MS = marker{2}; LW = marker{3}; MEC = marker{4}; MFC = marker{5};
    else
      T = marker{1}; MS = marker{2}; LW = marker{3}; MEC = [0 0 0]; MFC = [0 0 0];
    end
  else % assign default marker specification
    T = 'o'; MS = 12; LW = 4; MEC = [0 0 0]; MFC = [0 0 0]; 
  end
  
  HFig_marker = figure('Position', [300, 300, 400, 200]);

  % Components
  HType = uicontrol('Style','pushbutton',...
           'String', 'Type',...
           'Position',[315,160,70,25], ...
           'Callback', @Type_Callback);
  HMS   = uicontrol('Style','pushbutton',...
           'String', 'Size', ...
           'Position',[315,130,70,25], ...
           'Callback', @MS_Callback);
  HLW   = uicontrol('Style','pushbutton',...
           'String', 'Line Width', ...
           'Position',[315,100,70,25], ...
           'Callback', @LW_Callback);    
  HMEC  = uicontrol('Style','pushbutton', ...
           'String','Egde Color',...
           'Position',[315,70,70,25], ...
           'Callback', @MEC_Callback);
  HMFC  = uicontrol('Style','pushbutton', ...
           'String','Face Color',...
           'Position',[315,40,70,25], ...
           'Callback', @MFC_Callback); 
  OK    = uicontrol('Style','pushbutton', ...
           'String','OK',...
           'Position',[315,10,70,25], ...
           'Callback', 'uiresume(gcbf)');
   
  align([HType,HMS,HLW,HMEC,HMFC],'Center','None');
      
    
  plot(0, 0, T, 'MarkerSize', MS, 'LineWidth', LW, 'MarkerFaceColor', MFC, 'MarkerEdgeColor', MEC);
  axis('off');
  uiwait(gcf)
 
  close (HFig_marker)
  
  marker = {T, MS, LW, MEC, MFC}; % pack marker

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
      global T MS LW MEC MFC HMarker
      MEC = uisetcolor(HMarker, 'Set MarkerEdge Color');
      plot(0, 0, T, 'MarkerSize', MS, 'LineWidth', LW, 'MarkerFaceColor', MFC, 'MarkerEdgeColor', MEC); axis('off');
    end
    function C = MFC_Callback(source, eventdata) 
      global T MS LW MEC MFC HMarker
      MFC = uisetcolor(HMarker, 'Set MarkerFace Color');
      plot(0, 0, T, 'MarkerSize', MS, 'LineWidth', LW, 'MarkerFaceColor', MFC, 'MarkerEdgeColor', MEC); axis('off');
    end
