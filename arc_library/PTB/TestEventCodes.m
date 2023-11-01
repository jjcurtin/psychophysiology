%Usage: [ITIs] = TestEventCodes(EventCodes)
%TestEventCode will output EventCodes spaced by exactly 2.000s 
%Test script returns mean ITI between EventCodes
%see ConfigIO() for more detail on output.
%
%Inputs:
%EventCodes:  Array with Event codes to output.  Default =  [1:5 101:105]
%
%Outputs:
%ITIs:  vector with times between Events (for nEvents -1)

%Revision History
%2008-12-01: released, JJC, version 1
%2010-04-21:  substantial changes to code, JJC
%2010-04-22:  Fixed bug with ITI array dimensions, JJC
%2012-12-07:  Removed note that calling script without semi-colon will print aditional information,   DEB KPM 
%2012-12-07:  Fixed bug where ITIs array was only being populated with first 4 ITIs which lead to a bongus reported mean ITI,   DEB KPM
%2012-12-14:  Modified ITI's array to allow any event codes number DEB, KPM
function TestEventCodes(EventCodes)

if (nargin < 1)
    EventCodes = [1:5 101:105];  %Default values for Event Codes
end

    [DIO PortA PortB PortC] = ConfigIO; %Set up DIO card
    HoldValue = 0;  %Hold value for our NS setup
    io32(DIO,PortB,HoldValue);  %Output hold value to Port B (neuroscan port)
    
    %Force GetSecs and WaitSecs into memory to avoid latency later on:
    GetSecs;
    WaitSecs(0.1);
    
    EventTimes = zeros(length(EventCodes));  %Initialize EventTimes array
    
    fprintf('\n\nTestEventCodes will output %d event codes as follows:', length(EventCodes));
    EventCodes    %Print event codes to screen
    fprintf('\nThese event codes should be separated by exactly 2.000s\n');
    fprintf('Stats on time between events (ITI) returned to screen on test completion\n\n')
    PauseMsgCmd('Press ANY Key to START Event Code Test\n');

    fprintf('\nEvent Code Testing in Progress......\n\n');
    
    Priority(2); %move into realtime mode
    Now = GetSecs;
    Now = Now +2;  %schedule first event code for 2s after keypress above
    for i=1:length(EventCodes)
        EventTimes(i) = WaitSecs('UntilTime', Now);
        io32(DIO,PortB,EventCodes(i));  %output event code to Port B (neuroscan port) 
        fprintf('Output Event Code: %d\n',EventCodes(i))
        WaitSecs(.010); 
        io32(DIO,PortB,HoldValue); %output hold value to Port B
        Now = EventTimes(i) + 2; %schedule next event for 2s after last event
    end
    
    Priority(0);
    clear mex
    fprintf('Event Code Test Complete.\n\n');

    ITIs = zeros(length(EventCodes)-1, 1);
    for i=1:length(EventCodes)-1;
        ITIs(i) = EventTimes(i+1) - EventTimes(i);
    end
        
    fprintf('Expected ITI = 2.000\nMean Observed ITI = %d\n',mean(ITIs))
end
