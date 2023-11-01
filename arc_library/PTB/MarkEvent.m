function MarkEvent(IOCard, Port, EventCode, UseIO)
%Outputs EventCode to Port for .005s and then outputs 0 for a holdvalue.  
%If UseIO=false, will not execute. Useful for debugging on computers
%without IO.

    if nargin < 4
        UseIO = 1;
    end
        
    IOOut(IOCard, Port, EventCode, UseIO)
    WaitSecs(.005);
    IOOut(IOCard, Port, 0, UseIO);  %assumes holdvalue =0
end

