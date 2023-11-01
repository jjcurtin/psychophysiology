function FigBar(YData, Errors, ClusterNames, BarNames, XLabel, YLabel, Colors)
%USAGE: FigBar(YData, Errors, ClusterNames, BarNames, XLabel, YLabel, Colors)
%version 3
%bar graph with error bars
%
%INPUTS
%YData is Clusters X Bars (bars in clusters) array of cell means
%Errors is Clusters) X Bars (bars in clusters) array of cell SEs for error bars
%ClusterNames is a cell array of string names for each cluster of bars in order (i.e, first entry is for cluster in row 1)
%BarNames is a cell array of string names for each bar in order (i.e, first entry is for bar in column 1)
%XLabel is a string label for x-axis
%YLabel is a string label for y-axis
%Colors is a Bar X 3 array containing RGB triplets with each bar color in separate row
%Max four clusters.  Max five bars.
%Also uses barweb
%See also FigLine, FigInput, FigFile
%
%coded by John Curtin, jjcurtin@wisc.edu

%Revision history
%2009-04-07:  Released version 1, JJC
%2009-04-23:  fixed error with bar colors when Colors = [], JJC, v2
%2009-06-10:  updated names of vars and help, JJC, v3

%Check num arguments and set missing args to defaults
[NumGroups NumConds] = size(YData);
switch nargin
    case {0 1}
        error('Must supply at least the first two arguments:  YData and Errors')
    case 2
        ClusterNames = {'Group1' 'Group2' 'Group3' 'Group4'}; ClusterNames = ClusterNames(1:NumGroups);
        BarNames = {'Condition1' 'Condition2' 'Condition3' 'Condition4' 'Condition5'}; BarNames = BarNames(1:NumConds);
        XLabel = 'Condition';
        YLabel = 'Dependent Measure (\muV)';
        Colors = [0 0 1; 1 1 0; 1 0 0; 0 1 0; 0 1 1];  % blue, yellow, red, green
    case 3
        BarNames = {'Condition1' 'Condition2' 'Condition3' 'Condition4' 'Condition5'}; BarNames = BarNames(1:NumConds);
        XLabel = 'Condition';
        YLabel = 'Dependent Measure (\muV)';
        Colors = [0 0 1; 1 1 0; 1 0 0; 0 1 0; 0 1 1];  % blue, yellow, red, green
    case 4
        XLabel = 'Condition';
        YLabel = 'Dependent Measure (\muV)';
        Colors = [0 0 1; 1 1 0; 1 0 0; 0 1 0; 0 1 1];  % blue, yellow, red, green
    case 5
        YLabel = 'Dependent Measure (\muV)';
        Colors = [0 0 1; 1 1 0; 1 0 0; 0 1 0; 0 1 1];  % blue, yellow, red, green
    case 6
        Colors = [0 0 1; 1 1 0; 1 0 0; 0 1 0; 0 1 1];  % blue, yellow, red, green
end

%Check if [] assigned to args and set to default
if isempty(ClusterNames)
    ClusterNames = {'Group1' 'Group2' 'Group3' 'Group4'}; ClusterNames = ClusterNames(1:NumGroups);
end
if isempty(BarNames)
    BarNames = {'Condition1' 'Condition2' 'Condition3' 'Condition4' 'Condition5'}; BarNames = BarNames(1:NumConds);
end
if isempty(XLabel)
    XLabel = 'Condition';
end
if isempty(YLabel)
    YLabel = 'Dependent Measure (\muV)';
end
if isempty(Colors)
    Colors = [0 0 1; 1 1 0; 1 0 0; 0 1 0; 0 1 1];  % blue, yellow, red, green
end


H = barweb(YData,Errors,[],ClusterNames,[],XLabel, YLabel,[],[]);  %Uses custom barweb to make bar graph with error bars

%Format axes
set(H.ca, 'LineWidth',3, 'FontWeight','bold', 'FontSize',20, 'FontName','Arial', 'TickDir', 'out', 'LineWidth',3);
set (H.xlabel, 'FontWeight','bold', 'FontSize',24, 'FontName','Arial')
set (H.ylabel, 'FontWeight','bold', 'FontSize',20, 'FontName','Arial')

%Format individual bars
for i=1:NumConds
    set(H.bars(i),'FaceColor',Colors(i,:),'DisplayName',BarNames{i}, 'LineWidth', 3);
    set(H.errors(i),'LineWidth', 3);
end

%Format legend
Leg = legend(BarNames);
set(Leg,'LineWidth',3,'FontWeight','bold','FontSize',24, 'FontName','Arial');
