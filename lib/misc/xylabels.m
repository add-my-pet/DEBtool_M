function txt = xylabels(obj, event_obj, labels, xy)
    % created 2016/04/07 by Laure Pecquerie & Bas Kooijman
    
    %% Syntax
    % txt = <xylabels.m *xylabels*> (obj, event_obj, labels, xy)
    
    %% Description:
    % callback function for datacursormode: mouse clicks on figures to show labels that are associated to points in the plot
    %
    % Input:
    %
    % * obj: handle to object generating the callback (not used)
    % * event_obj: handle to event object
    % * labels: n-cell vector with names of entries
    % * xy: (n,2)-matrix with point coordinates
    %
    % Output:
    %
    % * txt: string with entries name
    
    %% Example of use
    % fig = figure;
    % plot(xy(:,1), xy(:,2), '.k', 'MarkerSize', 20);
    % set(gca, 'FontSize', 15, 'Box', 'on');
    % xlabel('label x');  
    % ylabel('label y');
    % h = datacursormode(fig);
    % h.UpdateFcn = @(obj, event_obj)xylabels(obj, event_obj, labels, xy);
    % h.SnapToDataVertex = 'on';
    % datacursormode on 

    
    pos = event_obj.Position;                       % position of mouse-click
    n = size(xy,1);                                 % number of points
    [x i] = min(sum((xy - pos(ones(n,1),:)).^2,2)); % minimum squared distance
    txt = labels{i};                                % string with label
end
