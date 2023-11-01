function NRT1_Baseline
%SubID = ABCDE
%A = Smoking Group (1 = Deprived, 2 = Non-Deprived)
%B = Treatment (1 = Active, 2 = Placebo)
%C = Gender (0 = Female, 1 = Male)
%D = Order (1-4, refers to trial/probe structure in task)
%E = SubID
%
%Day = 1 or 2
%Training = y (yes) or n (no)

%NRT1 baseline task
%JTK & KM
%Modified from Kaye1_Baseline as template

%% Generate Startle Probe Presentation Time
SubID = input('Enter SubID (5 digits)\n', 's'); %RA input SubID as str
Day = input('Enter Day (1 or 2)\n'); %RA input Day as double
Training = input('Enter Training (y or n)\n', 's'); %RA input Training as str

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
RootPath = fileparts(which('NRT1_Baseline.m'));
LocalPath = ['C:\Local\LocalNRT1\BaselineData\' SubID '\' ];

if Training ~= 'y'
    switch Day
        case{1} %Day = 1
            FileName = ['NRT1_Base1_' SubID '.dat'];
            OutFile = [LocalPath FileName];
            if  exist(fullfile(OutFile),'file')
                error('Filename: %s exists.  This must be an error!', FileName)
            end
            if  exist(fullfile([LocalPath 'NRT1_Base2_' SubID '.dat']),'file')
                error('Filename: %s exists. This must be an error!', ['NRT1_Base2_' SubID '.dat'])
            end
            
        case{2} %Day = 2
            FileName = ['NRT1_Base2_' SubID '.dat'];
            OutFile = [LocalPath FileName];
            if  exist(fullfile(OutFile),'file')
                error('Filename: %s exists.  This must be an error!', FileName)
            end
            if  ~exist(fullfile([LocalPath 'NRT1_Base1_' SubID '.dat']),'file')
                error('Filename: %s does NOT exist. This must be an error!', ['NRT1_Base1_' SubID '.dat'])
            end
        otherwise
            error('Day (%d) must be 1 or 2', Day)
    end
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
    FixationImg =  imread([RootPath '/NRT1/FixationCross.JPG'], 'JPG');
    FixTexture = Screen('MakeTexture', W, FixationImg);
    clear FixationImg
    
    %Black screen for block transitions
    BlackImg =  imread([RootPath '/NRT1/BlackImage.JPG'], 'JPG');
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
    FileName = ['NRT1_Base' num2str(Day) '_' SubID];
    DataSave(OutFile, [FileName  '.dat'], LocalPath);
    WaitSecs(.5);
    
    %% Save baseline cnt and dat files local computer and copy to server
    fprintf('\n\nCopying files to the server.\nDo not close Matlab yet.\n\n')
    DataCopy ([FileName '.cnt'], 'N:\NRT1\NRT1RawData\', ['P:\StudyData\NRT1\RawData\' SubID]);
    DataCopy ([FileName '.dat'], LocalPath, ['P:\StudyData\NRT1\RawData\' SubID]);
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