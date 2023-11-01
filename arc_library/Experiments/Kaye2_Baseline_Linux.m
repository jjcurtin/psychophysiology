function Kaye2_Baseline_Linux
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

%% Check that the appropriate time/day baseline task is being run
%Create Path to Local Directory on Computer
RootPath = fileparts(which('Kaye2_Baseline.m'));
LocalPath = ['/home/ra/LocalCurtin/LocalKaye2/BaselineData/' SubID '/' ];

switch Day
    case{1} %Day = 1
        FileName = ['Kaye2_Base_D1_Trials_' SubID];
        CheckFile = [LocalPath FileName '.dat'];
        if  exist(fullfile(CheckFile),'file')
            error('Filename: %s exists.  This must be an error!', FileName)
        end
        
    case{2} %Day = 2
        FileName = ['Kaye2_Base_D2_Trials_' SubID];
        CheckFile = [LocalPath FileName '.dat'];
        if  exist(fullfile(CheckFile),'file')
            error('Filename: %s exists.  This must be an error!', FileName)
        end
        if  ~exist(fullfile([LocalPath 'Kaye2_Base_D1_Trials_' SubID '.dat']),'file')
            error('Filename: %s does NOT exist. This must be an error!', ['Kaye2_Base_D1_Trials_' SubID '.dat'])
        end
        
otherwise
    error('Day (%d) must be 1 or 2', Day)
end

%% Set up DIO card
%PortA = Shock Box; PortB = Event Codes to Grael/Curry; PortC = Burron Box Input
[DIO, PortA, PortB, PortC, UseIO] = ConfigIO;
EventPort = PortB; %Output

%Define all Trial Parameters
NumTrials = 9;
ProbeTime = zeros(4,NumTrials); %Make ProbeTimeArray
ProbeTime(1,:) = str2double(SubID);
ProbeTime(2,:) = 1:NumTrials; %Trial Number 1 to 9

rng('shuffle'); %random seed so random() outputs new numbers each time matlab is restarted. This is important, do not delete.
for i=1:NumTrials
    ProbeTime(3,i) = round(random('unif', 13,20)); %Probe Time
end

%Define Event Codes
HabitSTLEvent = 10; %Habituation event code (trial 1-3)
BaseSTLEvent = 11;  %Baseline event code (trial 4-9)
ProbeTime(4,1:3) = HabitSTLEvent;
ProbeTime(4,4:NumTrials) = BaseSTLEvent;

BaselineStart = 54;
try
    %% Load Startle Probe
    InitializePsychSound(1);  %1=set for low-latency
    SoundCard = PsychPortAudio('GetDevices'); %Get sound card devices if not using default
    Index = not(cellfun('isempty',strfind({SoundCard.DeviceName},'USB Audio CODEC: USB Audio'))); %Replace string with sound card name
    SoundCardID = SoundCard(Index).DeviceIndex; %Get sound card deviceID for PsychPortAudio(Open)
    [y] = psychwavread('wnprobe.wav');  %updated from wavread, Matlab2015b not backward compatible
    Noise = y';
    modePlay = 1; %audio play back only
    freq = 44100; %a frequency of 44100 Hz
    reqlatencyclassPlay = 2; %for low latency (agressive but consider 3)
    nchannels = 2; %2 sound channels for stereo capture
    PsychPortAudio('Verbosity', 10);
    SoundCardPlay = PsychPortAudio('Open', SoundCardID, modePlay, reqlatencyclassPlay, freq, nchannels);  %This returns a handle to the audio device. Open sound card in play back mode.
    PsychPortAudio('FillBuffer', SoundCardPlay, Noise);
    
    %% START SCREEN
    AssertOpenGL;   %Check if PTB is properly installed on your system.
    W = Screen('OpenWindow', 0, 0, [], 32, 2);  %Open Window and configure text options
    HideCursor(W); %On Linux include W screen pointer, and call after first call of screen
    Screen('TextFont',W, 'Calibri'); % Calibri font default
    Screen('TextSize',W, 50); %50 pt font
    TxtColor = [255 255 255]; %Set to White
    BackColor = [0 0 0]; %Set to Black
    
    %load into memory for later high time precision use
    WaitSecs(.1);
    GetSecs;
    KbCheck;
    
    %% LOAD IMAGE FILES
    FixationImg =  imread([RootPath '/Kaye2/FixationCross_1365x768.jpg'], 'JPG');
    FixTexture = Screen('MakeTexture', W, FixationImg);
    clear FixationImg
    
    %Black screen for block transitions
    BlackImg =  imread([RootPath '/Kaye2/BlackImage.jpg'], 'JPG');
    BlackTexture = Screen('MakeTexture', W, BlackImg);
    clear BlackImg
    
    %% BASELINE TASK & HABITUATION
    %Wait until key press to start task
    EventTime = PauseMsg(W,'Start saving physiology data NOW\n\nPress space bar to start', TxtColor, BackColor, FixTexture, 0);
    MarkEvent(DIO, EventPort, BaselineStart, UseIO); % MarkEvent to identify Baseline Task in case recorded in same *.dat file as baseline task

    
    ITI = 5; %present first habituation probe 5 seconds into period
    
    for i=1:NumTrials  %loop for habituation startles
        EventTime = StartleProbe(EventTime+ITI, ProbeTime(4,i), SoundCardPlay, DIO, EventPort, UseIO);
        ITI = ProbeTime(3,i);
    end
    
    WaitSecs(2)
    PauseMsg(W,'Stop recording physiology NOW\n\nPress space bar to end task', TxtColor, BackColor, BlackTexture, 0);    
    
    %% POST TASK ISSUES
    WaitSecs(4);
    Screen('CloseAll'); %Close display windows
    PsychPortAudio('Close', SoundCardPlay);
    Priority(0); %Shutdown realtime mode
    ShowCursor(W); %Show cursor again, if it has been disabled
    
    %% Write dat file to local computer with Trial #, EventCode, and ITI
    OutFile = transpose(ProbeTime);
    fprintf('\n\nSaving files.\nDo not close Matlab yet.\n\n')
    DataSave(OutFile, [FileName  '.dat'], LocalPath);
    WaitSecs(.5);
    
    %% Save baseline dat files local computer and copy to server
    fprintf('\n\nCopying files to the server.\nDo not close Matlab yet.\n\n')
    DataCopy ([FileName '.dat'], LocalPath, ['/home/ra/CurtinServer/KAYE2RawData/' SubID]);
    fprintf('\n\nCopying complete. Data successfully copied to the server!\n\n')
    
catch TheError
    
    if exist ('SoundCardPlay', 'var')
        PsychPortAudio('Close', SoundCardPlay); %Close SoundCardPlay
    end
    
    Screen('CloseAll'); %Close display windows
    Priority(0); %Shutdown realtime mode
    ShowCursor(W); %Show cursor again, if it has been disabled
    
    %try to save dat files in case of PTB error
    DataSave(OutFile, [FileName  '.dat'], LocalPath);
    
    rethrow(TheError);
end