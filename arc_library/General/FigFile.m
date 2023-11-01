function [FigData] = FigFile(FigType, FileName)
%USAGE: FigFile(FigType, FileName)
%Version 2
%Creates either a bar (FigType=1; default) or line (FigType=2) graph based
%on data saved in a .mat file.  
%
%INPUTS
%FigType (optional) 1=bar (default); 2=line
%FileName: Filename and path (if not in current directory) for data file.  If not provided, will use uigetfile to locate
%Also uses FigBar, FigLine, & barweb
%See also FigInput
%coded by John Curtin, jjcurtin@wisc.edu

%Revision history
%2009-04-07:  Released, v1, JJC
%2009-06-10: Fixed bug with FigLine parameters, JJC, v2

if (nargin < 1) || isempty(FigType)
    FigType = 1;
end

if (nargin < 2) || isempty(FileName)
    %get  .mat filename and path
    [DataFN DataPath] = uigetfile('*.mat', 'Save data');  %default save in AzkPath
    if isequal(DataFN,0) || isequal(DataPath,0)
        warning('Data not saved!')
    else
        FileName = [DataPath DataFN];
    end
end

FigData = open(FileName);

%Make Graph
if FigType ==1
    FigBar(FigData.YData, FigData.Errors, FigData.GroupNames, FigData.CondNames, FigData.XLabel, FigData.YLabel)
else
    FigLine(FigData.YData, FigData.Errors, FigData.CondNames, FigData.GroupNames, FigData.XLabel, FigData.YLabel) 
end

