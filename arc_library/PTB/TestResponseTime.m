%USAGE: [RTs] = TestResponseTime(NumTests)
%To be used with a response box that simulates particpant input.  When box
%is triggered, it produces an input exactly 434ms later.  Response box green plug is
%connected to PortB output B0 (pin 10) and the white plug is connected to PortA input A1 (pin 36).
%Also connected to +5v (pin 18) and GND (pin 19).
%Loops NUMTESTS times recording response.  Responses should be constant
%with no bias.  Stats reported to assess this
%John Curtin (jjcurtin@wisc.edu)

%Revision History
%2008-12-13: released version 1, JJC
%2010-03-29:  Changed function name to TestResponseTime, JJC
%2011_04-04: Change function to test line 1 of portA, abs (see change in line calling get response)
%2013_07-25: Changed comments at top to indicate correct place to plug in device
function [RTs] = TestResponseTime(NumTests)

    if nargin < 1
        NumTests = 200;  %set default # of Trials
    end

    %Load for later high precision use
    GetSecs;
    WaitSecs(.010);
    
    [DIO PortA PortB] = ConfigIO;
    io32(DIO,PortB,1)   %Set trigger line (Port B bit 0) high
    RTs = zeros(NumTests,1);
    
    fprintf('Press ANY key to start ResponseTest\n\n')
    while KbCheck; end;  %Make sure Key is not already down
    KbWait;              %Wait for key press
    while KbCheck; end;  %Wait to return until key released    
    
    for i = 1:NumTests
        fprintf('Measuring RT: %d\n', i)
        io32(DIO,PortB,0);  %Trigger response box (triggers low)
        CurTime = GetSecs;  %Get current time
        WaitSecs(.010);  %trigger is 10ms duration
        io32(DIO,PortB,1);  %Reset Trigger line
        
        %Poll for input on Line1 of PORTA with a Timeout of 1.5s
        RTs(i) = GetResponse(CurTime, 1.5, 2, 2, PortA, DIO,1,1);
        WaitSecs(.010);
    end
    
    fprintf('MEAN Response Time: %d\n', mean(RTs))
    fprintf('MIN Response Time: %d\n', min(RTs))
    fprintf('MAX Response Time: %d\n', max(RTs))
    fprintf('SD Response Time: %d\n', std(RTs))
    figure;
    hist(RTs, 50);
    clear mex
end