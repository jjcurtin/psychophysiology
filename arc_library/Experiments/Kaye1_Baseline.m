function Kaye1_Baseline
%SubID = ABCD or EABCD (E added 4/29/15)
%E = 5: 2nd wave of subjects after all 4-digit SubID cells were full
%A = Sequence (1 = NPU 2 = IAPS, as first task of day)
%B = Sex (0=Female;1=Male)
%C = Version (usually called script order- refers to trial/probe structure in task)
%D = SubID
%
%Day = 1 or 2
%Time = 1 (pretask) or 2 (posttask)

%Kaye1 baseline task
%JTK, DEB & KM

%% Generate Startle Probe Presentation Time
SubID = input('Enter SubID (4 or 5 digits)\n', 's'); %RA input SubID as str
Day = input('Enter Day (1 or 2)\n'); %RA input SubID as double
Time = input('Enter Time (1 or 2)\n'); %RA input Time as double

%Define all Trial Parameters
NumTrials = 9;
ProbeTime = zeros(4,NumTrials); %Make ProbeTimeArray
ProbeTime(1,:) = str2double(SubID);
ProbeTime(2,:) = 1:NumTrials; %Trial Number 1 to 9

rng('shuffle'); %random seed so random() outputs new numbers each time matlab is restarted. This is important, do not delete.
for i=1:NumTrials
    ProbeTime(3,i) = round(random('unif', 13,20)); %Probe Time
end

HabitSTLEvent = 100; %Habituation event code (trial 1-3)
BaseSTLEvent = 101;  %Baseline event code (trial 4-9)
ProbeTime(4,1:3) = HabitSTLEvent;
ProbeTime(4,4:NumTrials) = BaseSTLEvent;

%% Check that the appropriate time/day baseline task is being run
%Create Path to Local Directory on Computer
RootPath = fileparts(which('Kaye1_Baseline.m'));
LocalPath = ['C:\Local\LocalKaye1\BaselineData\' SubID '\' ];

switch Day
    case{1} %Day = 1
        FileName = ['Kaye1_Base_D1_T1_' SubID '.dat'];
        OutFile = [LocalPath FileName];
        if Time == 1 %First Baseline
            if  exist(fullfile(OutFile),'file')
                error('Filename: %s exists.  This must be an error!', FileName)
            end
        end
        if Time == 2 %Second Baseline
            error('You may have entered the wrong Day or Time. This must be an error!')
        end
        
    case{2} %Day = 2
        FileName = ['Kaye1_Base_D2_T1_' SubID '.dat'];
        OutFile = [LocalPath FileName];
        if Time == 1 %First Baseline
            if  exist(fullfile(OutFile),'file')
                error('Filename: %s exists.  This must be an error!', FileName)
            end
            if  exist(fullfile([LocalPath 'Kaye1_Base_D1_T2_' SubID '.dat']),'file')
                error('Filename: %s does NOT exist. This must be an error!', ['Kaye1_Base_D1_T2_' SubID '.dat'])
            end
        end
        if Time == 2 %Second Baseline
            if  ~exist(fullfile(OutFile),'file')
                error('Filename: %s does NOT exist. This must be an error!', FileName)
            end
            FileName = ['Kaye1_Base_D2_T2_' SubID '.dat'];
            OutFile = [LocalPath FileName];
            if  exist(fullfile(OutFile),'file')
                error('Filename: %s exists. This must be an error!', FileName)
            end
        end
    otherwise
        error('Day (%d) must be 1 or 2', Day)
end

try
    %% Set up DIO card (PortA = Button Box; PortB =event codes to neuroscan; PortC = shock)
    [DIO PortA PortB PortC UseIO] = ConfigIO;
    
    %% Load Startle Probe
    InitializePsychSound(1);  %1=set for low-latency
    [y] = wavread('wnprobe');  %assumes file is in path
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
    HideCursor;
    Screen('TextFont',W, 'Calibri'); % Arial font default
    Screen('TextSize',W, 36); %36 pt font
    TxtColor = [255 255 255]; %Set to White
    BackColor = [0 0 0]; %Set to Black
    
    %load into memory for later high time precision use
    WaitSecs(.1);
    GetSecs;
    KbCheck;
    
    %% LOAD IMAGE FILES
    FixationImg =  imread([RootPath '/Kaye1/FixationCross.JPG'], 'JPG');
    FixTexture = Screen('MakeTexture', W, FixationImg);
    clear FixationImg
    
    %Black screen for block transitions
    BlackImg =  imread([RootPath '/Kaye1/BlackImage.JPG'], 'JPG');
    BlackTexture = Screen('MakeTexture', W, BlackImg);
    clear BlackImg
    
    %% BASELINE TASK & HABITUATION
    %Wait until key press to start task
    EventTime = PauseMsg(W,'Start saving physiology data NOW\n\nPress space bar to start', TxtColor, BackColor, FixTexture, 0);
    
    ITI = 5; %present first habituation probe 5 seconds into period
    
    for i=1:NumTrials  %loop for habituation startles
        EventTime = StartleProbe(EventTime+ITI, ProbeTime(4,i), SoundCardPlay, DIO, PortB, UseIO);
        ITI = ProbeTime(3,i);
    end
    
    WaitSecs(2)
    PauseMsg(W,'Stop recording physiology NOW\n\nPress space bar to end task', TxtColor, BackColor, BlackTexture, 0);
    
    %% Write dat file to local computer with Trial #, EventCode, and ITI
    OutFile = transpose(ProbeTime);
    FileName = ['Kaye1_Base_D' num2str(Day) '_T' num2str(Time) '_' SubID];
    DataSave(OutFile, [FileName  '.dat'], LocalPath);
    WaitSecs(.5);
    
    %% Save baseline cnt and dat files local computer and copy to server
    fprintf('\n\nCopying files to the server.\nDo not close Matlab yet.\n\n')
    DataCopy ([FileName '.cnt'], 'N:\Kaye1\Kaye1RawData\', ['P:\StudyData\Kaye1\RawData\' SubID]);
    DataCopy ([FileName '.dat'], LocalPath, ['P:\StudyData\Kaye1\RawData\' SubID]);
    fprintf('\n\nCopying complete. Data successfully copied to the server!\n\n')
    
    %% POST TASK ISSUES
    WaitSecs(4);
    Screen('CloseAll'); %Close display windows
    PsychPortAudio('Close', SoundCardPlay);
    Priority(0); %Shutdown realtime mode
    clear mex  %clear io32()
    ShowCursor; %Show cursor again, if it has been disabled
    
catch TheError
    
    if exist ('SoundCardPlay', 'var')
        PsychPortAudio('Close', SoundCardPlay); %Close SoundCardPlay
    end
    
    Screen('CloseAll'); %Close display windows
    Priority(0); %Shutdown realtime mode
    ShowCursor; %Show cursor again, if it has been disabled
    ListenChar(1);
    clear mex  %clear io32()
    
    %try to save dat files in case of PTB error
    DataSave(OutFile, [FileName  '.dat'], LocalPath);
    
    rethrow(TheError);
end