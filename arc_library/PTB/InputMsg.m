%Usage: PauseMsg(WPtr, MsgText, [TxtColor])
%Puts MsgText centered on the screen indicated by WPtr in TxtColor (default is White) and
%accepts keyboard inputs until <enter> is pressesd.

%Revision History
%2010_0204: Released version 1, MJS

function reply=InputMsg(WPtr, MsgText, TxtColor)
    KbName('UnifyKeyNames');
    
    if nargin < 3  %If TxtColor not provided, set to White
        TxtColor = [255 255 255];
    end
    
    DrawFormattedText(WPtr, MsgText, 'center', 'center', TxtColor, 50);
    Screen('Flip', WPtr);
    while KbCheck; end;  %Make sure Key is not already down

    reply='';
    % Flush the keyboard buffer:
    FlushEvents;
    while 1	% Loop until <return> or <enter>
        char=GetChar;
        switch(abs(char))
            case 13	% <return> or <enter>
                break;
            case 8			% <delete>
                if length(reply)>0
                    reply=reply(1:length(reply)-1);
                end
            case 97
                break;
            otherwise
                reply=[reply char];
        end
    end
    %KbWait;              %Wait for key press
    %while KbCheck; end;  %Wait to return until key released
    
end
