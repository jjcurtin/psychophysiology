%Usage: PauseMsgCmd(MsgText)
%Puts MsgText on command line and pauses until any key is pressesd.

%Revision History
%2009_0317: Released version 1, JJC
%2010-04-21: updated to use same code as PauseMsg (without screen), JJC

function PauseMsgCmd(MsgText)  
    fprintf([MsgText '\n']);
%     while KbCheck; end;  %Make sure Key is not already down
%     KbWait;              %Wait for key press
%     while KbCheck; end;  %Wait to return until key released
    
    KbWait([], 3);  %waits until all keys released, key pressed and then key released         
end
