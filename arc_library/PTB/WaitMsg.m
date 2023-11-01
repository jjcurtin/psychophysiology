%Usage: [EndTime] = WaitMsg(W, MsgText, WaitTime, [TxtColor], [BackColor], [NextTexture], [StartWait] )
%Puts MsgText centered on the screen indicated by WPtr 
%in TxtColor (default is White) on BackColor (default is Black) 
%and waits for WaitTime secs.  Returns to NextTexture if provided or previous
%display in back buffer (if NextTexture not provided) and returns current time (EndTime).  Will start wait period ASAP if StartWait
%=0 or at next retrace after system clock = StartWait

%Revision History
%2010-03-15: Released version 1, JJC
%2010-03-30: added 'BackColor' as parameter in function line, DB 
%2010-12-09: removed code for indefinite pause in WaitPause, DB, JJC
%2010-12-09   Added extra parameter for "Flip" so back screen is not erased DB

function [EndTime] = WaitMsg(W, MsgText, WaitTime, TxtColor, BackColor, NextTexture, StartWait)
    if nargin < 7
        StartWait = 0;
    end
    
    if nargin < 6
        NewDisplay = 0;  %dont draw  new texture if not provide
    else
        NewDisplay = 1;
    end

    if nargin < 5  %If TxtColor not provided, set to White
        TxtColor = [255 255 255];
        BackColor = [0 0 0];
    end
    
    if isempty(TxtColor)
        TxtColor = [255 255 255];
    end
    
    if isempty(BackColor)
        BackColor = [0 0 0];
    end    
    
    Screen('FillRect', W, BackColor);
    DrawFormattedText(W, MsgText, 'center', 'center', TxtColor, 50); 
    Screen('DrawingFinished', W);
    StartTime = Screen('Flip', W, StartWait, 2);  %2 is correct and IMPORTANT
    
    if NewDisplay
        %TheImage=Screen('MakeTexture', W, NextImage);
        Screen('DrawTexture', W, NextTexture); %post image slide to the screen
        Screen('DrawingFinished', W); %to mark the end of all drawing commands
    end    
    
    EndTime = Screen('Flip', W, StartTime + WaitTime);  %return display from before WaitMsg or NextTexture
   
end
