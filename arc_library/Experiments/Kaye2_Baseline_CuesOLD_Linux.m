function Kaye2_Baseline
%SubID = ABCDE
%A = Sequence (1 = Control group real sub, 9 = training)
%B = Sex (0=Female;1=Male)
%C = Version (usually called script order- refers to trial/probe structure in task)
%D = SubID
%E = SubID
%
%Day = 1 or 2

%Kaye2 baseline task
%JTK

%% Generate Startle Probe Presentation Time
SubID = input('Enter SubID (4 or 5 digits)\n', 's'); %RA input SubID as str
Day = input('Enter Day (1 or 2)\n'); %RA input Day as double
Training = input('Enter Training (y or n)\n', 's'); %RA input Training as str

%% Check that the appropriate time/day baseline task is being run
%Create Path to Local Directory on Computer
RootPath = fileparts(which('Kaye2_Baseline.m'));

%% To Do
%Add FileName check that this is correct SubID/Day, training, etc

try
    %% Set up DIO card
    %PortA = Shock Box; PortB = Event Codes to Grael/Curry; PortC = Input
    [DIO, PortA, PortB, PortC, UseIO] = ConfigIOLinux;
    EventPort = PortB;
    
    %% Define all Trial Parameters
    NumTrials = 9;    
    
    %Cue info
    CueDur = 5; %Cues presented for 5s
    %10 = Green cue, 20 = Red cue, 30 = Blue cue
    CueTypes = [10 30 20 20 30 20 10 30 10]; %Baseline cues
    
    %Cue probe info (present acoustic startle probe)
    %0 = No Cue Probe; 1 = Yes Cue Probe
    CueProbeTime = 4.5; %Time for probe during cue (4.5sec post-cue onset)
    CueProbes = [1 1 0 1 0 1 0 1 1];
    
    %ITI probe info (present acoustic startle probe)
    EI = 13; %time (sec) for early probe during ITI
    MI = 14; %time (sec) for early probe during ITI
    LI = 15; %time (sec) for early probe during ITI
    ITIProbeTime = [0 0 LI 0 EI 0 MI 0 0];
    
    %ITI duration info
    I1 = 14; %14 sec
    I2 = 17; %17 sec
    I3 = 20; %20 sec
    ITIDurs = [I1 I2 I3 I1 I2 I2 I3 I3 I1];

    %Event Codes
    HabitSTLEvent = 100; %Habituation event code (trial 1-3)
        
    %Cue startle probe event codes: 141
    CueSTLEvents = CueTypes + 100; %A = 1 (probe), %B= 1-3(green,red,blue)
    CueSTLEvents(CueProbes==0) = 0; %no startle on cue
    CueSTLEvents(CueProbes==1) = CueSTLEvents(CueProbes==1)+1; %C= 1(cue startle probe)
    
    %ITI startle probe event codes: 140
    ITISTLEvents = CueTypes + 100; %A = 1 (probe), %B= 1-3(green,red,blue)
    ITISTLEvents(ITIProbeTime==0) = 0;%no startle on cue
    
    %% Load Startle Probe
    InitializePsychSound(1);  %1=set for low-latency
    [y] = psychwavread('wnprobe.wav');  %updated from wavread, Matlab2015b not backward compatible
    Noise = y';
    modePlay = 1; %audio play back only
    freq = 44100; %a frequency of 44100 Hz
    reqlatencyclassPlay = 2; %for low latency (agressive but consider 3)
    nchannels = 2; %2 sound channels for stereo capture
    PsychPortAudio('Verbosity', 10);
    SoundCardPlay = PsychPortAudio('Open', [], modePlay, reqlatencyclassPlay, freq, nchannels);  %This returns a handle to the audio device. Open sound card in play back mode.
    PsychPortAudio('FillBuffer', SoundCardPlay, Noise);
    
    %% START SCREEN
    AssertOpenGL;   %Check if PTB is properly installed on your system.
    W = Screen('OpenWindow', 0, 0, [], 32, 2);  %Open Window and configure text options
    HideCursor(W); %On Linux include W screen pointer, and call after first call of screen
    Screen('TextFont',W, 'Calibri'); % Calibri font default
    Screen('TextSize',W, 36); %36 pt font
    TxtColor = [255 255 255]; %Set to White
    BackColor = [0 0 0]; %Set to Black
    
    %load into memory for later high time precision use
    WaitSecs(.1);
    GetSecs;
    KbCheck;
    
    %% LOAD IMAGE FILES
    FileType = 'JPG';
    
    %Cues stored in cell array (CueImg) CueType (1-3) --Consider removing
    %cell array structure since simplified from NPU
    CueImg = cell(1,3);
    CueImg{1,1} =  imread([RootPath '/Kaye2/Baseline/CueGreen_960x540.JPG'], FileType);
    CueImg{1,2} =  imread([RootPath '/Kaye2/Baseline/CueRed_960x540.JPG'], FileType);
    CueImg{1,3} =  imread([RootPath '/Kaye2/Baseline/CueBlue_960x540.JPG'], FileType);
    CueTextures = zeros(1,3);
    for i = 1:3
        CueTextures(1,i) = Screen('MakeTexture', W, CueImg{1,i});
    end
    clear CueImg
    
    FixationImg =  imread([RootPath '/Kaye2/FixationCross_960x540.JPG'], 'JPG');
    FixTexture = Screen('MakeTexture', W, FixationImg);
    clear FixationImg
    
    %Black screen for block transitions
    BlackImg =  imread([RootPath '/Kaye2/BlackImage.JPG'], 'JPG');
    BlackTexture = Screen('MakeTexture', W, BlackImg);
    clear BlackImg
    
    %% Prep Task
    Priority(2); %Enable realtime-scheduling for real trial
    HabitTime = PauseMsg(W,'Start recording physiology NOW\n\nPress space bar to begin task', TxtColor, BackColor, FixTexture, 0); %need to think about if want to use pause message or something else at VERY beginging of task
    
    %% PRE-TASK BASELINE/HABITUATION
    HabitITIDur = 5;  %present first habituation probe 5 seconds into period
    
    % Play 3 habituation startles
    for i=1:3  %loop for habituation startles
        HabitTime = StartleProbe(HabitTime+HabitITIDur, HabitSTLEvent, SoundCardPlay, DIO, EventPort, UseIO);
        HabitITIDur = 13; %separate all subsequent probes by 13s
    end
    
    WaitSecs(2)

    %% Start Task
    %Start ITI for first trial
    Screen('DrawTexture', W, FixTexture);
    Screen('DrawingFinished', W); %to mark the end of all drawing commands
    ITIStartTime = Screen('Flip', W); %Present ITIFixImg as soon as possible
    
    %% TRIAL LOOP
    %ITI Image already displayed.  Consider this start of ITI 1.
    for i=1:NumTrials  %loop for stimulus presentation;   TRIAL = (1) ITI, (2) CUE

       %Check/Present ITI STARTLE
        if (ITIProbeTime(i) >0)
            StartleProbe(ITIStartTime+ITIProbeTime(i), ITISTLEvents(i), SoundCardPlay, DIO, EventPort, UseIO)
        end

        %Prepare Cue
        switch CueTypes(i)
            case {10}
                Screen('DrawTexture', W, CueTextures(1));
            case {20};
                Screen('DrawTexture', W, CueTextures(2));
            case {30}
                Screen('DrawTexture', W, CueTextures(3));
        end
        Screen('DrawingFinished', W);
        
        %CUE PERIOD
        CueStartTime= Screen('Flip', W, ITIStartTime + ITIDurs(i));
        MarkEvent(DIO, EventPort, CueTypes(i), UseIO)
        
        %Check/Present Cue STARTLE
        if (CueProbes(i) == 1)
            StartleProbe(CueStartTime+CueProbeTime, CueSTLEvents(i), SoundCardPlay, DIO, EventPort, UseIO)
        end
        
        %Start
        Screen('DrawTexture', W, FixTexture);
        Screen('DrawingFinished', W); %to mark the end of all drawing commands
        ITIStartTime = Screen('Flip', W, CueStartTime + CueDur); %Present ITIFixImg as soon as cue disappears
        
    end
    
    WaitMsg(W, 'Thank you. Task Complete!', 4, [], [], BlackTexture, CueStartTime + CueDur)
    PauseMsg(W,'Stop recording physiology NOW\n\nPress space bar to end task', TxtColor, BackColor, BlackTexture, 0);
    WaitSecs(.5);
        
    %% POST TASK ISSUES
    WaitSecs(4);
    Screen('CloseAll'); %Close display windows
    PsychPortAudio('Close', SoundCardPlay);
    Priority(0); %Shutdown realtime mode
    ShowCursor(W); %Show cursor again, if it has been disabled

    %Copy Neuroscan data to server
    %TO DO - figure out if we need all data files (not just dat) and how to
    %map to neuroscan computer?
%     fprintf('\n\nCopying neuroscan files to the server.\nDo not close Matlab yet.\n\n')
%     DataCopy ([FileName '.dat'], 'N:\Kaye2\Kaye2RawData\', ['/home/ra/CurtinServer/KAYE2RawData/' SubID]);
%     fprintf('\n\nCopying complete. Data successfully copied to the server!\n\n')

catch TheError
    
    if exist ('SoundCardPlay', 'var')
        PsychPortAudio('Close', SoundCardPlay); %Close SoundCardPlay
    end
    
    Screen('CloseAll'); %Close display windows
    Priority(0); %Shutdown realtime mode
    ShowCursor(W); %Show cursor again, if it has been disabled
        
    rethrow(TheError);
end