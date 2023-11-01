 function TestBed

try 
   %% Initial set up of variables
    

    

    %% Load info from a .mat file
%     load(['P:\UW\StudyData\StimGen\RawData\' SubID2Str(SubID,4), '\ShockRatings' SubID2Str(SubID,4) '.mat'])
%     ShockIntensity = ShockRatings(end,2);
    
    %% Set up DIO card (PortB =event codes to neuroscan; PortC = shock)
%     [DIO PortA PortB PortC, IOStatus] = ConfigIO;   %Includes base address for left lab 
%     HoldValue = 0;  %Hold value for our NS setup
%     IOOut(DIO,PortB,HoldValue,IOStatus);   %code to output Holdvalue to Port B(Neuroscan event port)
  
    %% Set up for startle
%     [y, freq] = wavread('wnprobe');  %assumes file is in path
%     Noise = y';
%     InitializePsychSound(1);  %1=set for low-latency
%     PsychPortAudio('Verbosity', 10);
%     reqlatencyclass = 2;  %for low latency
%     SoundCard = PsychPortAudio('Open', [], [], reqlatencyclass, [], [], []);
%     PsychPortAudio('FillBuffer', SoundCard, Noise);
    
    %% START SCREEN
    AssertOpenGL;   %Check if PTB is properly installed on your system. 
    
    %Open Window and configure text options
    W = Screen('OpenWindow', 0, 0, [], 32, 2); 
    HideCursor;
    
    %load into memory for later high time precision use
    WaitSecs(.1);
    GetSecs;
    
    PauseMsg(W,'Press ANY Key to BEGIN Testing',[255, 255, 255]); 
    Priority(2); %Enable realtime-scheduling for real trial 
    
   
   %% TEST LOOP
    NumTrials = 5;
    %CurrentTime = GetSecs; 
    for i=1:NumTrials  
        
      Screen('Flip', W)
      %WaitSecs(3)
      DelayPause(W,3)
      DrawFormattedText(W, sprintf('Trial %d', i), 'center', 'center', [255 255 255], 50);
      Screen('Flip', W);  
      WaitSecs(2)         
    end

    %% Post Test Clean-Up
    %WaitSecs(3);
    
    Screen('CloseAll'); %Close display windows 
    Priority(0); %Shutdown realtime mode
    clear mex  %clear io32()
    ShowCursor; %Show cursor again, if it has been disabled
    
    %PsychPortAudio('Close', SoundCard);

        
    %Save Array as tab-delimited
    %dlmwrite('P:\UW\StudyData\StimGen\RawData\RiskData.dat',RiskData,'-append', 'delimiter', '\t')
   
    %Save Array as .mat file
    
catch TheError
    Screen('CloseAll'); %Close display windows 
    Priority(0); %Shutdown realtime mode
    clear mex  %clear io32()
    ShowCursor; %Show cursor again, if it has been disabled
    
    %PsychPortAudio('Close', SoundCard)
    rethrow(TheError);  
end   

    %% SAMPLES OF COMMON CODE  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Load and Present an Image
%     RawImage =  imread('images/ITIFix.jpg', 'JPG'); 
%     TheImage=Screen('MakeTexture', W, RawImage);
%     Screen('DrawTexture', W, TheImage); 
%     Screen('DrawingFinished', W);   
%     EventTime = Screen('Flip', W); 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %Loop of startle probes
%     HabitITIDur = 5; 
%     HabitSTLEvent = 100;  %Event code for startle probe
%     EventTime = GetSecs;
%     for i=1:3
%         EventTime = StartleProbe(EventTime+HabitITIDur, HabitSTLEvent, SoundCard, DIO, PortB);
%         HabitITIDur = 15; %separate all subsequent probes by 15s          
%     end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Mark an event
%     EventCode = 1;
%     HoldValue = 0;
%     io32(DIO,PortB,EventCode); WaitSecs(.005);  io32(DIO,PortB,HoldValue);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Get a response
%     RespData = zeros(10,3);   %array to  hold 10 trials of RT, Resp, and Correct
%     cntResp = 1; %coutner for response trials
%     RespStartTime = GetSecs; %get current time
%     [RT Resp Correct] = GetResponse(RespStartTime, 4, 1, 7, PortA, DIO,1);  %timeout = 4s, correct response = , mask for lines 0,1,2;  CHECK THIS
%     RespData(cntResp,:) = [RT Resp Correct];  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %sample case statement
%     switch CaseVar
%         case {1,2}
%             
%         case {3,4}
%             
%         otherwise
%             
%     end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Pause with message
    %PauseMsg(W,'Press ANY Key to BEGIN',[255, 255, 255]);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Draw formatted text
%     DrawFormattedText(WPtr, MsgText, 'center', 'center', TxtColor, 50);
%     Screen('Flip', WPtr);    
       
