%Usage: [EndTime] = PauseMsg(W, MsgText, [TxtColor], [BackColor], [NextTexture], [StartPause])
%Puts MsgText centered on the screen indicated by WPtr in TxtColor (default is White) 
%with BackColor (default is black) and pauses until any key is pressesd.  
%Flips back to NextTexture (Texture Index) if provided or previous display in back buffer (if no NextTexture provided
%after key press and returns current time (EndTime).  Will pause ASAP if
%StartPause = 0 (default), otherwise pause starts at next retrace after
%system clock = StartPause

%Revision History
%2008_1203: Released version 1, JJC
%2010-03-16:  Added coded to erase message on unpause
%2010-03-23:  Added a background color parameter
%2010-04-11:  added code to wait till key is relased before resume, JJC
%2010-04-13:  Modified KbWait parameter (forWhat) to 3, JJC
%2010-04-13:  Added back FillRect before drawformatted text to erase previous info, JJC
%2010-06-16:  Added BackColor as an argument in the FillRect command;
%             BackColor was formerly passed as an input argument for
%             PauseMsg but not used, MJS
%2010-12-09:  Modified to return back to  previous display and returns end
%             time, DB, JJC
%2010-12-09   Added extra parameter for "Flip" so back screen is not erased DB 

function [EndTime] = PauseMsg(W, MsgText, TxtColor, BackColor, NextTexture, StartPause)
    if nargin < 6
        StartPause = 0;  %Flip ASAP
    end

    if nargin < 5
        NewDisplay = 0;  %dont draw  new texture if not provide
    else
        NewDisplay = 1;
    end
    
    if nargin < 4  
        TxtColor = [255 255 255]; %If TxtColor not provided, set to White
        BackColor = [0 0 0]; %If BackColor not provided, set to Black
    end
    
    if isempty(TxtColor)
        TxtColor = [255 255 255];
    end
    
    if isempty(BackColor)
        BackColor = [0 0 0];
    end
    
    Screen('FillRect', W, BackColor);
    DrawFormattedText(W, MsgText, 'center', 'center', TxtColor, 50,[],[],1.5);
    Screen('DrawingFinished', W);
    Screen('Flip', W, StartPause, 2); %USE OF 2 is IMPORTANT AND CORRECT
    
    if NewDisplay
        %TheImage=Screen('MakeTexture', W, NextImage);
        Screen('DrawTexture', W, NextTexture); %post image slide to the screen
        Screen('DrawingFinished', W); %to mark the end of all drawing commands
    end

    KbWait([], 3);  %waits until all keys released, key pressed and then key released    
    EndTime = Screen('Flip', W);   %return to display from before PauseMsg or NextTexture
end
