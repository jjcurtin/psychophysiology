%USAGE: TestWhiteNoise (Analyze = true,SMA = False)
%Used to verify probe onset latency and consistency relative to event code .
%Presents ten 50ms white noise probes separated by 2s.  Each probe is marked by an event
%code (100). Uses ASIO low latency driver.  Uses WNProbe.wav file, which
%must be in the path.
%
%Inputs
%Analyze: should data be analyzed in EEGLab.  Default is TRUE
%SMA: using snapmaster in piper lab. Default is False. If True, currently assumes
%that PRB channel is '7'. 

%Revision history
%2010-0329:  modified PsychPortAudio Open to rely on mostly default parameters, JJC
%2010-0329:  modified to use priority(2) for testing, JJC
%2010-04-21: minor code update and commenting, JJC
%2011-12-11: modified to allow testing with snapmaster (piper lab), DB 

function TestWhiteNoise(Analyze, SMA)
    if nargin < 1
        SMA = false;
        Analyze = true;
    end
    
    if nargin < 2 
        SMA = false;    
    end

    [DIO PortA PortB] = ConfigIO; %Set up DIO card
    
    if (SMA)
       SoundEvent = 1;
    else 
       SoundEvent = 100;
    end
    HoldValue = 0;
    io32(DIO,PortB,HoldValue);  %initialize DIO with Hold value
    
    %Force GetSecs and WaitSecs into memory to avoid latency later on:
    GetSecs;
    WaitSecs(0.1);
        
    %load white noise
    [y, freq] = wavread('wnprobe');  %assumes file is in path
    noise = y';
    InitializePsychSound(1);  %1=set for low-latency
    PsychPortAudio('Verbosity', 10);
    
    reqlatencyclass = 2;  %for low latency
    SoundCard = PsychPortAudio('Open', [], [], reqlatencyclass, [], [], []);
    PsychPortAudio('FillBuffer', SoundCard, noise);
    
    fprintf('\n\nWhite Noise Test will present ten white noise probes.\nEach onset is marked with event code 100 for NS and 1 for SMA\n');
    PauseMsgCmd('Press ANY Key to START Test\n');
    fprintf('\nWhite Noise Testing in Progress....\n');
    Priority(2);
    
    Now = GetSecs;
    for i=1:10
        Now = StartleProbe(Now + 2, SoundEvent, SoundCard, DIO, PortB);    
    end
   
    Priority(0);
    clear mex  %clear io32()
    
        
    if (Analyze) && ~(SMA)
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
        
    if  (Analyze) && (SMA)
        [FileName FilePath] = uigetfile('*.sma', 'Open data file');  %get file name and path
        EEG = pop_LoadSma([FileName,FilePath],400);
        %EEG = pop_LoadSma();
        EEG = pop_epoch(EEG, {'1'}, [-0.01 0.06], 'newname', 'Epoches', 'epochinfo', 'yes');  %epoch file
        EEG = pop_rmbase( EEG, [-10   0]);  %baseline correct
        EEG = pop_select( EEG, 'channel',{ 'PRB'});
        EEGPlot = squeeze(EEG.data);  %remove singleton dimension
        plot(EEG.times,EEGPlot)   %make plot             
    end 
    

    fprintf('\nTestWhiteNoise Complete\n');
end
