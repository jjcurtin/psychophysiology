%USAGE: TestWhiteNoiseLinux (Analyze = true,SMA = False, Grael = false)
%Used to verify probe onset latency and consistency relative to event code .
%Presents ten 50ms white noise probes separated by 2s.  Each probe is marked by an event
%code (1). Uses Linux low latency driver.  Uses WNProbe.wav file, which
%must be in the path.
%
%Inputs
%Analyze: should data be analyzed in EEGLab.  Default is TRUE
%SMA: using snapmaster in piper lab. Default is False. If True, currently assumes
%that PRB channel is '7'.
%Grael: using Grael EEG amplifer (mobile lab). Default is False.

%Revision history
%2016-07-26: Released, JTK
%2016-07-26: Created new file to test on linux OS, modified from TestWhiteNoise.m for PC/Windows, JTK

function TestWhiteNoiseLinux(Analyze, SMA, Grael)
if nargin < 1
    SMA = false;
    Analyze = true;
    Grael = false;
end

if nargin < 2
    SMA = false;
    Grael = false;
end
%PortA = Shock Box; PortB = Event Codes to Grael/Curry; PortC = Input
[DIO, PortA, PortB] = ConfigIO;

SoundEvent = 1;
HoldValue = 0;
DaqDOut(DIO, PortB, HoldValue); %initialize DIO with Hold value

%Force GetSecs and WaitSecs into memory to avoid latency later on:
GetSecs;
WaitSecs(0.1);

%load white noise
[y] = psychwavread('wnprobe.wav');  %assumes file is in path
freq = 44100; % a frequency of 44100 Hz
noise = y';
InitializePsychSound(1);  %1=set for low-latency
SoundCardDevices = PsychPortAudio('GetDevices'); %Get sound card devices if not using default
Index = not(cellfun('isempty',strfind({SoundCardDevices.DeviceName},'USB Audio CODEC: USB Audio'))); %Replace string with sound card name
SoundCardID = SoundCardDevices(Index).DeviceIndex; %Get sound card deviceID for PsychPortAudio(Open)
PsychPortAudio('Verbosity', 10);

reqlatencyclass = 2;  %for low latency
SoundCard = PsychPortAudio('Open', SoundCardID, 1, reqlatencyclass, freq, 2, []);
PsychPortAudio('FillBuffer', SoundCard, noise);

fprintf('\n\nWhite Noise Test will present ten white noise probes.\nEach onset is marked with event code 1 for Grael EEG and 1 for SMA\n');
PauseMsgCmd('Press ANY Key to START Test\n');
fprintf('\nWhite Noise Testing in Progress....\n');
Priority(2);

Now = GetSecs;
for i=1:10
    Now = StartleProbe(Now + 2, SoundEvent, SoundCard, DIO, PortB);
end

Priority(0);

if (Analyze) && ~(SMA) && ~(Grael)
    [FileName FilePath] = uigetfile('*.cnt', 'Open data file');  %get file name and path
    DataType = str2double(input('\Enter Data Type (16 or 32):  ', 's'));  %get file data type
    
    %open file
    if DataType == 16
        EEG = pop_loadcnt([FilePath FileName], 'dataformat', 'int16');
    else
        EEG = pop_loadcnt([FilePath FileName], 'dataformat', 'int32');
    end
    
    EEG = pop_epoch(EEG, {'100'}, [-0.01 0.06], 'newname', 'Epoches', 'epochinfo', 'yes');  %epoch file
    EEG = pop_rmbase( EEG, [-10   0]);  %baseline correct
    EEG = pop_select( EEG, 'channel',{ 'PRB'});  %select probe channel (NEUROSCAN)
    
    EEGPlot = squeeze(EEG.data);  %remove singleton dimension
    plot(EEG.times,EEGPlot)   %make plot
end

if  (Analyze) && (SMA) && ~(Grael)
    [FileName FilePath] = uigetfile('*.sma', 'Open data file');  %get file name and path
    EEG = pop_LoadSma([FileName,FilePath],400);
    %EEG = pop_LoadSma();
    EEG = pop_epoch(EEG, {'1'}, [-0.01 0.06], 'newname', 'Epoches', 'epochinfo', 'yes');  %epoch file
    EEG = pop_rmbase( EEG, [-10   0]);  %baseline correct
    EEG = pop_select( EEG, 'channel',{ 'PRB'});
    EEGPlot = squeeze(EEG.data);  %remove singleton dimension
    plot(EEG.times,EEGPlot)   %make plot
end


if  (Analyze) && ~(SMA) && (Grael)
    [FileName FilePath] = uigetfile('*.dat', 'Open data file');  %get file name and path
    EEG = pop_loadcurry([FilePath,FileName]);
    EEG = pop_epoch(EEG, {'1'}, [-0.01 0.06], 'newname', 'Epoches', 'epochinfo', 'yes');  %epoch file
    EEG = pop_rmbase( EEG, [-10   0]);  %baseline correct
    EEG = pop_select( EEG, 'channel',{ 'ORB'});
    EEGPlot = squeeze(EEG.data);  %remove singleton dimension
    plot(EEG.times,EEGPlot)   %make plot
end

fprintf('\nTestWhiteNoise Complete\n');
end
