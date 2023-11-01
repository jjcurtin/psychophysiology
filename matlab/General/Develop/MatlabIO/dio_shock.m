%**********************************************************
%File: dio_shock.m
%Date: 10-03-08
%PCI-DIO24 with MATLAB
%This routine sends the signal for the shocker to shock.
%%**********************************************************

% Assume the system has been set up to shock.
% Trigger off, safety off and shock value placed on the bus.
putvalue(shocker_trigger, 1) ;  % Positive logic.  Trigger the shock.

% Run a timer to make sure the value propogates to the hardware.
% For now, approximately 50ms.
trigger_timer = timer('TimerFcn', @dio_max_safety, 'Period', 0.050);
start(trigger_timer) ;

% The setting of the shocker into a safe state is passed to dio_max_safety.