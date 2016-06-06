function shColorIndex

xlswrite('ColorIndex.xls', {'Index'},  'ColorIndex', 'A1'); % initiate file

%% Start Excel and tag file
txt_pwd = [pwd, '\']; % path to present directory that should contain file_name
excelObj = actxserver('Excel.Application'); %opens up an excel object
excelWorkbook = excelObj.workbooks.Open([txt_pwd, 'ColorIndex.xls']);

%% delete empty sheets 1, 2 and 3
excelObj.sheets.Item(1).Delete; 
excelObj.sheets.Item(1).Delete;
excelObj.sheets.Item(1).Delete;

%% colour cells
for i=1:56
  excelObj.sheets.Item('ColorIndex').Range(['A', num2str(i)]).Interior.ColorIndex = i;
end

%% close Excel
excelWorkbook.Save;
excelWorkbook.Close(false);
excelObj.Quit;
delete(excelObj);
