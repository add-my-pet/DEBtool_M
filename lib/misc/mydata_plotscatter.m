  %% mydata_plotscatter
  
  close all
  
  % compose points to plot
  n = 1000; xy = normrnd(0,1,n,2);
  
  % compose marker specs
  T = blanks(n)'; T(:) = '.'; T = cellstr(T);       % (n,1)-array of cells with MarkerType
  MS = num2cell(15*ones(n,1));                      % (n,1)-array of cells with MarkerSize
  LW = MS;                                          % (n,1)-array of cells with LineWidth
  MEC = num2cell(real2color(normrnd(0,1,n,1))',1)'; % (n,1)-array of cells with MarkerEdgeColor
  MFC = MEC;                                        % (n,1)-array of cells with MarkerFaceColor
  
  Mspec = cell(n,1); % initiate marker specs 
  for i = 1:n
    Mspec{i} = [T(i), MS(i), LW(i), MEC(i), MFC(i)]; 
  end 
  
  plotscatter(xy, Mspec);
  
  % Another example: get marker specs for legend
  %
  % M = legend_RSED; plotscatter([ones(9,1), (1:9)'], M(:,1))
