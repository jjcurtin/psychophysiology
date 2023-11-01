%Usage: TestInput()
%TestInput tests input to IO on Port specified by PortLetter  ('A', 'B', or 'C')
%accepts optional parameters of nPresses (Default = 1) to allow for
%multiple button presses without restart of function and Mask (default = 7)
%to allow input for lines other than 0-2.
%see ConfigIO() for more detail on output.

%Revision History
%2011-02-27, released, JJC, ABS
%2011-03-30, changed mask to 7, JJC, ABS
%2011-08-18:  added PortLetter argument, JJC

function TestInput(PortLetter, Mask, nPresses)

    [DIO PortA PortB PortC] = ConfigIO; %Set up DIO card  
    
    switch upper(PortLetter)
        case 'A'
            Port = PortA;
        case 'B'
            Port = PortB;
        case 'C'
            Port = PortC;
    end
    

     if nargin < 2
         Mask = 7;
         
     end
     
     if nargin < 3
         nPresses = 1; 
     end

   TimeOut = 5; 
   for i = 1:nPresses
        StartTime = GetSecs();
        sprintf('\n\nPRESS NOW\n\n')
        [RT Response Correct] = GetResponse(StartTime, TimeOut, 0, Mask, Port, DIO, 1);

        switch Response
            case 1
                IntResp = 0;
            case 2
                IntResp = 1;
            case 4
                IntResp = 2;
            case 8 
                IntResp = 3;
            case 16
                IntResp = 4;
            case 32
                IntResp = 5;
            case 64
                IntResp = 6;
            case 128
                IntResp = 7;
            otherwise
                IntResp = 999;
        end

        if Response > 0
            fprintf('Input detected on line %d at %d seconds\n\n', IntResp, RT)
        else
            fprintf('No response detected during %d second response window\n\n', TimeOut)
        end
   end
    
   fprintf('TestInput Complete.  Have a nice day.\n');
   clear mex
end