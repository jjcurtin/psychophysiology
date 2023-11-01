function [Rate] = ShockOnceCMD(Intensity, Location, GetRating)
%USAGE: ShockOnceCMD(Intensity)
%Administer a single shock of INTENSITY (0-255) from Matlab command line. 
%Timing may not be high precision.  Use for test purposes only.
%Can administer to 1 of 4 locations (0-3) via router if provided 
%(default = -1; dont use router)
%Returns participant rating if rating requested

%Revision History
%2011-06-20:  updated to use DAQ and new hardware, JJC

%% Timing parameters
PrepMsgDur =  1;  %Duration of preparation message
ShockMsgDur = .5;  %Shock is displayed on screen for .5s

try
    if nargin < 1
        help ShockOnce
        error('Must provide numeric Intensity (0-255) as argument to ShockOnce\n')
    end
    
    if nargin < 2
        Location = -1;
        GetRating = 0;
    end
  
    if nargin < 3
        GetRating = 0;
    end    
    %% Set up IO
    [DIO PortA PortB PortC] = ConfigIO(128); %Set up DIO card (PortB=Neuroscan; PortA = Shocker)

   %IOOut(IOCard,PortC,0,UseIO) %set shock port to 0       
    io32(DIO,PortC,0);   %code to output Holdvalue to Port B(Neuroscan event port)
 
    %% Shock admin code

    %Prepare for shock
    if Location > -1
        sprintf('Setting shock location (%d)\n\n', Location)  
        io32(DIO,PortA,Location);
        WaitSecs(6)
    end
    sprintf('Prepare for Shock Intensity = %d, in 3 seconds\n\n', Intensity)
    WaitSecs(PrepMsgDur)

    sprintf('SHOCK\n\n')
    %IOOut(PortC,Intensity,UseIO)  %shock IO
    io32(DIO,PortC,Intensity); 
    WaitSecs(ShockMsgDur); 
    io32(DIO,PortC,0); 
    
    %Rate intensity and display if requested
    %WaitSecs('UntilTime', ShockMsgTime+ShockMsgDur);
    
    if GetRating
        Rate = input('Please rate the shock intensity (0 - 100): ');
        if Rate > 100
            Rate = input('\n\nError: Please reenter the shock intensity: ');
        end    
        sprintf('\nParticipant''s rating was %d\n', Rate)  %Show rating immediately after entered
    end
     
    %% Finish up
     clear mex   %remove IO

catch TheError
     clear mex   %remove IO
    rethrow(TheError);        
end
