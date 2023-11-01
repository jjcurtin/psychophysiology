function Shock(IOCard,ShockPort,ShockIntensity, EventPort, EventCode, UseIO)
%Outputs ShockIntensit shock to ShockPort immediately.  Marks Shock with
%EventCode on EventPort.  Delays 5ms and then sends 0 to both ShockPort and
%EventPort.

    IOOut(IOCard,ShockPort,ShockIntensity, UseIO); %admin shock
    IOOut(IOCard,EventPort,EventCode, UseIO);  %Mark shock onset
    WaitSecs(.005); 
    IOOut(IOCard,ShockPort,0, UseIO);
    IOOut(IOCard,EventPort,0, UseIO); 
end

