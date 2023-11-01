function Demo_RecordSound(SubID)

try

%% Startup

TimeOut = 1.5;

Words = [1,2,1];
ITIDur = 1.5;
CueDur = .5;

AssertOpenGL;    

%Open Window and configure text options
W = Screen('OpenWindow', 0, 0, [], 32, 2); 
HideCursor;

%load into memory for later high time precision use
WaitSecs(.1);
GetSecs;
KBcheck;

InitializePsychSound;
mode=2;  %Only audio capture
reqlatencyclass = 2;  %for low latency
freq = 44100;
nchannels=2;
pahandle = PsychPortAudio('Open', [], mode, reqlatencyclass, freq, nchannels);
PsychPortAudio('GetAudioData', pahandle, TimeOut+.5);     % Preallocate an internal audio recording  buffer with a capacity of TimeOut seconds: 

PauseMsg(W,'Press ANY Key to BEGIN',[0 0 0], [255 255 255]); 
Priority(2); %Enable realtime-scheduling for real trial 

%ITIStartTime = Screen('Flip',W,0);  %start first ITI ASAP
ITIStartTime = 0;

for i = 1:1 % first set of practice trials
    
    ITIStartTime = Screen('Flip',W,ITIStartTime);
    CueStartTime = ITIStartTime + ITIDur;
    
    switch Words(i)
        case 1
            Word = 'red';
        case 2
            Word = 'blue';
    end
           
    DrawFormattedText(W,Word,'center','center',[0 0 0],50);
    CueStartTime = Screen('Flip',W,CueStartTime); 
    ITIStartTime = CueStartTime + CueDur;

    [audiodata, ITIStartTime, RecordOffset] = RecordVerbalResponse(pahandle, CueStartTime, TimeOut, CueDur, W);
    
    wavwrite(transpose(audiodata), freq, 16, [num2str(SubID) '_' Word int2str(i) '.wav']);       
end


    
Screen('CloseAll'); %Close display windows
Priority(0); %Shutdown realtime mode
ShowCursor; %Show cursor again, if it has been disabled 
clear all

   
catch TheError
    Screen('CloseAll'); %Close display windows
    clear mex  %clear io32() 
    clear all
    Priority(0); %Shutdown realtime mode
    ShowCursor; %Show cursor again, if it has been disabled
    rethrow(TheError);            
end   
