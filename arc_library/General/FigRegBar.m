function FigRegBar (Y, X, XP, DispError, BetIVLabels, WithinIVLabels, XLabel, YLabel, BarsWithin)
%Makes bar graphs (with or without error bars at discrete points)
%Accepts Y and X arrays.  X's should be centered appropriately for figure
%Can also import Y and X from data file with Ys in first columns
%If using auto importing data, input data file should have DV variables in first N columns
%
% INPUTS
% Y: Subjects x Number of DVs array 
% X: Subjects x Predictors. First column is Predictor to graph on X-axis.
% Predictor must be single df (quant or dichotomous)
%       All other predictors should be centered on appropriate values. 
% XP: Numeric array with points to graph (default for quant variable=3points -1.5sd mean
% 1.5sd' default for dichot variable is two levels).  
% DispError: Display Error Bars (Y)es or (N)o. 
% BetIVLabels: Cell array with IV condtion names. 
% WithinIVLabels: Cell array with DV condition names.
% XLabel: string labeling x-axis
% YLabel: string labeling y-axis
% BarsWithin: Bars represent within subject factor (Y)es or (N)o
%
% coded by John Curtin and Arielle Baskin-Sommers 
%
%NOTE: requires statistics toolbox.  see also FigBar. 

%revision history:
%2009-07-24: released v1
%2009-08-04, finalized, v2, JJC, ABS
%2009-08-04 displays values in command window for betas and standard errors
%graphed at each point. 

if nargin < 9
        Data = uiimport;
        NumConds = input ('How many Y Conditions?   ');
        Y = Data.data(:,1:NumConds);
        X = Data.data(:,NumConds+1:end);
        
        %Determine nature of X to graph (i.e., quant or dichot)
        if length(unique(X(:,1))) == 2
            XP = unique(X(:,1));
            NumGroups = 2;
        else
            XP = [mean(X(:,1))-1.5*std(X(:,1),1) mean(X(:,1)) mean(X(:,1))+1.5*std(X(:,1),1)]; %discrete points on X
            NumGroups = 3;
        end
        
        DispError = input('Display Errors? (Y)es or (N)o    ', 's');
        
        BetIVLabels = {num2str(XP(1)) num2str(XP(2)) num2str(XP(3))}; BetIVLabels = BetIVLabels(1:NumGroups);
        WithinIVLabels =  Data.textdata(1:NumConds);
        XLabel = 'X-axis';
        YLabel = 'Dependent measure (\muV)';
        BarsWithin = input ('Bars (vs. Clusters) represent Within Subject Factor? (Y)es or (N)o   ', 's'); 
else
    NumConds= size (Y,2);
end

DispError = upper(DispError); %checks input for DispError
if ~ (DispError == 'Y' || DispError == 'N')
   error ('DispError (%s) must be Y or N', DispError)
end

BarsWithin = upper(BarsWithin); %checks input for BarsWithin
if ~ (BarsWithin == 'Y' || BarsWithin == 'N')
    error ('BarsWithin (%s) must be Y or N', BarsWithin)
end    

NumXPs= length (XP);

YData= zeros (NumConds, NumXPs);
Errors = zeros (NumConds, NumXPs);

for i= 1:NumConds
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

if BarsWithin =='Y'  
    FigBar(YData', Errors', BetIVLabels, WithinIVLabels, XLabel, YLabel)
else 
   FigBar(YData, Errors, WithinIVLabels, BetIVLabels, XLabel, YLabel) 
end