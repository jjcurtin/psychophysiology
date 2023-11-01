function FigInput(FigType)
%USAGE: FigInput(FigType)
%Version 2
%Prompts user for all input to make either bar (FigType=1; default) or line (FigType=2) graph.
%Also saves a *.mat file with all relevant input.  This file can later be
%used with FigFile to reproduce the same figure
%
%INPUTS
%FigType (optional) 1=bar (default); 2=line
%Also uses FigBar, FigLine, & barweb
%See also FigFile
%coded by John Curtin, jjcurtin@wisc.edu

%Revision history
%2009-04-07:  Released, v1, JJC
%2009-06-10:  updated for use with newer FigBar and FigLine, JJC, v2

if (nargin < 1) || isempty (FigType)
    FigType =1;
end

%Get number of groups (Clusters/Lines) and names
NGroups = input('Number of Clusters/Lines:  ');
if NGroups > 4
    error('Max of 4 Clusters/Lines supported')
end
GroupNames = cell(NGroups,1);
for i=1:NGroups
    InMsg = sprintf('Enter Name for Group %0.0f:  ',i);
    GroupNames{i}= input(InMsg,'s');
end

%Get number of conditions (Bars/Points) and names
NConds = input('\nNumber of Conditions:  ');
if NConds > 5
    error('Max of 5 Bars/Lines supported (NOTE: Can use more points directly with FigLine)')
end
CondNames = cell(NConds,1);
for i=1:NConds
    InMsg = sprintf('Enter Name for Condition %0.0f:  ',i);
    CondNames{i}= input(InMsg,'s');
end

%Enter Means and SEs
YData = zeros(NGroups,NConds);
Errors = zeros(NGroups,NConds);
for i=1:NGroups
    for j=1:NConds
        InMsg = sprintf('\nEnter Mean for Group: %s; Condition: %s    ',GroupNames{i},CondNames{j});
        YData(i,j)= input(InMsg);
        InMsg = sprintf('Enter SE for Group: %s; Condition: %s    ',GroupNames{i},CondNames{j});
        Errors(i,j)= input(InMsg);
    end
end

XLabel = input ('\nLabel for X-axis: ','s');
YLabel = input ('Label for Y-axis: ','s');

%Save relevant data
[DataFN DataPath] = uiputfile('*.mat', 'Save data');  %default save in AzkPath
if isequal(DataFN,0) || isequal(DataPath,0)
    warning('Data not saved!')
end
datafile = [DataPath DataFN];
save(datafile, 'YData', 'Errors', 'GroupNames', 'CondNames', 'XLabel', 'YLabel');

%Make Graph
if FigType ==1
    FigBar(YData, Errors, GroupNames, CondNames, XLabel, YLabel)
else
    FigLine(YData, Errors, CondNames, GroupNames,  XLabel, YLabel) 
end

