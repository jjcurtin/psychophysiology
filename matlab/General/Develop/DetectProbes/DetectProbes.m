%FIX THIS HELP!!!!!!!!!!!!!!!!!!!!!!!!!!!!!should go in functions for EEGLAB, also fix cases to title case 
%Demo M-file to insert event codes based on startles in the probe channel.
%Produces a set file with codes added. 
%Requires NumProbes (number of probes to be added)
%Requires EventCodes (the codes, in the order of occurance to be added). 
%Must change 4 variables in code
%Revision history

function [OutEEG] = DetectProbes(InEEG, EventCodes, ProbeChanName)
    
    if nargin < 2
        help DetectProbes
        error ('must provide EEG data structure AND array of numeric event codes')  
    end
    
    if nargin < 3
        ProbeChanName = 'PRB';  
    end
    
    OutEEG = InEEG;
    ChanNum =  GetChanNum(OutEEG,ProbeChanName); %Select probe channel.
    p = OutEEG.data(ChanNum,:); %select probe array of data structure
    pc = zeros(1,length(p)); %creating empty array for translated probe channel   
    for i= 2:length(p)
        pc(i) = p(1,i) - p(1,i-1); %fill array with change scores of each sample value relative to preceeding value
    end

    eventcnt = 0;
    i = 1;
    NumOrigEvents = length(OutEEG.event);
    NumOrigurEvents = length(OutEEG.urevent); 
    while (i < length(pc)) && (eventcnt < length(EventCodes));
        if abs(pc(i)) > 1000 %check for diff score greater than 1000 microvolts 
            eventcnt = eventcnt + 1;
            OutEEG.event(NumOrigEvents+eventcnt).type = EventCodes(eventcnt);
            OutEEG.urevent(NumOrigurEvents+eventcnt).type = EventCodes(eventcnt);
            OutEEG.event(NumOrigEvents+eventcnt).latency = i;
            OutEEG.urevent(NumOrigurEvents+eventcnt).latency = i;
            OutEEG.event(NumOrigEvents+eventcnt).urevent = eventcnt; 
            i = i+3*OutEEG.srate; %after one loop through, skip well past the end of the probe i.e., 3 sec 
        else
            i = i+1;
        end
    end
    OutEEG = eeg_checkset( OutEEG );
    
    
end