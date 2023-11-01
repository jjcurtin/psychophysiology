%Usage: TestOutput(Output, [Port = B],[ControlWord = 144])
%TestOutput set Output on Port B or C with key press.  Default Port is B (neuroscan port).
%Second key press terminates Output.
%see ConfigIO() for more detail on output.

%Revision History
%2009-03-02: released, JJC, version 1
%2010-04-21: substantial revision, JJC
%2011-08-18:  allow PortA for output, JJC

function TestOutput(Output, Port, ControlWord)
   
    if nargin < 1
        error('Must provide Output as argument\n')
    end
    
    if nargin < 2
        Port = 'B'; %default is neuroscan port
        ControlWord = 144;
    end
     if nargin < 3
        ControlWord = 144;
     end
    [DIO PortA PortB PortC] = ConfigIO(ControlWord); %Set up DIO card 
    
    Port = upper(Port);
    switch Port
        case {'A'}
            PortOut = PortA;
        case {'B'}
            PortOut = PortB;
        case {'C'}
            PortOut = PortC;
        otherwise
            error('Invalid Port (%s)', Port);
    end
   
    PauseMsgCmd(sprintf('\n\nPress ANY Key to OUTPUT %d on Port %s\n\n', Output, Port));
    io32(DIO,PortOut,Output);
    
    PauseMsgCmd('Output ON.  Press ANY Key to END Output\n');
    
    io32(DIO,PortOut,0);  %Turn off all output
    fprintf('\nOutput Off.  TestOutput Complete.\n');

    clear mex
end