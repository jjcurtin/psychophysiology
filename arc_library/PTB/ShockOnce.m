function ShockOnce(Intensity, W, PortA, IOStatus)
%USAGE: ShockOnce(Intensity, W, PortA, UseIO)
%Administer a single shock of INTENSITY (0-255).  Can be used as stand alone script or embedded in PTB script
%If stand alone, no need to provide latter parameters.  Will use PortA.  
%If called within another PTB script, will
%administer shock on PortA with UseIO (True = enabled)
%using W = window pointer.

%Revision History
%2011-06-20, updated to use new hardward config and possible shock router

%% Timing parameters
PrepMsgDur =  3;  %Duration of preparation message
ShockMsgDur = .5;  %Shock is displayed on screen for .5s

try
    if nargin < 1
        help ShockOnce
        error('Must provide numeric Intensity (0-255) as argument to ShockOnce\n')
    end

    %% Set up PTB and IO Hardware if not already setup (i.e., if not called within PTB script with 4 arguments
    if nargin < 4
        %Setup PTB and IO hardware   
        AssertOpenGL;   %Check if PTB is properly installed on your system. 
        HideCursor;
        Priority(2); %Enable realtime-scheduling for real trial 

        WaitSecs(.001); GetSecs;   %Move into memory for later high precision use

        %Open Window and configure text options
        W = Screen('OpenWindow', 0, 0, [], 32, 2);
        Screen('TextFont',W, 'Times');
        Screen('TextSize',W, 32);      
        
        %IO card
        [DIO PortA PortB PortC  PortCLo, PortCHi, UseIO] = ConfigIO; %Set up DIO card (PortB=Neuroscan; PortA = Shocker)
        IOOut(PortA,0, UseIO) %set shock port to 0       
    end
        
    %% Shock admin code

    %Prepare for shock
    DrawFormattedText(W, ['Prepare for Shock Intensity = ' int2str(Intensity) ', in 3 seconds'], 'center', 'center', [255 255 255], 36)
    Screen('DrawingFinished', W);
    PrepMsgTime = Screen('Flip', W);  %Put up message quickly

    %Present shock msg & shock
    DrawFormattedText(W, 'Shock', 'center', 'center', [255 255 255], 36)
    Screen('DrawingFinished', W);    
    ShockMsgTime = Screen('Flip', W, PrepMsgTime + PrepMsgDur);  %put message up after prepmsgdur
    IOOut(PortA,Intensity, UseIO)  %shock IO
    WaitSecs(.010); 
    IOOut(PortA,0,UseIO) %clear port A after 10ms wait
    
    %Rate intensity
    %WaitSecs('UntilTime', ShockMsgTime+ShockMsgDur);
    RateString = Ask(W,'Please rate the shock intensity (0 - 100)',[255 255 255],[0 0 0],'GetString','center','center',36); % Accept keyboard input, but don't show it.
    Screen('Flip', W, ShockMsgTime+ShockMsgDur);

    if str2double (RateString) > 100
        RateString = Ask(W,'Error: Please reenter the shock intensity',[255 255 255],[0 0 0],'GetString','center','center',36); % Accept keyboard input, but don't show it.
        Screen('Flip', W);
    end

    %Show rating immediately after entered
    DrawFormattedText(W, ['Participant''s rating was ' RateString], 'center', 'center', [255 255 255], 36)
    Screen('DrawingFinished', W);       
    
    if nargin < 4   %function not called within other PTB script so close out
        clear DIO PortA PortB PortC PortCLo PortCHi UseIO
        Screen('CloseAll'); %Close display windows 
        Priority(0); %Shutdown realtime mode
        ShowCursor; %Show cursor again, if it has been disabled    
    end    

catch TheError
    clear DIO PortA PortB PortC PortCLo PortCHi UseIO  %remove IO
    Screen('CloseAll'); %Close display windows 
    Priority(0); %Exit real-time mode
    ShowCursor; %Show cursor again, if it has been disabled
    rethrow(TheError);        
end
