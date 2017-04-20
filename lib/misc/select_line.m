%% select_line
% graphical user interface for setting line

%%
function line = select_line(line)
%% created 2017/04/29 by Bas Kooijman

%% Syntax
% line = <../select_line.m *select_line*> (line)

%% Description
% Selects type, linewidth, color of a line
%
% Input:
%
% * line: optional 3-vector of cells with type, linewidth, color of a line
%
% Output: 
% 
% * marker: 3-vector of cells with type, linewidth, color of a line
%
%% Remarks
% Press OK when done

%% Example of use
% line = select_line;

  global T LW LC  HLine
  
  if exist('line', 'var')
    % unpack line
    T = line{1}; LW = line{2}; LC = line{3}; 
  else % assign default marker specification
    T = '-'; LW = 4; LC = 'b'; 
  end
  
  HFig_line = figure('Position', [300, 300, 400, 200]);

  % Components
  HType = uicontrol('Style','pushbutton',...
           'String', 'Type',...
           'Position',[315,130,70,25], ...
           'Callback', @Type_Callback);
  HLW   = uicontrol('Style','pushbutton',...
           'String', 'Line Width', ...
           'Position',[315,100,70,25], ...
           'Callback', @LW_Callback);    
  HLC   = uicontrol('Style','pushbutton', ...
           'String','Line Color',...
           'Position',[315,70,70,25], ...
           'Callback', @LC_Callback);
  OK    = uicontrol('Style','pushbutton', ...
           'String','OK',...
           'Position',[315,40,70,25], ...
           'Callback', 'uiresume(gcbf)');
   
  align([HType,HLW,HLC],'Center','None');
      
    
  plot([-1 1], [0 0], T, 'LineWidth', LW, 'Color', LC);
  axis('off');
  uiwait(gcf)
 
  close (HFig_line)
  line = {T; LW; LC}; % pack line
end

%% subfunctions
    function C = Type_Callback(source, eventdata) 
      global T LW LC
      list = {'-','--',':','-.'};
      i = 1:length(list); i = i(strcmp(list, T));
      T = list(listdlg('PromptString', 'Select Type', 'ListString', list, 'Selectionmode', 'single', 'InitialValue', i));
      T = T{1}; 
      plot([-1 1], [0 0], T, 'LineWidth', LW, 'Color', LC); axis('off');
    end
    function C = LW_Callback(source, eventdata) 
      global T LW LC
      list = {num2str((1:20)')};
      LW = listdlg('PromptString', 'Select Type', 'ListString', list, 'Selectionmode', 'single', 'InitialValue', LW);
      plot([-1 1], [0 0], T, 'LineWidth', LW, 'Color', LC); axis('off');
    end
    function C = LC_Callback(source, eventdata) 
      global T LW LC HLine
      LC = uisetcolor(HLine, 'Set Line Color');
      plot([-1 1], [0 0], T, 'LineWidth', LW, 'Color', LC); axis('off');
    end
