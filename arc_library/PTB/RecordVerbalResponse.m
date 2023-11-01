%USAGE: function [AudioData, FlipTime, RecordOffset] = RecordVerbalResponse(PAHandle, StartTime, TimeOut, FlipSOA, W)
% Saves verbal responses into array 

%INPUTS:
%PAHandle: handle of the device to start. should be set up at the start of your script (pahandle = PsychPortAudio('Open', [], mode, reqlatencyclass, freq, nchannels);)
%StartTime: time to start looking for a response (e.g. CueOnsetTime)
%TimeOut: total length of time to look for a response
%FlipSOA: time to flip to previously prepared back buffer if requested (so can present ITI or another stim and still be looking for a response)
%W= prepares a screen (back buffer) if FlipSOA is executed

%OUTPUTS
%AudioData: 2D array including number of channels and data 
%FlipTime: time of the recorded flip 
%RecordOffset: difference between the time recording was initialized and the inputed start time (hopefully 0)

%NOTE: JJC believes that RecordOffset is not specified correctly b/c
%RecordStartTime will always be 0 if we dont use WaitForStart.  Check this!

%Revision History
%22-03-11: created by ABS and JJC
%28-03-11: fixed startime bug, JJC

function [AudioData, FlipTime, RecordOffset] = RecordVerbalResponse(PAHandle, StartTime, TimeOut, FlipSOA, W)
   
    if nargin < 3
        error('Must provide PAHandle, StartTime, and TimeOut')
    end
    
    if nargin < 4
        FlipSOA = 0;
        W = [];
    end    
    
    if FlipSOA > TimeOut
        error('FlipSOA must be < TimeOut')        
    end
    
    RecordStartTime = PsychPortAudio('Start', PAHandle);   
     
    if FlipSOA  %Flip to previously prepared back buffer if requested
        FlipTime = Screen('Flip',W,StartTime + FlipSOA);
    end
     
    WaitSecs('UntilTime', StartTime+TimeOut);    
    PsychPortAudio('Stop', PAHandle);    
    AudioData = PsychPortAudio('GetAudioData', PAHandle);   
    
    RecordOffset = RecordStartTime - StartTime ;
end
