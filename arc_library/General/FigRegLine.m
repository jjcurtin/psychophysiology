function FigRegLine (Y, X, XP, DispError, LineNames, XLabel, YLabel, LinesWithin)
%Makes line graphs (with or without error bars at discrete points)
%Accepts Y and X arrays.  X's should be centered appropriately for figure
%Can also import Y and X from data file with Ys in first columns
%
% INPUTS
% Y: Subjects x Number of DVs array 
% X: Subjects x Predictors. First column is Predictor to graph on X-axis.
% Predictor must be single df (quant or dichotomous)
%       All other predictors should be centered on appropriate values. 
% XP: Numeric array with points to graph (default=3points -1.5sd mean
% 1.5sd).  
% DispError: Display Error Bars (Y)es or (N)o. 
% LineNames: Cell array with DV condtion names. 
% XLabel: string labeling x-axis
% YLabel: string labeling y-axis
% LinesWithin: Lines represent within subject factor (Y)es or (N)o
%
% coded by John Curtin and Arielle Baskin-Sommers 
%
%NOTE: requires statistics toolbox.  see also FigLine. 

%revision history:
%2009-06-12: released v1
%2009-06-14: Line 37 was added to fix a bug if users did not enter any
%information
%2009-07-24 checks for input of LinesWitin added
%2009-08-04 displays values in command window for betas and standard errors
%graphed at each point. 

if nargin < 7
        Data = uiimport;
        NumYs = input('How many Y conditions?  ');
        Y = Data.data(:,1:NumYs);
        X = Data.data(:,NumYs+1:end);
        XP = [mean(X(:,1))-1.5*std(X(:,1),1) mean(X(:,1)) mean(X(:,1))+1.5*std(X(:,1),1)]; %discrete points on X
        DispError = input('Display Errors? (Y)es or (N)o    ', 's');
        LineNames = Data.textdata(1:NumYs);
        XLabel = 'X-axis';
        YLabel = 'Dependent measure';
        LinesWithin = input ('Lines represent Within Subject Factor? (Y)es or (N)o   ', 's'); %addded by arielle 06/14
else
    NumYs= size (Y,2);
end

DispError = upper(DispError); %checks input for DispError
if ~ (DispError == 'Y' || DispError == 'N')
   error ('DispError (%s) must be Y or N', DispError)
end

LinesWithin = upper(LinesWithin); %checks input for LinesWithin
if ~ (LinesWithin == 'Y' || LinesWithin == 'N')
    error ('LinesWithin (%s) must be Y or N', LinesWithin)
end   

NumXPs= length (XP);

YData= zeros (NumYs, NumXPs);
Errors = zeros (NumYs, NumXPs);

for i= 1:NumYs
     for j= 1:length(XP)
        XT = X; %X temp
        XT(:,1) = X(:,1) - XP(j); % center first column in X around XP
        stats = regstats(Y(:,i),XT,'linear', 'tstat');
        YData(i,j) = stats.tstat.beta(1,1); %B for intercept
        if DispError == 'Y'
            Errors(i,j) = stats.tstat.se(1,1); %SE for intercept
        else
            Errors(i,j) = 0;
        end
     end
end

display(YData)
display(Errors)

if LinesWithin =='Y'  
    FigLine(YData, Errors, XP, LineNames, XLabel, YLabel) 
else 
    XNames = cell(1,NumXPs);
    for i = 1:NumXPs
        XNames{i} = num2str(XP(i));
    end
    FigLine(YData', Errors', LineNames, XNames, XLabel, YLabel)
end    
