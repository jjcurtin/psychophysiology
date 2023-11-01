function FigERPLine(YData, Times, LineNames, YLabel)
%USAGE: FigERPLine(YData, Times, LineNames, YLabel)
%version 1
%ERLine graph with error bars at discrete points on line
%
%INPUTS
%YData is Time x Points (on DV) array
%Times is a numeric column vector with X values (default if not provided 1:Cols of YData)
%LineNames is a Cell arry with DV condition names
%YLabel is a string label for y-axis (Dependent Measure)

%Max six lines (only 4 line style options).
%See also FigLine, FigInput, FigFile
%
%coded by John Curtin and Arielle Baskin-Sommers
    %contact: jjcurtin@wisc.edu

%Revision history
%2009-08-04:  Released version 1

%Check if [] assigned to args and set to default
if isempty(LineNames)
    LineNames = {'Cond1' 'Cond2' 'Cond3' 'Cond4' 'Cond5' 'Cond6'}; LineNames = LineNames(1:size(YData,2));
end

if isempty(Times)
    Times = 1:size(YData,1);
end

if isempty(YLabel)
    YLabel = 'Dependent Measure (\muV)';
end

fig1 = figure;
axes1 = axes('Parent',fig1,'FontName','Arial','FontWeight','bold','FontSize',20); %format axes
hold('on')

ERPPlot = plot(Times,YData); %plots Time x Condition
xlabel('Time','FontSize',24,'FontName','Arial','FontWeight','bold'); %format x label (Time)
ylabel(YLabel,'FontSize',20,'FontName','Arial', 'FontWeight','bold');%format y label (DV)

%Format legend
Leg = legend(LineNames);
set(Leg,'LineWidth',3,'FontWeight','bold','FontSize',24, 'FontName','Arial');

%Format individual line colors and markers
for i =1:length(LineNames)
    switch(i)
        case 1
            set(ERPPlot(1),'LineStyle','-','LineWidth', 3 );
        case 2
            set(ERPPlot(2),'LineStyle','--','LineWidth', 3 );
        case 3
            set(ERPPlot(3),'LineStyle',':','LineWidth', 3 );
        case 4
            set(ERPPlot(4),'LineStyle','-.','LineWidth', 3 );
    end
end
hold('off')



