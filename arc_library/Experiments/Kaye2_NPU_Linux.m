function Kaye2_NPU
%Kaye2 NPU Task
%SubID = ABCDE
%A = Sequence (1 = Control group real sub, 9 = training)
%B = Sex (0=Female;1=Male)
%C = Version (usually called script order- refers to trial/probe structure in task)
%D = SubID
%E = SubID
%
%Day = 1 or 2
%Training = y or n

% JTK

%% Confirm correct Program is being run for the correct SubID
% Ask for SubID, Day, and Training
SubID = input('Enter SubID (5 digits)\n', 's'); % RA input SubID as str
Day = input('Enter Day (1 or 2)\n'); % RA input Day as double
Training = input('Enter Training(y or n)\n', 's'); % RA input Training as str

% Verify Version range = 1-4
if Training == 'n'
    Version = mod(floor(str2double(SubID)/10),10); % Calculate proper version(order) based on SubID
    if all(Version ~= 1:4)
        error('There is in error with the SubID, the Tens digit should be 1, 2, 3 or 4. Confirm the correct SubID was entered!')
    end
elseif Training == 'y'
    Version = 1; %If training, set version to 1, to allow fake SubIDs (e.g., 99999)
else
	error('There is in error with the Training. Must be y or n.')
end

% Check that correct Day is being run
switch Day
    case{1} %Day = 1
        FileName = ['Kaye2_NPU1_' SubID]; %assumes that RawData folder has already been made prestudy!
        if  exist(fullfile('/home/ra/LocalCurtin/LocalKaye2/QuestionData/',SubID,['Kaye2_VoiceTest1_',SubID,'.wav']),'file')
            error('Filename: %s exists.  This must be an error!', ['Kaye2_VoiceTest',num2str(Day),'_',SubID,'.wav'])
        end

    case{2} %Day = 2
        FileName = ['Kaye2_NPU2_' SubID ]; %assumes that RawData folder has already been made prestudy!
        if  exist(fullfile('/home/ra/LocalCurtin/LocalKaye2/QuestionData/',SubID,['Kaye2_VoiceTest2_',SubID,'.wav']),'file')
            error('Filename: %s exists.  This must be an error!', ['Kaye2_VoiceTest2_',SubID,'.wav'])
        end

        if  ~exist(fullfile('/home/ra/LocalCurtin/LocalKaye2/QuestionData/',SubID,['Kaye2_VoiceTest1_',SubID,'.wav']),'file')
            error('Filename: %s does not exist.  You may have inputted the wrong day!', ['Kaye2_VoiceTest1_',SubID,'.wav'])
        end

    otherwise
        error('Day (%d) must be 1 or 2', Day)
end

try
    %% Set up DIO card
    %PortA = Shock Box; PortB = Event Codes to Grael/Curry; PortC = Input
    [DIO, PortA, PortB, PortC, UseIO] = ConfigIO;
    ShockPort = PortA;
    EventPort = PortB;
    ButtonPort = PortC;
    
    
    %% Define all Trial Parameters
    NumTrials = 42; %Should = 42
    
    %Cue info
    CueDur = 5;   %Cues presented for 5s
    %1 = NS, 3 = P, 5 = U
    CueTypes(1,:) = [5 5 5 5 5 5 1 1 1 1 1 1 3 3 3 3 3 3 1 1 1 1 1 1 3 3 3 3 3 3 1 1 1 1 1 1 5 5 5 5 5 5]; %A1
    CueTypes(2,:) = [3 3 3 3 3 3 1 1 1 1 1 1 5 5 5 5 5 5 1 1 1 1 1 1 5 5 5 5 5 5 1 1 1 1 1 1 3 3 3 3 3 3]; %A2
    CueTypes(3,:) = [5 5 5 5 5 5 1 1 1 1 1 1 3 3 3 3 3 3 1 1 1 1 1 1 3 3 3 3 3 3 1 1 1 1 1 1 5 5 5 5 5 5]; %B1
    CueTypes(4,:) = [3 3 3 3 3 3 1 1 1 1 1 1 5 5 5 5 5 5 1 1 1 1 1 1 5 5 5 5 5 5 1 1 1 1 1 1 3 3 3 3 3 3]; %B2
    
    %Cue probe info
    %0 = No Cue Probe; 1 = Yes Cue Probe;
    CueProbeTime = 4.5; %time for  probe durnig cue (4.5sec)
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
    
    %% EDIT EVENT CODES
    %Event codes
    ShockEvent = 63;
    HabitSTLEvent = 10;
    QuestionMark = 9;
    NPUStart = 55;
    
    %Cue startle probe event codes: 11,13,15 (odd numbers)
    CueSTLEvents = CueTypes + 10; %A = 1 (probe), %B= 1(NoShock), 3(Predictable), 5(Unpredictable)
    CueSTLEvents(CueProbes==0) = 0; %no startle on cue
    
    %ITI startle probe event codes: 12,14,16 (even numbers)
    ITISTLEvents = CueTypes + 11;%A = 1 (probe), %B= 2(NoShock), 4(Predictable), 6(Unpredictable)
    ITISTLEvents(ITIProbeTime==0) = 0;%no startle on ITI
    
    %% Get info about shock intensity
    ShockIntensity = dlmread(fullfile('/home/ra/LocalCurtin/LocalKaye2/ShockAssessments',SubID, ['ShockRatings_Kaye2_' SubID '.dat']));
    
    %Only need one value from the array
    ShockIntensity = ShockIntensity(end,2); % last (26th) row, 2nd column holds max shock value to be administered
    
    %% START SCREEN
    AssertOpenGL;   %Check if PTB is properly installed on your system.
    W = Screen('OpenWindow', 0, 0, [], 32, 2); %Open Window and configure text options
    Screen('TextSize',W, 50); %50 pt font
    Screen('TextFont',W, 'Calibri'); % Calibri font default
    HideCursor(W);
    TxtColor = [255 255 255]; %Set to White
    BackColor = [0 0 0]; %Set to Black
    
    %load into memory for later high time precision use
    WaitSecs(.1);
    GetSecs;
    KbCheck;
    
    %% Preparing all images
    RootPath = fileparts(which('Kaye2_NPU.m'));
    FileType = 'jpg';
    
    %Cues stored in cell array (CueImg) or (ITIImg as question (1=no question, 2=question) X CueType (1-3)
    CueImg = cell(2,3);
    CueImg{1,1} =  imread([RootPath '/Kaye2/NPU/CueN_1365x768.jpg'], FileType);
    CueImg{1,2} =  imread([RootPath '/Kaye2/NPU/CueP_1365x768.jpg'], FileType);
    CueImg{1,3} =  imread([RootPath '/Kaye2/NPU/CueU_1365x768.jpg'], FileType);
    CueImg{2,1} =  imread([RootPath '/Kaye2/NPU/CueNQ_1365x768.jpg'], FileType);
    CueImg{2,2} =  imread([RootPath '/Kaye2/NPU/CuePQ_1365x768.jpg'], FileType);
    CueImg{2,3} =  imread([RootPath '/Kaye2/NPU/CueUQ_1365x768.jpg'], FileType);
    CueTextures = zeros(2,3);
    for i = 1:2
        for j = 1:3
            CueTextures(i,j) = Screen('MakeTexture', W, CueImg{i,j});
        end
    end
    clear CueImg
    
    %ITI image
    ITIImg = cell(2,3);
    ITIImg{1,1} =  imread([RootPath '/Kaye2/NPU/ITIN_1365x768.jpg'], FileType);
    ITIImg{1,2} =  imread([RootPath '/Kaye2/NPU/ITIP_1365x768.jpg'], FileType);
    ITIImg{1,3} =  imread([RootPath '/Kaye2/NPU/ITIU_1365x768.jpg'], FileType);
    ITIImg{2,1} =  imread([RootPath '/Kaye2/NPU/ITINQ_1365x768.jpg'], FileType);
    ITIImg{2,2} =  imread([RootPath '/Kaye2/NPU/ITIPQ_1365x768.jpg'], FileType);
    ITIImg{2,3} =  imread([RootPath '/Kaye2/NPU/ITIUQ_1365x768.jpg'], FileType);
    ITITextures = zeros(2,3);
    for i = 1:2
        for j = 1:3
            ITITextures(i,j) = Screen('MakeTexture', W, ITIImg{i,j});
        end
    end
    clear ITIImg
    
    %ITI Fixation Cross for habituation period
    ITIFixImg =  imread([RootPath '/Kaye2/FixationCross_1365x768.jpg'], 'JPG');
    ITIFixTexture = Screen('MakeTexture', W, ITIFixImg);
    clear ITIFixImg
    
    %Black screen for block transitions
    BlackImg =  imread([RootPath '/Kaye2/BlackImage.jpg'], 'JPG');
    BlackTexture = Screen('MakeTexture', W, BlackImg);
    clear BlackImg
    
    %% Present Task Instructions
    InstructPath = [RootPath '/Kaye2/NPU/'];
    NSlides = 63; %63 for Kaye2
    ScreenDimensions = '1365x768';
    TaskInstructions(InstructPath, NSlides, ButtonPort, DIO, W, FileType, ScreenDimensions);
    
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
    SoundCard = PsychPortAudio('GetDevices'); %Get sound card devices if not using default
    Index = not(cellfun('isempty',strfind({SoundCard.DeviceName},'USB Audio CODEC: USB Audio'))); %Replace string with sound card name
    SoundCardID = SoundCard(Index).DeviceIndex; %Get sound card deviceID for PsychPortAudio(Open)

    
    %Record Audio Response and PlayBack to make sure can hear participant well enough
    VoiceTest = TestVerbalInput(W, ButtonPort, DIO, SoundCardID); % Run TestVerbalInput
    
    %% Load Startle Probe
    [y] = psychwavread('wnprobe.wav');  %assumes file is in path
    Noise = y';
    PsychPortAudio('Verbosity', 10);
    
    %% Prep Task
    Priority(2); %Enable realtime-scheduling for real trial
    HabitTime = PauseMsg(W,'Turn the box to READY\n\nStart recording physiology NOW\n\nPress space bar to begin task', TxtColor, BackColor, ITIFixTexture, 0); %need to think about if want to use pause message or something else at VERY beginging of task
    MarkEvent(DIO, EventPort, NPUStart, UseIO); % MarkEvent to identify NPU Task in case recorded in same *.dat file as baseline task
    
    %% PRE-TASK BASELINE/HABITUATION
    HabitITIDur = 5;  %present first habituation probe 5 seconds into period
    
    SoundCardPlay = PsychPortAudio('Open', SoundCardID, modePlay, reqlatencyclassPlay, freq, nchannels);  % This returns a handle to the audio device. Open sound card in play back mode.
    PsychPortAudio('FillBuffer', SoundCardPlay, Noise); % From typical startle studies

    % Play 3 habituation startles
    for i=1:3  %loop for habituation startles
        HabitTime = StartleProbe(HabitTime+HabitITIDur, HabitSTLEvent, SoundCardPlay, DIO, EventPort, UseIO);
        HabitITIDur = 13; %separate all subsequent probes by 13s
    end
    
    WaitSecs(2)
    
    %% Start First Block
    switch CueTypes(Version,1)
        case{1}
            WaitMsg(W, 'No Shocks', 9, TxtColor, BackColor)
            Screen('DrawTexture', W, ITITextures(1,1));
        case{3}
            WaitMsg(W, 'Shock at End of Red Square', 9, TxtColor, BackColor)
            Screen('DrawTexture', W, ITITextures(1,2));
        case{5}
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
                case {1} % N
                    Screen('DrawTexture', W, ITITextures(2,1));
                    RecordCondition{QCnt,1} = 'Niti'; %
                case {3} % P
                    Screen('DrawTexture', W, ITITextures(2,2));
                    RecordCondition{QCnt,1} = 'Piti'; %
                case {5} % U
                    Screen('DrawTexture', W, ITITextures(2,3));
                    RecordCondition{QCnt,1} = 'Uiti'; %
            end
            Screen('DrawingFinished', W);
            QStartTime = Screen('Flip', W, ITIStartTime + ITIQuestionTime(Version,i));
            MarkEvent(DIO, EventPort, QuestionMark, UseIO)
            
            PsychPortAudio('Start', SoundCardRecord); % Start recording
            
            %Prepare ITIImg for after Question
            switch CueTypes(Version,i)
                case {1}
                    Screen('DrawTexture', W, ITITextures(1,1));
                case {3}
                    Screen('DrawTexture', W, ITITextures(1,2));
                case {5}
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
            StartleProbe(ITIStartTime+ITIProbeTime(Version,i), ITISTLEvents(Version,i), SoundCardPlay, DIO, EventPort, UseIO)
        end
        
        %Prepare Cue
        switch CueTypes(Version,i)
            case {1}
                Screen('DrawTexture', W, CueTextures(1,1));
            case {3};
                Screen('DrawTexture', W, CueTextures(1,2));
            case {5}
                Screen('DrawTexture', W, CueTextures(1,3));
        end
        Screen('DrawingFinished', W);
        
        %Check/Present ITI SHOCK
        if (ITIShockTime(Version,i)>0)
            WaitSecs('UntilTime', ITIStartTime+ITIShockTime(Version,i));
            Shock(DIO,ShockPort,ShockIntensity, EventPort, ShockEvent, UseIO)
        end
        
        %CUE PERIOD
        CueStartTime= Screen('Flip', W, ITIStartTime + ITIDurs(Version,i));
        MarkEvent(DIO, EventPort, CueTypes(Version,i), UseIO)
        
        %Check/Measure Cue Question
        if (CueQuestion(Version,i) == 1)
            QCnt = QCnt +1; % Add 1 to question counter
            
            switch CueTypes(Version,i)
                case {1} % N
                    Screen('DrawTexture', W, CueTextures(2,1));
                    RecordCondition{QCnt,1} = 'Ncue'; %
                case {3} % P
                    Screen('DrawTexture', W, CueTextures(2,2));
                    RecordCondition{QCnt,1} = 'Pcue'; %
                case {5} % U
                    Screen('DrawTexture', W, CueTextures(2,3));
                    RecordCondition{QCnt,1} = 'Ucue'; %
            end
            Screen('DrawingFinished', W);
            QStartTime = Screen('Flip', W, CueStartTime + CueQTime);
            MarkEvent(DIO, EventPort, QuestionMark, UseIO)
            
            PsychPortAudio('Start', SoundCardRecord); % Start recording
            
            %Prepare Cue for after question
            switch CueTypes(Version,i)
                case {1}
                    Screen('DrawTexture', W, CueTextures(1,1));
                case {3}
                    Screen('DrawTexture', W, CueTextures(1,2));
                case {5}
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
            StartleProbe(CueStartTime+CueProbeTime, CueSTLEvents(Version,i), SoundCardPlay, DIO, EventPort, UseIO)
        end
        
        %Check/Present SHOCK
        if (CueShockTime(Version,i) > 0)
            WaitSecs('UntilTime', CueStartTime+CueShockTime(Version,i));
            Shock(DIO,ShockPort,ShockIntensity, EventPort, ShockEvent, UseIO)
        end
        
        switch i  %Checks for block ends and breaks
            case{6,12,18,24,30,36}
                switch CueTypes(Version, i+1)
                    case{1}
                        PauseMsg(W,'End of Set.\nPlease Wait For Experimenter',[], [], BlackTexture, CueStartTime + CueDur);%pause for break that restarts after pause
                        ITIStartTime = WaitMsg(W, 'No Shocks', 9, [], [], ITITextures(1,1), 0);
                    case{3}
                        PauseMsg(W,'End of Set.\nPlease Wait For Experimenter',[], [], BlackTexture, CueStartTime + CueDur);%pause for break that restarts after pause
                        ITIStartTime = WaitMsg(W, 'Shock at End of Red Square', 9, [], [], ITITextures(1,2), 0);  %NOTE:  THIS CAN NOW TAKE ITIIMAGE?  WAIT MESSAGE AND PAUSE MESSAGE SHOULD RETUR FLIP TIMNE
                    case{5}
                        PauseMsg(W,'End of Set.\nPlease Wait For Experimenter',[], [], BlackTexture, CueStartTime + CueDur);%pause for break that restarts after pause
                        ITIStartTime = WaitMsg(W, 'Shocks at Any Time', 9, [], [], ITITextures(1,3), 0);
                end
                
            case{42}  %Wrap up after last trial
                WaitMsg(W, 'Thank you. Task Complete!', 4, [], [], BlackTexture, CueStartTime + CueDur )
                PauseMsg(W,'Turn box to STANDBY\n\nStop recording physiology NOW!\n\nPress space bar to end task.',[], [], BlackTexture, 0);
                
            otherwise
                %Prepare ITI for Trial i+1 (next trial)
                
                switch CueTypes(Version,i+1)
                    case {1}
                        Screen('DrawTexture', W, ITITextures(1,1))
                    case {3}
                        Screen('DrawTexture', W, ITITextures(1,2))
                    case {5}
                        Screen('DrawTexture', W, ITITextures(1,3))
                end
                Screen('DrawingFinished', W);
                
                ITIStartTime = Screen('Flip', W, CueStartTime + CueDur);
        end
    end
    
    %% POST TASK ISSUES TO CLOSE PTB
    Screen('CloseAll'); %Close onscreen and offscreen windows and textures
    PsychPortAudio('Close', SoundCardPlay); % Close SoundCardPlay
    PsychPortAudio('Close', SoundCardRecord); % Close SoundCardRecord
    Priority(0); %Shutdown realtime mode
    ShowCursor(W); %Show cursor again, if it has been disabled
    
    %% Save participant's audio response (.wav) files  locally
    % Save VoiceTest wav file
    fprintf('\n\nSaving audio data files.\nDo not close Matlab yet.\n\n')
    DataSave(transpose(VoiceTest), ['Kaye2_VoiceTest' num2str(Day) '_' SubID '.wav'], ['/home/ra/LocalCurtin/LocalKaye2/QuestionData/' SubID '/']);
    
    % Save Audio Data Files
    for i = 1:QCnt
        DataSave(AudioData{i,1}, [FileName '_' num2str(i) num2str(RecordCondition{i,1}) '.wav'], ['/home/ra/LocalCurtin/LocalKaye2/QuestionData/' SubID '/']);
    end
    
    %% Copy wav data files to server
    %FOR LOOP FOR MOVING ALL QUESTION DATA TO SERVER FILE BY FILE 1-14
    fprintf('\n\nCopying audio data files to the server.\nDo not close Matlab yet.\n\n')
    for i=1:QCnt
        DataCopy([FileName '_' num2str(i) num2str(RecordCondition{i,1}) '.wav'], ['/home/ra/LocalCurtin/LocalKaye2/QuestionData/' SubID], ['/home/ra/CurtinServer/KAYE2RawData/' SubID '/'])
    end     
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
    ShowCursor(W); %Show cursor again, if it has been disabled
    ListenChar(1);
    
    %try to save wav files in case of PTB error
    for i = 1:QCnt
        DataSave(AudioData{i,1}, [FileName '_' num2str(i) num2str(RecordCondition{i,1}) '.wav'], ['/home/ra/LocalCurtin/LocalKaye2/QuestionData/' SubID]);
    end
    
    rethrow(TheError);
end