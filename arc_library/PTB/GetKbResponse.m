%Polls Keyboard until response deteced or TIMEOUT is reached.  
%Returns RT, keyCode mapping of key pressed, and info about accuracy.
%written by Mark Starr (starr2@wisc.edu)
%
%USAGE: function [RT KbResponse Correct] = GetKbResponse(StartTime,TimeOut, CorrectResponse)
%
%INPUTS:
%StartTime:  Time (in seconds) that response period began.  Can use GetSecs or supply time from earlier in script
%TimeOut:    Total time (in seconds) to wait for response.
%CorrectResponse:  String value of correct response (e.g., 'LeftArrow', 'RightArrow', etc)
%
%OUTPUTS
%RT:  Response time (in seconds).  If no response, RT = -1
%Response: Integer value of the key board response that was detected.  If not response, Response = [];
%Correct:  1= correct, 0= error, -1 = no response

%Revision History
%2010-04-13:  Released, MJs, version 1


function [RT KbResponse Correct] = GetKbResponse(StartTime, TimeOut, CorrectResponse)
    while KbCheck; end
    KbResponse = 0;  %initialize Response to No Response
    KbName('UnifyKeyNames');
    keyIsDown=0;
    while ((GetSecs - StartTime) < TimeOut) && keyIsDown~=1 %Loop until Response <>0 or TimeOut
        [ keyIsDown, timeSecs, keyCode ] = KbCheck;
        RT = timeSecs;   %Record Time
        KbResponse = find(keyCode);
        WaitSecs(.0001);   %wait to avoid locking computer.  Maybe not needed?
    end

    if keyIsDown > 0
        RT = RT - StartTime;
        if find(keyCode) == KbName(CorrectResponse)
            Correct = 1;
        else
            Correct = 0;
        end
    else
        RT = -1;
        Correct = -1;
        KbResponse = -999;
    end
end