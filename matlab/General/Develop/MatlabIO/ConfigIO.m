function [DIO PortA PortB PortC, UseIO] = ConfigIO(ControlWord)
%Usage:  [DIO PortA PortB PortC, UseIO] = ConfigIO
%version 2, JJC
%This function initialize the DIO24 card for input/output from Measurement 
%Computing.  BaseAddress can be passed as a parameter.  If no base address
%supplied, will look for base address in file: 'c:\local\configIO.dat'
%If no file found, will prompt for input of base address.
%It configures PortA for input, and Ports B&C for output.  
%It returns the decimal values of the port addresses and also a pointer 
%to the DIO object.  UseIO = 0 if no drivers found.  
%BaseAddress is the base address of the I/O card which
%can be obtained from instacal
%This function %uses a Mex-File Plug-in for Fast MATLAB Port I/O Access 
%that can be obtained here: 
%http://www.usd.edu/~schieber/psyc770/IO32.html

%Revision History
%2008-12-01:  Released, JJC Version 1
%2010-03-23:  Added BaseAddress argument, JJC 
%2010-04-09:  Added code to prompt user for lab if no BaseAddress provided,JJC
%2010-04-21:  Modified to allow function to check for IO card base address on local computer hard drive, JJC
%2011-02-27:  Modified to return IOStatus=0 rather than error if no io drivers found, JJC, ABS
%2022-02-28:  Modifed to check if MAC before calling io32(), JJC
%2011-03-8:   added unify key names so that scripts can be run on all computers using keyboard, ABS (with JJC sitting right here) 



%NOTES On IO Configuration
%	                                                                D7	D6	D5	D4	D3	D2	D1	D0
%Port A input; Ports B&C output	                                    1	0    0	1	0	0	0	0  (144)
%Port A Output, Port B Output, Port C Lo Output, Port C Hi Input	1	0    0	0	1	0	0	0 (136)

    if nargin < 1
        ControlWord = 144;
    end
    
    if nargin ==1 && ~(ControlWord == 144 || ControlWord == 136)
        error ('Control Word must be 144 or 136\n')
    end
    
    %check that control word 
    if (nargin == 1) && ischar(ControlWord)
        error('Control Word must be numeric.  Base address is  no longer a valid argument for function\n')
    end
    
    %set up universal keyboard
    KbName('UnifyKeyNames');

    %Configure IO
    if ispc()  %only call io32() if its a pc
                digitalio('mcc',0);   %necessary for IO on 2010B and later......
        DIO = io32();  %create an instance of the io32 object
        IOStatus = io32(DIO); %initialize the inpout32.dll system driver.  Returns 0 if successful
    else
        IOStatus = 1;  %if mac, no IO so set error flag
    end

    if IOStatus == 0   %PC and successful above
        UseIO = 1;  %to indicate that IO can be used by other functions
        fileID = fopen('c:\local\configIO.dat', 'r');   %get FID from local file

        if fileID < 0  %couldnt find the file so prompt user for lab location
            Lab = input('\nEnter lab location:  (L)eft, (R)ight, or (B)asement:  ', 's');
            Lab = upper(Lab);
            switch Lab
                case {'L'}
                    BaseAddress = 'dc00';
                case {'R'}
                    BaseAddress = 'da00';
                case {'B'}
                    BaseAddress = 'ce3c';
                otherwise
                    error('Lab (%s) must be L, R, or B\n', Lab)                
            end            
        else 
            Temp = textscan(fileID,'%s');
            BaseAddress = Temp{1}{1};     
            fclose(fileID);
        end
        
        fprintf('\nIO card configured for Base Address: %s\n\n', BaseAddress);
        PortA = hex2dec(BaseAddress);
        PortB = PortA + 1;
        PortC = PortA + 2;
        PortD = PortA + 3;

        io32(DIO,PortD,ControlWord);  %Configures ports as defined above for 144 or 136 Control words
    
    else   %if no IO, initial these variables to 0.  They wont be used but must be assigned
        warning('IO initialization failure')
        UseIO = 0;
        DIO = 0;
        PortA = 0;
        PortB = 0;
        PortC = 0;
        PortD = 0;
    end

      %example output
%     EventCode = 1;
%     ResetCode = 255;
%     io32(DIO,PortB,ResetCode);  %provide Hold value to start
%     WaitSecs(5);
%     io32(DIO,PortB,EventCode); WaitSecs(.010); io32(DIO,PortB,ResetCode);
%     WaitSecs(5);
%     io32(DIO,PortB,EventCode); WaitSecs(.010); io32(DIO,PortB,ResetCode);
%     WaitSecs(5);
%    
%     %example input
%     InputA = io32(DIO,PortA)

%     see also IOOut() from our lab.
end
