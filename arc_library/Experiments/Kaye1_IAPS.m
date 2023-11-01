function Kaye1_IAPS
%Kaye1 IAPS Task
%SubID = ABCD or EABCD (E added 4/29/15)
%E = 5: 2nd wave of subjects after all 4-digit SubID cells were full
%A = Sequence (1 = NPU 2 = IAPS, as first task of day)
%B = Sex (0=Female;1=Male)
%C = Version (usually called script order- refers to trial/probe structure in task)
%D = SubID
%Day = 1 or 2

%JTK

%% Confirm correct Program is being run for the correct SubID
%Ask for SubID and Day
SubID = input('Enter SubID (4 or 5 digits)\n', 's'); %RA input SubID as str
Day = input('Enter Day (1 or 2)\n'); %RA input SubID as double

%Check that correct task is being run (day and sequence)
Version = mod(floor(str2double(SubID)/10),10); %Calculate proper version(order) based on SubID
Sequence = mod(floor(str2double(SubID)/1000),10); %Calculate proper sequence(NPU or IAPS first) based on SubID

%Verify Version range = 1-4
%Version 1 & 2 see Picture Set A on Day 1; Version 3 & 4 see Picture Set B on Day 1
if  all(Version ~= 1:4)
    error('There is in error with the SubID, the tens digit should be 1, 2, 3 or 4. Confirm the correct SubID was entered!')
end

%Check to confirm correct script is being run. Assumes that RawData folder has already been made prestudy!
switch Day
    case{1} %Day = 1
        FileName = ['Kaye1_IAPS1_' SubID]; %Day 2 file name
        if  exist(fullfile('C:\Local\LocalKaye1\QuestionData', SubID, [FileName '.dat']),'file')
            error('Filename: %s exists.  \nThis must be an error!', [FileName '.dat'])
        end
        
        if Sequence ==1 %NPU First
            if  ~exist(fullfile('C:\Local\LocalKaye1\QuestionData',SubID,['Kaye1_VoiceTest1_',SubID,'.wav']),'file')
                error('You may have inputted the wrong day or SubID.\nOr you may need to run the NPU task first.')
            end
        end
        
        if Sequence ==2 %IAPS First
            if  exist(fullfile('C:\Local\LocalKaye1\QuestionData',SubID,['Kaye1_VoiceTest1_',SubID,'.wav']),'file')
                error('You may have inputted the wrong day or SubID!')
            end
        end

        %Set PictureSet
        if Version < 3 %Version is 1 or 2
            PictureSet = 1; %PictureSet 1(A) Day1 V1 or V2
        else
            PictureSet = 2; %PictureSet 2(B) Day1 V3 or V4
        end
        
    case{2} %Day = 2
        FileName = ['Kaye1_IAPS2_' SubID ]; %Day 2 file name
        if  exist(fullfile('C:\Local\LocalKaye1\QuestionData', SubID, [FileName '.dat']),'file')
            error('Filename: %s exists.  \nThis must be an error!', [FileName '.dat'])
        end
        
        if Sequence ==1 %NPU First
            if  ~exist(fullfile('C:\Local\LocalKaye1\QuestionData',SubID,['Kaye1_VoiceTest2_',SubID,'.wav']),'file')
                error('You may have inputted the wrong day or SubID.\nOr you may need to run the NPU task first.')
            end
        end
        
        if Sequence ==2 % IAPS First
            if  exist(fullfile('C:\Local\LocalKaye1\QuestionData',SubID,['Kaye1_VoiceTest2_',SubID,'.wav']),'file')
                error('You may have inputted the wrong day or SubID!')
            end
        end
        
        %Set PictureSet
        if Version < 3 %Version is 1 or 2
            PictureSet = 2; %PictureSet 2(A) Day2 V1 or V2
        else
            PictureSet = 1; %PictureSet 1(B) Day2 V3 or V4
        end
        
    otherwise
        error('Day (%d) must be 1 or 2', Day)
end

try
    %% Set up DIO card (PortA = Button Box; PortB =event codes to neuroscan; PortC = shock)
    [DIO PortA PortB PortC UseIO] = ConfigIO;   %Includes base address for left lab (A input, B and C Output)
    
    %% Define all Trial Parameters
    NumTrials = 36;
    
    %Cue info. 10 = Neutral, 20 = Pleasant, 30 = Unpleasant
    CueDur = 6;   %Cues presented for 6s
    CueTypes(1,:) = [30 20 30 10 20 10 20 30 10 30 10 20 20 10 30 10 20 30 30 20 10 30 10 20 20 10 30 10 30 20 10 20 10 30 20 30]; %A1
    CueTypes(2,:) = [20 30 20 10 30 10 30 20 10 20 10 30 30 10 20 10 30 20 20 30 10 20 10 30 30 10 20 10 20 30 10 30 10 20 30 20]; %A2
    CueTypes(3,:) = [10 30 10 20 30 20 30 20 10 20 10 30 10 30 20 30 20 10 10 20 30 20 30 10 30 10 20 10 20 30 20 30 20 10 30 10]; %B1
    CueTypes(4,:) = [10 20 10 30 20 30 20 30 10 30 10 20 10 20 30 20 30 10 10 30 20 30 20 10 20 10 30 10 30 20 30 20 30 10 20 10]; %B2
    
    %Cue probe info
    EC = 3;  %time (s) for early probe during Cue
    MC = 4;  %time (s) for middle probe durnig Cue
    LC = 5;  %time (s) for late probe durnig Cue
    CueProbes(1,:) = [EC 0 MC 0 LC MC MC 0 LC LC 0 EC MC MC 0 EC 0 MC MC 0 EC 0 MC MC EC 0 LC LC 0 MC MC LC 0 MC 0 EC]; %A1
    CueProbes(2,:) = [EC 0 MC 0 LC MC MC 0 LC LC 0 EC MC MC 0 EC 0 MC MC 0 EC 0 MC MC EC 0 LC LC 0 MC MC LC 0 MC 0 EC]; %A2
    CueProbes(3,:) = [EC MC 0 MC EC 0 0 LC MC EC LC 0 MC LC 0 MC MC 0 0 MC MC 0 LC MC 0 LC EC MC LC 0 0 EC MC 0 MC EC]; %B1
    CueProbes(4,:) = [EC MC 0 MC EC 0 0 LC MC EC LC 0 MC LC 0 MC MC 0 0 MC MC 0 LC MC 0 LC EC MC LC 0 0 EC MC 0 MC EC]; %B2
    
    %ITI probe info
    EI = 3;  %time (s) for early probe during ITI
    LI = 10;  %time (s) for late probe durnig ITI
    ITIProbeTime(1,:) = [0 LI 0 EI 0 0 0 EI 0 0 LI 0 0 0 LI 0 EI 0 0 EI 0 LI 0 0 0 LI 0 0 EI 0 0 0 EI 0 LI 0]; %A1
    ITIProbeTime(2,:) = [0 LI 0 EI 0 0 0 EI 0 0 LI 0 0 0 LI 0 EI 0 0 EI 0 LI 0 0 0 LI 0 0 EI 0 0 0 EI 0 LI 0]; %A2
    ITIProbeTime(3,:) = [0 0 EI 0 0 LI LI 0 0 0 0 EI 0 0 EI 0 0 LI LI 0 0 EI 0 0 EI 0 0 0 0 LI LI 0 0 EI 0 0]; %B1
    ITIProbeTime(4,:) = [0 0 EI 0 0 LI LI 0 0 0 0 EI 0 0 EI 0 0 LI LI 0 0 EI 0 0 EI 0 0 0 0 LI LI 0 0 EI 0 0]; %B2
    
    %ITI duration info
    I1 = 14; %14 sec
    I2 = 17; %17 sec
    I3 = 20; %20 sec
    ITIDurs(1,:) = [I1 I3 I1 I2 I3 I2 I2 I3 I1 I2 I3 I1 I1 I2 I3 I2 I1 I3 I1 I2 I1 I3 I2 I3 I2 I3 I1 I2 I3 I1 I3 I2 I1 I2 I3 I1]; %A1
    ITIDurs(2,:) = [I1 I3 I1 I2 I3 I2 I2 I3 I1 I2 I3 I1 I1 I2 I3 I2 I1 I3 I1 I2 I1 I3 I2 I3 I2 I3 I1 I2 I3 I1 I3 I2 I1 I2 I3 I1]; %A2
    ITIDurs(3,:) = [I2 I1 I2 I3 I3 I1 I3 I3 I1 I1 I2 I2 I2 I3 I3 I1 I2 I1 I3 I2 I3 I1 I2 I1 I2 I3 I2 I1 I3 I1 I3 I1 I2 I2 I1 I3]; %B1
    ITIDurs(4,:) = [I2 I1 I2 I3 I3 I1 I3 I3 I1 I1 I2 I2 I2 I3 I3 I1 I2 I1 I3 I2 I3 I1 I2 I1 I2 I3 I2 I1 I3 I1 I3 I1 I2 I2 I1 I3]; %B2
    
    %% Event codes; ABC
    HabitSTLEvent = 100;
    
    %Cue startle probe event codes: 111,112,113,121,122,123,131,132,133
    CueSTLEvents = CueTypes + 100; %A = 1 (probe), %B= 1(Neutral), 2(Pleas), 3(Unpleas)
    CueSTLEvents(CueProbes==0) = 0; %no startle on cue
    CueSTLEvents(CueProbes==EC) = CueSTLEvents(CueProbes==EC)+1; %C= 1(3s cue startle probe)
    CueSTLEvents(CueProbes==MC) = CueSTLEvents(CueProbes==MC)+2; %C= 2(4s cue startle probe)
    CueSTLEvents(CueProbes==LC) = CueSTLEvents(CueProbes==LC)+3; %C= 3(5s cue startle probe)
    
    %ITI startle probe event codes: 114,115,124,125,134,135
    %Coded based on the Cue Type they come after (not before)
    ITISTLEvents = CueTypes + 100; %A = 1 (probe), %B= 1(Neutral), 2(Pleas), 3(Unpleas)
    ITISTLEvents(ITIProbeTime==0) = 0; %no startle on ITI
    ITISTLEvents(ITIProbeTime==EI) = ITISTLEvents(ITIProbeTime==EI)+4;%C= 4(3s ITI startle probe)
    ITISTLEvents(ITIProbeTime==LI) = ITISTLEvents(ITIProbeTime==LI)+5;%C= 5(10s ITI startle probe)
    
    %% START SCREEN
    AssertOpenGL;   %Check if PTB is properly installed on your system.
    W = Screen('OpenWindow', 0, 0, [], 32, 2); %Open Window and configure text options
    Screen('TextSize',W, 36); %36 pt font
    Screen('TextFont',W, 'Calibri'); %Calibri font default
    HideCursor;
    TxtColor = [255 255 255]; %Set to White
    BackColor = [0 0 0]; %Set to Black
    
    %load into memory for later high time precision use
    WaitSecs(.1);
    GetSecs;
    KbCheck;
    
    %% Set paths
    RootPath = fileparts(which('Kaye1_IAPS.m'));
    LocalPath = ['C:\Local\LocalKaye1\QuestionData\' SubID '\' ];
    ServerPath = ['P:\StudyData\Kaye1\RawData\' SubID];
    NeuroscanPath = 'N:\Kaye1\Kaye1RawData\';
    
    %% Randomize IAPS picture order for participant
    %Cues stored in cell array. Column 1 = Neutral, Column 2 = Pleasant; Column 3 = Unpleasant
    %Each cell is a unique picture
    IAPSnumber(1,:) = [2200 2230 2381 2440 2480 5510 5740 7006 7010 7020 7035 9070]; %Neutral A
    IAPSnumber(2,:) = [2190 2210 2570 2850 2870 2890 5531 7000 7004 7050 7090 7950]; %Neutral B
    IAPSnumber(3,:) = [1710 4641 4650 4680 4690 4695 4698 5700 5833 7270 8030 8502]; %Pleasant A
    IAPSnumber(4,:) = [2150 4599 4608 4660 4668 4672 4687 5600 5836 7330 8190 8501]; %Pleasant B
    IAPSnumber(5,:) = [3000 3080 3102 3170 6260 6313 6415 9183 9295 9302 9325 9921]; %Unpleasant A
    IAPSnumber(6,:) = [3053 3071 3120 3130 6230 6350 9140 9301 9322 9340 9410 9570]; %Unpleasant B
    
    %Randomly sort order of pictures. Each Sub will have unique random order
    rng('shuffle');
    IAPSrand(1,:) = IAPSnumber(1,randperm(12)); %Neutral A random order
    IAPSrand(2,:) = IAPSnumber(2,randperm(12)); %Neutral B random order
    IAPSrand(3,:) = IAPSnumber(3,randperm(12)); %Pleasant A random order
    IAPSrand(4,:) = IAPSnumber(4,randperm(12)); %Pleasant B random order
    IAPSrand(5,:) = IAPSnumber(5,randperm(12)); %Unpleasant A random order
    IAPSrand(6,:) = IAPSnumber(6,randperm(12)); %Unpleasant B random order
    
    %% Preparing all images
    FileType = 'JPG';
    CueImg = cell(1,36); %Create empty 1x36 cell for jpg files
    Cue = zeros(1,36); %SubID column 1
    iN=0; iP=0; iU=0; %Create index counter for creating Cue
    
    switch PictureSet
        case{1} %Picture Set 1/A = Day 1 Version 1 & 2 or Day 2 Version 3 & 4
            for i = 1:NumTrials %Create full order of all cues
                if CueTypes(Version,i) == 10
                    iN = iN +1; %index neutral
                    Cue(i) =IAPSrand(1,iN);
                    CueImg{i} =  imread([RootPath '/Kaye1/IAPS/' num2str(IAPSrand(1,iN)) '.JPG'], FileType); %Column 1 = Neutral
                elseif CueTypes(Version,i) == 20
                    iP = iP +1; %index pleasant
                    Cue(i) =IAPSrand(3,iP);
                    CueImg{i} =  imread([RootPath '/Kaye1/IAPS/' num2str(IAPSrand(3,iP)) '.JPG'], FileType); %Column 2 = Pleasant
                elseif CueTypes(Version,i) == 30
                    iU = iU +1; %index unpleasant
                    Cue(i) =IAPSrand(5,iU);
                    CueImg{i} =  imread([RootPath '/Kaye1/IAPS/' num2str(IAPSrand(5,iU)) '.JPG'], FileType); %Column 3 = Unpleasant
                end
            end
            
        case{2} %Picture Set 2/B = Day 1 Version 3 & 4 or Day 2 Version 1 & 2
            for i = 1:NumTrials %Create full order of all cues
                if CueTypes(Version,i) == 10
                    iN = iN +1; %index neutral
                    Cue(i) =IAPSrand(2,iN);
                    CueImg{i} =  imread([RootPath '/Kaye1/IAPS/' num2str(IAPSrand(2,iN)) '.JPG'], FileType); %Column 1 = Neutral
                elseif CueTypes(Version,i) == 20
                    iP = iP +1; %index pleasant
                    Cue(i) =IAPSrand(4,iP);
                    CueImg{i} =  imread([RootPath '/Kaye1/IAPS/' num2str(IAPSrand(4,iP)) '.JPG'], FileType); %Column 2 = Pleasant
                elseif CueTypes(Version,i) == 30
                    iU = iU +1; %index unpleasant
                    Cue(i) =IAPSrand(6,iU);
                    CueImg{i} =  imread([RootPath '/Kaye1/IAPS/' num2str(IAPSrand(6,iU)) '.JPG'], FileType); %Column 3 = Unpleasant
                end
            end
    end
    
    CueTextures = zeros(36); %Create IAPS textures in 1x36 array with correct randomized order for this sub
    for i = 1:36
        CueTextures(i) = Screen('MakeTexture', W, CueImg{i});
    end
    clear CueImg IAPSnumber IAPSrand i iN iP iU
    
    %ITI Fixation Cross for habituation period
    ITIFixImg =  imread([RootPath '/Kaye1/FixationCross.JPG'], 'JPG');
    ITIFixTexture = Screen('MakeTexture', W, ITIFixImg);
    clear ITIFixImg
    
    %Black screen for block transitions
    BlackImg =  imread([RootPath '/Kaye1/BlackImage.JPG'], 'JPG');
    BlackTexture = Screen('MakeTexture', W, BlackImg);
    clear BlackImg
    
    %% Save participant's randomized IAPS picture order (.dat) files  locally and copy to server
    OutFile = zeros(36,5); %SubID column 1
    OutFile(:,1) = str2double(SubID); %SubID column 1
    OutFile(:,2) = 1:36; %trial number column 2
    OutFile(:,3) = Cue; %IAP picture number column 3
    OutFile(:,4) = CueSTLEvents(Version,:); %Cue probe event code column 4
    OutFile(:,5) = ITISTLEvents(Version,:); %ITI probe event code column 5
    DataSave(OutFile, [FileName  '.dat'], LocalPath); %Save dat file
    clear OutFile
    
    %% Present Task Instructions
    InstructPath = [RootPath '/Kaye1/IAPS/'];
    NSlides = 9; %Number of instruction slides
    TaskInstructions(InstructPath, NSlides, PortA, DIO, W, FileType);
    
    %% Set sound card parameters for recording and playing audio
    modePlay = 1; %audio play back only
    freq = 44100; %a frequency of 44100 Hz
    reqlatencyclassPlay = 2; %for low latency (agressive but consider 3)
    nchannels = 2; %2 sound channels for stereo capture
    WaitSecs(.1); %set up for fast transitions
    InitializePsychSound(1);  %initilze for low latency
    
    %% Load Startle Probe
    [y] = wavread('wnprobe');  %assumes file is in path
    Noise = y';
    PsychPortAudio('Verbosity', 10);
    
    %% Prep Task
    Priority(2); %Enable realtime-scheduling for real trial
    HabitTime = PauseMsg(W,'Start recording physiology NOW\n\nPress space bar to begin task', TxtColor, BackColor, ITIFixTexture, 0);
    
    %% PRE-TASK BASELINE/HABITUATION
    HabitITIDur = 5;  %present first habituation probe 5 seconds into period
    
    SoundCardPlay = PsychPortAudio('Open', [], modePlay, reqlatencyclassPlay, freq, nchannels);  %This returns a handle to the audio device. Open sound card in play back mode.
    PsychPortAudio('FillBuffer', SoundCardPlay, Noise); %From typical startle studies
    
    %Play 3 habituation startles
    for i=1:3  %loop for habituation startles
        HabitTime = StartleProbe(HabitTime+HabitITIDur, HabitSTLEvent, SoundCardPlay, DIO, PortB, UseIO);
        HabitITIDur = 15; %separate all subsequent probes by 15s
    end
    
    WaitSecs(2)
    
    %% Start First Block
    WaitMsg(W, 'Pictures will appear in a few moments', 9, TxtColor, BackColor);
    Screen('DrawTexture', W, ITIFixTexture);
    Screen('DrawingFinished', W); %to mark the end of all drawing commands
    ITIStartTime = Screen('Flip', W); %Present ITIFixImg as soon as possible
    
    %Prepare Cue
    Screen('DrawTexture', W, CueTextures(1));
    Screen('DrawingFinished', W);
    
    %% TRIAL LOOP
    %ITI Image already displayed.  Consider this start of ITI 1.
    for i=1:NumTrials  %loop for stimulus presentation;   TRIAL = First ITI then CUE
        switch i
            case{1,7,13,19,25} %First trial of each block
                %CUE PERIOD
                CueStartTime= Screen('Flip', W, ITIStartTime + 5); %Wait 5s until first slide
                MarkEvent(DIO, PortB, CueTypes(Version,i), UseIO);
                
            otherwise
                %CUE PERIOD
                CueStartTime= Screen('Flip', W, ITIStartTime + ITIDurs(Version,i-1)); %Wait ITI until first slide
                MarkEvent(DIO, PortB, CueTypes(Version,i), UseIO);
        end
        
        %Check/Present Cue STARTLE
        if (CueProbes(Version,i) > 0)
            StartleProbe(CueStartTime+CueProbes(Version,i), CueSTLEvents(Version,i), SoundCardPlay, DIO, PortB, UseIO); %present startle probe at 3, 4, or 5sec
        end
        
        %ITI PERIOD
        Screen('DrawTexture', W, ITIFixTexture);
        Screen('DrawingFinished', W);
        ITIStartTime = Screen('Flip', W, CueStartTime + CueDur); %Flip to start next trial
        
        %Check/Present ITI STARTLE
        if (ITIProbeTime(Version,i) >0)
            StartleProbe(ITIStartTime+ITIProbeTime(Version,i), ITISTLEvents(Version,i), SoundCardPlay, DIO, PortB, UseIO);
        end
        
        switch i  %Checks for block ends and breaks
            case{6,12,18,24,30}
                PauseMsg(W,'End of Set.\nPlease Tell the Experimenter \nWhen You Are Ready to Continue.',[], [], BlackTexture, ITIStartTime + ITIDurs(Version,i));%pause for break that restarts after pause
                ITIStartTime = WaitMsg(W, 'Pictures will appear in a few moments', 9, [], [], ITIFixTexture, 0);
                
                %Prepare Cue for Trial i + 1 (next trial
                Screen('DrawTexture', W, CueTextures(i+1));
                Screen('DrawingFinished', W);
                
            case{36}  %Wrap up after last trial
                WaitMsg(W, 'Thank you. Task Complete!', 4, [], [], BlackTexture, ITIStartTime + ITIDurs(Version,i));
                PauseMsg(W,'Stop recording physiology NOW!\n\nPress space bar to end task.',[], [], BlackTexture, 0);
                
            otherwise
                %Prepare Cue for Trial i + 1 (next trial
                Screen('DrawTexture', W, CueTextures(i+1));
                Screen('DrawingFinished', W);
        end
    end
    
    %% POST TASK ISSUES TO CLOSE PTB
    Screen('CloseAll'); %Close onscreen and offscreen windows and textures
    PsychPortAudio('Close', SoundCardPlay); %Close SoundCardPlay if SoundCardPlay exists
    Priority(0); %Shutdown realtime mode
    clear mex  %clear io32()
    ShowCursor; %Show cursor again, if it has been disabled
    
    %% Copy cnt data file to server
    fprintf('\n\nCopying neuroscan files to the server.\nDo not close Matlab yet.\n\n')
    DataCopy ([FileName '.dat'], LocalPath, ServerPath); %Copy dat file to server
    DataCopy ([FileName '.cnt'], NeuroscanPath, ServerPath);
    fprintf('\n\nCopying complete. Data successfully copied to the server!\n\n')
    
catch TheError
    
    if exist ('SoundCardPlay', 'var')
        PsychPortAudio('Close', SoundCardPlay); %Close SoundCardPlay if SoundCardPlay exists
    end
    
    Screen('CloseAll'); %Close display windows
    Priority(0); %Shutdown realtime mode
    ShowCursor; %Show cursor again, if it has been disabled
    ListenChar(1);
    clear mex  %clear io32()
    rethrow(TheError);
end