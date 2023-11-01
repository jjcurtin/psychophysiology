function Kaye1_NPU
%Kaye1 NPU Task
%SubID = ABCD or EABCD (E added 4/29/15)
%E = 5: 2nd wave of subjects after all 4-digit SubID cells were full
%A = Sequence (1 = NPU 2 = IAPS, as first task of day)
%B = Sex (0=Female;1=Male)
%C = Version (usually called script order- refers to trial/probe structure in task)
%D = SubID
%Day = 1 or 2

% JTK, DEB, KM and JJC

%% Confirm correct Program is being run for the correct SubID
% Ask for SubID and Day
SubID = input('Enter SubID (4 or 5 digits)\n', 's'); % RA input SubID as str
Day = input('Enter Day (1 or 2)\n'); % RA input SubID as double

% Check that correct task is being run (day and sequence)
Version = mod(floor(str2double(SubID)/10),10); % Calculate proper version(order) based on SubID
Sequence = mod(floor(str2double(SubID)/1000),10); % Calculate proper sequence(NPU or IAPS first) based on SubID

% Verify Version range = 1-4
if  all(Version ~= 1:4)
    error('There is in error with the SubID, the Tens digit should be 1, 2, 3 or 4. Confirm the correct SubID was entered!')
end

switch Day
    case{1} %Day = 1
        FileName = ['Kaye1_NPU1_' SubID]; %assumes that RawData folder has already been made prestudy!
        if  exist(fullfile('C:\Local\LocalKaye1\QuestionData',SubID,['Kaye1_VoiceTest1_',SubID,'.wav']),'file')
            error('Filename: %s exists.  This must be an error!', ['Kaye1_VoiceTest',num2str(Day),'_',SubID,'.wav'])
        end
        
        if Sequence ==1 %NPU First
            if  exist(fullfile('C:\Local\LocalKaye1\QuestionData',SubID,['Kaye1_IAPS1_' SubID '.dat']),'file')
                error('You may have inputted the wrong day!')
            end
        end
        
        if Sequence ==2 % IAPS First
            if  ~exist(fullfile('C:\Local\LocalKaye1\QuestionData',SubID,['Kaye1_IAPS1_' SubID '.dat']),'file')  %%%%%%%VERIFY ~ works for this
                error('You may have inputted the wrong day!')
            end
        end
    case{2} %Day = 2
        FileName = ['Kaye1_NPU2_' SubID ]; %assumes that RawData folder has already been made prestudy!
        if  exist(fullfile('C:\Local\LocalKaye1\QuestionData',SubID,['Kaye1_VoiceTest2_',SubID,'.wav']),'file')
            error('Filename: %s exists.  This must be an error!', ['Kaye1_VoiceTest2_',SubID,'.wav'])
        end
        
        if  ~exist(fullfile('C:\Local\LocalKaye1\QuestionData',SubID,['Kaye1_VoiceTest1_',SubID,'.wav']),'file')
            error('Filename: %s does not exist.  You may have inputted the wrong day!', ['Kaye1_VoiceTest1_',SubID,'.wav'])
        end
        
        if Sequence ==1 %NPU First
            if  exist(fullfile('C:\Local\LocalKaye1\QuestionData',SubID,['Kaye1_IAPS2',SubID,'.dat']),'file')
                error('You may have inputted the wrong day!')
            end
        end
        
        if Sequence ==2 % IAPS First
            if  ~exist(fullfile('C:\Local\LocalKaye1\QuestionData',SubID,['Kaye1_IAPS2_' SubID '.dat']),'file')  %%%%%%%VERIFY ~ works for this
                error('You may have inputted the wrong day!')
            end
        end
    otherwise
        error('Day (%d) must be 1 or 2', Day)
end

try
    %% Set up DIO card (PortA = Button Box; PortB =event codes to neuroscan; PortC = shock)
    [DIO PortA PortB PortC UseIO] = ConfigIO;   %Includes base address for left lab (A input, B and C Output
    
    %% Define all Trial Parameters
    NumTrials = 42;
    
    %Cue info
    CueDur = 5;   %Cues presented for 5s
    %10 = NS, 20 = P, 30 = U
    CueTypes(1,:) = [30 30 30 30 30 30 10 10 10 10 10 10 20 20 20 20 20 20 10 10 10 10 10 10 20 20 20 20 20 20 10 10 10 10 10 10 30 30 30 30 30 30]; %A1
    CueTypes(2,:) = [20 20 20 20 20 20 10 10 10 10 10 10 30 30 30 30 30 30 10 10 10 10 10 10 30 30 30 30 30 30 10 10 10 10 10 10 20 20 20 20 20 20]; %A2
    CueTypes(3,:) = [30 30 30 30 30 30 10 10 10 10 10 10 20 20 20 20 20 20 10 10 10 10 10 10 20 20 20 20 20 20 10 10 10 10 10 10 30 30 30 30 30 30]; %B1
    CueTypes(4,:) = [20 20 20 20 20 20 10 10 10 10 10 10 30 30 30 30 30 30 10 10 10 10 10 10 30 30 30 30 30 30 10 10 10 10 10 10 20 20 20 20 20 20]; %B2
    
    %Cue probe info
    %0 = No Cue Probe; 1 = Yes Cue Probe;
    CueProbeTime = 4.5;%time for  probe durnig cue (4.5sec)
    CueProbes(1,:) = [1 0 1 0 1 1 0 1 1 0 1 1 1 1 0 1 0 1 1 0 1 1 0 1 1 0 1 0 1 1 1 1 0 1 1 0 1 1 0 1 0 1]; %A1
    CueProbes(2,:) = [1 0 1 0 1 1 0 1 1 0 1 1 1 1 0 1 0 1 1 0 1 1 0 1 1 0 1 0 1 1 1 1 0 1 1 0 1 1 0 1 0 1]; %A2
    CueProbes(3,:) = [1 1 0 1 0 1 1 0 1 1 0 1 1 0 1 0 1 1 1 1 0 0 1 1 1 1 0 1 0 1 1 0 1 1 0 1 1 0 1 0 1 1]; %B1
    CueProbes(4,:) = [1 1 0 1 0 1 1 0 1 1 0 1 1 0 1 0 1 1 1 1 0 0 1 1 1 1 0 1 0 1 1 0 1 1 0 1 1 0 1 0 1 1]; %B2
    
    %ITI probe info
    EI = 13;  %time (s) for early probe during ITI
    MI = 14;  %time (s) for middle probe durnig ITI
    LI = 15;  %time (s) for late probe durnig ITI
    ITIProbeTime(1,:) = [0 LI 0 MI 0 0 EI 0 0 MI 0 0 0 0 MI 0 LI 0 0 LI 0 0 EI 0 0 MI 0 EI 0 0 0 0 MI 0 0 LI 0 0 EI 0 MI 0]; %A1
    ITIProbeTime(2,:) = [0 MI 0 EI 0 0 EI 0 0 MI 0 0 0 0 EI 0 MI 0 0 LI 0 0 EI 0 0 LI 0 MI 0 0 0 0 MI 0 0 LI 0 0 MI 0 LI 0]; %A2
    ITIProbeTime(3,:) = [0 0 MI 0 LI 0 0 LI 0 0 MI 0 0 MI 0 LI 0 0 0 0 EI LI 0 0 0 0 MI 0 EI 0 0 MI 0 0 EI 0 0 MI 0 EI 0 0]; %B1
    ITIProbeTime(4,:) = [0 0 MI 0 EI 0 0 LI 0 0 MI 0 0 MI 0 EI 0 0 0 0 EI LI 0 0 0 0 MI 0 LI 0 0 MI 0 0 EI 0 0 MI 0 LI 0 0]; %B2
    
    %ITI duration info
    I1 = 14; % 14 sec
    I2 = 17; % 17 sec
    I3 = 20; % 20 sec
    ITIDurs(1,:) = [I1 I3 I3 I2 I2 I1 I1 I2 I3 I2 I1 I3 I3 I2 I2 I1 I3 I1 I3 I2 I1 I2 I1 I3 I1 I3 I1 I2 I2 I3 I1 I2 I3 I2 I1 I3 I3 I1 I1 I3 I2 I2]; %A1
    ITIDurs(2,:) = [I1 I3 I1 I2 I2 I3 I1 I2 I3 I2 I1 I3 I3 I1 I1 I3 I2 I2 I3 I2 I1 I2 I1 I3 I1 I3 I3 I2 I2 I1 I1 I2 I3 I2 I1 I3 I3 I2 I2 I1 I3 I1]; %A2
    ITIDurs(3,:) = [I2 I3 I2 I1 I3 I1 I2 I3 I1 I3 I2 I1 I1 I2 I2 I3 I1 I3 I3 I1 I3 I2 I1 I2 I3 I1 I3 I2 I2 I1 I1 I2 I3 I1 I3 I2 I3 I2 I1 I1 I3 I2]; %B1
    ITIDurs(4,:) = [I3 I1 I3 I2 I2 I1 I2 I3 I1 I3 I2 I1 I3 I2 I1 I1 I3 I2 I3 I1 I3 I2 I1 I2 I2 I3 I2 I1 I3 I1 I1 I2 I3 I1 I3 I2 I1 I2 I2 I3 I1 I3]; %B2
    
    %Cue shock array
    ECS = 2; % Early Cue Shock
    LCS = 4.8; % Late Cue Shock
    CueShockTime(1,:)=[0 LCS 0 ECS 0 0 0 0 0 0 0 0 LCS LCS LCS LCS LCS LCS 0 0 0 0 0 0 LCS LCS LCS LCS LCS LCS 0 0 0 0 0 0 0 0 ECS 0 LCS 0]; %A1
    CueShockTime(2,:)=[LCS LCS LCS LCS LCS LCS 0 0 0 0 0 0 0 0 ECS 0 LCS 0 0 0 0 0 0 0 0 LCS 0 ECS 0 0 0 0 0 0 0 0 LCS LCS LCS LCS LCS LCS]; %A2
    CueShockTime(3,:)=[0 0 ECS 0 LCS 0 0 0 0 0 0 0 LCS LCS LCS LCS LCS LCS 0 0 0 0 0 0 LCS LCS LCS LCS LCS LCS 0 0 0 0 0 0 0 LCS 0 ECS 0 0]; %B1
    CueShockTime(4,:)=[LCS LCS LCS LCS LCS LCS 0 0 0 0 0 0 0 LCS 0 ECS 0 0 0 0 0 0 0 0 0 0 ECS 0 LCS 0 0 0 0 0 0 0 LCS LCS LCS LCS LCS LCS]; %B2
    
    %ITI shock array
    EIS = 4; % Early ITI Shock (sec)
    MIS = 8;  % Mid ITI Shock (sec)
    LIS = 12;  % Late ITI Shock (sec)
    ITIShockTime(1,:)=[EIS 0 LIS 0 MIS EIS 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 LIS EIS 0 LIS 0 MIS]; %A1
    ITIShockTime(2,:)=[0 0 0 0 0 0 0 0 0 0 0 0 LIS EIS 0 LIS 0 MIS 0 0 0 0 0 0 EIS 0 LIS 0 MIS EIS 0 0 0 0 0 0 0 0 0 0 0 0]; %A2
    ITIShockTime(3,:)=[MIS LIS 0 EIS 0 EIS 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 LIS 0 EIS 0 LIS MIS]; %B1
    ITIShockTime(4,:)=[0 0 0 0 0 0 0 0 0 0 0 0 LIS 0 EIS 0 LIS MIS 0 0 0 0 0 0 MIS LIS 0 EIS 0 EIS 0 0 0 0 0 0 0 0 0 0 0 0]; %B2
    
    %Cue question mark
    CueQTime = .5; % present question mark .5 second into cue presentation
    CueQuestion(1,:)=[0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 1 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1]; %A1
    CueQuestion(2,:)=[0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 1 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1]; %A2
    CueQuestion(3,:)=[0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 0 0]; %B1
    CueQuestion(4,:)=[0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 0 0]; %B2
    
    %ITI question array
    EIQ = 4; % Early question (sec)
    LIQ = 8;  % Mid question  (sec)
    ITIQuestionTime(1,:)=[0 0 0 EIQ 0 0 LIQ 0 0 0 0 0 0 0 0 0 EIQ 0 0 0 0 LIQ 0 0 0 0 LIQ 0 0 0 0 0 0 0 0 EIQ 0 0 0 0 LIQ 0]; %A1
    ITIQuestionTime(2,:)=[0 0 0 EIQ 0 0 LIQ 0 0 0 0 0 0 0 0 0 EIQ 0 0 0 0 LIQ 0 0 0 0 LIQ 0 0 0 0 0 0 0 0 EIQ 0 0 0 0 LIQ 0]; %A2
    ITIQuestionTime(3,:)=[0 0 0 0 LIQ 0 EIQ 0 0 0 0 0 0 0 0 0 EIQ 0 0 0 0 0 0 EIQ 0 0 LIQ 0 0 0 0 0 0 0 0 LIQ EIQ 0 0 0 0 0]; %B1
    ITIQuestionTime(4,:)=[0 0 0 0 LIQ 0 EIQ 0 0 0 0 0 0 0 0 0 EIQ 0 0 0 0 0 0 EIQ 0 0 LIQ 0 0 0 0 0 0 0 0 LIQ EIQ 0 0 0 0 0]; %B2
    
    %Set counters
    QCnt = 0;  %counter to track Question Asessments
    RecordCondition = cell(14,1); % Create cell array for condition info
    AudioData = cell(14,1); % Create cell array for condition info
    
    %Event codes
    ShockEvent = 1;
    HabitSTLEvent = 100;
    QuestionMark = 2;
    
    %Cue startle probe event codes: 111,112,121,122,131,132
    CueSTLEvents = CueTypes + 100; %A = 1 (probe), %B= 1(NoShock), 2(Predictable), 3(Unpredictable)
    CueSTLEvents(CueProbes==0) = 0; %no startle on cue
    CueSTLEvents(CueProbes==1) = CueSTLEvents(CueProbes==1)+1; %C= 1(cue startle probe - no question mark)
    CueSTLEvents(CueQuestion==1) = CueSTLEvents(CueQuestion==1) + 1; %C= 2(cue startle probe - question mark)
    
    %ITI startle probe event codes: 113,114,115,116,117,118,123,124,125,126,127,128,133,134,135,136,137,138
    ITISTLEvents = CueTypes + 100;%A = 1 (probe), %B= 1(NoShock), 2(Predictable), 3(Unpredictable)
    ITISTLEvents(ITIProbeTime==0) = 0;%no startle on cue
    ITISTLEvents(ITIProbeTime==EI) = ITISTLEvents(ITIProbeTime==EI)+3;%C= 3(13s ITI startle probe - no question mark)
    ITISTLEvents(ITIProbeTime==MI) = ITISTLEvents(ITIProbeTime==MI)+5;%C= 4(14s ITI startle probe - no question mark)
    ITISTLEvents(ITIProbeTime==LI) = ITISTLEvents(ITIProbeTime==LI)+7;%C= 7(15s ITI startle probe - no question mark)
    ITISTLEvents(ITIQuestionTime>1) = ITISTLEvents(ITIQuestionTime>1) + 1; %C= 4,6,8(13,14,15s ITI startle probe - question mark)
    
    %% Get info about shock intensity
    ShockIntensity = dlmread(fullfile('C:\Local\LocalKaye1\ShockAssessments',SubID, ['\ShockRatings_Kaye1_' SubID '.dat']));
    
    %Only need one value from the array
    ShockIntensity = ShockIntensity(end,2); % last (26th) row, 2nd column holds max shock value to be administered
    
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
    RootPath = fileparts(which('Kaye1_NPU.m'));
    FileType = 'JPG';
    
    %Cues stored in cell array (CueImg) or (ITIImg as question (1=no question, 2=question) X CueType (1-3)
    CueImg = cell(2,3);
    CueImg{1,1} =  imread([RootPath '/Kaye1/NPU/CueN.JPG'], FileType);
    CueImg{1,2} =  imread([RootPath '/Kaye1/NPU/CueP.JPG'], FileType);
    CueImg{1,3} =  imread([RootPath '/Kaye1/NPU/CueU.JPG'], FileType);
    CueImg{2,1} =  imread([RootPath '/Kaye1/NPU/CueNQ.JPG'], FileType);
    CueImg{2,2} =  imread([RootPath '/Kaye1/NPU/CuePQ.JPG'], FileType);
    CueImg{2,3} =  imread([RootPath '/Kaye1/NPU/CueUQ.JPG'], FileType);
    CueTextures = zeros(2,3);
    for i = 1:2
        for j = 1:3
            CueTextures(i,j) = Screen('MakeTexture', W, CueImg{i,j});
        end
    end
    clear CueImg
    
    %ITI image
    ITIImg = cell(2,3);
    ITIImg{1,1} =  imread([RootPath '/Kaye1/NPU/ITIN.JPG'], FileType);
    ITIImg{1,2} =  imread([RootPath '/Kaye1/NPU/ITIP.JPG'], FileType);
    ITIImg{1,3} =  imread([RootPath '/Kaye1/NPU/ITIU.JPG'], FileType);
    ITIImg{2,1} =  imread([RootPath '/Kaye1/NPU/ITINQ.JPG'], FileType);
    ITIImg{2,2} =  imread([RootPath '/Kaye1/NPU/ITIPQ.JPG'], FileType);
    ITIImg{2,3} =  imread([RootPath '/Kaye1/NPU/ITIUQ.JPG'], FileType);
    ITITextures = zeros(2,3);
    for i = 1:2
        for j = 1:3
            ITITextures(i,j) = Screen('MakeTexture', W, ITIImg{i,j});
        end
    end
    clear ITIImg
    
    %ITI Fixation Cross for habituation period
    ITIFixImg =  imread([RootPath '/Kaye1/FixationCross.JPG'], 'JPG');
    ITIFixTexture = Screen('MakeTexture', W, ITIFixImg);
    clear ITIFixImg
    
    %Black screen for block transitions
    BlackImg =  imread([RootPath '/Kaye1/BlackImage.JPG'], 'JPG');
    BlackTexture = Screen('MakeTexture', W, BlackImg);
    clear BlackImg
    
    %% Present Task Instructions
    InstructPath = [RootPath '/Kaye1/NPU/'];
    NSlides = 63;
    TaskInstructions(InstructPath, NSlides, PortA, DIO, W, FileType);
    
    %% Set sound card parameters for recording and playing audio
    modePlay = 1; % audio play back only
    modeRecord = 2; % audio capture only
    freq = 44100; % a frequency of 44100 Hz
    reqlatencyclassRecord = 0; % low latency control not important for recording
    reqlatencyclassPlay = 2; %for low latency (agressive but consider 3)
    nchannels = 2; % 2 sound channels for stereo capture
    TimeOut = 3; %how long participant has to respond once question mark appears
    
    %% VoiceTest
    % Get ready for VoiceTest
    WaitSecs(.1); % set up for fast transitions
    InitializePsychSound(1);  %initilze for low latency
    
    %Record Audio Response and PlayBack to make sure can hear participant well enough
    VoiceTest = TestVerbalInput(W, PortA, DIO); % Run TestVerbalInput
    
    %% Load Startle Probe
    [y] = wavread('wnprobe');  %assumes file is in path
    Noise = y';
    PsychPortAudio('Verbosity', 10);
    
    %% Prep Task
    Priority(2); %Enable realtime-scheduling for real trial
    HabitTime = PauseMsg(W,'Turn the box to READY\n\nStart recording physiology NOW\n\nPress space bar to begin task', TxtColor, BackColor, ITIFixTexture, 0); %need to think about if want to use pause message or something else at VERY beginging of task
    
    %% PRE-TASK BASELINE/HABITUATION
    HabitITIDur = 5;  %present first habituation probe 5 seconds into period
    
    SoundCardPlay = PsychPortAudio('Open', [], modePlay, reqlatencyclassPlay, freq, nchannels);  % This returns a handle to the audio device. Open sound card in play back mode.
    PsychPortAudio('FillBuffer', SoundCardPlay, Noise); % From typical startle studies
    
    % Play 3 habituation startles
    for i=1:3  %loop for habituation startles
        HabitTime = StartleProbe(HabitTime+HabitITIDur, HabitSTLEvent, SoundCardPlay, DIO, PortB, UseIO);
        HabitITIDur = 15; %separate all subsequent probes by 15s
    end
    
    WaitSecs(2)
    
    %% Start First Block
    switch CueTypes(Version,1)
        case{10}
            WaitMsg(W, 'No Shocks', 9, TxtColor, BackColor)
            Screen('DrawTexture', W, ITITextures(1,1));
        case{20}
            WaitMsg(W, 'Shock at End of Red Square', 9, TxtColor, BackColor)
            Screen('DrawTexture', W, ITITextures(1,2));
        case{30}
            WaitMsg(W, 'Shock at Any Time', 9, TxtColor, BackColor)
            Screen('DrawTexture', W, ITITextures(1,3));
    end
    Screen('DrawingFinished', W); %to mark the end of all drawing commands
    ITIStartTime = Screen('Flip', W); %Present ITIFixImg as soon as possible
    
    %% SoundCardRecord: Open, Fill and Allocate Buffers
    SoundCardRecord = PsychPortAudio('Open', [], modeRecord, reqlatencyclassRecord, freq, nchannels); % This returns a handle to the audio device. Open sound card in recording mode.
    PsychPortAudio('GetAudioData', SoundCardRecord, 10); % Preallocate an internal audio recording  buffer with a capacity of 10 seconds:
    
    %% TRIAL LOOP
    %ITI Image already displayed.  Consider this start of ITI 1.
    for i=1:NumTrials  %loop for stimulus presentation;   TRIAL = (1) ITI, (2) CUE
        
        %Check/Measure ITI Question
        if (ITIQuestionTime(Version,i) >0)
            QCnt = QCnt +1; % Add 1 to question counter
            switch CueTypes(Version,i)
                case {10} % N
                    Screen('DrawTexture', W, ITITextures(2,1));
                    RecordCondition{QCnt,1} = 'Niti'; %
                case {20} % P
                    Screen('DrawTexture', W, ITITextures(2,2));
                    RecordCondition{QCnt,1} = 'Piti'; %
                case {30} % U
                    Screen('DrawTexture', W, ITITextures(2,3));
                    RecordCondition{QCnt,1} = 'Uiti'; %
            end
            Screen('DrawingFinished', W);
            QStartTime = Screen('Flip', W, ITIStartTime + ITIQuestionTime(Version,i));
            MarkEvent(DIO, PortB, QuestionMark, UseIO)
            
            PsychPortAudio('Start', SoundCardRecord); % Start recording
            
            %Prepare ITIImg for after Question
            switch CueTypes(Version,i)
                case {10}
                    Screen('DrawTexture', W, ITITextures(1,1));
                case {20}
                    Screen('DrawTexture', W, ITITextures(1,2));
                case {30}
                    Screen('DrawTexture', W, ITITextures(1,3));
            end
            Screen('DrawingFinished', W);
            Screen('Flip', W, QStartTime + TimeOut);
            
            PsychPortAudio('Stop', SoundCardRecord);
            VerbalResponse = PsychPortAudio('GetAudioData', SoundCardRecord);
            AudioData{QCnt,1} = transpose(VerbalResponse); % Store audio data in array
        end
        
        %Check/Present ITI STARTLE
        if (ITIProbeTime(Version,i) >0)
            StartleProbe(ITIStartTime+ITIProbeTime(Version,i), ITISTLEvents(Version,i), SoundCardPlay, DIO, PortB, UseIO)
        end
        
        %Prepare Cue
        switch CueTypes(Version,i)
            case {10}
                Screen('DrawTexture', W, CueTextures(1,1));
            case {20};
                Screen('DrawTexture', W, CueTextures(1,2));
            case {30}
                Screen('DrawTexture', W, CueTextures(1,3));
        end
        Screen('DrawingFinished', W);
        
        %Check/Present ITI SHOCK
        if (ITIShockTime(Version,i)>0)
            WaitSecs('UntilTime', ITIStartTime+ITIShockTime(Version,i));
            Shock(DIO,PortC,ShockIntensity, PortB, ShockEvent, UseIO)
        end
        
        %CUE PERIOD
        CueStartTime= Screen('Flip', W, ITIStartTime + ITIDurs(Version,i));
        MarkEvent(DIO, PortB, CueTypes(Version,i), UseIO)
        
        %Check/Measure Cue Question
        if (CueQuestion(Version,i) == 1)
            QCnt = QCnt +1; % Add 1 to question counter
            
            switch CueTypes(Version,i)
                case {10} % N
                    Screen('DrawTexture', W, CueTextures(2,1));
                    RecordCondition{QCnt,1} = 'Ncue'; %
                case {20} % P
                    Screen('DrawTexture', W, CueTextures(2,2));
                    RecordCondition{QCnt,1} = 'Pcue'; %
                case {30} % U
                    Screen('DrawTexture', W, CueTextures(2,3));
                    RecordCondition{QCnt,1} = 'Ucue'; %
            end
            Screen('DrawingFinished', W);
            QStartTime = Screen('Flip', W, CueStartTime + CueQTime);
            MarkEvent(DIO, PortB, QuestionMark, UseIO)

            PsychPortAudio('Start', SoundCardRecord); % Start recording
            
            %Prepare Cue for after question
            switch CueTypes(Version,i)
                case {10}
                    Screen('DrawTexture', W, CueTextures(1,1));
                case {20}
                    Screen('DrawTexture', W, CueTextures(1,2));
                case {30}
                    Screen('DrawTexture', W, CueTextures(1,3));
            end
            Screen('DrawingFinished', W);
            Screen('Flip', W, QStartTime + TimeOut);  %waited till end of Timeout
            
            PsychPortAudio('Stop', SoundCardRecord);
            VerbalResponse = PsychPortAudio('GetAudioData', SoundCardRecord);
            AudioData{QCnt,1} = transpose(VerbalResponse); % Store audio data in array
        end
        
        %Check/Present Cue STARTLE
        if (CueProbes(Version,i) == 1)
            StartleProbe(CueStartTime+CueProbeTime, CueSTLEvents(Version,i), SoundCardPlay, DIO, PortB, UseIO)
        end
        
        %Check/Present SHOCK
        if (CueShockTime(Version,i) > 0)
            WaitSecs('UntilTime', CueStartTime+CueShockTime(Version,i));
            Shock(DIO,PortC,ShockIntensity, PortB, ShockEvent, UseIO)
        end
        
        switch i  %Checks for block ends and breaks
            case{6,12,18,24,30,36}
                switch CueTypes(Version, i+1)
                    case{10}
                        PauseMsg(W,'End of Set.\nPlease Wait For Experimenter',[], [], BlackTexture, CueStartTime + CueDur);%pause for break that restarts after pause
                        ITIStartTime = WaitMsg(W, 'No Shocks', 9, [], [], ITITextures(1,1), 0);
                    case{20}
                        PauseMsg(W,'End of Set.\nPlease Wait For Experimenter',[], [], BlackTexture, CueStartTime + CueDur);%pause for break that restarts after pause
                        ITIStartTime = WaitMsg(W, 'Shock at End of Red Square', 9, [], [], ITITextures(1,2), 0);  %NOTE:  THIS CAN NOW TAKE ITIIMAGE?  WAIT MESSAGE AND PAUSE MESSAGE SHOULD RETUR FLIP TIMNE
                    case{30}
                        PauseMsg(W,'End of Set.\nPlease Wait For Experimenter',[], [], BlackTexture, CueStartTime + CueDur);%pause for break that restarts after pause
                        ITIStartTime = WaitMsg(W, 'Shocks at Any Time', 9, [], [], ITITextures(1,3), 0);
                end
                
            case{42}  %Wrap up after last trial
                WaitMsg(W, 'Thank you. Task Complete!', 4, [], [], BlackTexture, CueStartTime + CueDur )
                PauseMsg(W,'Turn box to STANDBY\n\nStop recording physiology NOW!\n\nPress space bar to end task.',[], [], BlackTexture, 0);
                
            otherwise
                %Prepare ITI for Trial i+1 (next trial)
                
                switch CueTypes(Version,i+1)
                    case {10}
                        Screen('DrawTexture', W, ITITextures(1,1))
                    case {20}
                        Screen('DrawTexture', W, ITITextures(1,2))
                    case {30}
                        Screen('DrawTexture', W, ITITextures(1,3))
                end
                Screen('DrawingFinished', W);
                
                ITIStartTime = Screen('Flip', W, CueStartTime + CueDur);
        end
    end
    
    %% POST TASK ISSUES TO CLOSE PTB
    Screen('CloseAll'); %Close onscreen and offscreen windows and textures
    PsychPortAudio('Close', SoundCardPlay); % Close SoundCardPlay
    PsychPortAudio('Close', SoundCardRecord); % Close SoundCardPlay
    Priority(0); %Shutdown realtime mode
    clear mex  %clear io32()
    ShowCursor; %Show cursor again, if it has been disabled
    
    %% Save participant's audio response (.wav) files  locally
    % Save VoiceTest wav file
    fprintf('\n\nSaving audio data files.\nDo not close Matlab yet.\n\n')
    DataSave(transpose(VoiceTest), ['Kaye1_VoiceTest',num2str(Day),'_',SubID,'.wav'], ['C:\Local\LocalKaye1\QuestionData\', SubID]);
    
    % Save Audio Data Files
    for i = 1:QCnt
        DataSave(AudioData{i,1}, [FileName '_' num2str(i) num2str(RecordCondition{i,1}) '.wav'], ['C:\Local\LocalKaye1\QuestionData\' SubID]);
    end
    
    %% Copy cnt and wav data files to server
    %FOR LOOP FOR MOVING ALL QUESTION DATA TO SERVER FILE BY FILE 1-14
    fprintf('\n\nCopying audio data files to the server.\nDo not close Matlab yet.\n\n')
    for i=1:QCnt
        DataCopy([FileName '_' num2str(i) num2str(RecordCondition{i,1}) '.wav'], ['C:\Local\LocalKaye1\QuestionData\' SubID], ['P:\StudyData\Kaye1\RawData\' SubID])
    end
    fprintf('\n\nCopying neuroscan files to the server.\nDo not close Matlab yet.\n\n')
    DataCopy ([FileName '.cnt'], 'N:\Kaye1\Kaye1RawData\', ['P:\StudyData\Kaye1\RawData\' SubID]);
    fprintf('\n\nCopying complete. Data successfully copied to the server!\n\n')

catch TheError
    
    if exist ('SoundCardPlay', 'var')
        PsychPortAudio('Close', SoundCardPlay); % Close SoundCardPlay
    end
    
    if exist ('SoundCardRecord', 'var')
        PsychPortAudio('Close', SoundCardRecord); % Close SoundCardRecord
    end
    
    Screen('CloseAll'); %Close display windows
    Priority(0); %Shutdown realtime mode
    ShowCursor; %Show cursor again, if it has been disabled
    ListenChar(1);
    clear mex  %clear io32()
    
    %try to save wav files in case of PTB error
    for i = 1:QCnt
        DataSave(AudioData{i,1}, [FileName '_' num2str(i) num2str(RecordCondition{i,1}) '.wav'], ['C:\Local\LocalKaye1\QuestionData\' SubID]);
    end
    
    rethrow(TheError);
end