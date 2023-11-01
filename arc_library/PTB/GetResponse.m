%USAGE: function [RT Response Correct] = GetResponse(StartTime, TimeOut, CorrectResponse, Mask, Port, Device, Reverse, UseIO, InputDevice)
%Polls PORT every .1ms on valid input lines (via MASK) until response
%deteced or TIMEOUT is reached.  Returns RT, integer value of for response,
%and info about accuracy.
%
%INPUTS:
%StartTime:  Time (in seconds) that response period began.  Can use GetSecs or supply time from earlier in script
%TimeOut:    Total time (in seconds) to wait for response.
%Correct:    0 = error, 1=correct
%Response:  Integer value of correct response (e.g., line0 =1, line1
%= 2, line2= 4, etc).  Use 0 if correct response is no response.
%Mask:  Integer value mask of lines to monitor for input
%Port:  Integer value  of the Port address for input
%Device:  IO object (e.g; DIO from ConfigIO command)
%Reverse:  1= Reverse logic, low = pushed, high = not pushed; 0= normal logic
%UseIO:  if False, will use Keyboard rather than IO for input
%InputDevice: 0 = Keyboard, 1 = Button Box (default), 2 = USB Mouse
%
%OUTPUTS
%RT:  Response time (in seconds).  If no response, RT = TIMEOUT
%Response: Integer value of the response that was detected.  If not response, Response = 0;
%Correct:  1= correct, 0= error.  Based on comparing Response to CorrectResponse
%written by John Curtin (jjcurtin@wisc.edu)

%Revision History
%2008-12-13:  Released, JJC, version 1
%2009-03-12:  Added Device to parameter list
%2009-04-12:  Added support for reverse logic as a parameter
%2010-01-10: Changed coding of Correct to allow no response to be correct if CorrectResponse = 0
%2011-02-27:  Modified to add IOStatus for using keyboard with no IO drivers, JJC, ABS
%2011-03-08: Modified to used left and right shift labels rather than code numbers (see line 54), ABS,JCC
%2011-03-23: modified output parameters of KbCheck (line 53) to be [foo,RT,keyCode] rather than [~,RT,keyCode]; org parameters caused script to crash, MJS

function [RT Response Correct] = GetResponse(StartTime, TimeOut, CorrectResponse, Mask, Port, Device, Reverse, UseIO, InputDevice)
if nargin < 9
    InputDevice = 1; %Default to IO Button Box, backward compatibility - added to allow mouse input (not implemented)
end

if nargin < 8
    UseIO = 1;
end

if nargin < 7
    Reverse = 1;
end

Response = 0;  %initialize Response to No Response

while ((GetSecs - StartTime) < TimeOut) && ~Response %Loop until Response <>0 or TimeOut
    
    if UseIO && ispc % IO drivers installed and PC computer
        Response = io32(Device,Port);
        RT = GetSecs;   %Record Time
        if Reverse
            Response = bitcmp(Response,8);
        end
        Response = bitand(Response,Mask);
        WaitSecs(.0001);   %wait to avoid locking computer.  Maybe not needed?
        
    elseif UseIO && isunix %IO driver installed and Linux computer
        Response = DaqDIn(Device, [], Port); %DaqDIn([DeviceIndex],[NumberOfPorts],[port])
        RT = GetSecs;   %Record Time
        if Reverse
            Response = bitcmp(Response,'uint8');
        end
        Response = bitand(Response,Mask);
        WaitSecs(.0001);   %wait to avoid locking computer.  Maybe not needed?
        
    else  %use keyboard
        KbName('UnifyKeyNames');  %Important for use across Linux and Windows
        [~, RT, keyCode] = KbCheck;
        if strcmp('LeftShift', KbName(keyCode)) % left shift
            Response = 2;
        end
        
        if strcmp('RightShift', KbName(keyCode))% right shift
            Response = 4;
        end
        WaitSecs(.0001);   %wait to avoid locking computer.  Maybe not needed?
    end
end

if Response > 0
    RT = RT - StartTime;
else
    RT = TimeOut;
end

if Response == CorrectResponse
    Correct = 1;
else
    Correct = 0;
end

end
