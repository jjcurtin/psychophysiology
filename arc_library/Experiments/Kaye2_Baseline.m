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
SubID = input('Enter SubID (5 digits)\n', 's'); %RA input SubID as str
Day = input('Enter Day (1 or 2)\n'); %RA input SubID as double
Training = input('Enter Training (y or n)\n', 's'); %RA input Training as str

%% Check that the appropriate time/day baseline task is being run
%Create Path to Local Directory on Computer
RootPath = fileparts(which('Kaye2_Baseline.m'));
LocalPath = ['C:\Local\LocalKaye2\BaselineData\' SubID '\' ]; %edit path to linux

if Training == 'n'
    
    switch Day
        case{1} %Day = 1
            FileName = ['Kaye2_Base1_Trials_' SubID '.dat'];
            CheckFile = [LocalPath FileName];
            if  exist(fullfile(CheckFile),'file')
                error('Filename: %s exists.  This must be an error!', FileName)
            end
            
        case{2} %Day = 2
            FileName = ['Kaye2_Base2_Trials_' SubID '.dat'];
            CheckFile = [LocalPath FileName];
            if  exist(fullfile(CheckFile),'file')
                error('Filename: %s exists.  This must be an error!', FileName)
            end
            if  ~exist(fullfile([LocalPath 'Kaye2_Base1_Trials_' SubID '.dat']),'file')
                error('Filename: %s does NOT exist. This must be an error!', ['Kaye2_Base1_Trials_' SubID '.dat'])
            end
            
        otherwise
            error('Day (%d) must be 1 or 2', Day)
            
    end
    
elseif Training == 'y' %If Training then allow same fake subID to be saved multiple times
    FileName = ['Kaye2_Base_Training_Trials' SubID '.dat']; %assumes that RawData folder has already been made prestudy!
end

%% Set up DIO card
%PortA = Button Box Input; PortB = Neuroscan Event Codes Output; PortC = Shock Box Output
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

BaselineStart = 54; %Event code to identify Neuroscan/Curry dat file in case it is saved w NPU by mistake

try
    %% Set sound card parameters for playing audio
    InitializePsychSound(1);  %1=set for low-latency
    PsychPortAudio('Verbosity', 10);
    
    SoundCardID = []; %Use default sound card on Windows
    modePlay = 1; %audio play back only
    freq = 44100; %a frequency of 44100 Hz
    reqlatencyclassPlay = 2; %for low latency (agressive but consider 3)
    nchannels = 2; %2 sound channels for stereo capture
    
    %% Load Startle Probe
    [y] = wavread('wnprobe');  %assumes file is in path
    Noise = y';
    SoundCardPlay = PsychPortAudio('Open', SoundCardID, modePlay, reqlatencyclassPlay, freq, nchannels);  %This returns a handle to the audio device. Open sound card in play back mode.
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
    FixationImg =  imread([RootPath '/Kaye2/FixationCross_1024x768.JPG'], 'JPG');
    FixTexture = Screen('MakeTexture', W, FixationImg);
    clear FixationImg
    
    %Black screen for block transitions
    BlackImg =  imread([RootPath '/Kaye2/BlackImage.JPG'], 'JPG');
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
    ShowCursor; %Show cursor again, if it has been disabled
    PsychPortAudio('Close', SoundCardPlay);
    Priority(0); %Shutdown realtime mode
    ListenChar(1); %check if this is still necessary
    clear mex  %clear io32()
    
    %% Write dat file to local computer with Trial #, EventCode, and ITI
    OutFile = transpose(ProbeTime);
    fprintf('\n\nSaving files.\nDo not close Matlab yet.\n\n')
    DataSave(OutFile, FileName, LocalPath);
    fprintf('\n\nSaving complete.\nData successfully saved locally, unless there is a warning message above.\n\n')
    WaitSecs(.5);
    
    %% Save baseline dat files local computer and copy to server
%     if ispc
%         if exist('P:\StudyData','dir') == 7 %if directory exists
%             fprintf('\n\nCopying files to the server.\nDo not close Matlab yet.\n\n')
%             DataCopy ([FileName], LocalPath, ['P:\StudyData\Kaye2\RawData\' SubID]);
%             fprintf('\n\nCopying complete.\nData successfully copied to the server, unless there is a warning message above.\n\n')
%         else
%             fprintf('\n\nComputer IS NOT connected to the server. Data NOT copied to the server.\n\n')
%         end
%     elseif isunix
%         if exist('/home/ra/CurtinServer','dir') == 7 %if directory exists
%             fprintf('\n\nCopying files to the server.\nDo not close Matlab yet.\n\n')
%             DataCopy ([FileName], LocalPath, ['/home/ra/CurtinServer/KAYE2RawData/' SubID]);
%             fprintf('\n\nCopying complete.\nData successfully copied to the server, unless there is a warning message above.\n\n')
%         else
%             fprintf('\n\nComputer IS NOT connected to the server. Data NOT copied to the server.\n\n')
%         end
%     end
    
catch TheError
    
    if exist ('SoundCardPlay', 'var')
        PsychPortAudio('Close', SoundCardPlay); %Close SoundCardPlay
    end
    
    Screen('CloseAll'); %Close display windows
    ShowCursor; %Show cursor again, if it has been disabled
    Priority(0); %Shutdown realtime mode
    ListenChar(1); %check if this is still necessary
    clear mex  %clear io32()
    
    %try to save dat files in case of PTB error
    DataSave(OutFile, FileName, LocalPath);
    
    rethrow(TheError);
end