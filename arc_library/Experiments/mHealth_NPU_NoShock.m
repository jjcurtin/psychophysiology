function mHealth_NPU_NoShock
%mHealth NPU No Shock Shock Block
%JTK & KM

try
    %% Set up DIO card (PortA = Button Box; PortB =event codes to neuroscan; PortC = shock)
    [DIO PortA PortB PortC UseIO] = ConfigIO;   %Includes base address for left lab (A input, B and C Output
    
    %% Define all Trial Parameters
    NumTrials = 6;
    
    %Cue info
    CueDur = 5;   %Cues presented for 5s
    
    %10 = NS, 20 = P, 30 = U
    CueTypes(1,:) = [10 10 10 10 10 10]; 

    %ITI duration info
    I1 = 14; % 14 sec
    I2 = 17; % 17 sec
    I3 = 20; % 20 sec
    ITIDurs(1,:) = [I3 I2 I2 I1 I3 I1]; 

    %Cue shock array
    CueShockTime(1,:)=[0 0 0 0 0 0]; 
    
    %ITI shock array
    ITIShockTime(1,:)=[0 0 0 0 0 0]; 
    
    %Event codes
    ShockEvent = 1;
        
    ShockIntensity = 11; % manually set shock intensity 
    
    %% START SCREEN
    AssertOpenGL;   %Check if PTB is properly installed on your system.
    W = Screen('OpenWindow', 0, 0, [], 32, 2); %Open Window and configure text options
    Screen('TextSize',W, 36); %36 pt font
    Screen('TextFont',W, 'Calibri'); % Calibri font default
    HideCursor;
    TxtColor = [255 255 255]; %Set to White
    BackColor = [0 0 0]; %Set to Black
    
    %load into memory for later high time precision use
    WaitSecs(.1);
    GetSecs;
    KbCheck;
    
    %% Preparing all images
    RootPath = fileparts(which('mHealth_NPU_NoShock.m'));
    FileType = 'JPG';
     
    %Cues stored in cell array (CueImg) or (ITIImg as question (1=no question) X CueType (1)
    CueImg = cell(1,1);
    CueImg{1,1} =  imread([RootPath '/mHealth/NPU/CueN.JPG'], FileType);
    CueTextures = zeros(1,1);
    for i = 1:1
        for j = 1:1
            CueTextures(i,j) = Screen('MakeTexture', W, CueImg{i,j});
        end
    end
    clear CueImg
    
    %ITI image
    ITIImg = cell(1,1);
    ITIImg{1,1} =  imread([RootPath '/mHealth/NPU/ITIN.JPG'], FileType);
    ITITextures = zeros(1,1);
    for i = 1:1
        for j = 1:1
            ITITextures(i,j) = Screen('MakeTexture', W, ITIImg{i,j});
        end
    end
    clear ITIImg
    
    %ITI Fixation Cross for habituation period
    ITIFixImg =  imread([RootPath '/mHealth/FixationCross.JPG'], 'JPG');
    ITIFixTexture = Screen('MakeTexture', W, ITIFixImg);
    clear ITIFixImg
    
    %Black screen for block transitions
    BlackImg =  imread([RootPath '/mHealth/BlackImage.JPG'], 'JPG');
    BlackTexture = Screen('MakeTexture', W, BlackImg);
    clear BlackImg
    
    %% Prep Task
    Priority(2); %Enable realtime-scheduling for real trial
    PauseMsg(W,'Turn the box to READY\n\nStart recording physiology NOW\n\nPress space bar to begin task', TxtColor, BackColor, ITIFixTexture, 0); 
    
    %% Start First Block
    switch CueTypes(1,1)
        case{10}
            WaitMsg(W, 'No Shocks', 9, TxtColor, BackColor)
            Screen('DrawTexture', W, ITITextures(1,1));
    end
    Screen('DrawingFinished', W); %to mark the end of all drawing commands
    ITIStartTime = Screen('Flip', W); %Present ITIFixImg as soon as possible
        
    %% TRIAL LOOP
       %Prepare Cue
    for i=1:NumTrials  %loop for stimulus presentation;   TRIAL = (1) ITI, (2) CUE

        switch CueTypes(1,i)
            case {10};
                Screen('DrawTexture', W, CueTextures(1,1));
        end
        Screen('DrawingFinished', W);
        
        %Check/Present ITI SHOCK
        if (ITIShockTime(1,i)>0)
            WaitSecs('UntilTime', ITIStartTime+ITIShockTime(1,i));
            Shock(DIO,PortC,ShockIntensity, PortB, ShockEvent, UseIO)
        end
        
        %CUE PERIOD
        CueStartTime= Screen('Flip', W, ITIStartTime + ITIDurs(1,i));
        MarkEvent(DIO, PortB, CueTypes(1,i), UseIO)
        
        %Check/Present SHOCK
        if (CueShockTime(1,i) > 0)
            WaitSecs('UntilTime', CueStartTime+CueShockTime(1,i));
            Shock(DIO,PortC,ShockIntensity, PortB, ShockEvent, UseIO)
        end
        
        switch i  %Wrap up after last trial
            case{6}  
                WaitMsg(W, 'Thank you. Task Complete!', 4, [], [], BlackTexture, CueStartTime + CueDur )
                PauseMsg(W,'Turn box to STANDBY\n\nStop recording physiology NOW!\n\nPress space bar to end task.',[], [], BlackTexture, 0);
                
            otherwise
                %Prepare ITI for Trial i+1 (next trial)
                
                switch CueTypes(1,i+1)
                    case {10}
                        Screen('DrawTexture', W, ITITextures(1,1))
                end
                Screen('DrawingFinished', W);
                
                ITIStartTime = Screen('Flip', W, CueStartTime + CueDur);
        end
    end
 %% POST TASK ISSUES TO CLOSE PTB
    Screen('CloseAll'); %Close onscreen and offscreen windows and textures
    Priority(0); %Shutdown realtime mode
    clear mex  %clear io32()
    ShowCursor; %Show cursor again, if it has been disabled    

    
    catch TheError
        
    Screen('CloseAll'); %Close display windows
    ShowCursor; %Show cursor again, if it has been disabled
    Priority(0); %Shutdown realtime mode
    clear mex  %clear io32()
     
    rethrow(TheError);
end

end