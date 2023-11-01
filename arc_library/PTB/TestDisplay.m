%Usage: [Stats] = TestDisplay ([FlipFrames=20], Analyze=true, SMA=true)
%This script performs 100 white screen presentations, each separated by
%FlipFrames (default = 20) refresh intervals.  If Analyze is true, will
%make figure to deterime if onset is consistent across trials.
%If SMA is true, assumes photoresistor brought in on channel 7. 
%At end, script reports:
%1.  Expected ITI (i.e., FlipFrames * refresh interval) in seconds
%2.  Mean ITI across 100 trials
%3.  SD of ITI across 100 trials
%4.  Number of missed deadlines
%Each white screen onset is marked with an event code (1). If screen flip 
%onset is detected with photoresistor, you can verify that event code is
%time-locked to screen flip.
%Stats contains [vbl, sot, ft, missed] from Screen Flip command for each trial

%Revision History
%2008-12-02: released version 1, JJC
%2008-12-13: renamed to TestDisplay, JJC
%2010-04-21: cosmetic updates and commenting, JJC
%2010-05-18: added analyze functions, JJC
%2011-12-11: added "Analyze" as an input paramter, DB. 
%2011-12-11: moved 'clear all' to end to avoid clearing input variables. DB
%2011-12-13; modified to allow testing with snapmaster (piperlab). 
%2012-12-18; modified to improve automatic display of waveform. Commented out code query to datatype and replaced with autodetect. DEB, KPM, RAK
%2013-7-22; added label to x axis of plot. DB 
function [Stats] = TestDisplay(FlipFrames,Analyze,SMA,Grael)

try
    AssertOpenGL;   %Check if PTB is properly installed on your system. 
    HideCursor;
    
    if nargin < 1
        FlipFrames = 20;  %set default # of FlipFrames if not provided
        Analyze = true;
        SMA = true;
        Grael = false;
    end
    
    if nargin < 2
        Analyze = true;
        SMA = false;
        Grael = false;
    end
        
    if nargin < 3 
        SMA = false;
        Grael = false;
    end   

    if nargin < 4
        Grael = false;
    end   

    TotTrials = 100;
    Stats = zeros(100,4);
    
    [DIO, PortA, PortB, PortC] = ConfigIO; %Set up DIO card
    HoldValue = 0;  %Hold value for our NS setup
    IOOut(DIO,PortB,HoldValue);
%    io32(DIO,PortB,HoldValue); %OLD FOR WINDOWS ONLY
    
    %Open Window and configure text options
    W = Screen('OpenWindow', 0, 0, [], 32, 2); 
    Screen('TextFont',W, 'Courier New');
    Screen('TextSize',W, 50);
    Screen('TextStyle', W, 1+2);  %Bold & Italics

    Priority(2); %Enable realtime-scheduling 
    ifi = Screen('GetFlipInterval', W, 200);  %get ifi

    %DISPLAY START SCREEN
    Screen('FillRect', W, [0 0 0]);
    Screen('DrawingFinished', W);
    Screen('Flip', W);
    PauseMsg(W, 'Press ANY Key to \n\nSTART Screen Test')
    
    %Set screen to black
     Screen('FillRect', W, [0 0 0]);
     Screen('DrawingFinished', W); %to mark the End of all drawing commands 
     [vbl sot ft missed] = Screen('Flip', W);
    

    for i = 1:TotTrials
        %Prepare White Screen
        Screen('FillRect', W, [255 255 255]);
        Screen('DrawingFinished', W); 
        [vbl sot ft missed] = Screen('Flip', W, vbl + (FlipFrames - 0.5)*ifi); %present white screen FlipFrames after onset of trial
        IOOut(DIO,PortB,1);WaitSecs(.005);IOOut(DIO,PortB,HoldValue) %send event code to mark white screen onset
        %io32(DIO,PortB,1);WaitSecs(.005);io32(DIO,PortB,HoldValue) %send event code to mark white screen onset  % OLD FOR WINDOWS ONLY
        Stats(i,:) = [vbl sot ft missed];  %record info for this trial

        %Prepare Black Screen
        Screen('FillRect', W, [0 0 0]);
        Screen('DrawingFinished', W); 
        Screen('Flip', W, vbl + (FlipFrames/2 - 0.5)*ifi);  %present black screen after 1/2 of FlipFrames interval
    end
    
    %Calc mean and SD of interval between white screens
    ITI = FlipFrames * ifi;  %This is the expected time between White Screens
    ObsITIs = zeros(TotTrials-1,1);
    for i= 1:TotTrials-1
        ObsITIs(i) = Stats(i+1,1) - Stats(i,1);
    end
    MeanITI = mean(ObsITIs);
    SDITI = std(ObsITIs);
        
    %DISPLAY END SCREEN
    Output = sprintf('Expected ITI: %07.5f\n\nMean Observed ITI: %07.5f\n\nSD Observed ITI: %07.5f\n\nMissed Deadlines: %1.0f\n\n\nPress ANY key to END',ITI, MeanITI, SDITI,length(find(Stats(:,4)>0)));
    PauseMsg(W, Output) 
    
    Screen('CloseAll'); %Close display windows 
    Priority(0); %Shutdown realtime mode
    ShowCursor;
    
catch TheError
    Screen('CloseAll'); %Close display windows 
    Priority(0); %Shutdown realtime mode
    ShowCursor; %Show cursor again, if it has been disabled
    rethrow(TheError)
end

if (Analyze)&& ~ (SMA) && ~(Grael)
    [FileName FilePath] = uigetfile('*.cnt', 'Open data file');  %get file name and path
    %DataType = str2double(input('\Enter Data Type (16 or 32):  ', 's'));  %get file data type
    EEG = pop_loadcnt([FilePath FileName], 'dataformat', 'auto');
    %open file
    %if DataType == 16
        %EEG = pop_loadcnt([FilePath FileName], 'dataformat', 'int16');
    %else
        %EEG = pop_loadcnt([FilePath FileName], 'dataformat', 'int32');
    %end
end

if (Analyze) && (SMA)&& ~(Grael)
       [FileName FilePath] = uigetfile('*.sma', 'Open data file');  %get file name and path
       EEG = pop_LoadSma([FileName,FilePath,400]);
     
end 

if (Analyze)&& ~(SMA) && (Grael)
       [FileName FilePath] = uigetfile('*.dat', 'Open data file');  %get file name and path
       EEG = pop_loadcurry([FilePath,FileName]);
     
end 
    
    EEG = pop_epoch(EEG, {'1'}, [-.1 .25], 'newname', 'Epoches', 'epochinfo', 'yes');  %epoch file
    EEG = pop_rmbase( EEG, [-20   0]);  %baseline correct
    if (SMA)
        EEG = pop_select( EEG, 'channel',7);  %select 7 channel (Snapmaster)
    elseif (Grael)
        EEG = pop_select( EEG, 'channel',{ 'ORB'}); %select ORB channel (Curry)
    else        
        EEG = pop_select( EEG, 'channel',{ 'VPRB'});  %select BP32 channel (NEUROSCAN)
    end
    EEGPlot = squeeze(EEG.data);  %remove singleton dimension
    plot(EEG.times,EEGPlot)   %make plot    
    xlabel('Time (ms)')


fprintf('\nTestDisplay Complete\n');
clear mex    
end %ScreenTest


