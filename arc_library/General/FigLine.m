function FigLine(YData, Errors, Xs, LineNames, XLabel, YLabel, Colors)
%USAGE: FigLine(YData, Errors, Xs, LineNames, XLabel, YLabel, Colors)
%version 2
%Line graph with error bars at discrete points on line
%
%INPUTS
%YData is Lines X Points (X-axis) array of cell means
%Errors is Lines X Points (X-axis) array of cell SEs for error bars
%Xs is either a numeric row vector with X values (default if not provided 1:Cols of YData) or
%   a cell array of string names for each condition in order.
%LineNames is a cell array of string names for each line in order (i.e,
%first entry is for line in row 1)
%XLabel is a string label for x-axis
%YLabel is a string label for y-axis
%Colors is a Lines X 3 array containing RGB triplets with each line color in separate row
%Max four lines.
%See also FigBar, FigInput, FigFile
%
%coded by John Curtin, jjcurtin@wisc.edu

%Revision history
%2009-04-07:  Released version 1, JJC
%2009-06-07:  Major update to include x values and new help

%Check num args and set missing args to defaults
[NumGroups NumXs] = size(YData);
switch nargin
    case {0 1}
        error('Must supply at least the first two arguments:  YData and Errors')
    case 2
        Xs = 1:NumXs;
        LineNames = {'Group1' 'Group2' 'Group3' 'Group4'}; LineNames = LineNames(1:NumGroups);
        XLabel = 'X-Axis Label';
        YLabel = 'Dependent Measure (\muV)';
        Colors = [0 0 1; 1 1 0; 1 0 0; 0 1 0];  % blue, yellow, red, green
    case 3
        LineNames = {'Group1' 'Group2' 'Group3' 'Group4'}; LineNames = LineNames(1:NumGroups);
        XLabel = 'X-Axis Label';
        YLabel = 'Dependent Measure (\muV)';
        Colors = [0 0 1; 1 1 0; 1 0 0; 0 1 0];  % blue, yellow, red, green
    case 4
        XLabel = 'X-Axis Label';
        YLabel = 'Dependent Measure (\muV)';
        Colors = [0 0 1; 1 1 0; 1 0 0; 0 1 0];  % blue, yellow, red, green
    case 5
        YLabel = 'Dependent Measure (\muV)';
        Colors = [0 0 1; 1 1 0; 1 0 0; 0 1 0];  % blue, yellow, red, green
    case 6
        Colors = [0 0 1; 1 1 0; 1 0 0; 0 1 0];  % blue, yellow, red, green
end

%Check if [] assigned to args and set to default
if isempty(LineNames)
    LineNames = {'Group1' 'Group2' 'Group3' 'Group4'}; LineNames = LineNames(1:NumGroups);
end
if isempty(Xs)
    Xs = 1:NumXs;
end
if isempty(XLabel)
    XLabel = 'X-Axis Label';
end
if isempty(YLabel)
    YLabel = 'Dependent Measure (\muV)';
end
if isempty(Colors)
    Colors = [0 0 1; 1 1 0; 1 0 0; 0 1 0];  % blue, yellow, red, green
end

%Check if Xs contains condition names
if iscell(Xs)
    CondNames = Xs;
    Xs = 1:NumXs;
else
    CondNames = cell(1,NumXs);
    for i =1:NumXs
        CondNames{i} = num2str(Xs(i));
    end
end
   
TheFig = figure;

%Format the axes
TheAxes = axes('Parent',TheFig,'XTickLabel',CondNames,'XTick',Xs,'FontWeight','bold','FontSize',20,'FontName','Arial','TickDir', 'out','LineWidth',3);
xlim([min(Xs)-.25 max(Xs)+.25]);
xlabel(XLabel,'FontSize',24,'FontName','Arial','FontWeight','bold');
ylabel(YLabel,'FontSize',20,'FontName','Arial', 'FontWeight','bold');

%Plot ErrorBar on these axes
hold('on');
EB = errorbar(repmat(Xs,NumGroups,1)', YData',Errors');

%Format legend
Leg = legend(LineNames);
set(Leg,'LineWidth',3,'FontWeight','bold','FontSize',24, 'FontName','Arial');

%Format general line settings
set(EB(:), 'MarkerSize',14, 'LineWidth',3)

%Format individual line colors and markers
for i =1:NumGroups
    switch i
        case 1
            set(EB(1),'Marker','square', 'LineStyle','-','Color',Colors(1,:), 'MarkerFaceColor', Colors(1,:) );
        case 2
            set(EB(2),'Marker','o', 'LineStyle','--','Color',Colors(2,:), 'MarkerFaceColor', Colors(2,:));
        case 3
            set(EB(3),'Marker','diamond', 'LineStyle',':','Color',Colors(3,:), 'MarkerFaceColor', Colors(3,:));
    end
end
hold('off');


