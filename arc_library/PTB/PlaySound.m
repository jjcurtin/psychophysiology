%Usage: [RealProbeTime] = StartleProbe(ProbeTime, EventCode, SoundCard, DIO, Port)
%Administers a startle probe at ProbeTime (in system clock seconds) and
%marks the administration with Event code.
%Assumes that SoundCard is already initialized and probe wav file is loaded into buffer.  
%Assumes hold value for NS of 0.  Must Provide DIO and Port address from ConfigIO
%Returns RealProbeTime, which is the time that the event code for the probe
%happened

%Revision History
%2010-03-18: Released version 1, JJC
%2011-02-27: updated to include IOStatus.  Will not sent events if IOStatus = 0;

function [RealProbeTime] = StartleProbe(ProbeTime, EventCode, SoundCard, DIO, Port,IOStatus)
    if nargin < 6
        IOStatus = 1;
    end
    PsychPortAudio('Start', SoundCard, 1, inf, 0);
    PsychPortAudio('RescheduleStart', SoundCard, ProbeTime, 0);
    RealProbeTime = WaitSecs('UntilTime', ProbeTime);
    IOOut(DIO,Port,EventCode, IOStatus); WaitSecs(.005); IOOut(DIO,Port,0, IOStatus);
    PsychPortAudio('Stop', SoundCard, 1);    
end
